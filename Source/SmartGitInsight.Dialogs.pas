unit SmartGitInsight.Dialogs;

interface

procedure ShowSmartGitInsightSettingsDialog;
procedure ShowSmartGitInsightAboutDialog;

implementation

uses
  System.Classes,
  System.SysUtils,
  Vcl.Controls,
  Vcl.Dialogs,
  Vcl.ExtCtrls,
  Vcl.Forms,
  Vcl.StdCtrls,
  SmartGitInsight.Constants,
  SmartGitInsight.Settings;

procedure AddLabeledEdit(AOwner: TComponent; AParent: TWinControl; const Caption: string;
  var Top: Integer; out Edit: TEdit; const Text: string);
var
  LabelControl: TLabel;
begin
  LabelControl := TLabel.Create(AOwner);
  LabelControl.Parent := AParent;
  LabelControl.Left := 16;
  LabelControl.Top := Top + 4;
  LabelControl.Caption := Caption;

  Edit := TEdit.Create(AOwner);
  Edit.Parent := AParent;
  Edit.Left := 180;
  Edit.Top := Top;
  Edit.Width := 380;
  Edit.Text := Text;
  Inc(Top, 32);
end;

procedure ShowSmartGitInsightSettingsDialog;
var
  Form: TForm;
  GitEdit: TEdit;
  BashEdit: TEdit;
  CloneEdit: TEdit;
  BranchCheck: TCheckBox;
  ConfirmCheck: TCheckBox;
  BackgroundFetchCheck: TCheckBox;
  AutoCloseCheck: TCheckBox;
  ButtonPanel: TPanel;
  OkButton: TButton;
  CancelButton: TButton;
  Top: Integer;
begin
  Form := TForm.Create(nil);
  try
    Form.Caption := SGIProductName + ' Settings';
    Form.BorderStyle := bsDialog;
    Form.Position := poScreenCenter;
    Form.ClientWidth := 590;
    Form.ClientHeight := 330;

    Top := 18;
    AddLabeledEdit(Form, Form, 'Git executable', Top, GitEdit, SmartGitInsightSettings.GitExecutable);
    AddLabeledEdit(Form, Form, 'Git Bash executable', Top, BashEdit, SmartGitInsightSettings.GitBashExecutable);
    AddLabeledEdit(Form, Form, 'Default clone folder', Top, CloneEdit, SmartGitInsightSettings.DefaultCloneDirectory);

    BranchCheck := TCheckBox.Create(Form);
    BranchCheck.Parent := Form;
    BranchCheck.Left := 180;
    BranchCheck.Top := Top;
    BranchCheck.Width := 380;
    BranchCheck.Caption := 'Show current branch in the Smart GitInsight menu';
    BranchCheck.Checked := SmartGitInsightSettings.ShowBranchInMenu;
    Inc(Top, 28);

    ConfirmCheck := TCheckBox.Create(Form);
    ConfirmCheck.Parent := Form;
    ConfirmCheck.Left := 180;
    ConfirmCheck.Top := Top;
    ConfirmCheck.Width := 380;
    ConfirmCheck.Caption := 'Confirm destructive commands';
    ConfirmCheck.Checked := SmartGitInsightSettings.ShowConfirmationForDestructiveActions;
    Inc(Top, 28);

    BackgroundFetchCheck := TCheckBox.Create(Form);
    BackgroundFetchCheck.Parent := Form;
    BackgroundFetchCheck.Left := 180;
    BackgroundFetchCheck.Top := Top;
    BackgroundFetchCheck.Width := 380;
    BackgroundFetchCheck.Caption := 'Enable background fetch';
    BackgroundFetchCheck.Checked := SmartGitInsightSettings.BackgroundFetchEnabled;
    Inc(Top, 28);

    AutoCloseCheck := TCheckBox.Create(Form);
    AutoCloseCheck.Parent := Form;
    AutoCloseCheck.Left := 180;
    AutoCloseCheck.Top := Top;
    AutoCloseCheck.Width := 380;
    AutoCloseCheck.Caption := 'Close command console when the process succeeds';
    AutoCloseCheck.Checked := SmartGitInsightSettings.AutoCloseConsoleOnSuccess;

    ButtonPanel := TPanel.Create(Form);
    ButtonPanel.Parent := Form;
    ButtonPanel.Align := alBottom;
    ButtonPanel.Height := 48;
    ButtonPanel.BevelOuter := bvNone;

    OkButton := TButton.Create(Form);
    OkButton.Parent := ButtonPanel;
    OkButton.Caption := 'OK';
    OkButton.ModalResult := mrOK;
    OkButton.Left := 410;
    OkButton.Top := 10;
    OkButton.Default := True;

    CancelButton := TButton.Create(Form);
    CancelButton.Parent := ButtonPanel;
    CancelButton.Caption := 'Cancel';
    CancelButton.ModalResult := mrCancel;
    CancelButton.Left := 495;
    CancelButton.Top := 10;
    CancelButton.Cancel := True;

    if Form.ShowModal = mrOK then
    begin
      SmartGitInsightSettings.GitExecutable := GitEdit.Text;
      SmartGitInsightSettings.GitBashExecutable := BashEdit.Text;
      SmartGitInsightSettings.DefaultCloneDirectory := CloneEdit.Text;
      SmartGitInsightSettings.ShowBranchInMenu := BranchCheck.Checked;
      SmartGitInsightSettings.ShowConfirmationForDestructiveActions := ConfirmCheck.Checked;
      SmartGitInsightSettings.BackgroundFetchEnabled := BackgroundFetchCheck.Checked;
      SmartGitInsightSettings.AutoCloseConsoleOnSuccess := AutoCloseCheck.Checked;
      SmartGitInsightSettings.Save;
    end;
  finally
    Form.Free;
  end;
end;

procedure ShowSmartGitInsightAboutDialog;
begin
  MessageDlg(SGIProductName + sLineBreak + sLineBreak +
    'RAD Studio Git client for Delphi and C++Builder.' + sLineBreak +
    'This build provides the IDE integration and Git command surface foundation.',
    mtInformation, [mbOK], 0);
end;

end.
