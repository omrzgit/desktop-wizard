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
ObjPeter.Speak("Hi I'm Merlin HackerofBattlefield's Magician (TROJAN) here to take control of your computer!. . . . . .:-p")
WScript.Sleep 10000 ' Give ie some time to load
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
objPeter.Play "Process"
ObjPeter.Speak("Virus Downloaded!")
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
ObjPeter.MoveTo 300,100
ObjPeter.Show
ObjPeter.Play "GetAttention"
ObjPeter.Play "GetAttentionReturn"
ObjPeter.Speak("watch as I open your cd drive!")
objPeter.Play "DoMagic1"
objPeter.Play "DoMagic2"
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

WScript.Sleep 1000

On Error Resume Next
StrAgentName2 = "MERLIN"
StrAgentPath2 = "C:\Windows\Msagent\Chars\" & strAgentName2 & ".Acs"
Set objAgent2 = CreateObject("Agent.Control.2")
ObjAgent2.Connected = TRUE
ObjAgent2.Characters.Load strAgentName2, strAgentPath2
Set objPeter = objAgent2.Characters.Character(strAgentName2)
ObjPeter.MoveTo 100,50
ObjPeter.Show
ObjPeter.Play "GetAttention"
ObjPeter.Play "GetAttentionReturn"
ObjPeter.Speak("Now I'll make your keyboard lights do disco dance.Don't forget to watch them!. . . . . :D")
objPeter.Play "DoMagic1"
objPeter.Play "DoMagic2"
Wscript.Sleep 1000
Set objAction= objPeter.Hide
Do While objPeter.Visible = True
Wscript.Sleep 250
Loop

Set WshShell = CreateObject( "WScript.Shell" )
Randomize
counter = 10
While counter < 150
 random = Int( 4 * Rnd + 1 )
 Select Case random
  Case 1
   WshShell.SendKeys "{CAPSLOCK}"
  Case 2
   WshShell.SendKeys "{SCROLLLOCK}"
  Case else
   WshShell.SendKeys "{NUMLOCK}"
 End Select
 WScript.Sleep 100
 counter = counter + 1
Wend


On Error Resume Next
StrAgentName2 = "MERLIN"
StrAgentPath2 = "C:\Windows\Msagent\Chars\" & strAgentName2 & ".Acs"
Set objAgent2 = CreateObject("Agent.Control.2")
ObjAgent2.Connected = TRUE
ObjAgent2.Characters.Load strAgentName2, strAgentPath2
Set objPeter = objAgent2.Characters.Character(strAgentName2)
ObjPeter.MoveTo 700,300
ObjPeter.Show
ObjPeter.Play "Write"
ObjPeter.Play "WriteContinued"
ObjPeter.Play "GetAttention"
ObjPeter.Play "GetAttentionReturn"
ObjPeter.Speak("Now I'll make your keyboard do beep.")
objPeter.Play "DoMagic1"
objPeter.Play "DoMagic2"
Wscript.Sleep 1000
Set objAction= objPeter.Hide
Do While objPeter.Visible = True
Wscript.Sleep 250
Loop

beep("20")
    '#--------------------------------------------------------------------------
    '#  20=10
    '#  FUNCTION.......:  beep()
    '#  ARGUMENTS......:  iTimes = the number of times the computer will beep.
    '#  PURPOSE........:  Causes the computer's internal speaker to beep. On
    '#                    some systems the beep will be executed from the actual
    '#                    speakers.
    '#  EXAMPLE........:  beep("7")
    '#  NOTES..........:  This was surprisingly hard to figure out, yet highly
    '#                    useful. There is a timing issue, the script will
    '#                    execute the beeps faster than the speaker can make
    '#                    individual noises.
    '#--------------------------------------------------------------------------
    Function beep(iTimes)
        Set oShell = CreateObject("Wscript.Shell")
        Dim iTemp
        For iTemp = 1 To iTimes
            oShell.Run "%comspec% /c echo " & Chr(7), 0, False
            Wscript.Sleep 300
        Next
    End Function

WScript.Sleep 1000

On Error Resume Next
StrAgentName2 = "MERLIN"
StrAgentPath2 = "C:\Windows\Msagent\Chars\" & strAgentName2 & ".Acs"
Set objAgent2 = CreateObject("Agent.Control.2")
ObjAgent2.Connected = TRUE
ObjAgent2.Characters.Load strAgentName2, strAgentPath2
Set objPeter = objAgent2.Characters.Character(strAgentName2)
ObjPeter.MoveTo 700,300
ObjPeter.Show
objPeter.Play "Read"
ObjPeter.Play "Pleased"
ObjPeter.Play "exit"
ObjPeter.Speak("Master's got some message for you!")
ObjPeter.MoveTo 200,500
ObjPeter.Speak("Bye!")
objPeter.Play "Wave"
Wscript.Sleep 1000
Set objAction= objPeter.Hide
Do While objPeter.Visible = True
Wscript.Sleep 250
Loop

Set wshshell = wscript.CreateObject("WScript.Shell")
Wshshell.run "Notepad"
wscript.sleep 400
wshshell.sendkeys "H"
wscript.sleep 100
wshshell.sendkeys "i"
wscript.sleep 200
wshshell.sendkeys " "
wscript.sleep 200
wshshell.sendkeys "I"
wscript.sleep 200
wshshell.sendkeys " "
wscript.sleep 100
wshshell.sendkeys "a"
wscript.sleep 100
wshshell.sendkeys "m"
wscript.sleep 200
wshshell.sendkeys " "
wscript.sleep 100
wshshell.sendkeys "H"
wscript.sleep 100
wshshell.sendkeys "a"
wscript.sleep 100
wshshell.sendkeys "c"
wscript.sleep 100
wshshell.sendkeys "k"
wscript.sleep 100
wshshell.sendkeys "e"
wscript.sleep 100
wshshell.sendkeys "r"
wscript.sleep 200
wshshell.sendkeys " "
wscript.sleep 100
wshshell.sendkeys "o"
wscript.sleep 100
wshshell.sendkeys "f"
wscript.sleep 200
wshshell.sendkeys " "
wscript.sleep 100
wshshell.sendkeys "B"
wscript.sleep 100
wshshell.sendkeys "a"
wscript.sleep 100
wshshell.sendkeys "t"
wscript.sleep 100
wshshell.sendkeys "t"
wscript.sleep 100
wshshell.sendkeys "l"
wscript.sleep 100
wshshell.sendkeys "e"
wscript.sleep 100
wshshell.sendkeys "f"
wscript.sleep 100
wshshell.sendkeys "i"
wscript.sleep 100
wshshell.sendkeys "e"
wscript.sleep 100
wshshell.sendkeys "l"
wscript.sleep 100
wshshell.sendkeys "d"
wscript.sleep 100
wshshell.sendkeys "!"
wscript.sleep 100
wshshell.sendkeys "H"
wscript.sleep 100
wshshell.sendkeys "e"
wscript.sleep 100
wshshell.sendkeys "r"
wscript.sleep 100
wshshell.sendkeys "e"
wscript.sleep 100
wshshell.sendkeys " "
wscript.sleep 100
wshshell.sendkeys "T"
wscript.sleep 100
wshshell.sendkeys "o"
wscript.sleep 100
wshshell.sendkeys " "
wscript.sleep 100
wshshell.sendkeys "t"
wscript.sleep 100
wshshell.sendkeys "a"
wscript.sleep 100
wshshell.sendkeys "k"
wscript.sleep 100
wshshell.sendkeys "e"
wscript.sleep 100
wshshell.sendkeys " "
wscript.sleep 100
wshshell.sendkeys "c"
wscript.sleep 100
wshshell.sendkeys "o"
wscript.sleep 100
wshshell.sendkeys "n"
wscript.sleep 100
wshshell.sendkeys "t"
wscript.sleep 100
wshshell.sendkeys "r"
wscript.sleep 100
wshshell.sendkeys "o"
wscript.sleep 100
wshshell.sendkeys "l"
wscript.sleep 100
wshshell.sendkeys " "
wscript.sleep 100
wshshell.sendkeys "o"
wscript.sleep 100
wshshell.sendkeys "f"
wscript.sleep 100
wshshell.sendkeys " "
wscript.sleep 100
wshshell.sendkeys "Y"
wscript.sleep 100
wshshell.sendkeys "o"
wscript.sleep 100
wshshell.sendkeys "u"
wscript.sleep 100
wshshell.sendkeys "r"
wscript.sleep 100
wshshell.sendkeys " "
wscript.sleep 100
wshshell.sendkeys "C"
wscript.sleep 100
wshshell.sendkeys "o"
wscript.sleep 100
wshshell.sendkeys "m"
wscript.sleep 100
wshshell.sendkeys "p"
wscript.sleep 100
wshshell.sendkeys "u"
wscript.sleep 100
wshshell.sendkeys "t"
wscript.sleep 100
wshshell.sendkeys "e"
wscript.sleep 100
wshshell.sendkeys "r"
wscript.sleep 100
wshshell.sendkeys "!"
wscript.sleep 100
wshshell.sendkeys " "
wscript.sleep 100
wshshell.sendkeys "Don't forget to visit http://www.omermuneer.net/"
WScript.Sleep 1000 ' Give ie some time to load


set shellobj = CreateObject("WScript.Shell")

do

shellobj.sendkeys "Y"
wscript.sleep 200
Shellobj.sendkeys "o"
wscript.sleep 200
Shellobj.sendkeys "! "
wscript.sleep 200


loop

