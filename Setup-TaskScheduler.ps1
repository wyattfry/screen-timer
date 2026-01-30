# Setup script for Screen Timer Task Scheduler
# Run this script as Administrator to configure auto-start on login

$exePath = Join-Path $PSScriptRoot "bin\Release\net9.0-windows\ScreenTimer.exe"

if (-not (Test-Path $exePath)) {
    Write-Host "ERROR: Executable not found at $exePath" -ForegroundColor Red
    Write-Host "Please build the project in Release mode first:" -ForegroundColor Yellow
    Write-Host "  dotnet publish -c Release" -ForegroundColor Cyan
    exit 1
}

$taskName = "ScreenTimer"
$existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue

if ($existingTask) {
    Write-Host "Removing existing task..." -ForegroundColor Yellow
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
}

$action = New-ScheduledTaskAction -Execute $exePath
$trigger = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit 0
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Limited

Register-ScheduledTask -TaskName $taskName `
    -Action $action `
    -Trigger $trigger `
    -Settings $settings `
    -Principal $principal `
    -Description "Screen Time Limiter - Tracks and limits daily screen time"

Write-Host ""
Write-Host "SUCCESS: Screen Timer has been configured to start automatically at login." -ForegroundColor Green
Write-Host ""
Write-Host "Configuration file location:" -ForegroundColor Cyan
Write-Host "  $env:LOCALAPPDATA\screen-timer\config.txt" -ForegroundColor White
Write-Host ""
Write-Host "Usage data location:" -ForegroundColor Cyan
Write-Host "  $env:LOCALAPPDATA\screen-timer\usage.txt" -ForegroundColor White
Write-Host ""
Write-Host "To start the task now, run:" -ForegroundColor Yellow
Write-Host "  Start-ScheduledTask -TaskName '$taskName'" -ForegroundColor White
Write-Host ""
