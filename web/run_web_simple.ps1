# PowerShell script to run Flutter Web - Simple Version
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   Flutter Web - Simple Version" -ForegroundColor Cyan
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

# Wait a moment
Start-Sleep -Seconds 2

# Run Flutter web with simple Chrome settings
Write-Host "Starting Flutter Web..." -ForegroundColor Green
flutter run -d chrome --web-browser-flag="--disable-web-security" --web-browser-flag="--user-data-dir=$tempDir"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   Flutter Web session ended" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Press any key to continue..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
