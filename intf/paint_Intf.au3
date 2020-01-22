; Caller shall include "lib_Intf.aue" before including this file
; Snip Information
Global $gPaintExecutable    = "mspaint.exe"

; Dialog 1
Global $gPaintDialog1_class = "[CLASS:MSPaintApp]"

Global $gPaintDialog1_title = "Untitled - Paint"
Global $gPaintX             = -1
Global $gPaintY             = -1
Global $gPaintW             = -1
Global $gPaintH             = -1

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
