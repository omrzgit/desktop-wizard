On Error Resume Next

Set wshShell = wscript.CreateObject("WScript.Shell")

Dim Wsh

Set Wsh = WScript.CreateObject("WScript.Shell")

set shell = CreateObject("Wscript.Shell")

Set objScriptExec = objShell.Exec("shutdown -a")

set objShell = CreateObject("WScript.Shell")

StrAgentName2 = "MERLIN"

StrAgentPath2 = "C:\Windows\Msagent\Chars\" & strAgentName2 & ".Acs"

Set objAgent2 = CreateObject("Agent.Control.2")

ObjAgent2.Connected = TRUE

ObjAgent2.Characters.Load strAgentName2, strAgentPath2

Set objPeter = objAgent2.Characters.Character(strAgentName2)

ObjPeter.MoveTo 700,300

ObjPeter.Show

objPeter.Play "Announce"

objPeter.Play "Congratulate_2"

objPeter.Play "Process"

objPeter.Play "Read"

objPeter.Play "Decline"

objPeter.Play "Idle3_1"

objPeter.Play "Suggest"

objPeter.Play "StartListening"

objPeter.Play "Think"

objPeter.Play "Uncertain"

objPeter.Play "Blink"

objPeter.Play "Confused"

objPeter.Play "DoMagic2"

objPeter.Play "Explain"

objPeter.Play "WriteContinued"

objPeter.Play "Sad"

objPeter.Play "Alert"

objPeter.Play "DoMagic1"

objPeter.Play "Wave"

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

ObjPeter.Play "GetAttention"

ObjPeter.Play "GetAttentionReturn"

ObjPeter.Speak("Hi my name is merlin")

ObjPeter.MoveTo 300,100

ObjPeter.Show

ObjPeter.Speak("Whats your Name?")

Wscript.Sleep 1000

ObjPeter.MoveTo 300,100

ObjPeter.Show

ObjPeter.Play "GetAttention"

ObjPeter.Play "GetAttentionReturn"

ObjPeter.Speak("That's a nice name!")

Wscript.Sleep 1000

ObjPeter.MoveTo 100,50

Wscript.Sleep 1000

ObjPeter.MoveTo 600,50

ObjPeter.MoveTo 200,500

ObjPeter.Show

ObjPeter.Play "GetAttention"

ObjPeter.Play "GetAttentionReturn"

ObjPeter.Speak("Your nice person")

ObjPeter.Show

ObjPeter.Play "GetAttention"

ObjPeter.Play "GetAttentionReturn"

ObjPeter.Speak("Bye!")

objPeter.Play "Wave"


Set objAction= objPeter.Hide

Do While objPeter.Visible = True

loop