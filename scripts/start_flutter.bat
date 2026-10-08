@echo off
setlocal
echo ==============================================
echo   ARGUS AI - Starting Flutter Web Client
echo ==============================================
cd /d "%~dp0..\argus\argus_flutter"
flutter run -d chrome
pause
