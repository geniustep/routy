@echo off
echo ========================================
echo    Flutter Web - Simple Version
echo ========================================

REM Create temp directory for Chrome
if not exist "C:\temp\chrome_dev_test" mkdir "C:\temp\chrome_dev_test"

REM Kill any existing Chrome processes
echo Killing existing Chrome processes...
taskkill /f /im chrome.exe 2>nul

REM Wait a moment
timeout /t 2 /nobreak >nul

REM Run Flutter web with simple Chrome settings
echo Starting Flutter Web...
flutter run -d chrome --web-browser-flag="--disable-web-security" --web-browser-flag="--user-data-dir=C:\temp\chrome_dev_test"

echo.
echo ========================================
echo    Flutter Web session ended
echo ========================================
pause
