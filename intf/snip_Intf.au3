; Caller shall include "lib_Intf.au3" before including this file.
; Caller shall include "lib_cmds.au3" before including this file.
; Snip Information
Global $gSnipExecutable         = "snippingtool.exe"
Global $gSnipDialog1_class      = "[CLASS:Microsoft-Windows-SnipperToolbar]"
Global $gSnipX                  = -1
Global $gSnipY                  = -1
Global $gSnipW                  = -1
Global $gSnipH                  = -1

; Dialog 1
Global $gSnipDialog1_title      = "Snipping Tool"

; Dialog 2
Global $gSnipDialog2_title      = "Save As"
Global $gSnipDialog2_cntrl_Path = "ToolbarWindow324"
Global $gSnipDialog2_cntrl_File = "Edit1"

Func snip_init($aPrefix, $aPath, ByRef $aFilename)
	Local $funcName = "snip_init"
	ConsoleWrite("+++++ " & $funcName & @CRLF)
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
		ConsoleWrite("Error, aPath does not exists: " & $aPath)
	EndIf

	ConsoleWrite("----- " & $funcName & @CRLF)
	Return $bReturn
EndFunc

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
		ConsoleWrite("hWnd1=" & $hWnd1 & $gPaintDialog2_title & @CRLF)
		
		; Set the path
		ControlFocus($gSnipDialog2_title, "", $gSnipDialog2_cntrl_Path)
		ControlSend ($gSnipDialog2_title, "", $gSnipDialog2_cntrl_Path,     $aPath)

		; Set the filename
		ControlFocus($gSnipDialog2_title, "", $gSnipDialog2_cntrl_File)
		ControlSend ($gSnipDialog2_title, "", $gSnipDialog2_cntrl_File, $aFilename)

	EndIf
	ConsoleWrite("----- " & $funcName & @CRLF)
EndFunc