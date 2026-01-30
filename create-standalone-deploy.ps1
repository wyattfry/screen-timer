# Create deployment package with self-contained executable

Write-Host "Creating standalone deployment package..." -ForegroundColor Cyan
Write-Host ""

# Build first if needed
if (-not (Test-Path ".\release\ScreenTimer.exe")) {
    Write-Host "Building self-contained executable first..." -ForegroundColor Yellow
    & .\build-standalone.ps1
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Build failed!" -ForegroundColor Red
        exit 1
    }
}

# Create deploy folder
$deployPath = Join-Path $PSScriptRoot "deploy-standalone"
if (Test-Path $deployPath) {
    Write-Host "Removing old deploy folder..." -ForegroundColor Yellow
    Remove-Item -Path $deployPath -Recurse -Force
}

New-Item -ItemType Directory -Path $deployPath -Force | Out-Null

# Copy files
Write-Host "Copying files to deploy folder..." -ForegroundColor Yellow
Copy-Item -Path ".\release\ScreenTimer.exe" -Destination $deployPath
Copy-Item -Path ".\Setup-TaskScheduler.ps1" -Destination $deployPath
Copy-Item -Path ".\README.md" -Destination $deployPath
Copy-Item -Path ".\DEPLOYMENT.md" -Destination $deployPath

# Create instructions file
$instructions = @"
SCREEN TIMER - STANDALONE DEPLOYMENT PACKAGE
=============================================

This package contains a SELF-CONTAINED executable that does NOT require
.NET SDK to be installed on the target computer.

Contents:
- ScreenTimer.exe (includes .NET runtime - single file ~65MB)
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

Package created: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

"@

$instructions | Out-File -FilePath (Join-Path $deployPath "INSTALL.txt") -Encoding UTF8

# Get package size
$packageSize = (Get-ChildItem $deployPath -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB

Write-Host ""
Write-Host "SUCCESS: Standalone deployment package created!" -ForegroundColor Green
Write-Host ""
Write-Host "Location:" -ForegroundColor Cyan
Write-Host "  $deployPath" -ForegroundColor White
Write-Host ""
Write-Host "Package size: $([math]::Round($packageSize, 2)) MB" -ForegroundColor Cyan
Write-Host ""
Write-Host "Package contents:" -ForegroundColor Cyan
Get-ChildItem $deployPath | ForEach-Object {
    $size = if ($_.PSIsContainer) { "" } else { " ($([math]::Round($_.Length / 1MB, 2)) MB)" }
    Write-Host "  - $($_.Name)$size" -ForegroundColor White
}
Write-Host ""
Write-Host "This package can be deployed to Windows computers WITHOUT .NET installed." -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Copy the 'deploy-standalone' folder to USB drive or network share" -ForegroundColor White
Write-Host "  2. Transfer to target computers" -ForegroundColor White
Write-Host "  3. Follow instructions in INSTALL.txt" -ForegroundColor White
Write-Host ""
