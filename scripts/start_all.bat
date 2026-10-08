@echo off
setlocal
echo ==============================================
echo   ARGUS AI - Launching Full Stack
echo ==============================================
start "Argus Backend (Serverpod)" cmd /k "%~dp0start_server.bat"
timeout /t 3 /nobreak >nul
start "Argus Frontend (Flutter Web)" cmd /k "%~dp0start_flutter.bat"
