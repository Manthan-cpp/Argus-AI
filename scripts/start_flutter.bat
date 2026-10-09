@echo off
setlocal
echo ==============================================
echo   ARGUS AI - Starting Flutter Web Client
echo ==============================================
cd /d "%~dp0..\argus\argus_flutter"
if exist "%~dp0..\..\.env" (
  echo Found .env in workspace root. Loading definitions...
  flutter run -d chrome --dart-define-from-file="%~dp0..\..\.env"
) else if exist "%~dp0..\.env" (
  echo Found .env in argus directory. Loading definitions...
  flutter run -d chrome --dart-define-from-file="%~dp0..\.env"
) else if exist ".env" (
  echo Found .env in flutter directory. Loading definitions...
  flutter run -d chrome --dart-define-from-file=".env"
) else (
  flutter run -d chrome
)
pause
