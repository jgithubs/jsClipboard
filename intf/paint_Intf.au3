; Caller shall include "lib_Intf.aue" before including this file
; Snip Information
Global $gPaintExecutable    = "mspaint.exe"

; Dialog 1
Global $gPaintDialog1_title = "Untitled - Paint"
Global $gPaintDialog1_class = "[CLASS:MSPaintApp]"
Global $gPaintX             = -1
Global $gPaintY             = -1
Global $gPaintW             = -1
Global $gPaintH             = -1

; Dialog 2
Global $gPaintDialog2_title      = "Save As"
Global $gPaintDialog2_cntrl_Path = "ToolbarWindow324"
Global $gPaintDialog2_cntrl_File = "Edit1"

Func paint_init($aPrefix, $aPath, ByRef $aFilename)
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
	ConsoleWrite("aFilename ; " & $aFilename & @CRLF)

	; filepath
	if dir_exists($aPath) == True Then
		$bReturn = True;
		ConsoleWrite("path      ;" & $aPath & ";" & dir_exists($aPath) & @CRLF)
	EndIf

	Return $bReturn
EndFunc

Func copy_buffer_to_paint($aPath, $aFilename, $aSaveFlag = False)
	; Insert Image from buffer
	Send($gCmdPaste)
	Send($gCmdEsc)

	If $aSaveFlag == True Then
		; Invoke a save
		Send($gCmdSave)
		WinWaitActive($gPaintDialog1_class)

		; Set the path
		ControlFocus($gPaintDialog2_title, "", $gPaintDialog2_cntrl_Path)
		ControlSend ($gPaintDialog2_title, "", $gPaintDialog2_cntrl_Path,     $aPath)

		; Set the filename
		ControlFocus($gPaintDialog1_class, "", $gPaintDialog2_cntrl_File)
		ControlSend ($gPaintDialog1_class, "", $gPaintDialog2_cntrl_File, $aFilename)

	EndIf
EndFunc
