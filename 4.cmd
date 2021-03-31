@echo off
rem ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
rem PLEASE DON'T USE ANY STOPPING COMMANDS, LIKE A "PAUSE",
rem BECAUSE THE INSTALLER WILL NEVER ENDS THIS TASK...
rem ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
set /a WaitTime=5
setlocal EnableDelayedExpansion
set str=Please wait
for /l %%W in (1,1,%WaitTime%) do (
	Set Str=!Str!.
	echo !Str!
	ping.exe -w 1000 -l 1 -n 2 0.0.0.0 >nul 2>&1
)
