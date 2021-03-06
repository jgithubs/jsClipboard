; Caller shall include "lib_Intf.aue" before including this file
; Notepad App Information
Global $gNotepadStruct[10][2] = [ _
    ["Exe  ", "notepad.exe"],        _
	["Redir", False],                _
	["Class", "[CLASS:Notepad]"],    _
	["Title", "Untitled - Notepad"], _
	["Pid  ", -1], _
	["hWnd ", -1], _
	["X    ", -1], _
	["Y    ", -1], _
	["W    ", -1], _
	["H    ", -1]  _
   ]

; Dialog 2
Global $gNotepadDialog2_title      = "Save As"
Global $gNotepadDialog2_cntrl_Path = "ToolbarWindow324"
Global $gNotepadDialog2_cntrl_File = "Edit1"

Func notepad_init($aPrefix, $aPath, ByRef $aFilename)
	Local $bReturn = False

	; filename, part 1
	Local $timeStamp   = get_timestamp()
	; filename, part 3
	Local $fileSuffix  = "_func.png"

	ConsoleWrite("aPath     ;" & $aPath      & @CRLF)
	ConsoleWrite("timestamp ;" & $timeStamp  & @CRLF)
	ConsoleWrite("aPrefix   ;" & $aPrefix    & @CRLF)
	ConsoleWrite("fileSuffix;" & $fileSuffix & @CRLF)

	; filename
	$aFilename = $timeStamp & "-" & $aPrefix & $fileSuffix
	ConsoleWrite("aFilename ; " & $aFilename & @CRLF)

	; filepath
	if dir_exists($aPath) == True Then
		$bReturn = True;
		ConsoleWrite("path      ;" & $aPath & ";" & dir_exists($aPath) & @CRLF)
	Else
		ConsoleWrite("Error, aPath does not exists.")
	EndIf

	Return $bReturn
EndFunc

Func copy_buffer_to_notepad($aPath, $aFilename, $aSaveFlag = False)
	; Insert Image from buffer
	;Send($gCmdPaste)
	;Send($gCmdEsc)

	If $aSaveFlag == True Then
		; Invoke a save
		Send($gCmdSave)
		WinWaitActive($gNotepadDialog2_title)

		; Set the path
		ControlFocus($gNotepadDialog2_title, "", $gNotepadDialog2_cntrl_Path)
		ControlSend ($gNotepadDialog2_title, "", $gNotepadDialog2_cntrl_Path,     $aPath)

		; Set the filename
		ControlFocus($gNotepadDialog2_title, "", $gNotepadDialog2_cntrl_File)
		ControlSend ($gNotepadDialog2_title, "", $gNotepadDialog2_cntrl_File, $aFilename)

	EndIf
EndFunc