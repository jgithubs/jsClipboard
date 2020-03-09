;#include <ButtonConstants.au3>
;#include <EditConstants.au3>
#include <GUIConstantsEx.au3> ; $GUI_EVENT_CLOSE
;#include <StaticConstants.au3>
;#include <WindowsConstants.au3>
#include <Timers.au3> ; _Timer_SetTimer
#include <WinAPIEx.au3> ; Redirection

#include "lib\lib_Intf.au3"
#include "lib\lib_cmds.au3"
#include "intf\snip_Intf.au3"    ; requires lib_intf.au3 and lib_cmds.au3
#include "intf\paint_Intf.au3"

; Horizontal
Global  $gLeft1       = 30
Global  $gLeft2       = $gLeft1 + 30*2

Global  $gWidth1      = 100
Global  $gWidth2      = 100

; Vertical
Global  $gTop         = 30
Global  $gTopOffset   = 35

; Dialog
Global $gDialogWidth  = 413
Global $gDialogHeight = $gTopOffset*14
Global $gDialogLeft   = 192
Global $gDialogTop    = 180

Global $gSec          = 3

; Main WIndow
Global $hwndDialog = GUICreate("Process/Hwnd Watcher", $gDialogWidth, $gDialogHeight, $gDialogLeft, $gDialogTop)

; Label/Box
Global $wLabel     = 120
Global $hLabel     = 20

;$gTop = $gTopOffset
GUICtrlCreateLabel                      ("Class", $gLeft1, $gTop, $wLabel,   $hLabel)
Global $gIdLabel1  = GUICtrlCreateLabel ("",      $gLeft2, $gTop, $wLabel*3, $hLabel)
$gTop = $gTop + $gTopOffset
GUICtrlCreateLabel                      ("Pid",   $gLeft1, $gTop, $wLabel, $hLabel)
Global $gIdLabel2  = GUICtrlCreateLabel ("",      $gLeft2, $gTop, $wLabel, $hLabel)
$gTop = $gTop + $gTopOffset
GUICtrlCreateLabel                      ("hWnd",  $gLeft1, $gTop, $wLabel, $hLabel)
Global $gIdLabel3  = GUICtrlCreateLabel ("",      $gLeft2, $gTop, $wLabel, $hLabel)

$gTop = $gTop + $gTopOffset
GUICtrlCreateLabel                      ("Title",  $gLeft1, $gTop, $wLabel, $hLabel)
Global $gIdLabel4  = GUICtrlCreateLabel ("",      $gLeft2, $gTop, $wLabel, $hLabel)

$gTop = $gTop + $gTopOffset
GUICtrlCreateLabel                      ("X",     $gLeft1, $gTop, $wLabel, $hLabel)
Global $gIdLabel5  = GUICtrlCreateLabel ("",      $gLeft2, $gTop, $wLabel, $hLabel)
$gTop = $gTop + $gTopOffset
GUICtrlCreateLabel                      ("Y",      $gLeft1, $gTop, $wLabel, $hLabel)
Global $gIdLabel6  = GUICtrlCreateLabel ("",       $gLeft2, $gTop, $wLabel, $hLabel)
$gTop = $gTop + $gTopOffset
GUICtrlCreateLabel                      ("W",       $gLeft1, $gTop, $wLabel, $hLabel)
Global $gIdLabel7  = GUICtrlCreateLabel ("",        $gLeft2, $gTop, $wLabel, $hLabel)
$gTop = $gTop + $gTopOffset
GUICtrlCreateLabel                      ("H",      $gLeft1, $gTop, $wLabel, $hLabel)
Global $gIdLabel8  = GUICtrlCreateLabel ("",       $gLeft2, $gTop, $wLabel, $hLabel)
$gTop = $gTop + $gTopOffset
GUICtrlCreateLabel                      ("Rtn",    $gLeft1, $gTop, $wLabel, $hLabel)
Global $gIdLabel9  = GUICtrlCreateLabel ("",       $gLeft2, $gTop, $wLabel, $hLabel)
$gTop = $gTop + $gTopOffset
GUICtrlCreateLabel                      ("Status", $gLeft1, $gTop, $wLabel, $hLabel)
Global $gIdLabelA  = GUICtrlCreateLabel ("",       $gLeft2, $gTop, $wLabel, $hLabel)
$gTop = $gTop + $gTopOffset
GUICtrlCreateLabel ("Time", $gLeft1, $gTop, $wLabel, $hLabel)
Global $gIdInput1  = GUICtrlCreateInput ("Time",   $gLeft2, $gTop, $wLabel, $hLabel)

; Button
$gTop = $gTop + $gTopOffset
Global $gIdButton1 = GUICtrlCreateButton("Start", $gLeft2, $gTop, $wLabel, $hLabel)
$gTop = $gTop + $gTopOffset
Global $gIdButton2 = GUICtrlCreateButton("Stop", $gLeft2, $gTop, $wLabel, $hLabel)

GUICtrlSetData($gIdInput1, StringFormat("%02d:%02d:%02d", @HOUR, @MIN, @SEC))
GUICtrlSetState($gIdButton1, $GUI_FOCUS)
GUICtrlSetState($gIdButton2, $GUI_DISABLE)
GUICtrlSetState($gIdButton1, $GUI_ENABLE)
GUISetState(@SW_SHOW)

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			Exit
		Case $gIdButton1
			;_Timer_SetTimer($hwndDialog, 1000*2, "_UpdateControlsForSnip")
			_Timer_SetTimer($hwndDialog, 1000*$gSec, "_UpdateControlsForPaint")
			GUICtrlSetState($gIdButton1, $GUI_DISABLE)
			GUICtrlSetState($gIdButton2, $GUI_ENABLE)

			GUICtrlSetState($gIdButton2, $GUI_FOCUS)
		Case $gIdButton2
			 _Timer_KillAllTimers($hwndDialog)
			GUICtrlSetState($gIdButton2, $GUI_DISABLE)
			GUICtrlSetState($gIdButton1, $GUI_ENABLE)

			GUICtrlSetState($gIdButton1, $GUI_FOCUS)
	EndSwitch
WEnd

; call back function
Func _UpdateControlsForSnip($ahWnd, $aiMsg, $aiIDTimer, $aiTime)
	Local $status = -1
    Local $cfg    = 2

    If $cfg == 1 Then
        If appinfo_dump_processlist(@MIN&":"&@SEC, $gSnipStruct) == False Then
            ConsoleWrite           (@MIN&":"&@SEC&"..."&@CRLF)
        EndIf
    ElseIf $cfg == 2 Then
        If appinfo_dump_winlist(@MIN&":"&@SEC, $gSnipStruct) == False Then
            ConsoleWrite       (@MIN&":"&@SEC&"..."&@CRLF)
        EndIf
    Else
        Local $rtn    = appinfo_save_info($gSnipStruct, $status, False)

        GUICtrlSetData($gIdInput1, StringFormat("%02d:%02d:%02d", @HOUR, @MIN, @SEC))

        GUICtrlSetData($gIdLabel1, $gSnipStruct[$enAppClass][$enValue])
        GUICtrlSetData($gIdLabel2, $gSnipStruct[$enAppPid][$enValue])
        GUICtrlSetData($gIdLabel3, $gSnipStruct[$enAppHwd][$enValue])
        GUICtrlSetData($gIdLabel4, $gSnipStruct[$enAppX][$enValue])
        GUICtrlSetData($gIdLabel5, $gSnipStruct[$enAppY][$enValue])
        GUICtrlSetData($gIdLabel6, $gSnipStruct[$enAppW][$enValue])
        GUICtrlSetData($gIdLabel7, $gSnipStruct[$enAppH][$enValue])

        GUICtrlSetData($gIdLabel8, $rtn)
        GUICtrlSetData($gIdLabel9, $status&";"&ConvertGetPidToString($status))
    EndIf

EndFunc   ;==>_UpdateControlsForSnip

Func _UpdateControlsForPaint($ahWnd, $aiMsg, $aiIDTimer, $aiTime)
	Local $status = -1

    Local $cfg = 3

    If $cfg == 1  Or  $cfg == 2 Then
        Local $sTime = $cfg  &";"&@MIN&":"&@SEC
        Local $sMsg  = $sTime&";"&$gPaintStruct[$enAppExe][$enValue]&"..."&@CRLF
        If $cfg == 1  Then
            If appinfo_dump_processlist($sTime, $gPaintStruct) == False Then
                ConsoleWrite($sMsg)
            EndIf
        ElseIf $cfg == 2 Then
            If appinfo_dump_winlist    ($sTime, $gPaintStruct) == False Then
                ConsoleWrite($sMsg)
            EndIf
        EndIf
    Else
        Local $rtn    = appinfo_save_info($gPaintStruct, $status, False)

        GUICtrlSetData($gIdInput1, StringFormat("%02d:%02d:%02d", @HOUR, @MIN, @SEC))

        GUICtrlSetData($gIdLabel1, $gPaintStruct[$enAppClass][$enValue])
        GUICtrlSetData($gIdLabel2, $gPaintStruct[$enAppPid][$enValue])
        GUICtrlSetData($gIdLabel3, $gPaintStruct[$enAppHwd][$enValue])
        GUICtrlSetData($gIdLabel4, $gPaintStruct[$enAppTitle][$enValue])
        GUICtrlSetData($gIdLabel5, $gPaintStruct[$enAppX][$enValue])
        GUICtrlSetData($gIdLabel6, $gPaintStruct[$enAppY][$enValue])
        GUICtrlSetData($gIdLabel7, $gPaintStruct[$enAppW][$enValue])
        GUICtrlSetData($gIdLabel8, $gPaintStruct[$enAppH][$enValue])

        GUICtrlSetData($gIdLabel9, $rtn)
        GUICtrlSetData($gIdLabelA, $status&";"&ConvertGetPidToString($status))
    EndIf

EndFunc   ;==>_UpdateControlsForPaint