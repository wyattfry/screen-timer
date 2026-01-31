param(
    [string]$InstallPath = "$env:ProgramFiles\ScreenTimer",
    [string]$Version = "latest"
)

$ErrorActionPreference = "Stop"

Write-Host "Screen Timer Installer" -ForegroundColor Cyan
Write-Host "=====================" -ForegroundColor Cyan
Write-Host ""

$repo = "wyattfry/screen-timer"

if ($Version -eq "latest") {
    Write-Host "Fetching latest release information..." -ForegroundColor Yellow
    $apiUrl = "https://api.github.com/repos/$repo/releases/latest"
} else {
    Write-Host "Fetching release $Version..." -ForegroundColor Yellow
    $apiUrl = "https://api.github.com/repos/$repo/releases/tags/$Version"
}

try {
    $release = Invoke-RestMethod -Uri $apiUrl -Headers @{ "User-Agent" = "ScreenTimer-Installer" }
    $downloadUrl = $release.assets | Where-Object { $_.name -like "ScreenTimer-*.zip" } | Select-Object -First 1 -ExpandProperty browser_download_url
    
    if (-not $downloadUrl) {
        Write-Host "ERROR: Could not find ScreenTimer release package" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "Found release: $($release.tag_name)" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "ERROR: Failed to fetch release information" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

$tempZip = Join-Path $env:TEMP "ScreenTimer-$(New-Guid).zip"
$tempExtract = Join-Path $env:TEMP "ScreenTimer-$(New-Guid)"

Write-Host "Downloading $($release.tag_name)..." -ForegroundColor Yellow
try {
    Invoke-WebRequest -Uri $downloadUrl -OutFile $tempZip
    Write-Host "Download complete" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "ERROR: Failed to download release" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

Write-Host "Extracting files..." -ForegroundColor Yellow
try {
    Expand-Archive -Path $tempZip -DestinationPath $tempExtract -Force
    Write-Host "Extraction complete" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "ERROR: Failed to extract archive" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Remove-Item -Path $tempZip -Force -ErrorAction SilentlyContinue
    exit 1
}

$isUpdate = Test-Path $InstallPath
if ($isUpdate) {
    Write-Host "Updating existing installation at $InstallPath..." -ForegroundColor Yellow
    
    Write-Host "Stopping ScreenTimer if running..." -ForegroundColor Yellow
    try {
        Stop-Process -Name "ScreenTimer" -Force -ErrorAction SilentlyContinue
        Stop-ScheduledTask -TaskName "ScreenTimer" -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
    } catch {
        Write-Host "Warning: Could not stop existing process" -ForegroundColor Yellow
    }
} else {
    Write-Host "Installing to $InstallPath..." -ForegroundColor Yellow
}

try {
    New-Item -ItemType Directory -Path $InstallPath -Force | Out-Null
    Copy-Item -Path "$tempExtract\*" -Destination $InstallPath -Recurse -Force
    Write-Host "Installation complete" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "ERROR: Failed to copy files to $InstallPath" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Remove-Item -Path $tempZip -Force -ErrorAction SilentlyContinue
    Remove-Item -Path $tempExtract -Recurse -Force -ErrorAction SilentlyContinue
    exit 1
}

Remove-Item -Path $tempZip -Force
Remove-Item -Path $tempExtract -Recurse -Force

$setupScript = Join-Path $InstallPath "Setup-TaskScheduler.ps1"
if (Test-Path $setupScript) {
    Write-Host "Configuring auto-start..." -ForegroundColor Yellow
    Write-Host ""
    
    $exePath = Join-Path $InstallPath "ScreenTimer.exe"
    
    $existingTask = Get-ScheduledTask -TaskName "ScreenTimer" -ErrorAction SilentlyContinue
    if ($existingTask) {
        Unregister-ScheduledTask -TaskName "ScreenTimer" -Confirm:$false
    }
    
    $action = New-ScheduledTaskAction -Execute $exePath
    $trigger = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME
    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit 0
    $principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Limited
    
    Register-ScheduledTask -TaskName "ScreenTimer" `
        -Action $action `
        -Trigger $trigger `
        -Settings $settings `
        -Principal $principal `
        -Description "Screen Time Limiter - Tracks and limits daily screen time" | Out-Null
    
    Write-Host "Auto-start configured successfully" -ForegroundColor Green
    Write-Host ""
} else {
    Write-Host "Warning: Setup-TaskScheduler.ps1 not found, skipping auto-start setup" -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "SUCCESS: Screen Timer has been installed!" -ForegroundColor Green
Write-Host ""
Write-Host "Installation directory:" -ForegroundColor Cyan
Write-Host "  $InstallPath" -ForegroundColor White
Write-Host ""
Write-Host "Configuration file:" -ForegroundColor Cyan
Write-Host "  $env:LOCALAPPDATA\screen-timer\config.txt" -ForegroundColor White
Write-Host ""
Write-Host "Usage data:" -ForegroundColor Cyan
Write-Host "  $env:LOCALAPPDATA\screen-timer\usage.txt" -ForegroundColor White
Write-Host ""
Write-Host "To start now:" -ForegroundColor Yellow
Write-Host "  Start-ScheduledTask -TaskName 'ScreenTimer'" -ForegroundColor White
Write-Host ""
Write-Host "To configure time limits, edit the config file (7 lines, one per day Sun-Sat)" -ForegroundColor Yellow
Write-Host ""
