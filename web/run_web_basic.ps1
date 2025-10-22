# PowerShell script to run Flutter Web - Basic
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   Flutter Web - Basic" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Run Flutter web with basic settings
Write-Host "Starting Flutter Web..." -ForegroundColor Green
flutter run -d chrome

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   Flutter Web session ended" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Press any key to continue..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
