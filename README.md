# Screen Timer

A simple Windows screen time limiter that tracks daily computer usage and enforces configurable time limits.

## Features

- ✅ **Always-visible time display** - Floating widget shows remaining time
- ✅ **Color-coded warnings** - Green → Orange → Red as time runs low
- ✅ Tracks screen time per day
- ✅ Configurable daily limits for each day of the week
- ✅ Notifications at 30, 10, and 1 minute remaining
- ✅ Soft lock (workstation lock) when time is up
- ✅ Privacy-focused - all data stored locally
- ✅ Automatic reset at midnight
- ✅ No exit button - harder to tamper with

## Installation

### 1. Build the Application

```powershell
dotnet publish -c Release
```

### 2. Set Up Auto-Start (Optional)

To configure the app to start automatically at login:

```powershell
.\Setup-TaskScheduler.ps1
```

This creates a Task Scheduler task that starts Screen Timer when the user logs in.

### 3. Manual Start

Alternatively, you can run the app manually:

```powershell
dotnet run
```

Or run the compiled executable:

```powershell
.\bin\Release\net9.0-windows\ScreenTimer.exe
```

## Configuration

### Time Limits

Edit the config file to set daily time limits (in minutes):

**Location:** `%LOCALAPPDATA%\screen-timer\config.txt`

The file has 7 lines, one for each day of the week:
- Line 1: Sunday
- Line 2: Monday
- Line 3: Tuesday
- Line 4: Wednesday
- Line 5: Thursday
- Line 6: Friday
- Line 7: Saturday

**Default values:**
```
240  (Sunday - 4 hours)
120  (Monday - 2 hours)
120  (Tuesday - 2 hours)
120  (Wednesday - 2 hours)
120  (Thursday - 2 hours)
180  (Friday - 3 hours)
240  (Saturday - 4 hours)
```

To change limits, edit the numbers in the file. Changes take effect on the next day.

### Usage Data

Usage data is stored in: `%LOCALAPPDATA%\screen-timer\usage.txt`

Format: `YYYY-MM-DD,minutes`

Example:
```
2026-01-30,45
2026-01-31,120
```

## Usage

### Time Display Widget

An always-on-top floating widget appears in the top-right corner showing:
- Time remaining in large, easy-to-read text
- Color-coded status (green = good, orange = warning, red = critical)
- Updates automatically every minute

**Widget Features:**
- **Draggable** - Click and drag to reposition
- **Semi-transparent** - Becomes more visible when you hover over it
- **Always visible** - No need to click or interact to see time
- **No controls** - Cannot be closed or modified by user

### System Tray Icon

A small icon appears in the system tray showing the app is running. It has no menu or controls to prevent tampering.

## How It Works

1. **Display:** Always-on-top widget shows remaining time in color-coded format
2. **Tracking:** Every minute, the app increments the usage counter for the current day
3. **Notifications:** Popup alerts appear at 30, 10, and 1 minute remaining
4. **Enforcement:** When time is up, the workstation locks
5. **Reset:** At midnight, the counter resets and notifications/lock status clear

## Stopping the Application

**For parents/admins only:**

The app has no user-accessible exit button. To stop it:

```powershell
# Via PowerShell
Stop-Process -Name ScreenTimer -Force

# Or via Task Manager
Ctrl+Shift+Esc → Find ScreenTimer → End Task

# Or via Task Scheduler
Stop-ScheduledTask -TaskName "ScreenTimer"
```

## Customization

### Adjust Notification Thresholds

Edit `NotificationManager.cs` line 16 to change when notifications appear:

```csharp
if ((minutesRemaining == 30 || minutesRemaining == 10 || minutesRemaining == 1)
```

### Change Lock Behavior

Edit `LockManager.cs` to modify what happens when time is up. Options include:
- `LockWorkStation()` - Lock the computer (current)
- Log off the user
- Shut down
- Just disable without locking

### Change Timer Interval

Edit `Form1.cs` line 46 to change how often the app checks time (default: 60000ms = 1 minute):

```csharp
_timer.Interval = 60000;  // milliseconds
```

## Deployment to Kids' Laptops

1. Build in Release mode: `dotnet publish -c Release`
2. Copy the entire `bin\Release\net9.0-windows` folder to the target machine
3. Run `Setup-TaskScheduler.ps1` on each laptop
4. Edit the config file to set appropriate time limits
5. (Optional) Set file permissions to prevent kids from editing config

### Tamper Resistance

For better tamper resistance:
- Run the Task Scheduler task as SYSTEM account
- Move config files to `C:\ProgramData\screen-timer\` 
- Set config files as read-only for the child user account
- Hide the system tray icon by setting `_notifyIcon.Visible = false` after initialization

## Limitations

- Does not track activity vs. idle time (counts all time computer is on)
- Easy to bypass for tech-savvy users (can kill process from Task Manager)
- No remote management or reporting
- Windows only

## Requirements

- Windows 11 (or Windows 10)
- .NET 9.0 Runtime

## License

Free to use and modify for personal use.
