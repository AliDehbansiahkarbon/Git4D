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
  Vcl.Graphics,
  Vcl.StdCtrls,
  Vcl.Themes,
  ToolsAPI,
  Git4D.Constants,
  Git4D.Settings;

procedure ApplyIDETheme(Component: TComponent);
{$IF CompilerVersion >= 32.0}
var
{$IF CompilerVersion > 33.0}
  LThemingServices: IOTAIDEThemingServices;
{$ELSE}
  LThemingServices: IOTAIDEThemingServices250;
{$IFEND}
{$IFEND}
begin
{$IF CompilerVersion >= 32.0}
{$IF CompilerVersion > 33.0}
  if Supports(BorlandIDEServices, IOTAIDEThemingServices, LThemingServices) and
{$ELSE}
  if Supports(BorlandIDEServices, IOTAIDEThemingServices250, LThemingServices) and
{$IFEND}
    LThemingServices.IDEThemingEnabled and (Component <> nil) then
    LThemingServices.ApplyTheme(Component);
{$IFEND}
end;

function IDEStyleServices: TCustomStyleServices;
{$IF CompilerVersion >= 32.0}
var
{$IF CompilerVersion > 33.0}
  LThemingServices: IOTAIDEThemingServices;
{$ELSE}
  LThemingServices: IOTAIDEThemingServices250;
{$IFEND}
{$IFEND}
begin
  Result := TStyleManager.ActiveStyle;
{$IF CompilerVersion >= 32.0}
{$IF CompilerVersion > 33.0}
  if Supports(BorlandIDEServices, IOTAIDEThemingServices, LThemingServices) and
{$ELSE}
  if Supports(BorlandIDEServices, IOTAIDEThemingServices250, LThemingServices) and
{$IFEND}
    LThemingServices.IDEThemingEnabled then
    Result := LThemingServices.StyleServices;
{$IFEND}
end;

procedure ApplyIDEStyle(Control: TControl);
var
  LIndex: Integer;
  LTextColor: TColor;
  LWinControl: TWinControl;
  LWindowColor: TColor;
  LButtonFaceColor: TColor;
begin
  if Control = nil then
    Exit;

  LButtonFaceColor := IDEStyleServices.GetSystemColor(clBtnFace);
  LWindowColor := IDEStyleServices.GetSystemColor(clWindow);
  LTextColor := IDEStyleServices.GetSystemColor(clWindowText);

  if Control is TCustomForm then
  begin
    TCustomForm(Control).Color := LButtonFaceColor;
    TCustomForm(Control).Font.Color := LTextColor;
  end
  else if Control is TPanel then
  begin
    TPanel(Control).ParentBackground := False;
    TPanel(Control).Color := LButtonFaceColor;
    TPanel(Control).Font.Color := LTextColor;
    TPanel(Control).StyleElements := [seFont, seClient, seBorder];
  end
  else if Control is TLabel then
  begin
    TLabel(Control).Font.Color := LTextColor;
    TLabel(Control).StyleElements := [seFont];
  end
  else if Control is TButton then
  begin
    TButton(Control).Font.Color := LTextColor;
    TButton(Control).StyleElements := [seFont, seClient, seBorder];
  end
  else if Control is TEdit then
  begin
    TEdit(Control).Color := LWindowColor;
    TEdit(Control).Font.Color := LTextColor;
    TEdit(Control).StyleElements := [seFont, seClient, seBorder];
  end;

  if Control is TWinControl then
  begin
    LWinControl := TWinControl(Control);
    for LIndex := 0 to LWinControl.ControlCount - 1 do
      ApplyIDEStyle(LWinControl.Controls[LIndex]);
  end;
end;

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
var
  LAccentPanel: TPanel;
  LBodyPanel: TPanel;
  LButtonPanel: TPanel;
  LForm: TForm;
  LInfoLabel: TLabel;
  LOkButton: TButton;
  LSubtitleLabel: TLabel;
  LTitleLabel: TLabel;
begin
  LForm := TForm.Create(nil);
  try
    LForm.Caption := 'About ' + cG4DProductName;
    LForm.BorderStyle := bsDialog;
    LForm.Position := poScreenCenter;
    LForm.ClientWidth := 520;
    LForm.ClientHeight := 260;
    LForm.Font.Name := 'Segoe UI';
    LForm.Font.Size := 9;

    LAccentPanel := TPanel.Create(LForm);
    LAccentPanel.Parent := LForm;
    LAccentPanel.Align := alTop;
    LAccentPanel.Height := 8;
    LAccentPanel.BevelOuter := bvNone;
    LAccentPanel.Color := IDEStyleServices.GetSystemColor(clHighlight);
    LAccentPanel.ParentBackground := False;

    LBodyPanel := TPanel.Create(LForm);
    LBodyPanel.Parent := LForm;
    LBodyPanel.Align := alClient;
    LBodyPanel.BevelOuter := bvNone;
    LBodyPanel.Padding.Left := 24;
    LBodyPanel.Padding.Top := 18;
    LBodyPanel.Padding.Right := 24;
    LBodyPanel.Padding.Bottom := 12;

    LTitleLabel := TLabel.Create(LForm);
    LTitleLabel.Parent := LBodyPanel;
    LTitleLabel.Align := alTop;
    LTitleLabel.Caption := cG4DProductName;
    LTitleLabel.Font.Size := 22;
    LTitleLabel.Font.Style := [fsBold];
    LTitleLabel.Height := 38;
    LTitleLabel.AutoSize := False;

    LSubtitleLabel := TLabel.Create(LForm);
    LSubtitleLabel.Parent := LBodyPanel;
    LSubtitleLabel.Align := alTop;
    LSubtitleLabel.Caption := 'RAD Studio Git client for Delphi and C++Builder';
    LSubtitleLabel.Font.Size := 10;
    LSubtitleLabel.Height := 26;
    LSubtitleLabel.AutoSize := False;

    LInfoLabel := TLabel.Create(LForm);
    LInfoLabel.Parent := LBodyPanel;
    LInfoLabel.Align := alTop;
    LInfoLabel.AutoSize := False;
    LInfoLabel.WordWrap := True;
    LInfoLabel.Height := 96;
    LInfoLabel.Caption :=
      'Git4D adds IDE menus, editor and Project Explorer Git actions, optional external client integration, ' +
      'and a dockable Workbench for repository-oriented workflows.' + sLineBreak + sLineBreak +
      'Author: Ali Dehbansiahkarbon' + sLineBreak +
      'Email: adehban@gmail.com';

    LButtonPanel := TPanel.Create(LForm);
    LButtonPanel.Parent := LForm;
    LButtonPanel.Align := alBottom;
    LButtonPanel.Height := 52;
    LButtonPanel.BevelOuter := bvNone;

    LOkButton := TButton.Create(LForm);
    LOkButton.Parent := LButtonPanel;
    LOkButton.Caption := 'OK';
    LOkButton.ModalResult := mrOK;
    LOkButton.Default := True;
    LOkButton.Cancel := True;
    LOkButton.Width := 88;
    LOkButton.Height := 28;
    LOkButton.Left := LForm.ClientWidth - LOkButton.Width - 24;
    LOkButton.Top := 12;

    ApplyIDETheme(LForm);
    ApplyIDEStyle(LForm);
    LAccentPanel.Color := IDEStyleServices.GetSystemColor(clHighlight);
    LTitleLabel.Font.Style := [fsBold];
    LForm.ShowModal;
  finally
    LForm.Free;
  end;
end;

end.

