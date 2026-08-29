# 🧙‍♂️ Desktop Wizard (Microsoft Agent Merlin)

[![Platform: Windows](https://img.shields.io/badge/Platform-Windows%2010%20%2F%2011-blue.svg)](https://microsoft.com/windows)
[![Architecture: Zero--Install](https://img.shields.io/badge/Setup-Zero--Install-brightgreen.svg)]()
[![Engine: .NET / WPF](https://img.shields.io/badge/Engine-.NET%20Framework%204.8%20%2F%20WPF-purple.svg)]()
[![Legacy: MS Agent 2.0](https://img.shields.io/badge/Legacy-MS%20Agent%202.0%20(2012)-orange.svg)]()
[![Website: oomer.dev](https://img.shields.io/badge/Website-oomer.dev-blueviolet.svg)](https://oomer.dev/)

A nostalgic resurrection of the classic **Microsoft Agent Merlin** desktop wizard prank program from 2012, updated to run natively on modern versions of Windows (Windows 10 and Windows 11) with **zero installations** required on the entire computer.

---

## 📖 Background & History

In the Windows 98, 2000, and XP era, **Microsoft Agent** (`Agent.Control.2`) allowed interactive animated characters like **Merlin the Wizard**, **Genie**, **Peedy the Parrot**, and **Robby the Robot** to fly over the user's desktop, speak with speech balloons and Text-to-Speech (TTS), and perform animations.

In **October 2012**, this program (*"Desktop Wizard After"*) was created as an entertaining desktop wizard prank by **Omer Muneer** ([oomer.dev](https://oomer.dev/)).

### Why the Original Stopped Working
When Microsoft released Windows 8, 10, and 11, the underlying Microsoft Agent subsystem (`AgentServer.exe` and `Agent.Control.2`) was completely removed from Windows. Because legacy VBScripts relied on `On Error Resume Next`, scripts failed silently—Merlin never appeared on the desktop, animations never played, and speech balloons never showed up.

---

## ✨ Modern Resurrection (Zero-Installation)

This updated release brings Merlin back to life on modern Windows using only built-in Windows components:

- **100% Zero-Install:** Runs completely standalone without installing any third-party software, drivers, or system modifications.
- **Hardware-Accelerated WPF Transparency:** Uses Desktop Window Manager (DWM) composition for true 32-bit per-pixel alpha transparency—no jagged borders, magenta halos, or pixel artifacts.
- **Responsive Screen Placement:** Automatically calculates optimal viewing coordinates based on your active screen resolution and work area.
- **Smooth Gliding Flight:** Merlin floats across your monitor with sinusoidal easing curves instead of jarring teleportation.
- **Full Animation Atlas:** Renders Merlin's original sprites and animations (`Show`, `GetAttention`, `Process`, `DoMagic1`, `DoMagic2`, `Write`, `Read`, `Pleased`, `Wave`, `Hide`) with authentic multi-layer frame overlays (blinking eyes, spell sparkles, cauldron bubbles).
- **Authentic Speech Balloon:** Displays the classic pale yellow (`#FFFDE2`) speech bubble with soft drop shadow and collision detection to ensure it never covers Merlin or clips off-screen.
- **Windows Speech Synthesis (SAPI):** Speaks dialogue aloud in real time using the built-in Windows Speech API (`System.Speech.Synthesis`).
- **Sound Effects:** Plays the original 32 audio cues (wand swooshes, chimes, spell casting) via the `sounds/` library.
- **Interactive Controls:**
  - Left-click and drag Merlin anywhere on your monitor.
  - Double-click Merlin for a playful surprise animation.
  - Right-click for options (mute voice/audio, exit).
  - Press <kbd>ESC</kbd> anytime to instantly exit.
- **Safe Hardware Prank Execution:**
  - Optical drive tray eject (handles systems without optical drives gracefully).
  - Keyboard lights disco dance with automatic state saving & restoration (`CapsLock`, `NumLock`, `ScrollLock`).
  - Internal keyboard beeps.
  - Live Notepad typewriter typing effect with safe loop limits.

---

## 🎬 "Desktop Wizard After" Storyline

1. **Scene 1 (Intro):** Merlin flies in smoothly, calls for attention, announces himself as *Merlin the Magician (TROJAN)* here to take control of your computer, and vanishes in a puff of smoke.
2. **Scene 2 (Virus Download):** Reappears, stirs his magical cauldron with bubble sounds (`Process`), and proclaims *"Virus Downloaded!"*.
3. **Scene 3 (CD Drive Eject):** Glides toward center screen, casts magic with his glowing wand (`DoMagic1` & `DoMagic2`), and ejects the computer's CD/DVD drive tray.
4. **Scene 4 (Keyboard Disco Lights):** Floats to the upper screen, announces a keyboard light dance, and rapidly flashes `CapsLock`, `ScrollLock`, and `NumLock` keys like disco strobe lights (cleanly restoring initial key states afterward).
5. **Scene 5 (Keyboard Beeps):** Returns, writes glowing runes in the air, and triggers a sequence of keyboard speaker beeps.
6. **Scene 6 (Farewell):** Reads his ancient spellbook, smiles (`Pleased`), glides down, says *"Bye!"*, waves goodbye, and disappears.
7. **Scene 7 (Message in Notepad):** Automatically launches Notepad and types out the message character-by-character:
   ```text
   Hi! I am Merlin the Magician! Here to take control of your computer! Don't forget to visit https://oomer.dev/
   ```
8. **Scene 8 (Yo! Loop):** Executes the playful `"Yo! "` loop with safety controls so your keyboard never gets stuck.

---

## 🚀 How to Run

You can launch the program in any of the following ways:

| Launch Method | File | Description |
| :--- | :--- | :--- |
| **VBScript** | `Desktop Wizard After.vbs` | Double-click to run. Automatically detects modern Windows and routes to the zero-install engine. |
| **Batch Launcher** | `Desktop Wizard After.bat` | One-click batch launcher. |
| **Standalone Executable** | `DesktopWizard.exe` | High-performance standalone WPF player (compiled using Windows' built-in .NET compiler). |
| **PowerShell Script** | `Desktop_Wizard_Player.ps1` | Pure PowerShell 5.1 / WPF script implementation. |

> **Tip:** Press <kbd>ESC</kbd> or right-click Merlin at any time to instantly exit the program.

---

## 📂 Repository Structure

```text
├── Desktop Wizard After.vbs      # Modernized main script with auto-detection fallback
├── Desktop Wizard After.bat      # One-click launcher
├── DesktopWizard.exe             # Portable standalone native player (WPF + SAPI)
├── DesktopWizard.cs              # Source code for DesktopWizard.exe (C# 5 / .NET 4.8)
├── Desktop_Wizard_Player.ps1     # Native PowerShell 5.1 player alternative
├── MERLIN.vbs                    # Animation demo script with modern fallback
├── map.png                       # Merlin 2688x2688 32-bit transparent sprite atlas
├── agent.json                    # Animation frames, overlays, and timing definitions
├── sounds/                       # 32 original Merlin sound effects (MP3)
│   ├── 1.mp3 ... 32.mp3
│
└── original/                     # 📁 UNTOUCHED ARCHIVE (Original October 2012 files)
    ├── About Ms Agents.txt       # Original notes and character paths
    ├── Desktop Wizard After.vbs  # Exact original 2012 VBScript
    ├── Desktop Wizard before.vbs # Exact original 2012 prototype VBScript
    ├── MERLIN.vbs                # Exact original 2012 demo VBScript
    ├── Ms agents command.txt     # Original command reference sheet
    ├── Merlin.acs                # Original Microsoft Agent Merlin character file
    ├── Genie.acs                 # Original Microsoft Agent Genie character file
    ├── Peedy.acs                 # Original Microsoft Agent Peedy character file
    ├── Robby.acs                 # Original Microsoft Agent Robby character file
    └── Merlin.exe                # Original Microsoft cabinet self-extractor
```

---

## 💡 Creative Prank Ideas & Enhancements

Here are creative additions that could be introduced to elevate the prank even further:

1. **Mouse Cursor Evasion / Telekinesis:**
   When the user attempts to move the mouse cursor over Merlin to click him or close the window, Merlin casts `DoMagic1` and the mouse cursor playfully scurries away or teleports a few inches away from him.
2. **Fake Matrix / Retro Hacker Console:**
   Instead of just Notepad, Merlin summons a transparent black terminal window with green flowing matrix glyphs or fake decoding hex dumps before typing the message.
3. **Multi-Agent Cameos:**
   Since `original/` includes `Genie.acs`, `Peedy.acs`, and `Robby.acs`:
   - Peedy the Parrot could fly in, squawk a warning, and get shooed away by Merlin.
   - Genie could emerge from smoke to say a one-liner.
4. **Desktop Wallpaper Flip / Glitch:**
   Merlin waves his wand and momentarily flips the desktop wallpaper upside down, rotates screen orientation via Windows Display API (`ChangeDisplaySettingsEx`), or generates a harmless faux glass shatter overlay that clears after 3 seconds.
5. **Interactive Voice / AI Q&A:**
   Allow the user to type in a question into a little input box, and Merlin answers using an AI or humorous preset answers like an interactive desktop genie.
6. **Fake Windows BSOD Prank:**
   Merlin casts a spell that triggers a full-screen retro Windows 98/XP Blue Screen of Death (BSOD) for 3 seconds before laughing, saying *"Just kidding!"*, and revealing the real desktop.

---

## 📜 Credits & License

- **Author:** Omer Muneer ([oomer.dev](https://oomer.dev/))
- **Character Artwork & Sound:** &copy; Microsoft Corporation (Microsoft Agent 2.0).
