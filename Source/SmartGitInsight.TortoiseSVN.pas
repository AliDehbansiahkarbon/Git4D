unit SmartGitInsight.TortoiseSVN;

interface

uses
  SmartGitInsight.Repository;

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

  TSmartGitInsightTortoiseSVN = class
  public
    class function DetectExecutable: string; static;
    class function EffectiveExecutable: string; static;
    class function IsAvailable: Boolean; static;
    class function IsEnabledAndAvailable: Boolean; static;
    class function CommandDisplayName(ACommand: TTortoiseSvnCommand): string; static;
    class procedure Run(ACommand: TTortoiseSvnCommand; const Repository: TSmartGitInsightRepository); static;
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
  SmartGitInsight.Settings;

function Quote(const Value: string): string;
begin
  Result := '"' + StringReplace(Value, '"', '""', [rfReplaceAll]) + '"';
end;

function ReadRegistryString(const Root: HKEY; const KeyName, ValueName: string): string;
var
  Registry: TRegistry;
begin
  Result := '';
  Registry := TRegistry.Create(KEY_READ);
  try
    Registry.RootKey := Root;
    if Registry.OpenKeyReadOnly(KeyName) and Registry.ValueExists(ValueName) then
      Result := Registry.ReadString(ValueName);
  finally
    Registry.Free;
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
  DirectoryName: string;
  ParentName: string;
begin
  Result := '';
  DirectoryName := NormalizeStartDirectory(FileOrDirectory);
  while DirectoryName <> '' do
  begin
    if TDirectory.Exists(TPath.Combine(DirectoryName, '.svn')) then
    begin
      Result := DirectoryName;
      Exit;
    end;

    ParentName := TPath.GetDirectoryName(DirectoryName);
    if SameText(ParentName, DirectoryName) then
      Break;
    DirectoryName := ParentName;
  end;
end;

class function TSmartGitInsightTortoiseSVN.DetectExecutable: string;
var
  DirectoryName: string;
begin
  Result := ReadRegistryString(HKEY_LOCAL_MACHINE, 'SOFTWARE\TortoiseSVN', 'ProcPath');
  if (Result <> '') and FileExists(Result) then
    Exit;

  Result := ReadRegistryString(HKEY_LOCAL_MACHINE, 'SOFTWARE\WOW6432Node\TortoiseSVN', 'ProcPath');
  if (Result <> '') and FileExists(Result) then
    Exit;

  DirectoryName := ReadRegistryString(HKEY_LOCAL_MACHINE, 'SOFTWARE\TortoiseSVN', 'Directory');
  Result := CombineProcPath(DirectoryName);
  if (Result <> '') and FileExists(Result) then
    Exit;

  DirectoryName := ReadRegistryString(HKEY_LOCAL_MACHINE, 'SOFTWARE\WOW6432Node\TortoiseSVN', 'Directory');
  Result := CombineProcPath(DirectoryName);
  if (Result <> '') and FileExists(Result) then
    Exit;

  Result := 'C:\Program Files\TortoiseSVN\bin\TortoiseProc.exe';
  if FileExists(Result) then
    Exit;

  Result := 'C:\Program Files (x86)\TortoiseSVN\bin\TortoiseProc.exe';
  if not FileExists(Result) then
    Result := '';
end;

class function TSmartGitInsightTortoiseSVN.EffectiveExecutable: string;
begin
  Result := SmartGitInsightSettings.TortoiseSvnExecutable;
  if (Result = '') or not FileExists(Result) then
  begin
    Result := DetectExecutable;
    if SmartGitInsightSettings.TortoiseSvnExecutable = '' then
    begin
      SmartGitInsightSettings.TortoiseSvnExecutable := Result;
      SmartGitInsightSettings.Save;
    end;
  end;
end;

class function TSmartGitInsightTortoiseSVN.IsAvailable: Boolean;
begin
  Result := EffectiveExecutable <> '';
end;

class function TSmartGitInsightTortoiseSVN.IsEnabledAndAvailable: Boolean;
begin
  Result := SmartGitInsightSettings.TortoiseSvnEnabled and IsAvailable;
end;

class function TSmartGitInsightTortoiseSVN.CommandDisplayName(ACommand: TTortoiseSvnCommand): string;
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

class procedure TSmartGitInsightTortoiseSVN.Run(ACommand: TTortoiseSvnCommand;
  const Repository: TSmartGitInsightRepository);
var
  CommandLine: string;
  CurrentDirectory: PChar;
  DirectoryName: string;
  ExecutableName: string;
  Parameters: string;
  ProcessInfo: TProcessInformation;
  StartupInfo: TStartupInfo;
  TargetPath: string;
  WinError: DWORD;
begin
  ExecutableName := EffectiveExecutable;
  if ExecutableName = '' then
  begin
    MessageDlg('TortoiseProc.exe was not found. Configure it in Tools > Options > Third Party > Smart GitInsight.',
      mtInformation, [mbOK], 0);
    Exit;
  end;

  if CommandNeedsActiveFile(ACommand) and (Repository.ActiveFileName <> '') then
    TargetPath := Repository.ActiveFileName
  else
  begin
    TargetPath := DiscoverSvnWorkingCopyRoot(Repository.ActiveFileName);
    if TargetPath = '' then
      TargetPath := DiscoverSvnWorkingCopyRoot(Repository.ProjectFileName);
    if (TargetPath = '') and (Repository.ProjectFileName <> '') then
      TargetPath := ExtractFilePath(Repository.ProjectFileName);
  end;

  if (TargetPath = '') and not CommandAllowsNoTarget(ACommand) then
  begin
    MessageDlg('No active SVN working copy, project file, or editor file was found for the TortoiseSVN command.',
      mtInformation, [mbOK], 0);
    Exit;
  end;

  Parameters := '/command:' + CommandName(ACommand);
  if TargetPath <> '' then
    Parameters := Parameters + ' /path:' + Quote(TargetPath);
  Parameters := Parameters + ExtraArguments(ACommand);

  DirectoryName := '';
  if TargetPath <> '' then
  begin
    if DirectoryExists(TargetPath) then
      DirectoryName := TargetPath
    else
      DirectoryName := ExtractFilePath(TargetPath);
  end;

  ZeroMemory(@StartupInfo, SizeOf(StartupInfo));
  ZeroMemory(@ProcessInfo, SizeOf(ProcessInfo));
  StartupInfo.cb := SizeOf(StartupInfo);
  StartupInfo.dwFlags := STARTF_USESHOWWINDOW;
  StartupInfo.wShowWindow := SW_SHOWNORMAL;

  CommandLine := Quote(ExecutableName) + ' ' + Parameters;
  if DirectoryName <> '' then
    CurrentDirectory := PChar(DirectoryName)
  else
    CurrentDirectory := nil;

  if not CreateProcess(nil, PChar(CommandLine), nil, nil, False, 0, nil, CurrentDirectory,
    StartupInfo, ProcessInfo) then
  begin
    WinError := GetLastError;
    MessageDlg(Format('Unable to launch TortoiseSVN command "%s". Windows error %d: %s' + sLineBreak + sLineBreak +
      '%s', [CommandName(ACommand), WinError, SysErrorMessage(WinError), CommandLine]),
      mtError, [mbOK], 0);
  end
  else
  begin
    CloseHandle(ProcessInfo.hThread);
    CloseHandle(ProcessInfo.hProcess);
  end;
end;

class procedure TSmartGitInsightTortoiseSVN.RunForActiveRepository(ACommand: TTortoiseSvnCommand);
begin
  Run(ACommand, DiscoverActiveRepository);
end;

class procedure TSmartGitInsightTortoiseSVN.RunForActiveFile(ACommand: TTortoiseSvnCommand);
var
  Repository: TSmartGitInsightRepository;
begin
  Repository := DiscoverActiveRepository;
  if Repository.ActiveFileName = '' then
    MessageDlg('No active editor file was found.', mtInformation, [mbOK], 0)
  else
    Run(ACommand, Repository);
end;

end.
