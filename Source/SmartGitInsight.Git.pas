unit SmartGitInsight.Git;

interface

uses
  SmartGitInsight.Repository;

type
  TSmartGitInsightGit = class
  public
    class procedure OpenTerminal(const Repository: TSmartGitInsightRepository);
    class procedure RunGitConsole(const Repository: TSmartGitInsightRepository; const Arguments: string); static;
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
  SmartGitInsight.Constants,
  SmartGitInsight.Settings;

function Quote(const Value: string): string;
begin
  Result := '"' + StringReplace(Value, '"', '\"', [rfReplaceAll]) + '"';
end;

function ConsoleSwitch: string;
begin
  if SmartGitInsightSettings.AutoCloseConsoleOnSuccess then
    Result := '/C'
  else
    Result := '/K';
end;

procedure RequireRepository(const Repository: TSmartGitInsightRepository);
begin
  if not Repository.IsValid then
    raise Exception.Create('No Git repository was found for the active file or project.');
end;

class procedure TSmartGitInsightGit.OpenTerminal(const Repository: TSmartGitInsightRepository);
var
  ExecutableName: string;
  Parameters: string;
begin
  RequireRepository(Repository);

  ExecutableName := SmartGitInsightSettings.GitBashExecutable;
  if ExecutableName <> '' then
    Parameters := ''
  else
  begin
    ExecutableName := 'cmd.exe';
    Parameters := '/K cd /d ' + Quote(Repository.RootPath);
  end;

  ShellExecute(0, 'open', PChar(ExecutableName), PChar(Parameters), PChar(Repository.RootPath), SW_SHOWNORMAL);
end;

class procedure TSmartGitInsightGit.RunGitConsole(const Repository: TSmartGitInsightRepository; const Arguments: string);
var
  Parameters: string;
begin
  RequireRepository(Repository);
  Parameters := Format('%s cd /d %s && %s %s', [
    ConsoleSwitch,
    Quote(Repository.RootPath),
    SmartGitInsightSettings.GitExecutable,
    Arguments
  ]);
  ShellExecute(0, 'open', 'cmd.exe', PChar(Parameters), PChar(Repository.RootPath), SW_SHOWNORMAL);
end;

class procedure TSmartGitInsightGit.RunGitForActiveRepository(const Arguments: string);
begin
  try
    RunGitConsole(DiscoverActiveRepository, Arguments);
  except
    on E: Exception do
      MessageDlg(E.Message, mtInformation, [mbOK], 0);
  end;
end;

class procedure TSmartGitInsightGit.RunGitForActiveFile(const ArgumentsBeforeFile: string);
var
  Repository: TSmartGitInsightRepository;
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

class procedure TSmartGitInsightGit.DiffActiveFile;
begin
  RunGitForActiveFile('diff');
end;

class procedure TSmartGitInsightGit.FileHistory;
begin
  RunGitForActiveFile('log --follow --stat');
end;

class procedure TSmartGitInsightGit.BlameActiveFile;
begin
  RunGitForActiveFile('blame');
end;

class procedure TSmartGitInsightGit.ResetActiveFile;
begin
  if SmartGitInsightSettings.ShowConfirmationForDestructiveActions and
    (MessageDlg('Reset changes in the active file?', mtConfirmation, [mbYes, mbNo], 0) <> mrYes) then
    Exit;

  RunGitForActiveFile('checkout');
end;

class procedure TSmartGitInsightGit.StageActiveFile;
begin
  RunGitForActiveFile('add');
end;

end.
