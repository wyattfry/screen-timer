namespace ScreenTimer;

public class TimeTracker
{
    private readonly string _usagePath;
    private string _currentDate;
    private int _minutesToday;

    public TimeTracker()
    {
        string appDataPath = Path.Combine(
            Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
            "screen-timer"
        );
        Directory.CreateDirectory(appDataPath);
        _usagePath = Path.Combine(appDataPath, "usage.txt");
        _currentDate = DateTime.Now.ToString("yyyy-MM-dd");
        LoadTodayUsage();
    }

    private void LoadTodayUsage()
    {
        _minutesToday = 0;
        
        if (!File.Exists(_usagePath))
        {
            return;
        }

        try
        {
            string[] lines = File.ReadAllLines(_usagePath);
            foreach (string line in lines)
            {
                string[] parts = line.Split(',');
                if (parts.Length == 2 && parts[0] == _currentDate)
                {
                    if (int.TryParse(parts[1], out int minutes))
                    {
                        _minutesToday = minutes;
                    }
                    break;
                }
            }
        }
        catch (Exception ex)
        {
            MessageBox.Show($"Error reading usage data: {ex.Message}", "Usage Error",
                MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
    }

    public void IncrementMinute()
    {
        string today = DateTime.Now.ToString("yyyy-MM-dd");
        
        if (today != _currentDate)
        {
            _currentDate = today;
            _minutesToday = 0;
        }

        _minutesToday++;
        SaveUsage();
    }

    private void SaveUsage()
    {
        try
        {
            List<string> lines = new List<string>();
            bool foundToday = false;

            if (File.Exists(_usagePath))
            {
                string[] existingLines = File.ReadAllLines(_usagePath);
                foreach (string line in existingLines)
                {
                    string[] parts = line.Split(',');
                    if (parts.Length == 2 && parts[0] == _currentDate)
                    {
                        lines.Add($"{_currentDate},{_minutesToday}");
                        foundToday = true;
                    }
                    else
                    {
                        lines.Add(line);
                    }
                }
            }

            if (!foundToday)
            {
                lines.Add($"{_currentDate},{_minutesToday}");
            }

            File.WriteAllLines(_usagePath, lines);
        }
        catch (Exception ex)
        {
            MessageBox.Show($"Error saving usage data: {ex.Message}", "Usage Error",
                MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
    }

    public int GetMinutesToday()
    {
        string today = DateTime.Now.ToString("yyyy-MM-dd");
        if (today != _currentDate)
        {
            _currentDate = today;
            _minutesToday = 0;
        }
        return _minutesToday;
    }

    public string GetUsagePath()
    {
        return _usagePath;
    }
}
