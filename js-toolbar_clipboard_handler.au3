; CNTRL+FN+B
#include <GUIConstantsEX.au3>
#include <windowsconstants.au3>
#include <buttonconstants.au3>
#include <StaticConstants.au3>
#include <WinAPIEx.au3> ; Search the Forum and place in the includes folder.

#include "lib\lib_Intf.au3"
#include "lib\lib_cmds.au3"
#include "intf\paint_Intf.au3"   ; requires lib_intf.au3 and lib_cmds.au3
#include "intf\snip_Intf.au3"    ; requires lib_intf.au3 and lib_cmds.au3
#include "intf\notepad_Intf.au3" ; requires lib_intf.au3 and lib_cmds.au3
;Opt("MustDeclareVars", 1)

; ver 1.2.0
; $h_ToolBar = XSkinToolBarCreate($Xh_Gui, $tool_left, $tool_top, $tool_width, $tool_bkcolor = "")
; XSkinToolBarButton($iNumber, $iDLL = "shell32.dll")
; XSkinToolBarSeparator()

Global $TBcnt = -1

; ************************ YOUR CODE GOES BELOW HERE *****************************

; 1920 x 1200
Global $gBtnWidth  = 60          ; 24
Global $gBtnHeight = $gBtnWidth  ; Square

ConsoleWrite("Width          =" & @DesktopWidth    & @CRLF)
ConsoleWrite("Height         =" & @DesktopHeight   & @CRLF)
ConsoleWrite("ScriptDir      =" & @ScriptDir       & @CRLF)
ConsoleWrite("WindowsDir     =" & @WindowsDir      & @CRLF)
ConsoleWrite("SystemDir      =" & @SystemDir       & @CRLF)
ConsoleWrite("ProgramFilesDir=" & @ProgramFilesDir & @CRLF)

Local $junk        = 0
Local $iOffset     = 100
Local $iWidth      = ($gBtnWidth * 15) + ($gBtnWidth * 4) + 2
Local $iTop        = 80
Local $iLeft       = @DesktopWidth - ($iWidth + $iOffset)
Local $dirSystem32 = @SystemDir & "\"
Local $dirScript   = @ScriptDir & "\"
Local $dirIco      = $dirScript & "ico\"
Local $dirDest     = "C:\MyTemp\PaintMgr"
ConsoleWrite("dirIco         =" & $dirIco      & @CRLF)
ConsoleWrite("dirDest        =" & $dirDest     & @CRLF)
ConsoleWrite("dirSystem32    =" & $dirSystem32 & @CRLF)
ConsoleWrite("dirScript      =" & $dirScript   & @CRLF)
ConsoleWrite("====="                           & @CRLF)

Local $h_ToolBar = XSkinToolBarCreate("Float-ToolBar", $iLeft, $iTop, $iWidth)


Local $TButton01 = XSkinToolBarButton("", $dirIco & "\one.ico")
GUICtrlSetTip( -1, "Buffer Clear")

Local $TButton02 = XSkinToolBarButton("", $dirIco & "\two.ico")
GUICtrlSetTip( -1, "Buffer Check")

Local $TButton03 = XSkinToolBarButton("", $dirIco & "\three.ico")
GUICtrlSetTip( -1, "App Info")

Local $TButton04 = XSkinToolBarButton("", $dirIco & "\four.ico")
GUICtrlSetTip( -1, "Not Defined")

Local $TButton05 = XSkinToolBarButton("", $dirIco & "\five.ico")
GUICtrlSetTip( -1, "Prt Scr")

Local $TButton06 = XSkinToolBarButton("", $dirIco & "\six.ico")
GUICtrlSetTip( -1, "Alt Prt Scr")

; Seperator
XSkinToolBarSeparator()
GUICtrlSetTip( -1, "Drag Me")


Local $TButton07 = XSkinToolBarButton("", $dirSystem32 & $gNotepadStruct[$enAppExe][$enValue])
GUICtrlSetTip( -1, "Open Notepad")
Local $TButton08 = XSkinToolBarButton("", $dirIco & "\save.ico")
GUICtrlSetTip( -1, "Save Buffer to Notepad")
; Seperator
XSkinToolBarSeparator()
GUICtrlSetTip( -1, "Drag Me")


Local $TButton09 = XSkinToolBarButton("", $dirSystem32 & $gPaintStruct[$enAppExe][$enValue])
GUICtrlSetTip( -1, "Open Paint")
Local $TButton10 = XSkinToolBarButton("", $dirIco & "\save.ico")
GUICtrlSetTip( -1, "Save Buffer to Paint")
; Seperator
XSkinToolBarSeparator()
GUICtrlSetTip( -1, "Drag Me")


; #3 - Using Icons from an ico file
Local $TButton11 = XSkinToolBarButton("", $dirIco & "\snip.ico")
GUICtrlSetTip( -1, "Open Snip")
Local $TButton12 = XSkinToolBarButton("", $dirIco & "\save.ico")
GUICtrlSetTip( -1, "Save Buffer to Snip")
; Seperator
XSkinToolBarSeparator()
GUICtrlSetTip( -1, "Drag Me")


; Exit Button
Local $TButton13   = XSkinToolBarButton("", $dirIco & "\configure.ico")
GUICtrlSetTip( -1, "Save Window Positions")

Local $TButton14   = XSkinToolBarButton("", $dirIco & "\sync.ico")
GUICtrlSetTip( -1, "Reset Windows")

Local $TButtonLast = XSkinToolBarButton("", $dirIco & "\stop.ico")
GUICtrlSetTip( -1, "Exit Toolbar")

GUISetState(@SW_SHOW, $h_ToolBar)

WinSetOnTop($h_ToolBar, "", 1)

While 1
    $msg = GUIGetMsg()

	If $msg = $TButton01 Then
		buffer_clear()
    ElseIf $msg = $TButton02 Then
		buffer_check()
    ElseIf $msg = $TButton03 Then
		appinfo_dump_info("BTN7", $gNotepadStruct)
		appinfo_dump_info("BTN7", $gPaintStruct)
		appinfo_dump_info("BTN7", $gSnipStruct)
    ElseIf $msg = $TButton04 Then
		buffer_alt_print_screen()
    ElseIf $msg = $TButton05 Then
		buffer_print_screen()
    ElseIf $msg = $TButton06 Then
		buffer_alt_print_screen()

	Elseif $msg = $TButton07 Then
		appinfo_save_info($gNotepadStruct)
    ElseIf $msg = $TButton08 Then
		buffer_check()

	ElseIf $msg = $TButton09 Then
		appinfo_save_info($gPaintStruct)
	ElseIf $msg = $TButton10 Then
		ConsoleWrite(buffer_to_mspaint_and_save($dirDest) & ";Button10" & @CRLF)

	ElseIf $msg = $TButton11 Then
		appinfo_save_info($gSnipStruct)
    ElseIf $msg = $TButton12 Then
		ConsoleWrite(buffer_to_snip_and_save($dirDest) & ":Button13" & @CRLF)

	ElseIf $msg = $TButton13 Then
		appinfo_save_info($gPaintStruct)
		appinfo_save_info($gNotepadStruct)
		appinfo_save_info($gSnipStruct)
	ElseIf $msg = $TButton14 Then
		appinfo_reset_pos($gPaintStruct)
		appinfo_reset_pos($gNotepadStruct)
		appinfo_reset_pos($gSnipStruct)
    ElseIf $msg = $TButtonLast Then
		Exit
	EndIf
WEnd

; ************************ YOUR CODE ENDS HERE *****************************

;Func appinfo_reset_pos($aPid, $aClass, $aTitle, $aX, $aY, $aW, $aH)
;	Local $bResult =  False
;	;DumpWindowInfo("appinfo_reset_pos", $aClass, $aTitle, $aX, $aY, $aW, $aH)
;	
;	Local $hWnd1 = WinWait($aClass, "", 10)
;	If $hWnd1 <> 0 Then
;		ConsoleWrite("hWnd1=" & $hWnd1 & @CRLF)
;		Local $hWnd2 = WinMove($hWnd1, $aTitle, $aX, $aY, $aW, $ah)
;		ConsoleWrite("hWnd2=" & $hWnd2 & @CRLF)
;		If $hWnd2 <> 0 Then
;			$bResult = True
;		EndIf
;	EndIf
;	Return $bResult
;EndFunc

Func buffer_to_snip_and_save($aDestDir)
	Local $funcName = "buffer_to_snip_and_save"
	ConsoleWrite("+++++" & $funcName & @CRLF)
	Local $iReturn = 0;
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
	If snip_init("SNIP", $aDestDir, $fileName) == False Then
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

	ConsoleWrite("----- " & $funcName & @CRLF)
	return $iReturn
EndFunc

;---------------

Func buffer_to_mspaint_and_save($aDestDir)
	Local $funcName = "buffer_to_mspaint_and_save"
	ConsoleWrite("+++++ " & $funcName & @CRLF)
	Local $iReturn = 0;
	; This toolbar has the focus
	Local $fileName = ""


	; Is an image present in the clipboard?
	If is_clip_image() == False Then
		ConsoleWrite("Error, No image on clipboard" & @CRLF)
		$iReturn = 1;
		return $iReturn
	EndIf

	; Yes, initialize to get a filename with a unique timestamp
	If paint_init("PAINT", $aDestDir, $fileName) == False Then
		ConsoleWrite("Error, Unable to build filename" & @CRLF)
		$iReturn = 2;
		return $iReturn
	EndIf

	; Is mspaint is running?
	Local $status = is_app_running($gSnipStruct[$enAppClass][$enValue])
	ConsoleWrite("is_app_running=" & $status & @CRLF)
	If $status == False Then
		ConsoleWrite("Error, Paint is not running"  & @CRLF)
		$iReturn = 3;
		return $iReturn
	EndIf

	; Yes, Focus to mspaint
	If set_app_focuse($gSnipStruct[$enAppClass][$enValue]) == False Then
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

; ------------

Func buffer_check()
	Local $bReturn = False

	If is_clip_empty() == True Then
		ConsoleWrite("Clipboard is empty" & @CRLF)
		$bReturn = True;
		Return $bReturn
	Else
		If is_clip_text() == True Then
			ConsoleWrite("Clipboard has text" & @CRLF)
			$bReturn = True;
			Return $bReturn
		EndIf

		If is_clip_image() == True Then
			ConsoleWrite("Clipboard has image" & @CRLF)
			$bReturn = True;
			Return $bReturn
		EndIf
	EndIf

	ConsoleWrite("Clipboard has unknown contents" & @CRLF)
	Return $bReturn
EndFunc

Func buffer_print_screen()
	Local $bReturn = False

	; Copy image from the app to the clipboard
	Send($gCmdScrPrint)

	If is_clip_text() == True Then
		ConsoleWrite("Error, clipboard has text" & @CRLF)
		Return $bReturn
	EndIf

	If is_clip_image() == False Then
		ConsoleWrite("Error, clipboard has no image" & @CRLF)
		Return $bReturn
	EndIf

	$bReturn = True
	Return $bReturn
EndFunc

Func buffer_alt_print_screen()
	Local $bReturn = False

	; Capture the window in focus
	; Unfortunantly, this is the tool bar
	; Need to figure out how to program a set of keystrokes to a key

	; Copy image from the app to the clipboard
	Send($gCmdScrPrint)

	If is_clip_text() == True Then
		ConsoleWrite("Error, clipboard has text" & @CRLF)
		Return $bReturn
	EndIf

	If is_clip_image() == False Then
		ConsoleWrite("Error, clipboard has no image" & @CRLF)
		Return $bReturn
	EndIf

	$bReturn = True
	Return $bReturn
EndFunc

Func buffer_clear()
	Local $bReturn = False

	; Clear the clipboard
	ClipPut("")

	If is_clip_text() == True Then
		ConsoleWrite("Error, clipboard still has text" & @CRLF)
		Return $bReturn
	EndIf

	If is_clip_image() == True Then
		ConsoleWrite("Error, clipboard still has image" & @CRLF)
		Return $bReturn
	EndIf

	$bReturn = True
	ConsoleWrite("Clipboard cleared" & @CRLF)
	Return $bReturn
EndFunc



; ************************ YOUR CODE ENDS HERE *****************************

Func XSkinToolBarCreate($XTitle, $tool_left, $tool_top, $tool_width, $tool_bkcolor = "")
    Local $Xh_ToolBar = GUICreate($XTitle, $tool_width, $gBtnHeight, $tool_left, $tool_top, $WS_POPUP, $WS_CLIPCHILDREN);-1, $WS_EX_STATICEDGE);, $Xh_Gui)
    If $tool_bkcolor <> "" Then GUISetBkColor($tool_bkcolor, $Xh_ToolBar)
    Return $Xh_ToolBar
EndFunc   ;==>XSkinToolBarCreate

Func XSkinToolBarButton($iNumber, $aDllExeIco = "shell32.dll")
    $TBcnt          = $TBcnt + 1
	Local $iconSize = 1 ; 0=small, 1=normal
    Local $TBBleft  = $TBcnt * $gBtnWidth
    Local $Xhadd    = GUICtrlCreateButton("", $TBBleft, 1, $gBtnWidth, $gBtnHeight, $BS_ICON)
    GUICtrlSetImage($Xhadd, $aDllExeIco, $iNumber, $iconSize)
    Return $Xhadd
EndFunc   ;==>XSkinToolBarButton

Func XSkinToolBarButton2($iNumber, $aDllExeIco = "shell32.dll")
    $TBcnt          = $TBcnt + 1
	Local $iconSize = 1 ; 0=small, 1=normal
    Local $TBBleft  = $TBcnt * $gBtnWidth
	_WinAPI_Wow64EnableWow64FsRedirection(False)
    Local $Xhadd    = GUICtrlCreateButton("", $TBBleft, 1, $gBtnWidth, $gBtnHeight, $BS_ICON)
    GUICtrlSetImage($Xhadd, $aDllExeIco, $iNumber, $iconSize)
	_WinAPI_Wow64EnableWow64FsRedirection(True)
    Return $Xhadd
EndFunc   ;==>XSkinToolBarButton

Func XSkinToolBarSeparator()
	$TBcnt          = $TBcnt + 1
    Local $TBBleft  = $TBcnt * $gBtnWidth
	Local $barWidth = $gBtnWidth / 2
    GUICtrlCreateLabel("", $TBBleft+$barWidth, 2, $gBtnWidth, $gBtnHeight, $SS_ETCHEDVERT, $GUI_WS_EX_PARENTDRAG)
EndFunc   ;==>XSkinToolBarSeparator