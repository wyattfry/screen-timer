namespace ScreenTimer;

public class TimeDisplayWidget : Form
{
    private Label _timeLabel = null!;
    private double _opacity = 0.8;
    private bool _isDragging = false;
    private Point _dragStart;

    public TimeDisplayWidget()
    {
        InitializeWidget();
    }

    private void InitializeWidget()
    {
        this.FormBorderStyle = FormBorderStyle.None;
        this.StartPosition = FormStartPosition.Manual;
        this.TopMost = true;
        this.ShowInTaskbar = false;
        this.BackColor = Color.Black;
        this.Opacity = _opacity;
        this.Size = new Size(180, 60);
        
        int screenWidth = Screen.PrimaryScreen?.WorkingArea.Width ?? 1920;
        int screenHeight = Screen.PrimaryScreen?.WorkingArea.Height ?? 1080;
        this.Location = new Point(screenWidth - this.Width - 10, 10);

        _timeLabel = new Label
        {
            Dock = DockStyle.Fill,
            Font = new Font("Segoe UI", 14, FontStyle.Bold),
            ForeColor = Color.White,
            TextAlign = ContentAlignment.MiddleCenter,
            Text = "Loading...",
            Cursor = Cursors.SizeAll
        };

        _timeLabel.MouseDown += TimeLabel_MouseDown;
        _timeLabel.MouseMove += TimeLabel_MouseMove;
        _timeLabel.MouseUp += TimeLabel_MouseUp;
        _timeLabel.MouseEnter += (s, e) => this.Opacity = 0.95;
        _timeLabel.MouseLeave += (s, e) => this.Opacity = _opacity;

        this.Controls.Add(_timeLabel);
        this.ContextMenuStrip = null;
    }

    private void TimeLabel_MouseDown(object? sender, MouseEventArgs e)
    {
        if (e.Button == MouseButtons.Left)
        {
            _isDragging = true;
            _dragStart = e.Location;
        }
    }

    private void TimeLabel_MouseMove(object? sender, MouseEventArgs e)
    {
        if (_isDragging)
        {
            Point newLocation = this.Location;
            newLocation.X += e.X - _dragStart.X;
            newLocation.Y += e.Y - _dragStart.Y;
            this.Location = newLocation;
        }
    }

    private void TimeLabel_MouseUp(object? sender, MouseEventArgs e)
    {
        _isDragging = false;
    }

    public void UpdateTime(int minutesRemaining)
    {
        if (_timeLabel.InvokeRequired)
        {
            _timeLabel.Invoke(new Action(() => UpdateTime(minutesRemaining)));
            return;
        }

        int hours = minutesRemaining / 60;
        int mins = minutesRemaining % 60;

        if (minutesRemaining <= 0)
        {
            _timeLabel.Text = "TIME'S UP!";
            _timeLabel.ForeColor = Color.Red;
            this.BackColor = Color.DarkRed;
        }
        else if (minutesRemaining <= 10)
        {
            _timeLabel.Text = $"{mins}m left";
            _timeLabel.ForeColor = Color.Yellow;
            this.BackColor = Color.DarkRed;
        }
        else if (minutesRemaining <= 30)
        {
            _timeLabel.Text = hours > 0 ? $"{hours}h {mins}m left" : $"{mins}m left";
            _timeLabel.ForeColor = Color.Orange;
            this.BackColor = Color.DarkOrange;
        }
        else
        {
            _timeLabel.Text = hours > 0 ? $"{hours}h {mins}m left" : $"{mins}m left";
            _timeLabel.ForeColor = Color.LightGreen;
            this.BackColor = Color.DarkGreen;
        }
    }

    protected override void OnPaint(PaintEventArgs e)
    {
        base.OnPaint(e);
        ControlPaint.DrawBorder(e.Graphics, ClientRectangle,
            Color.Gray, 2, ButtonBorderStyle.Solid,
            Color.Gray, 2, ButtonBorderStyle.Solid,
            Color.Gray, 2, ButtonBorderStyle.Solid,
            Color.Gray, 2, ButtonBorderStyle.Solid);
    }
}
