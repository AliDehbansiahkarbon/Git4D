unit Git4D.GitExtensions;

interface

uses
  Git4D.Repository;

type
  TGitExtensionsCommand = (
    geBrowse,
    geOpenRepo,
    geCommit,
    gePull,
    gePush,
    geSynchronize,
    geAdd,
    geAddFiles,
    geApply,
    geApplyPatch,
    geBlame,
    geBranch,
    geCheckout,
    geCheckoutBranch,
    geCheckoutRevision,
    geCherryPick,
    geCleanup,
    geClone,
    geDiffTool,
    geFileHistory,
    geFileEditor,
    geFormatPatch,
    geGitIgnore,
    geInit,
    geMerge,
    geMergeConflicts,
    geMergeTool,
    geRebase,
    geRemotes,
    geReset,
    geRevert,
    geSearchFile,
    geSettings,
    geStash,
    geTag,
    geViewDiff,
    geViewPatch,
    geHelp,
    geAbout
  );

  TGit4DGitExtensions = class
  public
    class function DetectExecutable: string; static;
    class function EffectiveExecutable: string; static;
    class function IsAvailable: Boolean; static;
    class function IsEnabledAndAvailable: Boolean; static;
    class function CommandDisplayName(ACommand: TGitExtensionsCommand): string; static;
    class procedure Run(ACommand: TGitExtensionsCommand; const Repository: TGit4DRepository); static;
    class procedure RunForActiveRepository(ACommand: TGitExtensionsCommand); static;
    class procedure RunForActiveFile(ACommand: TGitExtensionsCommand); static;
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

function CombineExecutablePath(const DirectoryName: string): string;
begin
  Result := '';
  if DirectoryName <> '' then
    Result := IncludeTrailingPathDelimiter(DirectoryName) + 'GitExtensions.exe';
end;

function CommandName(ACommand: TGitExtensionsCommand): string;
begin
  case ACommand of
    geBrowse:
      Result := 'browse';
    geOpenRepo:
      Result := 'openrepo';
    geCommit:
      Result := 'commit';
    gePull:
      Result := 'pull';
    gePush:
      Result := 'push';
    geSynchronize:
      Result := 'synchronize';
    geAdd:
      Result := 'add';
    geAddFiles:
      Result := 'addfiles';
    geApply:
      Result := 'apply';
    geApplyPatch:
      Result := 'applypatch';
    geBlame:
      Result := 'blame';
    geBranch:
      Result := 'branch';
    geCheckout:
      Result := 'checkout';
    geCheckoutBranch:
      Result := 'checkoutbranch';
    geCheckoutRevision:
      Result := 'checkoutrevision';
    geCherryPick:
      Result := 'cherry';
    geCleanup:
      Result := 'cleanup';
    geClone:
      Result := 'clone';
    geDiffTool:
      Result := 'difftool';
    geFileHistory:
      Result := 'filehistory';
    geFileEditor:
      Result := 'fileeditor';
    geFormatPatch:
      Result := 'formatpatch';
    geGitIgnore:
      Result := 'gitignore';
    geInit:
      Result := 'init';
    geMerge:
      Result := 'merge';
    geMergeConflicts:
      Result := 'mergeconflicts';
    geMergeTool:
      Result := 'mergetool';
    geRebase:
      Result := 'rebase';
    geRemotes:
      Result := 'remotes';
    geReset:
      Result := 'reset';
    geRevert:
      Result := 'revert';
    geSearchFile:
      Result := 'searchfile';
    geSettings:
      Result := 'settings';
    geStash:
      Result := 'stash';
    geTag:
      Result := 'tag';
    geViewDiff:
      Result := 'viewdiff';
    geViewPatch:
      Result := 'viewpatch';
    geHelp:
      Result := 'help';
    geAbout:
      Result := 'about';
  else
    Result := 'browse';
  end;
end;

function CommandNeedsActiveFile(ACommand: TGitExtensionsCommand): Boolean;
begin
  Result := ACommand in [geAdd, geApply, geBlame, geDiffTool, geFileEditor, geFileHistory, geRevert, geViewPatch];
end;

function CommandUsesRepositoryPath(ACommand: TGitExtensionsCommand): Boolean;
begin
  Result := ACommand in [geBrowse, geOpenRepo, geClone, geInit];
end;

function CommandAllowsNoTarget(ACommand: TGitExtensionsCommand): Boolean;
begin
  Result := ACommand in [geClone, geHelp, geAbout, geInit, geSettings];
end;

class function TGit4DGitExtensions.DetectExecutable: string;
var
  LDirectoryName: string;
begin
  LDirectoryName := ReadRegistryString(HKEY_CURRENT_USER, 'Software\GitExtensions', 'InstallDir');
  Result := CombineExecutablePath(LDirectoryName);
  if (Result <> '') and FileExists(Result) then
    Exit;

  LDirectoryName := ReadRegistryString(HKEY_LOCAL_MACHINE, 'Software\GitExtensions', 'InstallDir');
  Result := CombineExecutablePath(LDirectoryName);
  if (Result <> '') and FileExists(Result) then
    Exit;

  LDirectoryName := ReadRegistryString(HKEY_LOCAL_MACHINE, 'Software\WOW6432Node\GitExtensions', 'InstallDir');
  Result := CombineExecutablePath(LDirectoryName);
  if (Result <> '') and FileExists(Result) then
    Exit;

  Result := 'C:\Program Files\GitExtensions\GitExtensions.exe';
  if FileExists(Result) then
    Exit;

  Result := 'C:\Program Files (x86)\GitExtensions\GitExtensions.exe';
  if not FileExists(Result) then
    Result := '';
end;

class function TGit4DGitExtensions.EffectiveExecutable: string;
begin
  Result := Git4DSettings.GitExtensionsExecutable;
  if (Result <> '') and FileExists(Result) then
    Exit;

  if not GExecutableDetectionAttempted then
  begin
    GDetectedExecutable := DetectExecutable;
    GExecutableDetectionAttempted := True;
  end;
  Result := GDetectedExecutable;
end;

class function TGit4DGitExtensions.IsAvailable: Boolean;
begin
  Result := EffectiveExecutable <> '';
end;

class function TGit4DGitExtensions.IsEnabledAndAvailable: Boolean;
begin
  Result := Git4DSettings.GitExtensionsEnabled and IsAvailable;
end;

class function TGit4DGitExtensions.CommandDisplayName(ACommand: TGitExtensionsCommand): string;
begin
  case ACommand of
    geBrowse:
      Result := 'Browse Repository';
    geOpenRepo:
      Result := 'Open Repository';
    geCommit:
      Result := 'Commit...';
    gePull:
      Result := 'Pull...';
    gePush:
      Result := 'Push...';
    geSynchronize:
      Result := 'Synchronize...';
    geAdd:
      Result := 'Add Current File';
    geAddFiles:
      Result := 'Add Files...';
    geApply:
      Result := 'Apply Current Patch';
    geApplyPatch:
      Result := 'Apply Patch...';
    geBlame:
      Result := 'Blame Current File';
    geBranch:
      Result := 'Branch...';
    geCheckout:
      Result := 'Checkout...';
    geCheckoutBranch:
      Result := 'Checkout Branch...';
    geCheckoutRevision:
      Result := 'Checkout Revision...';
    geCherryPick:
      Result := 'Cherry Pick...';
    geCleanup:
      Result := 'Cleanup...';
    geClone:
      Result := 'Clone...';
    geDiffTool:
      Result := 'Diff Current File';
    geFileHistory:
      Result := 'File History';
    geFileEditor:
      Result := 'File Editor';
    geFormatPatch:
      Result := 'Format Patch...';
    geGitIgnore:
      Result := 'Edit .gitignore';
    geInit:
      Result := 'Init Repository...';
    geMerge:
      Result := 'Merge...';
    geMergeConflicts:
      Result := 'Merge Conflicts';
    geMergeTool:
      Result := 'Merge Tool';
    geRebase:
      Result := 'Rebase...';
    geRemotes:
      Result := 'Remotes...';
    geReset:
      Result := 'Reset...';
    geRevert:
      Result := 'Revert Current File';
    geSearchFile:
      Result := 'Search File';
    geSettings:
      Result := 'Settings';
    geStash:
      Result := 'Stash...';
    geTag:
      Result := 'Tag...';
    geViewDiff:
      Result := 'View Diff';
    geViewPatch:
      Result := 'View Current Patch';
    geHelp:
      Result := 'Help';
    geAbout:
      Result := 'About';
  else
    Result := 'Git Extensions';
  end;
end;

class procedure TGit4DGitExtensions.Run(ACommand: TGitExtensionsCommand;
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
    MessageDlg('GitExtensions.exe was not found. Configure it in Tools > Options > Third Party > Git4D.',
      mtInformation, [mbOK], 0);
    Exit;
  end;

  if CommandNeedsActiveFile(ACommand) and (Repository.ActiveFileName <> '') then
    LTargetPath := Repository.ActiveFileName
  else if CommandUsesRepositoryPath(ACommand) and (Repository.RootPath <> '') then
    LTargetPath := Repository.RootPath
  else
    LTargetPath := '';

  if (LTargetPath = '') and CommandNeedsActiveFile(ACommand) then
  begin
    MessageDlg('No active editor file was found for the Git Extensions command.', mtInformation, [mbOK], 0);
    Exit;
  end;

  if (LTargetPath = '') and (Repository.RootPath = '') and not CommandAllowsNoTarget(ACommand) then
  begin
    MessageDlg('No active Git repository was found for the Git Extensions command.', mtInformation, [mbOK], 0);
    Exit;
  end;

  LParameters := CommandName(ACommand);
  if LTargetPath <> '' then
    LParameters := LParameters + ' ' + Quote(LTargetPath);

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
  if LDirectoryName <> '' then
    LCurrentDirectory := PChar(LDirectoryName)
  else
    LCurrentDirectory := nil;

  if not CreateProcess(nil, PChar(LCommandLine), nil, nil, False, 0, nil, LCurrentDirectory,
    LStartupInfo, LProcessInfo) then
  begin
    LWinError := GetLastError;
    MessageDlg(Format('Unable to launch Git Extensions command "%s". Windows error %d: %s' + sLineBreak + sLineBreak +
      '%s', [CommandName(ACommand), LWinError, SysErrorMessage(LWinError), LCommandLine]),
      mtError, [mbOK], 0);
  end
  else
  begin
    CloseHandle(LProcessInfo.hThread);
    CloseHandle(LProcessInfo.hProcess);
  end;
end;

class procedure TGit4DGitExtensions.RunForActiveRepository(ACommand: TGitExtensionsCommand);
begin
  Run(ACommand, DiscoverActiveRepository);
end;

class procedure TGit4DGitExtensions.RunForActiveFile(ACommand: TGitExtensionsCommand);
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

