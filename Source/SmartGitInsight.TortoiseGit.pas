unit SmartGitInsight.TortoiseGit;

interface

uses
  SmartGitInsight.Repository;

type
  TTortoiseGitCommand = (
    tgFetch,
    tgPull,
    tgPush,
    tgSync,
    tgCommit,
    tgDiff,
    tgPreviousDiff,
    tgLog,
    tgBlame,
    tgReflog,
    tgBrowseReferences,
    tgDaemon,
    tgRevisionGraph,
    tgRepoBrowser,
    tgRebase,
    tgStashSave,
    tgBisectStart,
    tgResolve,
    tgRevert,
    tgCleanup,
    tgSwitchCheckout,
    tgMerge,
    tgCreateBranch,
    tgCreateTag,
    tgExport,
    tgWorktrees,
    tgSubmoduleAdd,
    tgCreatePatchSerial,
    tgApplyPatchSerial,
    tgSettings,
    tgHelp,
    tgAbout
  );

  TSmartGitInsightTortoiseGit = class
  public
    class function DetectExecutable: string; static;
    class function EffectiveExecutable: string; static;
    class function IsAvailable: Boolean; static;
    class function IsEnabledAndAvailable: Boolean; static;
    class function CommandDisplayName(ACommand: TTortoiseGitCommand): string; static;
    class procedure Run(ACommand: TTortoiseGitCommand; const Repository: TSmartGitInsightRepository); static;
    class procedure RunForActiveRepository(ACommand: TTortoiseGitCommand); static;
    class procedure RunForActiveFile(ACommand: TTortoiseGitCommand); static;
  end;

implementation

uses
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
    Result := IncludeTrailingPathDelimiter(DirectoryName) + 'bin\TortoiseGitProc.exe';
end;

function CommandName(ACommand: TTortoiseGitCommand): string;
begin
  case ACommand of
    tgFetch:
      Result := 'fetch';
    tgPull:
      Result := 'pull';
    tgPush:
      Result := 'push';
    tgSync:
      Result := 'sync';
    tgCommit:
      Result := 'commit';
    tgDiff:
      Result := 'diff';
    tgPreviousDiff:
      Result := 'showcompare';
    tgLog:
      Result := 'log';
    tgBlame:
      Result := 'blame';
    tgReflog:
      Result := 'reflog';
    tgBrowseReferences:
      Result := 'refbrowse';
    tgDaemon:
      Result := 'daemon';
    tgRevisionGraph:
      Result := 'revisiongraph';
    tgRepoBrowser:
      Result := 'repobrowser';
    tgRebase:
      Result := 'rebase';
    tgStashSave:
      Result := 'stashsave';
    tgBisectStart:
      Result := 'bisect';
    tgResolve:
      Result := 'resolve';
    tgRevert:
      Result := 'revert';
    tgCleanup:
      Result := 'cleanup';
    tgSwitchCheckout:
      Result := 'switch';
    tgMerge:
      Result := 'merge';
    tgCreateBranch:
      Result := 'branch';
    tgCreateTag:
      Result := 'tag';
    tgExport:
      Result := 'export';
    tgWorktrees:
      Result := 'worktreelist';
    tgSubmoduleAdd:
      Result := 'subadd';
    tgCreatePatchSerial:
      Result := 'showcompare';
    tgApplyPatchSerial:
      Result := 'applypatch';
    tgSettings:
      Result := 'settings';
    tgHelp:
      Result := 'help';
    tgAbout:
      Result := 'about';
  else
    Result := 'about';
  end;
end;

function CommandNeedsActiveFile(ACommand: TTortoiseGitCommand): Boolean;
begin
  Result := ACommand in [tgDiff, tgPreviousDiff, tgBlame, tgResolve];
end;

function CommandAllowsNoTarget(ACommand: TTortoiseGitCommand): Boolean;
begin
  Result := ACommand in [tgSettings, tgHelp, tgAbout];
end;

function ExtraArguments(ACommand: TTortoiseGitCommand): string;
begin
  case ACommand of
    tgPreviousDiff:
      Result := ' /revision1:HEAD~1 /revision2:HEAD';
    tgBisectStart:
      Result := ' /start';
  else
    Result := '';
  end;
end;

class function TSmartGitInsightTortoiseGit.DetectExecutable: string;
var
  DirectoryName: string;
begin
  Result := ReadRegistryString(HKEY_LOCAL_MACHINE, 'SOFTWARE\TortoiseGit', 'ProcPath');
  if (Result <> '') and FileExists(Result) then
    Exit;

  Result := ReadRegistryString(HKEY_LOCAL_MACHINE, 'SOFTWARE\WOW6432Node\TortoiseGit', 'ProcPath');
  if (Result <> '') and FileExists(Result) then
    Exit;

  DirectoryName := ReadRegistryString(HKEY_LOCAL_MACHINE, 'SOFTWARE\TortoiseGit', 'Directory');
  Result := CombineProcPath(DirectoryName);
  if (Result <> '') and FileExists(Result) then
    Exit;

  DirectoryName := ReadRegistryString(HKEY_LOCAL_MACHINE, 'SOFTWARE\WOW6432Node\TortoiseGit', 'Directory');
  Result := CombineProcPath(DirectoryName);
  if (Result <> '') and FileExists(Result) then
    Exit;

  Result := 'C:\Program Files\TortoiseGit\bin\TortoiseGitProc.exe';
  if FileExists(Result) then
    Exit;

  Result := 'C:\Program Files (x86)\TortoiseGit\bin\TortoiseGitProc.exe';
  if not FileExists(Result) then
    Result := '';
end;

class function TSmartGitInsightTortoiseGit.EffectiveExecutable: string;
begin
  Result := SmartGitInsightSettings.TortoiseGitExecutable;
  if (Result = '') or not FileExists(Result) then
  begin
    Result := DetectExecutable;
    if SmartGitInsightSettings.TortoiseGitExecutable = '' then
    begin
      SmartGitInsightSettings.TortoiseGitExecutable := Result;
      SmartGitInsightSettings.Save;
    end;
  end;
end;

class function TSmartGitInsightTortoiseGit.IsAvailable: Boolean;
begin
  Result := EffectiveExecutable <> '';
end;

class function TSmartGitInsightTortoiseGit.IsEnabledAndAvailable: Boolean;
begin
  Result := SmartGitInsightSettings.TortoiseGitEnabled and IsAvailable;
end;

class function TSmartGitInsightTortoiseGit.CommandDisplayName(ACommand: TTortoiseGitCommand): string;
begin
  case ACommand of
    tgFetch:
      Result := 'Fetch...';
    tgPull:
      Result := 'Git Pull...';
    tgPush:
      Result := 'Git Push...';
    tgSync:
      Result := 'Git Sync...';
    tgCommit:
      Result := 'Git Commit...';
    tgDiff:
      Result := 'Diff';
    tgPreviousDiff:
      Result := 'Diff with previous version';
    tgLog:
      Result := 'Show Log';
    tgBlame:
      Result := 'Blame';
    tgReflog:
      Result := 'Show Reflog';
    tgBrowseReferences:
      Result := 'Browse References';
    tgDaemon:
      Result := 'Daemon';
    tgRevisionGraph:
      Result := 'Revision graph';
    tgRepoBrowser:
      Result := 'Repo-browser';
    tgRebase:
      Result := 'Rebase...';
    tgStashSave:
      Result := 'Stash changes';
    tgBisectStart:
      Result := 'Bisect start';
    tgResolve:
      Result := 'Resolve...';
    tgRevert:
      Result := 'Revert...';
    tgCleanup:
      Result := 'Clean up...';
    tgSwitchCheckout:
      Result := 'Switch/Checkout...';
    tgMerge:
      Result := 'Merge...';
    tgCreateBranch:
      Result := 'Create Branch...';
    tgCreateTag:
      Result := 'Create Tag...';
    tgExport:
      Result := 'Export...';
    tgWorktrees:
      Result := 'Worktrees';
    tgSubmoduleAdd:
      Result := 'Submodule Add...';
    tgCreatePatchSerial:
      Result := 'Create Patch Serial...';
    tgApplyPatchSerial:
      Result := 'Apply Patch Serial...';
    tgSettings:
      Result := 'Settings';
    tgHelp:
      Result := 'Help';
    tgAbout:
      Result := 'About';
  else
    Result := 'TortoiseGit';
  end;
end;

class procedure TSmartGitInsightTortoiseGit.Run(ACommand: TTortoiseGitCommand; const Repository: TSmartGitInsightRepository);
var
  CommandLine: string;
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
    MessageDlg('TortoiseGitProc.exe was not found. Configure it in Tools > Options > Third Party > Smart GitInsight.',
      mtInformation, [mbOK], 0);
    Exit;
  end;

  if CommandNeedsActiveFile(ACommand) and (Repository.ActiveFileName <> '') then
    TargetPath := Repository.ActiveFileName
  else if Repository.RootPath <> '' then
    TargetPath := Repository.RootPath
  else if Repository.ProjectFileName <> '' then
    TargetPath := Repository.ProjectFileName
  else
    TargetPath := '';

  if (TargetPath = '') and not CommandAllowsNoTarget(ACommand) then
  begin
    MessageDlg('No active Git repository or project file was found for the TortoiseGit command.',
      mtInformation, [mbOK], 0);
    Exit;
  end;

  Parameters := '/command:' + CommandName(ACommand);
  if TargetPath <> '' then
    Parameters := Parameters + ' /path:' + Quote(TargetPath);
  Parameters := Parameters + ExtraArguments(ACommand);

  DirectoryName := Repository.RootPath;
  if (DirectoryName = '') and (TargetPath <> '') then
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
  if not CreateProcess(nil, PChar(CommandLine), nil, nil, False, 0, nil, PChar(DirectoryName),
    StartupInfo, ProcessInfo) then
  begin
    WinError := GetLastError;
    MessageDlg(Format('Unable to launch TortoiseGit command "%s". Windows error %d: %s' + sLineBreak + sLineBreak +
      '%s', [CommandName(ACommand), WinError, SysErrorMessage(WinError), CommandLine]),
      mtError, [mbOK], 0);
  end
  else
  begin
    CloseHandle(ProcessInfo.hThread);
    CloseHandle(ProcessInfo.hProcess);
  end;
end;

class procedure TSmartGitInsightTortoiseGit.RunForActiveRepository(ACommand: TTortoiseGitCommand);
begin
  Run(ACommand, DiscoverActiveRepository);
end;

class procedure TSmartGitInsightTortoiseGit.RunForActiveFile(ACommand: TTortoiseGitCommand);
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
