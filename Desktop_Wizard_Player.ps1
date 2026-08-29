# ============================================================================
# Merlin Desktop Wizard - PowerShell Player (Modern Windows Compatibility)
# Runs natively on Windows 10 & 11 without installing anything on the PC.
# Recreates the entire sequence of "Desktop Wizard After.vbs" with full
# animations, transparent desktop window, voice synthesis, sound effects & pranks.
# ============================================================================

Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase, System.Xaml, System.Drawing, System.Speech, System.Windows.Forms, System.Web.Extensions

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
if (-not $scriptDir) { $scriptDir = $PWD.Path }

$mapPath = Join-Path $scriptDir "map.png"
$jsonPath = Join-Path $scriptDir "agent.json"
$soundsDir = Join-Path $scriptDir "sounds"

if (-not (Test-Path $mapPath) -or -not (Test-Path $jsonPath)) {
    [System.Windows.MessageBox]::Show("Required assets (map.png, agent.json) not found in $scriptDir", "Error", "OK", "Error")
    exit 1
}

# Win32 APIs for CD eject & keyboard lights
$csharpCode = @"
using System;
using System.Text;
using System.Runtime.InteropServices;

public class NativeHelper {
    [DllImport("winmm.dll", EntryPoint = "mciSendStringA", CharSet = CharSet.Ansi)]
    public static extern int mciSendString(string command, StringBuilder buffer, int bufferSize, IntPtr hwndCallback);

    [DllImport("user32.dll")]
    public static extern void keybd_event(byte bVk, byte bScan, uint dwFlags, UIntPtr dwExtraInfo);

    [DllImport("user32.dll")]
    public static extern short GetKeyState(int keyCode);

    [DllImport("user32.dll")]
    public static extern bool SetForegroundWindow(IntPtr hWnd);
}
"@
Add-Type -TypeDefinition $csharpCode -ErrorAction SilentlyContinue

# Load assets
$spriteSheet = [System.Windows.Media.Imaging.BitmapImage]::new([System.Uri]::new($mapPath, [System.UriKind]::Absolute))
$js = [System.Web.Script.Serialization.JavaScriptSerializer]::new()
$js.MaxJsonLength = [int]::MaxValue
$rootJson = $js.DeserializeObject([System.IO.File]::ReadAllText($jsonPath))
$animations = $rootJson["animations"]

# Audio & Speech
$soundPlayer = [System.Windows.Media.MediaPlayer]::new()
$synth = $null
try {
    $synth = [System.Speech.Synthesis.SpeechSynthesizer]::new()
} catch {}

# Responsive screen coordinates
$workArea = [System.Windows.SystemParameters]::WorkArea
$posX_Right = $workArea.Left + $workArea.Width * 0.65
$posY_Right = $workArea.Top + $workArea.Height * 0.35
$posX_Center = $workArea.Left + $workArea.Width * 0.35
$posY_Center = $workArea.Top + $workArea.Height * 0.20
$posX_Left = $workArea.Left + $workArea.Width * 0.15
$posY_Left = $workArea.Top + $workArea.Height * 0.15
$posX_End = $workArea.Left + $workArea.Width * 0.22
$posY_End = $workArea.Top + $workArea.Height * 0.58

# Merlin Window
$merlinWin = [System.Windows.Window]::new()
$merlinWin.Title = "Merlin Desktop Wizard"
$merlinWin.Width = 128
$merlinWin.Height = 128
$merlinWin.WindowStyle = [System.Windows.WindowStyle]::None
$merlinWin.AllowsTransparency = $true
$merlinWin.Background = [System.Windows.Media.Brushes]::Transparent
$merlinWin.Topmost = $true
$merlinWin.ShowInTaskbar = $false
$merlinWin.Cursor = [System.Windows.Input.Cursors]::Hand
$merlinWin.Left = $posX_Right
$merlinWin.Top = $posY_Right

$grid = [System.Windows.Controls.Grid]::new()
$grid.Width = 128
$grid.Height = 128

$baseImg = [System.Windows.Controls.Image]::new()
$baseImg.Width = 128
$baseImg.Height = 128
$grid.Children.Add($baseImg) | Out-Null

$overlayImg = [System.Windows.Controls.Image]::new()
$overlayImg.Width = 128
$overlayImg.Height = 128
$grid.Children.Add($overlayImg) | Out-Null

$merlinWin.Content = $grid

# Speech Balloon Window
$balloonWin = [System.Windows.Window]::new()
$balloonWin.Title = "Speech Balloon"
$balloonWin.WindowStyle = [System.Windows.WindowStyle]::None
$balloonWin.AllowsTransparency = $true
$balloonWin.Background = [System.Windows.Media.Brushes]::Transparent
$balloonWin.Topmost = $true
$balloonWin.ShowInTaskbar = $false
$balloonWin.SizeToContent = [System.Windows.SizeToContent]::WidthAndHeight

$border = [System.Windows.Controls.Border]::new()
$border.Background = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.Color]::FromRgb(255, 253, 226))
$border.BorderBrush = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.Color]::FromRgb(74, 74, 74))
$border.BorderThickness = [System.Windows.Thickness]::new(1.8)
$border.CornerRadius = [System.Windows.CornerRadius]::new(12)
$border.Padding = [System.Windows.Thickness]::new(14, 10, 14, 10)
$border.Margin = [System.Windows.Thickness]::new(12)

$shadow = [System.Windows.Media.Effects.DropShadowEffect]::new()
$shadow.BlurRadius = 10
$shadow.ShadowDepth = 2
$shadow.Opacity = 0.28
$border.Effect = $shadow

$balloonText = [System.Windows.Controls.TextBlock]::new()
$balloonText.FontSize = 13.5
$balloonText.FontFamily = [System.Windows.Media.FontFamily]::new("Comic Sans MS, Segoe UI, Tahoma")
$balloonText.Foreground = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.Color]::FromRgb(25, 25, 25))
$balloonText.TextWrapping = [System.Windows.TextWrapping]::Wrap
$balloonText.MaxWidth = 290
$balloonText.LineHeight = 19
$border.Child = $balloonText
$balloonWin.Content = $border

function Update-BalloonPosition {
    if ($balloonWin.IsVisible) {
        $balloonWidth = if ($balloonWin.ActualWidth -gt 0) { $balloonWin.ActualWidth } else { 260 }
        $balloonHeight = if ($balloonWin.ActualHeight -gt 0) { $balloonWin.ActualHeight } else { 80 }

        $targetLeft = $merlinWin.Left + 132
        $targetTop = $merlinWin.Top - 15

        if ($targetLeft + $balloonWidth -gt $workArea.Right - 10) {
            $targetLeft = $merlinWin.Left - $balloonWidth - 8
        }
        if ($targetTop -lt $workArea.Top + 10) {
            $targetTop = $workArea.Top + 10
        } elseif ($targetTop + $balloonHeight -gt $workArea.Bottom - 10) {
            $targetTop = $workArea.Bottom - $balloonHeight - 10
        }
        if ($targetLeft -lt $workArea.Left + 10) {
            $targetLeft = [Math]::Max($workArea.Left + 10, $merlinWin.Left)
            $targetTop = $merlinWin.Top + 135
        }

        $balloonWin.Left = $targetLeft
        $balloonWin.Top = $targetTop
    }
}

function Set-MerlinFrame([int]$x, [int]$y) {
    $rect = [System.Windows.Int32Rect]::new($x, $y, 128, 128)
    $crop = [System.Windows.Media.Imaging.CroppedBitmap]::new($spriteSheet, $rect)
    $baseImg.Source = $crop
    $overlayImg.Source = $null
    DoEvents
}

function Set-MerlinOverlayFrame([int]$x1, [int]$y1, [int]$x2, [int]$y2) {
    $rect1 = [System.Windows.Int32Rect]::new($x1, $y1, 128, 128)
    $baseImg.Source = [System.Windows.Media.Imaging.CroppedBitmap]::new($spriteSheet, $rect1)
    $rect2 = [System.Windows.Int32Rect]::new($x2, $y2, 128, 128)
    $overlayImg.Source = [System.Windows.Media.Imaging.CroppedBitmap]::new($spriteSheet, $rect2)
    DoEvents
}

function DoEvents {
    [System.Windows.Forms.Application]::DoEvents()
}

function Play-SoundEffect([string]$sndId) {
    $sndFile = Join-Path $soundsDir "$sndId.mp3"
    if (Test-Path $sndFile) {
        try {
            $soundPlayer.Open([System.Uri]::new($sndFile, [System.UriKind]::Absolute))
            $soundPlayer.Play()
        } catch {}
    }
}

function Play-Animation([string]$animName) {
    if (-not $animations.ContainsKey($animName)) { return }
    $anim = $animations[$animName]
    $frames = $anim["frames"]
    for ($i = 0; $i -lt $frames.Length; $i++) {
        $frame = $frames[$i]
        $duration = [int]$frame["duration"]
        if ($duration -le 0 -and $i -eq ($frames.Length - 1)) { break }

        if ($frame.ContainsKey("sound") -and $frame["sound"]) {
            Play-SoundEffect ([string]$frame["sound"])
        }

        if ($frame.ContainsKey("images") -and $frame["images"]) {
            $imgArr = $frame["images"]
            if ($imgArr.Length -eq 1) {
                $xy = $imgArr[0]
                Set-MerlinFrame ([int]$xy[0]) ([int]$xy[1])
            } elseif ($imgArr.Length -ge 2) {
                $xy1 = $imgArr[0]
                $xy2 = $imgArr[1]
                Set-MerlinOverlayFrame ([int]$xy1[0]) ([int]$xy1[1]) ([int]$xy2[0]) ([int]$xy2[1])
            }
        }

        if ($duration -gt 0) {
            Start-Sleep -Milliseconds $duration
            DoEvents
        }
    }
}

function Move-Merlin([double]$x, [double]$y) {
    $merlinWin.Left = $x
    $merlinWin.Top = $y
    Update-BalloonPosition
    DoEvents
}

function Smooth-Move-Merlin([double]$targetX, [double]$targetY, [int]$durationMs) {
    $startX = $merlinWin.Left; $startY = $merlinWin.Top
    $steps = 25
    $stepDelay = [int]($durationMs / $steps)
    for ($i = 1; $i -le $steps; $i++) {
        $t = $i / [double]$steps
        $ease = 0.5 * (1.0 - [Math]::Cos([Math]::PI * $t))
        $curX = $startX + ($targetX - $startX) * $ease
        $curY = $startY + ($targetY - $startY) * $ease
        Move-Merlin $curX $curY
        Start-Sleep -Milliseconds $stepDelay
    }
}

function Show-Merlin {
    $merlinWin.Show()
    Play-Animation "Show"
}

function Hide-Merlin {
    Play-Animation "Hide"
    $merlinWin.Hide()
    $balloonWin.Hide()
    DoEvents
}

function Speak-Merlin([string]$text) {
    $balloonText.Text = $text
    Update-BalloonPosition
    $balloonWin.Show()
    DoEvents

    if ($synth) {
        try {
            $synth.Speak($text)
        } catch {
            Start-Sleep -Milliseconds ([Math]::Max(1500, $text.Length * 55))
        }
    } else {
        Start-Sleep -Milliseconds ([Math]::Max(1500, $text.Length * 55))
    }
    DoEvents
}

# ============================================================================
# EXECUTION OF DESKTOP WIZARD AFTER
# ============================================================================

Set-MerlinFrame 0 0

# Scene 1: Hacker Intro
Move-Merlin $posX_Right $posY_Right
Show-Merlin
Play-Animation "GetAttention"
Play-Animation "GetAttentionReturn"
Speak-Merlin "Hi I'm Merlin the Magician (TROJAN) here to take control of your computer!. . . . . .:-p"
Start-Sleep -Milliseconds 2000
Hide-Merlin
Start-Sleep -Milliseconds 250

# Scene 2: Virus Download
Move-Merlin $posX_Right $posY_Right
Show-Merlin
Play-Animation "GetAttention"
Play-Animation "GetAttentionReturn"
Play-Animation "Process"
Speak-Merlin "Virus Downloaded!"
Start-Sleep -Milliseconds 1000
Hide-Merlin
Start-Sleep -Milliseconds 250

# Scene 3: Open CD Drive
Smooth-Move-Merlin $posX_Center $posY_Center 700
Show-Merlin
Play-Animation "GetAttention"
Play-Animation "GetAttentionReturn"
Speak-Merlin "watch as I open your cd drive!"
Play-Animation "DoMagic1"
Play-Animation "DoMagic2"
Start-Sleep -Milliseconds 800
Hide-Merlin

try { [NativeHelper]::mciSendString("set cdaudio door open", $null, 0, [IntPtr]::Zero) } catch {}
Start-Sleep -Milliseconds 1000

# Scene 4: Disco Keyboard Lights
Smooth-Move-Merlin $posX_Left $posY_Left 600
Show-Merlin
Play-Animation "GetAttention"
Play-Animation "GetAttentionReturn"
Speak-Merlin "Now I'll make your keyboard lights do disco dance.Don't forget to watch them!. . . . . :D"
Play-Animation "DoMagic1"
Play-Animation "DoMagic2"
Start-Sleep -Milliseconds 800
Hide-Merlin

$rnd = [System.Random]::new()
for ($i = 0; $i -lt 35; $i++) {
    $r = $rnd.Next(1, 4)
    $k = 0x90
    if ($r -eq 1) { $k = 0x14 } elseif ($r -eq 2) { $k = 0x91 }
    [NativeHelper]::keybd_event($k, 0x45, 0, [UIntPtr]::Zero)
    [NativeHelper]::keybd_event($k, 0x45, 2, [UIntPtr]::Zero)
    Start-Sleep -Milliseconds 90
}

# Scene 5: Keyboard Beep
Smooth-Move-Merlin $posX_Right $posY_Right 700
Show-Merlin
Play-Animation "Write"
Play-Animation "WriteContinued"
Play-Animation "GetAttention"
Play-Animation "GetAttentionReturn"
Speak-Merlin "Now I'll make your keyboard do beep."
Play-Animation "DoMagic1"
Play-Animation "DoMagic2"
Start-Sleep -Milliseconds 800
Hide-Merlin

for ($b = 0; $b -lt 15; $b++) {
    try { [System.Console]::Beep(900, 150) } catch { [System.Media.SystemSounds]::Beep.Play() }
    Start-Sleep -Milliseconds 200
}
Start-Sleep -Milliseconds 800

# Scene 6: Master's Message & Bye
Move-Merlin $posX_Right $posY_Right
Show-Merlin
Play-Animation "Read"
Play-Animation "Pleased"
Speak-Merlin "Master's got some message for you!"

# Smooth movement to lower left
Smooth-Move-Merlin $posX_End $posY_End 900

Speak-Merlin "Bye!"
Play-Animation "Wave"
Start-Sleep -Milliseconds 800
Hide-Merlin

# Scene 7: Notepad Typing
$np = [System.Diagnostics.Process]::Start("notepad.exe")
if ($np) {
    $np.WaitForInputIdle(3000)
    Start-Sleep -Milliseconds 500
    [NativeHelper]::SetForegroundWindow($np.MainWindowHandle) | Out-Null
    Start-Sleep -Milliseconds 300

    $msg = "Hi! I am Merlin the Magician! Here to take control of your computer! Don't forget to visit https://oomer.dev/`r`n`r`n"
    foreach ($char in $msg.ToCharArray()) {
        [System.Windows.Forms.SendKeys]::SendWait($char.ToString())
        Start-Sleep -Milliseconds 55
    }

    # Controlled Yo! loop (12 times)
    for ($y = 0; $y -lt 12; $y++) {
        [System.Windows.Forms.SendKeys]::SendWait("Y")
        Start-Sleep -Milliseconds 140
        [System.Windows.Forms.SendKeys]::SendWait("o")
        Start-Sleep -Milliseconds 140
        [System.Windows.Forms.SendKeys]::SendWait("! ")
        Start-Sleep -Milliseconds 180
    }
}

$merlinWin.Close()
$balloonWin.Close()
