'use strict';

const http = require('http');
const fs = require('fs');
const path = require('path');
const net = require('net');
const childProcess = require('child_process');

const ROOT = path.resolve(__dirname);
const PREFERRED_PORT = 3000;

const MIME = {
  '.html': 'text/html; charset=utf-8',
  '.htm': 'text/html; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.js': 'text/javascript; charset=utf-8',
  '.mjs': 'text/javascript; charset=utf-8',
  '.cjs': 'text/javascript; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.map': 'application/json; charset=utf-8',
  '.xml': 'application/xml; charset=utf-8',
  '.txt': 'text/plain; charset=utf-8',
  '.svg': 'image/svg+xml',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.gif': 'image/gif',
  '.webp': 'image/webp',
  '.avif': 'image/avif',
  '.ico': 'image/x-icon',
  '.woff': 'font/woff',
  '.woff2': 'font/woff2',
  '.ttf': 'font/ttf',
  '.otf': 'font/otf',
  '.eot': 'application/vnd.ms-fontobject',
  '.wasm': 'application/wasm',
  '.riv': 'application/octet-stream',
  '.glb': 'model/gltf-binary',
  '.gltf': 'model/gltf+json',
  '.ktx2': 'image/ktx2',
  '.basis': 'application/octet-stream',
  '.bin': 'application/octet-stream',
  '.hdr': 'image/vnd.radiance',
  '.exr': 'image/x-exr',
  '.mp4': 'video/mp4',
  '.m4v': 'video/x-m4v',
  '.mov': 'video/quicktime',
  '.webm': 'video/webm',
  '.ogv': 'video/ogg',
  '.mp3': 'audio/mpeg',
  '.ogg': 'audio/ogg',
  '.wav': 'audio/wav',
  '.aac': 'audio/aac'
};

function commonHeaders(filePath) {
  return {
    'Content-Type': MIME[path.extname(filePath).toLowerCase()] || 'application/octet-stream',
    'Cache-Control': 'no-cache, no-store, must-revalidate',
    'Access-Control-Allow-Origin': '*',
    'Cross-Origin-Resource-Policy': 'cross-origin',
    'Accept-Ranges': 'bytes'
  };
}

function sendText(res, status, text) {
  const body = Buffer.from(text, 'utf8');
  res.writeHead(status, {
    'Content-Type': 'text/plain; charset=utf-8',
    'Content-Length': body.length,
    'Cache-Control': 'no-store'
  });
  res.end(body);
}

function safeFilePath(req) {
  let pathname;
  try {
    pathname = decodeURIComponent(new URL(req.url, 'http://localhost').pathname);
  } catch (_) {
    return { error: 400 };
  }

  if (pathname.indexOf(String.fromCharCode(0)) !== -1) return { error: 400 };
  let relative = pathname.split(String.fromCharCode(92)).join('/');
  while (relative.charAt(0) === '/') relative = relative.slice(1);
  if (!relative) relative = 'index.html';

  let candidate = path.resolve(ROOT, relative);
  if (candidate !== ROOT && !candidate.startsWith(ROOT + path.sep)) return { error: 403 };

  try {
    if (fs.statSync(candidate).isDirectory()) candidate = path.join(candidate, 'index.html');
  } catch (_) {}

  if (!fs.existsSync(candidate)) {
    const acceptsHtml = String(req.headers.accept || '').includes('text/html');
    if (acceptsHtml || !path.extname(relative)) {
      const fallback = path.join(ROOT, 'index.html');
      if (fs.existsSync(fallback)) candidate = fallback;
    }
  }

  if (!fs.existsSync(candidate)) return { error: 404 };
  return { filePath: candidate };
}

function parseRange(value, size) {
  const match = /^bytes=(\d*)-(\d*)$/i.exec(String(value || '').trim());
  if (!match) return null;
  let start;
  let end;

  if (match[1] === '' && match[2] !== '') {
    const suffix = Number(match[2]);
    if (!Number.isFinite(suffix) || suffix <= 0) return null;
    start = Math.max(0, size - suffix);
    end = size - 1;
  } else {
    start = Number(match[1]);
    end = match[2] === '' ? size - 1 : Number(match[2]);
  }

  if (!Number.isFinite(start) || !Number.isFinite(end) || start < 0 || start >= size || end < start) return null;
  return { start: start, end: Math.min(end, size - 1) };
}

const server = http.createServer(function (req, res) {
  if (req.method === 'OPTIONS') {
    res.writeHead(204, {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, HEAD, OPTIONS',
      'Access-Control-Allow-Headers': '*'
    });
    res.end();
    return;
  }

  if (req.method !== 'GET' && req.method !== 'HEAD') {
    sendText(res, 405, 'Metodo nao permitido');
    return;
  }

  const resolved = safeFilePath(req);
  if (resolved.error) {
    sendText(res, resolved.error, resolved.error === 404 ? 'Arquivo nao encontrado' : 'Requisicao invalida');
    return;
  }

  fs.stat(resolved.filePath, function (err, stat) {
    if (err || !stat.isFile()) {
      sendText(res, 404, 'Arquivo nao encontrado');
      return;
    }

    const headers = commonHeaders(resolved.filePath);
    const requestedRange = req.headers.range;
    const range = requestedRange ? parseRange(requestedRange, stat.size) : null;

    if (requestedRange && !range) {
      res.writeHead(416, Object.assign(headers, { 'Content-Range': 'bytes */' + stat.size }));
      res.end();
      return;
    }

    if (range) {
      headers['Content-Range'] = 'bytes ' + range.start + '-' + range.end + '/' + stat.size;
      headers['Content-Length'] = range.end - range.start + 1;
      res.writeHead(206, headers);
      if (req.method === 'HEAD') return res.end();
      fs.createReadStream(resolved.filePath, { start: range.start, end: range.end }).pipe(res);
      return;
    }

    headers['Content-Length'] = stat.size;
    res.writeHead(200, headers);
    if (req.method === 'HEAD') return res.end();
    fs.createReadStream(resolved.filePath).pipe(res);
  });
});

function choosePort() {
  return new Promise(function (resolve) {
    const preferred = net.createServer();
    preferred.unref();
    preferred.once('error', function () {
      const automatic = net.createServer();
      automatic.unref();
      automatic.listen(0, '127.0.0.1', function () {
        const port = automatic.address().port;
        automatic.close(function () { resolve(port); });
      });
    });
    preferred.listen(PREFERRED_PORT, '127.0.0.1', function () {
      preferred.close(function () { resolve(PREFERRED_PORT); });
    });
  });
}

function openBrowser(url) {
  if (process.env.SITECLONER_NO_OPEN === '1') return;
  try {
    if (process.platform === 'win32') {
      childProcess.spawn('cmd.exe', ['/c', 'start', '', url], { detached: true, stdio: 'ignore', windowsHide: true }).unref();
    } else if (process.platform === 'darwin') {
      childProcess.spawn('open', [url], { detached: true, stdio: 'ignore' }).unref();
    } else {
      childProcess.spawn('xdg-open', [url], { detached: true, stdio: 'ignore' }).unref();
    }
  } catch (_) {}
}

choosePort().then(function (port) {
  server.listen(port, '127.0.0.1', function () {
    const url = 'http://127.0.0.1:' + port + '/';
    console.clear();
    console.log('SiteCloner Pro');
    console.log('');
    console.log('Previa iniciada com sucesso:');
    console.log(url);
    console.log('');
    console.log('Mantenha esta janela aberta. Para encerrar, pressione Ctrl+C.');
    openBrowser(url);
  });
}).catch(function (err) {
  console.error('Nao foi possivel iniciar a previa:', err && err.message ? err.message : err);
  process.exitCode = 1;
});

process.on('SIGINT', function () {
  server.close(function () { process.exit(0); });
});
