# Build script for Screen Timer

Write-Host "Building Screen Timer..." -ForegroundColor Cyan

dotnet publish -c Release

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "Build successful!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Executable location:" -ForegroundColor Cyan
    Write-Host "  $(Join-Path $PSScriptRoot 'bin\Release\net9.0-windows\ScreenTimer.exe')" -ForegroundColor White
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "  1. Run: .\Setup-TaskScheduler.ps1" -ForegroundColor White
    Write-Host "  2. Or manually run: .\bin\Release\net9.0-windows\ScreenTimer.exe" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "Build failed!" -ForegroundColor Red
    Write-Host ""
    exit 1
}
