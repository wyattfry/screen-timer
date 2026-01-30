# Screen Timer - Project Summary

## What Was Built

A complete C# Windows Forms application that tracks and limits daily screen time for Windows 11 computers. Built with .NET 9.0 and uses only built-in Windows features.

## Key Features

✅ **Time Tracking** - Runs every minute, tracks daily usage
✅ **Configurable Limits** - Different limits for each day of the week
✅ **System Tray Icon** - Shows remaining time at a glance
✅ **Notifications** - Alerts at 30, 10, and 1 minute remaining
✅ **Soft Lock** - Locks workstation when time is up
✅ **Privacy-First** - All data stored locally, no internet required
✅ **Auto-Start** - Task Scheduler integration for automatic startup
✅ **Date Rollover** - Automatically resets at midnight

## Project Structure

```
screen-timer/
├── ConfigManager.cs           # Reads 7-line config file
├── TimeTracker.cs             # Tracks daily usage in CSV format
├── NotificationManager.cs     # Handles notification popups
├── LockManager.cs             # Locks workstation when time is up
├── Form1.cs                   # Main application with system tray
├── Form1.Designer.cs          # Windows Forms designer file
├── Program.cs                 # Application entry point
├── ScreenTimer.csproj         # Project file
├── build.ps1                  # Build script
├── Setup-TaskScheduler.ps1    # Task Scheduler setup
├── create-deploy-package.ps1  # Creates deployment package
├── README.md                  # User documentation
├── DEPLOYMENT.md              # Deployment guide
└── .gitignore                 # Git ignore file
```

## Data Files (Created at Runtime)

**Location:** `%LOCALAPPDATA%\screen-timer\`

- `config.txt` - 7 lines, minutes per day (Sun-Sat)
- `usage.txt` - CSV format: `YYYY-MM-DD,minutes`

## Quick Commands

### Build
```powershell
.\build.ps1
# or
dotnet publish -c Release
```

### Run (Development)
```powershell
dotnet run
```

### Run (Production)
```powershell
.\bin\Release\net9.0-windows\ScreenTimer.exe
```

### Create Deployment Package
```powershell
.\create-deploy-package.ps1
```

### Setup Auto-Start
```powershell
.\Setup-TaskScheduler.ps1
```

## Configuration Format

**File:** `%LOCALAPPDATA%\screen-timer\config.txt`

```
240  # Line 1: Sunday
120  # Line 2: Monday
120  # Line 3: Tuesday
120  # Line 4: Wednesday
120  # Line 5: Thursday
180  # Line 6: Friday
240  # Line 7: Saturday
```

Values are in minutes. Changes take effect next day.

## How It Works

1. **Startup**: Application starts hidden, creates system tray icon
2. **Timer**: Every 60 seconds (60000ms), timer ticks
3. **Tracking**: Increment minute counter for current day
4. **Check Limit**: Compare usage vs. daily limit
5. **Notify**: Show popup at 30, 10, 1 minutes remaining
6. **Lock**: When limit reached, lock workstation
7. **Reset**: At midnight, reset counter and status

## Architecture Decisions

### Why C# Windows Forms?
- Excellent NotifyIcon support for system tray
- Native Windows integration
- Easy to build and deploy
- No external dependencies

### Why Task Scheduler vs. Windows Service?
- Easier to install (no admin for service installation)
- Runs in user context (better for UI)
- Simpler to debug and manage
- Good enough for the use case

### Why Text Files vs. Database?
- Simple requirements (one row per day)
- Easy to view/edit manually
- No dependencies
- Fast read/write for small data

### Why 1-Minute Interval?
- Accurate enough for daily tracking
- Low CPU usage
- Good notification timing
- Easy to test (can change to seconds)

## Testing Checklist

- [x] Application builds successfully
- [x] Config file created with defaults
- [x] Usage file tracks minutes correctly
- [x] System tray icon appears
- [x] Context menu works (Show Status, Open Config, Exit)
- [x] Timer increments every minute
- [x] Date rollover works (tested logic)
- [x] Deployment package created successfully

## Future Enhancements (Optional)

### Easy Additions
- [ ] Better notification system (Windows 10+ toast notifications)
- [ ] Idle time detection (don't count if user is away)
- [ ] Warning sound/beep
- [ ] Custom icon based on time remaining (green/yellow/red)
- [ ] Pause/resume functionality for parents

### Medium Difficulty
- [ ] GUI configuration editor
- [ ] Usage statistics/graphs
- [ ] Multiple user profiles
- [ ] Export usage reports
- [ ] Custom notification thresholds

### Advanced
- [ ] Run as Windows Service
- [ ] Network-based config management
- [ ] Central monitoring dashboard
- [ ] Application-specific limits (e.g., games only)
- [ ] Web filtering integration

## Known Limitations

1. **Not idle-aware** - Counts all time computer is on
2. **Easy to bypass** - Can kill from Task Manager
3. **No application filtering** - Counts all usage equally
4. **Local only** - No remote management
5. **Windows only** - Not cross-platform

## Deployment Checklist

- [ ] Build in Release mode
- [ ] Test on target machine type
- [ ] Create deployment package
- [ ] Configure time limits per child
- [ ] Set up Task Scheduler
- [ ] Test auto-start after reboot
- [ ] Set file permissions (optional)
- [ ] Document config for each laptop

## Troubleshooting

**App won't start:**
- Check .NET 9.0 Runtime is installed
- Verify Task Scheduler task exists
- Check Windows Event Log

**Time not tracking:**
- Verify process is running: `Get-Process ScreenTimer`
- Check usage file is being updated
- Verify timer interval is correct

**Lock not working:**
- Check user account permissions
- Verify LockWorkStation API is callable
- Test manually with: `rundll32.exe user32.dll,LockWorkStation`

## Resources

- **Microsoft Docs**: Windows Forms NotifyIcon
- **Microsoft Docs**: Task Scheduler PowerShell
- **Microsoft Docs**: LockWorkStation API

## Notes for Maintainer

### Changing Timer Interval
Edit `Form1.cs` line 46:
```csharp
_timer.Interval = 60000;  // milliseconds
```

### Changing Notification Thresholds
Edit `NotificationManager.cs` line 16:
```csharp
if ((minutesRemaining == 30 || minutesRemaining == 10 || minutesRemaining == 1)
```

### Changing Lock Behavior
Edit `LockManager.cs` line 19:
```csharp
LockWorkStation();
```

Options:
- `LockWorkStation()` - Lock (current)
- Log off: `ExitWindowsEx(0, 0)`
- Shutdown: `ExitWindowsEx(1, 0)`
- Sleep: `SetSuspendState()`

### Changing Data Location
Edit both `ConfigManager.cs` and `TimeTracker.cs` to change path from:
```csharp
Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData)
```

To shared location:
```csharp
"C:\\ProgramData\\screen-timer"
```

## Success Criteria Met

✅ Tracks daily screen time per user
✅ Configurable daily limits for each day of week
✅ Shows remaining time in system tray
✅ Notifies at 30, 10, 1 minute thresholds
✅ Soft locks when time is up
✅ Uses only Windows built-in features
✅ Simple config file format (7 lines)
✅ Privacy-focused (local storage)
✅ Easy to deploy to multiple machines
✅ Auto-start on login (via Task Scheduler)

## Time Invested

- Initial planning: ~15 minutes (research open source options)
- Development: ~45 minutes (core implementation)
- Testing: ~15 minutes (build, run, verify)
- Documentation: ~20 minutes (README, DEPLOYMENT, scripts)
- **Total: ~95 minutes**

## Conclusion

Successfully built a functional, privacy-focused screen time limiter that meets all requirements. Uses Windows built-in features (Forms, Task Scheduler, LockWorkStation), stores data locally, and is easy to customize and deploy.

Ready for deployment to kids' laptops! 🎉
