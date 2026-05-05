unit Git4D.TortoiseGit;

interface

uses
  Git4D.Repository;

type
  TTortoiseGitCommand = (
    tgFetch,
    tgPull,
    tgPush,
    tgSync,
    tgCommit,
    tgAdd,
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

  TGit4DTortoiseGit = class
  public
    class function DetectExecutable: string; static;
    class function EffectiveExecutable: string; static;
    class function IsAvailable: Boolean; static;
    class function IsEnabledAndAvailable: Boolean; static;
    class function CommandDisplayName(ACommand: TTortoiseGitCommand): string; static;
    class procedure Run(ACommand: TTortoiseGitCommand; const Repository: TGit4DRepository); static;
    class procedure RunForActiveRepository(ACommand: TTortoiseGitCommand); static;
    class procedure RunForActiveFile(ACommand: TTortoiseGitCommand); static;
  end;

implementation

uses
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
    tgAdd:
      Result := 'add';
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
  Result := ACommand in [tgAdd, tgDiff, tgPreviousDiff, tgBlame, tgResolve];
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

class function TGit4DTortoiseGit.DetectExecutable: string;
var
  LDirectoryName: string;
begin
  Result := ReadRegistryString(HKEY_LOCAL_MACHINE, 'SOFTWARE\TortoiseGit', 'ProcPath');
  if (Result <> '') and FileExists(Result) then
    Exit;

  Result := ReadRegistryString(HKEY_LOCAL_MACHINE, 'SOFTWARE\WOW6432Node\TortoiseGit', 'ProcPath');
  if (Result <> '') and FileExists(Result) then
    Exit;

  LDirectoryName := ReadRegistryString(HKEY_LOCAL_MACHINE, 'SOFTWARE\TortoiseGit', 'Directory');
  Result := CombineProcPath(LDirectoryName);
  if (Result <> '') and FileExists(Result) then
    Exit;

  LDirectoryName := ReadRegistryString(HKEY_LOCAL_MACHINE, 'SOFTWARE\WOW6432Node\TortoiseGit', 'Directory');
  Result := CombineProcPath(LDirectoryName);
  if (Result <> '') and FileExists(Result) then
    Exit;

  Result := 'C:\Program Files\TortoiseGit\bin\TortoiseGitProc.exe';
  if FileExists(Result) then
    Exit;

  Result := 'C:\Program Files (x86)\TortoiseGit\bin\TortoiseGitProc.exe';
  if not FileExists(Result) then
    Result := '';
end;

class function TGit4DTortoiseGit.EffectiveExecutable: string;
begin
  Result := Git4DSettings.TortoiseGitExecutable;
  if (Result <> '') and FileExists(Result) then
    Exit;

  if not GExecutableDetectionAttempted then
  begin
    GDetectedExecutable := DetectExecutable;
    GExecutableDetectionAttempted := True;
  end;
  Result := GDetectedExecutable;
end;

class function TGit4DTortoiseGit.IsAvailable: Boolean;
begin
  Result := EffectiveExecutable <> '';
end;

class function TGit4DTortoiseGit.IsEnabledAndAvailable: Boolean;
begin
  Result := Git4DSettings.TortoiseGitEnabled and IsAvailable;
end;

class function TGit4DTortoiseGit.CommandDisplayName(ACommand: TTortoiseGitCommand): string;
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
    tgAdd:
      Result := 'Git Add...';
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

class procedure TGit4DTortoiseGit.Run(ACommand: TTortoiseGitCommand; const Repository: TGit4DRepository);
var
  LCommandLine: string;
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
    MessageDlg('TortoiseGitProc.exe was not found. Configure it in Tools > Options > Third Party > Git4D.',
      mtInformation, [mbOK], 0);
    Exit;
  end;

  if CommandNeedsActiveFile(ACommand) and (Repository.ActiveFileName <> '') then
    LTargetPath := Repository.ActiveFileName
  else if Repository.RootPath <> '' then
    LTargetPath := Repository.RootPath
  else if Repository.ProjectFileName <> '' then
    LTargetPath := Repository.ProjectFileName
  else
    LTargetPath := '';

  if (LTargetPath = '') and not CommandAllowsNoTarget(ACommand) then
  begin
    MessageDlg('No active Git repository or project file was found for the TortoiseGit command.',
      mtInformation, [mbOK], 0);
    Exit;
  end;

  LParameters := '/command:' + CommandName(ACommand);
  if LTargetPath <> '' then
    LParameters := LParameters + ' /path:' + Quote(LTargetPath);
  LParameters := LParameters + ExtraArguments(ACommand);

  LDirectoryName := Repository.RootPath;
  if (LDirectoryName = '') and (LTargetPath <> '') then
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
  if not CreateProcess(nil, PChar(LCommandLine), nil, nil, False, 0, nil, PChar(LDirectoryName),
    LStartupInfo, LProcessInfo) then
  begin
    LWinError := GetLastError;
    MessageDlg(Format('Unable to launch TortoiseGit command "%s". Windows error %d: %s' + sLineBreak + sLineBreak +
      '%s', [CommandName(ACommand), LWinError, SysErrorMessage(LWinError), LCommandLine]),
      mtError, [mbOK], 0);
  end
  else
  begin
    CloseHandle(LProcessInfo.hThread);
    CloseHandle(LProcessInfo.hProcess);
  end;
end;

class procedure TGit4DTortoiseGit.RunForActiveRepository(ACommand: TTortoiseGitCommand);
begin
  Run(ACommand, DiscoverActiveRepository);
end;

class procedure TGit4DTortoiseGit.RunForActiveFile(ACommand: TTortoiseGitCommand);
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

