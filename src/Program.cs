namespace ScreenTimer;

static class Program
{
    private static Mutex? _mutex;

    [STAThread]
    static void Main()
    {
        const string mutexName = "ScreenTimer_SingleInstance_8F6F0AC4-B9A1-45fd-A8CF-72F04E6BDE8F";
        
        _mutex = new Mutex(true, mutexName, out bool isFirstInstance);
        
        if (!isFirstInstance)
        {
            MessageBox.Show("Screen Timer is already running.", "Already Running",
                MessageBoxButtons.OK, MessageBoxIcon.Information);
            return;
        }
        
        try
        {
            ApplicationConfiguration.Initialize();
            Application.Run(new ScreenTimerForm());
        }
        finally
        {
            _mutex?.ReleaseMutex();
            _mutex?.Dispose();
        }
    }    
}
