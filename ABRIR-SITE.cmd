@echo off
setlocal
title SiteCloner Pro - Previa local
cd /d "%~dp0"

if not exist "index.html" (
  echo.
  echo Nao foi possivel encontrar o index.html nesta pasta.
  echo Extraia todo o conteudo do ZIP antes de abrir a previa.
  echo.
  pause
  exit /b 1
)

where node.exe >nul 2>nul
if %errorlevel%==0 (
  node.exe "%~dp0servidor-local.js"
  exit /b %errorlevel%
)

where powershell.exe >nul 2>nul
if %errorlevel%==0 (
  powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0servidor-local.ps1"
  if %errorlevel%==0 exit /b 0
)

echo.
echo Nao foi possivel iniciar a previa automaticamente.
echo Consulte COMO-ABRIR.txt para usar um servidor alternativo.
echo.
pause
exit /b 1
