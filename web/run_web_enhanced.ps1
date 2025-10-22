# PowerShell script to run Flutter Web with Enhanced CORS settings
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   Flutter Web with Enhanced CORS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Create temp directory for Chrome
$tempDir = "C:\temp\chrome_dev_test"
if (!(Test-Path $tempDir)) {
    New-Item -ItemType Directory -Path $tempDir -Force
    Write-Host "Created temp directory: $tempDir" -ForegroundColor Green
}

# Kill any existing Chrome processes
Write-Host "Killing existing Chrome processes..." -ForegroundColor Yellow
Get-Process chrome -ErrorAction SilentlyContinue | Stop-Process -Force
Get-Process chrome -ErrorAction SilentlyContinue | Stop-Process -Force

# Wait a moment
Start-Sleep -Seconds 3

# Run Flutter web with enhanced Chrome settings
Write-Host "Starting Flutter Web with enhanced CORS settings..." -ForegroundColor Green
Write-Host ""
Write-Host "Chrome will open with the following settings:" -ForegroundColor Cyan
Write-Host "- Disabled web security" -ForegroundColor White
Write-Host "- Disabled features for better compatibility" -ForegroundColor White
Write-Host "- Custom user data directory" -ForegroundColor White
Write-Host "- Allowed insecure content" -ForegroundColor White
Write-Host ""

flutter run -d chrome --web-browser-flag="--disable-web-security" --web-browser-flag="--disable-features=VizDisplayCompositor" --web-browser-flag="--user-data-dir=$tempDir" --web-browser-flag="--allow-running-insecure-content" --web-browser-flag="--disable-extensions" --web-browser-flag="--disable-plugins" --web-browser-flag="--disable-images" --web-browser-flag="--disable-javascript" --web-browser-flag="--disable-web-security" --web-browser-flag="--disable-features=VizDisplayCompositor"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   Flutter Web session ended" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Press any key to continue..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
