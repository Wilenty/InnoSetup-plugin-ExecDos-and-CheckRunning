[Setup]
AppName=CreateDebugConsole 2 A-W Auto
AppVersion=1.0
DefaultDirName={tmp}
DirExistsWarning=no
Uninstallable=no
WizardImageFile=compiler:WizModernImage-IS.bmp
ArchitecturesInstallIn64BitMode=x64
WizardSmallImageFile=compiler:WizModernSmallImage-IS.bmp
DisableWelcomePage=no
PrivilegesRequired=lowest
OutputBaseFilename=CreateDebugConsole 2 A-W Auto
UserInfoPage=yes
; for InnoSetup 6+:
WizardResizable=yes
WizardStyle=modern
WizardSizePercent=100

[Components]
Name: "a"; Description: "1"; Types: "full";
Name: "b"; Description: "2"; Types: "compact";
Name: "c"; Description: "3"; Types: "custom";

[Tasks]
Name: "a"; Description: "1"; Flags: unchecked;
Name: "b"; Description: "2"; Flags: unchecked;
Name: "c"; Description: "3";

[Run]
// When internal (debug) console are created you must use the "ShellExec" flag for console apps,
//  without this flag it will be created in internal (debug) console, and the installer will stops here.
Filename: "{sys}\cmd.exe"; Description: "{cm:LaunchProgram,cmd.exe}"; Flags: ShellExec PostInstall RunAsCurrentUser SkipIfDoesNtExist SkipIfSilent Unchecked NoWait
Filename: "{sys}\calc.exe"; Description: "{cm:LaunchProgram,calc.exe}"; Flags: ShellExec PostInstall RunAsCurrentUser SkipIfDoesNtExist SkipIfSilent Unchecked NoWait
Filename: "{sys}\mspaint.exe"; Description: "{cm:LaunchProgram,mspaint.exe}"; Flags: ShellExec PostInstall RunAsCurrentUser SkipIfDoesNtExist SkipIfSilent Unchecked NoWait
Filename: "{sys}\notepad.exe"; Description: "{cm:LaunchProgram,notepad.exe}"; Flags: ShellExec PostInstall RunAsCurrentUser SkipIfDoesNtExist SkipIfSilent Unchecked NoWait

#Include "ExecDosAndCheckRunningA-Wauto.isi"

[Code]
Function Bool2Str(FalseTrue: Boolean): String;
  begin
    If FalseTrue then
      Result := 'True'
    else
      Result := 'False';
end;

// for InnoSetup 6.05 Extended Edition -> https://wilenty.wixsite.com/SoftwareByWilenty/inno-setup-xp-ee-script-studio-port
Function InitializeSetup(): Boolean;
  begin
    if ExpandConstant('{param:debug|0}') = '1' then
      CreateConsole();
    ConsoleWriteLine('');
    ConsoleWriteLine('FUNC: InitializeSetup(): Boolean;');
    ConsoleWriteLine(#9'debug console created!');
    ConsoleWriteLine(#9'setting THIS console title...');
    SetConsoleTitle('!!! Please don''t close this debug window, because you will KILL the INSTALLER !!!');
    ConsoleWriteLine(#9'setting THIS console text colors...');
    SetConsoleTextColors(BackGreen, TextYellow);
    ConsoleWriteLine(#9'setting THIS console colors...');
    SetConsoleColors(OldColor, OldColor);
    ConsoleWriteLine(#9'creating TApplication...');
    With TApplication.Create(nil) do
    begin
      ConsoleWriteLine(#9'setting: HintPause');
      HintPause := 0;
      ConsoleWriteLine(#9'setting: HintHidePause');
      HintHidePause := 1000 * 30;// 30s
      ConsoleWriteLine(#9'setting: HintShortPause');
      HintShortPause := 0;
      ConsoleWriteLine(#9'free the TApplication...');
      Free;
    end; // TApplication.Create(nil).
    Result := True;
    ConsoleWriteLine(#9'returning '+Bool2Str(Result)+'!');
    ConsoleWriteLine('leaving InitializeSetup()...');
    ConsoleWriteLine('');
end;
// ^_^

Var
  OldTypesComboOnChangeEvent: TNotifyEvent;

Procedure TypesComboOnChange(Sender: TObject);
  begin
    ConsoleWriteLine('PROC: TypesComboOnChange(Sender: TObject);');
    If OldTypesComboOnChangeEvent <> nil then
    begin
      ConsoleWriteLine(#9'calling: OldTypesComboOnChangeEvent(Sender)...');
      OldTypesComboOnChangeEvent(Sender);
    end;
    ConsoleWriteLine(#9'Type (name; desc): ' + WizardSetupType(false) + '; ' + WizardSetupType(True) );
    ConsoleWriteLine('leaving TypesComboOnChange(Sender: TObject)...');
    ConsoleWriteLine('');
end;

Var
  OldComponentsOnClickCheckEvent: TNotifyEvent;

Procedure ComponentsOnClickCheck(Sender: TObject);
  begin
    ConsoleWriteLine('PROC: ComponentsOnClickCheck(Sender: TObject);');
    If OldComponentsOnClickCheckEvent <> nil then
    begin
      ConsoleWriteLine(#9'calling: OldComponentsOnClickCheckEvent(Sender)...');
      OldComponentsOnClickCheckEvent(Sender);
    end;
    ConsoleWriteLine(#9'Components (name{s}; desc{s}): ' + WizardSelectedComponents(false) + '; ' + WizardSelectedComponents(True) );
    ConsoleWriteLine('leaving ComponentsOnClickCheck(Sender: TObject)...');
    ConsoleWriteLine('');
end;

Var
  OldTasksOnClickCheckEvent: TNotifyEvent;

Procedure TasksOnClickCheck(Sender: TObject);
  begin
    ConsoleWriteLine('PROC: TasksOnClickCheck(Sender: TObject);');
    If OldTasksOnClickCheckEvent <> nil then
    begin
      ConsoleWriteLine(#9'calling: OldTasksOnClickCheckEvent(Sender)...');
      OldTasksOnClickCheckEvent(Sender);
    end;
    ConsoleWriteLine(#9'Tasks (name{s}; desc{s}): ' + WizardSelectedTasks(false) + '; ' + WizardSelectedTasks(True) );
    ConsoleWriteLine('leaving TasksOnClickCheck(Sender: TObject)...');
    ConsoleWriteLine('');
end;

Var
  OldRunListOnClickCheckEvent: TNotifyEvent;

Procedure RunListOnClickCheck(Sender: TObject);
  Var
    Str: String;
    Int: Integer;
  begin
    ConsoleWriteLine('PROC: RunListOnClickCheck(Sender: TObject);');
    If OldRunListOnClickCheckEvent <> nil then
    begin
      ConsoleWriteLine(#9'calling: OldRunListOnClickCheckEvent(Sender)...');
      OldRunListOnClickCheckEvent(Sender);
    end;
    With WizardForm.RunList do
      For Int := 0 to Items.Count-1 do
        If Checked[Int] then
          Str := Str + ItemCaption[Int] + ', ';
    ConsoleWriteLine(#9'RunList (desc{s}): ' + Str );
    ConsoleWriteLine('leaving RunListOnClickCheck(Sender: TObject)...');
    ConsoleWriteLine('');
end;

Procedure InitializeWizard();
  begin
    ConsoleWriteLine('PROC: InitializeWizard();');
    ConsoleWriteLine(#9'taking WizardForm...');
    With WizardForm do
    begin

      ConsoleWriteLine(#9'taking BackButton...');
      With BackButton do
      begin
        ConsoleWriteLine(#9'setting: BackButton left');
        Left := Left - Width;
        ConsoleWriteLine(#9'setting: BackButton ShowHint');
        ShowHint := True;
        ConsoleWriteLine(#9'leaving BackButton...');
      end; // BackButton.

      ConsoleWriteLine(#9'taking NextButton...');
      With NextButton do
      begin
        ConsoleWriteLine(#9'setting: NextButton left');
        Left := Left - Width;
        ConsoleWriteLine(#9'setting: NextButton Width');
        Width := Width + Width;
        ConsoleWriteLine(#9'setting: NextButton ShowHint');
        ShowHint := True;
        ConsoleWriteLine(#9'leaving NextButton...');
      end; // NextButton.

      ConsoleWriteLine(#9'taking TypesCombo...');
      With TypesCombo do
      begin
        ConsoleWriteLine(#9'setting: OldComponentsOnClickCheckEvent');
        OldTypesComboOnChangeEvent := OnChange;
        ConsoleWriteLine(#9'setting: OnChange');
        OnChange := @TypesComboOnChange;
        ConsoleWriteLine(#9'leaving TypesCombo...');
      end;

      ConsoleWriteLine(#9'taking ComponentsList...');
      With ComponentsList do
      begin
        ConsoleWriteLine(#9'setting: OldComponentsOnClickCheckEvent');
        OldComponentsOnClickCheckEvent := OnClickCheck;
        ConsoleWriteLine(#9'setting: OnClickCheck');
        OnClickCheck := @ComponentsOnClickCheck;
        ConsoleWriteLine(#9'leaving ComponentsList...');
      end;

      ConsoleWriteLine(#9'taking TasksList...');
      With TasksList do
      begin
        ConsoleWriteLine(#9'setting: OldTasksOnClickCheckEvent');
        OldTasksOnClickCheckEvent := OnClickCheck;
        ConsoleWriteLine(#9'setting: OnClickCheck');
        OnClickCheck := @TasksOnClickCheck;
        ConsoleWriteLine(#9'leaving TasksList...');
      end;

      ConsoleWriteLine(#9'taking RunList...');
      With RunList do
      begin
        ConsoleWriteLine(#9'setting: OldRunListOnClickCheckEvent');
        OldRunListOnClickCheckEvent := OnClickCheck;
        ConsoleWriteLine(#9'setting: OnClickCheck');
        OnClickCheck := @RunListOnClickCheck;
        ConsoleWriteLine(#9'leaving RunList...');
      end;

      ConsoleWriteLine(#9'removing: UserInfoNameEdit.OnChange');
      UserInfoNameEdit.OnChange := nil;
      ConsoleWriteLine(#9'removing: UserInfoOrgEdit.OnChange');
      UserInfoOrgEdit.OnChange := nil;

      ConsoleWriteLine(#9'leaving WizardForm...');
    end; // WizardForm.
    ConsoleWriteLine('leaving InitializeWizard()...');
    ConsoleWriteLine('');
end;

function CheckPassword(Password: String): Boolean;
  Var
    PW: String;
  begin
    ConsoleWriteLine('FUNC: CheckPassword(Password: "'+Password+'"): Boolean;');
    PW := '123987';
    Result := Password = PW;
    If Result then
      ConsoleWriteLine(#9'returning '+Bool2Str(Result)+'!')
    else
    begin
      SetConsoleTextColors(BackRed, OldColor);
      ConsoleWriteLine(#9'Password is: ' + PW);
      SetConsoleTextColors(BackGreen, OldColor);
    end;
    ConsoleWriteLine('leaving CheckPassword(Password: String)...');
    ConsoleWriteLine('');
end;

function CheckSerial(Serial: String): Boolean;
  Var
    SN: String;
  begin
    ConsoleWriteLine('FUNC: CheckSerial(Serial: "'+Serial+'"): Boolean;');
    SN := '789321';
    Result := Serial = SN;
    If Result then
      ConsoleWriteLine(#9'returning '+Bool2Str(Result)+'!')
    else
    begin
      SetConsoleTextColors(BackRed, OldColor);
      ConsoleWriteLine(#9'Serial is: ' + SN);
      SetConsoleTextColors(BackGreen, OldColor);
    end;
    ConsoleWriteLine('leaving CheckSerial(Serial: String)...');
    ConsoleWriteLine('');
end;

function NextButtonClick(CurPageID: Integer): Boolean;
  begin
    ClearConsole();
    ConsoleWriteLine('');
    ConsoleWriteLine('FUNC: NextButtonClick(CurPageID: "'+IntToStr(CurPageID)+'"): Boolean;');
    If CurPageID = wpWelcome then
      ConsoleWriteLine(#9'CurPageID: wpWelcome');
    If CurPageID = wpLicense then
      ConsoleWriteLine(#9'CurPageID: wpLicense');
    If CurPageID = wpPassword then
      ConsoleWriteLine(#9'CurPageID: wpPassword');
    If CurPageID = wpInfoBefore then
      ConsoleWriteLine(#9'CurPageID: wpInfoBefore');
    If CurPageID = wpUserInfo then
      ConsoleWriteLine(#9'CurPageID: wpUserInfo');
    If CurPageID = wpSelectDir then
      ConsoleWriteLine(#9'CurPageID: wpSelectDir');
    If CurPageID = wpSelectComponents then
      ConsoleWriteLine(#9'CurPageID: wpSelectComponents');
    If CurPageID = wpSelectProgramGroup then
      ConsoleWriteLine(#9'CurPageID: wpSelectProgramGroup');
    If CurPageID = wpSelectTasks then
      ConsoleWriteLine(#9'CurPageID: wpSelectTasks');
    If CurPageID = wpReady then
      ConsoleWriteLine(#9'CurPageID: wpReady');
    If CurPageID = wpPreparing then
      ConsoleWriteLine(#9'CurPageID: wpPreparing');
    If CurPageID = wpInstalling then
      ConsoleWriteLine(#9'CurPageID: wpInstalling');
    If CurPageID = wpInfoAfter then
      ConsoleWriteLine(#9'CurPageID: wpInfoAfter');
    If CurPageID = wpFinished then
      ConsoleWriteLine(#9'CurPageID: wpFinished');
    Result := True;
    ConsoleWriteLine(#9'returning '+Bool2Str(Result)+'!');
    ConsoleWriteLine('leaving NextButtonClick(CurPageID: Integer)...');
    ConsoleWriteLine('');
end;

function BackButtonClick(CurPageID: Integer): Boolean;
  begin
    ClearConsole();
    ConsoleWriteLine('');
    ConsoleWriteLine('FUNC: BackButtonClick(CurPageID: "'+IntToStr(CurPageID)+'"): Boolean;');
    If CurPageID = wpWelcome then
      ConsoleWriteLine(#9'CurPageID: wpWelcome');
    If CurPageID = wpLicense then
      ConsoleWriteLine(#9'CurPageID: wpLicense');
    If CurPageID = wpPassword then
      ConsoleWriteLine(#9'CurPageID: wpPassword');
    If CurPageID = wpInfoBefore then
      ConsoleWriteLine(#9'CurPageID: wpInfoBefore');
    If CurPageID = wpUserInfo then
      ConsoleWriteLine(#9'CurPageID: wpUserInfo');
    If CurPageID = wpSelectDir then
      ConsoleWriteLine(#9'CurPageID: wpSelectDir');
    If CurPageID = wpSelectComponents then
      ConsoleWriteLine(#9'CurPageID: wpSelectComponents');
    If CurPageID = wpSelectProgramGroup then
      ConsoleWriteLine(#9'CurPageID: wpSelectProgramGroup');
    If CurPageID = wpSelectTasks then
      ConsoleWriteLine(#9'CurPageID: wpSelectTasks');
    If CurPageID = wpReady then
      ConsoleWriteLine(#9'CurPageID: wpReady');
    If CurPageID = wpPreparing then
      ConsoleWriteLine(#9'CurPageID: wpPreparing');
    If CurPageID = wpInstalling then
      ConsoleWriteLine(#9'CurPageID: wpInstalling');
    If CurPageID = wpInfoAfter then
      ConsoleWriteLine(#9'CurPageID: wpInfoAfter');
    If CurPageID = wpFinished then
      ConsoleWriteLine(#9'CurPageID: wpFinished');
    Result := True;
    ConsoleWriteLine(#9'returning '+Bool2Str(Result)+'!');
    ConsoleWriteLine('leaving BackButtonClick(CurPageID: Integer)...');
    ConsoleWriteLine('');
end;

procedure CancelButtonClick(CurPageID: Integer; var Cancel: Boolean; var Confirm: Boolean);
  begin
    ClearConsole();
    ConsoleWriteLine('');
    ConsoleWriteLine('PROC: CancelButtonClick(CurPageID: "'+IntToStr(CurPageID)+'"; var Cancel: '+Bool2Str(Cancel)+'; var Confirm: '+Bool2Str(Confirm)+');');
    If CurPageID = wpWelcome then
      ConsoleWriteLine(#9'CurPageID: wpWelcome');
    If CurPageID = wpLicense then
      ConsoleWriteLine(#9'CurPageID: wpLicense');
    If CurPageID = wpPassword then
      ConsoleWriteLine(#9'CurPageID: wpPassword');
    If CurPageID = wpInfoBefore then
      ConsoleWriteLine(#9'CurPageID: wpInfoBefore');
    If CurPageID = wpUserInfo then
      ConsoleWriteLine(#9'CurPageID: wpUserInfo');
    If CurPageID = wpSelectDir then
      ConsoleWriteLine(#9'CurPageID: wpSelectDir');
    If CurPageID = wpSelectComponents then
      ConsoleWriteLine(#9'CurPageID: wpSelectComponents');
    If CurPageID = wpSelectProgramGroup then
      ConsoleWriteLine(#9'CurPageID: wpSelectProgramGroup');
    If CurPageID = wpSelectTasks then
      ConsoleWriteLine(#9'CurPageID: wpSelectTasks');
    If CurPageID = wpReady then
      ConsoleWriteLine(#9'CurPageID: wpReady');
    If CurPageID = wpPreparing then
      ConsoleWriteLine(#9'CurPageID: wpPreparing');
    If CurPageID = wpInstalling then
      ConsoleWriteLine(#9'CurPageID: wpInstalling');
    If CurPageID = wpInfoAfter then
      ConsoleWriteLine(#9'CurPageID: wpInfoAfter');
    If CurPageID = wpFinished then
      ConsoleWriteLine(#9'CurPageID: wpFinished');
    ConsoleWriteLine('leaving CancelButtonClick(CurPageID: "'+IntToStr(CurPageID)+'"; var Cancel: '+Bool2Str(Cancel)+'; var Confirm: '+Bool2Str(Confirm)+')...');
    ConsoleWriteLine('');
end;

function ShouldSkipPage(PageID: Integer): Boolean;
  begin
    ConsoleWriteLine('FUNC: ShouldSkipPage(PageID: "'+IntToStr(PageID)+'"): Boolean;');
    If PageID = wpWelcome then
      ConsoleWriteLine(#9'PageID: wpWelcome');
    If PageID = wpLicense then
      ConsoleWriteLine(#9'PageID: wpLicense');
    If PageID = wpPassword then
      ConsoleWriteLine(#9'PageID: wpPassword');
    If PageID = wpInfoBefore then
      ConsoleWriteLine(#9'PageID: wpInfoBefore');
    If PageID = wpUserInfo then
      ConsoleWriteLine(#9'PageID: wpUserInfo');
    If PageID = wpSelectDir then
      ConsoleWriteLine(#9'PageID: wpSelectDir');
    If PageID = wpSelectComponents then
      ConsoleWriteLine(#9'PageID: wpSelectComponents');
    If PageID = wpSelectProgramGroup then
      ConsoleWriteLine(#9'PageID: wpSelectProgramGroup');
    If PageID = wpSelectTasks then
      ConsoleWriteLine(#9'PageID: wpSelectTasks');
    If PageID = wpReady then
      ConsoleWriteLine(#9'PageID: wpReady');
    If PageID = wpPreparing then
      ConsoleWriteLine(#9'PageID: wpPreparing');
    If PageID = wpInstalling then
      ConsoleWriteLine(#9'PageID: wpInstalling');
    If PageID = wpInfoAfter then
      ConsoleWriteLine(#9'PageID: wpInfoAfter');
    If PageID = wpFinished then
      ConsoleWriteLine(#9'PageID: wpFinished');
    ConsoleWriteLine(#9'returning '+Bool2Str(Result)+'!');
    ConsoleWriteLine('leaving ShouldSkipPage(PageID: Integer)...');
    ConsoleWriteLine('');
end;

procedure CurPageChanged(CurPageID: Integer);
  begin
    ConsoleWriteLine('PROC: CurPageChanged(CurPageID: "'+IntToStr(CurPageID)+'");');
    If CurPageID = wpWelcome then
      ConsoleWriteLine(#9'CurPageID: wpWelcome');
    If CurPageID = wpLicense then
      ConsoleWriteLine(#9'CurPageID: wpLicense');
    If CurPageID = wpPassword then
      ConsoleWriteLine(#9'CurPageID: wpPassword');
    If CurPageID = wpInfoBefore then
      ConsoleWriteLine(#9'CurPageID: wpInfoBefore');
    If CurPageID = wpUserInfo then
      ConsoleWriteLine(#9'CurPageID: wpUserInfo');
    If CurPageID = wpSelectDir then
      ConsoleWriteLine(#9'CurPageID: wpSelectDir');
    If CurPageID = wpSelectComponents then
      ConsoleWriteLine(#9'CurPageID: wpSelectComponents');
    If CurPageID = wpSelectProgramGroup then
      ConsoleWriteLine(#9'CurPageID: wpSelectProgramGroup');
    If CurPageID = wpSelectTasks then
      ConsoleWriteLine(#9'CurPageID: wpSelectTasks');
    If CurPageID = wpReady then
    begin
      ConsoleWriteLine(#9'CurPageID: wpReady');
      WizardForm.NextButton.Caption := FmtMessage( CustomMessage('LaunchProgram'), [''] );
    end;
    If CurPageID = wpPreparing then
      ConsoleWriteLine(#9'CurPageID: wpPreparing');
    If CurPageID = wpInstalling then
      ConsoleWriteLine(#9'CurPageID: wpInstalling');
    If CurPageID = wpInfoAfter then
      ConsoleWriteLine(#9'CurPageID: wpInfoAfter');
    If CurPageID = wpFinished then
      ConsoleWriteLine(#9'CurPageID: wpFinished');
    ConsoleWriteLine('leaving CurPageChanged(CurPageID: Integer)...');
    WriteConsole(#13#10);
    SetConsoleTextColors(BackYellow, TextPurple);
    WriteConsole('W');
    SetConsoleTextColors(OldColor, TextLime);
    WriteConsole('i');
    SetConsoleTextColors(OldColor, TextMaroon);
    WriteConsole('l');
    SetConsoleTextColors(OldColor, TextAqua);
    WriteConsole('e');
    SetConsoleTextColors(OldColor, TextSilver);
    WriteConsole('n');
    SetConsoleTextColors(OldColor, TextRed);
    WriteConsole('t');
    SetConsoleTextColors(OldColor, TextGreen);
    WriteConsole('y');
    SetConsoleTextColors(BackGreen, TextYellow);
    WriteConsole(' :-)'#13#10#13#10);
end;

function PrepareToInstall(var NeedsRestart: Boolean): String;
  begin
    ConsoleWriteLine('FUNC: PrepareToInstall(var NeedsRestart: '+Bool2Str(NeedsRestart)+'): String;');
    ConsoleWriteLine(#9'NeedsRestart? ;-)');
    ConsoleWriteLine('leaving PrepareToInstall(var NeedsRestart: '+Bool2Str(NeedsRestart)+')...');
    ConsoleWriteLine('');
end;

procedure CurStepChanged(CurStep: TSetupStep);
  begin
    ConsoleWriteLine('PROC: CurStepChanged(CurStep: TSetupStep);');
    if CurStep = ssPreInstall then
      ConsoleWriteLine(#9'CurStep (TSetupStep): ssPreInstall');
    if CurStep = ssInstall then
      ConsoleWriteLine(#9'CurStep (TSetupStep): ssInstall');
    if CurStep = ssPostInstall then
      ConsoleWriteLine(#9'CurStep (TSetupStep): ssPostInstall');
    if CurStep = ssDone then
      ConsoleWriteLine(#9'CurStep (TSetupStep): ssDone');
    ConsoleWriteLine('leaving CurStepChanged(CurStep: TSetupStep)...');
    ConsoleWriteLine('');
end;

procedure DeinitializeSetup();
  begin
    ConsoleWriteLine('PROC: PrepareToInstall(var NeedsRestart: Boolean): String;');
    ConsoleWriteLine('#9this it''s executed as the last...');
    ConsoleWriteLine('');
    If ConsoleWriteLine(#9'showing this message, and destroying THIS debug console...') then
      Sleep(1000);
    ConsoleWriteLine('leaving DeinitializeSetup()...');
    DestroyConsole();
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
