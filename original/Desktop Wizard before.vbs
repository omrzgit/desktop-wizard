On Error Resume Next
StrAgentName2 = "MERLIN"
StrAgentPath2 = "C:\Windows\Msagent\Chars\" & strAgentName2 & ".Acs"
Set objAgent2 = CreateObject("Agent.Control.2")
ObjAgent2.Connected = TRUE
ObjAgent2.Characters.Load strAgentName2, strAgentPath2
Set objPeter = objAgent2.Characters.Character(strAgentName2)
ObjPeter.MoveTo 700,300
ObjPeter.Show
ObjPeter.Play "GetAttention"
ObjPeter.Play "GetAttentionReturn"
ObjPeter.Speak("Hi I'm Merlin here to take control of your computer!")
Wscript.Sleep 1000
Set objAction= objPeter.Hide
Do While objPeter.Visible = True
Wscript.Sleep 250
Loop
Wscript.Sleep 100
On Error Resume Next
StrAgentName2 = "MERLIN"
StrAgentPath2 = "C:\Windows\Msagent\Chars\" & strAgentName2 & ".Acs"
Set objAgent2 = CreateObject("Agent.Control.2")
ObjAgent2.Connected = TRUE
ObjAgent2.Characters.Load strAgentName2, strAgentPath2
Set objPeter = objAgent2.Characters.Character(strAgentName2)
ObjPeter.MoveTo 700,300
ObjPeter.Show
ObjPeter.Play "GetAttention"
ObjPeter.Play "GetAttentionReturn"
ObjPeter.Speak("downloading virus . . . 20% . . . 40% . . . 60% . . . 80% . . . 100% virus downloaded")
Wscript.Sleep 1000
Set objAction= objPeter.Hide
Do While objPeter.Visible = True
Wscript.Sleep 250
Loop
Wscript.Sleep 100
On Error Resume Next
StrAgentName2 = "MERLIN"
StrAgentPath2 = "C:\Windows\Msagent\Chars\" & strAgentName2 & ".Acs"
Set objAgent2 = CreateObject("Agent.Control.2")
ObjAgent2.Connected = TRUE
ObjAgent2.Characters.Load strAgentName2, strAgentPath2
Set objPeter = objAgent2.Characters.Character(strAgentName2)
ObjPeter.MoveTo 700,300
ObjPeter.Show
ObjPeter.Play "GetAttention"
ObjPeter.Play "GetAttentionReturn"
ObjPeter.Speak("watch as I open your cd drive")
Wscript.Sleep 1000
Set objAction= objPeter.Hide
Do While objPeter.Visible = True
Wscript.Sleep 250
Loop
Wscript.Sleep 100
 
Set oWMP = CreateObject("WMPlayer.OCX.7" )
Set colCDROMs = oWMP.CdromCollection
If colCDROMs.Count >= 1 then
For I = 0 to colCDROMs.Count - 1
ColCDROMs.Item(I).Eject
Next ' cdrom
End If

Wscript.Sleep 100
On Error Resume Next
StrAgentName2 = "MERLIN"
StrAgentPath2 = "C:\Windows\Msagent\Chars\" & strAgentName2 & ".Acs"
Set objAgent2 = CreateObject("Agent.Control.2")
ObjAgent2.Connected = TRUE
ObjAgent2.Characters.Load strAgentName2, strAgentPath2
Set objPeter = objAgent2.Characters.Character(strAgentName2)
ObjPeter.MoveTo 700,300
ObjPeter.Show
ObjPeter.Play "GetAttention"
ObjPeter.Play "GetAttentionReturn"
ObjPeter.Speak("lol I now open internet explorer")
Wscript.Sleep 1000
Set objAction= objPeter.Hide
Do While objPeter.Visible = True
Wscript.Sleep 250
Loop
Wscript.Sleep 100
Set WshShell = WScript.CreateObject("WScript.Shell")
WshShell.Run "iexplore http://www.google.com", 9
WScript.Sleep 10000 ' Give ie some time to load