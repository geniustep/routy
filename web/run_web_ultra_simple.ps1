# PowerShell script to run Flutter Web - Ultra Simple
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   Flutter Web - Ultra Simple" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Kill any existing Chrome processes
Write-Host "Killing existing Chrome processes..." -ForegroundColor Yellow
Get-Process chrome -ErrorAction SilentlyContinue | Stop-Process -Force

# Wait a moment
Start-Sleep -Seconds 2

# Run Flutter web with minimal Chrome settings
Write-Host "Starting Flutter Web..." -ForegroundColor Green
flutter run -d chrome --web-browser-flag="--disable-web-security"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   Flutter Web session ended" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Press any key to continue..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
