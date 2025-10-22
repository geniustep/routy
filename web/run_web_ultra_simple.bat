@echo off
echo ========================================
echo    Flutter Web - Ultra Simple
echo ========================================

REM Kill any existing Chrome processes
echo Killing existing Chrome processes...
taskkill /f /im chrome.exe 2>nul

REM Wait a moment
timeout /t 2 /nobreak >nul

REM Run Flutter web with minimal Chrome settings
echo Starting Flutter Web...
flutter run -d chrome --web-browser-flag="--disable-web-security"

echo.
echo ========================================
echo    Flutter Web session ended
echo ========================================
pause
