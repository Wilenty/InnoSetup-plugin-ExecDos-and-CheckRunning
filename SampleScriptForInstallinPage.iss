[Setup]
AppName=My Example Program
AppVersion=1.0
CreateAppDir=no
Uninstallable=no
WizardImageFile=compiler:WizModernImage-IS.bmp
ArchitecturesInstallIn64BitMode=x64
WizardSmallImageFile=compiler:WizModernSmallImage-IS.bmp
DisableWelcomePage=no
PrivilegesRequired=lowest
DisableReadyPage=yes
; for InnoSetup 6+:
WizardResizable=yes
WizardStyle=modern

[Types]
Name: "custom"; Description: "Custom"; Flags: IsCustom;

[Components]
Name: "execute"; Description: "Extract to a ""%tmp%"" and execute from [Files] section via [Code] with output on installing page:";
Name: "execute\a"; Description: "1.cmd (dir %WinDir%)"; Types: custom;
Name: "execute\b"; Description: "2.cmd (Please wait 5s...)"; Types: custom;
Name: "execute\c"; Description: "3.cmd (tree /a %WinDir%\System32)"; Types: custom;
Name: "execute\d"; Description: "4.cmd (Please wait.....)"; Types: custom;

[CustomMessages]
StatusMsg=It's executed from script section [Files] via [Code]:
FilesMsg=	Executing "%1" via "cmd.exe"

[Files]
Source: "ExecDosAndCheckRunning.dll"; DestDir: "{tmp}"; Flags: DontCopy IgnoreVersion;
// explanation of use -=> -=> -=> -=> -=> -=> -=> -=> -=> -=> -=> -=> -=> -=> -=> -=> -=> -=> -=> AfterInstall: ExecDosWithOutputOnInstallingPage('program', 'cmd-line params', 'WorkDir', 'StatusMsg message', 'FilesMsg message'); // Working Dir and both last two messages can be empty
DestDir: "{tmp}"; Source: "1.cmd"; Flags: DeleteAfterInstall IgnoreVersion; Components: "execute\a"; AfterInstall: "ExecDosWithOutputOnInstallingPage('""cmd.exe""', '/c ""{tmp}\1.cmd""', '', '{cm:StatusMsg}', '{cm:FilesMsg,{tmp}\1.cmd}')";
DestDir: "{tmp}"; Source: "2.cmd"; Flags: DeleteAfterInstall IgnoreVersion; Components: "execute\b"; AfterInstall: "ExecDosWithOutputOnInstallingPage('""cmd.exe""', '/c ""{tmp}\2.cmd""', '', '{cm:StatusMsg}', '{cm:FilesMsg,{tmp}\2.cmd}')";
DestDir: "{tmp}"; Source: "3.cmd"; Flags: DeleteAfterInstall IgnoreVersion; Components: "execute\c"; AfterInstall: "ExecDosWithOutputOnInstallingPage('""cmd.exe""', '/c ""{tmp}\3.cmd""', '', '{cm:StatusMsg}', '{cm:FilesMsg,{tmp}\3.cmd}')";
DestDir: "{tmp}"; Source: "4.cmd"; Flags: DeleteAfterInstall IgnoreVersion; Components: "execute\d"; AfterInstall: "ExecDosWithOutputOnInstallingPage('""cmd.exe""', '/c ""{tmp}\4.cmd""', '', '{cm:StatusMsg}', '{cm:FilesMsg,{tmp}\4.cmd}')";

[Code]
type
  TExecDosCallBack = procedure(DosProgram, Params, Output: PAnsiChar);

Function ExecDos(FileNameOrFullPath, CommandLine, WorkingDirectory: PAnsiChar; const ShowWindow: Integer; CallBack: TExecDosCallBack): DWORD;
  external 'ExecDos@files:ExecDosAndCheckRunning.dll stdcall';

// this part of [code] was taken from there:
// https://stackoverflow.com/a/32266687
Type
  TMsg = record
    hwnd: HWND;
    message: UINT;
    wParam: Longint;
    lParam: Longint;
    time: DWORD;
    pt: TPoint;
  end;

function PeekMessage(var lpMsg: TMsg; hWnd: HWND; wMsgFilterMin, wMsgFilterMax, wRemoveMsg: UINT): BOOL;
  external 'PeekMessageA@user32.dll stdcall';
function TranslateMessage(const lpMsg: TMsg): BOOL;
  external 'TranslateMessage@user32.dll stdcall';
function DispatchMessage(const lpMsg: TMsg): Longint;
  external 'DispatchMessageA@user32.dll stdcall';

const
  PM_REMOVE = 1;

procedure AppProcessMessages();
  var
    Msg: TMsg;
  begin
    while PeekMessage(Msg, 0, 0, 0, PM_REMOVE) do
    begin
      TranslateMessage(Msg);
      DispatchMessage(Msg);
    end;
end;
// ^_^

Var
  InstallingListBox: TListBox;

Procedure ListBoxWrite(ListBox: TListBox; Str: String);
  begin
    ListBox.Items.Insert(0, Str);
    AppProcessMessages();
end;

procedure InstallingCallBack(DosProgram, Params, Output: PAnsiChar);
  begin
    ListBoxWrite(InstallingListBox, Output);
end;

Function ExpandScript(Str: String): String;
  begin
    If (Pos('{', Str) > 0) and (Pos('}', Str) > 0) then
      Result := ExpandConstant(Str)
    else
      Result := Str;
end;

Procedure ExecDosWithOutputOnInstallingPage(const FileNameOrFullPath, Params, WorkDir, StatusMsg, FilesMsg: String);
  Var
    Int, ExitCode: Integer;
    Str: String;
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

    With InstallingListBox.Items do
    begin
      ExitCode := ExecDos( ExpandScript(FileNameOrFullPath), ExpandScript(Params), ExpandScript(WorkDir), SW_HIDE, @InstallingCallBack );
      For Int := 0 to 30 do
        Str := Str + '-=';
      Str := Str + '-';
      Insert(0, Str);
      Insert(0,  'ExitCode: ' + IntToStr(ExitCode) + ', ' + SysErrorMessage(ExitCode) );
      Insert(0, Str);
    end; // InstallingListBox.Lines.
end;

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

Procedure InitializeWizard();
  Var
    Str: String;
    PID: Cardinal;
    ProcessOrDLL: String;
    Int: Integer;
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

      With ComponentsList do
      begin
        ShowHint := True;
        Hint := 'In this script there is no the [Run] section';
      end; // ComponentsList.
    end; // WizardForm.
end;

procedure CurPageChanged(CurPageID: Integer);
  begin
    With WizardForm do
    begin
      NextButton.Hint := '';
      BackButton.Hint := '';
      If CurPageID = wpSelectComponents then
      begin
        NextButton.Hint := ComponentsList.Hint;
        NextButton.Caption := FmtMessage( CustomMessage('LaunchProgram'), [''] );
      end;
    end; // WizardForm.
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
