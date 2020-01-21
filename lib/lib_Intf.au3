#include "Date.au3"

Func is_app_running($aTitleClassHandle)
	Local $bReturn = False
	If WinExists($aTitleClassHandle) == 1 Then
		$bReturn = True
	EndIf
	Return $bReturn
EndFunc

Func is_app_focused($aTitleClassHandle)
	Local $bReturn = False
	If WinActive($aTitleClassHandle) <> 0 Then
		$bReturn = True
	EndIf
	Return $bReturn
EndFunc

Func set_app_focuse($aTitleClassHandle)
	Local $bReturn = False
	If WinActivate($aTitleClassHandle) <> 0 Then
		$bReturn = True
	EndIf
	Return $bReturn
EndFunc

Func get_timestamp()
	Local $bReturn = "HHMMSS"
	; Get current time to enable a unique time
	Local $temp1   = _NowTime(5)
	Local $temp2   = StringSplit($temp1, ":")
	Local $bReturn = $temp2[1] & $temp2[2] & $temp2[3]
	Return $bReturn
EndFunc

Func is_clip_text()
	Local $bReturn = False
	; By default, expecting text data
	Local $status = ClipGet()
	If @error == 0 Then
		$bReturn = True
	EndIf
	Return $bReturn
EndFunc

Func is_clip_image()
	Local $bReturn = False
	; By default, expecting text data
	Local $status1 = ClipGet() ; Text string is returned (no meaning here)
	Local $status2 = @error    ; Type is in the return status
	If $status2 == 2 Then
		$bReturn = True
	EndIf
	;ConsoleWrite("is_clip_image;status2=" & $status2 & ";1=cb-empty,2=cb-nontext,3or4=cb-notaccessable" & @CRLF)
	Return $bReturn
EndFunc

Func is_clip_empty()
	Local $bReturn = False
	; By default, expecting text data
	Local $status1 = ClipGet() ; Text string is returned (no meaning here)
	Local $status2 = @error    ; Type is in the return status
	If $status2 == 1 Then
		$bReturn = True
	EndIf
	;ConsoleWrite("is_clip_image;status2=" & $status2 & ";1=cb-empty,2=cb-nontext,3or4=cb-notaccessable" & @CRLF)
	Return $bReturn
EndFunc

Func get_cmdarg($aMax, $aMin, $aIndex, ByRef $aReturn, $aType)
	Local $bReturn = False
	; string, dir, fn

	If $CmdLine[0] > $aMax Then
		ConsoleWrite("CmdLine max exceeded: " & $CmdLine[0] & " of " & $aMax & @CRLF)
	ElseIf $CmdLine[0] < $aMin Then
		ConsoleWrite("CmdLine min deceeded: " & $CmdLine[0] & " of " & $aMin & @CRLF)
    Else
		Switch $CmdLine[1]
			Case "/?"
				MsgBox(0, "", "Help")
			Case "/s"
				MsgBox(0, "", "_s")
			Case "/u"
				MsgBox(0, "", "_u")
			Case "/x"
				MsgBox(0, "", "_x")
		EndSwitch
	EndIf
	Return $bReturn
EndFunc

Func dir_exists($aPath)
	Local $bReturn = False
    If FileExists($aPath) Then
		If StringInStr(FileGetAttrib($aPath), 'D') Then
			$bReturn = True
		EndIf
	EndIf
    Return $bReturn
EndFunc