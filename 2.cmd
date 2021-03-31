@echo off
rem ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
rem PLEASE DON'T USE ANY STOPPING COMMANDS, LIKE A "PAUSE",
rem BECAUSE THE INSTALLER WILL NEVER ENDS THIS TASK...
rem ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo. ping.exe -w 1000 -l 1 -n 5 0.0.0.0 ^>nul 2^>^&1
echo. Please wait 5s...
ping.exe -w 1000 -l 1 -n 5 0.0.0.0 >nul 2>&1
