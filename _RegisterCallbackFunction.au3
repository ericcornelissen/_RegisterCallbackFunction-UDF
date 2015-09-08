#Region Header

#include-once

#include <Array.au3>

#CS UDF Info

   Name............: _RegisterCallbackFunction-UDF.au3
   Description.....: A UDF to create a callback loop for a certain function in your project.
   Author..........: Eric Cornelissen (https://github.com/ericcornelissen)
   Remarks.........: 1) Do not try crazy things with parameters if you don't know what you're doing (It may cause your program to freeze)!
   Requirements....: 1) Make sure "Array.au3" is installed in your AutoIt dir (..\AutoIt3\Include).
   Link............: https://github.com/ericcornelissen/_RegisterCallbackFunction-UDF

   *** Version History ***
   [v1.4] - [18.02.2015]
	  * Minor improvement to the return values of public functions.
	  * Minor improvements to the descriptions of public functions.

   [v1.3] - [17.02.2015]
	  + Added functions to request information about a registered callback
		 function, simply by giving it the registered callback ID.
	  * Improved return values for all public function.
	  * Improved public function descriptions.

   [v1.2] - [16.02.2015]
	  + Added the option to give your callback function parameters. Parameters
		 are limited to all DllCall() types except 'struct'.
	  + Added a function to edit the parameters of a callback function.
	  + Added two variables to the '$a__CBF_SYS_Callback' array
	  * Improved the public function descriptions.
	  * Changed internal function names.

   [v1.1] - [15.02.2015]
	  + Added a function to change the interval of a callback function.
	  * Changed '_CallbackFunctionStop' to '_CallbackRegFunc_Stop'.
	  * Updated examples.

   [v1.0] - [14.02.2015]
	  * First release.

#CE

#EndRegion Header

#Region Internal Global Variables

Global $a__CBF_SYS_Callback[1][6]
Global $i__CBF_SYS_Callback				= 0
Global $d__CDF_SYS_DEFAULTTIMER			= 5000

Global $c__CBF_User32_DLL				= @SystemDir & "\User32.dll"

Execute('OnAutoItExitRegister("__RCF_Exit")')

#EndRegion Internal Global Variables

#Region Public Functions

; #FUNCTION# ====================================================================================================
; Name............: _RegisterCallbackFunction
; Description.....: Create a callback loop for a certain function in your project.
; Syntax..........: _RegisterCallbackFunction-UDF ( $sFunction [, $iTimer = -1 [, $sParam = ""]] )
; Parameters......:	$sFunction		- The function to call.
;					$iTimer			- [Optional] The timeout between each time the function is called in milliseconds.
;										Default is 5000 (also used when a invalid value is given).
;					$sParam			- [Optional] The parameters for the callback function seperated by semicolons. Uses
;										all DllCall() types except 'struct'. Default is none.
; Return Values...: Success			- the identifier (controlID) of the new control.
;					Failure			- 0.
; Author..........:	Eric Cornelissen (https://github.com/ericcornelissen)
; Modified........:
; Remarks.........: 1) Use a positive integers for the timer ($iTimer).
;					2) Make sure the function has an equal amount of parameters as there are parameters given to $sParam,
;						otherwise your program will freeze.
; Related.........:
; Link............: https://github.com/ericcornelissen/_RegisterCallbackFunction-UDF
; ===============================================================================================================
Func _RegisterCallbackFunction ( $sFunction, $iTimer = -1, $sParam = "" )
   If $iTimer < 0 Or IsInt ( $iTimer ) = 0 Or IsString ( $iTimer ) = 1 Then $iTimer = $d__CDF_SYS_DEFAULTTIMER

   $i__CBF_SYS_Callback += 1
   ReDim $a__CBF_SYS_Callback[$i__CBF_SYS_Callback + 1][6]
   $a__CBF_SYS_Callback[$i__CBF_SYS_Callback][0] = DllCallbackRegister ( $sFunction, "none", $sParam )
   $tTimerID = DllCall ( $c__CBF_User32_DLL, "int", "SetTimer", "hwnd", 0, "uint_ptr", Round ( TimerInit ( ) ), "uint", Abs ( $iTimer ), "ptr", DllCallbackGetPtr ( $a__CBF_SYS_Callback[$i__CBF_SYS_Callback][0] ) )
   $a__CBF_SYS_Callback[$i__CBF_SYS_Callback][2] = __RCF_GetID ( )
   $a__CBF_SYS_Callback[$i__CBF_SYS_Callback][3] = $sFunction
   $a__CBF_SYS_Callback[$i__CBF_SYS_Callback][4] = $iTimer
   $a__CBF_SYS_Callback[$i__CBF_SYS_Callback][5] = $sParam

   If IsArray ( $tTimerID ) Then
	  $a__CBF_SYS_Callback[$i__CBF_SYS_Callback][1] = $tTimerID[0]
   Else
	  $a__CBF_SYS_Callback[$i__CBF_SYS_Callback][1] = $tTimerID
   EndIf


   If $a__CBF_SYS_Callback[$i__CBF_SYS_Callback][0] = 0 Then
	  Return ( 0 )
   Else
	  Return ( $a__CBF_SYS_Callback[$i__CBF_SYS_Callback][2] )
   EndIf
EndFunc


; #FUNCTION# ====================================================================================================
; Name............: _CallbackRegFunc_EditParam
; Description.....: Change the parameters of a registered callback function.
; Syntax..........: _CallbackRegFunc_EditParam ( $iCallbackFunc_ID, $nParam )
; Parameters......: $iCallbackFunc_ID	- The control identifier (controlID) as returned by _RegisterCallbackFunction-UDF().
;					$nParam				- The parameters for the callback function seperated by semicolons. Uses all DllCall()
;											types except 'struct'.
; Return Values...: Success				- 1.
;					Failure				- 0.
; Author..........:	Eric Cornelissen (https://github.com/ericcornelissen)
; Modified........:
; Remarks.........: 1) Make sure the function has an equal amount of parameters as there are parameters given to $nParam,
;						otherwise your program will freeze.
; Related.........: _RegisterCallbackFunction-UDF(), _CallbackRegFunc_GetParam()
; Link............: https://github.com/ericcornelissen/_RegisterCallbackFunction-UDF
; ===============================================================================================================
Func _CallbackRegFunc_EditParam ( $iCallbackFunc_ID, $nParam )
   Local $i = __RCF_FindID ( $iCallbackFunc_ID )
   If NOT @ERROR Then
	  __RCF_StopCallBack ( $a__CBF_SYS_Callback[$i][0], $a__CBF_SYS_Callback[$i][1] )

	  $a__CBF_SYS_Callback[$i][0] = DllCallbackRegister ( $a__CBF_SYS_Callback[$i][3], "none", $nParam )
	  $tTimerID = DllCall ( $c__CBF_User32_DLL, "int", "SetTimer", "hwnd", 0, "uint_ptr", Round ( TimerInit ( ) ), "uint", Abs ( $a__CBF_SYS_Callback[$i][4] ), "ptr", DllCallbackGetPtr ( $a__CBF_SYS_Callback[$i__CBF_SYS_Callback][0] ) )

	  If IsArray ( $tTimerID ) Then
		 $a__CBF_SYS_Callback[$i__CBF_SYS_Callback][1] = $tTimerID[0]
	  Else
		 $a__CBF_SYS_Callback[$i__CBF_SYS_Callback][1] = $tTimerID
	  EndIf

	  Return ( 1 )
   Else
	  Return ( 0 )
   EndIf
EndFunc

; #FUNCTION# ====================================================================================================
; Name............: _CallbackRegFunc_EditTimer
; Description.....: Change the interval time of a registered callback function.
; Syntax..........: _CallbackRegFunc_EditTimer ( $iCallbackFunc_ID, $nTimer )
; Parameters......: $iCallbackFunc_ID	- The control identifier (controlID) as returned by _RegisterCallbackFunction-UDF().
;					$nTimer				- The new timeout between each time the function is called in milliseconds. When an
;											invalid value is given a timer of 5000 will be used.
; Return Values...: Success				- 1.
;					Failure				- 0.
; Author..........:	Eric Cornelissen (https://github.com/ericcornelissen)
; Modified........:
; Remarks.........: 1) Use a positive integers for the timer ($nTimer).
; Related.........: _RegisterCallbackFunction-UDF(), _CallbackRegFunc_GetTimer()
; Link............: https://github.com/ericcornelissen/_RegisterCallbackFunction-UDF
; ===============================================================================================================
Func _CallbackRegFunc_EditTimer ( $iCallbackFunc_ID, $nTimer )
   Local $i = __RCF_FindID ( $iCallbackFunc_ID )
   If NOT @ERROR Then
	  If $nTimer < 0 Or IsInt ( $nTimer ) = 0 Or IsString ( $nTimer ) = 1 Then $nTimer = $d__CDF_SYS_DEFAULTTIMER

	  DllCall ( $c__CBF_User32_DLL, "int", "KillTimer", "hwnd", 0, "uint_ptr", $a__CBF_SYS_Callback[$i][1] )
	  $tTimerID = DllCall ( $c__CBF_User32_DLL, "int", "SetTimer", "hwnd", 0, "uint_ptr", Round ( TimerInit ( ) ), "uint", Abs ( $nTimer ), "ptr", DllCallbackGetPtr ( $a__CBF_SYS_Callback[$i][0] ) )
	  $a__CBF_SYS_Callback[$i__CBF_SYS_Callback][4] = $nTimer

	  If IsArray ( $tTimerID ) Then
		 $a__CBF_SYS_Callback[$i][1] = $tTimerID[0]
	  Else
		 $a__CBF_SYS_Callback[$i][1] = $tTimerID
	  EndIf

	  Return ( 1 )
   Else
	  Return ( 0 )
   EndIf
EndFunc


; #FUNCTION# ====================================================================================================
; Name............: _CallbackRegFunc_GetFunction
; Description.....: Get the function a registered callback function is calling.
; Syntax..........: _CallbackRegFunc_GetFunction ( $iCallbackFunc_ID )
; Parameters......: $iCallbackFunc_ID	- The control identifier (controlID) as returned by _RegisterCallbackFunction-UDF().
; Return Values...: Success				- The function that is called by the registered callback function.
;					Failure				- 0.
; Author..........:	Eric Cornelissen (https://github.com/ericcornelissen)
; Modified........:
; Remarks.........:
; Related.........: _RegisterCallbackFunction-UDF()
; Link............: https://github.com/ericcornelissen/_RegisterCallbackFunction-UDF
; ===============================================================================================================
Func _CallbackRegFunc_GetFunction ( $iCallbackFunc_ID )
   Local $i = __RCF_FindID ( $iCallbackFunc_ID )
   If NOT @ERROR Then
	  Return ( $a__CBF_SYS_Callback[$i][3] )
   Else
	  Return ( 0 )
   EndIf
EndFunc

; #FUNCTION# ====================================================================================================
; Name............: _CallbackRegFunc_GetParam
; Description.....: Get the parameters of a registered callback function.
; Syntax..........: _CallbackRegFunc_GetParam ( $iCallbackFunc_ID )
; Parameters......: $iCallbackFunc_ID	- The control identifier (controlID) as returned by _RegisterCallbackFunction-UDF().
; Return Values...: Success				- The parameters that are used by the registered callback function.
;					Failure				- 0.
; Author..........:	Eric Cornelissen (https://github.com/ericcornelissen)
; Modified........:
; Remarks.........:
; Related.........: _RegisterCallbackFunction-UDF(), _CallbackRegFunc_EditParam()
; Link............: https://github.com/ericcornelissen/_RegisterCallbackFunction-UDF
; ===============================================================================================================
Func _CallbackRegFunc_GetParam ( $iCallbackFunc_ID )
   Local $i = __RCF_FindID ( $iCallbackFunc_ID )
   If NOT @ERROR Then
	  Return ( $a__CBF_SYS_Callback[$i][5] )
   Else
	  Return ( 0 )
   EndIf
EndFunc

; #FUNCTION# ====================================================================================================
; Name............: _CallbackRegFunc_GetTimer
; Description.....: Get the timer of a registered callback function.
; Syntax..........: _CallbackRegFunc_GetTimer ( $iCallbackFunc_ID )
; Parameters......: $iCallbackFunc_ID	- The control identifier (controlID) as returned by _RegisterCallbackFunction-UDF().
; Return Values...: Success				- The length of the timer for the registered callback function.
;					Failure				- 0.
; Author..........:	Eric Cornelissen (https://github.com/ericcornelissen)
; Modified........:
; Remarks.........:
; Related.........: _RegisterCallbackFunction-UDF(), _CallbackRegFunc_EditTimer()
; Link............: https://github.com/ericcornelissen/_RegisterCallbackFunction-UDF
; ===============================================================================================================
Func _CallbackRegFunc_GetTimer ( $iCallbackFunc_ID )
   Local $i = __RCF_FindID ( $iCallbackFunc_ID )
   If NOT @ERROR Then
	  Return ( $a__CBF_SYS_Callback[$i][4] )
   Else
	  Return ( 0 )
   EndIf
EndFunc


; #FUNCTION# ====================================================================================================
; Name............: _CallbackRegFunc_Stop
; Description.....: Stop the callback of a function started with _RegisterCallbackFunction-UDF().
; Syntax..........: _CallbackRegFunc_Stop ( $iCallbackFunc_ID )
; Parameters......: $iCallbackFunc_ID	- The control identifier (controlID) as returned by _RegisterCallbackFunction-UDF().
; Return Values...: Success				- 1.
;					Failure				- 0.
; Author..........:	Eric Cornelissen (https://github.com/ericcornelissen)
; Modified........:
; Remarks.........:
; Related.........: _RegisterCallbackFunction-UDF()
; Link............: https://github.com/ericcornelissen/_RegisterCallbackFunction-UDF
; ===============================================================================================================
Func _CallbackRegFunc_Stop ( $iCallbackFunc_ID )
   Local $i = __RCF_FindID ( $iCallbackFunc_ID )
   If NOT @ERROR Then
	  __RCF_StopCallBack ( $a__CBF_SYS_Callback[$i][0], $a__CBF_SYS_Callback[$i][1] )

	  _ArrayDelete ( $a__CBF_SYS_Callback, $i )
	  $i__CBF_SYS_Callback -= 1

	  Return ( 1 )
   Else
	  Return ( 0 )
   EndIf
EndFunc

#EndRegion Public Functions

#Region Internal Functions

Func __RCF_StopCallBack ( $iTimerProc, $iTimerID )
   DllCallbackFree ( $iTimerProc )
   DllCall ( $c__CBF_User32_DLL, "int", "KillTimer", "hwnd", 0, "uint_ptr", $iTimerID )
EndFunc

Func __RCF_FindID ( $iCallbackFunc_ID )
   For $i = 1 To $i__CBF_SYS_Callback
	  If StringCompare ( $iCallbackFunc_ID, $a__CBF_SYS_Callback[$i][2], 1 ) = 0 Then
		 Return ( $i )
	  EndIf
   Next

   SetError ( 1 ) ;ID not found
EndFunc

Func __RCF_GetID ( )
   Do
	  Local $ID = "", $x = True
	  Dim $aChar[3]
	  For $i = 1 To 8
		 $aChar[0] = Chr ( Random ( 65, 90, 1 ) ) ;A-Z
		 $aChar[1] = Chr ( Random ( 97, 122, 1 ) ) ;a-z
		 $aChar[2] = Chr ( Random ( 48, 57, 1 ) ) ;0-9
		 $ID &= $aChar[Random ( 0, 2, 1 )]
	  Next

	  For $i = 0 To $i__CBF_SYS_Callback
		 If StringCompare ( $ID, $a__CBF_SYS_Callback[$i][2], 1 ) = 0 Then
			$x = False
			ExitLoop
		 EndIf
	  Next
   Until $x = True

   Return ( $ID )
EndFunc

Func __RCF_Exit ( )
   For $i = 1 To $i__CBF_SYS_Callback
	  __RCF_StopCallBack ( $a__CBF_SYS_Callback[$i][0], $a__CBF_SYS_Callback[$i][1] )
   Next
EndFunc

#EndRegion Internal Functions