@echo off
echo ========================================
echo    Flutter Web with Enhanced CORS
echo ========================================

REM Create temp directory for Chrome
if not exist "C:\temp\chrome_dev_test" mkdir "C:\temp\chrome_dev_test"

REM Kill any existing Chrome processes
echo Killing existing Chrome processes...
taskkill /f /im chrome.exe 2>nul
taskkill /f /im chrome.exe 2>nul

REM Wait a moment
timeout /t 3 /nobreak >nul

REM Run Flutter web with enhanced Chrome settings
echo Starting Flutter Web with enhanced CORS settings...
echo.
echo Chrome will open with the following settings:
echo - Disabled web security
echo - Disabled features for better compatibility
echo - Custom user data directory
echo - Allowed insecure content
echo.

flutter run -d chrome --web-browser-flag="--disable-web-security" --web-browser-flag="--disable-features=VizDisplayCompositor" --web-browser-flag="--user-data-dir=C:\temp\chrome_dev_test" --web-browser-flag="--allow-running-insecure-content" --web-browser-flag="--disable-extensions" --web-browser-flag="--disable-plugins" --web-browser-flag="--disable-images" --web-browser-flag="--disable-javascript" --web-browser-flag="--disable-web-security" --web-browser-flag="--disable-features=VizDisplayCompositor"

echo.
echo ========================================
echo    Flutter Web session ended
echo ========================================
pause
