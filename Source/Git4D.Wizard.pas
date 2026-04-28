unit Git4D.Wizard;

interface

uses
  System.Classes,
  System.StrUtils,
  Vcl.ActnList,
  Vcl.ExtCtrls,
  Vcl.Menus,
  ToolsAPI,
  Git4D.GitExtensions,
  Git4D.TortoiseGit,
  Git4D.TortoiseSVN;

type
  TGit4DWizard = class;

  TGit4DEditorPopupHook = class(TComponent)
  private
    FOldOnPopup: TNotifyEvent;
    FPopupOpening: Boolean;
    FPopupMenu: TPopupMenu;
    FWizard: TGit4DWizard;
    function IsHooked: Boolean;
    procedure PopupOpening(Sender: TObject);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AWizard: TGit4DWizard; APopupMenu: TPopupMenu); reintroduce;
    destructor Destroy; override;
    procedure EnsureHooked;
    property PopupMenu: TPopupMenu read FPopupMenu;
  end;

  TGit4DProjectMenuKind = (
    pmStatus,
    pmCommit,
    pmPull,
    pmPush,
    pmDiff,
    pmHistory
  );

  TGit4DProjectMenuItem = class(TNotifierObject, IOTAProjectManagerMenu)
  private
    FCaption: string;
    FChecked: Boolean;
    FEnabled: Boolean;
    FHelpContext: Integer;
    FIsMultiSelectable: Boolean;
    FKind: TGit4DProjectMenuKind;
    FName: string;
    FParent: string;
    FPosition: Integer;
    FVerb: string;
  public
    constructor Create(AKind: TGit4DProjectMenuKind; const ACaption, AName: string);
    function GetCaption: string;
    function GetChecked: Boolean;
    function GetEnabled: Boolean;
    function GetHelpContext: Integer;
    function GetName: string; reintroduce;
    function GetParent: string;
    function GetPosition: Integer;
    function GetVerb: string;
    procedure SetCaption(const Value: string);
    procedure SetChecked(Value: Boolean);
    procedure SetEnabled(Value: Boolean);
    procedure SetHelpContext(Value: Integer);
    procedure SetName(const Value: string);
    procedure SetParent(const Value: string);
    procedure SetPosition(Value: Integer);
    procedure SetVerb(const Value: string);
    function GetIsMultiSelectable: Boolean;
    procedure SetIsMultiSelectable(Value: Boolean);
    procedure Execute(const MenuContextList: IInterfaceList); overload;
    function PreExecute(const MenuContextList: IInterfaceList): Boolean;
    function PostExecute(const MenuContextList: IInterfaceList): Boolean;
  end;

  TGit4DProjectMenuNotifier = class(TNotifierObject, IOTAProjectMenuItemCreatorNotifier,
    INTAProjectMenuCreatorNotifier)
  private
    procedure AddProjectCommand(Menu: TMenuItem; AKind: TGit4DProjectMenuKind; const ACaption: string);
    procedure AddProjectGitExtensionsCommand(Menu: TMenuItem; Command: TGitExtensionsCommand);
    procedure AddProjectSeparator(Menu: TMenuItem);
    procedure AddProjectTortoiseGitCommand(Menu: TMenuItem; Command: TTortoiseGitCommand);
    procedure AddProjectTortoiseSvnCommand(Menu: TMenuItem; Command: TTortoiseSvnCommand);
    procedure ProjectCommandClick(Sender: TObject);
    procedure ProjectGitExtensionsClick(Sender: TObject);
    procedure ProjectTortoiseGitClick(Sender: TObject);
    procedure ProjectTortoiseSvnClick(Sender: TObject);
  public
    procedure AddMenu(const Project: IOTAProject; const IdentList: TStrings;
      const ProjectManagerMenuList: IInterfaceList; IsMultiSelect: Boolean); overload;
    function AddMenu(const Ident: string): TMenuItem; overload;
    function CanHandle(const Ident: string): Boolean;
  end;

  TGit4DWizard = class(TNotifierObject, IOTAWizard, IOTAMenuWizard)
  private
    FActionList: TActionList;
    FEditorMenuInstalled: Boolean;
    FEditorPopupHookTimer: TTimer;
    FEditorPopupHooks: TList;
    FMainMenu: TMenuItem;
    FMainMenuInstalled: Boolean;
    FMainMenuRetryCount: Integer;
    FMainMenuRetryTimer: TTimer;
    FProjectMenuNotifier: TGit4DProjectMenuNotifier;
    FProjectMenuNotifierIndex: Integer;
    FProjectMenuUsesLegacyNotifier: Boolean;
    procedure AddAction(const Caption: string; const Handler: TNotifyEvent; const Shortcut: TShortCut = 0);
    procedure AddGitCommand(Menu: TMenuItem; const Caption: string; const Handler: TNotifyEvent);
    procedure AddGitExtensionsCommand(Menu: TMenuItem; Command: TGitExtensionsCommand);
    function AddGitExtensionsSubMenu(ParentMenu: TMenuItem): Boolean;
    function AddGitSubMenu(ParentMenu: TMenuItem): TMenuItem;
    function AddTortoiseGitSubMenu(ParentMenu: TMenuItem): Boolean;
    procedure AddTortoiseGitCommand(Menu: TMenuItem; Command: TTortoiseGitCommand);
    procedure AddTortoiseSvnCommand(Menu: TMenuItem; Command: TTortoiseSvnCommand);
    function AddTortoiseSvnSubMenu(ParentMenu: TMenuItem): Boolean;
    procedure AddSeparator;
    procedure AddSubMenu(const Caption: string; const Items: array of TMenuItem);
    function CreateActionItem(const Caption: string; const Handler: TNotifyEvent; const Shortcut: TShortCut = 0): TMenuItem;
    function CreateSeparator: TMenuItem;
    procedure EditorPopupHookTimer(Sender: TObject);
    function FindToolsMenu(MainMenu: TMainMenu): TMenuItem;
    procedure ClearLegacyEditorLocalMenuRegistrations;
    procedure HookEditorPopups;
    procedure HookPopupMenu(PopupMenu: TPopupMenu);
    function IsCandidateEditorPopupMenu(PopupMenu: TPopupMenu): Boolean;
    procedure InstallEditorLocalMenu;
    procedure InstallMainMenu;
    procedure InstallProjectManagerMenu;
    function IsGit4DPopupMenu(PopupMenu: TPopupMenu): Boolean;
    procedure MainMenuRetryTimer(Sender: TObject);
    procedure UninstallEditorLocalMenu;
    procedure MainMenuPopup(Sender: TObject);
    procedure RebuildMainMenuItems;
    procedure RebuildEditorPopupMenu(PopupMenu: TPopupMenu);
    procedure RemoveGit4DPopupItem(PopupMenu: TPopupMenu);
    procedure BrowseRepository(Sender: TObject);
    procedure ShowStatus(Sender: TObject);
    procedure Commit(Sender: TObject);
    procedure Fetch(Sender: TObject);
    procedure Pull(Sender: TObject);
    procedure Push(Sender: TObject);
    procedure Stash(Sender: TObject);
    procedure CheckoutBranch(Sender: TObject);
    procedure CreateBranch(Sender: TObject);
    procedure MergeBranch(Sender: TObject);
    procedure RebaseBranch(Sender: TObject);
    procedure CherryPick(Sender: TObject);
    procedure ApplyPatch(Sender: TObject);
    procedure FormatPatch(Sender: TObject);
    procedure ManageRemotes(Sender: TObject);
    procedure EditGitIgnore(Sender: TObject);
    procedure DiffCurrentFile(Sender: TObject);
    procedure FileHistory(Sender: TObject);
    procedure BlameCurrentFile(Sender: TObject);
    procedure StageCurrentFile(Sender: TObject);
    procedure ResetCurrentFile(Sender: TObject);
    procedure OpenTerminal(Sender: TObject);
    procedure ShowSettings(Sender: TObject);
    procedure ShowAbout(Sender: TObject);
    procedure GitExtensionsCommand(Sender: TObject);
    procedure TortoiseSvnCommand(Sender: TObject);
    procedure ScheduleMainMenuRetry;
    procedure UpdateEditorAction(Sender: TObject);
    procedure UpdateEditorTortoiseGitAction(Sender: TObject);
    procedure TortoiseGitCommand(Sender: TObject);
  public
    constructor Create;
    destructor Destroy; override;
    procedure AfterSave;
    procedure BeforeSave;
    procedure Destroyed;
    procedure Modified;
    function GetIDString: string;
    function GetName: string;
    function GetState: TWizardState;
    procedure Execute;
    function GetMenuText: string;
  end;

implementation

uses
  System.SysUtils,
  Vcl.Dialogs,
  Vcl.Forms,
  Git4D.Constants,
  Git4D.Dialogs,
  Git4D.Git,
  Git4D.Options,
  Git4D.Repository,
  Git4D.Settings;

const
  G4DLegacyEditorActionListCategory = 'Git4D';
  G4DLegacyEditorActionListCategory2 = 'Git4D.EditorLocalMenu';
  G4DEditorPopupMenuName = 'Git4DEditorPopupMenu';
  G4DMainMenuName = 'Git4DToolsMenu';
  G4DMainMenuRetryLimit = 20;

function NormalizedCaption(const Caption: string): string;
begin
  Result := StringReplace(Caption, '&', '', [rfReplaceAll]);
end;

constructor TGit4DEditorPopupHook.Create(AWizard: TGit4DWizard; APopupMenu: TPopupMenu);
begin
  inherited Create(nil);
  FWizard := AWizard;
  FPopupMenu := APopupMenu;
  EnsureHooked;
end;

procedure TGit4DEditorPopupHook.EnsureHooked;
begin
  if FPopupMenu <> nil then
  begin
    FPopupMenu.FreeNotification(Self);
    if not IsHooked then
    begin
      FOldOnPopup := FPopupMenu.OnPopup;
      FPopupMenu.OnPopup := PopupOpening;
    end;
  end;
end;

destructor TGit4DEditorPopupHook.Destroy;
begin
  if FPopupMenu <> nil then
  begin
    try
      if IsHooked then
        FPopupMenu.OnPopup := FOldOnPopup;
      FPopupMenu.RemoveFreeNotification(Self);
    except
    end;
  end;
  inherited Destroy;
end;

procedure TGit4DEditorPopupHook.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FPopupMenu) then
    FPopupMenu := nil;
end;

function TGit4DEditorPopupHook.IsHooked: Boolean;
var
  CurrentMethod: TMethod;
  HookEvent: TNotifyEvent;
  HookMethod: TMethod;
begin
  Result := False;
  if FPopupMenu = nil then
    Exit;

  CurrentMethod := TMethod(FPopupMenu.OnPopup);
  HookEvent := PopupOpening;
  HookMethod := TMethod(HookEvent);
  Result := (CurrentMethod.Code = HookMethod.Code) and (CurrentMethod.Data = HookMethod.Data);
end;

procedure TGit4DEditorPopupHook.PopupOpening(Sender: TObject);
begin
  if FPopupOpening then
    Exit;

  FPopupOpening := True;
  try
    if (FWizard <> nil) and (Sender is TPopupMenu) then
      FWizard.RemoveGit4DPopupItem(Sender as TPopupMenu);
    if Assigned(FOldOnPopup) then
      FOldOnPopup(Sender);
    if (FWizard <> nil) and (Sender is TPopupMenu) then
      FWizard.RebuildEditorPopupMenu(Sender as TPopupMenu);
  finally
    FPopupOpening := False;
  end;
end;

constructor TGit4DProjectMenuItem.Create(AKind: TGit4DProjectMenuKind; const ACaption, AName: string);
begin
  inherited Create;
  FKind := AKind;
  FCaption := ACaption;
  FName := AName;
  FEnabled := True;
  FPosition := 1000 + Ord(AKind);
  FVerb := AName;
end;

function TGit4DProjectMenuItem.GetCaption: string;
begin
  Result := FCaption;
end;

function TGit4DProjectMenuItem.GetChecked: Boolean;
begin
  Result := FChecked;
end;

function TGit4DProjectMenuItem.GetEnabled: Boolean;
begin
  Result := FEnabled;
end;

function TGit4DProjectMenuItem.GetHelpContext: Integer;
begin
  Result := FHelpContext;
end;

function TGit4DProjectMenuItem.GetName: string;
begin
  Result := FName;
end;

function TGit4DProjectMenuItem.GetParent: string;
begin
  Result := FParent;
end;

function TGit4DProjectMenuItem.GetPosition: Integer;
begin
  Result := FPosition;
end;

function TGit4DProjectMenuItem.GetVerb: string;
begin
  Result := FVerb;
end;

procedure TGit4DProjectMenuItem.SetCaption(const Value: string);
begin
  FCaption := Value;
end;

procedure TGit4DProjectMenuItem.SetChecked(Value: Boolean);
begin
  FChecked := Value;
end;

procedure TGit4DProjectMenuItem.SetEnabled(Value: Boolean);
begin
  FEnabled := Value;
end;

procedure TGit4DProjectMenuItem.SetHelpContext(Value: Integer);
begin
  FHelpContext := Value;
end;

procedure TGit4DProjectMenuItem.SetName(const Value: string);
begin
  FName := Value;
end;

procedure TGit4DProjectMenuItem.SetParent(const Value: string);
begin
  FParent := Value;
end;

procedure TGit4DProjectMenuItem.SetPosition(Value: Integer);
begin
  FPosition := Value;
end;

procedure TGit4DProjectMenuItem.SetVerb(const Value: string);
begin
  FVerb := Value;
end;

function TGit4DProjectMenuItem.GetIsMultiSelectable: Boolean;
begin
  Result := FIsMultiSelectable;
end;

procedure TGit4DProjectMenuItem.SetIsMultiSelectable(Value: Boolean);
begin
  FIsMultiSelectable := Value;
end;

procedure TGit4DProjectMenuItem.Execute(const MenuContextList: IInterfaceList);
begin
  case FKind of
    pmStatus:
      TGit4DGit.RunGitForActiveRepository('status --short --branch');
    pmCommit:
      TGit4DGit.RunGitForActiveRepository('status --short && git add --patch && git commit');
    pmPull:
      TGit4DGit.RunGitForActiveRepository('pull --stat');
    pmPush:
      TGit4DGit.RunGitForActiveRepository('push');
    pmDiff:
      TGit4DGit.DiffActiveFile;
    pmHistory:
      TGit4DGit.FileHistory;
  end;
end;

function TGit4DProjectMenuItem.PreExecute(const MenuContextList: IInterfaceList): Boolean;
begin
  Result := True;
end;

function TGit4DProjectMenuItem.PostExecute(const MenuContextList: IInterfaceList): Boolean;
begin
  Result := True;
end;

procedure TGit4DProjectMenuNotifier.AddMenu(const Project: IOTAProject; const IdentList: TStrings;
  const ProjectManagerMenuList: IInterfaceList; IsMultiSelect: Boolean);
begin
  ProjectManagerMenuList.Add(TGit4DProjectMenuItem.Create(pmStatus,
    G4DProductName + ': Status', 'Git4DProjectStatus') as IOTAProjectManagerMenu);
  ProjectManagerMenuList.Add(TGit4DProjectMenuItem.Create(pmCommit,
    G4DProductName + ': Commit', 'Git4DProjectCommit') as IOTAProjectManagerMenu);
  ProjectManagerMenuList.Add(TGit4DProjectMenuItem.Create(pmPull,
    G4DProductName + ': Pull', 'Git4DProjectPull') as IOTAProjectManagerMenu);
  ProjectManagerMenuList.Add(TGit4DProjectMenuItem.Create(pmPush,
    G4DProductName + ': Push', 'Git4DProjectPush') as IOTAProjectManagerMenu);
  ProjectManagerMenuList.Add(TGit4DProjectMenuItem.Create(pmDiff,
    G4DProductName + ': Diff Current File', 'Git4DProjectDiff') as IOTAProjectManagerMenu);
  ProjectManagerMenuList.Add(TGit4DProjectMenuItem.Create(pmHistory,
    G4DProductName + ': File History', 'Git4DProjectHistory') as IOTAProjectManagerMenu);
end;

procedure TGit4DProjectMenuNotifier.AddProjectCommand(Menu: TMenuItem;
  AKind: TGit4DProjectMenuKind; const ACaption: string);
var
  Item: TMenuItem;
begin
  Item := TMenuItem.Create(Menu);
  Item.Caption := ACaption;
  Item.Tag := Ord(AKind);
  Item.OnClick := ProjectCommandClick;
  Menu.Add(Item);
end;

procedure TGit4DProjectMenuNotifier.AddProjectSeparator(Menu: TMenuItem);
var
  Item: TMenuItem;
begin
  Item := TMenuItem.Create(Menu);
  Item.Caption := '-';
  Menu.Add(Item);
end;

procedure TGit4DProjectMenuNotifier.AddProjectGitExtensionsCommand(Menu: TMenuItem;
  Command: TGitExtensionsCommand);
var
  Item: TMenuItem;
begin
  Item := TMenuItem.Create(Menu);
  Item.Caption := TGit4DGitExtensions.CommandDisplayName(Command);
  Item.Tag := Ord(Command);
  Item.HelpContext := Ord(Command);
  Item.OnClick := ProjectGitExtensionsClick;
  Menu.Add(Item);
end;

procedure TGit4DProjectMenuNotifier.AddProjectTortoiseGitCommand(Menu: TMenuItem;
  Command: TTortoiseGitCommand);
var
  Item: TMenuItem;
begin
  Item := TMenuItem.Create(Menu);
  Item.Caption := TGit4DTortoiseGit.CommandDisplayName(Command);
  Item.Tag := Ord(Command);
  Item.HelpContext := Ord(Command);
  Item.OnClick := ProjectTortoiseGitClick;
  Menu.Add(Item);
end;

procedure TGit4DProjectMenuNotifier.AddProjectTortoiseSvnCommand(Menu: TMenuItem;
  Command: TTortoiseSvnCommand);
var
  Item: TMenuItem;
begin
  Item := TMenuItem.Create(Menu);
  Item.Caption := TGit4DTortoiseSVN.CommandDisplayName(Command);
  Item.Tag := Ord(Command);
  Item.HelpContext := Ord(Command);
  Item.OnClick := ProjectTortoiseSvnClick;
  Menu.Add(Item);
end;

function TGit4DProjectMenuNotifier.AddMenu(const Ident: string): TMenuItem;
var
  ExternalMenuAdded: Boolean;
  GitExtensionsMenu: TMenuItem;
  TortoiseMenu: TMenuItem;
  TortoiseSvnMenu: TMenuItem;
begin
  Result := TMenuItem.Create(nil);
  Result.Caption := G4DProductName;

  ExternalMenuAdded := False;
  if Git4DSettings.TortoiseSvnEnabled then
  begin
    TortoiseSvnMenu := TMenuItem.Create(Result);
    TortoiseSvnMenu.Caption := 'TortoiseSVN';
    AddProjectTortoiseSvnCommand(TortoiseSvnMenu, svnLog);
    AddProjectTortoiseSvnCommand(TortoiseSvnMenu, svnDiff);
    AddProjectTortoiseSvnCommand(TortoiseSvnMenu, svnBlame);
    AddProjectTortoiseSvnCommand(TortoiseSvnMenu, svnCommit);
    AddProjectTortoiseSvnCommand(TortoiseSvnMenu, svnUpdate);
    AddProjectTortoiseSvnCommand(TortoiseSvnMenu, svnCheckForModifications);
    AddProjectTortoiseSvnCommand(TortoiseSvnMenu, svnRepoBrowser);
    AddProjectTortoiseSvnCommand(TortoiseSvnMenu, svnSettings);
    Result.Add(TortoiseSvnMenu);
    ExternalMenuAdded := True;
  end;

  if Git4DSettings.TortoiseGitEnabled then
  begin
    TortoiseMenu := TMenuItem.Create(Result);
    TortoiseMenu.Caption := 'TortoiseGit';
    AddProjectTortoiseGitCommand(TortoiseMenu, tgLog);
    AddProjectTortoiseGitCommand(TortoiseMenu, tgDiff);
    AddProjectTortoiseGitCommand(TortoiseMenu, tgCommit);
    AddProjectTortoiseGitCommand(TortoiseMenu, tgPull);
    AddProjectTortoiseGitCommand(TortoiseMenu, tgPush);
    AddProjectTortoiseGitCommand(TortoiseMenu, tgSync);
    AddProjectTortoiseGitCommand(TortoiseMenu, tgReflog);
    AddProjectTortoiseGitCommand(TortoiseMenu, tgRepoBrowser);
    AddProjectTortoiseGitCommand(TortoiseMenu, tgSettings);
    Result.Add(TortoiseMenu);
    ExternalMenuAdded := True;
  end;

  if Git4DSettings.GitExtensionsEnabled then
  begin
    GitExtensionsMenu := TMenuItem.Create(Result);
    GitExtensionsMenu.Caption := 'Git Extensions';
    AddProjectGitExtensionsCommand(GitExtensionsMenu, geBrowse);
    AddProjectGitExtensionsCommand(GitExtensionsMenu, geCommit);
    AddProjectGitExtensionsCommand(GitExtensionsMenu, gePull);
    AddProjectGitExtensionsCommand(GitExtensionsMenu, gePush);
    AddProjectGitExtensionsCommand(GitExtensionsMenu, geSynchronize);
    AddProjectGitExtensionsCommand(GitExtensionsMenu, geFileHistory);
    AddProjectGitExtensionsCommand(GitExtensionsMenu, geBlame);
    AddProjectGitExtensionsCommand(GitExtensionsMenu, geDiffTool);
    AddProjectGitExtensionsCommand(GitExtensionsMenu, geSettings);
    Result.Add(GitExtensionsMenu);
    ExternalMenuAdded := True;
  end;

  if ExternalMenuAdded then
    AddProjectSeparator(Result);

  AddProjectCommand(Result, pmStatus, 'Status');
  AddProjectCommand(Result, pmCommit, 'Commit');
  AddProjectCommand(Result, pmPull, 'Pull');
  AddProjectCommand(Result, pmPush, 'Push');
  AddProjectSeparator(Result);
  AddProjectCommand(Result, pmDiff, 'Diff Current File');
  AddProjectCommand(Result, pmHistory, 'File History');
end;

function TGit4DProjectMenuNotifier.CanHandle(const Ident: string): Boolean;
begin
  Result := True;
end;

procedure TGit4DProjectMenuNotifier.ProjectCommandClick(Sender: TObject);
var
  Kind: TGit4DProjectMenuKind;
begin
  if not (Sender is TMenuItem) then
    Exit;

  Kind := TGit4DProjectMenuKind((Sender as TMenuItem).Tag);
  case Kind of
    pmStatus:
      TGit4DGit.RunGitForActiveRepository('status --short --branch');
    pmCommit:
      TGit4DGit.RunGitForActiveRepository('status --short && git add --patch && git commit');
    pmPull:
      TGit4DGit.RunGitForActiveRepository('pull --stat');
    pmPush:
      TGit4DGit.RunGitForActiveRepository('push');
    pmDiff:
      TGit4DGit.DiffActiveFile;
    pmHistory:
      TGit4DGit.FileHistory;
  end;
end;

procedure TGit4DProjectMenuNotifier.ProjectGitExtensionsClick(Sender: TObject);
var
  Command: TGitExtensionsCommand;
  CommandOrdinal: Integer;
begin
  try
    if not (Sender is TMenuItem) then
      Exit;

    CommandOrdinal := (Sender as TMenuItem).HelpContext;
    if (CommandOrdinal < Ord(Low(TGitExtensionsCommand))) or
      (CommandOrdinal > Ord(High(TGitExtensionsCommand))) then
      raise Exception.CreateFmt('Invalid Git Extensions command id: %d', [CommandOrdinal]);

    Command := TGitExtensionsCommand(CommandOrdinal);
    if Command in [geAdd, geApply, geBlame, geDiffTool, geFileEditor, geFileHistory, geRevert, geViewPatch] then
      TGit4DGitExtensions.RunForActiveFile(Command)
    else
      TGit4DGitExtensions.RunForActiveRepository(Command);
  except
    on E: Exception do
      MessageDlg(E.Message, mtError, [mbOK], 0);
  end;
end;

procedure TGit4DProjectMenuNotifier.ProjectTortoiseGitClick(Sender: TObject);
var
  Command: TTortoiseGitCommand;
  CommandOrdinal: Integer;
begin
  try
    if not (Sender is TMenuItem) then
      Exit;

    CommandOrdinal := (Sender as TMenuItem).HelpContext;
    if (CommandOrdinal < Ord(Low(TTortoiseGitCommand))) or
      (CommandOrdinal > Ord(High(TTortoiseGitCommand))) then
      raise Exception.CreateFmt('Invalid TortoiseGit command id: %d', [CommandOrdinal]);

    Command := TTortoiseGitCommand(CommandOrdinal);
    if Command in [tgDiff, tgPreviousDiff, tgBlame, tgResolve] then
      TGit4DTortoiseGit.RunForActiveFile(Command)
    else
      TGit4DTortoiseGit.RunForActiveRepository(Command);
  except
    on E: Exception do
      MessageDlg(E.Message, mtError, [mbOK], 0);
  end;
end;

procedure TGit4DProjectMenuNotifier.ProjectTortoiseSvnClick(Sender: TObject);
var
  Command: TTortoiseSvnCommand;
  CommandOrdinal: Integer;
begin
  try
    if not (Sender is TMenuItem) then
      Exit;

    CommandOrdinal := (Sender as TMenuItem).HelpContext;
    if (CommandOrdinal < Ord(Low(TTortoiseSvnCommand))) or
      (CommandOrdinal > Ord(High(TTortoiseSvnCommand))) then
      raise Exception.CreateFmt('Invalid TortoiseSVN command id: %d', [CommandOrdinal]);

    Command := TTortoiseSvnCommand(CommandOrdinal);
    if Command in [svnDiff, svnPreviousDiff, svnBlame, svnResolved] then
      TGit4DTortoiseSVN.RunForActiveFile(Command)
    else
      TGit4DTortoiseSVN.RunForActiveRepository(Command);
  except
    on E: Exception do
      MessageDlg(E.Message, mtError, [mbOK], 0);
  end;
end;

constructor TGit4DWizard.Create;
begin
  inherited Create;
  FActionList := TActionList.Create(nil);
  FProjectMenuNotifierIndex := -1;
  try
    InstallMainMenu;
  except
    ScheduleMainMenuRetry;
  end;
  try
    ClearLegacyEditorLocalMenuRegistrations;
    InstallEditorLocalMenu;
  except
    UninstallEditorLocalMenu;
  end;
  try
    InstallProjectManagerMenu;
  except
  end;
end;

destructor TGit4DWizard.Destroy;
begin
  UninstallEditorLocalMenu;
  if FProjectMenuNotifierIndex >= 0 then
    try
      if FProjectMenuUsesLegacyNotifier then
        (BorlandIDEServices as IOTAProjectManager).RemoveMenuCreatorNotifier(FProjectMenuNotifierIndex)
      else
        (BorlandIDEServices as IOTAProjectManager).RemoveMenuItemCreatorNotifier(FProjectMenuNotifierIndex);
    except
    end;
  if (FMainMenu <> nil) and (FMainMenu.Parent <> nil) then
    FMainMenu.Parent.Remove(FMainMenu);
  FMainMenu.Free;
  FMainMenuRetryTimer.Free;
  FActionList.Free;
  inherited Destroy;
end;

procedure TGit4DWizard.AfterSave;
begin
end;

procedure TGit4DWizard.BeforeSave;
begin
end;

procedure TGit4DWizard.Destroyed;
begin
end;

procedure TGit4DWizard.Modified;
begin
end;

function TGit4DWizard.GetIDString: string;
begin
  Result := G4DWizardID;
end;

function TGit4DWizard.GetName: string;
begin
  Result := G4DProductName;
end;

function TGit4DWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

procedure TGit4DWizard.Execute;
begin
  BrowseRepository(nil);
end;

function TGit4DWizard.GetMenuText: string;
begin
  Result := G4DProductName;
end;

function TGit4DWizard.CreateActionItem(const Caption: string; const Handler: TNotifyEvent;
  const Shortcut: TShortCut): TMenuItem;
begin
  Result := TMenuItem.Create(nil);
  Result.Caption := Caption;
  Result.ShortCut := Shortcut;
  Result.OnClick := Handler;
end;

function TGit4DWizard.CreateSeparator: TMenuItem;
begin
  Result := TMenuItem.Create(nil);
  Result.Caption := '-';
end;

procedure TGit4DWizard.EditorPopupHookTimer(Sender: TObject);
begin
  HookEditorPopups;
end;

procedure TGit4DWizard.ClearLegacyEditorLocalMenuRegistrations;
var
  EditorLocalMenu: INTAEditorLocalMenu;
  EditorServices: IOTAEditorServices;
begin
  try
    if Supports(BorlandIDEServices, IOTAEditorServices, EditorServices) then
    begin
      EditorLocalMenu := EditorServices.GetEditorLocalMenu;
      if EditorLocalMenu <> nil then
      begin
        try
          EditorLocalMenu.UnregisterActionList(G4DLegacyEditorActionListCategory);
        except
        end;
        try
          EditorLocalMenu.UnregisterActionList(G4DLegacyEditorActionListCategory2);
        except
        end;
      end;
    end;
  except
  end;
end;

procedure TGit4DWizard.HookEditorPopups;
var
  ComponentIndex: Integer;
  EditWindow: INTAEditWindow;
  Form: TCustomForm;
  PopupMenu: TPopupMenu;
  ServiceIndex: Integer;
  Services: INTAEditorServices;
begin
  if not Git4DSettings.EditorPopupEnabled then
    Exit;

  if FEditorPopupHooks = nil then
    FEditorPopupHooks := TList.Create;

  if not Supports(BorlandIDEServices, INTAEditorServices, Services) then
    Exit;

  for ServiceIndex := 0 to Services.GetEditWindowCount - 1 do
  begin
    EditWindow := Services.GetEditWindow(ServiceIndex);
    if EditWindow = nil then
      Continue;

    Form := EditWindow.GetForm;
    if Form = nil then
      Continue;

    for ComponentIndex := 0 to Form.ComponentCount - 1 do
      if Form.Components[ComponentIndex] is TPopupMenu then
      begin
        PopupMenu := TPopupMenu(Form.Components[ComponentIndex]);
        if IsCandidateEditorPopupMenu(PopupMenu) then
          HookPopupMenu(PopupMenu);
      end;
  end;
end;

procedure TGit4DWizard.HookPopupMenu(PopupMenu: TPopupMenu);
var
  Index: Integer;
  Hook: TGit4DEditorPopupHook;
begin
  if PopupMenu = nil then
    Exit;

  if FEditorPopupHooks = nil then
    FEditorPopupHooks := TList.Create;

  for Index := FEditorPopupHooks.Count - 1 downto 0 do
  begin
    Hook := TGit4DEditorPopupHook(FEditorPopupHooks[Index]);
    if Hook.PopupMenu = nil then
    begin
      Hook.Free;
      FEditorPopupHooks.Delete(Index);
    end
    else if Hook.PopupMenu = PopupMenu then
    begin
      Hook.EnsureHooked;
      Exit;
    end;
  end;

  FEditorPopupHooks.Add(TGit4DEditorPopupHook.Create(Self, PopupMenu));
end;

function TGit4DWizard.IsCandidateEditorPopupMenu(PopupMenu: TPopupMenu): Boolean;
var
  OwnerName: string;
begin
  Result := False;
  if PopupMenu = nil then
    Exit;

  if SameText(PopupMenu.Name, 'EditorLocalMenu') or
    ContainsText(PopupMenu.Name, 'Editor') then
    Exit(True);

  if PopupMenu.Owner is TComponent then
    OwnerName := TComponent(PopupMenu.Owner).Name
  else
    OwnerName := '';

  Result := ContainsText(OwnerName, 'Editor') or IsGit4DPopupMenu(PopupMenu);
end;

procedure TGit4DWizard.AddAction(const Caption: string; const Handler: TNotifyEvent;
  const Shortcut: TShortCut);
begin
  FMainMenu.Add(CreateActionItem(Caption, Handler, Shortcut));
end;

procedure TGit4DWizard.AddTortoiseGitCommand(Menu: TMenuItem; Command: TTortoiseGitCommand);
var
  Item: TMenuItem;
begin
  Item := CreateActionItem(TGit4DTortoiseGit.CommandDisplayName(Command), TortoiseGitCommand);
  Item.Tag := Ord(Command);
  Item.HelpContext := Ord(Command);
  Menu.Add(Item);
end;

procedure TGit4DWizard.AddTortoiseSvnCommand(Menu: TMenuItem; Command: TTortoiseSvnCommand);
var
  Item: TMenuItem;
begin
  Item := CreateActionItem(TGit4DTortoiseSVN.CommandDisplayName(Command), TortoiseSvnCommand);
  Item.Tag := Ord(Command);
  Item.HelpContext := Ord(Command);
  Menu.Add(Item);
end;

procedure TGit4DWizard.AddGitExtensionsCommand(Menu: TMenuItem; Command: TGitExtensionsCommand);
var
  Item: TMenuItem;
begin
  Item := CreateActionItem(TGit4DGitExtensions.CommandDisplayName(Command), GitExtensionsCommand);
  Item.Tag := Ord(Command);
  Item.HelpContext := Ord(Command);
  Menu.Add(Item);
end;

procedure TGit4DWizard.AddSeparator;
begin
  FMainMenu.Add(CreateSeparator);
end;

procedure TGit4DWizard.AddSubMenu(const Caption: string; const Items: array of TMenuItem);
var
  Menu: TMenuItem;
  Index: Integer;
begin
  Menu := TMenuItem.Create(nil);
  Menu.Caption := Caption;
  for Index := Low(Items) to High(Items) do
    Menu.Add(Items[Index]);
  FMainMenu.Add(Menu);
end;

procedure TGit4DWizard.AddGitCommand(Menu: TMenuItem; const Caption: string; const Handler: TNotifyEvent);
begin
  Menu.Add(CreateActionItem(Caption, Handler));
end;

function TGit4DWizard.AddTortoiseSvnSubMenu(ParentMenu: TMenuItem): Boolean;
var
  TortoiseSvnMenu: TMenuItem;
begin
  Result := False;
  if not Git4DSettings.TortoiseSvnEnabled then
    Exit;

  TortoiseSvnMenu := TMenuItem.Create(ParentMenu);
  TortoiseSvnMenu.Caption := 'TortoiseSVN';

  AddTortoiseSvnCommand(TortoiseSvnMenu, svnUpdate);
  AddTortoiseSvnCommand(TortoiseSvnMenu, svnCommit);
  AddTortoiseSvnCommand(TortoiseSvnMenu, svnDiff);
  AddTortoiseSvnCommand(TortoiseSvnMenu, svnPreviousDiff);
  AddTortoiseSvnCommand(TortoiseSvnMenu, svnLog);
  AddTortoiseSvnCommand(TortoiseSvnMenu, svnBlame);
  AddTortoiseSvnCommand(TortoiseSvnMenu, svnCheckForModifications);
  AddTortoiseSvnCommand(TortoiseSvnMenu, svnRepoBrowser);
  AddTortoiseSvnCommand(TortoiseSvnMenu, svnRevisionGraph);
  TortoiseSvnMenu.Add(CreateSeparator);
  AddTortoiseSvnCommand(TortoiseSvnMenu, svnAdd);
  AddTortoiseSvnCommand(TortoiseSvnMenu, svnRevert);
  AddTortoiseSvnCommand(TortoiseSvnMenu, svnCleanup);
  AddTortoiseSvnCommand(TortoiseSvnMenu, svnResolved);
  TortoiseSvnMenu.Add(CreateSeparator);
  AddTortoiseSvnCommand(TortoiseSvnMenu, svnSwitch);
  AddTortoiseSvnCommand(TortoiseSvnMenu, svnMerge);
  AddTortoiseSvnCommand(TortoiseSvnMenu, svnBranchTag);
  AddTortoiseSvnCommand(TortoiseSvnMenu, svnCheckout);
  AddTortoiseSvnCommand(TortoiseSvnMenu, svnExport);
  TortoiseSvnMenu.Add(CreateSeparator);
  AddTortoiseSvnCommand(TortoiseSvnMenu, svnSettings);
  AddTortoiseSvnCommand(TortoiseSvnMenu, svnHelp);
  AddTortoiseSvnCommand(TortoiseSvnMenu, svnAbout);

  ParentMenu.Add(TortoiseSvnMenu);
  Result := True;
end;

function TGit4DWizard.AddGitExtensionsSubMenu(ParentMenu: TMenuItem): Boolean;
var
  GitExtensionsMenu: TMenuItem;
begin
  Result := False;
  if not Git4DSettings.GitExtensionsEnabled then
    Exit;

  GitExtensionsMenu := TMenuItem.Create(ParentMenu);
  GitExtensionsMenu.Caption := 'Git Extensions';

  AddGitExtensionsCommand(GitExtensionsMenu, geBrowse);
  AddGitExtensionsCommand(GitExtensionsMenu, geOpenRepo);
  AddGitExtensionsCommand(GitExtensionsMenu, geCommit);
  AddGitExtensionsCommand(GitExtensionsMenu, gePull);
  AddGitExtensionsCommand(GitExtensionsMenu, gePush);
  AddGitExtensionsCommand(GitExtensionsMenu, geSynchronize);
  GitExtensionsMenu.Add(CreateSeparator);
  AddGitExtensionsCommand(GitExtensionsMenu, geAdd);
  AddGitExtensionsCommand(GitExtensionsMenu, geAddFiles);
  AddGitExtensionsCommand(GitExtensionsMenu, geDiffTool);
  AddGitExtensionsCommand(GitExtensionsMenu, geViewDiff);
  AddGitExtensionsCommand(GitExtensionsMenu, geFileHistory);
  AddGitExtensionsCommand(GitExtensionsMenu, geBlame);
  AddGitExtensionsCommand(GitExtensionsMenu, geFileEditor);
  GitExtensionsMenu.Add(CreateSeparator);
  AddGitExtensionsCommand(GitExtensionsMenu, geBranch);
  AddGitExtensionsCommand(GitExtensionsMenu, geCheckout);
  AddGitExtensionsCommand(GitExtensionsMenu, geCheckoutBranch);
  AddGitExtensionsCommand(GitExtensionsMenu, geCheckoutRevision);
  AddGitExtensionsCommand(GitExtensionsMenu, geCherryPick);
  AddGitExtensionsCommand(GitExtensionsMenu, geMerge);
  AddGitExtensionsCommand(GitExtensionsMenu, geMergeConflicts);
  AddGitExtensionsCommand(GitExtensionsMenu, geMergeTool);
  AddGitExtensionsCommand(GitExtensionsMenu, geRebase);
  AddGitExtensionsCommand(GitExtensionsMenu, geReset);
  AddGitExtensionsCommand(GitExtensionsMenu, geRevert);
  GitExtensionsMenu.Add(CreateSeparator);
  AddGitExtensionsCommand(GitExtensionsMenu, geStash);
  AddGitExtensionsCommand(GitExtensionsMenu, geTag);
  AddGitExtensionsCommand(GitExtensionsMenu, geRemotes);
  AddGitExtensionsCommand(GitExtensionsMenu, geSearchFile);
  AddGitExtensionsCommand(GitExtensionsMenu, geGitIgnore);
  AddGitExtensionsCommand(GitExtensionsMenu, geCleanup);
  GitExtensionsMenu.Add(CreateSeparator);
  AddGitExtensionsCommand(GitExtensionsMenu, geClone);
  AddGitExtensionsCommand(GitExtensionsMenu, geInit);
  AddGitExtensionsCommand(GitExtensionsMenu, geApply);
  AddGitExtensionsCommand(GitExtensionsMenu, geApplyPatch);
  AddGitExtensionsCommand(GitExtensionsMenu, geFormatPatch);
  AddGitExtensionsCommand(GitExtensionsMenu, geViewPatch);
  GitExtensionsMenu.Add(CreateSeparator);
  AddGitExtensionsCommand(GitExtensionsMenu, geSettings);
  AddGitExtensionsCommand(GitExtensionsMenu, geHelp);
  AddGitExtensionsCommand(GitExtensionsMenu, geAbout);

  ParentMenu.Add(GitExtensionsMenu);
  Result := True;
end;

function TGit4DWizard.AddGitSubMenu(ParentMenu: TMenuItem): TMenuItem;
begin
  Result := TMenuItem.Create(ParentMenu);
  Result.Caption := 'Git';

  AddGitCommand(Result, '&Browse Repository', BrowseRepository);
  AddGitCommand(Result, '&Status', ShowStatus);
  AddGitCommand(Result, '&Commit', Commit);
  AddGitCommand(Result, '&Fetch', Fetch);
  AddGitCommand(Result, '&Pull', Pull);
  AddGitCommand(Result, 'Pu&sh', Push);
  AddGitCommand(Result, 'Stas&h', Stash);
  Result.Add(CreateSeparator);
  AddGitCommand(Result, 'Diff Current File', DiffCurrentFile);
  AddGitCommand(Result, 'File History', FileHistory);
  AddGitCommand(Result, 'Blame Current File', BlameCurrentFile);
  AddGitCommand(Result, 'Stage Current File', StageCurrentFile);
  AddGitCommand(Result, 'Reset Current File Changes', ResetCurrentFile);
  Result.Add(CreateSeparator);
  AddGitCommand(Result, 'Checkout &Branch', CheckoutBranch);
  AddGitCommand(Result, 'Create Bra&nch', CreateBranch);
  AddGitCommand(Result, '&Merge Branch', MergeBranch);
  AddGitCommand(Result, '&Rebase Branch', RebaseBranch);
  AddGitCommand(Result, 'Cherry &Pick', CherryPick);
  Result.Add(CreateSeparator);
  AddGitCommand(Result, '&Apply Patch', ApplyPatch);
  AddGitCommand(Result, '&Format Patch', FormatPatch);
  AddGitCommand(Result, 'Manage Rem&otes', ManageRemotes);
  AddGitCommand(Result, 'Edit .&gitignore', EditGitIgnore);
  AddGitCommand(Result, 'Git &Terminal', OpenTerminal);

  ParentMenu.Add(Result);
end;

procedure TGit4DWizard.InstallEditorLocalMenu;
begin
  if FEditorMenuInstalled or not Git4DSettings.EditorPopupEnabled then
    Exit;

  if FEditorPopupHooks = nil then
    FEditorPopupHooks := TList.Create;

  HookEditorPopups;

  if FEditorPopupHookTimer = nil then
  begin
    FEditorPopupHookTimer := TTimer.Create(nil);
    FEditorPopupHookTimer.Enabled := False;
    FEditorPopupHookTimer.Interval := 3000;
    FEditorPopupHookTimer.OnTimer := EditorPopupHookTimer;
  end;

  FEditorPopupHookTimer.Enabled := True;
  FEditorMenuInstalled := True;
end;

procedure TGit4DWizard.UninstallEditorLocalMenu;
begin
  if (not FEditorMenuInstalled) and (FEditorPopupHookTimer = nil) and (FEditorPopupHooks = nil) then
    Exit;

  FEditorPopupHookTimer.Free;
  FEditorPopupHookTimer := nil;

  if FEditorPopupHooks <> nil then
  begin
    while FEditorPopupHooks.Count > 0 do
    begin
      TObject(FEditorPopupHooks[0]).Free;
      FEditorPopupHooks.Delete(0);
    end;
    FEditorPopupHooks.Free;
    FEditorPopupHooks := nil;
  end;

  FEditorMenuInstalled := False;
end;

procedure TGit4DWizard.InstallMainMenu;
var
  ExistingMenu: TMenuItem;
  Index: Integer;
  MainMenu: TMainMenu;
  ToolsMenu: TMenuItem;
begin
  if FMainMenuInstalled then
    Exit;

  if not Supports(BorlandIDEServices, INTAServices) then
  begin
    ScheduleMainMenuRetry;
    Exit;
  end;

  MainMenu := (BorlandIDEServices as INTAServices).MainMenu;
  if MainMenu = nil then
  begin
    ScheduleMainMenuRetry;
    Exit;
  end;

  ToolsMenu := FindToolsMenu(MainMenu);
  if ToolsMenu = nil then
  begin
    ScheduleMainMenuRetry;
    Exit;
  end;

  if FMainMenuRetryTimer <> nil then
    FMainMenuRetryTimer.Enabled := False;

  ExistingMenu := nil;
  for Index := 0 to ToolsMenu.Count - 1 do
    if SameText(ToolsMenu.Items[Index].Name, G4DMainMenuName) or
      SameText(NormalizedCaption(ToolsMenu.Items[Index].Caption), G4DProductName) then
    begin
      ExistingMenu := ToolsMenu.Items[Index];
      Break;
    end;

  if ExistingMenu <> nil then
  begin
    ToolsMenu.Remove(ExistingMenu);
    ExistingMenu.Free;
  end;

  FMainMenu := TMenuItem.Create(nil);
  FMainMenu.Name := G4DMainMenuName;
  FMainMenu.Caption := '&Git4D';
  FMainMenu.OnClick := MainMenuPopup;

  RebuildMainMenuItems;
  ToolsMenu.Add(FMainMenu);
  FMainMenuInstalled := True;
end;

procedure TGit4DWizard.ScheduleMainMenuRetry;
begin
  if FMainMenuInstalled or (FMainMenuRetryCount >= G4DMainMenuRetryLimit) then
    Exit;

  if FMainMenuRetryTimer = nil then
  begin
    FMainMenuRetryTimer := TTimer.Create(nil);
    FMainMenuRetryTimer.Enabled := False;
    FMainMenuRetryTimer.Interval := 500;
    FMainMenuRetryTimer.OnTimer := MainMenuRetryTimer;
  end;

  FMainMenuRetryTimer.Enabled := True;
end;

procedure TGit4DWizard.MainMenuRetryTimer(Sender: TObject);
begin
  if FMainMenuRetryTimer <> nil then
    FMainMenuRetryTimer.Enabled := False;

  Inc(FMainMenuRetryCount);
  try
    InstallMainMenu;
  except
  end;

  if not FMainMenuInstalled then
    ScheduleMainMenuRetry;
end;

procedure TGit4DWizard.RebuildMainMenuItems;
var
  ExternalMenuAdded: Boolean;
begin
  if FMainMenu = nil then
    Exit;

  FMainMenu.Clear;

  ExternalMenuAdded := AddTortoiseSvnSubMenu(FMainMenu);
  if AddTortoiseGitSubMenu(FMainMenu) then
    ExternalMenuAdded := True;
  if AddGitExtensionsSubMenu(FMainMenu) then
    ExternalMenuAdded := True;
  if ExternalMenuAdded then
    AddSeparator;
  AddGitSubMenu(FMainMenu);

  AddSeparator;
  AddAction('Se&ttings', ShowSettings);
  AddAction('&About', ShowAbout);
end;

function TGit4DWizard.IsGit4DPopupMenu(PopupMenu: TPopupMenu): Boolean;
var
  CaptionText: string;
  Index: Integer;
begin
  Result := False;
  if PopupMenu = nil then
    Exit;

  if SameText(PopupMenu.Name, 'EditorLocalMenu') then
  begin
    Result := True;
    Exit;
  end;

  for Index := 0 to PopupMenu.Items.Count - 1 do
  begin
    CaptionText := NormalizedCaption(PopupMenu.Items[Index].Caption);
    if SameText(CaptionText, 'Smart CodeInsight') or
      SameText(CaptionText, 'Editor Options') or
      SameText(CaptionText, 'Code Preview Window') or
      SameText(CaptionText, 'Open File at Cursor') or
      SameText(CaptionText, 'Close All Other Pages') then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

procedure TGit4DWizard.RemoveGit4DPopupItem(PopupMenu: TPopupMenu);
var
  Index: Integer;
  Item: TMenuItem;
begin
  if PopupMenu = nil then
    Exit;

  for Index := PopupMenu.Items.Count - 1 downto 0 do
  begin
    Item := PopupMenu.Items[Index];
    if SameText(Item.Name, G4DEditorPopupMenuName) or
      SameText(NormalizedCaption(Item.Caption), G4DProductName) then
    begin
      PopupMenu.Items.Remove(Item);
      Item.Free;
    end;
  end;
end;

procedure TGit4DWizard.RebuildEditorPopupMenu(PopupMenu: TPopupMenu);
var
  ExternalMenuAdded: Boolean;
  FoundSmartCodeInsight: Boolean;
  Index: Integer;
  InsertIndex: Integer;
  Item: TMenuItem;
  RootMenu: TMenuItem;
begin
  if PopupMenu = nil then
    Exit;

  RemoveGit4DPopupItem(PopupMenu);
  if not IsGit4DPopupMenu(PopupMenu) then
    Exit;
  if not Git4DSettings.EditorPopupEnabled then
    Exit;

  FoundSmartCodeInsight := False;
  InsertIndex := PopupMenu.Items.Count;
  for Index := 0 to PopupMenu.Items.Count - 1 do
  begin
    Item := PopupMenu.Items[Index];
    if SameText(NormalizedCaption(Item.Caption), 'Smart CodeInsight') then
    begin
      InsertIndex := Index + 1;
      FoundSmartCodeInsight := True;
      Break;
    end;
  end;
  if not FoundSmartCodeInsight then
    InsertIndex := PopupMenu.Items.Count;
  if InsertIndex > PopupMenu.Items.Count then
    InsertIndex := PopupMenu.Items.Count;

  RootMenu := TMenuItem.Create(PopupMenu);
  RootMenu.Name := G4DEditorPopupMenuName;
  RootMenu.Caption := G4DProductName;
  ExternalMenuAdded := AddTortoiseSvnSubMenu(RootMenu);
  if AddTortoiseGitSubMenu(RootMenu) then
    ExternalMenuAdded := True;
  if AddGitExtensionsSubMenu(RootMenu) then
    ExternalMenuAdded := True;
  if ExternalMenuAdded then
    RootMenu.Add(CreateSeparator);
  AddGitSubMenu(RootMenu);

  if RootMenu.Count = 0 then
    RootMenu.Enabled := False;

  PopupMenu.Items.Insert(InsertIndex, RootMenu);
end;

procedure TGit4DWizard.MainMenuPopup(Sender: TObject);
begin
  RebuildMainMenuItems;
end;

function TGit4DWizard.FindToolsMenu(MainMenu: TMainMenu): TMenuItem;
var
  Index: Integer;
  CaptionText: string;
begin
  Result := nil;
  for Index := 0 to MainMenu.Items.Count - 1 do
  begin
    CaptionText := StringReplace(MainMenu.Items[Index].Caption, '&', '', [rfReplaceAll]);
    if SameText(CaptionText, 'Tools') then
    begin
      Result := MainMenu.Items[Index];
      Exit;
    end;
  end;
end;

procedure TGit4DWizard.InstallProjectManagerMenu;
var
  ProjectManager: IOTAProjectManager;
begin
  if FProjectMenuNotifierIndex >= 0 then
    Exit;

  if Supports(BorlandIDEServices, IOTAProjectManager, ProjectManager) then
  begin
    FProjectMenuNotifier := TGit4DProjectMenuNotifier.Create;
    try
      FProjectMenuNotifierIndex := ProjectManager.AddMenuItemCreatorNotifier(FProjectMenuNotifier);
      FProjectMenuUsesLegacyNotifier := False;
    except
      FProjectMenuNotifierIndex := ProjectManager.AddMenuCreatorNotifier(FProjectMenuNotifier);
      FProjectMenuUsesLegacyNotifier := True;
    end;
  end;
end;

function TGit4DWizard.AddTortoiseGitSubMenu(ParentMenu: TMenuItem): Boolean;
var
  TortoiseMenu: TMenuItem;
begin
  Result := False;
  if not Git4DSettings.TortoiseGitEnabled then
    Exit;

  TortoiseMenu := TMenuItem.Create(ParentMenu);
  TortoiseMenu.Caption := 'TortoiseGit';

  AddTortoiseGitCommand(TortoiseMenu, tgPull);
  AddTortoiseGitCommand(TortoiseMenu, tgPush);
  AddTortoiseGitCommand(TortoiseMenu, tgSync);
  AddTortoiseGitCommand(TortoiseMenu, tgCommit);
  AddTortoiseGitCommand(TortoiseMenu, tgFetch);
  AddTortoiseGitCommand(TortoiseMenu, tgDiff);
  AddTortoiseGitCommand(TortoiseMenu, tgPreviousDiff);
  AddTortoiseGitCommand(TortoiseMenu, tgLog);
  AddTortoiseGitCommand(TortoiseMenu, tgReflog);
  AddTortoiseGitCommand(TortoiseMenu, tgBrowseReferences);
  AddTortoiseGitCommand(TortoiseMenu, tgDaemon);
  AddTortoiseGitCommand(TortoiseMenu, tgRevisionGraph);
  AddTortoiseGitCommand(TortoiseMenu, tgRepoBrowser);
  AddTortoiseGitCommand(TortoiseMenu, tgRebase);
  AddTortoiseGitCommand(TortoiseMenu, tgStashSave);
  AddTortoiseGitCommand(TortoiseMenu, tgBisectStart);
  AddTortoiseGitCommand(TortoiseMenu, tgResolve);
  AddTortoiseGitCommand(TortoiseMenu, tgRevert);
  AddTortoiseGitCommand(TortoiseMenu, tgCleanup);
  AddTortoiseGitCommand(TortoiseMenu, tgSwitchCheckout);
  AddTortoiseGitCommand(TortoiseMenu, tgMerge);
  AddTortoiseGitCommand(TortoiseMenu, tgCreateBranch);
  AddTortoiseGitCommand(TortoiseMenu, tgCreateTag);
  AddTortoiseGitCommand(TortoiseMenu, tgExport);
  AddTortoiseGitCommand(TortoiseMenu, tgWorktrees);
  AddTortoiseGitCommand(TortoiseMenu, tgSubmoduleAdd);
  AddTortoiseGitCommand(TortoiseMenu, tgCreatePatchSerial);
  AddTortoiseGitCommand(TortoiseMenu, tgApplyPatchSerial);
  AddTortoiseGitCommand(TortoiseMenu, tgSettings);
  AddTortoiseGitCommand(TortoiseMenu, tgHelp);
  AddTortoiseGitCommand(TortoiseMenu, tgAbout);

  ParentMenu.Add(TortoiseMenu);
  Result := True;
end;

procedure TGit4DWizard.BrowseRepository(Sender: TObject);
begin
  TGit4DGit.RunGitForActiveRepository('log --graph --decorate --oneline --all --date-order -n 120');
end;

procedure TGit4DWizard.ShowStatus(Sender: TObject);
begin
  TGit4DGit.RunGitForActiveRepository('status --short --branch');
end;

procedure TGit4DWizard.Commit(Sender: TObject);
begin
  TGit4DGit.RunGitForActiveRepository('status --short && git add --patch && git commit');
end;

procedure TGit4DWizard.Fetch(Sender: TObject);
begin
  TGit4DGit.RunGitForActiveRepository('fetch --all --prune');
end;

procedure TGit4DWizard.Pull(Sender: TObject);
begin
  TGit4DGit.RunGitForActiveRepository('pull --stat');
end;

procedure TGit4DWizard.Push(Sender: TObject);
begin
  TGit4DGit.RunGitForActiveRepository('push');
end;

procedure TGit4DWizard.Stash(Sender: TObject);
begin
  TGit4DGit.RunGitForActiveRepository('stash --include-untracked');
end;

procedure TGit4DWizard.CheckoutBranch(Sender: TObject);
var
  BranchName: string;
begin
  if InputQuery(G4DProductName, 'Branch to checkout', BranchName) then
    TGit4DGit.RunGitForActiveRepository('checkout ' + BranchName);
end;

procedure TGit4DWizard.CreateBranch(Sender: TObject);
var
  BranchName: string;
begin
  if InputQuery(G4DProductName, 'New branch name', BranchName) then
    TGit4DGit.RunGitForActiveRepository('checkout -b ' + BranchName);
end;

procedure TGit4DWizard.MergeBranch(Sender: TObject);
var
  BranchName: string;
begin
  if InputQuery(G4DProductName, 'Branch to merge', BranchName) then
    TGit4DGit.RunGitForActiveRepository('merge ' + BranchName);
end;

procedure TGit4DWizard.RebaseBranch(Sender: TObject);
var
  BranchName: string;
begin
  if InputQuery(G4DProductName, 'Branch to rebase onto', BranchName) then
    TGit4DGit.RunGitForActiveRepository('rebase ' + BranchName);
end;

procedure TGit4DWizard.CherryPick(Sender: TObject);
var
  CommitHash: string;
begin
  if InputQuery(G4DProductName, 'Commit to cherry-pick', CommitHash) then
    TGit4DGit.RunGitForActiveRepository('cherry-pick ' + CommitHash);
end;

procedure TGit4DWizard.ApplyPatch(Sender: TObject);
begin
  TGit4DGit.RunGitForActiveRepository('am');
end;

procedure TGit4DWizard.FormatPatch(Sender: TObject);
begin
  TGit4DGit.RunGitForActiveRepository('format-patch -1 HEAD');
end;

procedure TGit4DWizard.ManageRemotes(Sender: TObject);
begin
  TGit4DGit.RunGitForActiveRepository('remote -v');
end;

procedure TGit4DWizard.EditGitIgnore(Sender: TObject);
begin
  TGit4DGit.RunGitForActiveRepository('status --ignored --short');
end;

procedure TGit4DWizard.DiffCurrentFile(Sender: TObject);
begin
  TGit4DGit.DiffActiveFile;
end;

procedure TGit4DWizard.FileHistory(Sender: TObject);
begin
  TGit4DGit.FileHistory;
end;

procedure TGit4DWizard.BlameCurrentFile(Sender: TObject);
begin
  TGit4DGit.BlameActiveFile;
end;

procedure TGit4DWizard.StageCurrentFile(Sender: TObject);
begin
  TGit4DGit.StageActiveFile;
end;

procedure TGit4DWizard.ResetCurrentFile(Sender: TObject);
begin
  TGit4DGit.ResetActiveFile;
end;

procedure TGit4DWizard.OpenTerminal(Sender: TObject);
begin
  try
    TGit4DGit.OpenTerminal(DiscoverActiveRepository);
  except
    on E: Exception do
      MessageDlg(E.Message, mtInformation, [mbOK], 0);
  end;
end;

procedure TGit4DWizard.ShowSettings(Sender: TObject);
begin
  OpenGit4DOptions;
end;

procedure TGit4DWizard.ShowAbout(Sender: TObject);
begin
  ShowGit4DAboutDialog;
end;

procedure TGit4DWizard.GitExtensionsCommand(Sender: TObject);
var
  Command: TGitExtensionsCommand;
  CommandOrdinal: Integer;
begin
  try
    if Sender is TMenuItem then
      CommandOrdinal := (Sender as TMenuItem).HelpContext
    else if Sender is TAction then
      CommandOrdinal := (Sender as TAction).HelpContext
    else
      Exit;

    if (CommandOrdinal < Ord(Low(TGitExtensionsCommand))) or
      (CommandOrdinal > Ord(High(TGitExtensionsCommand))) then
      raise Exception.CreateFmt('Invalid Git Extensions command id: %d', [CommandOrdinal]);

    Command := TGitExtensionsCommand(CommandOrdinal);
    if Command in [geAdd, geApply, geBlame, geDiffTool, geFileEditor, geFileHistory, geRevert, geViewPatch] then
      TGit4DGitExtensions.RunForActiveFile(Command)
    else
      TGit4DGitExtensions.RunForActiveRepository(Command);
  except
    on E: Exception do
      MessageDlg(E.Message, mtError, [mbOK], 0);
  end;
end;

procedure TGit4DWizard.TortoiseSvnCommand(Sender: TObject);
var
  Command: TTortoiseSvnCommand;
  CommandOrdinal: Integer;
begin
  try
    if Sender is TMenuItem then
      CommandOrdinal := (Sender as TMenuItem).HelpContext
    else if Sender is TAction then
      CommandOrdinal := (Sender as TAction).HelpContext
    else
      Exit;

    if (CommandOrdinal < Ord(Low(TTortoiseSvnCommand))) or
      (CommandOrdinal > Ord(High(TTortoiseSvnCommand))) then
      raise Exception.CreateFmt('Invalid TortoiseSVN command id: %d', [CommandOrdinal]);

    Command := TTortoiseSvnCommand(CommandOrdinal);
    if Command in [svnDiff, svnPreviousDiff, svnBlame, svnResolved] then
      TGit4DTortoiseSVN.RunForActiveFile(Command)
    else
      TGit4DTortoiseSVN.RunForActiveRepository(Command);
  except
    on E: Exception do
      MessageDlg(E.Message, mtError, [mbOK], 0);
  end;
end;

procedure TGit4DWizard.UpdateEditorAction(Sender: TObject);
begin
  if Sender is TCustomAction then
  begin
    (Sender as TCustomAction).Visible := Git4DSettings.EditorPopupEnabled;
    (Sender as TCustomAction).Enabled := Git4DSettings.EditorPopupEnabled;
  end;
end;

procedure TGit4DWizard.UpdateEditorTortoiseGitAction(Sender: TObject);
begin
  if Sender is TCustomAction then
  begin
    (Sender as TCustomAction).Visible := Git4DSettings.EditorPopupEnabled and
      Git4DSettings.TortoiseGitEnabled;
    (Sender as TCustomAction).Enabled := Git4DSettings.EditorPopupEnabled and
      Git4DSettings.TortoiseGitEnabled;
  end;
end;

procedure TGit4DWizard.TortoiseGitCommand(Sender: TObject);
var
  Command: TTortoiseGitCommand;
  CommandOrdinal: Integer;
begin
  try
    if Sender is TMenuItem then
      CommandOrdinal := (Sender as TMenuItem).HelpContext
    else if Sender is TAction then
      CommandOrdinal := (Sender as TAction).HelpContext
    else
      Exit;

    if (CommandOrdinal < Ord(Low(TTortoiseGitCommand))) or
      (CommandOrdinal > Ord(High(TTortoiseGitCommand))) then
      raise Exception.CreateFmt('Invalid TortoiseGit command id: %d', [CommandOrdinal]);

    Command := TTortoiseGitCommand(CommandOrdinal);
    if Command in [tgDiff, tgPreviousDiff, tgBlame, tgResolve] then
      TGit4DTortoiseGit.RunForActiveFile(Command)
    else
      TGit4DTortoiseGit.RunForActiveRepository(Command);
  except
    on E: Exception do
      MessageDlg(E.Message, mtError, [mbOK], 0);
  end;
end;

end.

