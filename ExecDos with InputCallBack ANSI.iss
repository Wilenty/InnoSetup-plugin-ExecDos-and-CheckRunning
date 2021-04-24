[Setup]
AppName=ExecDos with InputCallBack ANSI
AppVersion=1.0
CreateAppDir=no
Uninstallable=no
WizardImageFile=compiler:WizModernImage-IS.bmp
ArchitecturesInstallIn64BitMode=x64
WizardSmallImageFile=compiler:WizModernSmallImage-IS.bmp
DisableWelcomePage=no
PrivilegesRequired=lowest
DisableReadyPage=yes
OutputBaseFilename=ExecDos with InputCallBack ANSI
; for InnoSetup 6+:
WizardResizable=yes
WizardStyle=modern

#Include "ExecDosAndCheckRunning.isi"

[Types]
Name: "custom"; Description: "Custom"; Flags: IsCustom;

[Components]
Name: "execute"; Description: "Extract to a ""%tmp%"" and execute from [Files] section via [Code] with output on installing page:";
Name: "execute\a"; Description: "1.cmd (dir %WinDir%)"; Types: custom;
Name: "execute\b"; Description: "2.cmd (ping.exe -w 1000 -l 1 -n 5 0.0.0.0)"; Types: custom;
Name: "execute\c"; Description: "3.cmd (tree /a %WinDir%\System32)"; Types: custom;
Name: "execute\d"; Description: "4.cmd (Please wait.....)"; Types: custom;

[CustomMessages]
StatusMsg=It's executed from script section [Files] via [Code]:
FilesMsg=	Executing "%1" via "InputCallBackA"

[Files]
// explanation of use -=> -=> -=> -=> -=> -=> -=> -=> -=> -=> -=> -=> -=> -=> -=> -=> -=> -=> -=> AfterInstall: WriteInputCallBackA('cmd-line params', 'StatusMsg message', 'FilesMsg message'); // both last two messages can be empty
DestDir: "{tmp}"; Source: "1.cmd"; Flags: DeleteAfterInstall IgnoreVersion; Components: "execute\a"; AfterInstall: "WriteInputCallBackA('""{tmp}\1.cmd""', '{cm:StatusMsg}', '{cm:FilesMsg,{tmp}\1.cmd}')";
DestDir: "{tmp}"; Source: "2.cmd"; Flags: DeleteAfterInstall IgnoreVersion; Components: "execute\b"; AfterInstall: "WriteInputCallBackA('""{tmp}\2.cmd""', '{cm:StatusMsg}', '{cm:FilesMsg,{tmp}\2.cmd}')";
DestDir: "{tmp}"; Source: "3.cmd"; Flags: DeleteAfterInstall IgnoreVersion; Components: "execute\c"; AfterInstall: "WriteInputCallBackA('""{tmp}\3.cmd""', '{cm:StatusMsg}', '{cm:FilesMsg,{tmp}\3.cmd}')";
DestDir: "{tmp}"; Source: "4.cmd"; Flags: DeleteAfterInstall IgnoreVersion; Components: "execute\d"; AfterInstall: "WriteInputCallBackA('""{tmp}\4.cmd""', '{cm:StatusMsg}', '{cm:FilesMsg,{tmp}\4.cmd}')";

[Code]
// for InnoSetup 6.05 Extended Edition -> https://wilenty.wixsite.com/SoftwareByWilenty/inno-setup-xp-ee-script-studio-port
Function InitializeSetup(): Boolean;
  begin
    With TApplication.Create(nil) do
    begin
      HintPause := 0;
      HintHidePause := 1000 * 30;// 30s
      HintShortPause := 0;
      Free;
    end; // TApplication.Create(nil).
    Result := True;
end;
// ^_^

Var
  InstallingListBox: TListBox;

Procedure InitializeWizard();
  begin
    With WizardForm do
    begin
      InstallingListBox := TListBox.Create(InstallingPage);
      With InstallingListBox do
      begin
        Parent := InstallingPage;
        Left := 0;
        Top := ProgressGauge.Top + ProgressGauge.Height + ScaleY(5);
        Width := InstallingPage.ClientWidth;
        Height := InstallingPage.ClientHeight - Top;
        Color := clBlack;
        With Font do
        begin
          Color := clLtGray;
          Style := Style + [fsBold];
        end; // Font.
        // for InnoSetup 6+:
        Anchors := [akLeft, akTop, akRight, akBottom];
      end; // InstallingListBox.

      With BackButton do
      begin
        Left := Left - Width;
        ShowHint := True;
      end; // BackButton.

      With NextButton do
      begin
        Left := Left - Width;
        Width := Width + Width;
        ShowHint := True;
      end; // NextButton.

    end; // WizardForm.
end;

Procedure ListBoxWrite(ListBox: TListBox; Str: String);
  begin
    ListBox.Items.Insert(0, Str);
    AppProcessMessagesA();
end;

procedure InstallingCallBackA(const OutputA: PAnsiChar);
  begin
    ListBoxWrite(InstallingListBox, OutputA);
end;
Function GetWindowTextA(hWnd: HWND; lpStringA: AnsiString; nMaxCount: Integer): Integer;
  External 'GetWindowTextA@User32.dll stdcall';

Function EnumWindowsProcA(hwnd: HWND; strParamA: String): BOOL;
  Var
    WindowTitle: AnsiString;
    Int: Integer;
  begin
    Result := True;
    Int := 1024;
    SetLength(WindowTitle, Int);
    Int := GetWindowTextA( HWND, WindowTitle, Int );
    If Int = 0 then
      exit;
    Delete( WindowTitle, Int+1, Length(WindowTitle) );
    If Pos( strParamA, WindowTitle ) > 0 then
      Result := False;
end;

Var
  EnumWindowsProcCallBack: LongWord;

Function EnumWindows(lpEnumFunc: LongWord; sParam: String): BOOL;
  External 'EnumWindows@User32.dll stdcall';

Function ExpandScript(Str: String): String;
  begin
    If (Pos('{', Str) > 0) and (Pos('}', Str) > 0) then
      Result := ExpandConstant(Str)
    else
      Result := Str;
end;

Procedure WriteInputCallBackA(Params, StatusMsg, FilesMsg: String);
  Var
    ParamsStr: String;
  begin
    With WizardForm do
    begin
      Update;
      Repaint;
      With InstallingPage do
      begin
        StatusLabel.Caption := ExpandScript(StatusMsg);
        FilenameLabel.Caption := ExpandScript(FilesMsg);
      end; // InstallingPage.
    end; // WizardForm.

    ParamsStr := ExpandScript(Params);
    If DosWriteInputA( ParamsStr ) then
      Repeat
        AppProcessMessagesA();
        Sleep(50);
      Until EnumWindows( EnumWindowsProcCallBack, ParamsStr );
end;

Var
  ProcessID: DWORD;
  ProcessExitCode: DWORD;

procedure CurStepChanged(CurStep: TSetupStep);
  begin
    If CurStep = ssInstall then
    begin
      EnumWindowsProcCallBack := CreateCallback(@EnumWindowsProcA);
      ProcessID := ExecDosA('cmd.exe', '/k echo off&cls', '', SW_SHOWMINNOACTIVE, @InstallingCallBackA, False);
      WizardForm.Caption := Format('"cmd.exe" ProcessID: %d', [ProcessID]);
      While GetPIDhWND(ProcessID) = 0 do
        Sleep(250);
    end;
    If CurStep = ssPostInstall then
    begin
      WriteInputCallBackA( 'exit /b %ErrorLevel%', 'Exiting the console program...', #9#9'bye, bye, see you next time. ;-)' );
      ProcessExitCode := Wait4ProcessExitCode(ProcessID);
    end;
end;

procedure CurPageChanged(CurPageID: Integer);
  begin
    If CurPageID = wpSelectComponents then
      WizardForm.NextButton.Caption := FmtMessage( CustomMessage('LaunchProgram'), [''] );
    If CurPageID = wpFinished then
    begin
      MsgBox( Format('ProcessID: %d' + #13#10 + 'ExitCode: %d ($%x)', [ProcessID, ProcessExitCode, ProcessExitCode]), mbInformation, MB_OK );
    end;
end;

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "afrikaans"; MessagesFile: "compiler:Languages\Afrikaans.isl"
Name: "albanian"; MessagesFile: "compiler:Languages\Albanian.isl"
Name: "arabic"; MessagesFile: "compiler:Languages\Arabic.islu"
Name: "armenian"; MessagesFile: "compiler:Languages\Armenian.islu"
Name: "asturian"; MessagesFile: "compiler:Languages\Asturian.isl"
Name: "basque"; MessagesFile: "compiler:Languages\Basque.isl"
Name: "belarusian"; MessagesFile: "compiler:Languages\Belarusian.isl"
Name: "bengali"; MessagesFile: "compiler:Languages\Bengali.islu"
Name: "bosnian"; MessagesFile: "compiler:Languages\Bosnian.isl"
Name: "brazilianportuguese"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"
Name: "bulgarian"; MessagesFile: "compiler:Languages\Bulgarian.islu"
Name: "catalan"; MessagesFile: "compiler:Languages\Catalan.isl"
Name: "chinesesimplified"; MessagesFile: "compiler:Languages\ChineseSimplified.islu"
Name: "chinesetraditional"; MessagesFile: "compiler:Languages\ChineseTraditional.islu"
Name: "corsican"; MessagesFile: "compiler:Languages\Corsican.islu"
Name: "croatian"; MessagesFile: "compiler:Languages\Croatian.islu"
Name: "czech"; MessagesFile: "compiler:Languages\Czech.isl"
Name: "danish"; MessagesFile: "compiler:Languages\Danish.isl"
Name: "dutch"; MessagesFile: "compiler:Languages\Dutch.islu"
Name: "englishbritish"; MessagesFile: "compiler:Languages\EnglishBritish.isl"
Name: "esperanto"; MessagesFile: "compiler:Languages\Esperanto.isl"
Name: "estonian"; MessagesFile: "compiler:Languages\Estonian.isl"
Name: "farsi"; MessagesFile: "compiler:Languages\Farsi.isl"
Name: "finnish"; MessagesFile: "compiler:Languages\Finnish.isl"
Name: "french"; MessagesFile: "compiler:Languages\French.islu"
Name: "galician"; MessagesFile: "compiler:Languages\Galician.islu"
Name: "georgian"; MessagesFile: "compiler:Languages\Georgian.islu"
Name: "german"; MessagesFile: "compiler:Languages\German.islu"
Name: "greek"; MessagesFile: "compiler:Languages\Greek.islu"
Name: "hebrew"; MessagesFile: "compiler:Languages\Hebrew.isl"
Name: "hindi"; MessagesFile: "compiler:Languages\Hindi.islu"
Name: "hungarian"; MessagesFile: "compiler:Languages\Hungarian.isl"
Name: "icelandic"; MessagesFile: "compiler:Languages\Icelandic.islu"
Name: "indonesian"; MessagesFile: "compiler:Languages\Indonesian.islu"
Name: "italian"; MessagesFile: "compiler:Languages\Italian.islu"
Name: "japanese"; MessagesFile: "compiler:Languages\Japanese.isl"
Name: "kazakh"; MessagesFile: "compiler:Languages\Kazakh.islu"
Name: "korean"; MessagesFile: "compiler:Languages\Korean.isl"
Name: "kurdish"; MessagesFile: "compiler:Languages\Kurdish.isl"
Name: "latvian"; MessagesFile: "compiler:Languages\Latvian.isl"
Name: "ligurian"; MessagesFile: "compiler:Languages\Ligurian.isl"
Name: "lithuanian"; MessagesFile: "compiler:Languages\Lithuanian.isl"
Name: "luxemburgish"; MessagesFile: "compiler:Languages\Luxemburgish.isl"
Name: "macedonian"; MessagesFile: "compiler:Languages\Macedonian.isl"
Name: "malaysian"; MessagesFile: "compiler:Languages\Malaysian.isl"
Name: "marathi"; MessagesFile: "compiler:Languages\Marathi.islu"
Name: "mongolian"; MessagesFile: "compiler:Languages\Mongolian.isl"
Name: "montenegrian"; MessagesFile: "compiler:Languages\Montenegrian.isl"
Name: "nepali"; MessagesFile: "compiler:Languages\Nepali.islu"
Name: "norwegian"; MessagesFile: "compiler:Languages\Norwegian.isl"
Name: "norwegiannynorsk"; MessagesFile: "compiler:Languages\NorwegianNynorsk.isl"
Name: "occitan"; MessagesFile: "compiler:Languages\Occitan.isl"
Name: "persian"; MessagesFile: "compiler:Languages\Persian.isl"
Name: "polish"; MessagesFile: "compiler:Languages\Polish.isl"
Name: "portuguese"; MessagesFile: "compiler:Languages\Portuguese.isl"
Name: "romanian"; MessagesFile: "compiler:Languages\Romanian.isl"
Name: "russian"; MessagesFile: "compiler:Languages\Russian.isl"
Name: "scottishgaelic"; MessagesFile: "compiler:Languages\ScottishGaelic.islu"
Name: "serbiancyrillic"; MessagesFile: "compiler:Languages\SerbianCyrillic.isl"
Name: "serbianlatin"; MessagesFile: "compiler:Languages\SerbianLatin.isl"
Name: "sinhala"; MessagesFile: "compiler:Languages\Sinhala.islu"
Name: "slovak"; MessagesFile: "compiler:Languages\Slovak.isl"
Name: "slovenian"; MessagesFile: "compiler:Languages\Slovenian.isl"
Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"
Name: "swedish"; MessagesFile: "compiler:Languages\Swedish.isl"
Name: "tatar"; MessagesFile: "compiler:Languages\Tatar.isl"
Name: "thai"; MessagesFile: "compiler:Languages\Thai.isl"
Name: "turkish"; MessagesFile: "compiler:Languages\Turkish.isl"
Name: "ukrainian"; MessagesFile: "compiler:Languages\Ukrainian.isl"
Name: "uyghur"; MessagesFile: "compiler:Languages\Uyghur.islu"
Name: "uzbek"; MessagesFile: "compiler:Languages\Uzbek.isl"
Name: "valencian"; MessagesFile: "compiler:Languages\Valencian.isl"
Name: "vietnamese"; MessagesFile: "compiler:Languages\Vietnamese.islu"
