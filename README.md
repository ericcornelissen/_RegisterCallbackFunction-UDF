# _RegisterCallbackFunction()
A UDF to create a callback loop for a certain function in your project.

## How to install
<ol>
<li>Download and install <a href="https://www.autoitscript.com/site/autoit/downloads/">AutoIt v3</a>.</li>
<li>Copy the UDF Au3 file (_RegisterCallbackFunction.au3) to your '..\AutoIt3\Include' folder.</li>
<li>Create your AutoIt v3 project.</li>
<li>Include the UDF to your project, as shown below.</li>
</ol>
```autoit
#include <_RegisterCallbackFunction.au3>
```

## How to use
Short example below. For full and working examples see the example(s) folder.
```autoit
#include <_RegisterCallbackFunction.au3>
_RegisterCallbackFunction ( "_myFunc", 1000 )

Func _myFunc ()
  ConsoleWrite ( "Hey there, this message will appear every second!" )
EndFunc
```