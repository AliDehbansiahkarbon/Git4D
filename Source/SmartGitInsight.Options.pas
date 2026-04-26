unit SmartGitInsight.Options;

interface

uses
  System.Classes,
  Vcl.Controls,
  Vcl.ExtCtrls,
  Vcl.Forms,
  Vcl.StdCtrls,
  ToolsAPI;

type
  TSmartGitInsightOptionsFrame = class(TFrame)
  private
    FAutoCloseCheck: TCheckBox;
    FBackgroundFetchCheck: TCheckBox;
    FBashEdit: TEdit;
    FCloneEdit: TEdit;
    FConfirmCheck: TCheckBox;
    FGitEdit: TEdit;
    FShowBranchCheck: TCheckBox;
    FTortoiseGitCheck: TCheckBox;
    FTortoiseGitEdit: TEdit;
    procedure AddLabeledEdit(const ACaption: string; var ATop: Integer; out AEdit: TEdit);
    procedure AddCheckBox(const ACaption: string; var ATop: Integer; out ACheckBox: TCheckBox);
  public
    constructor Create(AOwner: TComponent); override;
    procedure LoadSettings;
    procedure SaveSettings;
  end;

  TSmartGitInsightAddInOptions = class(TInterfacedObject, INTAAddInOptions)
  private
    FFrame: TSmartGitInsightOptionsFrame;
  public
    function GetArea: string;
    function GetCaption: string;
    function GetFrameClass: TCustomFrameClass;
    procedure FrameCreated(AFrame: TCustomFrame);
    procedure DialogClosed(Accepted: Boolean);
    function ValidateContents: Boolean;
    function GetHelpContext: Integer;
    function IncludeInIDEInsight: Boolean;
  end;

procedure RegisterSmartGitInsightOptions;
procedure UnregisterSmartGitInsightOptions;
procedure OpenSmartGitInsightOptions;

implementation

{$R *.dfm}

uses
  System.SysUtils,
  Vcl.Dialogs,
  SmartGitInsight.Constants,
  SmartGitInsight.Settings,
  SmartGitInsight.TortoiseGit;

var
  GAddInOptions: INTAAddInOptions;

procedure RegisterSmartGitInsightOptions;
var
  Services: INTAEnvironmentOptionsServices;
begin
  if GAddInOptions <> nil then
    Exit;

  if Supports(BorlandIDEServices, INTAEnvironmentOptionsServices, Services) then
  begin
    GAddInOptions := TSmartGitInsightAddInOptions.Create;
    Services.RegisterAddInOptions(GAddInOptions);
  end;
end;

procedure UnregisterSmartGitInsightOptions;
var
  Services: INTAEnvironmentOptionsServices;
begin
  if GAddInOptions = nil then
    Exit;

  if Supports(BorlandIDEServices, INTAEnvironmentOptionsServices, Services) then
    Services.UnregisterAddInOptions(GAddInOptions);
  GAddInOptions := nil;
end;

procedure OpenSmartGitInsightOptions;
var
  Options: IOTAEnvironmentOptions;
begin
  if Supports((BorlandIDEServices as IOTAServices).GetEnvironmentOptions, IOTAEnvironmentOptions140, Options) then
    (Options as IOTAEnvironmentOptions140).EditOptions('', SGIProductName)
  else
    MessageDlg('Open Tools > Options > Third Party > ' + SGIProductName + ' to configure Smart GitInsight.',
      mtInformation, [mbOK], 0);
end;

constructor TSmartGitInsightOptionsFrame.Create(AOwner: TComponent);
var
  Top: Integer;
begin
  inherited Create(AOwner);
  Align := alClient;
  BevelOuter := bvNone;
  ParentBackground := False;

  Top := 18;
  AddLabeledEdit('Git executable', Top, FGitEdit);
  AddLabeledEdit('Git Bash executable', Top, FBashEdit);
  AddLabeledEdit('Default clone folder', Top, FCloneEdit);
  AddCheckBox('Show current branch in Smart GitInsight menus', Top, FShowBranchCheck);
  AddCheckBox('Confirm destructive commands', Top, FConfirmCheck);
  AddCheckBox('Enable background fetch', Top, FBackgroundFetchCheck);
  AddCheckBox('Close command console when process succeeds', Top, FAutoCloseCheck);
  Inc(Top, 10);
  AddCheckBox('Enable TortoiseGit submenu when installed', Top, FTortoiseGitCheck);
  AddLabeledEdit('TortoiseGitProc.exe', Top, FTortoiseGitEdit);

  LoadSettings;
end;

procedure TSmartGitInsightOptionsFrame.AddLabeledEdit(const ACaption: string; var ATop: Integer; out AEdit: TEdit);
var
  LabelControl: TLabel;
begin
  LabelControl := TLabel.Create(Self);
  LabelControl.Parent := Self;
  LabelControl.Left := 16;
  LabelControl.Top := ATop + 4;
  LabelControl.Caption := ACaption;

  AEdit := TEdit.Create(Self);
  AEdit.Parent := Self;
  AEdit.Left := 190;
  AEdit.Top := ATop;
  AEdit.Width := 420;
  Inc(ATop, 32);
end;

procedure TSmartGitInsightOptionsFrame.AddCheckBox(const ACaption: string; var ATop: Integer; out ACheckBox: TCheckBox);
begin
  ACheckBox := TCheckBox.Create(Self);
  ACheckBox.Parent := Self;
  ACheckBox.Left := 190;
  ACheckBox.Top := ATop;
  ACheckBox.Width := 420;
  ACheckBox.Caption := ACaption;
  Inc(ATop, 28);
end;

procedure TSmartGitInsightOptionsFrame.LoadSettings;
begin
  FGitEdit.Text := SmartGitInsightSettings.GitExecutable;
  FBashEdit.Text := SmartGitInsightSettings.GitBashExecutable;
  FCloneEdit.Text := SmartGitInsightSettings.DefaultCloneDirectory;
  FShowBranchCheck.Checked := SmartGitInsightSettings.ShowBranchInMenu;
  FConfirmCheck.Checked := SmartGitInsightSettings.ShowConfirmationForDestructiveActions;
  FBackgroundFetchCheck.Checked := SmartGitInsightSettings.BackgroundFetchEnabled;
  FAutoCloseCheck.Checked := SmartGitInsightSettings.AutoCloseConsoleOnSuccess;
  FTortoiseGitCheck.Checked := SmartGitInsightSettings.TortoiseGitEnabled;
  FTortoiseGitEdit.Text := SmartGitInsightSettings.TortoiseGitExecutable;
  if FTortoiseGitEdit.Text = '' then
    FTortoiseGitEdit.Text := TSmartGitInsightTortoiseGit.DetectExecutable;
end;

procedure TSmartGitInsightOptionsFrame.SaveSettings;
begin
  SmartGitInsightSettings.GitExecutable := FGitEdit.Text;
  SmartGitInsightSettings.GitBashExecutable := FBashEdit.Text;
  SmartGitInsightSettings.DefaultCloneDirectory := FCloneEdit.Text;
  SmartGitInsightSettings.ShowBranchInMenu := FShowBranchCheck.Checked;
  SmartGitInsightSettings.ShowConfirmationForDestructiveActions := FConfirmCheck.Checked;
  SmartGitInsightSettings.BackgroundFetchEnabled := FBackgroundFetchCheck.Checked;
  SmartGitInsightSettings.AutoCloseConsoleOnSuccess := FAutoCloseCheck.Checked;
  SmartGitInsightSettings.TortoiseGitEnabled := FTortoiseGitCheck.Checked;
  SmartGitInsightSettings.TortoiseGitExecutable := FTortoiseGitEdit.Text;
  SmartGitInsightSettings.Save;
end;

function TSmartGitInsightAddInOptions.GetArea: string;
begin
  Result := '';
end;

function TSmartGitInsightAddInOptions.GetCaption: string;
begin
  Result := SGIProductName;
end;

function TSmartGitInsightAddInOptions.GetFrameClass: TCustomFrameClass;
begin
  Result := TSmartGitInsightOptionsFrame;
end;

procedure TSmartGitInsightAddInOptions.FrameCreated(AFrame: TCustomFrame);
begin
  FFrame := AFrame as TSmartGitInsightOptionsFrame;
  FFrame.LoadSettings;
end;

procedure TSmartGitInsightAddInOptions.DialogClosed(Accepted: Boolean);
begin
  if Accepted and (FFrame <> nil) then
    FFrame.SaveSettings;
  FFrame := nil;
end;

function TSmartGitInsightAddInOptions.ValidateContents: Boolean;
begin
  Result := True;
  if (FFrame <> nil) and (Trim(FFrame.FGitEdit.Text) = '') then
  begin
    Result := False;
    MessageDlg('Git executable cannot be empty.', mtError, [mbOK], 0);
  end;
end;

function TSmartGitInsightAddInOptions.GetHelpContext: Integer;
begin
  Result := 0;
end;

function TSmartGitInsightAddInOptions.IncludeInIDEInsight: Boolean;
begin
  Result := True;
end;

end.
