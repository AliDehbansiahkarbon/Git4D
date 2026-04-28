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
  DirectoryName: string;
  ParentName: string;
begin
  Result := Default(TGit4DRepository);
  Result.ActiveFileName := FileOrDirectory;

  DirectoryName := NormalizeStartDirectory(FileOrDirectory);
  while DirectoryName <> '' do
  begin
    if IsGitRoot(DirectoryName) then
    begin
      Result.RootPath := DirectoryName;
      Result.IsValid := True;
      Exit;
    end;

    ParentName := TPath.GetDirectoryName(DirectoryName);
    if SameText(ParentName, DirectoryName) then
      Break;
    DirectoryName := ParentName;
  end;
end;

function TryGetActiveModuleFileName: string;
var
  ModuleServices: IOTAModuleServices;
  Module: IOTAModule;
begin
  Result := '';
  try
    ModuleServices := BorlandIDEServices as IOTAModuleServices;
    Module := ModuleServices.CurrentModule;
    if Module <> nil then
      Result := Module.FileName;
  except
    Result := '';
  end;
end;

function TryGetActiveProjectFileName: string;
var
  ModuleServices: IOTAModuleServices;
  Project: IOTAProject;
begin
  Result := '';
  try
    ModuleServices := BorlandIDEServices as IOTAModuleServices;
    Project := ModuleServices.GetActiveProject;
    if Project <> nil then
      Result := Project.FileName;
  except
    Result := '';
  end;
end;

function DiscoverActiveRepository: TGit4DRepository;
var
  ActiveFileName: string;
  ProjectFileName: string;
begin
  ActiveFileName := TryGetActiveModuleFileName;
  ProjectFileName := TryGetActiveProjectFileName;

  if ActiveFileName <> '' then
    Result := DiscoverRepository(ActiveFileName)
  else
    Result := DiscoverRepository(ProjectFileName);

  Result.ActiveFileName := ActiveFileName;
  Result.ProjectFileName := ProjectFileName;
end;

function ReadPipeText(const CommandLine, WorkingDirectory: string): string;
var
  SecurityAttributes: TSecurityAttributes;
  ReadPipe: THandle;
  WritePipe: THandle;
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
  Buffer: array[0..2047] of AnsiChar;
  BytesRead: DWORD;
  Chunk: AnsiString;
  MutableCommandLine: string;
begin
  Result := '';
  SecurityAttributes.nLength := SizeOf(SecurityAttributes);
  SecurityAttributes.bInheritHandle := True;
  SecurityAttributes.lpSecurityDescriptor := nil;

  if not CreatePipe(ReadPipe, WritePipe, @SecurityAttributes, 0) then
    Exit;
  try
    SetHandleInformation(ReadPipe, HANDLE_FLAG_INHERIT, 0);
    ZeroMemory(@StartupInfo, SizeOf(StartupInfo));
    StartupInfo.cb := SizeOf(StartupInfo);
    StartupInfo.dwFlags := STARTF_USESHOWWINDOW or STARTF_USESTDHANDLES;
    StartupInfo.wShowWindow := SW_HIDE;
    StartupInfo.hStdOutput := WritePipe;
    StartupInfo.hStdError := WritePipe;

    ZeroMemory(@ProcessInfo, SizeOf(ProcessInfo));
    MutableCommandLine := CommandLine;
    if CreateProcess(nil, PChar(MutableCommandLine), nil, nil, True, CREATE_NO_WINDOW, nil,
      PChar(WorkingDirectory), StartupInfo, ProcessInfo) then
    begin
      CloseHandle(WritePipe);
      WritePipe := 0;
      while ReadFile(ReadPipe, Buffer, SizeOf(Buffer), BytesRead, nil) and (BytesRead > 0) do
      begin
        SetString(Chunk, PAnsiChar(@Buffer[0]), BytesRead);
        Result := Result + string(Chunk);
      end;
      WaitForSingleObject(ProcessInfo.hProcess, 2000);
      CloseHandle(ProcessInfo.hThread);
      CloseHandle(ProcessInfo.hProcess);
    end;
  finally
    if WritePipe <> 0 then
      CloseHandle(WritePipe);
    CloseHandle(ReadPipe);
  end;
end;

function GetCurrentBranchName(const RepositoryRoot: string): string;
var
  Output: string;
begin
  Result := '';
  if RepositoryRoot = '' then
    Exit;

  Output := ReadPipeText('"' + Git4DSettings.GitExecutable + '" branch --show-current', RepositoryRoot);
  Result := Trim(Output);
end;

end.

