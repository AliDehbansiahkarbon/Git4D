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

procedure AddLabeledEdit(AOwner: TComponent; AParent: TWinControl; const ACaption: string;
  var ATop: Integer; out AEdit: TEdit; const Text: string);
var
  LLabelControl: TLabel;
begin
  LLabelControl := TLabel.Create(AOwner);
  LLabelControl.Parent := AParent;
  LLabelControl.Left := 16;
  LLabelControl.Top := ATop + 4;
  LLabelControl.Caption := ACaption;

  AEdit := TEdit.Create(AOwner);
  AEdit.Parent := AParent;
  AEdit.Left := 180;
  AEdit.Top := ATop;
  AEdit.Width := 380;
  AEdit.Text := Text;
  Inc(ATop, 32);
end;

procedure ShowGit4DSettingsDialog;
var
  LForm: TForm;
  LGitEdit: TEdit;
  LBashEdit: TEdit;
  LCloneEdit: TEdit;
  LBranchCheck: TCheckBox;
  LConfirmCheck: TCheckBox;
  LBackgroundFetchCheck: TCheckBox;
  LAutoCloseCheck: TCheckBox;
  LButtonPanel: TPanel;
  LOkButton: TButton;
  LCancelButton: TButton;
  LTop: Integer;
begin
  LForm := TForm.Create(nil);
  try
    LForm.Caption := cG4DProductName + ' Settings';
    LForm.BorderStyle := bsDialog;
    LForm.Position := poScreenCenter;
    LForm.ClientWidth := 590;
    LForm.ClientHeight := 330;

    LTop := 18;
    AddLabeledEdit(LForm, LForm, 'Git executable', LTop, LGitEdit, Git4DSettings.GitExecutable);
    AddLabeledEdit(LForm, LForm, 'Git Bash executable', LTop, LBashEdit, Git4DSettings.GitBashExecutable);
    AddLabeledEdit(LForm, LForm, 'Default clone folder', LTop, LCloneEdit, Git4DSettings.DefaultCloneDirectory);

    LBranchCheck := TCheckBox.Create(LForm);
    LBranchCheck.Parent := LForm;
    LBranchCheck.Left := 180;
    LBranchCheck.Top := LTop;
    LBranchCheck.Width := 380;
    LBranchCheck.Caption := 'Show current branch in the Git4D menu';
    LBranchCheck.Checked := Git4DSettings.ShowBranchInMenu;
    Inc(LTop, 28);

    LConfirmCheck := TCheckBox.Create(LForm);
    LConfirmCheck.Parent := LForm;
    LConfirmCheck.Left := 180;
    LConfirmCheck.Top := LTop;
    LConfirmCheck.Width := 380;
    LConfirmCheck.Caption := 'Confirm destructive commands';
    LConfirmCheck.Checked := Git4DSettings.ShowConfirmationForDestructiveActions;
    Inc(LTop, 28);

    LBackgroundFetchCheck := TCheckBox.Create(LForm);
    LBackgroundFetchCheck.Parent := LForm;
    LBackgroundFetchCheck.Left := 180;
    LBackgroundFetchCheck.Top := LTop;
    LBackgroundFetchCheck.Width := 380;
    LBackgroundFetchCheck.Caption := 'Enable background fetch';
    LBackgroundFetchCheck.Checked := Git4DSettings.BackgroundFetchEnabled;
    Inc(LTop, 28);

    LAutoCloseCheck := TCheckBox.Create(LForm);
    LAutoCloseCheck.Parent := LForm;
    LAutoCloseCheck.Left := 180;
    LAutoCloseCheck.Top := LTop;
    LAutoCloseCheck.Width := 380;
    LAutoCloseCheck.Caption := 'Close command console when the process succeeds';
    LAutoCloseCheck.Checked := Git4DSettings.AutoCloseConsoleOnSuccess;

    LButtonPanel := TPanel.Create(LForm);
    LButtonPanel.Parent := LForm;
    LButtonPanel.Align := alBottom;
    LButtonPanel.Height := 48;
    LButtonPanel.BevelOuter := bvNone;

    LOkButton := TButton.Create(LForm);
    LOkButton.Parent := LButtonPanel;
    LOkButton.Caption := 'OK';
    LOkButton.ModalResult := mrOK;
    LOkButton.Left := 410;
    LOkButton.Top := 10;
    LOkButton.Default := True;

    LCancelButton := TButton.Create(LForm);
    LCancelButton.Parent := LButtonPanel;
    LCancelButton.Caption := 'Cancel';
    LCancelButton.ModalResult := mrCancel;
    LCancelButton.Left := 495;
    LCancelButton.Top := 10;
    LCancelButton.Cancel := True;

    if LForm.ShowModal = mrOK then
    begin
      Git4DSettings.GitExecutable := LGitEdit.Text;
      Git4DSettings.GitBashExecutable := LBashEdit.Text;
      Git4DSettings.DefaultCloneDirectory := LCloneEdit.Text;
      Git4DSettings.ShowBranchInMenu := LBranchCheck.Checked;
      Git4DSettings.ShowConfirmationForDestructiveActions := LConfirmCheck.Checked;
      Git4DSettings.BackgroundFetchEnabled := LBackgroundFetchCheck.Checked;
      Git4DSettings.AutoCloseConsoleOnSuccess := LAutoCloseCheck.Checked;
      Git4DSettings.Save;
    end;
  finally
    LForm.Free;
  end;
end;

procedure ShowGit4DAboutDialog;
begin
  MessageDlg(cG4DProductName + sLineBreak + sLineBreak +
    'RAD Studio Git client for Delphi and C++Builder.' + sLineBreak +
    'This build provides the IDE integration and Git command surface foundation.' + sLineBreak +
    'By Ali Dehbansiahkarbon(adehban@gmail.com)',
    mtInformation, [mbOK], 0);
end;

end.

