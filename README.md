# 🧙‍♂️ Desktop Wizard & Multi-Agent Framework (Microsoft Agent)

[![Platform: Windows](https://img.shields.io/badge/Platform-Windows%2010%20%2F%2011-blue.svg)](https://microsoft.com/windows)
[![Architecture: Zero--Install](https://img.shields.io/badge/Setup-Zero--Install-brightgreen.svg)]()
[![Engine: .NET / WPF](https://img.shields.io/badge/Engine-.NET%20Framework%204.8%20%2F%20WPF-purple.svg)]()
[![Agents: Merlin · Genie · Peedy · Clippy](https://img.shields.io/badge/Agents-Merlin%20·%20Genie%20·%20Peedy%20·%20Clippy-success.svg)]()
[![Website: oomer.dev](https://img.shields.io/badge/Website-oomer.dev-blueviolet.svg)](https://oomer.dev/)

A nostalgic resurrection and developer framework for the classic **Microsoft Agent** assistants (**Merlin the Wizard**, **Genie**, **Peedy the Parrot**, and **Clippy**), re-engineered to run natively on modern Windows (Windows 10 and Windows 11) with **zero installations** required on the entire computer.

---

## 🌟 Highlights & Capabilities

- **100% Zero-Install & Portable:** Runs completely standalone without administrative privileges, third-party software, or system installers.
- **Multi-Agent Roster:** Includes the full character roster:
  - 🧙 **Merlin the Wizard** (Magic spells, ancient spellbook, gestures)
  - 🧞 **Genie** (Magical lamp appearance, wishes, greetings)
  - 🦜 **Peedy the Parrot** (Flight, squawks, suggestions, snacks)
  - 📎 **Clippy** (The iconic office paperclip, paper airplanes, notepad tricks)
- **Hardware-Accelerated 32-Bit Transparency:** Uses Desktop Window Manager (DWM) composition in WPF for true per-pixel alpha transparency—no magenta halos, jagged edges, or background borders.
- **Authentic Speech Balloons:** Renders classic pale yellow (`#FFFDE2`) speech callouts with comic typography, subtle drop shadows, and automatic collision detection that prevents obscuring characters or clipping screen edges.
- **Windows Speech Synthesis (SAPI):** Voices dialogue aloud in real time using the built-in Windows Speech API (`System.Speech.Synthesis`).
- **Original Audio Effects:** Complete library of authentic sound cues (wand swooshes, spell chimes, bird squawks, typewriter clicks).
- **Interactive Playground:**
  - **Drag & Drop:** Left-click and drag any character anywhere on your monitor.
  - **Double-Click:** Triggers playful animations on the spot.
  - **Right-Click Context Menu:** Trigger specific animations, mute voice/sound, or make characters speak custom text.
  - **Custom Speech Dialog:** Type any message in the right-click menu to hear that agent speak it aloud with their speech bubble.
  - **Instant Exit:** Press <kbd>ESC</kbd> at any time to close all agents cleanly.

---

## 🎬 Showcase Walkthrough

When launched, the agents deliver a brief, high-energy introduction demonstrating the system's capabilities:

1. **Merlin** glides onto the desktop with a wave of his wand:  
   *"Welcome! Microsoft Agent is back on modern Windows with zero installation!"*
2. **Genie** emerges from magical smoke:  
   *"Your wish is granted! We are fully interactive desktop companions."*
3. **Peedy** flaps his wings across the screen:  
   *"Squawk! We can speak, animate, and fly across your desktop!"*
4. **Clippy** pops in with his signature chime:  
   *"It looks like you're building a project! Drag us anywhere or right-click us!"*

After the intro, all agents remain on the screen in **Interactive Playground Mode** so you can interact with them or test custom behaviors.

---

## 🛠️ Developer CLI & Workflow Integration

Other developers can use `DesktopWizard.exe` as a lightweight CLI notification engine in batch scripts, PowerShell pipelines, build tasks, and terminal workflows.

### Command-Line Arguments:
```text
DesktopWizard.exe [--agent <Name>] [--play <Animation>] [--say <Message>]
```

### Examples:

#### 1. CI/CD & Build Notifications:
Notify yourself when a long compile, test suite, or container build finishes:
```cmd
DesktopWizard.exe --agent Clippy --play Congratulate --say "Build succeeded! All unit tests passed."
```

#### 2. Deployment Alerts:
```cmd
DesktopWizard.exe --agent Merlin --play DoMagic1 --say "Production deployment completed successfully!"
```

#### 3. Task / Download Complete:
```cmd
DesktopWizard.exe --agent Peedy --play Suggest --say "Your files have finished downloading!"
```

#### 4. Server Backup Notification:
```cmd
DesktopWizard.exe --agent Genie --play Acknowledge --say "Master, your scheduled database backup is done."
```

---

## 🚀 How to Run

| Method | File | Description |
| :--- | :--- | :--- |
| **Executable (Recommended)** | `DesktopWizard.exe` | Launches the multi-agent interactive showcase. |
| **One-Click Batch** | `Desktop Wizard After.bat` | Double-click to launch `DesktopWizard.exe`. |
| **PowerShell Player** | `Desktop_Wizard_Player.ps1` | Pure PowerShell 5.1 / WPF multi-agent implementation. |
| **VBScript** | `Desktop Wizard After.vbs` | Double-click to run. Automatically detects modern Windows and routes to the engine. |

> **Controls:**
> - **Move:** Left-click and drag any agent.
> - **Interact:** Double-click for a reaction.
> - **Options:** Right-click an agent for animation menus and custom speech.
> - **Exit:** Press <kbd>ESC</kbd> anytime.

---

## 📂 Repository Structure

```text
├── DesktopWizard.exe             # Portable standalone native player (WPF + SAPI)
├── DesktopWizard.cs              # Source code for DesktopWizard.exe (C# 5 / .NET 4.8)
├── Desktop Wizard After.bat      # One-click launcher
├── Desktop Wizard After.vbs      # Modernized VBScript with auto-detection fallback
├── Desktop_Wizard_Player.ps1     # Native PowerShell 5.1 multi-agent player
├── MERLIN.vbs                    # Animation demo script with modern fallback
├── README.md                     # Documentation and developer guide
│
├── agents/                       # 🎭 Character Assets
│   ├── Merlin/                   # Sprite atlas, animation JSON, 32 audio cues
│   ├── Genie/                    # Sprite atlas, animation JSON, 14 audio cues
│   ├── Peedy/                    # Sprite atlas, animation JSON, 30 audio cues
│   └── Clippy/                   # Sprite atlas, animation JSON, 15 audio cues
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

## 📜 Credits & License

- **Developer:** Omer Muneer ([oomer.dev](https://oomer.dev/))
- **Character Artwork & Audio:** &copy; Microsoft Corporation (Microsoft Agent 2.0).
- **Asset Maps:** Extracted via open-source preservation projects.
