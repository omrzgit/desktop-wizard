' =========================================================================
' Desktop Wizard - Microsoft Agent Interactive Showcase
' Updated for modern Windows compatibility & developer integration.
' Website: https://oomer.dev/
' =========================================================================

On Error Resume Next
StrAgentName2 = "MERLIN"
StrAgentPath2 = "C:\Windows\Msagent\Chars\" & strAgentName2 & ".Acs"
Set objAgent2 = CreateObject("Agent.Control.2")

' Modern Windows Compatibility Check (Windows 8 / 10 / 11)
' Microsoft Agent (Agent.Control.2) was deprecated by Microsoft.
' If Agent.Control.2 is missing, seamlessly launch the zero-install modern engine!
If objAgent2 Is Nothing Then
    Set objFSO = CreateObject("Scripting.FileSystemObject")
    strFolder = objFSO.GetParentFolderName(WScript.ScriptFullName)
    strExe = strFolder & "\DesktopWizard.exe"
    If objFSO.FileExists(strExe) Then
        Set objWsh = CreateObject("WScript.Shell")
        objWsh.Run """" & strExe & """", 1, False
        WScript.Quit
    End If
End If

' Legacy Windows Engine Execution (Windows 98 / 2000 / XP / 7)
ObjAgent2.Connected = TRUE
ObjAgent2.Characters.Load strAgentName2, strAgentPath2
Set objPeter = objAgent2.Characters.Character(strAgentName2)

ObjPeter.MoveTo 700, 300
ObjPeter.Show
ObjPeter.Play "GetAttention"
ObjPeter.Play "GetAttentionReturn"
ObjPeter.Speak("Welcome! I am Merlin the Desktop Wizard.")
WScript.Sleep 1000

ObjPeter.Play "Suggest"
ObjPeter.Speak("I can speak, fly across your screen, and play retro animations!")
WScript.Sleep 1000

ObjPeter.MoveTo 300, 200
ObjPeter.Play "DoMagic1"
ObjPeter.Play "DoMagic2"
ObjPeter.Speak("Use this project as a foundation to build your own desktop assistants!")
WScript.Sleep 1000

ObjPeter.MoveTo 200, 500
ObjPeter.Speak("Visit https://oomer.dev/ for more projects. Goodbye!")
ObjPeter.Play "Wave"
WScript.Sleep 1500

Set objAction = objPeter.Hide
Do While objPeter.Visible = True
    WScript.Sleep 250
Loop
