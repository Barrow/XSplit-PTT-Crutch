#SingleInstance, Force
#Persistent
#InstallKeybdHook
Menu, Tray, NoStandard
Menu, Tray, Add, Set Primary Hotkey, Options
Menu, Tray, Add, Set Secondary Hotkey, Options2
Menu, Tray, Add, Current Hotkey(s), CurrentHotkey
Menu, Tray, Add, About
Menu, Tray, Default, Set Primary Hotkey
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
	Check_ForUpdate("XSplit PTT Crutch", 0.008, "http://www.barrowdev.com/update/XSplit_PTT_Crutch/Version.ini")
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
	
	IniRead, secondaryHotkeyDisplay, Settings.ini, Hotkeys, secondaryHotkeyDisplay 								; So we don't have to re-parse the human-readable version
	if(secondaryHotkeyDisplay == "ERROR" || secondaryHotkeyDisplay == "None")
	{
		IniWrite, None, Settings.ini, Hotkeys, secondaryHotkeyDisplay
		secondaryHotkeyDisplay := "none"
	}
	
	IniRead, secondaryHotkeyFinal, Settings.ini, Hotkeys, secondaryHotkeyFinal 									; Actual hotkey
	if(secondaryHotkeyFinal == "ERROR" || secondaryHotkeyFinal == "None")
		IniWrite, None, Settings.ini, Hotkeys, secondaryHotkeyFinal
	else
	{
		Hotkey, ~*%secondaryHotkeyFinal%, PttDown, On 													; Enable push/release hotkeys
		Hotkey, ~%secondaryHotkeyFinal% Up, PttUp, On
	}
	
	ptt := false 																				; Start by assuming the microphone is muted
	hotkeyOld := hotkeyFinal 																	; For use with Cancel/errors
	secondaryHotkeyOld := secondaryHotkeyFinal 																	; For use with Cancel/errors
	
	spam := "gmail.com"
	anti := "Barrow.Dev"
	
	Return
}

Options:
	hotkeyFinal := HotkeyGUI(, hotkeyOld,,,"XSplit PTT Crutch")
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

Options2:
	secondaryHotkeyFinal := HotkeyGUI(, secondaryHotkeyOld,,,"XSplit PTT Crutch")
	if(!secondaryHotkeyFinal || ErrorLevel) 																		; If user chose manual entry, but didn't enter anything
	{
		secondaryHotkeyFinal := secondaryHotkeyOld
		Return
	}
		
	secondaryHotkeyDisplay := secondaryHotkeyFinal 																; Human readable hotkey
	StringReplace, secondaryHotkeyDisplay, secondaryHotkeyDisplay, +, % "Shift + "
	StringReplace, secondaryHotkeyDisplay, secondaryHotkeyDisplay, ^, % "Ctrl + "
	StringReplace, secondaryHotkeyDisplay, secondaryHotkeyDisplay, !, % "Alt + "
	StringReplace, secondaryHotkeyDisplay, secondaryHotkeyDisplay, #, % "Win + "
	
	IniWrite, %secondaryHotkeyDisplay%, Settings.ini, Hotkeys, secondaryHotkeyDisplay
	IniWrite, %secondaryHotkeyFinal%, Settings.ini, Hotkeys, secondaryHotkeyFinal
	
	if(secondaryHotkeyOld != "None" && secondaryHotkeyOld != "ERROR" && secondaryHotkeyOld)
	{
		Hotkey, ~*%secondaryHotkeyOld%, PttDown, Off 														; Disable the old hotkey
		Hotkey, ~%secondaryHotkeyOld% Up, PttUp, Off
	}
	
	Hotkey, ~*%secondaryHotkeyFinal%, PttDown, On 														; Enable the new hotkey
	Hotkey, ~%secondaryHotkeyFinal% Up, PttUp, On
	
	secondaryHotkeyOld := secondaryHotkeyFinal
	Return
	
CurrentHotkey:
	String := "Your current hotkey is """ . hotkeyDisplay . """."
	if(secondaryHotkeyOld != "None" && secondaryHotkeyOld != "ERROR" && secondaryHotkeyOld)
		String .= "`nYour secondary hotkey is """ . secondaryHotkeyDisplay . """."
	MsgBox, 0x0, Current Hotkey, % String 						; Quick-and-dirty status window.
	Return

About:
	MsgBox, 0x0, About, Made by %anti%@%spam% in Autohotkey_L. Version 0.008`nFeel free to e-mail me with any questions, comments, and concerns.
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