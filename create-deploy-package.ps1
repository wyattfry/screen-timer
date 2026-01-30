# Create deployment package for Screen Timer

Write-Host "Creating deployment package..." -ForegroundColor Cyan
Write-Host ""

# Build first
Write-Host "Building application..." -ForegroundColor Yellow
dotnet publish -c Release

if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed!" -ForegroundColor Red
    exit 1
}

# Create deploy folder
$deployPath = Join-Path $PSScriptRoot "deploy"
if (Test-Path $deployPath) {
    Write-Host "Removing old deploy folder..." -ForegroundColor Yellow
    Remove-Item -Path $deployPath -Recurse -Force
}

New-Item -ItemType Directory -Path $deployPath -Force | Out-Null

# Copy files
Write-Host "Copying files to deploy folder..." -ForegroundColor Yellow
$sourcePath = Join-Path $PSScriptRoot "bin\Release\net9.0-windows\*"
Copy-Item -Path $sourcePath -Destination $deployPath -Recurse

# Copy setup script
Copy-Item -Path (Join-Path $PSScriptRoot "Setup-TaskScheduler.ps1") -Destination $deployPath
Copy-Item -Path (Join-Path $PSScriptRoot "README.md") -Destination $deployPath
Copy-Item -Path (Join-Path $PSScriptRoot "DEPLOYMENT.md") -Destination $deployPath

# Create instructions file
$instructions = @"
SCREEN TIMER - DEPLOYMENT PACKAGE
==================================

Contents:
- ScreenTimer.exe (and supporting files)
- Setup-TaskScheduler.ps1
- README.md
- DEPLOYMENT.md

Quick Start:
1. Copy this entire folder to target computer
2. Run PowerShell as Administrator
3. cd to this folder
4. Run: .\Setup-TaskScheduler.ps1
5. Configure time limits in: %LOCALAPPDATA%\screen-timer\config.txt

For detailed instructions, see DEPLOYMENT.md

"@

$instructions | Out-File -FilePath (Join-Path $deployPath "INSTALL.txt") -Encoding UTF8

Write-Host ""
Write-Host "SUCCESS: Deployment package created!" -ForegroundColor Green
Write-Host ""
Write-Host "Location:" -ForegroundColor Cyan
Write-Host "  $deployPath" -ForegroundColor White
Write-Host ""
Write-Host "Package contents:" -ForegroundColor Cyan
Get-ChildItem $deployPath | ForEach-Object {
    Write-Host "  - $($_.Name)" -ForegroundColor White
}
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Copy the 'deploy' folder to USB drive or network share" -ForegroundColor White
Write-Host "  2. Transfer to target computers" -ForegroundColor White
Write-Host "  3. Follow instructions in DEPLOYMENT.md" -ForegroundColor White
Write-Host ""
