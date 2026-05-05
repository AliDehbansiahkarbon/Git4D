unit Git4D.Settings;

interface

type
  TGit4DSettings = class
  private
    FAutoCloseConsoleOnSuccess: Boolean;
    FBackgroundFetchEnabled: Boolean;
    FBackgroundFetchIntervalSeconds: Integer;
    FDefaultCloneDirectory: string;
    FEditorPopupEnabled: Boolean;
    FGitBashExecutable: string;
    FGitExtensionsEnabled: Boolean;
    FGitExtensionsExecutable: string;
    FGitExecutable: string;
    FShowBranchInMenu: Boolean;
    FShowConfirmationForDestructiveActions: Boolean;
    FTortoiseGitEnabled: Boolean;
    FTortoiseGitExecutable: string;
    FTortoiseSvnEnabled: Boolean;
    FTortoiseSvnExecutable: string;
    FWorkbenchTerminalEnabled: Boolean;
    FWorkbenchTerminalWordWrap: Boolean;
    function GetLegacySettingsFileName: string;
    function GetSettingsDirectory(const ProductName: string): string;
    function GetSettingsFileName: string;
  public
    constructor Create;
    procedure Load;
    procedure Save;
    property SettingsFileName: string read GetSettingsFileName;
    property GitExecutable: string read FGitExecutable write FGitExecutable;
    property GitBashExecutable: string read FGitBashExecutable write FGitBashExecutable;
    property GitExtensionsEnabled: Boolean read FGitExtensionsEnabled write FGitExtensionsEnabled;
    property GitExtensionsExecutable: string read FGitExtensionsExecutable write FGitExtensionsExecutable;
    property DefaultCloneDirectory: string read FDefaultCloneDirectory write FDefaultCloneDirectory;
    property EditorPopupEnabled: Boolean read FEditorPopupEnabled write FEditorPopupEnabled;
    property ShowBranchInMenu: Boolean read FShowBranchInMenu write FShowBranchInMenu;
    property ShowConfirmationForDestructiveActions: Boolean read FShowConfirmationForDestructiveActions write FShowConfirmationForDestructiveActions;
    property TortoiseGitEnabled: Boolean read FTortoiseGitEnabled write FTortoiseGitEnabled;
    property TortoiseGitExecutable: string read FTortoiseGitExecutable write FTortoiseGitExecutable;
    property TortoiseSvnEnabled: Boolean read FTortoiseSvnEnabled write FTortoiseSvnEnabled;
    property TortoiseSvnExecutable: string read FTortoiseSvnExecutable write FTortoiseSvnExecutable;
    property WorkbenchTerminalEnabled: Boolean read FWorkbenchTerminalEnabled write FWorkbenchTerminalEnabled;
    property WorkbenchTerminalWordWrap: Boolean read FWorkbenchTerminalWordWrap write FWorkbenchTerminalWordWrap;
    property BackgroundFetchEnabled: Boolean read FBackgroundFetchEnabled write FBackgroundFetchEnabled;
    property BackgroundFetchIntervalSeconds: Integer read FBackgroundFetchIntervalSeconds write FBackgroundFetchIntervalSeconds;
    property AutoCloseConsoleOnSuccess: Boolean read FAutoCloseConsoleOnSuccess write FAutoCloseConsoleOnSuccess;
  end;

function Git4DSettings: TGit4DSettings;

implementation

uses
  System.IniFiles,
  System.IOUtils,
  System.SysUtils,
  Git4D.Constants;

var
  GSettings: TGit4DSettings;

function Git4DSettings: TGit4DSettings;
begin
  if GSettings = nil then
  begin
    GSettings := TGit4DSettings.Create;
    GSettings.Load;
  end;
  Result := GSettings;
end;

constructor TGit4DSettings.Create;
begin
  inherited Create;
  FGitExecutable := 'git.exe';
  FGitBashExecutable := '';
  FDefaultCloneDirectory := TPath.Combine(TPath.GetDocumentsPath, 'Git');
  FEditorPopupEnabled := True;
  FShowBranchInMenu := True;
  FShowConfirmationForDestructiveActions := True;
  FGitExtensionsEnabled := False;
  FGitExtensionsExecutable := '';
  FTortoiseGitEnabled := False;
  FTortoiseGitExecutable := '';
  FTortoiseSvnEnabled := False;
  FTortoiseSvnExecutable := '';
  FWorkbenchTerminalEnabled := True;
  FWorkbenchTerminalWordWrap := True;
  FBackgroundFetchEnabled := False;
  FBackgroundFetchIntervalSeconds := 300;
  FAutoCloseConsoleOnSuccess := False;
end;

function TGit4DSettings.GetSettingsFileName: string;
var
  LSettingsDir: string;
begin
  LSettingsDir := GetSettingsDirectory(cG4DProductName);
  Result := TPath.Combine(LSettingsDir, cG4DSettingsFileName);
end;

function TGit4DSettings.GetLegacySettingsFileName: string;
begin
  Result := TPath.Combine(GetSettingsDirectory('Smart GitInsight'), 'SmartGitInsight.ini');
end;

function TGit4DSettings.GetSettingsDirectory(const ProductName: string): string;
begin
  Result := TPath.Combine(TPath.GetHomePath, ProductName);
  ForceDirectories(Result);
end;

procedure TGit4DSettings.Load;
var
  LIni: TIniFile;
  LIniFileName: string;
begin
  LIniFileName := SettingsFileName;
  if (not FileExists(LIniFileName)) and FileExists(GetLegacySettingsFileName) then
    LIniFileName := GetLegacySettingsFileName;

  LIni := TIniFile.Create(LIniFileName);
  try
    FGitExecutable := LIni.ReadString('Git', 'GitExecutable', FGitExecutable);
    FGitBashExecutable := LIni.ReadString('Git', 'GitBashExecutable', FGitBashExecutable);
    FDefaultCloneDirectory := LIni.ReadString('Git', 'DefaultCloneDirectory', FDefaultCloneDirectory);
    FEditorPopupEnabled := LIni.ReadBool('IDE', 'EditorPopupEnabled', FEditorPopupEnabled);
    FShowBranchInMenu := LIni.ReadBool('IDE', 'ShowBranchInMenu', FShowBranchInMenu);
    FShowConfirmationForDestructiveActions := LIni.ReadBool('IDE', 'ShowConfirmationForDestructiveActions', FShowConfirmationForDestructiveActions);
    FGitExtensionsEnabled := LIni.ReadBool('GitExtensions', 'Enabled', FGitExtensionsEnabled);
    FGitExtensionsExecutable := LIni.ReadString('GitExtensions', 'Executable', FGitExtensionsExecutable);
    FTortoiseGitEnabled := LIni.ReadBool('TortoiseGit', 'Enabled', FTortoiseGitEnabled);
    FTortoiseGitExecutable := LIni.ReadString('TortoiseGit', 'Executable', FTortoiseGitExecutable);
    FTortoiseSvnEnabled := LIni.ReadBool('TortoiseSVN', 'Enabled', FTortoiseSvnEnabled);
    FTortoiseSvnExecutable := LIni.ReadString('TortoiseSVN', 'Executable', FTortoiseSvnExecutable);
    FWorkbenchTerminalEnabled := LIni.ReadBool('Workbench', 'TerminalEnabled', FWorkbenchTerminalEnabled);
    FWorkbenchTerminalWordWrap := LIni.ReadBool('Workbench', 'TerminalWordWrap', FWorkbenchTerminalWordWrap);
    FBackgroundFetchEnabled := LIni.ReadBool('BackgroundFetch', 'Enabled', FBackgroundFetchEnabled);
    FBackgroundFetchIntervalSeconds := LIni.ReadInteger('BackgroundFetch', 'IntervalSeconds', FBackgroundFetchIntervalSeconds);
    FAutoCloseConsoleOnSuccess := LIni.ReadBool('Process', 'AutoCloseConsoleOnSuccess', FAutoCloseConsoleOnSuccess);
  finally
    LIni.Free;
  end;
end;

procedure TGit4DSettings.Save;
var
  LIni: TIniFile;
begin
  LIni := TIniFile.Create(SettingsFileName);
  try
    LIni.WriteString('Git', 'GitExecutable', FGitExecutable);
    LIni.WriteString('Git', 'GitBashExecutable', FGitBashExecutable);
    LIni.WriteString('Git', 'DefaultCloneDirectory', FDefaultCloneDirectory);
    LIni.WriteBool('IDE', 'EditorPopupEnabled', FEditorPopupEnabled);
    LIni.WriteBool('IDE', 'ShowBranchInMenu', FShowBranchInMenu);
    LIni.WriteBool('IDE', 'ShowConfirmationForDestructiveActions', FShowConfirmationForDestructiveActions);
    LIni.WriteBool('GitExtensions', 'Enabled', FGitExtensionsEnabled);
    LIni.WriteString('GitExtensions', 'Executable', FGitExtensionsExecutable);
    LIni.WriteBool('TortoiseGit', 'Enabled', FTortoiseGitEnabled);
    LIni.WriteString('TortoiseGit', 'Executable', FTortoiseGitExecutable);
    LIni.WriteBool('TortoiseSVN', 'Enabled', FTortoiseSvnEnabled);
    LIni.WriteString('TortoiseSVN', 'Executable', FTortoiseSvnExecutable);
    LIni.WriteBool('Workbench', 'TerminalEnabled', FWorkbenchTerminalEnabled);
    LIni.WriteBool('Workbench', 'TerminalWordWrap', FWorkbenchTerminalWordWrap);
    LIni.WriteBool('BackgroundFetch', 'Enabled', FBackgroundFetchEnabled);
    LIni.WriteInteger('BackgroundFetch', 'IntervalSeconds', FBackgroundFetchIntervalSeconds);
    LIni.WriteBool('Process', 'AutoCloseConsoleOnSuccess', FAutoCloseConsoleOnSuccess);
  finally
    LIni.Free;
  end;
end;

initialization

finalization
  GSettings.Free;

end.

