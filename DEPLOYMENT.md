# Deployment Guide - Screen Timer for Kids' Laptops

This guide will help you deploy Screen Timer to your kids' Windows 11 laptops.

## Prerequisites

- Windows 11 laptops
- Admin access to each laptop
- USB drive or network share for file transfer

## Step-by-Step Deployment

### Step 1: Build the Application

On your development machine:

```powershell
.\build.ps1
```

This creates the executable at: `bin\Release\net9.0-windows\ScreenTimer.exe`

### Step 2: Package for Deployment

Copy these files to a USB drive or network share:

```
screen-timer-deploy/
├── ScreenTimer.exe
├── ScreenTimer.dll
├── ScreenTimer.runtimeconfig.json
├── Setup-TaskScheduler.ps1
└── (all other files from bin\Release\net9.0-windows\)
```

**Quick command to prepare deployment folder:**

```powershell
# Create deployment folder
New-Item -ItemType Directory -Path ".\deploy" -Force

# Copy all necessary files
Copy-Item -Path ".\bin\Release\net9.0-windows\*" -Destination ".\deploy" -Recurse

# Copy setup script
Copy-Item -Path ".\Setup-TaskScheduler.ps1" -Destination ".\deploy"
```

### Step 3: Install on Each Laptop

On each child's laptop:

1. **Create installation directory:**
   ```powershell
   New-Item -ItemType Directory -Path "C:\Program Files\ScreenTimer" -Force
   ```

2. **Copy files:**
   - Copy all files from your deployment package to `C:\Program Files\ScreenTimer`

3. **Update Setup Script:**
   Edit `Setup-TaskScheduler.ps1` and change line 4 to:
   ```powershell
   $exePath = "C:\Program Files\ScreenTimer\ScreenTimer.exe"
   ```

4. **Run setup as Administrator:**
   ```powershell
   cd "C:\Program Files\ScreenTimer"
   .\Setup-TaskScheduler.ps1
   ```

### Step 4: Configure Time Limits

For each child, edit their config file:

**Location:** `C:\Users\[ChildUsername]\AppData\Local\screen-timer\config.txt`

Example configuration:
```
180  (Sunday - 3 hours)
90   (Monday - 1.5 hours - school day)
90   (Tuesday - 1.5 hours)
90   (Wednesday - 1.5 hours)
90   (Thursday - 1.5 hours)
120  (Friday - 2 hours)
180  (Saturday - 3 hours)
```

### Step 5: Increase Tamper Resistance (Optional)

#### Option A: File Permissions

Prevent the child from modifying config:

```powershell
$configPath = "$env:LOCALAPPDATA\screen-timer\config.txt"
$acl = Get-Acl $configPath
$username = $env:USERNAME
$permission = $username,"Read","Allow"
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule $permission
$acl.SetAccessRule($accessRule)
Set-Acl $configPath $acl
```

#### Option B: Run as SYSTEM (Advanced)

Modify the Task Scheduler setup to run as SYSTEM:

```powershell
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
```

**Note:** If running as SYSTEM, config location changes to:
`C:\Windows\System32\config\systemprofile\AppData\Local\screen-timer\config.txt`

It's better to use a shared location like `C:\ProgramData\screen-timer\`.

#### Option C: Hide System Tray Icon

Edit `Form1.cs` line 42 and set:
```csharp
_notifyIcon.Visible = false;
```

Then rebuild and redeploy.

### Step 6: Test

On each laptop:

1. Start the task manually:
   ```powershell
   Start-ScheduledTask -TaskName "ScreenTimer"
   ```

2. Check system tray for the icon

3. Right-click and choose "Show Status" to verify it's tracking

4. Open Config Folder to verify location

5. Restart the laptop to test auto-start

## Monitoring & Maintenance

### Check Usage Data

View usage history:
```powershell
Get-Content "$env:LOCALAPPDATA\screen-timer\usage.txt"
```

### Update Time Limits

To change limits remotely (if using network shares):

1. Create a shared config location
2. Modify `ConfigManager.cs` to read from network path
3. Rebuild and redeploy

### Troubleshooting

**App not starting:**
- Check Task Scheduler: `Get-ScheduledTask -TaskName "ScreenTimer"`
- Check event logs: `Get-EventLog -LogName Application -Source "ScreenTimer"`
- Verify .NET 9.0 Runtime is installed

**Time not tracking:**
- Check if process is running: `Get-Process ScreenTimer`
- Verify usage file is being updated
- Check file permissions

**Lock not working:**
- User account must not have "Bypass workstation lock" policy
- Verify `LockWorkStation()` is being called (check code)

## Uninstalling

To remove from a laptop:

```powershell
# Stop and remove task
Stop-ScheduledTask -TaskName "ScreenTimer"
Unregister-ScheduledTask -TaskName "ScreenTimer" -Confirm:$false

# Stop running process
Stop-Process -Name "ScreenTimer" -Force

# Remove files
Remove-Item -Path "C:\Program Files\ScreenTimer" -Recurse -Force
Remove-Item -Path "$env:LOCALAPPDATA\screen-timer" -Recurse -Force
```

## Advanced: Centralized Management

For managing multiple laptops:

1. **Store configs on network share:**
   - Modify code to read from `\\server\share\configs\[username]\config.txt`

2. **Collect usage data centrally:**
   - Modify `TimeTracker.cs` to write to network location
   - Set up scheduled task to sync usage data

3. **Remote updates:**
   - Use Group Policy to deploy updates
   - Or use configuration management tool (Ansible, etc.)

## Security Considerations

⚠️ **Important Notes:**

- This app is not military-grade security
- Tech-savvy kids can bypass it (Task Manager, Safe Mode, etc.)
- It's designed as a "gentle reminder" system
- For serious enforcement, consider commercial solutions or Windows Family Safety

**Best used as:**
- Teaching tool for time management
- Reasonable deterrent for younger children
- Conversation starter about screen time

## Support

For issues or questions, check:
- README.md for general usage
- Application logs in Event Viewer
- Task Scheduler history
