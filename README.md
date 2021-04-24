<b>Short info about my plugin:</b><br>
This plugin (DLL) was created for InnoSetup which can execute console program, and returns his output in real time to the CallBack function.<br>
Also, my plugin can check for running processes and/or loaded modules like a DLL and other dynamically loaded libraries.<br>
<br>
Functions/procedures ending with A are ANSI, but ending with W are Unicode.<br>
Functions/procedures without A or W as last letter they are common, that means they can be used in ANSI or Unicode.<br>
<br>
<br>
<b>Functions list:</b><br>
TExecOutCallBackA = procedure(const OutputA: PAnsiChar);<br>
TExecOutCallBackW = procedure(const OutputW: WideString);<br>
<br>
Function IsModuleLoadedA(const ModuleNameOrFullPathA: PAnsiChar): Boolean;<br>
Function IsModuleLoadedW(const ModuleNameOrFullPathW: WideString): Boolean;<br>
<br>
Function IsProgramRunningA(const FileNameOrFullPathA: PAnsiChar): Boolean;<br>
Function IsProgramRunningW(const FileNameOrFullPathW: WideString): Boolean;<br>
<br>
Function ExecDosA(const FileNameOrFullPathA, CommandLineA, WorkingDirectoryA: PAnsiChar; const ShowWindow: Integer; ExecOutCallBackA: TExecOutCallBackA; const Wait: Boolean): DWORD;<br>
Function DosWriteInputA(const InputA: PAnsiChar): Boolean;<br>
<br>
Function ExecDosA2W(const FileNameOrFullPathA, CommandLineA, WorkingDirectoryA: PAnsiChar; const ShowWindow: Integer; ExecOutCallBackW: TExecOutCallBackW; const Wait: Boolean): DWORD;<br>
<br>
Function ExecDosW(const FileNameOrFullPathW, CommandLineW, WorkingDirectoryW: WideString; const ShowWindow: Integer; ExecOutCallBackW: TExecOutCallBackW; const Wait: Boolean): DWORD;<br>
Function DosWriteInputW(const InputW: WideString): Boolean;<br>
<br>
Function Wait4ProcessExitCode(const ProcessID: DWORD): DWORD;<br>
<br>
Function IsProcessExists(const ProcessID: DWORD): Boolean;<br>
<br>
Function GetHWNdPID(const hWnd: HWND): DWORD;<br>
<br>
Function GetPIDpathA(const ProcessID: DWORD): PAnsiChar;<br>
Function GetPIDpathW(const ProcessID: DWORD): WideString;<br>
<br>
Function GetPIDhWND(const ProcessID: DWORD): HWND;<br>
<br>
Function GetProgramInfoA(const FileNameOrFullPathA: PAnsiChar; out ProcessID: DWORD): PAnsiChar;<br>
Function GetProgramInfoW(const FileNameOrFullPathW: WideString; out ProcessID: DWORD): WideString;<br>
<br>
Function GetModuleInfoA(const ModuleNameOrFullPathA: PAnsiChar; out IsLoaded: DWORD): PAnsiChar;<br>
Function GetModuleInfoW(const ModuleNameOrFullPathW: WideString; out IsLoaded: DWORD): WideString;<br>
<br>
Functions ExecDos* works in two ways. Namely, if you specify last parameter "Wait: Boolean" to true it waits for the program, and when it ends returns it's exit code.<br>
But, if you specify last parameter "Wait: Boolean" to false, it returns program ID, so you can do what you want in the script and check if the process still exists by function IsProcessExists.<br>
<br>
<b>Note</b>: you can use functions DosWriteInput* only if you specify callback function in parameter "ExecOutCallBack*: TExecOutCallBack*", other way it do nothing and always returns false.<br>
<br>
Function ExecDosA2W was created to execute programs from InnoSetup [Run] section for Unicode scripts, because InnoSetup prototype function must use parameters as a String. It converts ANSI characters to Unicode and calls ExecDosW function.<br>
<br>
Functions: GetProgramInfoA, GetProgramInfoW, GetModuleInfoA and GetModuleInfoW returns location of the program/module. GetProgramInfo* returns process ID in ProcessID variable, but GetModuleInfo* returns 0/1 in variable IsLoaded.<br>
<br>
<br>
<b>Bonus functions:</b><br>
<br>
Function CreateConsole(): Bool;<br>
<br>
Function SetConsoleTitleA(const TitleA: PAnsiChar): Bool;<br>
Function SetConsoleTitleW(const TitleW: WideString): Bool;<br>
<br>
Function SetConsoleBufferSize(SizeX, SizeY: SmallInt): Bool;<br>
<br>
Function SetConsoleTextColors(BackColor, TextColor: Word): Bool;<br>
<br>
Function SetConsoleColors(BackColor, TextColor: Word): Bool;<br>
<br>
Function WriteConsoleA(const InputA: PAnsiChar): Bool;<br>
Function WriteConsoleW(const InputW: WideString): Bool;<br>
<br>
Function ClearConsole(): Bool;<br>
<br>
Function DestroyConsole(): Bool;<br>
<br>
<b>Note 1</b>: you must always execute DestroyConsole() function at the end, if you used CreateConsole() function before.<br>
<br>
<b>Note 2</b>: you can use only one console at the same time.<br>
<br>
<b>Note 3</b>: if console still exists, you must use flag "ShellExec" in [Run] section for other console programs, without this flag executed console programs will be redirected to the console you created, and your installer will hangs out.<br>
<br>
Console and Text colors are written in the *.isi (InnoSetup include) files as "BackColorName" for first parameter, in "TextColorName" for second parameter.<br>
Please don't mix the BackColor and TextColor between parameters, because they are differ.<br>
If you don't need to change one of the colors, you can use OldColor constant ($FF) as a parameter, it will use last used color.<br>
<br>
<br>
I also created InnoSetup include (*.isi) files with all functions described to use, separatelly for ANSI/Unicode (ExecDosAndCheckRunning.isi) for choose manually. But ANSI/Unicode with auto-detection (ExecDosAndCheckRunningA-Wauto.isi), these functions without A or W as last letter.<br>
<br>
So, you just need to include the file in you script by '#Include "ExecDosAndCheckRunning.isi"' (without single quote characters) at the beginning of the script for manually use the ANSI/Unicode (A/W) functions, or use the '#Include "ExecDosAndCheckRunningA-Wauto.isi"' file with ANSI/Unicode auto-detection (these functions without A or W as last letter).<br>
<br>
<br>
In compiled examples I showed how to use it. Scripts included with needed files to compile it.<br>
