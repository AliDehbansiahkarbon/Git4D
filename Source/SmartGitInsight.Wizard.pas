unit SmartGitInsight.Wizard;

interface

uses
  System.Classes,
  Vcl.ActnList,
  Vcl.ExtCtrls,
  Vcl.Menus,
  ToolsAPI,
  SmartGitInsight.GitExtensions,
  SmartGitInsight.TortoiseGit;

type
  TSmartGitInsightWizard = class;

  TSmartGitInsightEditorPopupHook = class(TComponent)
  private
    FOldOnPopup: TNotifyEvent;
    FPopupMenu: TPopupMenu;
    FWizard: TSmartGitInsightWizard;
    function IsHooked: Boolean;
    procedure PopupOpening(Sender: TObject);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AWizard: TSmartGitInsightWizard; APopupMenu: TPopupMenu); reintroduce;
    destructor Destroy; override;
    procedure EnsureHooked;
    property PopupMenu: TPopupMenu read FPopupMenu;
  end;

  TSmartGitInsightProjectMenuKind = (
    pmStatus,
    pmCommit,
    pmPull,
    pmPush,
    pmDiff,
    pmHistory
  );

  TSmartGitInsightProjectMenuItem = class(TNotifierObject, IOTAProjectManagerMenu)
  private
    FCaption: string;
    FChecked: Boolean;
    FEnabled: Boolean;
    FHelpContext: Integer;
    FIsMultiSelectable: Boolean;
    FKind: TSmartGitInsightProjectMenuKind;
    FName: string;
    FParent: string;
    FPosition: Integer;
    FVerb: string;
  public
    constructor Create(AKind: TSmartGitInsightProjectMenuKind; const ACaption, AName: string);
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

  TSmartGitInsightProjectMenuNotifier = class(TNotifierObject, IOTAProjectMenuItemCreatorNotifier,
    INTAProjectMenuCreatorNotifier)
  private
    procedure AddProjectCommand(Menu: TMenuItem; AKind: TSmartGitInsightProjectMenuKind; const ACaption: string);
    procedure AddProjectGitExtensionsCommand(Menu: TMenuItem; Command: TGitExtensionsCommand);
    procedure AddProjectSeparator(Menu: TMenuItem);
    procedure AddProjectTortoiseGitCommand(Menu: TMenuItem; Command: TTortoiseGitCommand);
    procedure ProjectCommandClick(Sender: TObject);
    procedure ProjectGitExtensionsClick(Sender: TObject);
    procedure ProjectTortoiseGitClick(Sender: TObject);
  public
    procedure AddMenu(const Project: IOTAProject; const IdentList: TStrings;
      const ProjectManagerMenuList: IInterfaceList; IsMultiSelect: Boolean); overload;
    function AddMenu(const Ident: string): TMenuItem; overload;
    function CanHandle(const Ident: string): Boolean;
  end;

  TSmartGitInsightWizard = class(TNotifierObject, IOTAWizard, IOTAMenuWizard)
  private
    FActionList: TActionList;
    FEditorMenuInstalled: Boolean;
    FEditorPopupHookTimer: TTimer;
    FEditorPopupHooks: TList;
    FMainMenu: TMenuItem;
    FMainMenuInstalled: Boolean;
    FMainMenuRetryCount: Integer;
    FMainMenuRetryTimer: TTimer;
    FProjectMenuNotifier: TSmartGitInsightProjectMenuNotifier;
    FProjectMenuNotifierIndex: Integer;
    FProjectMenuUsesLegacyNotifier: Boolean;
    procedure AddAction(const Caption: string; const Handler: TNotifyEvent; const Shortcut: TShortCut = 0);
    procedure AddGitCommand(Menu: TMenuItem; const Caption: string; const Handler: TNotifyEvent);
    procedure AddGitExtensionsCommand(Menu: TMenuItem; Command: TGitExtensionsCommand);
    function AddGitExtensionsSubMenu(ParentMenu: TMenuItem): Boolean;
    function AddGitSubMenu(ParentMenu: TMenuItem): TMenuItem;
    function AddTortoiseGitSubMenu(ParentMenu: TMenuItem): Boolean;
    procedure AddTortoiseGitCommand(Menu: TMenuItem; Command: TTortoiseGitCommand);
    procedure AddSeparator;
    procedure AddSubMenu(const Caption: string; const Items: array of TMenuItem);
    function CreateActionItem(const Caption: string; const Handler: TNotifyEvent; const Shortcut: TShortCut = 0): TMenuItem;
    function CreateSeparator: TMenuItem;
    procedure EditorPopupHookTimer(Sender: TObject);
    function FindToolsMenu(MainMenu: TMainMenu): TMenuItem;
    procedure ClearLegacyEditorLocalMenuRegistrations;
    procedure HookEditorPopups;
    procedure HookPopupMenu(PopupMenu: TPopupMenu);
    procedure InstallEditorLocalMenu;
    procedure InstallMainMenu;
    procedure InstallProjectManagerMenu;
    function IsSmartGitInsightPopupMenu(PopupMenu: TPopupMenu): Boolean;
    procedure MainMenuRetryTimer(Sender: TObject);
    procedure UninstallEditorLocalMenu;
    procedure MainMenuPopup(Sender: TObject);
    procedure RebuildMainMenuItems;
    procedure RebuildEditorPopupMenu(PopupMenu: TPopupMenu);
    procedure RemoveSmartGitInsightPopupItem(PopupMenu: TPopupMenu);
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
  SmartGitInsight.Constants,
  SmartGitInsight.Dialogs,
  SmartGitInsight.Git,
  SmartGitInsight.Options,
  SmartGitInsight.Repository,
  SmartGitInsight.Settings;

const
  SGILegacyEditorActionListCategory = 'SmartGitInsight';
  SGILegacyEditorActionListCategory2 = 'SmartGitInsight.EditorLocalMenu';
  SGIEditorPopupMenuName = 'SmartGitInsightEditorPopupMenu';
  SGIMainMenuName = 'SmartGitInsightToolsMenu';
  SGIMainMenuRetryLimit = 20;

function NormalizedCaption(const Caption: string): string;
begin
  Result := StringReplace(Caption, '&', '', [rfReplaceAll]);
end;

constructor TSmartGitInsightEditorPopupHook.Create(AWizard: TSmartGitInsightWizard; APopupMenu: TPopupMenu);
begin
  inherited Create(nil);
  FWizard := AWizard;
  FPopupMenu := APopupMenu;
  EnsureHooked;
end;

procedure TSmartGitInsightEditorPopupHook.EnsureHooked;
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

destructor TSmartGitInsightEditorPopupHook.Destroy;
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

procedure TSmartGitInsightEditorPopupHook.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FPopupMenu) then
    FPopupMenu := nil;
end;

function TSmartGitInsightEditorPopupHook.IsHooked: Boolean;
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

procedure TSmartGitInsightEditorPopupHook.PopupOpening(Sender: TObject);
begin
  if (FWizard <> nil) and (Sender is TPopupMenu) then
    FWizard.RemoveSmartGitInsightPopupItem(Sender as TPopupMenu);
  if Assigned(FOldOnPopup) then
    FOldOnPopup(Sender);
  if (FWizard <> nil) and (Sender is TPopupMenu) then
    FWizard.RebuildEditorPopupMenu(Sender as TPopupMenu);
end;

constructor TSmartGitInsightProjectMenuItem.Create(AKind: TSmartGitInsightProjectMenuKind; const ACaption, AName: string);
begin
  inherited Create;
  FKind := AKind;
  FCaption := ACaption;
  FName := AName;
  FEnabled := True;
  FPosition := 1000 + Ord(AKind);
  FVerb := AName;
end;

function TSmartGitInsightProjectMenuItem.GetCaption: string;
begin
  Result := FCaption;
end;

function TSmartGitInsightProjectMenuItem.GetChecked: Boolean;
begin
  Result := FChecked;
end;

function TSmartGitInsightProjectMenuItem.GetEnabled: Boolean;
begin
  Result := FEnabled;
end;

function TSmartGitInsightProjectMenuItem.GetHelpContext: Integer;
begin
  Result := FHelpContext;
end;

function TSmartGitInsightProjectMenuItem.GetName: string;
begin
  Result := FName;
end;

function TSmartGitInsightProjectMenuItem.GetParent: string;
begin
  Result := FParent;
end;

function TSmartGitInsightProjectMenuItem.GetPosition: Integer;
begin
  Result := FPosition;
end;

function TSmartGitInsightProjectMenuItem.GetVerb: string;
begin
  Result := FVerb;
end;

procedure TSmartGitInsightProjectMenuItem.SetCaption(const Value: string);
begin
  FCaption := Value;
end;

procedure TSmartGitInsightProjectMenuItem.SetChecked(Value: Boolean);
begin
  FChecked := Value;
end;

procedure TSmartGitInsightProjectMenuItem.SetEnabled(Value: Boolean);
begin
  FEnabled := Value;
end;

procedure TSmartGitInsightProjectMenuItem.SetHelpContext(Value: Integer);
begin
  FHelpContext := Value;
end;

procedure TSmartGitInsightProjectMenuItem.SetName(const Value: string);
begin
  FName := Value;
end;

procedure TSmartGitInsightProjectMenuItem.SetParent(const Value: string);
begin
  FParent := Value;
end;

procedure TSmartGitInsightProjectMenuItem.SetPosition(Value: Integer);
begin
  FPosition := Value;
end;

procedure TSmartGitInsightProjectMenuItem.SetVerb(const Value: string);
begin
  FVerb := Value;
end;

function TSmartGitInsightProjectMenuItem.GetIsMultiSelectable: Boolean;
begin
  Result := FIsMultiSelectable;
end;

procedure TSmartGitInsightProjectMenuItem.SetIsMultiSelectable(Value: Boolean);
begin
  FIsMultiSelectable := Value;
end;

procedure TSmartGitInsightProjectMenuItem.Execute(const MenuContextList: IInterfaceList);
begin
  case FKind of
    pmStatus:
      TSmartGitInsightGit.RunGitForActiveRepository('status --short --branch');
    pmCommit:
      TSmartGitInsightGit.RunGitForActiveRepository('status --short && git add --patch && git commit');
    pmPull:
      TSmartGitInsightGit.RunGitForActiveRepository('pull --stat');
    pmPush:
      TSmartGitInsightGit.RunGitForActiveRepository('push');
    pmDiff:
      TSmartGitInsightGit.DiffActiveFile;
    pmHistory:
      TSmartGitInsightGit.FileHistory;
  end;
end;

function TSmartGitInsightProjectMenuItem.PreExecute(const MenuContextList: IInterfaceList): Boolean;
begin
  Result := True;
end;

function TSmartGitInsightProjectMenuItem.PostExecute(const MenuContextList: IInterfaceList): Boolean;
begin
  Result := True;
end;

procedure TSmartGitInsightProjectMenuNotifier.AddMenu(const Project: IOTAProject; const IdentList: TStrings;
  const ProjectManagerMenuList: IInterfaceList; IsMultiSelect: Boolean);
begin
  ProjectManagerMenuList.Add(TSmartGitInsightProjectMenuItem.Create(pmStatus,
    SGIProductName + ': Status', 'SmartGitInsightProjectStatus') as IOTAProjectManagerMenu);
  ProjectManagerMenuList.Add(TSmartGitInsightProjectMenuItem.Create(pmCommit,
    SGIProductName + ': Commit', 'SmartGitInsightProjectCommit') as IOTAProjectManagerMenu);
  ProjectManagerMenuList.Add(TSmartGitInsightProjectMenuItem.Create(pmPull,
    SGIProductName + ': Pull', 'SmartGitInsightProjectPull') as IOTAProjectManagerMenu);
  ProjectManagerMenuList.Add(TSmartGitInsightProjectMenuItem.Create(pmPush,
    SGIProductName + ': Push', 'SmartGitInsightProjectPush') as IOTAProjectManagerMenu);
  ProjectManagerMenuList.Add(TSmartGitInsightProjectMenuItem.Create(pmDiff,
    SGIProductName + ': Diff Current File', 'SmartGitInsightProjectDiff') as IOTAProjectManagerMenu);
  ProjectManagerMenuList.Add(TSmartGitInsightProjectMenuItem.Create(pmHistory,
    SGIProductName + ': File History', 'SmartGitInsightProjectHistory') as IOTAProjectManagerMenu);
end;

procedure TSmartGitInsightProjectMenuNotifier.AddProjectCommand(Menu: TMenuItem;
  AKind: TSmartGitInsightProjectMenuKind; const ACaption: string);
var
  Item: TMenuItem;
begin
  Item := TMenuItem.Create(Menu);
  Item.Caption := ACaption;
  Item.Tag := Ord(AKind);
  Item.OnClick := ProjectCommandClick;
  Menu.Add(Item);
end;

procedure TSmartGitInsightProjectMenuNotifier.AddProjectSeparator(Menu: TMenuItem);
var
  Item: TMenuItem;
begin
  Item := TMenuItem.Create(Menu);
  Item.Caption := '-';
  Menu.Add(Item);
end;

procedure TSmartGitInsightProjectMenuNotifier.AddProjectGitExtensionsCommand(Menu: TMenuItem;
  Command: TGitExtensionsCommand);
var
  Item: TMenuItem;
begin
  Item := TMenuItem.Create(Menu);
  Item.Caption := TSmartGitInsightGitExtensions.CommandDisplayName(Command);
  Item.Tag := Ord(Command);
  Item.HelpContext := Ord(Command);
  Item.OnClick := ProjectGitExtensionsClick;
  Menu.Add(Item);
end;

procedure TSmartGitInsightProjectMenuNotifier.AddProjectTortoiseGitCommand(Menu: TMenuItem;
  Command: TTortoiseGitCommand);
var
  Item: TMenuItem;
begin
  Item := TMenuItem.Create(Menu);
  Item.Caption := TSmartGitInsightTortoiseGit.CommandDisplayName(Command);
  Item.Tag := Ord(Command);
  Item.HelpContext := Ord(Command);
  Item.OnClick := ProjectTortoiseGitClick;
  Menu.Add(Item);
end;

function TSmartGitInsightProjectMenuNotifier.AddMenu(const Ident: string): TMenuItem;
var
  ExternalMenuAdded: Boolean;
  GitExtensionsMenu: TMenuItem;
  TortoiseMenu: TMenuItem;
begin
  Result := TMenuItem.Create(nil);
  Result.Caption := SGIProductName;

  ExternalMenuAdded := False;
  if SmartGitInsightSettings.TortoiseGitEnabled then
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

  if SmartGitInsightSettings.GitExtensionsEnabled then
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

function TSmartGitInsightProjectMenuNotifier.CanHandle(const Ident: string): Boolean;
begin
  Result := True;
end;

procedure TSmartGitInsightProjectMenuNotifier.ProjectCommandClick(Sender: TObject);
var
  Kind: TSmartGitInsightProjectMenuKind;
begin
  if not (Sender is TMenuItem) then
    Exit;

  Kind := TSmartGitInsightProjectMenuKind((Sender as TMenuItem).Tag);
  case Kind of
    pmStatus:
      TSmartGitInsightGit.RunGitForActiveRepository('status --short --branch');
    pmCommit:
      TSmartGitInsightGit.RunGitForActiveRepository('status --short && git add --patch && git commit');
    pmPull:
      TSmartGitInsightGit.RunGitForActiveRepository('pull --stat');
    pmPush:
      TSmartGitInsightGit.RunGitForActiveRepository('push');
    pmDiff:
      TSmartGitInsightGit.DiffActiveFile;
    pmHistory:
      TSmartGitInsightGit.FileHistory;
  end;
end;

procedure TSmartGitInsightProjectMenuNotifier.ProjectGitExtensionsClick(Sender: TObject);
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
      TSmartGitInsightGitExtensions.RunForActiveFile(Command)
    else
      TSmartGitInsightGitExtensions.RunForActiveRepository(Command);
  except
    on E: Exception do
      MessageDlg(E.Message, mtError, [mbOK], 0);
  end;
end;

procedure TSmartGitInsightProjectMenuNotifier.ProjectTortoiseGitClick(Sender: TObject);
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
      TSmartGitInsightTortoiseGit.RunForActiveFile(Command)
    else
      TSmartGitInsightTortoiseGit.RunForActiveRepository(Command);
  except
    on E: Exception do
      MessageDlg(E.Message, mtError, [mbOK], 0);
  end;
end;

constructor TSmartGitInsightWizard.Create;
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

destructor TSmartGitInsightWizard.Destroy;
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

procedure TSmartGitInsightWizard.AfterSave;
begin
end;

procedure TSmartGitInsightWizard.BeforeSave;
begin
end;

procedure TSmartGitInsightWizard.Destroyed;
begin
end;

procedure TSmartGitInsightWizard.Modified;
begin
end;

function TSmartGitInsightWizard.GetIDString: string;
begin
  Result := SGIWizardID;
end;

function TSmartGitInsightWizard.GetName: string;
begin
  Result := SGIProductName;
end;

function TSmartGitInsightWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

procedure TSmartGitInsightWizard.Execute;
begin
  BrowseRepository(nil);
end;

function TSmartGitInsightWizard.GetMenuText: string;
begin
  Result := SGIProductName;
end;

function TSmartGitInsightWizard.CreateActionItem(const Caption: string; const Handler: TNotifyEvent;
  const Shortcut: TShortCut): TMenuItem;
begin
  Result := TMenuItem.Create(nil);
  Result.Caption := Caption;
  Result.ShortCut := Shortcut;
  Result.OnClick := Handler;
end;

function TSmartGitInsightWizard.CreateSeparator: TMenuItem;
begin
  Result := TMenuItem.Create(nil);
  Result.Caption := '-';
end;

procedure TSmartGitInsightWizard.EditorPopupHookTimer(Sender: TObject);
begin
  HookEditorPopups;
end;

procedure TSmartGitInsightWizard.ClearLegacyEditorLocalMenuRegistrations;
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
          EditorLocalMenu.UnregisterActionList(SGILegacyEditorActionListCategory);
        except
        end;
        try
          EditorLocalMenu.UnregisterActionList(SGILegacyEditorActionListCategory2);
        except
        end;
      end;
    end;
  except
  end;
end;

procedure TSmartGitInsightWizard.HookEditorPopups;
var
  ComponentIndex: Integer;
  EditWindow: INTAEditWindow;
  Form: TCustomForm;
  PopupMenu: TPopupMenu;
  ServiceIndex: Integer;
  Services: INTAEditorServices;
begin
  if not SmartGitInsightSettings.EditorPopupEnabled then
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
        HookPopupMenu(PopupMenu);
      end;
  end;
end;

procedure TSmartGitInsightWizard.HookPopupMenu(PopupMenu: TPopupMenu);
var
  Index: Integer;
  Hook: TSmartGitInsightEditorPopupHook;
begin
  if PopupMenu = nil then
    Exit;

  if FEditorPopupHooks = nil then
    FEditorPopupHooks := TList.Create;

  for Index := FEditorPopupHooks.Count - 1 downto 0 do
  begin
    Hook := TSmartGitInsightEditorPopupHook(FEditorPopupHooks[Index]);
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

  FEditorPopupHooks.Add(TSmartGitInsightEditorPopupHook.Create(Self, PopupMenu));
end;

procedure TSmartGitInsightWizard.AddAction(const Caption: string; const Handler: TNotifyEvent;
  const Shortcut: TShortCut);
begin
  FMainMenu.Add(CreateActionItem(Caption, Handler, Shortcut));
end;

procedure TSmartGitInsightWizard.AddTortoiseGitCommand(Menu: TMenuItem; Command: TTortoiseGitCommand);
var
  Item: TMenuItem;
begin
  Item := CreateActionItem(TSmartGitInsightTortoiseGit.CommandDisplayName(Command), TortoiseGitCommand);
  Item.Tag := Ord(Command);
  Item.HelpContext := Ord(Command);
  Menu.Add(Item);
end;

procedure TSmartGitInsightWizard.AddGitExtensionsCommand(Menu: TMenuItem; Command: TGitExtensionsCommand);
var
  Item: TMenuItem;
begin
  Item := CreateActionItem(TSmartGitInsightGitExtensions.CommandDisplayName(Command), GitExtensionsCommand);
  Item.Tag := Ord(Command);
  Item.HelpContext := Ord(Command);
  Menu.Add(Item);
end;

procedure TSmartGitInsightWizard.AddSeparator;
begin
  FMainMenu.Add(CreateSeparator);
end;

procedure TSmartGitInsightWizard.AddSubMenu(const Caption: string; const Items: array of TMenuItem);
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

procedure TSmartGitInsightWizard.AddGitCommand(Menu: TMenuItem; const Caption: string; const Handler: TNotifyEvent);
begin
  Menu.Add(CreateActionItem(Caption, Handler));
end;

function TSmartGitInsightWizard.AddGitExtensionsSubMenu(ParentMenu: TMenuItem): Boolean;
var
  GitExtensionsMenu: TMenuItem;
begin
  Result := False;
  if not SmartGitInsightSettings.GitExtensionsEnabled then
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

function TSmartGitInsightWizard.AddGitSubMenu(ParentMenu: TMenuItem): TMenuItem;
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

procedure TSmartGitInsightWizard.InstallEditorLocalMenu;
begin
  if FEditorMenuInstalled or not SmartGitInsightSettings.EditorPopupEnabled then
    Exit;

  if FEditorPopupHooks = nil then
    FEditorPopupHooks := TList.Create;

  HookEditorPopups;

  if FEditorPopupHookTimer = nil then
  begin
    FEditorPopupHookTimer := TTimer.Create(nil);
    FEditorPopupHookTimer.Enabled := False;
    FEditorPopupHookTimer.Interval := 1000;
    FEditorPopupHookTimer.OnTimer := EditorPopupHookTimer;
  end;

  FEditorPopupHookTimer.Enabled := True;
  FEditorMenuInstalled := True;
end;

procedure TSmartGitInsightWizard.UninstallEditorLocalMenu;
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

procedure TSmartGitInsightWizard.InstallMainMenu;
var
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

  FMainMenu := TMenuItem.Create(nil);
  FMainMenu.Name := SGIMainMenuName;
  FMainMenu.Caption := '&Smart GitInsight';
  FMainMenu.OnClick := MainMenuPopup;

  RebuildMainMenuItems;
  ToolsMenu.Add(FMainMenu);
  FMainMenuInstalled := True;
end;

procedure TSmartGitInsightWizard.ScheduleMainMenuRetry;
begin
  if FMainMenuInstalled or (FMainMenuRetryCount >= SGIMainMenuRetryLimit) then
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

procedure TSmartGitInsightWizard.MainMenuRetryTimer(Sender: TObject);
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

procedure TSmartGitInsightWizard.RebuildMainMenuItems;
var
  ExternalMenuAdded: Boolean;
begin
  if FMainMenu = nil then
    Exit;

  FMainMenu.Clear;

  ExternalMenuAdded := AddTortoiseGitSubMenu(FMainMenu);
  if AddGitExtensionsSubMenu(FMainMenu) then
    ExternalMenuAdded := True;
  if ExternalMenuAdded then
    AddSeparator;
  AddGitSubMenu(FMainMenu);

  AddSeparator;
  AddAction('Se&ttings', ShowSettings);
  AddAction('&About', ShowAbout);
end;

function TSmartGitInsightWizard.IsSmartGitInsightPopupMenu(PopupMenu: TPopupMenu): Boolean;
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

procedure TSmartGitInsightWizard.RemoveSmartGitInsightPopupItem(PopupMenu: TPopupMenu);
var
  Index: Integer;
  Item: TMenuItem;
begin
  if PopupMenu = nil then
    Exit;

  for Index := PopupMenu.Items.Count - 1 downto 0 do
  begin
    Item := PopupMenu.Items[Index];
    if SameText(Item.Name, SGIEditorPopupMenuName) or
      SameText(NormalizedCaption(Item.Caption), SGIProductName) then
    begin
      PopupMenu.Items.Remove(Item);
      Item.Free;
    end;
  end;
end;

procedure TSmartGitInsightWizard.RebuildEditorPopupMenu(PopupMenu: TPopupMenu);
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

  RemoveSmartGitInsightPopupItem(PopupMenu);
  if not IsSmartGitInsightPopupMenu(PopupMenu) then
    Exit;
  if not SmartGitInsightSettings.EditorPopupEnabled then
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
  RootMenu.Name := SGIEditorPopupMenuName;
  RootMenu.Caption := SGIProductName;
  ExternalMenuAdded := AddTortoiseGitSubMenu(RootMenu);
  if AddGitExtensionsSubMenu(RootMenu) then
    ExternalMenuAdded := True;
  if ExternalMenuAdded then
    RootMenu.Add(CreateSeparator);
  AddGitSubMenu(RootMenu);

  if RootMenu.Count = 0 then
    RootMenu.Enabled := False;

  PopupMenu.Items.Insert(InsertIndex, RootMenu);
end;

procedure TSmartGitInsightWizard.MainMenuPopup(Sender: TObject);
begin
  RebuildMainMenuItems;
end;

function TSmartGitInsightWizard.FindToolsMenu(MainMenu: TMainMenu): TMenuItem;
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

procedure TSmartGitInsightWizard.InstallProjectManagerMenu;
var
  ProjectManager: IOTAProjectManager;
begin
  if FProjectMenuNotifierIndex >= 0 then
    Exit;

  if Supports(BorlandIDEServices, IOTAProjectManager, ProjectManager) then
  begin
    FProjectMenuNotifier := TSmartGitInsightProjectMenuNotifier.Create;
    FProjectMenuNotifierIndex := ProjectManager.AddMenuCreatorNotifier(FProjectMenuNotifier);
    FProjectMenuUsesLegacyNotifier := True;
  end;
end;

function TSmartGitInsightWizard.AddTortoiseGitSubMenu(ParentMenu: TMenuItem): Boolean;
var
  TortoiseMenu: TMenuItem;
begin
  Result := False;
  if not SmartGitInsightSettings.TortoiseGitEnabled then
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

procedure TSmartGitInsightWizard.BrowseRepository(Sender: TObject);
begin
  TSmartGitInsightGit.RunGitForActiveRepository('log --graph --decorate --oneline --all --date-order -n 120');
end;

procedure TSmartGitInsightWizard.ShowStatus(Sender: TObject);
begin
  TSmartGitInsightGit.RunGitForActiveRepository('status --short --branch');
end;

procedure TSmartGitInsightWizard.Commit(Sender: TObject);
begin
  TSmartGitInsightGit.RunGitForActiveRepository('status --short && git add --patch && git commit');
end;

procedure TSmartGitInsightWizard.Fetch(Sender: TObject);
begin
  TSmartGitInsightGit.RunGitForActiveRepository('fetch --all --prune');
end;

procedure TSmartGitInsightWizard.Pull(Sender: TObject);
begin
  TSmartGitInsightGit.RunGitForActiveRepository('pull --stat');
end;

procedure TSmartGitInsightWizard.Push(Sender: TObject);
begin
  TSmartGitInsightGit.RunGitForActiveRepository('push');
end;

procedure TSmartGitInsightWizard.Stash(Sender: TObject);
begin
  TSmartGitInsightGit.RunGitForActiveRepository('stash --include-untracked');
end;

procedure TSmartGitInsightWizard.CheckoutBranch(Sender: TObject);
var
  BranchName: string;
begin
  if InputQuery(SGIProductName, 'Branch to checkout', BranchName) then
    TSmartGitInsightGit.RunGitForActiveRepository('checkout ' + BranchName);
end;

procedure TSmartGitInsightWizard.CreateBranch(Sender: TObject);
var
  BranchName: string;
begin
  if InputQuery(SGIProductName, 'New branch name', BranchName) then
    TSmartGitInsightGit.RunGitForActiveRepository('checkout -b ' + BranchName);
end;

procedure TSmartGitInsightWizard.MergeBranch(Sender: TObject);
var
  BranchName: string;
begin
  if InputQuery(SGIProductName, 'Branch to merge', BranchName) then
    TSmartGitInsightGit.RunGitForActiveRepository('merge ' + BranchName);
end;

procedure TSmartGitInsightWizard.RebaseBranch(Sender: TObject);
var
  BranchName: string;
begin
  if InputQuery(SGIProductName, 'Branch to rebase onto', BranchName) then
    TSmartGitInsightGit.RunGitForActiveRepository('rebase ' + BranchName);
end;

procedure TSmartGitInsightWizard.CherryPick(Sender: TObject);
var
  CommitHash: string;
begin
  if InputQuery(SGIProductName, 'Commit to cherry-pick', CommitHash) then
    TSmartGitInsightGit.RunGitForActiveRepository('cherry-pick ' + CommitHash);
end;

procedure TSmartGitInsightWizard.ApplyPatch(Sender: TObject);
begin
  TSmartGitInsightGit.RunGitForActiveRepository('am');
end;

procedure TSmartGitInsightWizard.FormatPatch(Sender: TObject);
begin
  TSmartGitInsightGit.RunGitForActiveRepository('format-patch -1 HEAD');
end;

procedure TSmartGitInsightWizard.ManageRemotes(Sender: TObject);
begin
  TSmartGitInsightGit.RunGitForActiveRepository('remote -v');
end;

procedure TSmartGitInsightWizard.EditGitIgnore(Sender: TObject);
begin
  TSmartGitInsightGit.RunGitForActiveRepository('status --ignored --short');
end;

procedure TSmartGitInsightWizard.DiffCurrentFile(Sender: TObject);
begin
  TSmartGitInsightGit.DiffActiveFile;
end;

procedure TSmartGitInsightWizard.FileHistory(Sender: TObject);
begin
  TSmartGitInsightGit.FileHistory;
end;

procedure TSmartGitInsightWizard.BlameCurrentFile(Sender: TObject);
begin
  TSmartGitInsightGit.BlameActiveFile;
end;

procedure TSmartGitInsightWizard.StageCurrentFile(Sender: TObject);
begin
  TSmartGitInsightGit.StageActiveFile;
end;

procedure TSmartGitInsightWizard.ResetCurrentFile(Sender: TObject);
begin
  TSmartGitInsightGit.ResetActiveFile;
end;

procedure TSmartGitInsightWizard.OpenTerminal(Sender: TObject);
begin
  try
    TSmartGitInsightGit.OpenTerminal(DiscoverActiveRepository);
  except
    on E: Exception do
      MessageDlg(E.Message, mtInformation, [mbOK], 0);
  end;
end;

procedure TSmartGitInsightWizard.ShowSettings(Sender: TObject);
begin
  OpenSmartGitInsightOptions;
end;

procedure TSmartGitInsightWizard.ShowAbout(Sender: TObject);
begin
  ShowSmartGitInsightAboutDialog;
end;

procedure TSmartGitInsightWizard.GitExtensionsCommand(Sender: TObject);
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
      TSmartGitInsightGitExtensions.RunForActiveFile(Command)
    else
      TSmartGitInsightGitExtensions.RunForActiveRepository(Command);
  except
    on E: Exception do
      MessageDlg(E.Message, mtError, [mbOK], 0);
  end;
end;

procedure TSmartGitInsightWizard.UpdateEditorAction(Sender: TObject);
begin
  if Sender is TCustomAction then
  begin
    (Sender as TCustomAction).Visible := SmartGitInsightSettings.EditorPopupEnabled;
    (Sender as TCustomAction).Enabled := SmartGitInsightSettings.EditorPopupEnabled;
  end;
end;

procedure TSmartGitInsightWizard.UpdateEditorTortoiseGitAction(Sender: TObject);
begin
  if Sender is TCustomAction then
  begin
    (Sender as TCustomAction).Visible := SmartGitInsightSettings.EditorPopupEnabled and
      SmartGitInsightSettings.TortoiseGitEnabled;
    (Sender as TCustomAction).Enabled := SmartGitInsightSettings.EditorPopupEnabled and
      SmartGitInsightSettings.TortoiseGitEnabled;
  end;
end;

procedure TSmartGitInsightWizard.TortoiseGitCommand(Sender: TObject);
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
      TSmartGitInsightTortoiseGit.RunForActiveFile(Command)
    else
      TSmartGitInsightTortoiseGit.RunForActiveRepository(Command);
  except
    on E: Exception do
      MessageDlg(E.Message, mtError, [mbOK], 0);
  end;
end;

end.
