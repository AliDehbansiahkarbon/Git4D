unit Git4D.Workbench;

interface

uses
  DockForm;

procedure ShowGit4DWorkbench;
procedure CloseGit4DWorkbench;
procedure ReleaseGit4DWorkbench;
procedure RefreshGit4DWorkbenchSettings;

implementation

{$R *.dfm}

uses
  System.Classes,
  System.SysUtils,
  Vcl.ComCtrls,
  Vcl.Controls,
  Vcl.Dialogs,
  Vcl.ExtCtrls,
  Vcl.Forms,
  Vcl.Graphics,
  Vcl.Menus,
  Vcl.StdCtrls,
  Vcl.Themes,
  Winapi.Messages,
  Winapi.Windows,
  ToolsAPI,
  Git4D.Constants,
  Git4D.Git,
  Git4D.GitExtensions,
  Git4D.Repository,
  Git4D.Settings,
  Git4D.TortoiseGit;

type
  TGit4DWorkbenchClient = (
    wcGit4D,
    wcTortoiseGit,
    wcGitExtensions
  );

  TGit4DWorkbenchForm = class(TDockableForm)
  published
    FBranchLabel: TLabel;
    FChangedFiles: TListView;
    FClientCombo: TComboBox;
    FContentPanel: TPanel;
    FLastOutput: TMemo;
    FLeftPanel: TPanel;
    FMainSplitter: TSplitter;
    FRepositoryLabel: TLabel;
    FRightPanel: TPanel;
    FStatusLabel: TLabel;
    FTerminalInput: TEdit;
    FTerminalOutput: TMemo;
    FTerminalPanel: TPanel;
    FTerminalPromptLabel: TLabel;
    FTerminalSplitter: TSplitter;
    FTerminalTitleLabel: TLabel;
    TopPanel: TPanel;
    HeaderPanel: TPanel;
    ConnectToLabel: TLabel;
    ToolbarPanel: TPanel;
    GapPanel: TPanel;
    TerminalHeaderPanel: TPanel;
    CommandPanel: TPanel;
    RefreshButton: TButton;
    StatusButton: TButton;
    DiffButton: TButton;
    StageButton: TButton;
    ResetButton: TButton;
    CommitButton: TButton;
    PullButton: TButton;
    PushButton: TButton;
  private
    FFilePopup: TPopupMenu;
    FMenuAdd: TMenuItem;
    FMenuBlame: TMenuItem;
    FMenuDiff: TMenuItem;
    FMenuHistory: TMenuItem;
    FMenuRefresh: TMenuItem;
    FMenuReset: TMenuItem;
    FMenuStage: TMenuItem;
    FMenuUnstage: TMenuItem;
    FRepository: TGit4DRepository;
    FTerminalCurrentDirectory: string;
    procedure AddClick(Sender: TObject);
    function AddFileMenuItem(const Caption: string; const Handler: TNotifyEvent): TMenuItem;
    procedure AppendTerminalText(const Value: string);
    procedure ApplyIDEStyle(Control: TControl);
    procedure BuildPopupMenu;
    procedure BindLayoutEvents;
    procedure BlameClick(Sender: TObject);
    procedure ChangedFilesResize(Sender: TObject);
    procedure ClientChanged(Sender: TObject);
    function CurrentClient: TGit4DWorkbenchClient;
    procedure CommitClick(Sender: TObject);
    procedure DiffClick(Sender: TObject);
    function ExecuteRepositoryCommand(const Arguments, Description: string): Boolean;
    function ExecuteSelectedFileCommand(const ArgumentsBeforeFile, Description: string;
      const RefreshAfter: Boolean = False): Boolean;
    procedure FormShown(Sender: TObject);
    function GetSelectedStatusCode: string;
    function GetSelectedRelativePath: string;
    procedure HistoryClick(Sender: TObject);
    function IsSelectedFileUntracked: Boolean;
    function PromptCommitMessage(out MessageText: string): Boolean;
    procedure PullClick(Sender: TObject);
    procedure PopupOpening(Sender: TObject);
    procedure PushClick(Sender: TObject);
    procedure RefreshClick(Sender: TObject);
    procedure RefreshRepository;
    function RepositoryForSelectedFile: TGit4DRepository;
    procedure ResetClick(Sender: TObject);
    procedure ResizeChangedFilesColumns;
    procedure RouteGitExtensionsRepository(Command: TGitExtensionsCommand);
    procedure RouteGitExtensionsSelectedFile(Command: TGitExtensionsCommand);
    procedure RouteTortoiseGitRepository(Command: TTortoiseGitCommand);
    procedure RouteTortoiseGitSelectedFile(Command: TTortoiseGitCommand);
    procedure SetLastOutput(const Value: string);
    procedure StageClick(Sender: TObject);
    procedure StatusClick(Sender: TObject);
    procedure TerminalInputKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure UnstageClick(Sender: TObject);
    procedure UpdateClientCombo;
    procedure UpdateWorkbenchSettings;
    procedure UpdateTerminalDirectory;
    procedure UpdateTerminalPrompt;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

  TGit4DStyleNotifier = class(TNotifierObject, IOTANotifier, INTAIDEThemingServicesNotifier)
  public
    procedure ChangingTheme;
    procedure ChangedTheme;
  end;

var
  GWorkbench: TGit4DWorkbenchForm;
  GStyleNotifier: TGit4DStyleNotifier;
  GStyleNotifierIndex: Integer = -1;

function EndsWithLineBreak(const Value: string): Boolean;
begin
  Result := (Value = '') or (Copy(Value, Length(Value) - Length(sLineBreak) + 1, Length(sLineBreak)) = sLineBreak);
end;

procedure ApplyIDETheme(Component: TComponent);
{$IF CompilerVersion >= 32.0}
var
{$IF CompilerVersion > 33.0}
  ThemingServices: IOTAIDEThemingServices;
{$ELSE}
  ThemingServices: IOTAIDEThemingServices250;
{$IFEND}
{$IFEND}
begin
{$IF CompilerVersion >= 32.0}
{$IF CompilerVersion > 33.0}
  if Supports(BorlandIDEServices, IOTAIDEThemingServices, ThemingServices) and
{$ELSE}
  if Supports(BorlandIDEServices, IOTAIDEThemingServices250, ThemingServices) and
{$IFEND}
    ThemingServices.IDEThemingEnabled then
  begin
    ThemingServices.RegisterFormClass(TGit4DWorkbenchForm);
    if Component <> nil then
      ThemingServices.ApplyTheme(Component);
  end;
{$IFEND}
end;

function IDEStyleServices: TCustomStyleServices;
{$IF CompilerVersion >= 32.0}
var
{$IF CompilerVersion > 33.0}
  ThemingServices: IOTAIDEThemingServices;
{$ELSE}
  ThemingServices: IOTAIDEThemingServices250;
{$IFEND}
{$IFEND}
begin
  Result := TStyleManager.ActiveStyle;
{$IF CompilerVersion >= 32.0}
{$IF CompilerVersion > 33.0}
  if Supports(BorlandIDEServices, IOTAIDEThemingServices, ThemingServices) and
{$ELSE}
  if Supports(BorlandIDEServices, IOTAIDEThemingServices250, ThemingServices) and
{$IFEND}
    ThemingServices.IDEThemingEnabled then
    Result := ThemingServices.StyleServices;
{$IFEND}
end;

procedure RegisterStyleNotifier;
{$IF CompilerVersion >= 32.0}
var
{$IF CompilerVersion > 33.0}
  ThemingServices: IOTAIDEThemingServices;
{$ELSE}
  ThemingServices: IOTAIDEThemingServices250;
{$IFEND}
{$IFEND}
begin
{$IF CompilerVersion >= 32.0}
  if GStyleNotifierIndex <> -1 then
    Exit;

{$IF CompilerVersion > 33.0}
  if Supports(BorlandIDEServices, IOTAIDEThemingServices, ThemingServices) and
{$ELSE}
  if Supports(BorlandIDEServices, IOTAIDEThemingServices250, ThemingServices) and
{$IFEND}
    ThemingServices.IDEThemingEnabled then
  begin
    GStyleNotifier := TGit4DStyleNotifier.Create;
    GStyleNotifierIndex := ThemingServices.AddNotifier(GStyleNotifier);
  end;
{$IFEND}
end;

procedure UnregisterStyleNotifier;
{$IF CompilerVersion >= 32.0}
var
{$IF CompilerVersion > 33.0}
  ThemingServices: IOTAIDEThemingServices;
{$ELSE}
  ThemingServices: IOTAIDEThemingServices250;
{$IFEND}
{$IFEND}
begin
{$IF CompilerVersion >= 32.0}
  if GStyleNotifierIndex = -1 then
    Exit;

{$IF CompilerVersion > 33.0}
  if Supports(BorlandIDEServices, IOTAIDEThemingServices, ThemingServices) then
{$ELSE}
  if Supports(BorlandIDEServices, IOTAIDEThemingServices250, ThemingServices) then
{$IFEND}
    ThemingServices.RemoveNotifier(GStyleNotifierIndex);
  GStyleNotifierIndex := -1;
  GStyleNotifier := nil;
{$IFEND}
end;

function Quote(const Value: string): string;
begin
  Result := '"' + StringReplace(Value, '"', '""', [rfReplaceAll]) + '"';
end;

function ExecuteCommandCapture(const WorkingDirectory, CommandLine: string;
  out Output: string; out ExitCode: Cardinal; TimeoutMilliseconds: Cardinal): Boolean; forward;

function ExecuteGitCapture(const Repository: TGit4DRepository; const Arguments: string;
  out Output: string; out ExitCode: Cardinal; TimeoutMilliseconds: Cardinal): Boolean;
begin
  Result := False;
  if Repository.IsValid then
    Result := ExecuteCommandCapture(Repository.RootPath, Quote(Git4DSettings.GitExecutable) + ' ' + Arguments,
      Output, ExitCode, TimeoutMilliseconds);
end;

function ExecuteCommandCapture(const WorkingDirectory, CommandLine: string;
  out Output: string; out ExitCode: Cardinal; TimeoutMilliseconds: Cardinal): Boolean;
var
  Buffer: array[0..4095] of AnsiChar;
  BytesAvailable: DWORD;
  BytesRead: DWORD;
  Chunk: AnsiString;
  MutableCommandLine: string;
  ProcessInfo: TProcessInformation;
  ReadPipe: THandle;
  SecurityAttributes: TSecurityAttributes;
  StartTick: Cardinal;
  StartupInfo: TStartupInfo;
  WaitResult: DWORD;
  WritePipe: THandle;
begin
  Result := False;
  Output := '';
  ExitCode := Cardinal(-1);

  if WorkingDirectory = '' then
    Exit;

  SecurityAttributes.nLength := SizeOf(SecurityAttributes);
  SecurityAttributes.bInheritHandle := True;
  SecurityAttributes.lpSecurityDescriptor := nil;

  if not CreatePipe(ReadPipe, WritePipe, @SecurityAttributes, 0) then
    Exit;
  try
    SetHandleInformation(ReadPipe, HANDLE_FLAG_INHERIT, 0);
    ZeroMemory(@StartupInfo, SizeOf(StartupInfo));
    ZeroMemory(@ProcessInfo, SizeOf(ProcessInfo));
    StartupInfo.cb := SizeOf(StartupInfo);
    StartupInfo.dwFlags := STARTF_USESHOWWINDOW or STARTF_USESTDHANDLES;
    StartupInfo.wShowWindow := SW_HIDE;
    StartupInfo.hStdOutput := WritePipe;
    StartupInfo.hStdError := WritePipe;

    MutableCommandLine := CommandLine;
    if CreateProcess(nil, PChar(MutableCommandLine), nil, nil, True, CREATE_NO_WINDOW, nil,
      PChar(WorkingDirectory), StartupInfo, ProcessInfo) then
    begin
      CloseHandle(WritePipe);
      WritePipe := 0;
      StartTick := GetTickCount;
      while True do
      begin
        BytesAvailable := 0;
        if PeekNamedPipe(ReadPipe, nil, 0, nil, @BytesAvailable, nil) and (BytesAvailable > 0) then
          if ReadFile(ReadPipe, Buffer, SizeOf(Buffer), BytesRead, nil) and (BytesRead > 0) then
          begin
            SetString(Chunk, PAnsiChar(@Buffer[0]), BytesRead);
            Output := Output + string(Chunk);
          end;

        WaitResult := WaitForSingleObject(ProcessInfo.hProcess, 20);
        if WaitResult = WAIT_OBJECT_0 then
          Break;

        if (TimeoutMilliseconds > 0) and (GetTickCount - StartTick > TimeoutMilliseconds) then
        begin
          TerminateProcess(ProcessInfo.hProcess, 1);
          Output := Output + sLineBreak + Format('Command timed out after %d seconds.',
            [TimeoutMilliseconds div 1000]);
          Break;
        end;

        Application.ProcessMessages;
      end;

      while PeekNamedPipe(ReadPipe, nil, 0, nil, @BytesAvailable, nil) and (BytesAvailable > 0) do
        if ReadFile(ReadPipe, Buffer, SizeOf(Buffer), BytesRead, nil) and (BytesRead > 0) then
        begin
          SetString(Chunk, PAnsiChar(@Buffer[0]), BytesRead);
          Output := Output + string(Chunk);
        end
        else
          Break;

      GetExitCodeProcess(ProcessInfo.hProcess, ExitCode);
      CloseHandle(ProcessInfo.hThread);
      CloseHandle(ProcessInfo.hProcess);
      Result := True;
    end;
  finally
    if WritePipe <> 0 then
      CloseHandle(WritePipe);
    CloseHandle(ReadPipe);
  end;
end;

function StatusCaption(const StatusCode: string): string;
begin
  if StatusCode = '??' then
    Result := 'Untracked'
  else if Pos('A', StatusCode) > 0 then
    Result := 'Added'
  else if Pos('M', StatusCode) > 0 then
    Result := 'Modified'
  else if Pos('D', StatusCode) > 0 then
    Result := 'Deleted'
  else if Pos('R', StatusCode) > 0 then
    Result := 'Renamed'
  else if Pos('C', StatusCode) > 0 then
    Result := 'Copied'
  else if Pos('U', StatusCode) > 0 then
    Result := 'Conflict'
  else
    Result := Trim(StatusCode);
end;

constructor TGit4DWorkbenchForm.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  DeskSection := 'Git4DWorkbench';
  AutoSave := True;
  SaveStateNecessary := True;
  Caption := cG4DProductName + ' Workbench';
  ClientWidth := 760;
  ClientHeight := 520;
  Position := poMainFormCenter;
  OnShow := FormShown;
  BindLayoutEvents;
  BuildPopupMenu;
  ApplyIDETheme(Self);
  ApplyIDEStyle(Self);
end;

destructor TGit4DWorkbenchForm.Destroy;
begin
  GWorkbench := nil;
  inherited Destroy;
end;

procedure TGit4DWorkbenchForm.BindLayoutEvents;
begin
  RefreshButton.OnClick := RefreshClick;
  StatusButton.OnClick := StatusClick;
  DiffButton.OnClick := DiffClick;
  StageButton.OnClick := StageClick;
  ResetButton.OnClick := ResetClick;
  CommitButton.OnClick := CommitClick;
  PullButton.OnClick := PullClick;
  PushButton.OnClick := PushClick;
  FClientCombo.OnChange := ClientChanged;
  FChangedFiles.OnResize := ChangedFilesResize;
  FChangedFiles.MultiSelect := True;
  FTerminalInput.OnKeyDown := TerminalInputKeyDown;
  FClientCombo.ShowHint := True;
  ResizeChangedFilesColumns;
end;

function TGit4DWorkbenchForm.AddFileMenuItem(const Caption: string; const Handler: TNotifyEvent): TMenuItem;
var
  Item: TMenuItem;
begin
  Item := TMenuItem.Create(FFilePopup);
  Item.Caption := Caption;
  Item.OnClick := Handler;
  FFilePopup.Items.Add(Item);
  Result := Item;
end;

procedure TGit4DWorkbenchForm.AppendTerminalText(const Value: string);
begin
  if FTerminalOutput = nil then
    Exit;

  if (FTerminalOutput.Text <> '') and not EndsWithLineBreak(FTerminalOutput.Text) then
    FTerminalOutput.Lines.Add('');
  FTerminalOutput.SelStart := Length(FTerminalOutput.Text);
  FTerminalOutput.SelText := Value;
  if not EndsWithLineBreak(Value) then
    FTerminalOutput.SelText := sLineBreak;
  FTerminalOutput.SelStart := Length(FTerminalOutput.Text);
  FTerminalOutput.Perform(EM_SCROLLCARET, 0, 0);
end;

procedure TGit4DWorkbenchForm.ApplyIDEStyle(Control: TControl);
var
  ButtonFaceColor: TColor;
  Index: Integer;
  TextColor: TColor;
  WinControl: TWinControl;
  WindowColor: TColor;
begin
  if Control = nil then
    Exit;

  ButtonFaceColor := IDEStyleServices.GetSystemColor(clBtnFace);
  WindowColor := IDEStyleServices.GetSystemColor(clWindow);
  TextColor := IDEStyleServices.GetSystemColor(clWindowText);

  if Control is TCustomForm then
  begin
    TCustomForm(Control).Color := ButtonFaceColor;
    TCustomForm(Control).Font.Color := TextColor;
  end
  else if Control is TPanel then
  begin
    TPanel(Control).ParentBackground := False;
    TPanel(Control).Color := ButtonFaceColor;
    TPanel(Control).Font.Color := TextColor;
    TPanel(Control).StyleElements := [seFont, seClient, seBorder];
  end
  else if Control is TListView then
  begin
    TListView(Control).Color := WindowColor;
    TListView(Control).Font.Color := TextColor;
    TListView(Control).StyleElements := [seFont, seClient, seBorder];
  end
  else if Control is TMemo then
  begin
    TMemo(Control).Color := WindowColor;
    TMemo(Control).Font.Color := TextColor;
    TMemo(Control).StyleElements := [seFont, seClient, seBorder];
  end
  else if Control is TEdit then
  begin
    TEdit(Control).Color := WindowColor;
    TEdit(Control).Font.Color := TextColor;
    TEdit(Control).StyleElements := [seFont, seClient, seBorder];
  end
  else if Control is TSplitter then
  begin
    TSplitter(Control).Color := IDEStyleServices.GetSystemColor(clBtnShadow);
    TSplitter(Control).StyleElements := [seClient];
  end
  else if Control is TComboBox then
  begin
    TComboBox(Control).Color := WindowColor;
    TComboBox(Control).Font.Color := TextColor;
    TComboBox(Control).StyleElements := [seFont, seClient, seBorder];
  end
  else if Control is TButton then
  begin
    TButton(Control).Font.Color := TextColor;
    TButton(Control).StyleElements := [seFont, seClient, seBorder]
  end
  else if Control is TLabel then
  begin
    TLabel(Control).Font.Color := TextColor;
    TLabel(Control).StyleElements := [seFont];
  end;

  if Control is TWinControl then
  begin
    WinControl := TWinControl(Control);
    for Index := 0 to WinControl.ControlCount - 1 do
      ApplyIDEStyle(WinControl.Controls[Index]);
  end;
end;

procedure TGit4DWorkbenchForm.BuildPopupMenu;
begin
  FFilePopup := TPopupMenu.Create(Self);
  FFilePopup.OnPopup := PopupOpening;
  FMenuAdd := AddFileMenuItem('&Add', AddClick);
  FMenuDiff := AddFileMenuItem('&Diff', DiffClick);
  FMenuStage := AddFileMenuItem('&Stage', StageClick);
  FMenuUnstage := AddFileMenuItem('&Unstage', UnstageClick);
  FMenuReset := AddFileMenuItem('&Reset changes', ResetClick);
  FFilePopup.Items.Add(TMenuItem.Create(FFilePopup));
  FFilePopup.Items[FFilePopup.Items.Count - 1].Caption := '-';
  FMenuHistory := AddFileMenuItem('File &History', HistoryClick);
  FMenuBlame := AddFileMenuItem('&Blame', BlameClick);
  FFilePopup.Items.Add(TMenuItem.Create(FFilePopup));
  FFilePopup.Items[FFilePopup.Items.Count - 1].Caption := '-';
  FMenuRefresh := AddFileMenuItem('&Refresh', RefreshClick);
  FChangedFiles.PopupMenu := FFilePopup;
end;

procedure TGit4DWorkbenchForm.ChangedFilesResize(Sender: TObject);
begin
  ResizeChangedFilesColumns;
end;

procedure TGit4DWorkbenchForm.FormShown(Sender: TObject);
begin
  UpdateWorkbenchSettings;
  RefreshRepository;
  ResizeChangedFilesColumns;
end;

function TGit4DWorkbenchForm.GetSelectedRelativePath: string;
begin
  Result := '';
  if (FChangedFiles <> nil) and (FChangedFiles.Selected <> nil) then
    Result := FChangedFiles.Selected.Caption;
end;

function TGit4DWorkbenchForm.GetSelectedStatusCode: string;
begin
  Result := '';
  if (FChangedFiles <> nil) and (FChangedFiles.Selected <> nil) and
    (FChangedFiles.Selected.SubItems.Count >= 2) then
    Result := FChangedFiles.Selected.SubItems[1];
end;

function TGit4DWorkbenchForm.IsSelectedFileUntracked: Boolean;
begin
  Result := SameText(GetSelectedStatusCode, '??');
end;

function TGit4DWorkbenchForm.PromptCommitMessage(out MessageText: string): Boolean;
var
  ButtonPanel: TPanel;
  CancelButton: TButton;
  Edit: TEdit;
  Form: TForm;
  InfoLabel: TLabel;
  OkButton: TButton;
  PromptLabel: TLabel;
begin
  Result := False;
  MessageText := '';

  Form := TForm.Create(nil);
  try
    Form.Caption := cG4DProductName + ' Commit';
    Form.BorderStyle := bsDialog;
    Form.Position := poScreenCenter;
    Form.ClientWidth := 460;
    Form.ClientHeight := 150;
    Form.Font.Name := 'Segoe UI';
    Form.Font.Size := 9;

    PromptLabel := TLabel.Create(Form);
    PromptLabel.Parent := Form;
    PromptLabel.Left := 18;
    PromptLabel.Top := 18;
    PromptLabel.Width := 420;
    PromptLabel.Height := 18;
    PromptLabel.AutoSize := False;
    PromptLabel.Caption := 'Commit message';

    Edit := TEdit.Create(Form);
    Edit.Parent := Form;
    Edit.Left := 18;
    Edit.Top := 42;
    Edit.Width := 420;
    Edit.Height := 24;
    Edit.Anchors := [akLeft, akTop, akRight];

    InfoLabel := TLabel.Create(Form);
    InfoLabel.Parent := Form;
    InfoLabel.Left := 18;
    InfoLabel.Top := 74;
    InfoLabel.Width := 420;
    InfoLabel.Height := 18;
    InfoLabel.AutoSize := False;
    InfoLabel.Caption := 'The message is passed to git commit -m.';

    ButtonPanel := TPanel.Create(Form);
    ButtonPanel.Parent := Form;
    ButtonPanel.Align := alBottom;
    ButtonPanel.Height := 48;
    ButtonPanel.BevelOuter := bvNone;

    OkButton := TButton.Create(Form);
    OkButton.Parent := ButtonPanel;
    OkButton.Caption := 'Commit';
    OkButton.ModalResult := mrOK;
    OkButton.Default := True;
    OkButton.Width := 88;
    OkButton.Height := 28;
    OkButton.Left := Form.ClientWidth - 184;
    OkButton.Top := 10;

    CancelButton := TButton.Create(Form);
    CancelButton.Parent := ButtonPanel;
    CancelButton.Caption := 'Cancel';
    CancelButton.ModalResult := mrCancel;
    CancelButton.Cancel := True;
    CancelButton.Width := 88;
    CancelButton.Height := 28;
    CancelButton.Left := Form.ClientWidth - 94;
    CancelButton.Top := 10;

    ApplyIDETheme(Form);
    ApplyIDEStyle(Form);

    if Form.ShowModal = mrOK then
    begin
      MessageText := Trim(Edit.Text);
      Result := MessageText <> '';
    end;
  finally
    Form.Free;
  end;
end;

function TGit4DWorkbenchForm.CurrentClient: TGit4DWorkbenchClient;
begin
  Result := wcGit4D;
  if (FClientCombo <> nil) and (FClientCombo.ItemIndex >= 0) then
    Result := TGit4DWorkbenchClient(FClientCombo.Items.Objects[FClientCombo.ItemIndex]);
end;

procedure TGit4DWorkbenchForm.ClientChanged(Sender: TObject);
begin
  FStatusLabel.Caption := 'Workbench connected to ' + FClientCombo.Text + '.';
end;

function TGit4DWorkbenchForm.RepositoryForSelectedFile: TGit4DRepository;
var
  RelativePath: string;
begin
  Result := FRepository;
  RelativePath := GetSelectedRelativePath;
  if (RelativePath <> '') and (FRepository.RootPath <> '') then
    Result.ActiveFileName := IncludeTrailingPathDelimiter(FRepository.RootPath) + RelativePath;
end;

procedure TGit4DWorkbenchForm.RouteTortoiseGitRepository(Command: TTortoiseGitCommand);
begin
  TGit4DTortoiseGit.Run(Command, FRepository);
end;

procedure TGit4DWorkbenchForm.RouteTortoiseGitSelectedFile(Command: TTortoiseGitCommand);
begin
  TGit4DTortoiseGit.Run(Command, RepositoryForSelectedFile);
end;

procedure TGit4DWorkbenchForm.RouteGitExtensionsRepository(Command: TGitExtensionsCommand);
begin
  TGit4DGitExtensions.Run(Command, FRepository);
end;

procedure TGit4DWorkbenchForm.RouteGitExtensionsSelectedFile(Command: TGitExtensionsCommand);
begin
  TGit4DGitExtensions.Run(Command, RepositoryForSelectedFile);
end;

function TGit4DWorkbenchForm.ExecuteRepositoryCommand(const Arguments, Description: string): Boolean;
var
  ExitCode: Cardinal;
  Output: string;
begin
  Result := False;
  if not FRepository.IsValid then
  begin
    MessageDlg('No Git repository was found.', mtInformation, [mbOK], 0);
    Exit;
  end;

  FStatusLabel.Caption := Description + '...';
  if ExecuteGitCapture(FRepository, Arguments, Output, ExitCode, 30000) then
  begin
    SetLastOutput(Output);
    if ExitCode = 0 then
    begin
      FStatusLabel.Caption := Description + ' completed.';
      Result := True;
      RefreshRepository;
      SetLastOutput(Output);
    end
    else
      FStatusLabel.Caption := Format('%s returned exit code %d.', [Description, ExitCode]);
  end
  else
  begin
    FStatusLabel.Caption := Description + ' failed to start.';
    MessageDlg('Unable to start Git command.', mtError, [mbOK], 0);
  end;
end;

function TGit4DWorkbenchForm.ExecuteSelectedFileCommand(const ArgumentsBeforeFile, Description: string;
  const RefreshAfter: Boolean): Boolean;
var
  ExitCode: Cardinal;
  Output: string;
  RelativePath: string;
begin
  Result := False;
  RelativePath := GetSelectedRelativePath;
  if RelativePath = '' then
  begin
    MessageDlg('Select a changed file first.', mtInformation, [mbOK], 0);
    Exit;
  end;

  if not FRepository.IsValid then
  begin
    MessageDlg('No Git repository was found.', mtInformation, [mbOK], 0);
    Exit;
  end;

  FStatusLabel.Caption := Description + '...';
  if ExecuteGitCapture(FRepository, ArgumentsBeforeFile + ' ' + Quote(RelativePath),
    Output, ExitCode, 30000) then
  begin
    SetLastOutput(Output);
    if ExitCode = 0 then
    begin
      FStatusLabel.Caption := Description + ' completed.';
      Result := True;
      if RefreshAfter then
      begin
        RefreshRepository;
        SetLastOutput(Output);
      end;
    end
    else
      FStatusLabel.Caption := Format('%s returned exit code %d.', [Description, ExitCode]);
  end
  else
  begin
    FStatusLabel.Caption := Description + ' failed to start.';
    MessageDlg('Unable to start Git command.', mtError, [mbOK], 0);
  end;
end;

procedure TGit4DWorkbenchForm.RefreshRepository;
var
  BranchName: string;
  ExitCode: Cardinal;
  Index: Integer;
  Item: TListItem;
  Line: string;
  Lines: TStringList;
  Output: string;
  PathText: string;
  StatusCode: string;
begin
  FRepository := DiscoverActiveRepository;
  UpdateTerminalDirectory;
  FChangedFiles.Items.BeginUpdate;
  try
    FChangedFiles.Items.Clear;
    if not FRepository.IsValid then
    begin
      FRepositoryLabel.Caption := 'Repository: not found';
      FBranchLabel.Caption := 'Branch:';
      FStatusLabel.Caption := 'Open a file or project inside a Git repository, then refresh.';
      SetLastOutput('');
      Exit;
    end;

    FRepositoryLabel.Caption := 'Repository: ' + FRepository.RootPath;
    BranchName := GetCurrentBranchName(FRepository.RootPath);
    if BranchName = '' then
      BranchName := '(detached or unknown)';
    FBranchLabel.Caption := 'Branch: ' + BranchName;

    if not ExecuteGitCapture(FRepository, 'status --short --branch', Output, ExitCode, 15000) then
    begin
      FStatusLabel.Caption := 'Unable to run git status.';
      SetLastOutput('Unable to run git status.');
      Exit;
    end;

    Lines := TStringList.Create;
    try
      Lines.Text := Output;
      for Index := 0 to Lines.Count - 1 do
      begin
        Line := Lines[Index];
        if Line = '' then
          Continue;
        if Copy(Line, 1, 2) = '##' then
          Continue;

        StatusCode := Trim(Copy(Line, 1, 2));
        PathText := Trim(Copy(Line, 4, MaxInt));
        if PathText = '' then
          Continue;

        Item := FChangedFiles.Items.Add;
        Item.Caption := PathText;
        Item.SubItems.Add(StatusCaption(StatusCode));
        Item.SubItems.Add(StatusCode);
      end;
    finally
      Lines.Free;
    end;

    if ExitCode = 0 then
      FStatusLabel.Caption := Format('%d changed file(s)', [FChangedFiles.Items.Count])
    else
      FStatusLabel.Caption := Format('git status returned exit code %d', [ExitCode]);
    SetLastOutput(Output);
  finally
    FChangedFiles.Items.EndUpdate;
  end;
end;

procedure TGit4DWorkbenchForm.RefreshClick(Sender: TObject);
begin
  RefreshRepository;
end;

procedure TGit4DWorkbenchForm.ResizeChangedFilesColumns;
var
  AvailableWidth: Integer;
  CodeWidth: Integer;
  FileWidth: Integer;
  StateWidth: Integer;
begin
  if (FChangedFiles = nil) or (FChangedFiles.Columns.Count < 3) then
    Exit;

  AvailableWidth := FChangedFiles.ClientWidth - 4;
  if AvailableWidth < 240 then
    AvailableWidth := 240;

  CodeWidth := 64;
  StateWidth := AvailableWidth div 5;
  if StateWidth < 110 then
    StateWidth := 110;
  if StateWidth > 180 then
    StateWidth := 180;

  FileWidth := AvailableWidth - StateWidth - CodeWidth;
  if FileWidth < 120 then
    FileWidth := 120;

  FChangedFiles.Columns[0].Width := FileWidth;
  FChangedFiles.Columns[1].Width := StateWidth;
  FChangedFiles.Columns[2].Width := CodeWidth;
end;

procedure TGit4DWorkbenchForm.PopupOpening(Sender: TObject);
var
  HasSelection: Boolean;
begin
  HasSelection := GetSelectedRelativePath <> '';
  FMenuAdd.Visible := HasSelection and IsSelectedFileUntracked;
  FMenuDiff.Enabled := HasSelection;
  FMenuStage.Enabled := HasSelection;
  FMenuStage.Visible := HasSelection and not IsSelectedFileUntracked;
  FMenuUnstage.Enabled := HasSelection and not IsSelectedFileUntracked;
  FMenuUnstage.Visible := HasSelection and not IsSelectedFileUntracked;
  FMenuReset.Enabled := HasSelection and not IsSelectedFileUntracked;
  FMenuHistory.Enabled := HasSelection and not IsSelectedFileUntracked;
  FMenuBlame.Enabled := HasSelection and not IsSelectedFileUntracked;
  FMenuRefresh.Enabled := True;

  case CurrentClient of
    wcGit4D:
    begin
      FMenuStage.Caption := '&Stage';
      FMenuDiff.Caption := '&Diff';
      FMenuHistory.Caption := 'File &History';
      FMenuBlame.Caption := '&Blame';
    end;
    wcTortoiseGit:
    begin
      FMenuStage.Caption := '&Stage with Git4D';
      FMenuDiff.Caption := '&Diff with TortoiseGit';
      FMenuHistory.Caption := 'Show &Log with TortoiseGit';
      FMenuBlame.Caption := '&Blame with TortoiseGit';
    end;
    wcGitExtensions:
    begin
      FMenuStage.Caption := '&Stage with Git Extensions';
      FMenuDiff.Caption := '&Diff with Git Extensions';
      FMenuHistory.Caption := 'File &History with Git Extensions';
      FMenuBlame.Caption := '&Blame with Git Extensions';
    end;
  end;
end;

procedure TGit4DWorkbenchForm.StatusClick(Sender: TObject);
begin
  case CurrentClient of
    wcGit4D:
      ExecuteRepositoryCommand('status --short --branch', 'Status');
    wcTortoiseGit:
      RouteTortoiseGitRepository(tgLog);
    wcGitExtensions:
      RouteGitExtensionsRepository(geBrowse);
  end;
end;

procedure TGit4DWorkbenchForm.DiffClick(Sender: TObject);
begin
  case CurrentClient of
    wcGit4D:
      ExecuteSelectedFileCommand('diff --', 'Diff');
    wcTortoiseGit:
      RouteTortoiseGitSelectedFile(tgDiff);
    wcGitExtensions:
      RouteGitExtensionsSelectedFile(geDiffTool);
  end;
end;

procedure TGit4DWorkbenchForm.HistoryClick(Sender: TObject);
begin
  case CurrentClient of
    wcGit4D:
      ExecuteSelectedFileCommand('log --follow --stat --', 'File history');
    wcTortoiseGit:
      RouteTortoiseGitSelectedFile(tgLog);
    wcGitExtensions:
      RouteGitExtensionsSelectedFile(geFileHistory);
  end;
end;

procedure TGit4DWorkbenchForm.BlameClick(Sender: TObject);
begin
  case CurrentClient of
    wcGit4D:
      ExecuteSelectedFileCommand('blame --', 'Blame');
    wcTortoiseGit:
      RouteTortoiseGitSelectedFile(tgBlame);
    wcGitExtensions:
      RouteGitExtensionsSelectedFile(geBlame);
  end;
end;

procedure TGit4DWorkbenchForm.StageClick(Sender: TObject);
begin
  case CurrentClient of
    wcGit4D:
      ExecuteSelectedFileCommand('add --', 'Stage', True);
    wcTortoiseGit:
      RouteTortoiseGitSelectedFile(tgAdd);
    wcGitExtensions:
      RouteGitExtensionsSelectedFile(geAdd);
  end;
end;

procedure TGit4DWorkbenchForm.AddClick(Sender: TObject);
begin
  StageClick(Sender);
end;

procedure TGit4DWorkbenchForm.UnstageClick(Sender: TObject);
begin
  ExecuteSelectedFileCommand('restore --staged --', 'Unstage', True);
end;

procedure TGit4DWorkbenchForm.ResetClick(Sender: TObject);
var
  RelativePath: string;
begin
  RelativePath := GetSelectedRelativePath;
  if RelativePath = '' then
  begin
    MessageDlg('Select a changed file first.', mtInformation, [mbOK], 0);
    Exit;
  end;

  if MessageDlg('Reset changes in "' + RelativePath + '"?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    ExecuteSelectedFileCommand('restore --source=HEAD --worktree --', 'Reset changes', True);
end;

procedure TGit4DWorkbenchForm.CommitClick(Sender: TObject);
var
  MessageText: string;
begin
  if not FRepository.IsValid then
  begin
    MessageDlg('No Git repository was found.', mtInformation, [mbOK], 0);
    Exit;
  end;

  case CurrentClient of
    wcGit4D:
      if PromptCommitMessage(MessageText) then
        ExecuteRepositoryCommand('commit -m ' + Quote(MessageText), 'Commit');
    wcTortoiseGit:
      RouteTortoiseGitRepository(tgCommit);
    wcGitExtensions:
      RouteGitExtensionsRepository(geCommit);
  end;
end;

procedure TGit4DWorkbenchForm.PullClick(Sender: TObject);
begin
  case CurrentClient of
    wcGit4D:
      ExecuteRepositoryCommand('pull --stat', 'Pull');
    wcTortoiseGit:
      RouteTortoiseGitRepository(tgPull);
    wcGitExtensions:
      RouteGitExtensionsRepository(gePull);
  end;
end;

procedure TGit4DWorkbenchForm.PushClick(Sender: TObject);
begin
  case CurrentClient of
    wcGit4D:
      ExecuteRepositoryCommand('push', 'Push');
    wcTortoiseGit:
      RouteTortoiseGitRepository(tgPush);
    wcGitExtensions:
      RouteGitExtensionsRepository(gePush);
  end;
end;

procedure TGit4DWorkbenchForm.SetLastOutput(const Value: string);
begin
  FLastOutput.Lines.Text := Value;
end;

procedure TGit4DWorkbenchForm.TerminalInputKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  CommandLine: string;
  CommandText: string;
  ComSpec: string;
  ExitCode: Cardinal;
  NewDirectory: string;
  Output: string;
  SpaceIndex: Integer;
begin
  if Key <> VK_RETURN then
    Exit;

  Key := 0;
  CommandText := Trim(FTerminalInput.Text);
  FTerminalInput.Clear;
  if CommandText = '' then
    Exit;

  UpdateTerminalDirectory;
  AppendTerminalText(FTerminalCurrentDirectory + '> ' + CommandText);

  if SameText(CommandText, 'cls') then
  begin
    FTerminalOutput.Clear;
    Exit;
  end;

  if SameText(CommandText, 'cd') or SameText(CommandText, 'chdir') then
  begin
    AppendTerminalText(FTerminalCurrentDirectory);
    Exit;
  end;

  if SameText(Copy(CommandText, 1, 3), 'cd ') or SameText(Copy(CommandText, 1, 6), 'chdir ') then
  begin
    SpaceIndex := Pos(' ', CommandText);
    NewDirectory := Trim(Copy(CommandText, SpaceIndex + 1, MaxInt));
    if SameText(Copy(NewDirectory, 1, 3), '/d ') then
      NewDirectory := Trim(Copy(NewDirectory, 4, MaxInt));
    if (Length(NewDirectory) >= 2) and (NewDirectory[1] = '"') and
      (NewDirectory[Length(NewDirectory)] = '"') then
      NewDirectory := Copy(NewDirectory, 2, Length(NewDirectory) - 2);
    if not DirectoryExists(NewDirectory) then
      NewDirectory := ExpandFileName(IncludeTrailingPathDelimiter(FTerminalCurrentDirectory) + NewDirectory);

    if DirectoryExists(NewDirectory) then
    begin
      FTerminalCurrentDirectory := ExcludeTrailingPathDelimiter(NewDirectory);
      UpdateTerminalPrompt;
    end
    else
      AppendTerminalText('The system cannot find the path specified.');
    Exit;
  end;

  ComSpec := GetEnvironmentVariable('ComSpec');
  if ComSpec = '' then
    ComSpec := 'cmd.exe';

  CommandLine := Quote(ComSpec) + ' /S /C ' + Quote(CommandText);
  if ExecuteCommandCapture(FTerminalCurrentDirectory, CommandLine, Output, ExitCode, 120000) then
  begin
    if Output <> '' then
      AppendTerminalText(Output);
    if ExitCode <> 0 then
      AppendTerminalText(Format('[exit code %d]', [ExitCode]));
    RefreshRepository;
  end
  else
    AppendTerminalText('Unable to start the command shell.');
end;

procedure TGit4DWorkbenchForm.UpdateClientCombo;
var
  DesiredClient: TGit4DWorkbenchClient;
  Index: Integer;
begin
  if FClientCombo = nil then
    Exit;

  DesiredClient := CurrentClient;
  FClientCombo.Items.BeginUpdate;
  try
    FClientCombo.Items.Clear;
    FClientCombo.Items.AddObject('Git4D', TObject(Ord(wcGit4D)));
    if Git4DSettings.TortoiseGitEnabled then
      FClientCombo.Items.AddObject('TortoiseGit', TObject(Ord(wcTortoiseGit)));
    if Git4DSettings.GitExtensionsEnabled then
      FClientCombo.Items.AddObject('Git Extensions', TObject(Ord(wcGitExtensions)));

    FClientCombo.ItemIndex := 0;
    for Index := 0 to FClientCombo.Items.Count - 1 do
      if TGit4DWorkbenchClient(FClientCombo.Items.Objects[Index]) = DesiredClient then
      begin
        FClientCombo.ItemIndex := Index;
        Break;
      end;
  finally
    FClientCombo.Items.EndUpdate;
  end;

  FClientCombo.Enabled := FClientCombo.Items.Count > 1;
  FClientCombo.Visible := True;
  if FClientCombo.Enabled then
    FClientCombo.Hint := 'Choose which configured Git client should handle Workbench actions.'
  else
    FClientCombo.Hint := 'Enable and configure a Git client in Tools > Options > Third Party > Git4D.';
end;

procedure TGit4DWorkbenchForm.UpdateWorkbenchSettings;
begin
  ApplyIDETheme(Self);
  ApplyIDEStyle(Self);
  UpdateClientCombo;

  if FTerminalPanel <> nil then
    FTerminalPanel.Visible := Git4DSettings.WorkbenchTerminalEnabled;
  if FTerminalSplitter <> nil then
    FTerminalSplitter.Visible := Git4DSettings.WorkbenchTerminalEnabled;

  if FTerminalOutput <> nil then
  begin
    FTerminalOutput.WordWrap := Git4DSettings.WorkbenchTerminalWordWrap;
    if FTerminalOutput.WordWrap then
      FTerminalOutput.ScrollBars := ssVertical
    else
      FTerminalOutput.ScrollBars := ssBoth;
  end;
end;

procedure TGit4DWorkbenchForm.UpdateTerminalDirectory;
var
  DirectoryName: string;
begin
  DirectoryName := '';
  if FRepository.IsValid then
    DirectoryName := FRepository.RootPath
  else if FRepository.ProjectFileName <> '' then
  begin
    if DirectoryExists(FRepository.ProjectFileName) then
      DirectoryName := FRepository.ProjectFileName
    else if FileExists(FRepository.ProjectFileName) then
      DirectoryName := ExtractFilePath(FRepository.ProjectFileName);
  end;

  if DirectoryName = '' then
    DirectoryName := GetCurrentDir;
  DirectoryName := ExcludeTrailingPathDelimiter(DirectoryName);

  if (FTerminalCurrentDirectory = '') or (not DirectoryExists(FTerminalCurrentDirectory)) then
    FTerminalCurrentDirectory := DirectoryName
  else if (FRepository.RootPath <> '') and
    (Pos(UpperCase(FRepository.RootPath), UpperCase(FTerminalCurrentDirectory)) <> 1) then
    FTerminalCurrentDirectory := DirectoryName;

  UpdateTerminalPrompt;
end;

procedure TGit4DWorkbenchForm.UpdateTerminalPrompt;
begin
  if FTerminalPromptLabel = nil then
    Exit;

  FTerminalPromptLabel.Hint := FTerminalCurrentDirectory;
  FTerminalPromptLabel.ShowHint := True;
  if FTerminalCurrentDirectory = '' then
    FTerminalPromptLabel.Caption := 'terminal>'
  else
    FTerminalPromptLabel.Caption := ExtractFileName(FTerminalCurrentDirectory) + '>';
end;

procedure TGit4DStyleNotifier.ChangedTheme;
begin
  RefreshGit4DWorkbenchSettings;
end;

procedure TGit4DStyleNotifier.ChangingTheme;
begin
end;

procedure ShowGit4DWorkbench;
begin
  if GWorkbench = nil then
    GWorkbench := TGit4DWorkbenchForm.Create(Application);
  RegisterStyleNotifier;
  GWorkbench.Show;
  GWorkbench.BringToFront;
  GWorkbench.UpdateWorkbenchSettings;
  GWorkbench.RefreshRepository;
end;

procedure CloseGit4DWorkbench;
begin
  if GWorkbench <> nil then
    try
      GWorkbench.Close;
    except
      GWorkbench := nil;
    end;
end;

procedure ReleaseGit4DWorkbench;
var
  Workbench: TGit4DWorkbenchForm;
begin
  Workbench := GWorkbench;
  GWorkbench := nil;
  if Workbench <> nil then
  begin
    try
      Workbench.OnShow := nil;
      Workbench.SaveStateNecessary := False;
      Workbench.AutoSave := False;
      Workbench.Hide;
      Workbench.Free;
    except
    end;
  end;
  UnregisterStyleNotifier;
end;

procedure RefreshGit4DWorkbenchSettings;
begin
  if GWorkbench <> nil then
    GWorkbench.UpdateWorkbenchSettings;
end;

initialization
  GWorkbench := nil;

finalization
  ReleaseGit4DWorkbench;
  UnregisterStyleNotifier;

end.
