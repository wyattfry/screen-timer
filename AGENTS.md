# AGENTS.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

Screen Timer is a Windows Forms application (.NET 9.0) that tracks and limits daily screen time. It runs as a background process with an always-visible floating widget, system tray icon, and enforces time limits via workstation locking.

**Key characteristics:**
- Privacy-focused: All data stored locally in `%LOCALAPPDATA%\screen-timer\`
- Simple text-based storage: `config.txt` (7 lines, one per day) and `usage.txt` (CSV format)
- Singleton enforcement: Uses Mutex to prevent multiple instances (prevents double-counting)
- Widget can be hidden/shown via system tray right-click menu
- Deployed via Windows Task Scheduler for auto-start

## Directory Structure

- **src/** - C# source files (Form1.cs, TimeTracker.cs, ConfigManager.cs, etc.)
- **scripts/** - PowerShell build and setup scripts
- **ScreenTimer.csproj** - Project file (references src/**/*.cs)
- **install.ps1** - Web-based installer script (root level for easy access)

## Build, Run & Deploy Commands

### Development
```powershell
# Run in development mode
dotnet run

# Build Release version (requires .NET 9.0 Runtime)
.\scripts\build.ps1
# or
dotnet publish -c Release

# Executable location
.\bin\Release\net9.0-windows\ScreenTimer.exe
```

### Standalone Build
```powershell
# Build self-contained .exe (includes .NET runtime)
.\scripts\build-standalone.ps1
# Creates single .exe at .\release\ScreenTimer.exe
```

### Installation & Deployment
```powershell
# Web-based install (from GitHub releases) - run as Administrator
irm https://raw.githubusercontent.com/USER/screen-timer/main/install.ps1 | iex

# Local setup for auto-start
.\scripts\Setup-TaskScheduler.ps1

# Manually control the task
Start-ScheduledTask -TaskName "ScreenTimer"
Stop-ScheduledTask -TaskName "ScreenTimer"
Get-ScheduledTask -TaskName "ScreenTimer"

# Stop the running process
Stop-Process -Name ScreenTimer -Force
```

## Architecture

### Component Structure

The application follows a manager-based architecture where each concern is isolated:

- **src/Program.cs** - Entry point, enforces singleton using Mutex
  - Creates named Mutex "ScreenTimer_SingleInstance_..."
  - Shows message and exits if another instance is already running
- **src/Form1.cs (ScreenTimerForm)** - Main orchestrator that coordinates all managers and the widget
  - Hidden form that runs in background
  - Contains main timer (60-second interval) that drives all updates
  - Handles date rollover detection and state resets
  - Creates system tray context menu with Show/Hide timer option
  - Prevents widget from closing (hides it instead when user clicks X)
- **src/ConfigManager.cs** - Reads daily time limits from 7-line config file
- **src/TimeTracker.cs** - Tracks minutes used, persists to CSV, handles date changes
- **src/NotificationManager.cs** - Triggers popup alerts at 30, 10, 1 minute thresholds
- **src/LockManager.cs** - Calls Win32 `LockWorkStation()` API when time limit reached
- **src/TimeDisplayWidget.cs** - Always-on-top draggable floating window
  - Shows remaining time in color-coded format
  - Green (>30 min), Orange (10-30 min), Red (0-10 min)
  - Semi-transparent, becomes opaque on hover

### Data Flow

1. **Timer tick** (every 60 seconds in src/Form1.cs) triggers:
   - Date rollover check → resets notifications and lock status if new day
   - TimeTracker increments minute counter → saves to disk
   - Display widget updates with current time remaining
   - NotificationManager checks thresholds → shows MessageBox if needed
   - LockManager checks limit → locks workstation once per day

2. **State persistence:**
   - ConfigManager: Loads config once at startup (changes require restart)
   - TimeTracker: Updates usage.txt on every minute increment
   - NotificationManager: Maintains in-memory set of shown notifications
   - LockManager: Tracks boolean flag for whether lock occurred today

### Configuration Files

Located at `%LOCALAPPDATA%\screen-timer\`:

- **config.txt** - 7 lines (Sun-Sat), each is minutes allowed (e.g., "120" = 2 hours)
  - Line 1 = Sunday, Line 2 = Monday, ..., Line 7 = Saturday
  - Default: [240, 120, 120, 120, 120, 180, 240]
- **usage.txt** - CSV format: `YYYY-MM-DD,minutes`
  - One row per day, updated every minute
  - TimeTracker reads/writes entire file on each save

## Key Implementation Details

### Singleton Enforcement
Uses a named Mutex to prevent multiple instances:
- Mutex name: "ScreenTimer_SingleInstance_8F6F0AC4-B9A1-45fd-A8CF-72F04E6BDE8F"
- If second instance is launched, shows message and exits immediately
- Prevents double-counting of time usage
- Mutex is created in src/Program.cs and held for entire application lifetime

### Widget Visibility
The time display widget can be hidden/shown but never truly closed:
- System tray right-click menu has "Hide Timer" / "Show Timer" toggle
- When user closes widget via X button or Alt+Tab → Close, it hides instead (FormClosing event cancels and hides)
- Widget always exists in memory, just visibility toggled
- This ensures timer keeps running and prevents confusion

### Timer Interval
The main timer runs every 60 seconds (60000ms). To change:
- Edit src/Form1.cs line 42: `_timer.Interval = 60000;`
- Can set to 1000ms (1 second) for testing

### Notification Thresholds
Alerts triggered at 30, 10, and 1 minute remaining. To modify:
- Edit src/NotificationManager.cs line 16: `if ((minutesRemaining == 30 || minutesRemaining == 10 || minutesRemaining == 1)`
- Uses MessageBox with `MessageBoxOptions.DefaultDesktopOnly` to show over fullscreen apps

### Lock Behavior
Calls Windows API `LockWorkStation()` once per day when limit reached. To change:
- Edit src/LockManager.cs line 19
- Options: Log off (`ExitWindowsEx(0, 0)`), Shutdown (`ExitWindowsEx(1, 0)`), Sleep, or just disable

### Widget Position & Style
- Default: Top-right corner (10px from edge)
- Draggable via click-and-drag on label
- Opacity: 0.8 normally, 0.95 on hover
- Edit src/TimeDisplayWidget.cs line 27 to change initial position

### Date Rollover Logic
Two separate checks for date changes:
1. src/Form1.cs Timer_Tick (line 56-62): Resets notification and lock flags
2. src/TimeTracker.IncrementMinute (line 55-61): Resets minute counter

This dual-check ensures robustness if app runs continuously across midnight.

## Testing & Validation

**No automated tests are included.** Manual testing checklist:

1. Build succeeds: `.\build.ps1` completes without errors
2. Config file created with defaults at first run
3. Usage file updates every minute
4. System tray icon appears (currently visible)
5. Widget shows in top-right with correct color coding
6. Timer increments minutes correctly
7. Notifications appear at thresholds (test by editing config to low values)
8. Lock triggers when limit reached
9. Task Scheduler setup completes successfully

To test quickly, temporarily change timer interval to 1 second and set config limit to 1-2 minutes.

## Deployment Notes

### Web-Based Installation (Easiest)
On target machine, run as Administrator:
```powershell
irm https://raw.githubusercontent.com/USER/screen-timer/main/install.ps1 | iex
```

This downloads the latest GitHub release, installs to `C:\Program Files\ScreenTimer`, and configures Task Scheduler auto-start.

**How it works:**
- install.ps1 calls GitHub API to get latest release
- Downloads and extracts the .zip package
- Copies files to Program Files
- Runs Task Scheduler setup automatically
- Handles updates (stops existing process before replacing files)

### Standard Deployment (requires .NET 9.0 Runtime on target)
1. Use `.\scripts\build.ps1` or `dotnet publish -c Release`
2. Copy `bin\Release\net9.0-windows\` folder to target machine
3. Run `scripts\Setup-TaskScheduler.ps1` on target as user who will use the app
4. Edit `%LOCALAPPDATA%\screen-timer\config.txt` to set time limits

### Standalone Deployment (no .NET Runtime required)
1. Use `.\scripts\build-standalone.ps1` to create self-contained .exe
2. Copy single `release\ScreenTimer.exe` to target machine
3. Run `scripts\Setup-TaskScheduler.ps1` from same directory as .exe
4. Script auto-detects exe location

### Tamper Resistance Options
- Move config to `C:\ProgramData\screen-timer\` and set read-only for child user
- Run Task Scheduler task as SYSTEM account (requires changing src/ConfigManager.cs and src/TimeTracker.cs paths)
- Hide system tray icon: Set `_notifyIcon.Visible = false` in src/Form1.cs
- Set file permissions so child user cannot modify config or kill process easily

### Multi-Machine Management
- Codebase uses Environment.SpecialFolder.LocalApplicationData for paths
- To centralize: Modify src/ConfigManager.cs and src/TimeTracker.cs to use network share paths
- Consider Group Policy deployment for enterprise scenarios
