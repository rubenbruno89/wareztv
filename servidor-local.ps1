$ErrorActionPreference = "Stop"
$root = [System.IO.Path]::GetFullPath($PSScriptRoot)

$source = @'
using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Threading;

public static class SiteClonerPreviewServer
{
    private static string root;

    public static void Run(TcpListener listener, string rootPath)
    {
        root = Path.GetFullPath(rootPath);
        while (true)
        {
            TcpClient client = listener.AcceptTcpClient();
            ThreadPool.QueueUserWorkItem(delegate { Handle(client); });
        }
    }

    private static void Handle(TcpClient client)
    {
        using (client)
        {
            try
            {
                client.ReceiveTimeout = 15000;
                client.SendTimeout = 30000;
                NetworkStream stream = client.GetStream();
                StreamReader reader = new StreamReader(stream, Encoding.ASCII, false, 8192, true);
                string requestLine = reader.ReadLine();
                if (String.IsNullOrWhiteSpace(requestLine)) return;

                string[] parts = requestLine.Split(' ');
                if (parts.Length < 2) { SendText(stream, 400, "Bad Request", "Requisicao invalida"); return; }
                string method = parts[0].ToUpperInvariant();
                string target = parts[1];

                Dictionary<string, string> headers = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
                string line;
                while (!String.IsNullOrEmpty(line = reader.ReadLine()))
                {
                    int colon = line.IndexOf(':');
                    if (colon > 0) headers[line.Substring(0, colon).Trim()] = line.Substring(colon + 1).Trim();
                }

                if (method == "OPTIONS")
                {
                    WriteHeaders(stream, 204, "No Content", 0, "text/plain", null, null);
                    return;
                }
                if (method != "GET" && method != "HEAD")
                {
                    SendText(stream, 405, "Method Not Allowed", "Metodo nao permitido");
                    return;
                }

                string pathOnly = target.Split('?')[0];
                string decoded;
                try { decoded = Uri.UnescapeDataString(pathOnly); }
                catch { SendText(stream, 400, "Bad Request", "Requisicao invalida"); return; }
                if (decoded.IndexOf('\0') >= 0) { SendText(stream, 400, "Bad Request", "Requisicao invalida"); return; }

                string relative = decoded.Replace('/', Path.DirectorySeparatorChar).TrimStart(Path.DirectorySeparatorChar);
                if (String.IsNullOrEmpty(relative)) relative = "index.html";
                string candidate = Path.GetFullPath(Path.Combine(root, relative));
                string rootPrefix = root.TrimEnd(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar) + Path.DirectorySeparatorChar;
                if (!candidate.Equals(root, StringComparison.OrdinalIgnoreCase) && !candidate.StartsWith(rootPrefix, StringComparison.OrdinalIgnoreCase))
                {
                    SendText(stream, 403, "Forbidden", "Acesso negado");
                    return;
                }

                if (Directory.Exists(candidate)) candidate = Path.Combine(candidate, "index.html");
                if (!File.Exists(candidate))
                {
                    string accept = headers.ContainsKey("Accept") ? headers["Accept"] : "";
                    if (accept.IndexOf("text/html", StringComparison.OrdinalIgnoreCase) >= 0 || String.IsNullOrEmpty(Path.GetExtension(relative)))
                    {
                        string fallback = Path.Combine(root, "index.html");
                        if (File.Exists(fallback)) candidate = fallback;
                    }
                }
                if (!File.Exists(candidate)) { SendText(stream, 404, "Not Found", "Arquivo nao encontrado"); return; }

                FileInfo info = new FileInfo(candidate);
                long start = 0;
                long end = info.Length - 1;
                bool partial = false;
                string rangeValue = headers.ContainsKey("Range") ? headers["Range"] : null;
                if (!String.IsNullOrEmpty(rangeValue))
                {
                    if (!TryParseRange(rangeValue, info.Length, out start, out end))
                    {
                        WriteHeaders(stream, 416, "Range Not Satisfiable", 0, Mime(candidate), "bytes */" + info.Length.ToString(CultureInfo.InvariantCulture), null);
                        return;
                    }
                    partial = true;
                }

                long length = end - start + 1;
                WriteHeaders(stream, partial ? 206 : 200, partial ? "Partial Content" : "OK", length, Mime(candidate),
                    partial ? "bytes " + start.ToString(CultureInfo.InvariantCulture) + "-" + end.ToString(CultureInfo.InvariantCulture) + "/" + info.Length.ToString(CultureInfo.InvariantCulture) : null,
                    "bytes");
                if (method == "HEAD") return;

                using (FileStream file = new FileStream(candidate, FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
                {
                    file.Seek(start, SeekOrigin.Begin);
                    byte[] buffer = new byte[65536];
                    long remaining = length;
                    while (remaining > 0)
                    {
                        int read = file.Read(buffer, 0, (int)Math.Min(buffer.Length, remaining));
                        if (read <= 0) break;
                        stream.Write(buffer, 0, read);
                        remaining -= read;
                    }
                }
            }
            catch { }
        }
    }

    private static bool TryParseRange(string value, long size, out long start, out long end)
    {
        start = 0;
        end = size - 1;
        if (!value.StartsWith("bytes=", StringComparison.OrdinalIgnoreCase)) return false;
        string[] pair = value.Substring(6).Split('-');
        if (pair.Length != 2) return false;
        if (pair[0].Length == 0)
        {
            long suffix;
            if (!Int64.TryParse(pair[1], out suffix) || suffix <= 0) return false;
            start = Math.Max(0, size - suffix);
            return true;
        }
        if (!Int64.TryParse(pair[0], out start) || start < 0 || start >= size) return false;
        if (pair[1].Length > 0 && (!Int64.TryParse(pair[1], out end) || end < start)) return false;
        end = Math.Min(end, size - 1);
        return true;
    }

    private static void SendText(Stream stream, int status, string reason, string message)
    {
        byte[] body = Encoding.UTF8.GetBytes(message);
        WriteHeaders(stream, status, reason, body.Length, "text/plain; charset=utf-8", null, null);
        stream.Write(body, 0, body.Length);
    }

    private static void WriteHeaders(Stream stream, int status, string reason, long length, string contentType, string contentRange, string acceptRanges)
    {
        StringBuilder h = new StringBuilder();
        h.Append("HTTP/1.1 ").Append(status).Append(' ').Append(reason).Append("
");
        h.Append("Content-Type: ").Append(contentType).Append("
");
        h.Append("Content-Length: ").Append(length.ToString(CultureInfo.InvariantCulture)).Append("
");
        h.Append("Cache-Control: no-cache, no-store, must-revalidate
");
        h.Append("Access-Control-Allow-Origin: *
");
        h.Append("Access-Control-Allow-Methods: GET, HEAD, OPTIONS
");
        h.Append("Access-Control-Allow-Headers: *
");
        h.Append("Cross-Origin-Resource-Policy: cross-origin
");
        if (!String.IsNullOrEmpty(contentRange)) h.Append("Content-Range: ").Append(contentRange).Append("
");
        if (!String.IsNullOrEmpty(acceptRanges)) h.Append("Accept-Ranges: ").Append(acceptRanges).Append("
");
        h.Append("Connection: close

");
        byte[] bytes = Encoding.ASCII.GetBytes(h.ToString());
        stream.Write(bytes, 0, bytes.Length);
    }

    private static string Mime(string file)
    {
        switch (Path.GetExtension(file).ToLowerInvariant())
        {
            case ".html": case ".htm": return "text/html; charset=utf-8";
            case ".css": return "text/css; charset=utf-8";
            case ".js": case ".mjs": case ".cjs": return "text/javascript; charset=utf-8";
            case ".json": case ".map": return "application/json; charset=utf-8";
            case ".svg": return "image/svg+xml";
            case ".png": return "image/png";
            case ".jpg": case ".jpeg": return "image/jpeg";
            case ".gif": return "image/gif";
            case ".webp": return "image/webp";
            case ".avif": return "image/avif";
            case ".ico": return "image/x-icon";
            case ".woff": return "font/woff";
            case ".woff2": return "font/woff2";
            case ".ttf": return "font/ttf";
            case ".otf": return "font/otf";
            case ".wasm": return "application/wasm";
            case ".glb": return "model/gltf-binary";
            case ".gltf": return "model/gltf+json";
            case ".ktx2": return "image/ktx2";
            case ".hdr": return "image/vnd.radiance";
            case ".exr": return "image/x-exr";
            case ".mp4": return "video/mp4";
            case ".m4v": return "video/x-m4v";
            case ".mov": return "video/quicktime";
            case ".webm": return "video/webm";
            case ".ogv": return "video/ogg";
            case ".mp3": return "audio/mpeg";
            case ".ogg": return "audio/ogg";
            case ".wav": return "audio/wav";
            case ".aac": return "audio/aac";
            default: return "application/octet-stream";
        }
    }
}
'@

Add-Type -TypeDefinition $source -Language CSharp

$listener = $null
try {
    try {
        $listener = New-Object System.Net.Sockets.TcpListener([System.Net.IPAddress]::Loopback, 3000)
        $listener.Start()
    }
    catch {
        if ($listener) { try { $listener.Stop() } catch {} }
        $listener = New-Object System.Net.Sockets.TcpListener([System.Net.IPAddress]::Loopback, 0)
        $listener.Start()
    }

    $port = ([System.Net.IPEndPoint]$listener.LocalEndpoint).Port
    $url = "http://127.0.0.1:$port/"
    Clear-Host
    Write-Host "SiteCloner Pro" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Previa iniciada com sucesso:" -ForegroundColor Green
    Write-Host $url -ForegroundColor White
    Write-Host ""
    Write-Host "Mantenha esta janela aberta. Para encerrar, pressione Ctrl+C."
    if ($env:SITECLONER_NO_OPEN -ne "1") { Start-Process $url }
    [SiteClonerPreviewServer]::Run($listener, $root)
}
finally {
    if ($listener) { try { $listener.Stop() } catch {} }
}
