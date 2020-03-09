; Caller shall include "lib_Intf.au3" before including this file.
; Caller shall include "lib_cmds.au3" before including this file.

; Snip App Information
Global $gSnipStruct[10][2] = [     _
    ["Exe  ", "snippingtool.exe"], _
	["Redir", True],               _
	["Class", "[CLASS:Microsoft-Windows-SnipperToolbar]"], _
	["Title", "Snipping Tool"],    _
	["Pid  ", -1], _
	["hWnd ", -1], _
	["X    ", -1], _
	["Y    ", -1], _
	["W    ", -1], _
	["H    ", -1]  _
   ]

; Dialog 2
Global $gSnipDialog2_title      = "Save As"
Global $gSnipDialog2_cntrl_Path = "ToolbarWindow324"
Global $gSnipDialog2_cntrl_File = "Edit1"

Func copy_buffer_to_snip($aPath, $aFilename, $aSaveFlag = False)
	; Insert Image from buffer no required
    ; Snip requires user to select a box, therefore, it is already in the buffer
	Local $funcName = "copy_buffer_to_snip"
	ConsoleWrite("+++++ " & $funcName & @CRLF)
	ConsoleWrite("aPath     ;" & $aPath     & @CRLF)
	ConsoleWrite("aFilename ;" & $aFilename & @CRLF)
	ConsoleWrite("aSaveFlag ;" & $aSaveFlag & @CRLF)

	If $aSaveFlag == True Then
		; Invoke a save
		Send($gCmdSave)
		Local $hWnd1 = WinWaitActive($gSnipDialog2_title)
		ConsoleWrite("hWnd1=" & $hWnd1 & $gSnipDialog2_title & @CRLF)

		; Set the path
		ControlFocus($gSnipDialog2_title, "", $gSnipDialog2_cntrl_Path)
		ControlSend ($gSnipDialog2_title, "", $gSnipDialog2_cntrl_Path,     $aPath)

		; Set the filename
		ControlFocus($gSnipDialog2_title, "", $gSnipDialog2_cntrl_File)
		ControlSend ($gSnipDialog2_title, "", $gSnipDialog2_cntrl_File, $aFilename)

	EndIf
	ConsoleWrite("----- " & $funcName & @CRLF)
EndFunc

Func buffer_to_snip_and_save($aDestDir)
	Local $iReturn  = 0;
	Local $funcName = "buffer_to_snip_and_save"
	ConsoleWrite("+++++" & $funcName & @CRLF)

	; This toolbar has the focus
	Local $fileName = ""
	ConsoleWrite("aDestDir=" & $aDestDir & @CRLF)


	; Is an image present in the clipboard?
	If is_clip_image() == False Then
		ConsoleWrite("Error, No image on clipboard" & @CRLF)
		$iReturn = 1;
		return $iReturn
	EndIf

	; Yes, initialize to get a filename with a unique timestamp
	If get_save_filename("SNIP", $aDestDir, $fileName) == False Then
		ConsoleWrite("Error, Unable to build filename" & @CRLF)
		$iReturn = 1;
		return $iReturn
	EndIf

	; Is mspaint is running?
	Local $status = is_app_running($gSnipStruct[$enAppTitle][$enValue])
	ConsoleWrite("is_app_running=" & $status & @CRLF)
	If $status == False Then
		ConsoleWrite("Error, Snip is not running"  & @CRLF)
		$iReturn = 2;
		return $iReturn
	EndIf

	; Yes, Focus to mspaint
	If set_app_focuse($gSnipStruct[$enAppTitle][$enValue]) == False Then
		ConsoleWrite("Error, Unable to focus on mspaint" & @CRLF)
		$iReturn = 3;
		return $iReturn
	EndIf

	; Main function
	If copy_buffer_to_snip($aDestDir, $fileName, True) == False Then
		$iReturn = 4;
		return $iReturn
	EndIf

	ConsoleWrite("----- " & $funcName & " " & $iReturn & @CRLF)
	return $iReturn
EndFunc