#SingleInstance, Force
#Persistent
#InstallKeybdHook
Menu, Tray, NoStandard
Menu, Tray, Add, Options
Menu, Tray, Add, Current Hotkey, CurrentHotkey
Menu, Tray, Add, About
Menu, Tray, Default, Options
Menu, Tray, Click, 2
Menu, Tray, Add, Exit
if(A_IsCompiled)
	Menu, tray, Icon, %A_ScriptName%, 1
SetWorkingDir, % A_ScriptDir
Initialize()
Return

Initialize()
{
	global 																						; Since we only have one real function, and the rest are labels
	Check_ForUpdate("XSplit PTT Crutch", 0.007, "http://www.barrowdev.com/update/XSplit_PTT_Crutch/Version.ini")
	IniRead, hotkeyDisplay, Settings.ini, Hotkeys, hotkeyDisplay 								; So we don't have to re-parse the human-readable version
	if(hotkeyDisplay == "ERROR" || hotkeyDisplay == "None")
	{
		IniWrite, None, Settings.ini, Hotkeys, hotkeyDisplay
		hotkeyDisplay := "none"
	}
	
	IniRead, hotkeyFinal, Settings.ini, Hotkeys, hotkeyFinal 									; Actual hotkey
	if(hotkeyFinal == "ERROR" || hotkeyFinal == "None")
		IniWrite, None, Settings.ini, Hotkeys, hotkeyFinal
	else
	{
		Hotkey, ~*%hotkeyFinal%, PttDown, On 													; Enable push/release hotkeys
		Hotkey, ~%hotkeyFinal% Up, PttUp, On
	}
		
	ptt := false 																				; Start by assuming the microphone is muted
	hotkeyOld := hotkeyFinal 																	; For use with Cancel/errors
	
	spam := "gmail.com"
	anti := "Barrow.Dev"
	
	Return
}

Options:
	hotkeyFinal := HotkeyGUI(,,,,"XSplit PTT Crutch")
	if(!hotkeyFinal || ErrorLevel) 																		; If user chose manual entry, but didn't enter anything
	{
		hotkeyFinal := hotkeyOld
		Return
	}
		
	hotkeyDisplay := hotkeyFinal 																; Human readable hotkey
	StringReplace, hotkeyDisplay, hotkeyDisplay, +, % "Shift + "
	StringReplace, hotkeyDisplay, hotkeyDisplay, ^, % "Ctrl + "
	StringReplace, hotkeyDisplay, hotkeyDisplay, !, % "Alt + "
	StringReplace, hotkeyDisplay, hotkeyDisplay, #, % "Win + "
	
	IniWrite, %hotkeyDisplay%, Settings.ini, Hotkeys, hotkeyDisplay
	IniWrite, %hotkeyFinal%, Settings.ini, Hotkeys, hotkeyFinal
	
	if(hotkeyOld != "None" && hotkeyOld != "ERROR" && hotkeyOld)
	{
		Hotkey, ~*%hotkeyOld%, PttDown, Off 														; Disable the old hotkey
		Hotkey, ~%hotkeyOld% Up, PttUp, Off
	}
	
	Hotkey, ~*%hotkeyFinal%, PttDown, On 														; Enable the new hotkey
	Hotkey, ~%hotkeyFinal% Up, PttUp, On
	
	hotkeyOld := hotkeyFinal
	Return
	
CurrentHotkey:
	MsgBox, 0x0, Current Hotkey, Your current hotkey is "%hotkeyDisplay%". 						; Quick-and-dirty status window.
	Return

About:
	MsgBox, 0x0, About, Made by %anti%@%spam% in Autohotkey.`nFeel free to e-mail with questions, comments, and concerns.
	Return

Exit:
	ExitApp
	
PttDown:
	if(!xsplitID || !WinExist("ahk_id " xsplitID))
	{
		if(WinExist("Streaming Live"))
			WinGet, xsplitID, ID, Streaming Live
		else if(WinExist("XSplit Broadcaster"))
			WinGet, xsplitID, ID, XSplit Broadcaster
		else
			Return
	}
	; else
		; OutputDebug, xsplitID = %xsplitID%
	ControlGet, isChecked, Checked,, Button18, ahk_id %xsplitID%
	if(!isChecked)
		Control, Check,, Button18, ahk_id %xsplitID%
	Return
	
PttUp:
	if(!xsplitID || !WinExist("ahk_id " xsplitID))
		Return
	Control, Uncheck,, Button18, ahk_id %xsplitID%
	Return