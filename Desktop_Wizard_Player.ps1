# ============================================================================
# Microsoft Agent - Multi-Agent Interactive Desktop Player (PowerShell / WPF)
# Zero-Installation Engine for Windows 10 & Windows 11.
# Features: Merlin, Genie, Peedy, and Clippy with full animations, TTS,
# sound effects, speech balloons, and interactive controls.
# ============================================================================

Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase, System.Xaml, System.Drawing, System.Speech, System.Windows.Forms, System.Web.Extensions

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
if (-not $scriptDir) { $scriptDir = $PWD.Path }

$agentsDir = Join-Path $scriptDir "agents"
if (-not (Test-Path $agentsDir)) {
    [System.Windows.MessageBox]::Show("agents directory not found in $scriptDir", "Error", "OK", "Error")
    exit 1
}

$workArea = [System.Windows.SystemParameters]::WorkArea
$js = [System.Web.Script.Serialization.JavaScriptSerializer]::new()
$js.MaxJsonLength = [int]::MaxValue

$synth = $null
try {
    $synth = [System.Speech.Synthesis.SpeechSynthesizer]::new()
    $synth.Rate = 0
} catch {}

class AgentUI {
    [string]$Name
    [int]$Width
    [int]$Height
    [System.Windows.Media.Imaging.BitmapImage]$SpriteSheet
    [hashtable]$Animations
    [System.Windows.Window]$Window
    [System.Windows.Controls.Image]$BaseImg
    [System.Windows.Controls.Image]$OverlayImg
    [System.Windows.Window]$BalloonWindow
    [System.Windows.Controls.TextBlock]$BalloonText
    [System.Windows.Media.MediaPlayer]$SoundPlayer
    [string]$Dir
}

$loadedAgents = @{}

# Load available agents
foreach ($agentName in @("Merlin", "Genie", "Peedy", "Clippy")) {
    $dir = Join-Path $agentsDir $agentName
    $mapPath = Join-Path $dir "map.png"
    $jsonPath = Join-Path $dir "agent.json"

    if ((Test-Path $mapPath) -and (Test-Path $jsonPath)) {
        $rootJson = $js.DeserializeObject([System.IO.File]::ReadAllText($jsonPath))
        $anims = $rootJson["animations"]
        $fSize = $rootJson["framesize"]
        $fw = [int]$fSize[0]
        $fh = [int]$fSize[1]

        $ui = [AgentUI]::new()
        $ui.Name = $agentName
        $ui.Width = $fw
        $ui.Height = $fh
        $ui.Dir = $dir
        $ui.SpriteSheet = [System.Windows.Media.Imaging.BitmapImage]::new([System.Uri]::new($mapPath, [System.UriKind]::Absolute))
        $ui.Animations = $anims
        $ui.SoundPlayer = [System.Windows.Media.MediaPlayer]::new()

        # Agent Window
        $win = [System.Windows.Window]::new()
        $win.Title = $agentName
        $win.Width = $fw
        $win.Height = $fh
        $win.WindowStyle = [System.Windows.WindowStyle]::None
        $win.AllowsTransparency = $true
        $win.Background = [System.Windows.Media.Brushes]::Transparent
        $win.Topmost = $true
        $win.ShowInTaskbar = $false
        $win.Cursor = [System.Windows.Input.Cursors]::Hand

        $grid = [System.Windows.Controls.Grid]::new()
        $grid.Width = $fw
        $grid.Height = $fh

        $baseImg = [System.Windows.Controls.Image]::new()
        $baseImg.Width = $fw; $baseImg.Height = $fh
        $grid.Children.Add($baseImg) | Out-Null

        $overImg = [System.Windows.Controls.Image]::new()
        $overImg.Width = $fw; $overImg.Height = $fh
        $grid.Children.Add($overImg) | Out-Null
        $win.Content = $grid

        $ui.Window = $win
        $ui.BaseImg = $baseImg
        $ui.OverlayImg = $overImg

        # Balloon Window
        $bWin = [System.Windows.Window]::new()
        $bWin.Title = "$agentName Speech"
        $bWin.WindowStyle = [System.Windows.WindowStyle]::None
        $bWin.AllowsTransparency = $true
        $bWin.Background = [System.Windows.Media.Brushes]::Transparent
        $bWin.Topmost = $true
        $bWin.ShowInTaskbar = $false
        $bWin.SizeToContent = [System.Windows.SizeToContent]::WidthAndHeight

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

        $bText = [System.Windows.Controls.TextBlock]::new()
        $bText.FontSize = 13.5
        $bText.FontFamily = [System.Windows.Media.FontFamily]::new("Comic Sans MS, Segoe UI, Tahoma")
        $bText.Foreground = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.Color]::FromRgb(25, 25, 25))
        $bText.TextWrapping = [System.Windows.TextWrapping]::Wrap
        $bText.MaxWidth = 290
        $bText.LineHeight = 19
        $border.Child = $bText
        $bWin.Content = $border

        $ui.BalloonWindow = $bWin
        $ui.BalloonText = $bText

        # Draggable
        $win.Add_MouseLeftButtonDown({
            param($s, $e)
            if ($e.ButtonState -eq [System.Windows.Input.MouseButtonState]::Pressed) {
                try { $s.DragMove() } catch {}
            }
        })

        $loadedAgents[$agentName] = $ui
    }
}

function DoEvents {
    [System.Windows.Forms.Application]::DoEvents()
}

function Update-AgentBalloon([AgentUI]$agent) {
    if ($agent.BalloonWindow.IsVisible) {
        $bWidth = if ($agent.BalloonWindow.ActualWidth -gt 0) { $agent.BalloonWindow.ActualWidth } else { 260 }
        $bHeight = if ($agent.BalloonWindow.ActualHeight -gt 0) { $agent.BalloonWindow.ActualHeight } else { 80 }

        $targetLeft = $agent.Window.Left + $agent.Width + 6
        $targetTop = $agent.Window.Top - 15

        if ($targetLeft + $bWidth -gt $workArea.Right - 10) {
            $targetLeft = $agent.Window.Left - $bWidth - 8
        }
        if ($targetTop -lt $workArea.Top + 10) {
            $targetTop = $workArea.Top + 10
        } elseif ($targetTop + $bHeight -gt $workArea.Bottom - 10) {
            $targetTop = $workArea.Bottom - $bHeight - 10
        }

        $agent.BalloonWindow.Left = $targetLeft
        $agent.BalloonWindow.Top = $targetTop
    }
}

function Set-AgentFrame([AgentUI]$agent, [int]$x, [int]$y) {
    $rect = [System.Windows.Int32Rect]::new($x, $y, $agent.Width, $agent.Height)
    $crop = [System.Windows.Media.Imaging.CroppedBitmap]::new($agent.SpriteSheet, $rect)
    $agent.BaseImg.Source = $crop
    $agent.OverlayImg.Source = $null
    DoEvents
}

function Set-AgentOverlay([AgentUI]$agent, [int]$x1, [int]$y1, [int]$x2, [int]$y2) {
    $rect1 = [System.Windows.Int32Rect]::new($x1, $y1, $agent.Width, $agent.Height)
    $agent.BaseImg.Source = [System.Windows.Media.Imaging.CroppedBitmap]::new($agent.SpriteSheet, $rect1)
    $rect2 = [System.Windows.Int32Rect]::new($x2, $y2, $agent.Width, $agent.Height)
    $agent.OverlayImg.Source = [System.Windows.Media.Imaging.CroppedBitmap]::new($agent.SpriteSheet, $rect2)
    DoEvents
}

function Play-AgentSound([AgentUI]$agent, [string]$sndId) {
    $sndPath = Join-Path $agent.Dir "sounds\$sndId.mp3"
    if (Test-Path $sndPath) {
        try {
            $agent.SoundPlayer.Open([System.Uri]::new($sndPath, [System.UriKind]::Absolute))
            $agent.SoundPlayer.Play()
        } catch {}
    }
}

function Play-AgentAnim([AgentUI]$agent, [string]$animName) {
    if (-not $agent.Animations.ContainsKey($animName)) { return }
    $anim = $agent.Animations[$animName]
    $frames = $anim["frames"]
    for ($i = 0; $i -lt $frames.Length; $i++) {
        $frame = $frames[$i]
        $duration = [int]$frame["duration"]
        if ($duration -le 0 -and $i -eq ($frames.Length - 1)) { break }

        if ($frame.ContainsKey("sound") -and $frame["sound"]) {
            Play-AgentSound $agent ([string]$frame["sound"])
        }

        if ($frame.ContainsKey("images") -and $frame["images"]) {
            $imgArr = $frame["images"]
            if ($imgArr.Length -eq 1) {
                $xy = $imgArr[0]
                Set-AgentFrame $agent ([int]$xy[0]) ([int]$xy[1])
            } elseif ($imgArr.Length -ge 2) {
                $xy1 = $imgArr[0]; $xy2 = $imgArr[1]
                Set-AgentOverlay $agent ([int]$xy1[0]) ([int]$xy1[1]) ([int]$xy2[0]) ([int]$xy2[1])
            }
        }

        if ($duration -gt 0) {
            Start-Sleep -Milliseconds $duration
            DoEvents
        }
    }
}

function Show-Agent([AgentUI]$agent) {
    $agent.Window.Show()
    Play-AgentAnim $agent "Show"
}

function Hide-Agent([AgentUI]$agent) {
    Play-AgentAnim $agent "Hide"
    $agent.Window.Hide()
    $agent.BalloonWindow.Hide()
    DoEvents
}

function Speak-Agent([AgentUI]$agent, [string]$text) {
    $agent.BalloonText.Text = $text
    Update-AgentBalloon $agent
    $agent.BalloonWindow.Show()
    DoEvents

    if ($synth) {
        try {
            $synth.Speak($text)
        } catch {
            Start-Sleep -Milliseconds ([Math]::Max(1200, $text.Length * 50))
        }
    } else {
        Start-Sleep -Milliseconds ([Math]::Max(1200, $text.Length * 50))
    }
    DoEvents
}

function Move-Agent([AgentUI]$agent, [double]$x, [double]$y) {
    $agent.Window.Left = $x
    $agent.Window.Top = $y
    Update-AgentBalloon $agent
    DoEvents
}

# ============================================================================
# MULTI-AGENT DEMONSTRATION & SHOWCASE
# ============================================================================

# Initial frame setup
foreach ($k in $loadedAgents.Keys) {
    Set-AgentFrame $loadedAgents[$k] 0 0
}

# 1. Merlin
if ($loadedAgents.ContainsKey("Merlin")) {
    $m = $loadedAgents["Merlin"]
    Move-Agent $m ($workArea.Left + $workArea.Width * 0.20) ($workArea.Top + $workArea.Height * 0.35)
    Show-Agent $m
    Play-AgentAnim $m "GetAttention"
    Speak-Agent $m "Welcome! Microsoft Agent is back on modern Windows with zero installation!"
    Start-Sleep -Milliseconds 600
}

# 2. Genie
if ($loadedAgents.ContainsKey("Genie")) {
    $g = $loadedAgents["Genie"]
    Move-Agent $g ($workArea.Left + $workArea.Width * 0.42) ($workArea.Top + $workArea.Height * 0.30)
    Show-Agent $g
    Play-AgentAnim $g "Acknowledge"
    Speak-Agent $g "Your wish is granted! We are fully interactive desktop companions."
    Start-Sleep -Milliseconds 600
}

# 3. Peedy
if ($loadedAgents.ContainsKey("Peedy")) {
    $p = $loadedAgents["Peedy"]
    Move-Agent $p ($workArea.Left + $workArea.Width * 0.64) ($workArea.Top + $workArea.Height * 0.35)
    Show-Agent $p
    Play-AgentAnim $p "Suggest"
    Speak-Agent $p "Squawk! We can speak, animate, and fly across your desktop!"
    Start-Sleep -Milliseconds 600
}

# 4. Clippy
if ($loadedAgents.ContainsKey("Clippy")) {
    $c = $loadedAgents["Clippy"]
    Move-Agent $c ($workArea.Left + $workArea.Width * 0.82) ($workArea.Top + $workArea.Height * 0.45)
    Show-Agent $c
    Play-AgentAnim $c "GetAttention"
    Speak-Agent $c "It looks like you're building a project! Drag us anywhere or right-click us!"
    Start-Sleep -Milliseconds 800
}

# Keep active on screen for user interaction
Write-Host "Agents are active on desktop. Press Ctrl+C in terminal or close windows to exit."
while ($true) {
    DoEvents
    Start-Sleep -Milliseconds 50
}
