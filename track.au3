;#include <GUIConstantsEX.au3>
;#include <windowsconstants.au3>
;#include <buttonconstants.au3>
;#include <StaticConstants.au3>
#include <WinAPIEx.au3> ; Redirection

#include "lib\lib_Intf.au3"
#include "lib\lib_cmds.au3"
#include "intf\paint_Intf.au3"   ; requires lib_intf.au3 and lib_cmds.au3
#include "intf\snip_Intf.au3"    ; requires lib_intf.au3 and lib_cmds.au3
#include "intf\notepad_Intf.au3" ; requires lib_intf.au3 and lib_cmds.au3

CreateFirst("First")
;CreateFirst("Again1")
;CreateFirst("Again2")
;MsgBox(0, "Reset Test", "Move window to reset")
;ResetSingle()



Func CreateFirst($aTag)
	Local $nTimes = 300
	For $i = 1 To $nTimes
		Local $Header = "Time " & $i & " to " & $nTimes
		appinfo_save_info($gSnipStruct)
		appinfo_dump_info($Header, $gSnipStruct)
		Sleep(1000*10)
	Next
	;appinfo_save_info($gPaintStruct)
	;appinfo_dump_info($aTag, $gPaintStruct)
EndFunc

Func ResetSingle()
	appinfo_reset_pos($gPaintStruct)
EndFunc

Func DumpArray($aArray)
	Local  $arr[3][3] = [[1, 2, 3], [2, 3, 4], [3, 4, 5]]

	For $i = 0 to UBound( $arr, 1) - 1
		For $j = 0 to UBound($arr, 2) - 1
			ConsoleWrite("$arr[" & $i & "][" & $j & "]:=" & $arr[$i][$j] & @LF)
		Next

		ConsoleWrite(@LF)
	Next
EndFunc