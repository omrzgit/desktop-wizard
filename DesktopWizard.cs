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
            string mode = "after";
            if (args != null && args.Length > 0)
            {
                string arg = args[0].ToLowerInvariant();
                if (arg.Contains("demo") || arg.Contains("merlin")) mode = "demo";
            }

            App app = new App(mode);
            app.InitializeComponent();
            app.Run();
        }
    }

    public class App : Application
    {
        private Window merlinWin;
        private Window balloonWin;
        private Image merlinBaseImg;
        private Image merlinOverlayImg;
        private TextBlock balloonText;
        private Border balloonBorder;
        private Polygon balloonTail;
        private BitmapImage spriteSheet;
        private Dictionary<string, object> animations;
        private MediaPlayer soundPlayer;
        private SpeechSynthesizer synth;
        private bool isCanceled = false;
        private bool isMuted = false;
        private string appDir;
        private string scriptMode = "after";

        [DllImport("winmm.dll", EntryPoint = "mciSendStringA", CharSet = CharSet.Ansi)]
        private static extern int mciSendString(string command, StringBuilder buffer, int bufferSize, IntPtr hwndCallback);

        [DllImport("user32.dll")]
        private static extern void keybd_event(byte bVk, byte bScan, uint dwFlags, UIntPtr dwExtraInfo);

        [DllImport("user32.dll")]
        private static extern short GetKeyState(int keyCode);

        [DllImport("user32.dll")]
        private static extern bool SetForegroundWindow(IntPtr hWnd);

        private const byte VK_CAPITAL = 0x14;
        private const byte VK_NUMLOCK = 0x90;
        private const byte VK_SCROLL = 0x91;
        private const uint KEYEVENTF_KEYUP = 0x0002;

        public App(string mode)
        {
            scriptMode = mode;
        }

        public void InitializeComponent()
        {
            appDir = AppDomain.CurrentDomain.BaseDirectory;
            soundPlayer = new MediaPlayer();

            try
            {
                synth = new SpeechSynthesizer();
                synth.Rate = 0;
            }
            catch { }

            LoadAssets();
            CreateMerlinWindow();
            CreateBalloonWindow();
        }

        private void LoadAssets()
        {
            string mapPath = System.IO.Path.Combine(appDir, "map.png");
            if (!File.Exists(mapPath))
            {
                MessageBox.Show("map.png not found at " + mapPath, "Desktop Wizard", MessageBoxButton.OK, MessageBoxImage.Error);
                Environment.Exit(1);
            }
            spriteSheet = new BitmapImage(new Uri(mapPath, UriKind.Absolute));

            string jsonPath = System.IO.Path.Combine(appDir, "agent.json");
            if (!File.Exists(jsonPath))
            {
                MessageBox.Show("agent.json not found at " + jsonPath, "Desktop Wizard", MessageBoxButton.OK, MessageBoxImage.Error);
                Environment.Exit(1);
            }
            string json = File.ReadAllText(jsonPath);
            JavaScriptSerializer js = new JavaScriptSerializer();
            js.MaxJsonLength = int.MaxValue;
            Dictionary<string, object> root = (Dictionary<string, object>)js.DeserializeObject(json);
            animations = (Dictionary<string, object>)root["animations"];
        }

        private void CreateMerlinWindow()
        {
            merlinWin = new Window();
            merlinWin.Title = "Merlin Desktop Wizard";
            merlinWin.Width = 128;
            merlinWin.Height = 128;
            merlinWin.WindowStyle = WindowStyle.None;
            merlinWin.AllowsTransparency = true;
            merlinWin.Background = Brushes.Transparent;
            merlinWin.Topmost = true;
            merlinWin.ShowInTaskbar = false;
            merlinWin.Cursor = Cursors.Hand;

            // Initial responsive position
            Rect workArea = SystemParameters.WorkArea;
            merlinWin.Left = workArea.Left + workArea.Width * 0.65;
            merlinWin.Top = workArea.Top + workArea.Height * 0.35;

            Grid grid = new Grid();
            grid.Width = 128;
            grid.Height = 128;

            merlinBaseImg = new Image();
            merlinBaseImg.Width = 128;
            merlinBaseImg.Height = 128;
            merlinBaseImg.Stretch = Stretch.None;

            merlinOverlayImg = new Image();
            merlinOverlayImg.Width = 128;
            merlinOverlayImg.Height = 128;
            merlinOverlayImg.Stretch = Stretch.None;

            grid.Children.Add(merlinBaseImg);
            grid.Children.Add(merlinOverlayImg);

            merlinWin.Content = grid;

            // Draggable
            merlinWin.MouseLeftButtonDown += (s, e) =>
            {
                if (e.ButtonState == MouseButtonState.Pressed)
                {
                    try
                    {
                        merlinWin.DragMove();
                        UpdateBalloonPosition();
                    }
                    catch { }
                }
            };

            // Double click: Play quick magic sparkle
            merlinWin.MouseDoubleClick += (s, e) =>
            {
                new Thread(() => { Play("Surprised"); Thread.Sleep(400); Play("RestPose"); }).Start();
            };

            // Enhanced Context Menu
            ContextMenu cm = new ContextMenu();
            MenuItem miTitle = new MenuItem { Header = "🧙 Merlin the Wizard", IsEnabled = false };
            MenuItem miMute = new MenuItem { Header = "Mute Voice / Sound" };
            miMute.Click += (s, e) =>
            {
                isMuted = !isMuted;
                miMute.Header = isMuted ? "Unmute Voice / Sound" : "Mute Voice / Sound";
                if (isMuted && synth != null) synth.SpeakAsyncCancelAll();
            };
            MenuItem miExit = new MenuItem { Header = "Exit Wizard (ESC)" };
            miExit.Click += (s, e) => CancelAndClose();

            cm.Items.Add(miTitle);
            cm.Items.Add(new Separator());
            cm.Items.Add(miMute);
            cm.Items.Add(miExit);
            merlinWin.ContextMenu = cm;

            merlinWin.KeyDown += (s, e) =>
            {
                if (e.Key == Key.Escape) CancelAndClose();
            };

            merlinWin.LocationChanged += (s, e) => UpdateBalloonPosition();
        }

        private void CreateBalloonWindow()
        {
            balloonWin = new Window();
            balloonWin.Title = "Merlin Speech";
            balloonWin.WindowStyle = WindowStyle.None;
            balloonWin.AllowsTransparency = true;
            balloonWin.Background = Brushes.Transparent;
            balloonWin.Topmost = true;
            balloonWin.ShowInTaskbar = false;
            balloonWin.SizeToContent = SizeToContent.WidthAndHeight;

            Canvas rootCanvas = new Canvas();

            // Speech Balloon Border
            balloonBorder = new Border();
            balloonBorder.Background = new SolidColorBrush(Color.FromRgb(255, 253, 226)); // Classic MS Agent pale yellow
            balloonBorder.BorderBrush = new SolidColorBrush(Color.FromRgb(74, 74, 74));
            balloonBorder.BorderThickness = new Thickness(1.8);
            balloonBorder.CornerRadius = new CornerRadius(12);
            balloonBorder.Padding = new Thickness(14, 10, 14, 10);
            balloonBorder.Margin = new Thickness(12);

            DropShadowEffect shadow = new DropShadowEffect();
            shadow.BlurRadius = 10;
            shadow.ShadowDepth = 2;
            shadow.Opacity = 0.28;
            shadow.Color = Color.FromRgb(30, 30, 30);
            balloonBorder.Effect = shadow;

            balloonText = new TextBlock();
            balloonText.FontSize = 13.5;
            balloonText.FontFamily = new FontFamily("Comic Sans MS, Segoe UI, Tahoma");
            balloonText.Foreground = new SolidColorBrush(Color.FromRgb(25, 25, 25));
            balloonText.TextWrapping = TextWrapping.Wrap;
            balloonText.MaxWidth = 290;
            balloonText.LineHeight = 19;

            balloonBorder.Child = balloonText;

            // Tail pointing to Merlin
            balloonTail = new Polygon();
            balloonTail.Fill = new SolidColorBrush(Color.FromRgb(255, 253, 226));
            balloonTail.Stroke = new SolidColorBrush(Color.FromRgb(74, 74, 74));
            balloonTail.StrokeThickness = 1.8;

            Grid container = new Grid();
            container.Children.Add(balloonBorder);

            balloonWin.Content = container;

            balloonWin.KeyDown += (s, e) =>
            {
                if (e.Key == Key.Escape) CancelAndClose();
            };
        }

        private void UpdateBalloonPosition()
        {
            if (balloonWin != null && balloonWin.IsVisible && merlinWin != null)
            {
                Rect workArea = SystemParameters.WorkArea;
                double balloonWidth = balloonWin.ActualWidth > 0 ? balloonWin.ActualWidth : 260;
                double balloonHeight = balloonWin.ActualHeight > 0 ? balloonWin.ActualHeight : 80;

                // Default: place to the right of Merlin
                double targetLeft = merlinWin.Left + 132;
                double targetTop = merlinWin.Top - 15;

                // If overflowing right side, flip to the left
                if (targetLeft + balloonWidth > workArea.Right - 10)
                {
                    targetLeft = merlinWin.Left - balloonWidth - 8;
                }

                // Keep vertically within work area
                if (targetTop < workArea.Top + 10)
                {
                    targetTop = workArea.Top + 10;
                }
                else if (targetTop + balloonHeight > workArea.Bottom - 10)
                {
                    targetTop = workArea.Bottom - balloonHeight - 10;
                }

                // If still off left edge, place below Merlin
                if (targetLeft < workArea.Left + 10)
                {
                    targetLeft = Math.Max(workArea.Left + 10, merlinWin.Left);
                    targetTop = merlinWin.Top + 135;
                }

                balloonWin.Left = targetLeft;
                balloonWin.Top = targetTop;
            }
        }

        protected override void OnStartup(StartupEventArgs e)
        {
            base.OnStartup(e);

            Thread worker = new Thread(RunSelectedScript);
            worker.IsBackground = true;
            worker.Start();
        }

        private void CancelAndClose()
        {
            isCanceled = true;
            Dispatcher.Invoke(new Action(() =>
            {
                try { if (soundPlayer != null) soundPlayer.Stop(); } catch { }
                try { if (synth != null) synth.SpeakAsyncCancelAll(); } catch { }
                try { if (balloonWin != null) balloonWin.Close(); } catch { }
                try { if (merlinWin != null) merlinWin.Close(); } catch { }
                Shutdown();
            }));
        }

        private void RunSelectedScript()
        {
            try
            {
                Thread.Sleep(300);
                SetFrame(0, 0);

                if (scriptMode == "demo")
                {
                    RunDemoScript();
                }
                else
                {
                    RunAfterScript();
                }
            }
            catch (Exception ex)
            {
                Debug.WriteLine("Script error: " + ex.Message);
            }
            finally
            {
                Dispatcher.Invoke(new Action(() => Shutdown()));
            }
        }

        // ==========================================
        // 1. DESKTOP WIZARD AFTER (Main Program)
        // ==========================================
        private void RunAfterScript()
        {
            Rect workArea = SystemParameters.WorkArea;
            double posX_Right = workArea.Left + workArea.Width * 0.65;
            double posY_Right = workArea.Top + workArea.Height * 0.35;
            double posX_Center = workArea.Left + workArea.Width * 0.35;
            double posY_Center = workArea.Top + workArea.Height * 0.20;
            double posX_Left = workArea.Left + workArea.Width * 0.15;
            double posY_Left = workArea.Top + workArea.Height * 0.15;
            double posX_End = workArea.Left + workArea.Width * 0.22;
            double posY_End = workArea.Top + workArea.Height * 0.58;

            // Scene 1: Hacker Intro
            MoveTo(posX_Right, posY_Right);
            Show();
            Play("GetAttention");
            Play("GetAttentionReturn");
            Speak("Hi I'm Merlin the Magician (TROJAN) here to take control of your computer!. . . . . .:-p");
            Sleep(2000);
            Hide();
            Sleep(250);
            if (isCanceled) return;

            // Scene 2: Virus Download
            MoveTo(posX_Right, posY_Right);
            Show();
            Play("GetAttention");
            Play("GetAttentionReturn");
            Play("Process");
            Speak("Virus Downloaded!");
            Sleep(1000);
            Hide();
            Sleep(250);
            if (isCanceled) return;

            // Scene 3: Open CD Drive
            SmoothMoveTo(posX_Center, posY_Center, 700);
            Show();
            Play("GetAttention");
            Play("GetAttentionReturn");
            Speak("watch as I open your cd drive!");
            Play("DoMagic1");
            Play("DoMagic2");
            Sleep(800);
            Hide();

            EjectCDTray();
            Sleep(1000);
            if (isCanceled) return;

            // Scene 4: Disco Keyboard Lights
            SmoothMoveTo(posX_Left, posY_Left, 600);
            Show();
            Play("GetAttention");
            Play("GetAttentionReturn");
            Speak("Now I'll make your keyboard lights do disco dance.Don't forget to watch them!. . . . . :D");
            Play("DoMagic1");
            Play("DoMagic2");
            Sleep(800);
            Hide();

            DiscoKeyboardLights();
            Sleep(600);
            if (isCanceled) return;

            // Scene 5: Keyboard Beep
            SmoothMoveTo(posX_Right, posY_Right, 700);
            Show();
            Play("Write");
            Play("WriteContinued");
            Play("GetAttention");
            Play("GetAttentionReturn");
            Speak("Now I'll make your keyboard do beep.");
            Play("DoMagic1");
            Play("DoMagic2");
            Sleep(800);
            Hide();

            PlayKeyboardBeeps(15);
            Sleep(1000);
            if (isCanceled) return;

            // Scene 6: Master's Message & Bye
            MoveTo(posX_Right, posY_Right);
            Show();
            Play("Read");
            Play("Pleased");
            Speak("Master's got some message for you!");
            SmoothMoveTo(posX_End, posY_End, 900);
            Speak("Bye!");
            Play("Wave");
            Sleep(800);
            Hide();
            if (isCanceled) return;

            // Scene 7: Notepad Typing
            LaunchNotepadAndType();
            Sleep(1000);
        }

        // ==========================================
        // 2. MERLIN.VBS (Animation Showcase)
        // ==========================================
        private void RunDemoScript()
        {
            Rect workArea = SystemParameters.WorkArea;
            double posX = workArea.Left + workArea.Width * 0.55;
            double posY = workArea.Top + workArea.Height * 0.35;

            MoveTo(posX, posY);
            Show();

            string[] animList = new string[] {
                "Announce", "Congratulate_2", "Process", "Read", "Decline",
                "Idle3_1", "Suggest", "StartListening", "Think", "Uncertain",
                "Blink", "Confused", "DoMagic2", "Explain", "WriteContinued",
                "Sad", "Alert", "DoMagic1", "Wave"
            };

            foreach (string anim in animList)
            {
                if (isCanceled) return;
                Play(anim);
                Sleep(200);
            }

            Play("GetAttention");
            Play("GetAttentionReturn");
            Speak("Hi my name is merlin");
            SmoothMoveTo(workArea.Left + workArea.Width * 0.3, workArea.Top + workArea.Height * 0.2, 600);
            Speak("Whats your Name?");
            Sleep(1000);

            Play("GetAttention");
            Play("GetAttentionReturn");
            Speak("That's a nice name!");
            Sleep(1000);

            SmoothMoveTo(workArea.Left + workArea.Width * 0.15, workArea.Top + workArea.Height * 0.1, 500);
            Sleep(400);
            SmoothMoveTo(workArea.Left + workArea.Width * 0.25, workArea.Top + workArea.Height * 0.6, 700);

            Play("GetAttention");
            Play("GetAttentionReturn");
            Speak("Your nice person");

            Play("GetAttention");
            Play("GetAttentionReturn");
            Speak("Bye!");
            Play("Wave");
            Hide();
        }

        // ==========================================
        // ACTIONS & PRANK EMULATION
        // ==========================================
        private void EjectCDTray()
        {
            try
            {
                mciSendString("set cdaudio door open", null, 0, IntPtr.Zero);
            }
            catch { }
        }

        private void DiscoKeyboardLights()
        {
            try
            {
                bool initCaps = (GetKeyState(VK_CAPITAL) & 1) != 0;
                bool initNum = (GetKeyState(VK_NUMLOCK) & 1) != 0;
                bool initScroll = (GetKeyState(VK_SCROLL) & 1) != 0;

                Random rnd = new Random();
                for (int i = 0; i < 40 && !isCanceled; i++)
                {
                    int r = rnd.Next(1, 4);
                    byte key = VK_NUMLOCK;
                    if (r == 1) key = VK_CAPITAL;
                    else if (r == 2) key = VK_SCROLL;

                    keybd_event(key, 0x45, 0, UIntPtr.Zero);
                    keybd_event(key, 0x45, KEYEVENTF_KEYUP, UIntPtr.Zero);
                    Thread.Sleep(90);
                }

                // Cleanly restore initial key states
                bool curCaps = (GetKeyState(VK_CAPITAL) & 1) != 0;
                if (curCaps != initCaps)
                {
                    keybd_event(VK_CAPITAL, 0x45, 0, UIntPtr.Zero);
                    keybd_event(VK_CAPITAL, 0x45, KEYEVENTF_KEYUP, UIntPtr.Zero);
                }
                bool curNum = (GetKeyState(VK_NUMLOCK) & 1) != 0;
                if (curNum != initNum)
                {
                    keybd_event(VK_NUMLOCK, 0x45, 0, UIntPtr.Zero);
                    keybd_event(VK_NUMLOCK, 0x45, KEYEVENTF_KEYUP, UIntPtr.Zero);
                }
                bool curScroll = (GetKeyState(VK_SCROLL) & 1) != 0;
                if (curScroll != initScroll)
                {
                    keybd_event(VK_SCROLL, 0x45, 0, UIntPtr.Zero);
                    keybd_event(VK_SCROLL, 0x45, KEYEVENTF_KEYUP, UIntPtr.Zero);
                }
            }
            catch { }
        }

        private void PlayKeyboardBeeps(int count)
        {
            for (int i = 0; i < count && !isCanceled; i++)
            {
                try
                {
                    Console.Beep(900, 150);
                }
                catch
                {
                    System.Media.SystemSounds.Beep.Play();
                }
                Thread.Sleep(200);
            }
        }

        private void LaunchNotepadAndType()
        {
            try
            {
                Process np = Process.Start("notepad.exe");
                if (np != null)
                {
                    np.WaitForInputIdle(3000);
                    Thread.Sleep(500);

                    SetForegroundWindow(np.MainWindowHandle);
                    Thread.Sleep(300);

                    string message = "Hi! I am Merlin the Magician! Here to take control of your computer! Don't forget to visit https://oomer.dev/\r\n\r\n";
                    foreach (char c in message)
                    {
                        if (isCanceled || np.HasExited) break;
                        System.Windows.Forms.SendKeys.SendWait(c.ToString());
                        Thread.Sleep(55);
                    }

                    // Controlled Yo! loop (12 times)
                    for (int y = 0; y < 12 && !isCanceled && !np.HasExited; y++)
                    {
                        System.Windows.Forms.SendKeys.SendWait("Y");
                        Thread.Sleep(140);
                        System.Windows.Forms.SendKeys.SendWait("o");
                        Thread.Sleep(140);
                        System.Windows.Forms.SendKeys.SendWait("! ");
                        Thread.Sleep(180);
                    }
                }
            }
            catch (Exception ex)
            {
                Debug.WriteLine("Notepad launch error: " + ex.Message);
            }
        }

        // ==========================================
        // CHARACTER ANIMATION & INTERACTION
        // ==========================================
        private void Show()
        {
            Dispatcher.Invoke(new Action(() =>
            {
                merlinWin.Show();
            }));
            Play("Show");
        }

        private void Hide()
        {
            Play("Hide");
            Dispatcher.Invoke(new Action(() =>
            {
                merlinWin.Hide();
                if (balloonWin.IsVisible) balloonWin.Hide();
            }));
        }

        private void MoveTo(double x, double y)
        {
            Dispatcher.Invoke(new Action(() =>
            {
                merlinWin.Left = x;
                merlinWin.Top = y;
                UpdateBalloonPosition();
            }));
        }

        private void SmoothMoveTo(double targetX, double targetY, int durationMs)
        {
            double startX = 0, startY = 0;
            Dispatcher.Invoke(new Action(() =>
            {
                startX = merlinWin.Left;
                startY = merlinWin.Top;
            }));

            int steps = 28;
            int stepDelay = durationMs / steps;
            for (int i = 1; i <= steps && !isCanceled; i++)
            {
                // Smooth sinusoidal easing
                double t = i / (double)steps;
                double ease = 0.5 * (1.0 - Math.Cos(Math.PI * t));

                double curX = startX + (targetX - startX) * ease;
                double curY = startY + (targetY - startY) * ease;
                Dispatcher.Invoke(new Action(() =>
                {
                    merlinWin.Left = curX;
                    merlinWin.Top = curY;
                    UpdateBalloonPosition();
                }));
                Thread.Sleep(stepDelay);
            }
        }

        private void Speak(string text)
        {
            if (isCanceled) return;

            Dispatcher.Invoke(new Action(() =>
            {
                balloonText.Text = text;
                UpdateBalloonPosition();
                balloonWin.Show();
            }));

            if (!isMuted && synth != null)
            {
                try
                {
                    synth.Speak(text);
                }
                catch
                {
                    Thread.Sleep(Math.Max(1500, text.Length * 55));
                }
            }
            else
            {
                Thread.Sleep(Math.Max(1500, text.Length * 55));
            }
        }

        private void Play(string animName)
        {
            if (isCanceled || !animations.ContainsKey(animName)) return;

            Dictionary<string, object> anim = (Dictionary<string, object>)animations[animName];
            object[] frames = (object[])anim["frames"];

            for (int i = 0; i < frames.Length && !isCanceled; i++)
            {
                Dictionary<string, object> frame = (Dictionary<string, object>)frames[i];
                int duration = Convert.ToInt32(frame["duration"]);
                if (duration <= 0 && i == frames.Length - 1) break;

                if (!isMuted && frame.ContainsKey("sound") && frame["sound"] != null)
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
                        int x = Convert.ToInt32(xy[0]);
                        int y = Convert.ToInt32(xy[1]);
                        SetFrame(x, y);
                    }
                    else if (imgArr.Length >= 2)
                    {
                        object[] xy1 = (object[])imgArr[0];
                        int x1 = Convert.ToInt32(xy1[0]);
                        int y1 = Convert.ToInt32(xy1[1]);

                        object[] xy2 = (object[])imgArr[1];
                        int x2 = Convert.ToInt32(xy2[0]);
                        int y2 = Convert.ToInt32(xy2[1]);

                        SetFrameWithOverlay(x1, y1, x2, y2);
                    }
                }

                if (duration > 0)
                {
                    Thread.Sleep(duration);
                }
            }
        }

        private void SetFrame(int x, int y)
        {
            Dispatcher.Invoke(new Action(() =>
            {
                Int32Rect rect = new Int32Rect(x, y, 128, 128);
                CroppedBitmap crop = new CroppedBitmap(spriteSheet, rect);
                merlinBaseImg.Source = crop;
                merlinOverlayImg.Source = null;
            }));
        }

        private void SetFrameWithOverlay(int x1, int y1, int x2, int y2)
        {
            Dispatcher.Invoke(new Action(() =>
            {
                Int32Rect rect1 = new Int32Rect(x1, y1, 128, 128);
                CroppedBitmap crop1 = new CroppedBitmap(spriteSheet, rect1);
                merlinBaseImg.Source = crop1;

                Int32Rect rect2 = new Int32Rect(x2, y2, 128, 128);
                CroppedBitmap crop2 = new CroppedBitmap(spriteSheet, rect2);
                merlinOverlayImg.Source = crop2;
            }));
        }

        private void PlaySound(string soundId)
        {
            string sndPath = System.IO.Path.Combine(appDir, "sounds", soundId + ".mp3");
            if (File.Exists(sndPath))
            {
                Dispatcher.Invoke(new Action(() =>
                {
                    try
                    {
                        soundPlayer.Open(new Uri(sndPath, UriKind.Absolute));
                        soundPlayer.Play();
                    }
                    catch { }
                }));
            }
        }

        private void Sleep(int ms)
        {
            int elapsed = 0;
            while (elapsed < ms && !isCanceled)
            {
                Thread.Sleep(50);
                elapsed += 50;
            }
        }
    }
}
