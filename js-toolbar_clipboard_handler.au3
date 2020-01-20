#include <GUIConstantsEX.au3>
#include <windowsconstants.au3>
#include <buttonconstants.au3>
#include <StaticConstants.au3>
#include <WinAPIEx.au3> ; Search the Forum and place in the includes folder.

#include "lib\lib_Intf.au3"
#include "lib\lib_cmds.au3"
#include "intf\paint_Intf.au3" ; requires lib_intf.au3
#include "intf\snip_Intf.au3"  ; requires lib_intf.au3
;Opt("MustDeclareVars", 1)

; ver 1.2.0
; $h_ToolBar = XSkinToolBarCreate($Xh_Gui, $tool_left, $tool_top, $tool_width, $tool_bkcolor = "")
; XSkinToolBarButton($iNumber, $iDLL = "shell32.dll")
; XSkinToolBarSeparator()

Global $TBcnt = -1

; ************************ YOUR CODE GOES BELOW HERE *****************************

; 1920 x 1200
Global $gBtnWidth  = 80          ; 24
Global $gBtnHeight = $gBtnWidth  ; Square

ConsoleWrite("Width          =" & @DesktopWidth    & @CRLF)
ConsoleWrite("Height         =" & @DesktopHeight   & @CRLF)
ConsoleWrite("ScriptDir      =" & @ScriptDir       & @CRLF)
ConsoleWrite("WindowsDir     =" & @WindowsDir      & @CRLF)
ConsoleWrite("SystemDir      =" & @SystemDir       & @CRLF)
ConsoleWrite("ProgramFilesDir=" & @ProgramFilesDir & @CRLF)

Local $iOffset     = 100
Local $iWidth      = ($gBtnWidth * 12) + ($gBtnWidth * 3) + 2
Local $iTop        = 80
Local $iLeft       = @DesktopWidth - ($iWidth + $iOffset)
Local $h_ToolBar   = XSkinToolBarCreate("Float-ToolBar", $iLeft, $iTop, $iWidth)
Local $dirSystem32 = @SystemDir & "\"
Local $dirScript   = @ScriptDir & "\"
Local $dirIco      = $dirScript & "ico\"
ConsoleWrite("dirSystem32    =" & $dirSystem32 & @CRLF)
ConsoleWrite("dirScript      =" & $dirScript   & @CRLF)
ConsoleWrite("=====" & @CRLF)

Local $exeFile01 = "notepad.exe"
Local $TButton01 = XSkinToolBarButton("", $dirSystem32 & $exeFile01)

; #1 - Using Icons from a dll ( shell32.dll is default)
Local $exeFile02 = "mspaint.exe"
Local $TButton02 = XSkinToolBarButton("", $dirSystem32 & $exeFile02)

Local $exeFile03 = "snippingtool.exe"
Local $TButton03 = XSkinToolBarButton("", $dirSystem32 & $exeFile03)

Local $exeFile04 = "calc.exe"
Local $TButton04 = XSkinToolBarButton("", $dirSystem32 & $exeFile04)

; Seperator
XSkinToolBarSeparator()
GUICtrlSetTip( -1, "Drag Me")

; #2 - Using Icons from an exe file
Local $TButton05 = XSkinToolBarButton("", $dirIco & "\one.ico")

Local $TButton06 = XSkinToolBarButton("", $dirIco & "\two.ico")

Local $TButton07 = XSkinToolBarButton("", $dirIco & "\three.ico")

Local $TButton08 = XSkinToolBarButton("", $dirIco & "\four.ico")

; Seperator
XSkinToolBarSeparator()
GUICtrlSetTip( -1, "Drag Me")

; #3 - Using Icons from an ico file
Local $TButton09 = XSkinToolBarButton("", $dirIco & "\five.ico")

Local $TButton10 = XSkinToolBarButton("", $dirIco & "\six.ico")

Local $TButton11 = XSkinToolBarButton("", $dirIco & "\seven.ico")

; Seperator
XSkinToolBarSeparator()
GUICtrlSetTip( -1, "Drag Me")

; Exit Button
$TButtonLast = XSkinToolBarButton(27)

GUISetState(@SW_SHOW, $h_ToolBar)

WinSetOnTop($h_ToolBar, "", 1)

While 1
    $msg = GUIGetMsg()

    if $msg = $TButton01 Then
		Run($exeFile01)           ; Open notepad
    ElseIf $msg = $TButton02 Then
		Run($exeFile02)           ; Open mspain
    ElseIf $msg = $TButton03 Then
		_WinAPI_Wow64EnableWow64FsRedirection(False)
		Run($exeFile03)           ; Open snip
		_WinAPI_Wow64EnableWow64FsRedirection(True)
    ElseIf $msg = $TButton04 Then
		Run($exeFile04)           ; Open calc
    ElseIf $msg = $TButton05 Then
		buffer_clear()            ; One, buffer clear
    ElseIf $msg = $TButton06 Then
		buffer_print_screen()     ; Two, buffer: insert entire screen
    ElseIf $msg = $TButton07 Then
		buffer_alt_print_screen() ; Three
    ElseIf $msg = $TButton08 Then
		buffer_check() ; Four
    ElseIf $msg = $TButton09 Then
		buffer_check() ; Five
    ElseIf $msg = $TButton10 Then
		buffer_to_snip_and_save()    ; Six,   copy clipboard to snip  and setup save
    ElseIf $msg = $TButton11 Then
		buffer_to_mspaint_and_save() ; Seven, copy clipboard to paint and setup save
    ElseIf $msg = $TButtonLast Then
		Exit
	EndIf
WEnd

; ************************ YOUR CODE ENDS HERE *****************************

Func buffer_to_snip_and_save()
	Local $iReturn = 0;
	; This toolbar has the focus
	Local $dir      = "C:\MyAu3\PaintMgr"
	Local $fileName = ""
	ConsoleWrite("+++++" & @CRLF)

	; Is an image present in the clipboard?
	If is_clip_image() == False Then
		ConsoleWrite("Error, No image on clipboard" & @CRLF)
		$iReturn = 1;
		return $iReturn
	EndIf

	; Yes, initialize to get a filename with a unique timestamp
	If snip_init("SNIP", $dir, $fileName) == False Then
		ConsoleWrite("Error, Unable to build filename" & @CRLF)
		$iReturn = 1;
		return $iReturn
	EndIf

	; Is mspaint is running?
	Local $status = is_app_running($gSnipDialog1_title)
	ConsoleWrite("is_app_running=" & $status & @CRLF)
	If $status == False Then
		ConsoleWrite("Error, Snip is not running"  & @CRLF)
		$iReturn = 1;
		return $iReturn
	EndIf

	; Yes, Focus to mspaint
	If set_app_focuse($gSnipDialog1_title) == False Then
		ConsoleWrite("Error, Unable to focus on mspaint" & @CRLF)
		$iReturn = 1;
		return $iReturn
	EndIf

	; Main function
	If copy_buffer_to_snip($dir, $fileName, True) == True Then
		$iReturn = 1;
		return $iReturn
	EndIf

	ConsoleWrite("-----" & @CRLF)
	return $iReturn
EndFunc

Func buffer_to_mspaint_and_save()
	Local $iReturn = 0;
	; This toolbar has the focus
	Local $dir      = "C:\MyAu3\PaintMgr"
	Local $fileName = ""
	ConsoleWrite("+++++" & @CRLF)

	; Is an image present in the clipboard?
	If is_clip_image() == False Then
		ConsoleWrite("Error, No image on clipboard" & @CRLF)
		$iReturn = 1;
		return $iReturn
	EndIf

	; Yes, initialize to get a filename with a unique timestamp
	If paint_init("PAINT", $dir, $fileName) == False Then
		ConsoleWrite("Error, Unable to build filename" & @CRLF)
		$iReturn = 1;
		return $iReturn
	EndIf

	; Is mspaint is running?
	Local $status = is_app_running($gDialog1_title)
	ConsoleWrite("is_app_running=" & $status & @CRLF)
	If $status == False Then
		ConsoleWrite("Error, Paint is not running"  & @CRLF)
		$iReturn = 1;
		return $iReturn
	EndIf

	; Yes, Focus to mspaint
	If set_app_focuse($gDialog1_title) == False Then
		ConsoleWrite("Error, Unable to focus on mspaint" & @CRLF)
		$iReturn = 1;
		return $iReturn
	EndIf

	; Main function
	If copy_buffer_to_paint($dir, $fileName, True) == True Then
		$iReturn = 1;
		return $iReturn
	EndIf

	ConsoleWrite("-----" & @CRLF)
	return $iReturn
EndFunc

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
    $TBcnt         = $TBcnt + 1
	Local $iconSize = 1 ; 0=small, 1=normal
    Local $TBBleft = $TBcnt * $gBtnWidth
    Local $Xhadd   = GUICtrlCreateButton("", $TBBleft, 1, $gBtnWidth, $gBtnHeight, $BS_ICON)
    GUICtrlSetImage($Xhadd, $aDllExeIco, $iNumber, $iconSize)
    Return $Xhadd
EndFunc   ;==>XSkinToolBarButton

Func XSkinToolBarButton2($iNumber, $aDllExeIco = "shell32.dll")
    $TBcnt         = $TBcnt + 1
	Local $iconSize = 1 ; 0=small, 1=normal
    Local $TBBleft = $TBcnt * $gBtnWidth
	_WinAPI_Wow64EnableWow64FsRedirection(False)
    Local $Xhadd   = GUICtrlCreateButton("", $TBBleft, 1, $gBtnWidth, $gBtnHeight, $BS_ICON)
    GUICtrlSetImage($Xhadd, $aDllExeIco, $iNumber, $iconSize)
	_WinAPI_Wow64EnableWow64FsRedirection(True)
    Return $Xhadd
EndFunc   ;==>XSkinToolBarButton

Func XSkinToolBarSeparator()
    ;$TBcnt         = $TBcnt + .5
	$TBcnt          = $TBcnt + 1
    Local $TBBleft  = $TBcnt * $gBtnWidth
	Local $barWidth = $gBtnWidth / 2
    GUICtrlCreateLabel("", $TBBleft+$barWidth, 2, $gBtnWidth, $gBtnHeight, $SS_ETCHEDVERT, $GUI_WS_EX_PARENTDRAG)
EndFunc   ;==>XSkinToolBarSeparator