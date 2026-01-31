namespace ScreenTimer;

public partial class ScreenTimerForm : Form
{
    private NotifyIcon _notifyIcon = null!;
    private System.Windows.Forms.Timer _timer = null!;
    private ConfigManager _configManager = null!;
    private TimeTracker _timeTracker = null!;
    private NotificationManager _notificationManager = null!;
    private LockManager _lockManager = null!;
    private TimeDisplayWidget _displayWidget = null!;
    private string _lastDate = null!;

    public ScreenTimerForm()
    {
        InitializeComponent();
        InitializeComponents();
        _lastDate = DateTime.Now.ToString("yyyy-MM-dd");
    }

    private void InitializeComponents()
    {
        _configManager = new ConfigManager();
        _timeTracker = new TimeTracker();
        _notificationManager = new NotificationManager();
        _lockManager = new LockManager();

        this.WindowState = FormWindowState.Minimized;
        this.ShowInTaskbar = false;
        this.FormBorderStyle = FormBorderStyle.FixedToolWindow;
        this.Load += ScreenTimerForm_Load;

        _notifyIcon = new NotifyIcon();
        _notifyIcon.Icon = SystemIcons.Information;
        _notifyIcon.Text = "Screen Timer - Running";
        _notifyIcon.Visible = true;
        _notifyIcon.ContextMenuStrip = CreateContextMenu();

        _displayWidget = new TimeDisplayWidget();
        _displayWidget.FormClosing += DisplayWidget_FormClosing;
        _displayWidget.Show();

        _timer = new System.Windows.Forms.Timer();
        _timer.Interval = 60000;
        _timer.Tick += Timer_Tick;
        _timer.Start();

        UpdateDisplay();
    }

    private ContextMenuStrip CreateContextMenu()
    {
        var contextMenu = new ContextMenuStrip();
        
        var showHideItem = new ToolStripMenuItem("Hide Timer");
        showHideItem.Click += (s, e) =>
        {
            if (_displayWidget.Visible)
            {
                _displayWidget.Hide();
                showHideItem.Text = "Show Timer";
            }
            else
            {
                _displayWidget.Show();
                showHideItem.Text = "Hide Timer";
            }
        };
        
        contextMenu.Items.Add(showHideItem);
        
        return contextMenu;
    }

    private void DisplayWidget_FormClosing(object? sender, FormClosingEventArgs e)
    {
        if (e.CloseReason == CloseReason.UserClosing)
        {
            e.Cancel = true;
            _displayWidget.Hide();
            
            if (_notifyIcon.ContextMenuStrip?.Items[0] is ToolStripMenuItem menuItem)
            {
                menuItem.Text = "Show Timer";
            }
        }
    }

    private void ScreenTimerForm_Load(object? sender, EventArgs e)
    {
        this.Hide();
    }

    private void Timer_Tick(object? sender, EventArgs e)
    {
        string currentDate = DateTime.Now.ToString("yyyy-MM-dd");
        if (currentDate != _lastDate)
        {
            _lastDate = currentDate;
            _notificationManager.ResetNotifications();
            _lockManager.ResetLockStatus();
        }

        _timeTracker.IncrementMinute();

        int minutesUsed = _timeTracker.GetMinutesToday();
        int limitMinutes = _configManager.GetLimitForToday();
        int minutesRemaining = limitMinutes - minutesUsed;

        UpdateDisplay();

        _notificationManager.CheckAndNotify(minutesRemaining);
        _lockManager.LockIfNeeded(minutesUsed, limitMinutes);
    }

    private void UpdateDisplay()
    {
        int minutesUsed = _timeTracker.GetMinutesToday();
        int limitMinutes = _configManager.GetLimitForToday();
        int minutesRemaining = Math.Max(0, limitMinutes - minutesUsed);

        _displayWidget.UpdateTime(minutesRemaining);
    }

    protected override void Dispose(bool disposing)
    {
        if (disposing)
        {
            _timer?.Stop();
            _timer?.Dispose();
            _notifyIcon?.Dispose();
            _displayWidget?.Dispose();
        }
        base.Dispose(disposing);
    }
}
