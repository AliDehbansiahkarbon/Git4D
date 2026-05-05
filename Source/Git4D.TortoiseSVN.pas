unit Git4D.TortoiseSVN;

interface

uses
  Git4D.Repository;

type
  TTortoiseSvnCommand = (
    svnUpdate,
    svnCommit,
    svnDiff,
    svnPreviousDiff,
    svnLog,
    svnBlame,
    svnRepoBrowser,
    svnRevisionGraph,
    svnCheckForModifications,
    svnAdd,
    svnRevert,
    svnCleanup,
    svnResolved,
    svnSwitch,
    svnMerge,
    svnBranchTag,
    svnCheckout,
    svnExport,
    svnSettings,
    svnHelp,
    svnAbout
  );

  TGit4DTortoiseSVN = class
  public
    class function DetectExecutable: string; static;
    class function EffectiveExecutable: string; static;
    class function IsAvailable: Boolean; static;
    class function IsEnabledAndAvailable: Boolean; static;
    class function CommandDisplayName(ACommand: TTortoiseSvnCommand): string; static;
    class procedure Run(ACommand: TTortoiseSvnCommand; const Repository: TGit4DRepository); static;
    class procedure RunForActiveRepository(ACommand: TTortoiseSvnCommand); static;
    class procedure RunForActiveFile(ACommand: TTortoiseSvnCommand); static;
  end;

implementation

uses
  System.IOUtils,
  System.SysUtils,
  System.Win.Registry,
  Vcl.Dialogs,
  Winapi.Windows,
  Git4D.Settings;

var
  GDetectedExecutable: string;
  GExecutableDetectionAttempted: Boolean;

function Quote(const Value: string): string;
begin
  Result := '"' + StringReplace(Value, '"', '""', [rfReplaceAll]) + '"';
end;

function ReadRegistryString(const Root: HKEY; const KeyName, ValueName: string): string;
var
  LRegistry: TRegistry;
begin
  Result := '';
  LRegistry := TRegistry.Create(KEY_READ);
  try
    LRegistry.RootKey := Root;
    if LRegistry.OpenKeyReadOnly(KeyName) and LRegistry.ValueExists(ValueName) then
      Result := LRegistry.ReadString(ValueName);
  finally
    LRegistry.Free;
  end;
end;

function CombineProcPath(const DirectoryName: string): string;
begin
  Result := '';
  if DirectoryName <> '' then
    Result := IncludeTrailingPathDelimiter(DirectoryName) + 'bin\TortoiseProc.exe';
end;

function CommandName(ACommand: TTortoiseSvnCommand): string;
begin
  case ACommand of
    svnUpdate:
      Result := 'update';
    svnCommit:
      Result := 'commit';
    svnDiff:
      Result := 'diff';
    svnPreviousDiff:
      Result := 'prevdiff';
    svnLog:
      Result := 'log';
    svnBlame:
      Result := 'blame';
    svnRepoBrowser:
      Result := 'repobrowser';
    svnRevisionGraph:
      Result := 'revisiongraph';
    svnCheckForModifications:
      Result := 'repostatus';
    svnAdd:
      Result := 'add';
    svnRevert:
      Result := 'revert';
    svnCleanup:
      Result := 'cleanup';
    svnResolved:
      Result := 'resolve';
    svnSwitch:
      Result := 'switch';
    svnMerge:
      Result := 'merge';
    svnBranchTag:
      Result := 'copy';
    svnCheckout:
      Result := 'checkout';
    svnExport:
      Result := 'export';
    svnSettings:
      Result := 'settings';
    svnHelp:
      Result := 'help';
    svnAbout:
      Result := 'about';
  else
    Result := 'about';
  end;
end;

function CommandNeedsActiveFile(ACommand: TTortoiseSvnCommand): Boolean;
begin
  Result := ACommand in [svnDiff, svnPreviousDiff, svnBlame, svnResolved];
end;

function CommandAllowsNoTarget(ACommand: TTortoiseSvnCommand): Boolean;
begin
  Result := ACommand in [svnCheckout, svnSettings, svnHelp, svnAbout];
end;

function ExtraArguments(ACommand: TTortoiseSvnCommand): string;
begin
  case ACommand of
    svnCleanup:
      Result := ' /cleanup';
  else
    Result := '';
  end;
end;

function NormalizeStartDirectory(const FileOrDirectory: string): string;
begin
  Result := FileOrDirectory;
  if Result = '' then
    Exit;

  if TFile.Exists(Result) then
    Result := TPath.GetDirectoryName(Result);
end;

function DiscoverSvnWorkingCopyRoot(const FileOrDirectory: string): string;
var
  LDirectoryName: string;
  LParentName: string;
begin
  Result := '';
  LDirectoryName := NormalizeStartDirectory(FileOrDirectory);
  while LDirectoryName <> '' do
  begin
    if TDirectory.Exists(TPath.Combine(LDirectoryName, '.svn')) then
    begin
      Result := LDirectoryName;
      Exit;
    end;

    LParentName := TPath.GetDirectoryName(LDirectoryName);
    if SameText(LParentName, LDirectoryName) then
      Break;
    LDirectoryName := LParentName;
  end;
end;

class function TGit4DTortoiseSVN.DetectExecutable: string;
var
  LDirectoryName: string;
begin
  Result := ReadRegistryString(HKEY_LOCAL_MACHINE, 'SOFTWARE\TortoiseSVN', 'ProcPath');
  if (Result <> '') and FileExists(Result) then
    Exit;

  Result := ReadRegistryString(HKEY_LOCAL_MACHINE, 'SOFTWARE\WOW6432Node\TortoiseSVN', 'ProcPath');
  if (Result <> '') and FileExists(Result) then
    Exit;

  LDirectoryName := ReadRegistryString(HKEY_LOCAL_MACHINE, 'SOFTWARE\TortoiseSVN', 'Directory');
  Result := CombineProcPath(LDirectoryName);
  if (Result <> '') and FileExists(Result) then
    Exit;

  LDirectoryName := ReadRegistryString(HKEY_LOCAL_MACHINE, 'SOFTWARE\WOW6432Node\TortoiseSVN', 'Directory');
  Result := CombineProcPath(LDirectoryName);
  if (Result <> '') and FileExists(Result) then
    Exit;

  Result := 'C:\Program Files\TortoiseSVN\bin\TortoiseProc.exe';
  if FileExists(Result) then
    Exit;

  Result := 'C:\Program Files (x86)\TortoiseSVN\bin\TortoiseProc.exe';
  if not FileExists(Result) then
    Result := '';
end;

class function TGit4DTortoiseSVN.EffectiveExecutable: string;
begin
  Result := Git4DSettings.TortoiseSvnExecutable;
  if (Result <> '') and FileExists(Result) then
    Exit;

  if not GExecutableDetectionAttempted then
  begin
    GDetectedExecutable := DetectExecutable;
    GExecutableDetectionAttempted := True;
  end;
  Result := GDetectedExecutable;
end;

class function TGit4DTortoiseSVN.IsAvailable: Boolean;
begin
  Result := EffectiveExecutable <> '';
end;

class function TGit4DTortoiseSVN.IsEnabledAndAvailable: Boolean;
begin
  Result := Git4DSettings.TortoiseSvnEnabled and IsAvailable;
end;

class function TGit4DTortoiseSVN.CommandDisplayName(ACommand: TTortoiseSvnCommand): string;
begin
  case ACommand of
    svnUpdate:
      Result := 'SVN Update...';
    svnCommit:
      Result := 'SVN Commit...';
    svnDiff:
      Result := 'Diff';
    svnPreviousDiff:
      Result := 'Diff with previous version';
    svnLog:
      Result := 'Show Log';
    svnBlame:
      Result := 'Blame';
    svnRepoBrowser:
      Result := 'Repo-browser';
    svnRevisionGraph:
      Result := 'Revision graph';
    svnCheckForModifications:
      Result := 'Check for modifications';
    svnAdd:
      Result := 'Add...';
    svnRevert:
      Result := 'Revert...';
    svnCleanup:
      Result := 'Clean up...';
    svnResolved:
      Result := 'Resolve...';
    svnSwitch:
      Result := 'Switch...';
    svnMerge:
      Result := 'Merge...';
    svnBranchTag:
      Result := 'Branch/Tag...';
    svnCheckout:
      Result := 'Checkout...';
    svnExport:
      Result := 'Export...';
    svnSettings:
      Result := 'Settings';
    svnHelp:
      Result := 'Help';
    svnAbout:
      Result := 'About';
  else
    Result := 'TortoiseSVN';
  end;
end;

class procedure TGit4DTortoiseSVN.Run(ACommand: TTortoiseSvnCommand;
  const Repository: TGit4DRepository);
var
  LCommandLine: string;
  LCurrentDirectory: PChar;
  LDirectoryName: string;
  LExecutableName: string;
  LParameters: string;
  LProcessInfo: TProcessInformation;
  LStartupInfo: TStartupInfo;
  LTargetPath: string;
  LWinError: DWORD;
begin
  LExecutableName := EffectiveExecutable;
  if LExecutableName = '' then
  begin
    MessageDlg('TortoiseProc.exe was not found. Configure it in Tools > Options > Third Party > Git4D.',
      mtInformation, [mbOK], 0);
    Exit;
  end;

  if CommandNeedsActiveFile(ACommand) and (Repository.ActiveFileName <> '') then
    LTargetPath := Repository.ActiveFileName
  else
  begin
    LTargetPath := DiscoverSvnWorkingCopyRoot(Repository.ActiveFileName);
    if LTargetPath = '' then
      LTargetPath := DiscoverSvnWorkingCopyRoot(Repository.ProjectFileName);
    if (LTargetPath = '') and (Repository.ProjectFileName <> '') then
      LTargetPath := ExtractFilePath(Repository.ProjectFileName);
  end;

  if (LTargetPath = '') and not CommandAllowsNoTarget(ACommand) then
  begin
    MessageDlg('No active SVN working copy, project file, or editor file was found for the TortoiseSVN command.',
      mtInformation, [mbOK], 0);
    Exit;
  end;

  LParameters := '/command:' + CommandName(ACommand);
  if LTargetPath <> '' then
    LParameters := LParameters + ' /path:' + Quote(LTargetPath);
  LParameters := LParameters + ExtraArguments(ACommand);

  LDirectoryName := '';
  if LTargetPath <> '' then
  begin
    if DirectoryExists(LTargetPath) then
      LDirectoryName := LTargetPath
    else
      LDirectoryName := ExtractFilePath(LTargetPath);
  end;

  ZeroMemory(@LStartupInfo, SizeOf(LStartupInfo));
  ZeroMemory(@LProcessInfo, SizeOf(LProcessInfo));
  LStartupInfo.cb := SizeOf(LStartupInfo);
  LStartupInfo.dwFlags := STARTF_USESHOWWINDOW;
  LStartupInfo.wShowWindow := SW_SHOWNORMAL;

  LCommandLine := Quote(LExecutableName) + ' ' + LParameters;
  if LDirectoryName <> '' then
    LCurrentDirectory := PChar(LDirectoryName)
  else
    LCurrentDirectory := nil;

  if not CreateProcess(nil, PChar(LCommandLine), nil, nil, False, 0, nil, LCurrentDirectory,
    LStartupInfo, LProcessInfo) then
  begin
    LWinError := GetLastError;
    MessageDlg(Format('Unable to launch TortoiseSVN command "%s". Windows error %d: %s' + sLineBreak + sLineBreak +
      '%s', [CommandName(ACommand), LWinError, SysErrorMessage(LWinError), LCommandLine]),
      mtError, [mbOK], 0);
  end
  else
  begin
    CloseHandle(LProcessInfo.hThread);
    CloseHandle(LProcessInfo.hProcess);
  end;
end;

class procedure TGit4DTortoiseSVN.RunForActiveRepository(ACommand: TTortoiseSvnCommand);
begin
  Run(ACommand, DiscoverActiveRepository);
end;

class procedure TGit4DTortoiseSVN.RunForActiveFile(ACommand: TTortoiseSvnCommand);
var
  LRepository: TGit4DRepository;
begin
  LRepository := DiscoverActiveRepository;
  if LRepository.ActiveFileName = '' then
    MessageDlg('No active editor file was found.', mtInformation, [mbOK], 0)
  else
    Run(ACommand, LRepository);
end;

end.

