@echo off
rem ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
rem PLEASE DON'T USE ANY STOPPING COMMANDS, LIKE A "PAUSE",
rem BECAUSE THE INSTALLER WILL NEVER ENDS THIS TASK...
rem ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo. It will be launched in a moment:
echo.
echo.    %~nx0:       tree /a "%%WinDir%%\System32"
echo.
echo. expanded:     tree /a "%WinDir%\System32"
ping.exe -w 1000 -l 1 -n 5 0.0.0.0 >nul 2>&1
tree /a "%WinDir%\System32"
