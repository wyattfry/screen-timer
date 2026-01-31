namespace ScreenTimer;

public class ConfigManager
{
    private readonly string _configPath;
    private int[] _dailyLimits;

    public ConfigManager()
    {
        string appDataPath = Path.Combine(
            Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
            "screen-timer"
        );
        Directory.CreateDirectory(appDataPath);
        _configPath = Path.Combine(appDataPath, "config.txt");
        _dailyLimits = new int[7];
        LoadConfig();
    }

    private void LoadConfig()
    {
        if (!File.Exists(_configPath))
        {
            CreateDefaultConfig();
        }

        try
        {
            string[] lines = File.ReadAllLines(_configPath);
            for (int i = 0; i < Math.Min(7, lines.Length); i++)
            {
                if (int.TryParse(lines[i].Trim(), out int limit))
                {
                    _dailyLimits[i] = limit;
                }
            }
        }
        catch (Exception ex)
        {
            MessageBox.Show($"Error reading config: {ex.Message}", "Config Error", 
                MessageBoxButtons.OK, MessageBoxIcon.Error);
            CreateDefaultConfig();
        }
    }

    private void CreateDefaultConfig()
    {
        _dailyLimits = new int[] { 240, 120, 120, 120, 120, 180, 240 };
        try
        {
            File.WriteAllLines(_configPath, _dailyLimits.Select(x => x.ToString()));
        }
        catch (Exception ex)
        {
            MessageBox.Show($"Error creating default config: {ex.Message}", "Config Error",
                MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
    }

    public int GetLimitForToday()
    {
        int dayOfWeek = (int)DateTime.Now.DayOfWeek;
        return _dailyLimits[dayOfWeek];
    }

    public string GetConfigPath()
    {
        return _configPath;
    }
}
