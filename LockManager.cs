using System.Runtime.InteropServices;

namespace ScreenTimer;

public class LockManager
{
    [DllImport("user32.dll")]
    private static extern bool LockWorkStation();

    private bool _hasLockedToday = false;

    public void LockIfNeeded(int minutesUsed, int limitMinutes)
    {
        if (minutesUsed >= limitMinutes && !_hasLockedToday)
        {
            _hasLockedToday = true;
            MessageBox.Show("Your screen time limit has been reached. The computer will now lock.",
                "Screen Time Limit Reached", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            LockWorkStation();
        }
    }

    public void ResetLockStatus()
    {
        _hasLockedToday = false;
    }
}
