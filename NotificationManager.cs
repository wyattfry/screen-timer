using System.Runtime.InteropServices;

namespace ScreenTimer;

public class NotificationManager
{
    private HashSet<int> _notifiedMinutes = new HashSet<int>();

    public void CheckAndNotify(int minutesRemaining)
    {
        if (minutesRemaining <= 0)
        {
            return;
        }

        if ((minutesRemaining == 30 || minutesRemaining == 10 || minutesRemaining == 1) 
            && !_notifiedMinutes.Contains(minutesRemaining))
        {
            ShowNotification($"Screen Time Warning", 
                $"You have {minutesRemaining} minute{(minutesRemaining > 1 ? "s" : "")} of screen time remaining.");
            _notifiedMinutes.Add(minutesRemaining);
        }
    }

    public void ResetNotifications()
    {
        _notifiedMinutes.Clear();
    }

    private void ShowNotification(string title, string message)
    {
        try
        {
            MessageBox.Show(message, title, MessageBoxButtons.OK, MessageBoxIcon.Information,
                MessageBoxDefaultButton.Button1, MessageBoxOptions.DefaultDesktopOnly);
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"Error showing notification: {ex.Message}");
        }
    }
}
