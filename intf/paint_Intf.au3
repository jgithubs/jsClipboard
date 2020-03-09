; Caller shall include "lib_Intf.aue" before including this file

; Paint App Information
Global $gPaintStruct[10][2] = [ _
    ["Exe  ", "mspaint.exe"],        _
	["Redir", False],                _
	["Class", "[CLASS:MSPaintApp]"], _
	["Title", "Untitled - Paint"],   _
	["Pid  ", -1], _
	["hWnd ", -1], _
	["X    ", -1], _
	["Y    ", -1], _
	["W    ", -1], _
	["H    ", -1]  _
   ]

; Dialog 2
Global $gPaintDialog2_title      = "Save As"
Global $gPaintDialog2_cntrl_Path = "ToolbarWindow324"
Global $gPaintDialog2_cntrl_File = "Edit1"

Func copy_buffer_to_paint($aPath, $aFilename, $aSaveFlag = False)
	Local $bReturn  = False
	Local $funcName = "copy_buffer_to_paint"
	ConsoleWrite("+++++ " & $funcName & @CRLF)

	ConsoleWrite("aPath     ;" & $aPath     & @CRLF)
	ConsoleWrite("aFilename ;" & $aFilename & @CRLF)
	ConsoleWrite("aSaveFlag ;" & $aSaveFlag & @CRLF)

	; Insert Image from buffer
	Send($gCmdPaste)
	Send($gCmdEsc)

	If $aSaveFlag == True Then
		; Invoke a save
		Send($gCmdSave)

		ConsoleWrite("Waiting" & $gPaintDialog2_title & @CRLF)
		Local $hWnd1 = WinWaitActive($gPaintDialog2_title)
		ConsoleWrite("hWnd1=" & $hWnd1 & $gPaintDialog2_title & @CRLF)
		If $hWnd1 <> 0 Then
			; Set the path
			ControlFocus($gPaintDialog2_title, "", $gPaintDialog2_cntrl_Path)
			ControlSend ($gPaintDialog2_title, "", $gPaintDialog2_cntrl_Path,     $aPath)

			; Set the filename
			ControlFocus($gPaintDialog2_title, "", $gPaintDialog2_cntrl_File)
			ControlSend ($gPaintDialog2_title, "", $gPaintDialog2_cntrl_File, $aFilename)

			$bReturn = True
		Else
			ConsoleWrite("Timeout" & @CRLF)
		EndIf

	EndIf
	
	ConsoleWrite("+++++ " & $funcName & @CRLF)
	Return $bReturn
EndFunc

Func buffer_to_mspaint_and_save($aDestDir)
	Local $iReturn = 0;
	
	Local $funcName = "buffer_to_mspaint_and_save"
	ConsoleWrite("+++++ " & $funcName & @CRLF)

	; This toolbar has the focus
	Local $fileName = ""


	; Is an image present in the clipboard?
	If is_clip_image() == False Then
		ConsoleWrite("Error, No image on clipboard" & @CRLF)
		$iReturn = 1;
		return $iReturn
	EndIf

	; Yes, initialize to get a filename with a unique timestamp
	If get_save_filename("PAINT", $aDestDir, $fileName) == False Then
		ConsoleWrite("Error, Unable to build filename" & @CRLF)
		$iReturn = 2;
		return $iReturn
	EndIf

	; Is mspaint is running?
	Local $status = is_app_running($gPaintStruct[$enAppClass][$enValue])
	ConsoleWrite("is_app_running=" & $status & @CRLF)
	If $status == False Then
		ConsoleWrite("Error, Paint is not running"  & @CRLF)
		$iReturn = 3;
		return $iReturn
	EndIf

	; Yes, Focus to mspaint
	If set_app_focuse($gPaintStruct[$enAppClass][$enValue]) == False Then
		ConsoleWrite("Error, Unable to focus on mspaint" & @CRLF)
		$iReturn = 4;
		return $iReturn
	EndIf

	; Main function
	If copy_buffer_to_paint($aDestDir, $fileName, True) == False Then
		$iReturn = 5;
		return $iReturn
	EndIf

	ConsoleWrite("-----" & $funcName & ";" & $iReturn & @CRLF)
	return $iReturn
EndFunc
