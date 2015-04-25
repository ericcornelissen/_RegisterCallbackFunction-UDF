#Include <_RegisterCallbackFunction.au3>
#include <GUIConstantsEx.au3>


$hGUI = GUICreate ( "Example", 270, 140 )
$btt_toggle = GUICtrlCreateButton ( "Enable test function", 10, 30, 120, 23 )
$btt_interval = GUICtrlCreateButton ( "Change interval", 140, 30, 120, 23 )
GUISetState ( @SW_SHOW, $hGUI )

Global $_callback_colorID

While 1
   Local $msg = GUIGetMsg ( )
   Switch $msg
	  Case $btt_toggle
		 If GUICtrlRead ( $btt_toggle ) = "Enable test function" Then
			$_callback_colorID = _RegisterCallbackFunction ( "_callback_color", 2000 )
			GUICtrlSetData ( $btt_toggle, "Disable test function" )
		 Else
			_CallbackRegFunc_Stop ( $_callback_colorID )
			GUICtrlSetData ( $btt_toggle, "Enable test function" )
		 EndIf
	  Case $btt_interval
		 $x = Random ( 500, 5000, 1 ) ;Random number from 500 to 5000 milliseconds
		 MsgBox ( 0, "New interval", "The new interval is: " & $x & " milliseconds" )
		 _CallbackRegFunc_EditTimer ( $_callback_colorID, $x )

	  Case $GUI_EVENT_CLOSE
		 Exit
   EndSwitch
WEnd

Func _callback_color ( )
   Dim $bkColors = [0x8C1717, 0xE04006, 0xFFC125, 0x9CCB19, 0x70DBDB, 0x38B0DE, 0x7F00FF, 0x862A51, 0xFFFFFF]
   GUISetBkColor ( $bkColors[Random ( 0, 8, 1 )], $hGUI )
EndFunc