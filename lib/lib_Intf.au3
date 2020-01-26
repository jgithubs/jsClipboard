#include "Date.au3"
#include <WinAPIEx.au3> ; Redirection

; App Structure test/value
Global Enum $enAppExe, $enAppRedirect, $enAppClass, $enAppTitle, $enAppPid, $enAppHwd, $enAppX, $enAppY, $enAppW, $enAppH
Global Enum $enTitle, $enValue



; Credit: https://github.com/subnet-/AutoIT.git
;===============================================================================
;
; Function Name:    _ProcessGetHWnd
; Description:      Returns the HWND(s) owned by the specified process (PID only !).
;
; Parameter(s):     $iPid		- the owner-PID.
;					$iOption	- Optional : return/search methods :
;						0 - returns the HWND for the first non-titleless window.
;						1 - returns the HWND for the first found window (default).
;						2 - returns all HWNDs for all matches.
;
;                   $sTitle		- Optional : the title to match (see notes).
;					$iTimeout	- Optional : timeout in msec (see notes)
;
; Return Value(s):  On Success - returns the HWND (see below for method 2).
;						$array[0][0] - number of HWNDs
;						$array[x][0] - title
;						$array[x][1] - HWND
;
;                   On Failure	- returns 0 and sets @error to 1.
;
; Note(s):			When a title is specified it will then only return the HWND to the titles
;					matching that specific string. If no title is specified it will return as
;					described by the option used.
;
;					When using a timeout it's possible to use WinWaitDelay (Opt) to specify how
;					often it should wait before attempting another time to get the HWND.
;
;
; Author(s):        Helge
;
;===============================================================================
Func _ProcessGetHWnd($iPid, $iOption = 1, $sTitle = "", $iTimeout = 2000)
	Local $aReturn[1][1] = [[0]], $aWin, $hTimer = TimerInit()

	While 1

		; Get list of windows
		$aWin = WinList($sTitle)

		; Searches thru all windows
		For $i = 1 To $aWin[0][0]

			; Found a window owned by the given PID
			If $iPid = WinGetProcess($aWin[$i][1]) Then

				; Option 0 or 1 used
				If $iOption = 1 OR ($iOption = 0 And $aWin[$i][0] <> "") Then
					Return $aWin[$i][1]

				; Option 2 is used
				ElseIf $iOption = 2 Then
					ReDim $aReturn[UBound($aReturn) + 1][2]
					$aReturn[0][0] += 1
					$aReturn[$aReturn[0][0]][0] = $aWin[$i][0]
					$aReturn[$aReturn[0][0]][1] = $aWin[$i][1]
				EndIf
			EndIf
		Next

		; If option 2 is used and there was matches then the list is returned
		If $iOption = 2 And $aReturn[0][0] > 0 Then Return $aReturn

		; If timed out then give up
		If TimerDiff($hTimer) > $iTimeout Then ExitLoop

		; Waits before new attempt
		Sleep(Opt("WinWaitDelay"))
	WEnd


	; No matches
	SetError(1)
	Return 0
EndFunc   ;==>_ProcessGetHWnd

Func appinfo_save_info(ByRef $aArray)

	Local $bReturn = False
	Local $funcName = "appinfo_save_info"
	ConsoleWrite("+++++ " & $funcName & " " & $aArray[$enAppExe][$enValue] & @CRLF)

	Local $hWnd = 0

	; Does a single valid process exists?
	If appinfo_get_pid($aArray) == True Then
		; Yes, using existing process
		$bReturn = True
	Else
		; No, start a process
		If $aArray[$enAppRedirect][$enValue] == True Then _WinAPI_Wow64EnableWow64FsRedirection(False)
		$aPid      = Run($aArray[$enAppExe][$enValue])
		If $aArray[$enAppRedirect][$enValue] == True Then _WinAPI_Wow64EnableWow64FsRedirection(True)
		; Does a Pid and hWnd exists?
		If $aPid <> 0 Then
			$hWnd = _ProcessGetHWnd($aPid)
			If $hWnd <> 0 Then
				; Yes, Save the appinfo
				Local $winPos = WinGetPos($hWnd)
				If @error == 0 Then
					$aHwnd  = $hWnd
					$aTitle = WinGetTitle($hWnd)
					$aX     = $winPos[0]
					$aY     = $winPos[1]
					$aW     = $winPos[2]
					$aH     = $winPos[3]
					; exe and class will always be the same
					$bReturn = True
				EndIf
			EndIf
		EndIf
	EndIf

	ConsoleWrite("----- " & $funcName & "," & $bReturn & @CRLF)
	Return $bReturn
EndFunc

Func appinfo_reset_pos($aArray)
	Local $bResult =  False
	Local $funcName = "appinfo_reset_pos"
	ConsoleWrite("+++++ " & $funcName & " " & $aArray[$enAppExe][$enValue] & @CRLF)

	Local $hWnd1 = WinWait($aArray[$enAppClass][$enValue], "", 10)
	If $hWnd1 <> 0 Then
		ConsoleWrite("Class hWnd1=" & $hWnd1 & @CRLF)
		Local $hWnd2 = WinMove($hWnd1, $aArray[$enAppTitle][$enValue], _
			$aArray[$enAppX][$enValue], $aArray[$enAppY][$enValue], $aArray[$enAppW][$enValue], $aArray[$enAppH][$enValue])
		ConsoleWrite("Window hWnd2=" & $hWnd2 & @CRLF)
		If $hWnd2 <> 0 Then
			$bResult = True
		EndIf
	EndIf

	ConsoleWrite("----- " & $funcName & "," & $bResult & @CRLF)
	Return $bResult
EndFunc

Func appinfo_get_pid(ByRef $aArray)
	Local $bReturn = False
	Local $funcName = "appinfo_get_pid"
	ConsoleWrite("+++++ " & $funcName & @CRLF)

	;appinfo_dump_info("BF", $aArray)

	Local $aPL     = ProcessList($aArray[$enAppExe][$enValue])
	Local $nProcesses = $aPL[0][0]

	; Process further only if a single process exists
	If $nProcesses == 1 Then
		Local $name       = $aPL[1][0]
		Local $pid        = $aPL[1][1]
		;ConsoleWrite("SingleProcess;"&$aPL[1][0]&";"&$aPL[1][1]&@CRLF)
		; If the handle can be obtained, the all the appinfo is available
		Local $hWnd   = _ProcessGetHWnd($pid, 1, $aArray[$enAppTitle][$enValue])
		Local $status = @error
		ConsoleWrite("SingleProcess;name="&$name&";pid="&$pid &";hwnd="&$hWnd&";title="&$aArray[$enAppTitle][$enValue]&";status="&$status&@CRLF)
		If $hWnd <> 0 Then
			Local $winPos = WinGetPos($hWnd)
			$aArray[$enAppPid][$enValue] = $pid
			$aArray[$enAppHwd][$enValue] = $hWnd
			$aArray[$enAppX][$enValue]   = $winPos[0]
			$aArray[$enAppY][$enValue]   = $winPos[1]
			$aArray[$enAppW][$enValue]   = $winPos[2]
			$aArray[$enAppH][$enValue]   = $winPos[3]
			$bReturn = True
		EndIf
	Else
		ConsoleWrite("MultipleProcess or no process"&@CRLF)
	EndIf
	ConsoleWrite("----- " & $funcName & "," & $bReturn & @CRLF)
	Return $bReturn
EndFunc

Func appinfo_dump_info($aHeader, $aArray)
	Local $funcName = "appinfo_dump_info"
	ConsoleWrite("+++++ " & $funcName & " " & $aArray[$enAppExe][$enValue] & @CRLF)

	Local $aPL = ProcessList($aArray[$enAppExe][$enValue])
	Local $i   = 0;
	ConsoleWrite("nProcesses="&$aPL[$i][0]&@CRLF)
	For $i = 1 To $aPL[0][0]
		Local $hWnd   = _ProcessGetHWnd($aPL[$i][1])
		Local $sTitle = "NA"
		Local $sPos   = ";X=NA;Y=NA;W=NA;H=NA"
		If $hWnd <> 0 Then
			$sTitle = WinGetTitle($hWnd)
			$winPos = WinGetPos($hWnd)
			$sPos   = ";X="&$winPos[0]&";Y="&$winPos[1]&";W="&$winPos[2]&";H="&$winPos[3]
			$sPos   = StringReplace($sPos, "NA", $winPos[0], 1)
			$sPos   = StringReplace($sPos, "NA", $winPos[1], 1)
			$sPos   = StringReplace($sPos, "NA", $winPos[2], 1)
			$sPos   = StringReplace($sPos, "NA", $winPos[3], 1)
		EndIf
		ConsoleWrite("idx="  &$i    &";Name'=" &$aPL[$i][0] & ";Pid'="& $aPL[$i][1] & _
					 ";hWnd'="&$hWnd &";Title="&$sTitle     & $sPos & _
					 @CRLF)
	Next
	ConsoleWrite($enAppExe      & $aArray[$enAppExe][$enTitle]      & " =" & $aArray[$enAppExe][$enValue]      & @CRLF)
	ConsoleWrite($enAppRedirect & $aArray[$enAppRedirect][$enTitle] & " =" & $aArray[$enAppRedirect][$enValue] & @CRLF)
	ConsoleWrite($enAppClass    & $aArray[$enAppClass][$enTitle]    & " =" & $aArray[$enAppClass][$enValue]    & @CRLF)
	ConsoleWrite($enAppTitle    & $aArray[$enAppTitle][$enTitle]    & " =" & $aArray[$enAppTitle][$enValue]    & @CRLF)
	ConsoleWrite($enAppPid      & $aArray[$enAppPid][$enTitle]      & " =" & $aArray[$enAppPid][$enValue]      & @CRLF)
	ConsoleWrite($enAppHwd      & $aArray[$enAppHwd][$enTitle]      & " =" & $aArray[$enAppHwd][$enValue]      & @CRLF)

	ConsoleWrite($enAppX & $aArray[$enAppX][$enTitle]     & " =" & $aArray[$enAppX][$enValue]    & @CRLF)
	ConsoleWrite($enAppY & $aArray[$enAppY][$enTitle]     & " =" & $aArray[$enAppY][$enValue]    & @CRLF)
	ConsoleWrite($enAppW & $aArray[$enAppW][$enTitle]     & " =" & $aArray[$enAppW][$enValue]    & @CRLF)
	ConsoleWrite($enAppH & $aArray[$enAppH][$enTitle]     & " =" & $aArray[$enAppH][$enValue]    & @CRLF)
	ConsoleWrite("----- "  & $funcName & @CRLF)
EndFunc


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