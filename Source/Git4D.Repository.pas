unit Git4D.Repository;

interface

type
  TGit4DRepository = record
    RootPath: string;
    ActiveFileName: string;
    ProjectFileName: string;
    IsValid: Boolean;
  end;

function DiscoverRepository(const FileOrDirectory: string): TGit4DRepository;
function DiscoverActiveRepository: TGit4DRepository;
function GetCurrentBranchName(const RepositoryRoot: string): string;

implementation

uses
  System.IOUtils,
  System.SysUtils,
  ToolsAPI,
  Winapi.Windows,
  Git4D.Settings;

function IsGitRoot(const DirectoryName: string): Boolean;
begin
  Result := TDirectory.Exists(TPath.Combine(DirectoryName, '.git')) or
    TFile.Exists(TPath.Combine(DirectoryName, '.git'));
end;

function NormalizeStartDirectory(const FileOrDirectory: string): string;
begin
  Result := FileOrDirectory;
  if Result = '' then
    Exit;

  if TFile.Exists(Result) then
    Result := TPath.GetDirectoryName(Result);
end;

function DiscoverRepository(const FileOrDirectory: string): TGit4DRepository;
var
  LDirectoryName: string;
  LParentName: string;
begin
  Result := Default(TGit4DRepository);
  Result.ActiveFileName := FileOrDirectory;

  LDirectoryName := NormalizeStartDirectory(FileOrDirectory);
  while LDirectoryName <> '' do
  begin
    if IsGitRoot(LDirectoryName) then
    begin
      Result.RootPath := LDirectoryName;
      Result.IsValid := True;
      Exit;
    end;

    LParentName := TPath.GetDirectoryName(LDirectoryName);
    if SameText(LParentName, LDirectoryName) then
      Break;
    LDirectoryName := LParentName;
  end;
end;

function TryGetActiveModuleFileName: string;
var
  LModule: IOTAModule;
  LModuleServices: IOTAModuleServices;
begin
  Result := '';
  try
    LModuleServices := BorlandIDEServices as IOTAModuleServices;
    LModule := LModuleServices.CurrentModule;
    if LModule <> nil then
      Result := LModule.FileName;
  except
    Result := '';
  end;
end;

function TryGetActiveProjectFileName: string;
var
  LModuleServices: IOTAModuleServices;
  LProject: IOTAProject;
begin
  Result := '';
  try
    LModuleServices := BorlandIDEServices as IOTAModuleServices;
    LProject := LModuleServices.GetActiveProject;
    if LProject <> nil then
      Result := LProject.FileName;
  except
    Result := '';
  end;
end;

function DiscoverActiveRepository: TGit4DRepository;
var
  LActiveFileName: string;
  LProjectFileName: string;
begin
  LActiveFileName := TryGetActiveModuleFileName;
  LProjectFileName := TryGetActiveProjectFileName;

  if LActiveFileName <> '' then
    Result := DiscoverRepository(LActiveFileName)
  else
    Result := DiscoverRepository(LProjectFileName);

  Result.ActiveFileName := LActiveFileName;
  Result.ProjectFileName := LProjectFileName;
end;

function ReadPipeText(const CommandLine, WorkingDirectory: string): string;
var
  LBuffer: array[0..2047] of AnsiChar;
  LBytesRead: DWORD;
  LChunk: AnsiString;
  LMutableCommandLine: string;
  LProcessInfo: TProcessInformation;
  LReadPipe: THandle;
  LSecurityAttributes: TSecurityAttributes;
  LStartupInfo: TStartupInfo;
  LWritePipe: THandle;
begin
  Result := '';
  LSecurityAttributes.nLength := SizeOf(LSecurityAttributes);
  LSecurityAttributes.bInheritHandle := True;
  LSecurityAttributes.lpSecurityDescriptor := nil;

  if not CreatePipe(LReadPipe, LWritePipe, @LSecurityAttributes, 0) then
    Exit;
  try
    SetHandleInformation(LReadPipe, HANDLE_FLAG_INHERIT, 0);
    ZeroMemory(@LStartupInfo, SizeOf(LStartupInfo));
    LStartupInfo.cb := SizeOf(LStartupInfo);
    LStartupInfo.dwFlags := STARTF_USESHOWWINDOW or STARTF_USESTDHANDLES;
    LStartupInfo.wShowWindow := SW_HIDE;
    LStartupInfo.hStdOutput := LWritePipe;
    LStartupInfo.hStdError := LWritePipe;

    ZeroMemory(@LProcessInfo, SizeOf(LProcessInfo));
    LMutableCommandLine := CommandLine;
    if CreateProcess(nil, PChar(LMutableCommandLine), nil, nil, True, CREATE_NO_WINDOW, nil,
      PChar(WorkingDirectory), LStartupInfo, LProcessInfo) then
    begin
      CloseHandle(LWritePipe);
      LWritePipe := 0;
      while ReadFile(LReadPipe, LBuffer, SizeOf(LBuffer), LBytesRead, nil) and (LBytesRead > 0) do
      begin
        SetString(LChunk, PAnsiChar(@LBuffer[0]), LBytesRead);
        Result := Result + string(LChunk);
      end;
      WaitForSingleObject(LProcessInfo.hProcess, 2000);
      CloseHandle(LProcessInfo.hThread);
      CloseHandle(LProcessInfo.hProcess);
    end;
  finally
    if LWritePipe <> 0 then
      CloseHandle(LWritePipe);
    CloseHandle(LReadPipe);
  end;
end;

function GetCurrentBranchName(const RepositoryRoot: string): string;
var
  LOutput: string;
begin
  Result := '';
  if RepositoryRoot = '' then
    Exit;

  LOutput := ReadPipeText('"' + Git4DSettings.GitExecutable + '" branch --show-current', RepositoryRoot);
  Result := Trim(LOutput);
end;

end.

