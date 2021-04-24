[Setup]
AppName=ExecDos without CallBack 1
AppVersion=1.0
CreateAppDir=no
Uninstallable=no
WizardImageFile=compiler:WizModernImage-IS.bmp
ArchitecturesInstallIn64BitMode=x64
WizardSmallImageFile=compiler:WizModernSmallImage-IS.bmp
DisableWelcomePage=no
PrivilegesRequired=lowest
DisableReadyPage=yes
OutputBaseFilename=ExecDos without CallBack 1
; for InnoSetup 6+:
WizardResizable=yes
WizardStyle=modern

#Include "ExecDosAndCheckRunningA-Wauto.isi"

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

Procedure InitializeWizard();
  begin
    With WizardForm do
    begin

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

procedure CurStepChanged(CurStep: TSetupStep);
  Var
    ExitCode: Integer;
  begin
    If CurStep = ssInstall then
    begin
      With WizardForm do
      begin
        StatusLabel.Caption := 'Launching the "cmd.exe"...';
        FilenameLabel.Caption := #9'...and waiting for it''s exit...'
        Update;
        ExitCode := ExecDos('cmd.exe', '', '', SW_SHOWMINIMIZED, nil, True);
        FilenameLabel.Caption := #9'"cmd.exe" closed, displaying results msg.';
        Update;
      end;
      MsgBox( Format('ExitCode: %d ($%x)', [ExitCode, ExitCode]), mbInformation, MB_OK );
    end;
end;

procedure CurPageChanged(CurPageID: Integer);
  begin
    If CurPageID = wpWelcome then
      WizardForm.NextButton.Caption := FmtMessage( CustomMessage('LaunchProgram'), [''] );
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
