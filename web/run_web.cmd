@echo off
echo Starting Flutter Web with CORS settings...

REM Create temp directory for Chrome
if not exist "C:\temp\chrome_dev_test" mkdir "C:\temp\chrome_dev_test"

REM Kill any existing Chrome processes
taskkill /f /im chrome.exe 2>nul

REM Wait a moment
timeout /t 2 /nobreak >nul

REM Run Flutter web with specific Chrome settings
echo Running Flutter Web...
flutter run -d chrome --web-browser-flag="--disable-web-security" --web-browser-flag="--disable-features=VizDisplayCompositor" --web-browser-flag="--user-data-dir=C:\temp\chrome_dev_test" --web-browser-flag="--allow-running-insecure-content"

echo Press any key to continue...
pause >nul
