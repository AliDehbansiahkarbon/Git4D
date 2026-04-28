unit Git4D.Dialogs;

interface

procedure ShowGit4DSettingsDialog;
procedure ShowGit4DAboutDialog;

implementation

uses
  System.Classes,
  System.SysUtils,
  Vcl.Controls,
  Vcl.Dialogs,
  Vcl.ExtCtrls,
  Vcl.Forms,
  Vcl.StdCtrls,
  Git4D.Constants,
  Git4D.Settings;

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

procedure ShowGit4DSettingsDialog;
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
    Form.Caption := G4DProductName + ' Settings';
    Form.BorderStyle := bsDialog;
    Form.Position := poScreenCenter;
    Form.ClientWidth := 590;
    Form.ClientHeight := 330;

    Top := 18;
    AddLabeledEdit(Form, Form, 'Git executable', Top, GitEdit, Git4DSettings.GitExecutable);
    AddLabeledEdit(Form, Form, 'Git Bash executable', Top, BashEdit, Git4DSettings.GitBashExecutable);
    AddLabeledEdit(Form, Form, 'Default clone folder', Top, CloneEdit, Git4DSettings.DefaultCloneDirectory);

    BranchCheck := TCheckBox.Create(Form);
    BranchCheck.Parent := Form;
    BranchCheck.Left := 180;
    BranchCheck.Top := Top;
    BranchCheck.Width := 380;
    BranchCheck.Caption := 'Show current branch in the Git4D menu';
    BranchCheck.Checked := Git4DSettings.ShowBranchInMenu;
    Inc(Top, 28);

    ConfirmCheck := TCheckBox.Create(Form);
    ConfirmCheck.Parent := Form;
    ConfirmCheck.Left := 180;
    ConfirmCheck.Top := Top;
    ConfirmCheck.Width := 380;
    ConfirmCheck.Caption := 'Confirm destructive commands';
    ConfirmCheck.Checked := Git4DSettings.ShowConfirmationForDestructiveActions;
    Inc(Top, 28);

    BackgroundFetchCheck := TCheckBox.Create(Form);
    BackgroundFetchCheck.Parent := Form;
    BackgroundFetchCheck.Left := 180;
    BackgroundFetchCheck.Top := Top;
    BackgroundFetchCheck.Width := 380;
    BackgroundFetchCheck.Caption := 'Enable background fetch';
    BackgroundFetchCheck.Checked := Git4DSettings.BackgroundFetchEnabled;
    Inc(Top, 28);

    AutoCloseCheck := TCheckBox.Create(Form);
    AutoCloseCheck.Parent := Form;
    AutoCloseCheck.Left := 180;
    AutoCloseCheck.Top := Top;
    AutoCloseCheck.Width := 380;
    AutoCloseCheck.Caption := 'Close command console when the process succeeds';
    AutoCloseCheck.Checked := Git4DSettings.AutoCloseConsoleOnSuccess;

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
      Git4DSettings.GitExecutable := GitEdit.Text;
      Git4DSettings.GitBashExecutable := BashEdit.Text;
      Git4DSettings.DefaultCloneDirectory := CloneEdit.Text;
      Git4DSettings.ShowBranchInMenu := BranchCheck.Checked;
      Git4DSettings.ShowConfirmationForDestructiveActions := ConfirmCheck.Checked;
      Git4DSettings.BackgroundFetchEnabled := BackgroundFetchCheck.Checked;
      Git4DSettings.AutoCloseConsoleOnSuccess := AutoCloseCheck.Checked;
      Git4DSettings.Save;
    end;
  finally
    Form.Free;
  end;
end;

procedure ShowGit4DAboutDialog;
begin
  MessageDlg(G4DProductName + sLineBreak + sLineBreak +
    'RAD Studio Git client for Delphi and C++Builder.' + sLineBreak +
    'This build provides the IDE integration and Git command surface foundation.',
    mtInformation, [mbOK], 0);
end;

end.

