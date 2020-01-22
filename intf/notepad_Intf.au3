; Caller shall include "lib_Intf.aue" before including this file
; Snip Information
Global $gNotepadExecutable         = "notepad.exe"

; Dialog 1
Global $gNotepadDialog1_class      = "[CLASS:Notepad]"
Global $gNotepadDialog1_title      = "Untitled - Notepad"
Global $gNotepadX                  = -1
Global $gNotepadY                  = -1
Global $gNotepadW                  = -1
Global $gNotepadH                  = -1

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
		WinWaitActive($gSnipDialog2_title)

		; Set the path
		ControlFocus($gSnipDialog2_title, "", $gSnipDialog2_cntrl_Path)
		ControlSend ($gSnipDialog2_title, "", $gSnipDialog2_cntrl_Path,     $aPath)

		; Set the filename
		ControlFocus($gSnipDialog2_title, "", $gSnipDialog2_cntrl_File)
		ControlSend ($gSnipDialog2_title, "", $gSnipDialog2_cntrl_File, $aFilename)

	EndIf
EndFunc