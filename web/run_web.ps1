# PowerShell script to run Flutter Web with CORS settings
Write-Host "Starting Flutter Web with CORS settings..." -ForegroundColor Green

# Create temp directory for Chrome
$tempDir = "C:\temp\chrome_dev_test"
if (!(Test-Path $tempDir)) {
    New-Item -ItemType Directory -Path $tempDir -Force
}

# Kill any existing Chrome processes
Get-Process chrome -ErrorAction SilentlyContinue | Stop-Process -Force

# Wait a moment
Start-Sleep -Seconds 2

# Run Flutter web with specific Chrome settings
Write-Host "Running Flutter Web..." -ForegroundColor Yellow
flutter run -d chrome --web-browser-flag="--disable-web-security" --web-browser-flag="--disable-features=VizDisplayCompositor" --web-browser-flag="--user-data-dir=$tempDir" --web-browser-flag="--allow-running-insecure-content"

Write-Host "Press any key to continue..." -ForegroundColor Cyan
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
