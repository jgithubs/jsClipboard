; Caller shall include "lib_Intf.aue" before including this file

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
; Snip Information


; Dialog 2
Global $gPaintDialog2_title      = "Save As"
Global $gPaintDialog2_cntrl_Path = "ToolbarWindow324"
Global $gPaintDialog2_cntrl_File = "Edit1"

Func paint_init($aPrefix, $aPath, ByRef $aFilename)
	Local $funcName = "paint_init"
	ConsoleWrite("+++++ " & $funcName & @CRLF)
	Local $bReturn = False

	; filename, part 1
	Local $timeStamp   = get_timestamp()
	; filename, part 3
	Local $fileSuffix    = "_func.png"

	ConsoleWrite("aPath     ;" & $aPath      & @CRLF)
	ConsoleWrite("timestamp ;" & $timeStamp  & @CRLF)
	ConsoleWrite("aPrefix   ;" & $aPrefix    & @CRLF)
	ConsoleWrite("fileSuffix;" & $fileSuffix & @CRLF)

	; filename
	$aFilename = $timeStamp & "-" & $aPrefix & $fileSuffix
	ConsoleWrite("aFilename ;" & $aFilename & @CRLF)

	; filepath
	if dir_exists($aPath) == True Then
		$bReturn = True;
		ConsoleWrite("path      ;" & $aPath & ";" & dir_exists($aPath) & @CRLF)
	EndIf

	ConsoleWrite("----- " & $funcName & @CRLF)
	Return $bReturn
EndFunc

Func copy_buffer_to_paint($aPath, $aFilename, $aSaveFlag = False)
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
		Else
			ConsoleWrite("Timeout" & @CRLF)
		EndIf

	EndIf
	ConsoleWrite("+++++ " & $funcName & @CRLF)
EndFunc