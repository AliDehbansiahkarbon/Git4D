unit Git4D.Options;

interface

uses
  System.Classes,
  Vcl.Controls,
  Vcl.ExtCtrls,
  Vcl.Forms,
  Vcl.StdCtrls,
  ToolsAPI;

type
  TGit4DOptionsFrame = class(TFrame)
  private
    FAutoCloseCheck: TCheckBox;
    FBackgroundFetchCheck: TCheckBox;
    FBashEdit: TEdit;
    FCloneEdit: TEdit;
    FConfirmCheck: TCheckBox;
    FEditorPopupCheck: TCheckBox;
    FGitExtensionsCheck: TCheckBox;
    FGitExtensionsEdit: TEdit;
    FGitEdit: TEdit;
    FShowBranchCheck: TCheckBox;
    FTortoiseGitCheck: TCheckBox;
    FTortoiseGitEdit: TEdit;
    FTortoiseSvnCheck: TCheckBox;
    FTortoiseSvnEdit: TEdit;
    FWorkbenchTerminalCheck: TCheckBox;
    FWorkbenchTerminalWordWrapCheck: TCheckBox;
    procedure AddLabeledEdit(const ACaption: string; var ATop: Integer; out AEdit: TEdit);
    procedure AddCheckBox(const ACaption: string; var ATop: Integer; out ACheckBox: TCheckBox);
  public
    constructor Create(AOwner: TComponent); override;
    procedure LoadSettings;
    procedure SaveSettings;
  end;

  TGit4DAddInOptions = class(TInterfacedObject, INTAAddInOptions)
  private
    FFrame: TGit4DOptionsFrame;
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

procedure RegisterGit4DOptions;
procedure UnregisterGit4DOptions;
procedure OpenGit4DOptions;

implementation

{$R *.dfm}

uses
  System.SysUtils,
  Vcl.Dialogs,
  Git4D.Constants,
  Git4D.GitExtensions,
  Git4D.Settings,
  Git4D.Workbench,
  Git4D.TortoiseGit,
  Git4D.TortoiseSVN;

var
  GAddInOptions: INTAAddInOptions;

function ResolveGitExtensionsExecutable: string;
begin
  Result := Trim(Git4DSettings.GitExtensionsExecutable);
  if Result = '' then
    Result := Trim(TGit4DGitExtensions.EffectiveExecutable);
end;

function ResolveTortoiseGitExecutable: string;
begin
  Result := Trim(Git4DSettings.TortoiseGitExecutable);
  if Result = '' then
    Result := Trim(TGit4DTortoiseGit.EffectiveExecutable);
end;

function ResolveTortoiseSvnExecutable: string;
begin
  Result := Trim(Git4DSettings.TortoiseSvnExecutable);
  if Result = '' then
    Result := Trim(TGit4DTortoiseSVN.EffectiveExecutable);
end;

procedure RegisterGit4DOptions;
var
  LServices: INTAEnvironmentOptionsServices;
begin
  if GAddInOptions <> nil then
    Exit;

  if Supports(BorlandIDEServices, INTAEnvironmentOptionsServices, LServices) then
  begin
    GAddInOptions := TGit4DAddInOptions.Create;
    LServices.RegisterAddInOptions(GAddInOptions);
  end;
end;

procedure UnregisterGit4DOptions;
var
  LServices: INTAEnvironmentOptionsServices;
begin
  if GAddInOptions = nil then
    Exit;

  if Supports(BorlandIDEServices, INTAEnvironmentOptionsServices, LServices) then
    LServices.UnregisterAddInOptions(GAddInOptions);
  GAddInOptions := nil;
end;

procedure OpenGit4DOptions;
var
  LOptions: IOTAEnvironmentOptions;
  LServices: IOTAServices;
begin
  if Supports(BorlandIDEServices, IOTAServices, LServices) and
    Supports(LServices.GetEnvironmentOptions, IOTAEnvironmentOptions140, LOptions) then
    (LOptions as IOTAEnvironmentOptions140).EditOptions('', cG4DProductName)
  else
    MessageDlg('Open Tools > Options > Third Party > ' + cG4DProductName + ' to configure Git4D.',
      mtInformation, [mbOK], 0);
end;

constructor TGit4DOptionsFrame.Create(AOwner: TComponent);
var
  LTop: Integer;
begin
  inherited Create(AOwner);
  Align := alClient;
  BevelOuter := bvNone;
  ParentBackground := False;

  LTop := 18;
  AddLabeledEdit('Git executable', LTop, FGitEdit);
  AddLabeledEdit('Git Bash executable', LTop, FBashEdit);
  AddLabeledEdit('Default clone folder', LTop, FCloneEdit);
  AddCheckBox('Enable editor popup menu integration', LTop, FEditorPopupCheck);
  AddCheckBox('Show current branch in Git4D menus', LTop, FShowBranchCheck);
  AddCheckBox('Confirm destructive commands', LTop, FConfirmCheck);
  AddCheckBox('Enable background fetch', LTop, FBackgroundFetchCheck);
  AddCheckBox('Close command console when process succeeds', LTop, FAutoCloseCheck);
  AddCheckBox('Show Workbench terminal', LTop, FWorkbenchTerminalCheck);
  AddCheckBox('Word wrap Workbench terminal output', LTop, FWorkbenchTerminalWordWrapCheck);
  Inc(LTop, 10);
  AddCheckBox('Enable TortoiseGit submenu when installed', LTop, FTortoiseGitCheck);
  AddLabeledEdit('TortoiseGitProc.exe', LTop, FTortoiseGitEdit);
  Inc(LTop, 10);
  AddCheckBox('Enable TortoiseSVN submenu when installed', LTop, FTortoiseSvnCheck);
  AddLabeledEdit('TortoiseProc.exe', LTop, FTortoiseSvnEdit);
  Inc(LTop, 10);
  AddCheckBox('Enable Git Extensions submenu when installed', LTop, FGitExtensionsCheck);
  AddLabeledEdit('GitExtensions.exe', LTop, FGitExtensionsEdit);
end;

procedure TGit4DOptionsFrame.AddLabeledEdit(const ACaption: string; var ATop: Integer; out AEdit: TEdit);
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

procedure TGit4DOptionsFrame.AddCheckBox(const ACaption: string; var ATop: Integer; out ACheckBox: TCheckBox);
begin
  ACheckBox := TCheckBox.Create(Self);
  ACheckBox.Parent := Self;
  ACheckBox.Left := 190;
  ACheckBox.Top := ATop;
  ACheckBox.Width := 420;
  ACheckBox.Caption := ACaption;
  Inc(ATop, 28);
end;

procedure TGit4DOptionsFrame.LoadSettings;
begin
  FGitEdit.Text := Git4DSettings.GitExecutable;
  FBashEdit.Text := Git4DSettings.GitBashExecutable;
  FCloneEdit.Text := Git4DSettings.DefaultCloneDirectory;
  FEditorPopupCheck.Checked := Git4DSettings.EditorPopupEnabled;
  FShowBranchCheck.Checked := Git4DSettings.ShowBranchInMenu;
  FConfirmCheck.Checked := Git4DSettings.ShowConfirmationForDestructiveActions;
  FBackgroundFetchCheck.Checked := Git4DSettings.BackgroundFetchEnabled;
  FAutoCloseCheck.Checked := Git4DSettings.AutoCloseConsoleOnSuccess;
  FWorkbenchTerminalCheck.Checked := Git4DSettings.WorkbenchTerminalEnabled;
  FWorkbenchTerminalWordWrapCheck.Checked := Git4DSettings.WorkbenchTerminalWordWrap;
  FTortoiseGitCheck.Checked := Git4DSettings.TortoiseGitEnabled;
  FTortoiseGitEdit.Text := ResolveTortoiseGitExecutable;
  FTortoiseSvnCheck.Checked := Git4DSettings.TortoiseSvnEnabled;
  FTortoiseSvnEdit.Text := ResolveTortoiseSvnExecutable;
  FGitExtensionsCheck.Checked := Git4DSettings.GitExtensionsEnabled;
  FGitExtensionsEdit.Text := ResolveGitExtensionsExecutable;
end;

procedure TGit4DOptionsFrame.SaveSettings;
begin
  Git4DSettings.GitExecutable := FGitEdit.Text;
  Git4DSettings.GitBashExecutable := FBashEdit.Text;
  Git4DSettings.DefaultCloneDirectory := FCloneEdit.Text;
  Git4DSettings.EditorPopupEnabled := FEditorPopupCheck.Checked;
  Git4DSettings.ShowBranchInMenu := FShowBranchCheck.Checked;
  Git4DSettings.ShowConfirmationForDestructiveActions := FConfirmCheck.Checked;
  Git4DSettings.BackgroundFetchEnabled := FBackgroundFetchCheck.Checked;
  Git4DSettings.AutoCloseConsoleOnSuccess := FAutoCloseCheck.Checked;
  Git4DSettings.WorkbenchTerminalEnabled := FWorkbenchTerminalCheck.Checked;
  Git4DSettings.WorkbenchTerminalWordWrap := FWorkbenchTerminalWordWrapCheck.Checked;
  Git4DSettings.TortoiseGitEnabled := FTortoiseGitCheck.Checked;
  Git4DSettings.TortoiseGitExecutable := FTortoiseGitEdit.Text;
  Git4DSettings.TortoiseSvnEnabled := FTortoiseSvnCheck.Checked;
  Git4DSettings.TortoiseSvnExecutable := FTortoiseSvnEdit.Text;
  Git4DSettings.GitExtensionsEnabled := FGitExtensionsCheck.Checked;
  Git4DSettings.GitExtensionsExecutable := FGitExtensionsEdit.Text;
  Git4DSettings.Save;
  RefreshGit4DWorkbenchSettings;
end;

function TGit4DAddInOptions.GetArea: string;
begin
  Result := '';
end;

function TGit4DAddInOptions.GetCaption: string;
begin
  Result := cG4DProductName;
end;

function TGit4DAddInOptions.GetFrameClass: TCustomFrameClass;
begin
  Result := TGit4DOptionsFrame;
end;

procedure TGit4DAddInOptions.FrameCreated(AFrame: TCustomFrame);
begin
  FFrame := AFrame as TGit4DOptionsFrame;
  FFrame.LoadSettings;
end;

procedure TGit4DAddInOptions.DialogClosed(Accepted: Boolean);
begin
  if Accepted and (FFrame <> nil) then
    FFrame.SaveSettings;
  FFrame := nil;
end;

function TGit4DAddInOptions.ValidateContents: Boolean;
begin
  Result := True;
  if (FFrame <> nil) and (Trim(FFrame.FGitEdit.Text) = '') then
  begin
    Result := False;
    MessageDlg('Git executable cannot be empty.', mtError, [mbOK], 0);
  end;
end;

function TGit4DAddInOptions.GetHelpContext: Integer;
begin
  Result := 0;
end;

function TGit4DAddInOptions.IncludeInIDEInsight: Boolean;
begin
  Result := True;
end;

end.

