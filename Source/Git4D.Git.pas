unit Git4D.Git;

interface

uses
  Git4D.Repository;

type
  TGit4DGit = class
  public
    class procedure OpenTerminal(const Repository: TGit4DRepository);
    class procedure RunGitConsole(const Repository: TGit4DRepository; const Arguments: string); static;
    class procedure RunGitForActiveRepository(const Arguments: string); static;
    class procedure RunGitForActiveFile(const ArgumentsBeforeFile: string); static;
    class procedure DiffActiveFile;
    class procedure FileHistory;
    class procedure BlameActiveFile;
    class procedure ResetActiveFile;
    class procedure StageActiveFile;
  end;

implementation

uses
  System.SysUtils,
  Vcl.Controls,
  Vcl.Dialogs,
  Winapi.ShellAPI,
  Winapi.Windows,
  Git4D.Constants,
  Git4D.Settings;

function Quote(const Value: string): string;
begin
  Result := '"' + StringReplace(Value, '"', '""', [rfReplaceAll]) + '"';
end;

function ConsoleSwitch: string;
begin
  if Git4DSettings.AutoCloseConsoleOnSuccess then
    Result := '/C'
  else
    Result := '/K';
end;

procedure RequireRepository(const Repository: TGit4DRepository);
begin
  if not Repository.IsValid then
    raise Exception.Create('No Git repository was found for the active file or project.');
end;

class procedure TGit4DGit.OpenTerminal(const Repository: TGit4DRepository);
var
  ExecutableName: string;
  Parameters: string;
begin
  RequireRepository(Repository);

  ExecutableName := Git4DSettings.GitBashExecutable;
  if ExecutableName <> '' then
    Parameters := ''
  else
  begin
    ExecutableName := 'cmd.exe';
    Parameters := '/K cd /d ' + Quote(Repository.RootPath);
  end;

  ShellExecute(0, 'open', PChar(ExecutableName), PChar(Parameters), PChar(Repository.RootPath), SW_SHOWNORMAL);
end;

class procedure TGit4DGit.RunGitConsole(const Repository: TGit4DRepository; const Arguments: string);
var
  Parameters: string;
begin
  RequireRepository(Repository);
  Parameters := Format('%s "cd /d %s && %s %s"', [
    ConsoleSwitch,
    Quote(Repository.RootPath),
    Quote(Git4DSettings.GitExecutable),
    Arguments
  ]);
  ShellExecute(0, 'open', 'cmd.exe', PChar(Parameters), PChar(Repository.RootPath), SW_SHOWNORMAL);
end;

class procedure TGit4DGit.RunGitForActiveRepository(const Arguments: string);
begin
  try
    RunGitConsole(DiscoverActiveRepository, Arguments);
  except
    on E: Exception do
      MessageDlg(E.Message, mtInformation, [mbOK], 0);
  end;
end;

class procedure TGit4DGit.RunGitForActiveFile(const ArgumentsBeforeFile: string);
var
  Repository: TGit4DRepository;
  RelativeFileName: string;
begin
  try
    Repository := DiscoverActiveRepository;
    RequireRepository(Repository);
    if Repository.ActiveFileName = '' then
      raise Exception.Create('No active editor file was found.');

    RelativeFileName := ExtractRelativePath(IncludeTrailingPathDelimiter(Repository.RootPath), Repository.ActiveFileName);
    RunGitConsole(Repository, ArgumentsBeforeFile + ' -- ' + Quote(RelativeFileName));
  except
    on E: Exception do
      MessageDlg(E.Message, mtInformation, [mbOK], 0);
  end;
end;

class procedure TGit4DGit.DiffActiveFile;
begin
  RunGitForActiveFile('diff');
end;

class procedure TGit4DGit.FileHistory;
begin
  RunGitForActiveFile('log --follow --stat');
end;

class procedure TGit4DGit.BlameActiveFile;
begin
  RunGitForActiveFile('blame');
end;

class procedure TGit4DGit.ResetActiveFile;
begin
  if Git4DSettings.ShowConfirmationForDestructiveActions and
    (MessageDlg('Reset changes in the active file?', mtConfirmation, [mbYes, mbNo], 0) <> mrYes) then
    Exit;

  RunGitForActiveFile('restore --source=HEAD --worktree');
end;

class procedure TGit4DGit.StageActiveFile;
begin
  RunGitForActiveFile('add');
end;

end.

