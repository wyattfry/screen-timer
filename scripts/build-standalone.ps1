# Build standalone/self-contained executable
# This creates a single .exe file that includes the .NET runtime
# Can run on systems without .NET SDK installed

Set-Location (Join-Path $PSScriptRoot "..")

Write-Host "Building self-contained Screen Timer executable..." -ForegroundColor Cyan
Write-Host ""

# Clean previous builds
if (Test-Path ".\release") {
    Write-Host "Cleaning previous build..." -ForegroundColor Yellow
    Remove-Item -Path ".\release" -Recurse -Force
}

# Build self-contained single-file executable
Write-Host "Building self-contained executable (this may take a minute)..." -ForegroundColor Yellow
dotnet publish -c Release `
    --runtime win-x64 `
    --self-contained true `
    -p:PublishSingleFile=true `
    -p:IncludeNativeLibrariesForSelfExtract=true `
    -p:EnableCompressionInSingleFile=true `
    -o ./release

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "Build failed!" -ForegroundColor Red
    Write-Host ""
    exit 1
}

# Get file size
$exePath = ".\release\ScreenTimer.exe"
$fileSize = (Get-Item $exePath).Length / 1MB

Write-Host ""
Write-Host "Build successful!" -ForegroundColor Green
Write-Host ""
Write-Host "Self-contained executable:" -ForegroundColor Cyan
Write-Host "  Location: $exePath" -ForegroundColor White
Write-Host "  Size: $([math]::Round($fileSize, 2)) MB" -ForegroundColor White
Write-Host ""
Write-Host "This .exe includes the .NET runtime and can run on systems" -ForegroundColor Yellow
Write-Host "WITHOUT .NET SDK installed." -ForegroundColor Yellow
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Copy ScreenTimer.exe to target computer" -ForegroundColor White
Write-Host "  2. Run scripts\Setup-TaskScheduler.ps1 on target computer" -ForegroundColor White
Write-Host ""
