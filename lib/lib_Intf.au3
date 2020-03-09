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
; Parameter(s):     $iPid       - the owner-PID.
;                   $iOption    - Optional : return/search methods :
;                       0 - returns the HWND for the first non-titleless window.
;                       1 - returns the HWND for the first found window (default).
;                       2 - returns all HWNDs for all matches.
;
;                   $sTitle     - Optional : the title to match (see notes).
;                   $iTimeout   - Optional : timeout in msec (see notes)
;
; Return Value(s):  On Success - returns the HWND (see below for method 2).
;                       $array[0][0] - number of HWNDs
;                       $array[x][0] - title
;                       $array[x][1] - HWND
;
;                   On Failure  - returns 0 and sets @error to 1.
;
; Note(s):          When a title is specified it will then only return the HWND to the titles
;                   matching that specific string. If no title is specified it will return as
;                   described by the option used.
;
;                   When using a timeout it's possible to use WinWaitDelay (Opt) to specify how
;                   often it should wait before attempting another time to get the HWND.
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
                If $iOption = 1 Or ($iOption = 0 And $aWin[$i][0] <> "") Then
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

; -----------------------------------------------------------------------------

Func appinfo_save_info(ByRef $aArray, ByRef $aStatus, $aStartFlag = False)
    Local $bReturn = False

    Local $funcName = "appinfo_save_info"
    ConsoleWrite("+++++ " & $funcName & " " & $aArray[$enAppExe][$enValue] & @CRLF)

    Local $hWnd = 0
    ;Local $status = 0

    ; Does a single valid process exists?
    If appinfo_get_hwnd($aArray, $aStatus) == True Then
        ; Yes, using existing process
        $bReturn = True
    Else
        ; Process exists but handle does not match
        ;If $aStatus == 1 Then
        ;   $aStatus = 0
        ;   ; Reset to new handle and new position
        ;Else
        ;
        ;EndIf
        If $aStartFlag == True Then
            ; No, start a process
            If $aArray[$enAppRedirect][$enValue] == True Then _WinAPI_Wow64EnableWow64FsRedirection(False)
            $aPid = Run($aArray[$enAppExe][$enValue])
            If $aArray[$enAppRedirect][$enValue] == True Then _WinAPI_Wow64EnableWow64FsRedirection(True)
            ; Does a Pid and hWnd exists?
            If $aPid <> 0 Then
                $hWnd = _ProcessGetHWnd($aPid)
                If $hWnd <> 0 Then
                    ; Yes, Save the appinfo
                    Local $winPos = WinGetPos($hWnd)
                    If @error == 0 Then
                        $aHwnd = $hWnd
                        $aTitle = WinGetTitle($hWnd)
                        $aX = $winPos[0]
                        $aY = $winPos[1]
                        $aW = $winPos[2]
                        $aH = $winPos[3]
                        ; exe and class will always be the same
                        $bReturn = True
                    EndIf
                EndIf
            EndIf
        EndIf
    EndIf

    ConsoleWrite("----- " & $funcName & "," & $bReturn & @CRLF)
    Return $bReturn
EndFunc   ;==>appinfo_save_info

Func appinfo_reset_pos($aArray)
    Local $bResult = False
    Local $funcName = "appinfo_reset_pos"
    ConsoleWrite("+++++ " & $funcName & " " & $aArray[$enAppExe][$enValue] & @CRLF)

    Local $hWnd1 = WinWait($aArray[$enAppClass][$enValue], "", 10)
    ; Does a handle exists based on class name?
    If $hWnd1 <> 0 Then
        ; Yes.  Get title
        ConsoleWrite("Class hWnd1=" & $hWnd1 & @CRLF)
        Local $wTitle = WinGetTitle($hWnd1)
        ConsoleWrite("hWnd1 Title=" & $wTitle & @CRLF)
        ; Move windows based on the handle
        Local $hWnd2 = WinMove($hWnd1, $aArray[$enAppTitle][$enValue], _
                $aArray[$enAppX][$enValue], $aArray[$enAppY][$enValue], $aArray[$enAppW][$enValue], $aArray[$enAppH][$enValue])
        ConsoleWrite("Window hWnd2=" & $hWnd2 & @CRLF)
        ; I move return a handle (same handle), then a good reset
        If $hWnd2 <> 0 Then
            $bResult = True
        EndIf
    EndIf

    ConsoleWrite("----- " & $funcName & "," & $bResult & @CRLF)
    Return $bResult
EndFunc   ;==>appinfo_reset_pos

Func ConvertGetPidToString($aStatus)
    Local $rtnValue = "Unk"
    Switch ($aStatus)
        Case 0
            $rtnValue = "pid  / hwnd"
        Case 1
            $rtnValue = "pid  / hwnd-not"
        Case 2
            $rtnValue = "pid-not / hwnd"
        Case 3
            $rtnValue = "pid-not / hwnd-not"
        Case 99
            $rtnValue = "noPid"
        Case 98
            $rtnValue = "multiPid"
    EndSwitch
    Return $rtnValue
EndFunc   ;==>ConvertGetPidToString

Func appinfo_get_hwnd(ByRef $aArray, ByRef $aRtnFlag)
    Local $bReturn  = False
    Local $funcName = "appinfo_get_hwnd"
    ConsoleWrite("+++++ " & $funcName & @CRLF)

    Local $bPid    = False
    Local $bHWnd   = False
    ; Get a list of windows based on class
    Local $titleHwndList = WinList($aArray[$enAppClass][$enValue])
    Local $idxMax  = $titleHwndList[0][0]
    ConsoleWrite("idxMax="&$idxMax& @CRLF)

    $aRtnFlag = -1

    ; Process further only if a single process exists
    If $idxMax == 0 Then
        ;ConsoleWrite("Zero Processes"     & @CRLF)
        appinfo_set_struct($aArray, -1, -1)
        $aRtnFlag = 99
    ElseIf $idxMax >= 1 Then
        Local $idx     = 0
        ; Loop through all processes that match the executable
        For $idx = 1 To $idxMax
            Local $title = $titleHwndList[$idx][$enTitle]
            Local $hwnd  = $titleHwndList[$idx][$enValue]
            Local $itr   = $idx & ";" & $idxMax
            Local $pid   = WinGetProcess($hwnd)

            ; Is the structure empty?
            If $aArray[$enAppHwd][$enValue] == -1 Then
                ; Yes, use the first instance that produces a valid handle
                If $hwnd <> 0 Then
                    ConsoleWrite($itr & ";Handle produced;Exit" & @CRLF)
                    appinfo_set_struct($aArray, $pid, $hwnd)

                    If $pid <> 0  And  $hwnd <> 0 Then $aRtnFlag = 0 ; pid /hwnd
                    If $pid <> 0  And  $hwnd <> 0 Then $aRtnFlag = 1 ; pid /hwnd'
                    If $pid <> 0  And  $hwnd <> 0 Then $aRtnFlag = 2 ; pid'/hwnd
                    If $pid <> 0  And  $hwnd <> 0 Then $aRtnFlag = 3 ; pid'/hwnd'
                    $bReturn = True  ; A hWnd exists
                    ExitLoop
                Else
                    ConsoleWrite($itr & ";Handle not produced;Next" & @CRLF)
                EndIf
                ; No, does the match the structure?
            ElseIf $pid == $aArray[$enAppPid][$enValue] Then
                $bPid = True
                ; Yes, does the handle match
                Local $hWnd = _ProcessGetHWnd($pid, 1, $aArray[$enAppTitle][$enValue])
                Local $status = @error
                If $hWnd == $aArray[$enAppHwd][$enValue] Then $bHWnd = True

                Local $status = @error
                ConsoleWrite($itr & ";MatchProcess;name=" & $title & ";pid=" & $pid & ";hwnd=" & $hWnd & ";title=" & $aArray[$enAppTitle][$enValue] & ";status=" & $status & ";" & "Exit" & @CRLF)
                If $hWnd > 0 Then
                    appinfo_set_struct($aArray, $pid, $hWnd)

                    If $bPid == True And $bHWnd == True Then $aRtnFlag = 0     ; pid /wnd
                    If $bPid == True And $bHWnd == False Then $aRtnFlag = 1    ; pid /hwnd'
                    If $bPid == False And $bHWnd == True Then $aRtnFlag = 2    ; pid'/hwnd
                    If $bPid == False And $bHWnd == False Then $aRtnFlag = 3   ; pid'/hwnd'
                    $bReturn = True  ; A hWnd exists
                    ExitLoop
                Else
                    ; Reason for not getting a handle
                    ; - Window is not open (minimized)
                    ConsoleWrite($itr & ";Unable to convert pid to handle;Exit" & @CRLF)
                    $aRtnFlag = 98
                    ExitLoop
                EndIf
            Else
                ConsoleWrite($itr & ";UnMatchProcess;name=" & $title & ";pid=" & $pid & ";Next" & @CRLF)
                $aRtnFlag = 99
            EndIf
        Next ; For
    EndIf

    ConsoleWrite("----- " & $funcName & "," & ConvertGetPidToString($aRtnFlag) & "," & $aRtnFlag & "," & $bReturn & @CRLF)
    Return $bReturn
EndFunc   ;==>appinfo_get_hwnd

Func appinfo_set_struct(ByRef $aStruct, $aPid, $aHwnd)
    If $aHwnd > 0 Then
        Local $winPos = WinGetPos($aHwnd)
        $aStruct[$enAppPid][$enValue] = $aPid
        $aStruct[$enAppHwd][$enValue] = $aHwnd
        $aStruct[$enAppX][$enValue] = $winPos[0]
        $aStruct[$enAppY][$enValue] = $winPos[1]
        $aStruct[$enAppW][$enValue] = $winPos[2]
        $aStruct[$enAppH][$enValue] = $winPos[3]
    Else
        $aStruct[$enAppPid][$enValue] = -1
        $aStruct[$enAppHwd][$enValue] = -1
        $aStruct[$enAppX][$enValue] = -1
        $aStruct[$enAppY][$enValue] = -1
        $aStruct[$enAppW][$enValue] = -1
        $aStruct[$enAppH][$enValue] = -1
    EndIf
EndFunc   ;==>appinfo_set_struct

Func appinfo_dump_processlist($aHdr, $aArray)
    Local $rtnValue = False

    Local $arrList = ProcessList($aArray[$enAppExe][$enValue])
    Local $idxMax  = $arrList[0][0]
    Local $idx     = 0
    For $idx = 1 To $idxMax
        Local $name = $arrList[$idx][$enTitle]
        Local $pid  = $arrList[$idx][$enValue]
        Local $Itr  = $idx&"-"&$idxMax
        ConsoleWrite($aHdr&";"&$itr&";"&$pid&";"&$name&@CRLF)
    Next
    If $idxMax > 0 Then $rtnValue = True

    Return $rtnValue
EndFunc   ;==>appinfo_dump_processlist

Func appinfo_dump_winlist($aHdr, $aArray)
    Local $rtnValue = False

    Local $arrList = WinList($aArray[$enAppClass][$enValue])
    Local $idxMax  = $arrList[0][0]
    Local $idx     = 0
    For $idx = 1 To $idxMax
        Local $name = $arrList[$idx][$enTitle]
        Local $hwnd = $arrList[$idx][$enValue]
        Local $itr  = $idx&"-"&$idxMax
        ConsoleWrite($aHdr&";"&$itr&";"&$hwnd&";"&$name&@CRLF)
    Next
    If $idxMax > 0 Then $rtnValue = True

    Return $rtnValue
EndFunc   ;==>appinfo_dump_winlist

Func appinfo_dump_info($aHeader, $aArray)
    Local $funcName = "appinfo_dump_info"
    ConsoleWrite("+++++ " & $funcName & " " & $aArray[$enAppExe][$enValue] & @CRLF)

    Local $aPL = ProcessList($aArray[$enAppExe][$enValue])
    Local $i = 0       ;
    Local $nProcess = $aPL[0][0]
    ConsoleWrite($aHeader & @CRLF)
    ConsoleWrite("nProcesses=" & $nProcess & @CRLF)
    For $i = 1 To $nProcess
        Local $pid = $aPL[$i][1]
        Local $hWnd = _ProcessGetHWnd($aPL[$i][1])
        Local $sTitle = "NA"
        Local $sPos = ";X=NA;Y=NA;W=NA;H=NA"
        If $hWnd <> 0 Then
            $sTitle = WinGetTitle($hWnd)
            $winPos = WinGetPos($hWnd)
            $sPos   = ";X=" & $winPos[0] & ";Y=" & $winPos[1] & ";W=" & $winPos[2] & ";H=" & $winPos[3]
            $sPos   = StringReplace($sPos, "NA", $winPos[0], 1)
            $sPos   = StringReplace($sPos, "NA", $winPos[1], 1)
            $sPos   = StringReplace($sPos, "NA", $winPos[2], 1)
            $sPos   = StringReplace($sPos, "NA", $winPos[3], 1)
        EndIf
        ConsoleWrite("idx=" & $i & ";Name'=" & $aPL[$i][0] & ";Pid'=" & $aPL[$i][1] & _
                ";hWnd'=" & $hWnd & ";Title=" & $sTitle & $sPos & _
                @CRLF)
    Next

    ConsoleWrite($enAppExe      &";"& $aArray[$enAppExe][$enTitle]      & " =" & $aArray[$enAppExe][$enValue] & @CRLF)
    ConsoleWrite($enAppRedirect &";"& $aArray[$enAppRedirect][$enTitle] & " =" & $aArray[$enAppRedirect][$enValue] & @CRLF)
    ConsoleWrite($enAppClass    &";"& $aArray[$enAppClass][$enTitle]    & " =" & $aArray[$enAppClass][$enValue] & @CRLF)
    ConsoleWrite($enAppTitle    &";"& $aArray[$enAppTitle][$enTitle]    & " =" & $aArray[$enAppTitle][$enValue] & @CRLF)
    ConsoleWrite($enAppPid      &";"& $aArray[$enAppPid][$enTitle]      & " =" & $aArray[$enAppPid][$enValue] & @CRLF)
    ConsoleWrite($enAppHwd      &";"& $aArray[$enAppHwd][$enTitle]      & " =" & $aArray[$enAppHwd][$enValue] & @CRLF)

    ConsoleWrite($enAppX        &";"& $aArray[$enAppX][$enTitle]        & " =" & $aArray[$enAppX][$enValue] & @CRLF)
    ConsoleWrite($enAppY        &";"& $aArray[$enAppY][$enTitle]        & " =" & $aArray[$enAppY][$enValue] & @CRLF)
    ConsoleWrite($enAppW        &";"& $aArray[$enAppW][$enTitle]        & " =" & $aArray[$enAppW][$enValue] & @CRLF)
    ConsoleWrite($enAppH        &";"& $aArray[$enAppH][$enTitle]        & " =" & $aArray[$enAppH][$enValue] & @CRLF)
    ConsoleWrite("----- " & $funcName & @CRLF)
EndFunc   ;==>appinfo_dump_info

; -----------------------------------------------------------------------------

Func is_app_running($aTitleClassHandle)
    Local $bReturn = False
    If WinExists($aTitleClassHandle) == 1 Then
        $bReturn = True
    EndIf
    Return $bReturn
EndFunc   ;==>is_app_running

Func is_app_focused($aTitleClassHandle)
    Local $bReturn = False
    If WinActive($aTitleClassHandle) <> 0 Then
        $bReturn = True
    EndIf
    Return $bReturn
EndFunc   ;==>is_app_focused

Func set_app_focuse($aTitleClassHandle)
    Local $bReturn = False
    If WinActivate($aTitleClassHandle) <> 0 Then
        $bReturn = True
    EndIf
    Return $bReturn
EndFunc   ;==>set_app_focuse

; -----------------------------------------------------------------------------

Func get_save_filename($aPrefix, $aPath, ByRef $aFilename)
    Local $funcName = "get_save_filename"
    ConsoleWrite("+++++ " & $funcName & @CRLF)
    Local $bReturn = False

    ; filename, part 1
    Local $timeStamp = get_timestamp()
    ; filename, part 3
    Local $fileSuffix = "_func.png"

    ConsoleWrite("aPath     ;" & $aPath & @CRLF)
    ConsoleWrite("aPrefix   ;" & $aPrefix & @CRLF)
    ConsoleWrite("timestamp ;" & $timeStamp & @CRLF)
    ConsoleWrite("fileSuffix;" & $fileSuffix & @CRLF)

    ; filename
    $aFilename = $timeStamp & "-" & $aPrefix & $fileSuffix
    ConsoleWrite("aFilename ;" & $aFilename & @CRLF)

    ; filepath
    If dir_exists($aPath) == True Then
        $bReturn = True ;
        ConsoleWrite("path      ;" & $aPath & ";" & dir_exists($aPath) & @CRLF)
    EndIf

    ConsoleWrite("----- " & $funcName & " " & $bReturn & @CRLF)
    Return $bReturn
EndFunc   ;==>get_save_filename

Func get_timestamp()
    Local $bReturn = "HHMMSS"
    ; Get current time to enable a unique time
    Local $temp1 = _NowTime(5)
    Local $temp2 = StringSplit($temp1, ":")
    Local $bReturn = $temp2[1] & $temp2[2] & $temp2[3]
    Return $bReturn
EndFunc   ;==>get_timestamp

; -----------------------------------------------------------------------------

Func is_clip_text()
    Local $bReturn = False
    ; By default, expecting text data
    Local $status = ClipGet()
    If @error == 0 Then
        $bReturn = True
    EndIf
    Return $bReturn
EndFunc   ;==>is_clip_text

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
EndFunc   ;==>is_clip_image

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
EndFunc   ;==>is_clip_empty

; -----------------------------------------------------------------------------

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
EndFunc   ;==>get_cmdarg

Func dir_exists($aPath)
    Local $bReturn = False
    If FileExists($aPath) Then
        If StringInStr(FileGetAttrib($aPath), 'D') Then
            $bReturn = True
        EndIf
    EndIf
    Return $bReturn
EndFunc   ;==>dir_exists