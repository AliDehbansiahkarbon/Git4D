unit SmartGitInsight.Settings;

interface

type
  TSmartGitInsightSettings = class
  private
    FAutoCloseConsoleOnSuccess: Boolean;
    FBackgroundFetchEnabled: Boolean;
    FBackgroundFetchIntervalSeconds: Integer;
    FDefaultCloneDirectory: string;
    FGitBashExecutable: string;
    FGitExecutable: string;
    FShowBranchInMenu: Boolean;
    FShowConfirmationForDestructiveActions: Boolean;
    FTortoiseGitEnabled: Boolean;
    FTortoiseGitExecutable: string;
    function GetSettingsFileName: string;
  public
    constructor Create;
    procedure Load;
    procedure Save;
    property SettingsFileName: string read GetSettingsFileName;
    property GitExecutable: string read FGitExecutable write FGitExecutable;
    property GitBashExecutable: string read FGitBashExecutable write FGitBashExecutable;
    property DefaultCloneDirectory: string read FDefaultCloneDirectory write FDefaultCloneDirectory;
    property ShowBranchInMenu: Boolean read FShowBranchInMenu write FShowBranchInMenu;
    property ShowConfirmationForDestructiveActions: Boolean read FShowConfirmationForDestructiveActions write FShowConfirmationForDestructiveActions;
    property TortoiseGitEnabled: Boolean read FTortoiseGitEnabled write FTortoiseGitEnabled;
    property TortoiseGitExecutable: string read FTortoiseGitExecutable write FTortoiseGitExecutable;
    property BackgroundFetchEnabled: Boolean read FBackgroundFetchEnabled write FBackgroundFetchEnabled;
    property BackgroundFetchIntervalSeconds: Integer read FBackgroundFetchIntervalSeconds write FBackgroundFetchIntervalSeconds;
    property AutoCloseConsoleOnSuccess: Boolean read FAutoCloseConsoleOnSuccess write FAutoCloseConsoleOnSuccess;
  end;

function SmartGitInsightSettings: TSmartGitInsightSettings;

implementation

uses
  System.IniFiles,
  System.IOUtils,
  System.SysUtils,
  SmartGitInsight.Constants;

var
  GSettings: TSmartGitInsightSettings;

function SmartGitInsightSettings: TSmartGitInsightSettings;
begin
  if GSettings = nil then
  begin
    GSettings := TSmartGitInsightSettings.Create;
    GSettings.Load;
  end;
  Result := GSettings;
end;

constructor TSmartGitInsightSettings.Create;
begin
  inherited Create;
  FGitExecutable := 'git.exe';
  FGitBashExecutable := '';
  FDefaultCloneDirectory := TPath.Combine(TPath.GetDocumentsPath, 'Git');
  FShowBranchInMenu := True;
  FShowConfirmationForDestructiveActions := True;
  FTortoiseGitEnabled := True;
  FTortoiseGitExecutable := '';
  FBackgroundFetchEnabled := False;
  FBackgroundFetchIntervalSeconds := 300;
  FAutoCloseConsoleOnSuccess := False;
end;

function TSmartGitInsightSettings.GetSettingsFileName: string;
var
  SettingsDir: string;
begin
  SettingsDir := TPath.Combine(TPath.GetHomePath, SGIProductName);
  ForceDirectories(SettingsDir);
  Result := TPath.Combine(SettingsDir, SGISettingsFileName);
end;

procedure TSmartGitInsightSettings.Load;
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(SettingsFileName);
  try
    FGitExecutable := Ini.ReadString('Git', 'GitExecutable', FGitExecutable);
    FGitBashExecutable := Ini.ReadString('Git', 'GitBashExecutable', FGitBashExecutable);
    FDefaultCloneDirectory := Ini.ReadString('Git', 'DefaultCloneDirectory', FDefaultCloneDirectory);
    FShowBranchInMenu := Ini.ReadBool('IDE', 'ShowBranchInMenu', FShowBranchInMenu);
    FShowConfirmationForDestructiveActions := Ini.ReadBool('IDE', 'ShowConfirmationForDestructiveActions', FShowConfirmationForDestructiveActions);
    FTortoiseGitEnabled := Ini.ReadBool('TortoiseGit', 'Enabled', FTortoiseGitEnabled);
    FTortoiseGitExecutable := Ini.ReadString('TortoiseGit', 'Executable', FTortoiseGitExecutable);
    FBackgroundFetchEnabled := Ini.ReadBool('BackgroundFetch', 'Enabled', FBackgroundFetchEnabled);
    FBackgroundFetchIntervalSeconds := Ini.ReadInteger('BackgroundFetch', 'IntervalSeconds', FBackgroundFetchIntervalSeconds);
    FAutoCloseConsoleOnSuccess := Ini.ReadBool('Process', 'AutoCloseConsoleOnSuccess', FAutoCloseConsoleOnSuccess);
  finally
    Ini.Free;
  end;
end;

procedure TSmartGitInsightSettings.Save;
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(SettingsFileName);
  try
    Ini.WriteString('Git', 'GitExecutable', FGitExecutable);
    Ini.WriteString('Git', 'GitBashExecutable', FGitBashExecutable);
    Ini.WriteString('Git', 'DefaultCloneDirectory', FDefaultCloneDirectory);
    Ini.WriteBool('IDE', 'ShowBranchInMenu', FShowBranchInMenu);
    Ini.WriteBool('IDE', 'ShowConfirmationForDestructiveActions', FShowConfirmationForDestructiveActions);
    Ini.WriteBool('TortoiseGit', 'Enabled', FTortoiseGitEnabled);
    Ini.WriteString('TortoiseGit', 'Executable', FTortoiseGitExecutable);
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
