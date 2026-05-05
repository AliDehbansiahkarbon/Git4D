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
  FBackgroundFetchEnabled := False;
  FBackgroundFetchIntervalSeconds := 300;
  FAutoCloseConsoleOnSuccess := False;
end;

function TGit4DSettings.GetSettingsFileName: string;
var
  SettingsDir: string;
begin
  SettingsDir := GetSettingsDirectory(cG4DProductName);
  Result := TPath.Combine(SettingsDir, cG4DSettingsFileName);
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
  Ini: TIniFile;
  IniFileName: string;
begin
  IniFileName := SettingsFileName;
  if (not FileExists(IniFileName)) and FileExists(GetLegacySettingsFileName) then
    IniFileName := GetLegacySettingsFileName;

  Ini := TIniFile.Create(IniFileName);
  try
    FGitExecutable := Ini.ReadString('Git', 'GitExecutable', FGitExecutable);
    FGitBashExecutable := Ini.ReadString('Git', 'GitBashExecutable', FGitBashExecutable);
    FDefaultCloneDirectory := Ini.ReadString('Git', 'DefaultCloneDirectory', FDefaultCloneDirectory);
    FEditorPopupEnabled := Ini.ReadBool('IDE', 'EditorPopupEnabled', FEditorPopupEnabled);
    FShowBranchInMenu := Ini.ReadBool('IDE', 'ShowBranchInMenu', FShowBranchInMenu);
    FShowConfirmationForDestructiveActions := Ini.ReadBool('IDE', 'ShowConfirmationForDestructiveActions', FShowConfirmationForDestructiveActions);
    FGitExtensionsEnabled := Ini.ReadBool('GitExtensions', 'Enabled', FGitExtensionsEnabled);
    FGitExtensionsExecutable := Ini.ReadString('GitExtensions', 'Executable', FGitExtensionsExecutable);
    FTortoiseGitEnabled := Ini.ReadBool('TortoiseGit', 'Enabled', FTortoiseGitEnabled);
    FTortoiseGitExecutable := Ini.ReadString('TortoiseGit', 'Executable', FTortoiseGitExecutable);
    FTortoiseSvnEnabled := Ini.ReadBool('TortoiseSVN', 'Enabled', FTortoiseSvnEnabled);
    FTortoiseSvnExecutable := Ini.ReadString('TortoiseSVN', 'Executable', FTortoiseSvnExecutable);
    FBackgroundFetchEnabled := Ini.ReadBool('BackgroundFetch', 'Enabled', FBackgroundFetchEnabled);
    FBackgroundFetchIntervalSeconds := Ini.ReadInteger('BackgroundFetch', 'IntervalSeconds', FBackgroundFetchIntervalSeconds);
    FAutoCloseConsoleOnSuccess := Ini.ReadBool('Process', 'AutoCloseConsoleOnSuccess', FAutoCloseConsoleOnSuccess);
  finally
    Ini.Free;
  end;
end;

procedure TGit4DSettings.Save;
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(SettingsFileName);
  try
    Ini.WriteString('Git', 'GitExecutable', FGitExecutable);
    Ini.WriteString('Git', 'GitBashExecutable', FGitBashExecutable);
    Ini.WriteString('Git', 'DefaultCloneDirectory', FDefaultCloneDirectory);
    Ini.WriteBool('IDE', 'EditorPopupEnabled', FEditorPopupEnabled);
    Ini.WriteBool('IDE', 'ShowBranchInMenu', FShowBranchInMenu);
    Ini.WriteBool('IDE', 'ShowConfirmationForDestructiveActions', FShowConfirmationForDestructiveActions);
    Ini.WriteBool('GitExtensions', 'Enabled', FGitExtensionsEnabled);
    Ini.WriteString('GitExtensions', 'Executable', FGitExtensionsExecutable);
    Ini.WriteBool('TortoiseGit', 'Enabled', FTortoiseGitEnabled);
    Ini.WriteString('TortoiseGit', 'Executable', FTortoiseGitExecutable);
    Ini.WriteBool('TortoiseSVN', 'Enabled', FTortoiseSvnEnabled);
    Ini.WriteString('TortoiseSVN', 'Executable', FTortoiseSvnExecutable);
    Ini.WriteBool('BackgroundFetch', 'Enabled', FBackgroundFetchEnabled);
    Ini.WriteInteger('BackgroundFetch', 'IntervalSeconds', FBackgroundFetchIntervalSeconds);
    Ini.WriteBool('Process', 'AutoCloseConsoleOnSuccess', FAutoCloseConsoleOnSuccess);
  finally
    Ini.Free;
  end;
end;

initialization

finalization
  GSettings.Free;

end.

