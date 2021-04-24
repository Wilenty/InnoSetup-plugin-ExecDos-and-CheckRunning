[Setup]
AppName=Example A-W Auto
AppVersion=1.0
CreateAppDir=no
Uninstallable=no
WizardImageFile=compiler:WizModernImage-IS.bmp
ArchitecturesInstallIn64BitMode=x64
WizardSmallImageFile=compiler:WizModernSmallImage-IS.bmp
DisableWelcomePage=no
PrivilegesRequired=lowest
DisableReadyPage=yes
OutputBaseFilename=Example A-W Auto
; for InnoSetup 6+:
WizardResizable=yes
WizardStyle=modern

#Include "ExecDosAndCheckRunningA-Wauto.isi"

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
FilesMsg=	Executing "%1" via "cmd.exe"

[Files]
// explanation of use -=> -=> -=> -=> -=> -=> -=> -=> -=> -=> -=> -=> -=> -=> -=> -=> -=> -=> -=> AfterInstall: ExecDosWithOutputOnInstallingPage('program', 'cmd-line params', 'WorkDir', 'StatusMsg message', 'FilesMsg message'); // Working Dir and both last two messages can be empty
DestDir: "{tmp}"; Source: "1.cmd"; Flags: DeleteAfterInstall IgnoreVersion; Components: "execute\a"; AfterInstall: "ExecDosWithOutputOnInstallingPage('""cmd.exe""', '/c ""{tmp}\1.cmd""', '', '{cm:StatusMsg}', '{cm:FilesMsg,{tmp}\1.cmd}')";
DestDir: "{tmp}"; Source: "2.cmd"; Flags: DeleteAfterInstall IgnoreVersion; Components: "execute\b"; AfterInstall: "ExecDosWithOutputOnInstallingPage('""cmd.exe""', '/c ""{tmp}\2.cmd""', '', '{cm:StatusMsg}', '{cm:FilesMsg,{tmp}\2.cmd}')";
DestDir: "{tmp}"; Source: "3.cmd"; Flags: DeleteAfterInstall IgnoreVersion; Components: "execute\c"; AfterInstall: "ExecDosWithOutputOnInstallingPage('""cmd.exe""', '/c ""{tmp}\3.cmd""', '', '{cm:StatusMsg}', '{cm:FilesMsg,{tmp}\3.cmd}')";
DestDir: "{tmp}"; Source: "4.cmd"; Flags: DeleteAfterInstall IgnoreVersion; Components: "execute\d"; AfterInstall: "ExecDosWithOutputOnInstallingPage('""cmd.exe""', '/c ""{tmp}\4.cmd""', '', '{cm:StatusMsg}', '{cm:FilesMsg,{tmp}\4.cmd}')";

[Code]
Var
  InstallingListBox: TListBox;

Procedure ListBoxWrite(ListBox: TListBox; Str: String);
  begin
    ListBox.Items.Insert(0, Str);
    AppProcessMessages();
end;

#If Defined Unicode
procedure InstallingCallBack(const Output: WideString);
  begin
    ListBoxWrite(InstallingListBox, Output);
end;
#Else
procedure InstallingCallBack(const Output: PAnsiChar);
  begin
    ListBoxWrite(InstallingListBox, Output);
end;
#EndIf

Function ExpandScript(Str: String): String;
  begin
    If (Pos('{', Str) > 0) and (Pos('}', Str) > 0) then
      Result := ExpandConstant(Str)
    else
      Result := Str;
end;

Procedure WriteStatusLabels(StatusMsg, FilesMsg: String);
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
end;

#If Defined Unicode
Procedure ExecDosWithOutputOnInstallingPage(const FileNameOrFullPath, Params, WorkDir, StatusMsg, FilesMsg: String);
  Var
    Int, ExitCode: Integer;
    Str: String;
  begin
    WriteStatusLabels(StatusMsg, FilesMsg);

    With InstallingListBox.Items do
    begin
      ExitCode := ExecDosA2W( ExpandScript(FileNameOrFullPath), ExpandScript(Params), ExpandScript(WorkDir), SW_HIDE, @InstallingCallBack, True );
      For Int := 0 to 30 do
        Str := Str + '-=';
      Str := Str + '-';
      Insert(0, Str);
      Insert(0,  'ExitCode: ' + IntToStr(ExitCode) + ', ' + SysErrorMessage(ExitCode) );
      Insert(0, Str);
    end; // InstallingListBox.Lines.
end;
#Else
Procedure ExecDosWithOutputOnInstallingPage(const FileNameOrFullPath, Params, WorkDir, StatusMsg, FilesMsg: String);
  Var
    Int, ExitCode: Integer;
    Str: String;
  begin
    WriteStatusLabels(StatusMsg, FilesMsg);

    With InstallingListBox.Items do
    begin
      ExitCode := ExecDos( ExpandScript(FileNameOrFullPath), ExpandScript(Params), ExpandScript(WorkDir), SW_HIDE, @InstallingCallBack, True );
      For Int := 0 to 30 do
        Str := Str + '-=';
      Str := Str + '-';
      Insert(0, Str);
      Insert(0,  'ExitCode: ' + IntToStr(ExitCode) + ', ' + SysErrorMessage(ExitCode) );
      Insert(0, Str);
    end; // InstallingListBox.Lines.
end;
#EndIf

Var
  FileListPage, TreeListPage, ErrorListPage: TOutputMsgMemoWizardPage;

Procedure MemoWrite(Memo: TMemo; Str: String);
  begin
    Memo.Lines.Add(Str);
end;

#If Defined Unicode
procedure FileListCallBack(const Output: WideString);
  begin
    MemoWrite(FileListPage.RichEditViewer, Output);
end;
#Else
procedure FileListCallBack(const Output: PAnsiChar);
  begin
    MemoWrite(FileListPage.RichEditViewer, Output);
end;
#EndIf

#If Defined Unicode
procedure TreeListCallBack(const Output: WideString);
  begin
    MemoWrite(TreeListPage.RichEditViewer, Output);
end;
#Else
procedure TreeListCallBack(const Output: PAnsiChar);
  begin
    MemoWrite(TreeListPage.RichEditViewer, Output);
end;
#EndIf

#If Defined Unicode
procedure ErrorListCallBack(const Output: WideString);
  begin
    MemoWrite(ErrorListPage.RichEditViewer, Output);
end;
#Else
procedure ErrorListCallBack(const Output: PAnsiChar);
  begin
    MemoWrite(ErrorListPage.RichEditViewer, Output);
end;
#EndIf

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
    ProcessID: DWORD;
    ProgramOrDLL: String;
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

      WelcomeLabel2.Visible := False;

      With TRichEditViewer.Create(WelcomePage) do
      begin
        Parent := WelcomePage;
        Left := WizardBitmapImage.Left + WizardBitmapImage.Width + ScaleX(10);
        Top := WelcomeLabel1.Top + WelcomeLabel1.Height;
        Width := WelcomePage.ClientWidth - Left - ScaleX(10);
        Height := WelcomePage.ClientHeight - Top - ScaleY(10);
        ScrollBars := ssBoth;
        ReadOnly := True;
        WantReturns := False;
        // for InnoSetup 6+:
        Anchors := [akLeft, akTop, akRight, akBottom];

        With Lines do
        begin
          ProcessID := GetHWndPID(WizardForm.Handle);
          Add('This sample installer process ID is: ' + IntToStr(ProcessID) + #13#10 + 'and it''s path is: "' + GetPIDpath(ProcessID) + '"'#13#10);

          ProgramOrDLL := 'cmd.exe';
          If IsProgramRunning( ProgramOrDLL ) then
            Add('"' + ProgramOrDLL + '" is running...' + #13#10 + 'it''s path is: "' + GetProgramInfo(ProgramOrDLL, ProcessID) + '"'#13#10'and process ID is: ' + IntToStr(ProcessID) + #13#10)
          else
            Add('"' + ProgramOrDLL + '" process not found.' + #13#10);

          ProgramOrDLL := 'Kernel32.dll';
          If IsModuleLoaded( ProgramOrDLL ) then
            Add('"' + ProgramOrDLL + '" is loaded...' + #13#10 + 'and it''s path is: "' + GetModuleInfo(ProgramOrDLL, ProcessID) + '"'#13#10)
          else
            Add('"' + ProgramOrDLL + '" not loaded.' + #13#10);

          ProgramOrDLL := 'richtx32.ocx';
          If IsModuleLoaded( ProgramOrDLL ) then
            Add('"' + ProgramOrDLL + '" is loaded...' + #13#10 + 'and it''s path is: "' + GetModuleInfo(ProgramOrDLL, ProcessID) + '"'#13#10)
          else
            Add('"' + ProgramOrDLL + '" not loaded.' + #13#10);

          ProgramOrDLL := 'User32.dll';
          If IsModuleLoaded( ProgramOrDLL ) then
            Add('"' + ProgramOrDLL + '" is loaded...' + #13#10 + 'and it''s path is: "' + GetModuleInfo(ProgramOrDLL, ProcessID) + '"'#13#10)
          else
            Add('"' + ProgramOrDLL + '" not loaded.' + #13#10);

          ProgramOrDLL := 'Explorer.exe';
          If IsProgramRunning( ProgramOrDLL ) then
            Add('"' + ProgramOrDLL + '" is running...' + #13#10 + 'it''s path is: "' + GetProgramInfo(ProgramOrDLL, ProcessID) + '"'#13#10'process ID is: ' + IntToStr(ProcessID) + #13#10'and first active window handle is: $' + Format('%x', [GetPIDhWnd(ProcessID)]) + #13#10 )
          else
            Add('"' + ProgramOrDLL + '" not loaded.' + #13#10);

          For Int := 0 to 25 do
            Str := Str + '-=';
          Str := Str + '-';
          Add(Str);
          Add('	This sample created by Wilenty:');
          Add('		https://www.buymeacoffee.com/Wilenty');
          Add(Str);
          Insert(0, '');
          Delete(0);
        end; // Lines.
      end; // TRichEditViewer.Create(WelcomePage).

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

    FileListPage := CreateOutputMsgMemoPage(wpUserInfo, 'Listing files and/or folders.', 'It''s fully executed from InnoSetup code.', 'Example 1 of 3'#13#10 + '"' + ExpandConstant('{cmd}') + '" /c dir "' + ExpandConstant('{win}') +'":', '');
    With FileListPage.RichEditViewer do
    begin
      ScrollBars := ssBoth;
      Color := clBlack;
      UseRichEdit := False;
      With Font do
      begin
        Color := clLtGray;
        Style := Style + [fsBold];
      end; // Font.
    end; // FileListPage.RichEditViewer.

    ErrorListPage := CreateOutputMsgMemoPage(FileListPage.ID, 'Here you see an error example.', 'It''s fully executed from InnoSetup code.', 'Example 2 of 3'#13#10'"ping.exe" -w 1000 -l 1 -n 5 0.0.0.0:', '');
    With ErrorListPage.RichEditViewer do
    begin
      ScrollBars := ssBoth;
      Color := clBlack;
      UseRichEdit := False;
      With Font do
      begin
        Color := clLtGray;
        Style := Style + [fsBold];
      end; // Font.
    end; // ErrorListPage.RichEditViewer.

    TreeListPage := CreateOutputMsgMemoPage(ErrorListPage.ID, 'Listing folders as a tree.', 'It''s fully executed from InnoSetup code.', 'Example 3 of 3'#13#10 + '"' + ExpandConstant('{cmd}') + '" /c tree /a "' + ExpandConstant('{sys}') + '":', '');
    With TreeListPage.RichEditViewer do
    begin
      ScrollBars := ssBoth;
      Color := clBlack;
      UseRichEdit := False;
      With Font do
      begin
        Color := clLtGray;
        Style := Style + [fsBold];
      end; // Font.
    end; // TreeListPage.RichEditViewer.
end;

Function Execute(const Prog, Params: String; ListPage: TOutputMsgMemoWizardPage; ExecOutCallBack: TExecOutCallBack; Wait: Boolean): Integer;
  Var
    Int: Integer;
    Str: String;
  begin
    Result := -1;
    With ListPage do
    begin
      With Surface do
      begin
        With RichEditViewer.Lines do
        begin
          Clear;
          Update;
          Repaint;
          Result := ExecDos(Prog, Params, '', SW_HIDE, ExecOutCallBack, Wait);
          For Int := 0 to 30 do
            Str := Str + '-=';
          Str := Str + '-';
          Add(Str);
          Add( 'ExitCode: ' + IntToStr(Result) + ', ' + SysErrorMessage(Result) );
          Add(Str);
        end; // RichEditViewer.Lines.
      end; // Surface.
    end; // ListPage.
end;

Function GetHint(Str: String): String;
  begin
    Result := Copy(Str, 1, Length(Str)-1);
end;

Function ExecuteWithParams(const CmdLine: String; ListPage: TOutputMsgMemoWizardPage; ExecOutCallBack: TExecOutCallBack; Wait: Boolean): Integer;
  var
    Run: String;
    Int: Integer;
  begin
    CmdLine := Copy( CmdLine, Pos(#13#10, CmdLine)+2, Length(CmdLine) );
    Delete(CmdLine, Length(CmdLine), 1);
    Int := Pos('" ', CmdLine);
    Run := Copy( CmdLine, 1, Int );
    CmdLine := Trim( Copy( CmdLine, Int+1, Length(CmdLine) ) );
    Result := Execute(Run, CmdLine, ListPage, ExecOutCallBack, Wait);
end;

procedure CurPageChanged(CurPageID: Integer);
  begin
    With WizardForm do
    begin
      NextButton.Hint := '';
      BackButton.Hint := '';
      If CurPageID = wpWelcome then
        NextButton.Hint := GetHint(FileListPage.SubCaptionLabel.Caption)
      else If CurPageID = FileListPage.ID then
      begin
        NextButton.Hint := GetHint(ErrorListPage.SubCaptionLabel.Caption);
        BackButton.Hint := 'Welcome page';
        ExecuteWithParams(FileListPage.SubCaptionLabel.Caption, FileListPage, @FileListCallBack, True);
      end
      else If CurPageID = ErrorListPage.ID then
      begin
        NextButton.Hint := GetHint(TreeListPage.SubCaptionLabel.Caption);
        BackButton.Hint := GetHint(FileListPage.SubCaptionLabel.Caption);
        ExecuteWithParams(ErrorListPage.SubCaptionLabel.Caption, ErrorListPage, @ErrorListCallBack, True);
      end
      else If CurPageID = TreeListPage.ID then
      begin
        NextButton.Hint := 'Components page';
        BackButton.Hint := GetHint(ErrorListPage.SubCaptionLabel.Caption);
        ExecuteWithParams(TreeListPage.SubCaptionLabel.Caption, TreeListPage, @TreeListCallBack, True);
      end
      else If CurPageID = wpSelectComponents then
      begin
        NextButton.Hint := ComponentsList.Hint;
        NextButton.Caption := FmtMessage( CustomMessage('LaunchProgram'), [''] );
        BackButton.Hint := GetHint(TreeListPage.SubCaptionLabel.Caption);
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
