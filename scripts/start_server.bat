@echo off
setlocal
echo ==============================================
echo   ARGUS AI - Starting Serverpod Backend
echo ==============================================
cd /d "%~dp0..\argus\argus_server"
serverpod start --no-docker
pause
