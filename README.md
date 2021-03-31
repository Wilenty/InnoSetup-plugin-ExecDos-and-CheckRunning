<b>Short info about my plugin:</b><br>
This plugin (DLL) was created for InnoSetup which can execute console program, and returns his output in real time to the CallBack function.<br>
Also, my plugin can check for running processes and/or loaded modules like a DLL and other dynamically loaded libraries.<br>
<br>
I created/compiled also Unicode version, which uses WideString's, but it does not work with InnoSetup script like the ANSI version, so, I placed it in separate folder.<br>
<br>
<b>ANSI functions included in the plugin</b>:<br>
  TExecDosCallBack = procedure(DosProgram, Params, Output: PAnsiChar);<br>
Function IsModuleLoaded(ModuleNameOrFullPath: PAnsiChar): Boolean;<br>
Function IsProcessRunning(FileNameOrFullPath: PAnsiChar): Boolean;<br>
Function ExecDos(FileNameOrFullPath, CommandLine, WorkingDirectory: PAnsiChar; const ShowWindow: Integer; CallBack: TExecDosCallBack): DWORD;<br>
Function GetHWndPID(const hWnd: HWND): DWORD;<br>
Function GetPIDpath(const PID: DWORD): PAnsiChar;<br>
Function GetPIDhWnd(const PID: DWORD): HWND;<br>
Function ProcessGetInfo(FileNameOrFullPath: PAnsiChar; out PID: DWORD): PAnsiChar;<br>
Function ModuleGetInfo(ModuleNameOrFullPath: PAnsiChar; out IsLoaded: DWORD): PAnsiChar;<br>
<br>
<font color=red><b>Unicode functions do not work from InnoSetup script, but they works excellent with InnoSetup [Code]. So, I decided to place them in separate plugin (DLL) and share separate Unicode version with this note.</font></b><br>
<br>
<b>Unicode functions included in the separate plugin</b> (because they don't fully work with InnoSetup script):<br>
  TExecDosCallBackW = procedure(DosProgram, Params, Output: WideString);<br>
Function IsModuleLoadedW(ModuleNameOrFullPath: WideString): Boolean;<br>
Function IsProcessRunningW(FileNameOrFullPath: WideString): Boolean;<br>
Function ExecDosW(FileNameOrFullPath, CommandLine, WorkingDirectory: WideString; const ShowWindow: Integer; CallBack: TExecDosCallBackW): DWORD;<br>
Function GetHWndPID(const hWnd: HWND): DWORD;<br>
Function GetPIDpathW(const PID: DWORD): WideString;<br>
Function GetPIDhWnd(const PID: DWORD): HWND;<br>
Function ProcessGetInfoW(FileNameOrFullPath: WideString; out PID: DWORD): WideString;<br>
Function ModuleGetInfoW(ModuleNameOrFullPath: WideString; out IsLoaded: DWORD): WideString;<br>
<br>
Functions: ProcessGetInfo, ProcessGetInfoW, ModuleGetInfo and ModuleGetInfoW returns location of the program/module. ProcessGetInfo* returns process ID in PID variable, but ModuleGetInfo* returns 0/1 in variable IsLoaded.<br>
<br>
In compiled example I showed how to use it. Scripts included with needed files to compile it.<br>
