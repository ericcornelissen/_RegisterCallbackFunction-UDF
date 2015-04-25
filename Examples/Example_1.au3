#Include <_RegisterCallbackFunction.au3>
#include <GUIConstantsEx.au3>


$hGUI = GUICreate ( "Example", 100, 100 )
$lbl_time = GUICtrlCreateLabel ( @HOUR & ":" & @MIN & ":" & @SEC, 30, 40 )
GUISetState ( @SW_SHOW, $hGUI )

_RegisterCallbackFunction ( "_updateTime", 1000 )

While 1
   If GUIGetMsg ( ) = $GUI_EVENT_CLOSE Then Exit
WEnd

Func _updateTime ( )
   GUICtrlSetData ( $lbl_time, @HOUR & ":" & @MIN & ":" & @SEC )
EndFunc