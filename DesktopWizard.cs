using System;
using System.IO;
using System.Collections.Generic;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Effects;
using System.Windows.Media.Imaging;
using System.Windows.Shapes;
using System.Web.Script.Serialization;
using System.Speech.Synthesis;

namespace DesktopWizard
{
    public class Program
    {
        [STAThread]
        public static void Main(string[] args)
        {
            string targetAgent = null;
            string targetAnim = null;
            string targetSay = null;

            for (int i = 0; i < args.Length; i++)
            {
                string a = args[i].ToLowerInvariant();
                if ((a == "--agent" || a == "-a") && i + 1 < args.Length)
                {
                    targetAgent = args[++i];
                }
                else if ((a == "--play" || a == "-p") && i + 1 < args.Length)
                {
                    targetAnim = args[++i];
                }
                else if ((a == "--say" || a == "-s") && i + 1 < args.Length)
                {
                    targetSay = args[++i];
                }
            }

            App app = new App(targetAgent, targetAnim, targetSay);
            app.InitializeComponent();
            app.Run();
        }
    }

    public class AgentInstance
    {
        public string Name { get; set; }
        public int FrameWidth { get; set; }
        public int FrameHeight { get; set; }
        public int OverlayCount { get; set; }
        public BitmapImage SpriteSheet { get; set; }
        public Dictionary<string, object> Animations { get; set; }
        public Window AgentWindow { get; set; }
        public Image BaseImage { get; set; }
        public Image OverlayImage { get; set; }
        public Window BalloonWindow { get; set; }
        public TextBlock BalloonText { get; set; }
        public Border BalloonBorder { get; set; }
        public MediaPlayer SoundPlayer { get; set; }
        public string AgentDir { get; set; }
        public App ParentApp { get; set; }

        public void Show()
        {
            ParentApp.Dispatcher.Invoke(new Action(() =>
            {
                AgentWindow.Show();
            }));
            Play("Show");
        }

        public void Hide()
        {
            Play("Hide");
            ParentApp.Dispatcher.Invoke(new Action(() =>
            {
                AgentWindow.Hide();
                if (BalloonWindow.IsVisible) BalloonWindow.Hide();
            }));
        }

        public void MoveTo(double x, double y)
        {
            ParentApp.Dispatcher.Invoke(new Action(() =>
            {
                AgentWindow.Left = x;
                AgentWindow.Top = y;
                UpdateBalloonPosition();
            }));
        }

        public void SmoothMoveTo(double targetX, double targetY, int durationMs)
        {
            double startX = 0, startY = 0;
            ParentApp.Dispatcher.Invoke(new Action(() =>
            {
                startX = AgentWindow.Left;
                startY = AgentWindow.Top;
            }));

            int steps = 25;
            int stepDelay = durationMs / steps;
            for (int i = 1; i <= steps && !ParentApp.IsCanceled; i++)
            {
                double t = i / (double)steps;
                double ease = 0.5 * (1.0 - Math.Cos(Math.PI * t));
                double curX = startX + (targetX - startX) * ease;
                double curY = startY + (targetY - startY) * ease;

                ParentApp.Dispatcher.Invoke(new Action(() =>
                {
                    AgentWindow.Left = curX;
                    AgentWindow.Top = curY;
                    UpdateBalloonPosition();
                }));
                Thread.Sleep(stepDelay);
            }
        }

        public void Speak(string text)
        {
            if (ParentApp.IsCanceled) return;

            ParentApp.Dispatcher.Invoke(new Action(() =>
            {
                BalloonText.Text = text;
                UpdateBalloonPosition();
                BalloonWindow.Show();
            }));

            if (!ParentApp.IsMuted && ParentApp.Synthesizer != null)
            {
                try
                {
                    ParentApp.Synthesizer.Speak(text);
                }
                catch
                {
                    Thread.Sleep(Math.Max(1500, text.Length * 50));
                }
            }
            else
            {
                Thread.Sleep(Math.Max(1500, text.Length * 50));
            }
        }

        public void Play(string animName)
        {
            if (ParentApp.IsCanceled || !Animations.ContainsKey(animName)) return;

            Dictionary<string, object> anim = (Dictionary<string, object>)Animations[animName];
            object[] frames = (object[])anim["frames"];

            for (int i = 0; i < frames.Length && !ParentApp.IsCanceled; i++)
            {
                Dictionary<string, object> frame = (Dictionary<string, object>)frames[i];
                int duration = Convert.ToInt32(frame["duration"]);
                if (duration <= 0 && i == frames.Length - 1) break;

                if (!ParentApp.IsMuted && frame.ContainsKey("sound") && frame["sound"] != null)
                {
                    string sndId = frame["sound"].ToString();
                    PlaySound(sndId);
                }

                if (frame.ContainsKey("images") && frame["images"] != null)
                {
                    object[] imgArr = (object[])frame["images"];
                    if (imgArr.Length == 1)
                    {
                        object[] xy = (object[])imgArr[0];
                        SetFrame(Convert.ToInt32(xy[0]), Convert.ToInt32(xy[1]));
                    }
                    else if (imgArr.Length >= 2)
                    {
                        object[] xy1 = (object[])imgArr[0];
                        object[] xy2 = (object[])imgArr[1];
                        SetFrameWithOverlay(
                            Convert.ToInt32(xy1[0]), Convert.ToInt32(xy1[1]),
                            Convert.ToInt32(xy2[0]), Convert.ToInt32(xy2[1])
                        );
                    }
                }

                if (duration > 0)
                {
                    Thread.Sleep(duration);
                }
            }
        }

        public void SetFrame(int x, int y)
        {
            ParentApp.Dispatcher.Invoke(new Action(() =>
            {
                Int32Rect rect = new Int32Rect(x, y, FrameWidth, FrameHeight);
                CroppedBitmap crop = new CroppedBitmap(SpriteSheet, rect);
                BaseImage.Source = crop;
                OverlayImage.Source = null;
            }));
        }

        public void SetFrameWithOverlay(int x1, int y1, int x2, int y2)
        {
            ParentApp.Dispatcher.Invoke(new Action(() =>
            {
                Int32Rect rect1 = new Int32Rect(x1, y1, FrameWidth, FrameHeight);
                CroppedBitmap crop1 = new CroppedBitmap(SpriteSheet, rect1);
                BaseImage.Source = crop1;

                Int32Rect rect2 = new Int32Rect(x2, y2, FrameWidth, FrameHeight);
                CroppedBitmap crop2 = new CroppedBitmap(SpriteSheet, rect2);
                OverlayImage.Source = crop2;
            }));
        }

        public void PlaySound(string soundId)
        {
            string sndPath = System.IO.Path.Combine(AgentDir, "sounds", soundId + ".mp3");
            if (File.Exists(sndPath))
            {
                ParentApp.Dispatcher.Invoke(new Action(() =>
                {
                    try
                    {
                        SoundPlayer.Open(new Uri(sndPath, UriKind.Absolute));
                        SoundPlayer.Play();
                    }
                    catch { }
                }));
            }
        }

        public void UpdateBalloonPosition()
        {
            if (BalloonWindow != null && BalloonWindow.IsVisible && AgentWindow != null)
            {
                Rect workArea = SystemParameters.WorkArea;
                double bWidth = BalloonWindow.ActualWidth > 0 ? BalloonWindow.ActualWidth : 260;
                double bHeight = BalloonWindow.ActualHeight > 0 ? BalloonWindow.ActualHeight : 80;

                double targetLeft = AgentWindow.Left + FrameWidth + 6;
                double targetTop = AgentWindow.Top - 15;

                if (targetLeft + bWidth > workArea.Right - 10)
                {
                    targetLeft = AgentWindow.Left - bWidth - 8;
                }
                if (targetTop < workArea.Top + 10)
                {
                    targetTop = workArea.Top + 10;
                }
                else if (targetTop + bHeight > workArea.Bottom - 10)
                {
                    targetTop = workArea.Bottom - bHeight - 10;
                }
                if (targetLeft < workArea.Left + 10)
                {
                    targetLeft = Math.Max(workArea.Left + 10, AgentWindow.Left);
                    targetTop = AgentWindow.Top + FrameHeight + 10;
                }

                BalloonWindow.Left = targetLeft;
                BalloonWindow.Top = targetTop;
            }
        }
    }

    public class App : Application
    {
        public bool IsCanceled { get; set; }
        public bool IsMuted { get; set; }
        public SpeechSynthesizer Synthesizer { get; set; }

        private string cliAgent;
        private string cliAnim;
        private string cliSay;
        private string appDir;
        private Dictionary<string, AgentInstance> loadedAgents = new Dictionary<string, AgentInstance>();

        public App(string agent, string anim, string say)
        {
            cliAgent = agent;
            cliAnim = anim;
            cliSay = say;
            IsCanceled = false;
            IsMuted = false;
        }

        public void InitializeComponent()
        {
            appDir = AppDomain.CurrentDomain.BaseDirectory;

            try
            {
                Synthesizer = new SpeechSynthesizer();
                Synthesizer.Rate = 0;
            }
            catch { }

            // Pre-load available agents: Merlin, Genie, Peedy, Clippy
            string[] knownAgents = new string[] { "Merlin", "Genie", "Peedy", "Clippy" };
            foreach (string name in knownAgents)
            {
                string dir = System.IO.Path.Combine(appDir, "agents", name);
                if (Directory.Exists(dir))
                {
                    LoadAgent(name, dir);
                }
            }

            // Fallback for Merlin in root if agents/Merlin was missing
            if (!loadedAgents.ContainsKey("Merlin") && File.Exists(System.IO.Path.Combine(appDir, "map.png")))
            {
                LoadAgent("Merlin", appDir);
            }
        }

        private void LoadAgent(string name, string dir)
        {
            string mapPath = System.IO.Path.Combine(dir, "map.png");
            string jsonPath = System.IO.Path.Combine(dir, "agent.json");
            if (!File.Exists(mapPath) || !File.Exists(jsonPath)) return;

            JavaScriptSerializer js = new JavaScriptSerializer { MaxJsonLength = int.MaxValue };
            Dictionary<string, object> root = (Dictionary<string, object>)js.DeserializeObject(File.ReadAllText(jsonPath));
            Dictionary<string, object> anims = (Dictionary<string, object>)root["animations"];

            object[] fSize = (object[])root["framesize"];
            int fw = Convert.ToInt32(fSize[0]);
            int fh = Convert.ToInt32(fSize[1]);
            int overlayCount = root.ContainsKey("overlayCount") ? Convert.ToInt32(root["overlayCount"]) : 1;

            AgentInstance inst = new AgentInstance
            {
                Name = name,
                FrameWidth = fw,
                FrameHeight = fh,
                OverlayCount = overlayCount,
                SpriteSheet = new BitmapImage(new Uri(mapPath, UriKind.Absolute)),
                Animations = anims,
                AgentDir = dir,
                SoundPlayer = new MediaPlayer(),
                ParentApp = this
            };

            CreateWindowsForAgent(inst);
            loadedAgents[name] = inst;
        }

        private void CreateWindowsForAgent(AgentInstance agent)
        {
            // Agent Transparent Window
            Window win = new Window
            {
                Title = agent.Name,
                Width = agent.FrameWidth,
                Height = agent.FrameHeight,
                WindowStyle = WindowStyle.None,
                AllowsTransparency = true,
                Background = Brushes.Transparent,
                Topmost = true,
                ShowInTaskbar = false,
                Cursor = Cursors.Hand
            };

            Grid grid = new Grid { Width = agent.FrameWidth, Height = agent.FrameHeight };
            Image baseImg = new Image { Width = agent.FrameWidth, Height = agent.FrameHeight, Stretch = Stretch.None };
            Image overImg = new Image { Width = agent.FrameWidth, Height = agent.FrameHeight, Stretch = Stretch.None };

            grid.Children.Add(baseImg);
            grid.Children.Add(overImg);
            win.Content = grid;

            agent.AgentWindow = win;
            agent.BaseImage = baseImg;
            agent.OverlayImage = overImg;

            // Dragging
            win.MouseLeftButtonDown += (s, e) =>
            {
                if (e.ButtonState == MouseButtonState.Pressed)
                {
                    try { win.DragMove(); agent.UpdateBalloonPosition(); } catch { }
                }
            };

            // Double click: fun animation
            win.MouseDoubleClick += (s, e) =>
            {
                new Thread(() =>
                {
                    string funAnim = "Congratulate";
                    if (!agent.Animations.ContainsKey(funAnim)) funAnim = "Wave";
                    if (!agent.Animations.ContainsKey(funAnim)) funAnim = "Pleased";
                    agent.Play(funAnim);
                }).Start();
            };

            // Context Menu
            ContextMenu cm = new ContextMenu();
            MenuItem miTitle = new MenuItem { Header = string.Format("{0} (Microsoft Agent)", agent.Name), IsEnabled = false };
            cm.Items.Add(miTitle);
            cm.Items.Add(new Separator());

            // Submenu: Play Animation
            MenuItem miPlay = new MenuItem { Header = "Play Animation" };
            string[] topAnims = new string[] { "Wave", "Congratulate", "Suggest", "Explain", "Thinking", "Pleased", "Acknowledge", "GetAttention" };
            foreach (string anim in topAnims)
            {
                if (agent.Animations.ContainsKey(anim))
                {
                    string target = anim;
                    MenuItem miAnim = new MenuItem { Header = target };
                    miAnim.Click += (s, e) => new Thread(() => agent.Play(target)).Start();
                    miPlay.Items.Add(miAnim);
                }
            }
            cm.Items.Add(miPlay);

            // Custom Speak Dialog
            MenuItem miSay = new MenuItem { Header = "Speak Custom Text..." };
            miSay.Click += (s, e) => PromptCustomSpeak(agent);
            cm.Items.Add(miSay);

            cm.Items.Add(new Separator());

            // Mute / Unmute
            MenuItem miMute = new MenuItem { Header = "Mute Voice / Audio" };
            miMute.Click += (s, e) =>
            {
                IsMuted = !IsMuted;
                miMute.Header = IsMuted ? "Unmute Voice / Audio" : "Mute Voice / Audio";
                if (IsMuted && Synthesizer != null) Synthesizer.SpeakAsyncCancelAll();
            };
            cm.Items.Add(miMute);

            // Hide Agent
            MenuItem miHide = new MenuItem { Header = "Hide Agent" };
            miHide.Click += (s, e) => new Thread(() => agent.Hide()).Start();
            cm.Items.Add(miHide);

            // Show All Agents
            MenuItem miShowAll = new MenuItem { Header = "Show All Agents" };
            miShowAll.Click += (s, e) => new Thread(() => ShowAllAgents()).Start();
            cm.Items.Add(miShowAll);

            // Exit
            MenuItem miExit = new MenuItem { Header = "Exit (ESC)" };
            miExit.Click += (s, e) => CancelAndClose();
            cm.Items.Add(miExit);

            win.ContextMenu = cm;

            win.KeyDown += (s, e) =>
            {
                if (e.Key == Key.Escape) CancelAndClose();
            };

            win.LocationChanged += (s, e) => agent.UpdateBalloonPosition();

            // Speech Balloon Window
            Window bWin = new Window
            {
                Title = agent.Name + " Speech",
                WindowStyle = WindowStyle.None,
                AllowsTransparency = true,
                Background = Brushes.Transparent,
                Topmost = true,
                ShowInTaskbar = false,
                SizeToContent = SizeToContent.WidthAndHeight
            };

            Border border = new Border
            {
                Background = new SolidColorBrush(Color.FromRgb(255, 253, 226)),
                BorderBrush = new SolidColorBrush(Color.FromRgb(74, 74, 74)),
                BorderThickness = new Thickness(1.8),
                CornerRadius = new CornerRadius(12),
                Padding = new Thickness(14, 10, 14, 10),
                Margin = new Thickness(12),
                Effect = new DropShadowEffect
                {
                    BlurRadius = 10,
                    ShadowDepth = 2,
                    Opacity = 0.28,
                    Color = Color.FromRgb(30, 30, 30)
                }
            };

            TextBlock tb = new TextBlock
            {
                FontSize = 13.5,
                FontFamily = new FontFamily("Comic Sans MS, Segoe UI, Tahoma"),
                Foreground = new SolidColorBrush(Color.FromRgb(25, 25, 25)),
                TextWrapping = TextWrapping.Wrap,
                MaxWidth = 290,
                LineHeight = 19
            };

            border.Child = tb;
            bWin.Content = border;

            bWin.KeyDown += (s, e) =>
            {
                if (e.Key == Key.Escape) CancelAndClose();
            };

            agent.BalloonWindow = bWin;
            agent.BalloonBorder = border;
            agent.BalloonText = tb;
        }

        private void PromptCustomSpeak(AgentInstance agent)
        {
            Window dialog = new Window
            {
                Title = "Speak with " + agent.Name,
                Width = 380,
                Height = 150,
                WindowStartupLocation = WindowStartupLocation.CenterScreen,
                ResizeMode = ResizeMode.NoResize,
                Topmost = true
            };

            StackPanel sp = new StackPanel { Margin = new Thickness(14) };
            TextBlock lbl = new TextBlock { Text = string.Format("Enter text for {0} to say:", agent.Name), Margin = new Thickness(0, 0, 0, 8), FontWeight = FontWeights.SemiBold };
            TextBox txt = new TextBox { Text = "Hello! I am ready to help you.", Margin = new Thickness(0, 0, 0, 12), Padding = new Thickness(4) };

            StackPanel btnPanel = new StackPanel { Orientation = Orientation.Horizontal, HorizontalAlignment = HorizontalAlignment.Right };
            Button btnSpeak = new Button { Content = "Speak", Width = 75, Height = 26, Margin = new Thickness(0, 0, 8, 0), IsDefault = true };
            Button btnCancel = new Button { Content = "Cancel", Width = 75, Height = 26, IsCancel = true };

            btnSpeak.Click += (s, e) =>
            {
                string textToSay = txt.Text;
                dialog.Close();
                new Thread(() => agent.Speak(textToSay)).Start();
            };

            btnPanel.Children.Add(btnSpeak);
            btnPanel.Children.Add(btnCancel);

            sp.Children.Add(lbl);
            sp.Children.Add(txt);
            sp.Children.Add(btnPanel);

            dialog.Content = sp;
            dialog.ShowDialog();
        }

        protected override void OnStartup(StartupEventArgs e)
        {
            base.OnStartup(e);

            Thread worker = new Thread(RunWorkflow);
            worker.IsBackground = true;
            worker.Start();
        }

        private void RunWorkflow()
        {
            try
            {
                Thread.Sleep(300);

                // Mode 1: CLI Direct Call
                if (!string.IsNullOrEmpty(cliAgent) && loadedAgents.ContainsKey(cliAgent))
                {
                    RunCliMode(loadedAgents[cliAgent]);
                    return;
                }

                // Mode 2: Multi-Agent Interactive Showcase Demo
                RunMultiAgentShowcase();
            }
            catch (Exception ex)
            {
                Debug.WriteLine("Error: " + ex.Message);
            }
        }

        private void RunCliMode(AgentInstance agent)
        {
            Rect workArea = SystemParameters.WorkArea;
            agent.MoveTo(workArea.Left + workArea.Width * 0.7, workArea.Top + workArea.Height * 0.4);
            agent.SetFrame(0, 0);
            agent.Show();

            if (!string.IsNullOrEmpty(cliAnim) && agent.Animations.ContainsKey(cliAnim))
            {
                agent.Play(cliAnim);
            }

            if (!string.IsNullOrEmpty(cliSay))
            {
                agent.Speak(cliSay);
            }

            Thread.Sleep(1000);
            agent.Hide();
            Dispatcher.Invoke(new Action(() => Shutdown()));
        }

        private void RunMultiAgentShowcase()
        {
            Rect workArea = SystemParameters.WorkArea;

            // Target positions for the agents
            double merlinX = workArea.Left + workArea.Width * 0.20;
            double merlinY = workArea.Top + workArea.Height * 0.35;

            double genieX = workArea.Left + workArea.Width * 0.42;
            double genieY = workArea.Top + workArea.Height * 0.30;

            double peedyX = workArea.Left + workArea.Width * 0.64;
            double peedyY = workArea.Top + workArea.Height * 0.35;

            double clippyX = workArea.Left + workArea.Width * 0.82;
            double clippyY = workArea.Top + workArea.Height * 0.45;

            // 1. Merlin Arrives
            if (loadedAgents.ContainsKey("Merlin") && !IsCanceled)
            {
                AgentInstance merlin = loadedAgents["Merlin"];
                merlin.MoveTo(merlinX, merlinY);
                merlin.SetFrame(0, 0);
                merlin.Show();
                merlin.Play("GetAttention");
                merlin.Speak("Welcome! Microsoft Agent is back on modern Windows with zero installation!");
                Thread.Sleep(800);
            }

            // 2. Genie Arrives
            if (loadedAgents.ContainsKey("Genie") && !IsCanceled)
            {
                AgentInstance genie = loadedAgents["Genie"];
                genie.MoveTo(genieX, genieY);
                genie.SetFrame(0, 0);
                genie.Show();
                genie.Play("Acknowledge");
                genie.Speak("Your wish is granted! We are fully interactive desktop companions.");
                Thread.Sleep(800);
            }

            // 3. Peedy Arrives
            if (loadedAgents.ContainsKey("Peedy") && !IsCanceled)
            {
                AgentInstance peedy = loadedAgents["Peedy"];
                peedy.MoveTo(peedyX, peedyY);
                peedy.SetFrame(0, 0);
                peedy.Show();
                peedy.Play("Suggest");
                peedy.Speak("Squawk! We can speak, animate, and fly across your desktop!");
                Thread.Sleep(800);
            }

            // 4. Clippy Arrives
            if (loadedAgents.ContainsKey("Clippy") && !IsCanceled)
            {
                AgentInstance clippy = loadedAgents["Clippy"];
                clippy.MoveTo(clippyX, clippyY);
                clippy.SetFrame(0, 0);
                clippy.Show();
                clippy.Play("GetAttention");
                clippy.Speak("It looks like you're building a project! Drag us anywhere or right-click us!");
                Thread.Sleep(1000);
            }

            // Agents stay active on screen! The user can now freely drag them, right-click, test custom dialogue!
        }

        public void ShowAllAgents()
        {
            Rect workArea = SystemParameters.WorkArea;
            double[] xPos = new double[] { 0.20, 0.42, 0.64, 0.82 };
            int i = 0;
            foreach (var kvp in loadedAgents)
            {
                AgentInstance a = kvp.Value;
                double targetX = workArea.Left + workArea.Width * xPos[Math.Min(i, 3)];
                double targetY = workArea.Top + workArea.Height * 0.35;
                a.MoveTo(targetX, targetY);
                a.Show();
                i++;
            }
        }

        public void CancelAndClose()
        {
            IsCanceled = true;
            Dispatcher.Invoke(new Action(() =>
            {
                try { if (Synthesizer != null) Synthesizer.SpeakAsyncCancelAll(); } catch { }
                foreach (var kvp in loadedAgents)
                {
                    try { kvp.Value.SoundPlayer.Stop(); } catch { }
                    try { kvp.Value.BalloonWindow.Close(); } catch { }
                    try { kvp.Value.AgentWindow.Close(); } catch { }
                }
                Shutdown();
            }));
        }
    }
}
