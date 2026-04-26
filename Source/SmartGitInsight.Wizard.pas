unit SmartGitInsight.Wizard;

interface

uses
  System.Classes,
  Vcl.ActnList,
  Vcl.ExtCtrls,
  Vcl.Menus,
  ToolsAPI,
  SmartGitInsight.TortoiseGit;

type
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

  TSmartGitInsightProjectMenuNotifier = class(TNotifierObject, IOTAProjectMenuItemCreatorNotifier)
  public
    procedure AddMenu(const Project: IOTAProject; const IdentList: TStrings;
      const ProjectManagerMenuList: IInterfaceList; IsMultiSelect: Boolean);
  end;

  TSmartGitInsightWizard = class(TNotifierObject, IOTAWizard, IOTAMenuWizard)
  private
    FActionList: TActionList;
    FEditorActionList: TActionList;
    FEditorMenuInstalled: Boolean;
    FMainMenu: TMenuItem;
    FMainMenuInstalled: Boolean;
    FProjectMenuNotifier: IOTAProjectMenuItemCreatorNotifier;
    FProjectMenuNotifierIndex: Integer;
    procedure AddAction(const Caption: string; const Handler: TNotifyEvent; const Shortcut: TShortCut = 0);
    function AddTortoiseGitSubMenu(ParentMenu: TMenuItem): Boolean;
    procedure AddTortoiseGitCommand(Menu: TMenuItem; Command: TTortoiseGitCommand);
    procedure AddSeparator;
    procedure AddSubMenu(const Caption: string; const Items: array of TMenuItem);
    function CreateActionItem(const Caption: string; const Handler: TNotifyEvent; const Shortcut: TShortCut = 0): TMenuItem;
    function CreateSeparator: TMenuItem;
    function FindToolsMenu(MainMenu: TMainMenu): TMenuItem;
    procedure InstallEditorLocalMenu;
    procedure InstallMainMenu;
    procedure InstallProjectManagerMenu;
    procedure MainMenuPopup(Sender: TObject);
    procedure RebuildMainMenuItems;
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
    procedure OpenTerminal(Sender: TObject);
    procedure ShowSettings(Sender: TObject);
    procedure ShowAbout(Sender: TObject);
    procedure DiffCurrentFile(Sender: TObject);
    procedure FileHistory(Sender: TObject);
    procedure BlameCurrentFile(Sender: TObject);
    procedure ResetCurrentFile(Sender: TObject);
    procedure StageCurrentFile(Sender: TObject);
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
  SmartGitInsight.Repository;

const
  SGIEditorMenuCategory = 'SmartGitInsight';
  SGIEditorNativeCategory = 'SmartGitInsight.Native';
  SGIEditorTortoiseCategory = 'SmartGitInsight.TortoiseGit';

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

constructor TSmartGitInsightWizard.Create;
begin
  inherited Create;
  FActionList := TActionList.Create(nil);
  FEditorActionList := TActionList.Create(nil);
  FProjectMenuNotifierIndex := -1;
  InstallMainMenu;
  InstallEditorLocalMenu;
  InstallProjectManagerMenu;
end;

destructor TSmartGitInsightWizard.Destroy;
begin
  if FProjectMenuNotifierIndex >= 0 then
    try
      (BorlandIDEServices as IOTAProjectManager).RemoveMenuItemCreatorNotifier(FProjectMenuNotifierIndex);
    except
    end;
  if (FMainMenu <> nil) and (FMainMenu.Parent <> nil) then
    FMainMenu.Parent.Remove(FMainMenu);
  FMainMenu.Free;
  FEditorActionList.Free;
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

procedure TSmartGitInsightWizard.InstallMainMenu;
var
  MainMenu: TMainMenu;
  ToolsMenu: TMenuItem;
begin
  if FMainMenuInstalled then
    Exit;

  if not Supports(BorlandIDEServices, INTAServices) then
    Exit;

  MainMenu := (BorlandIDEServices as INTAServices).MainMenu;
  if MainMenu = nil then
    Exit;

  ToolsMenu := FindToolsMenu(MainMenu);
  if ToolsMenu = nil then
    Exit;

  FMainMenu := TMenuItem.Create(nil);
  FMainMenu.Caption := '&Smart GitInsight';
  FMainMenu.OnClick := MainMenuPopup;

  RebuildMainMenuItems;
  ToolsMenu.Add(FMainMenu);
  FMainMenuInstalled := True;
end;

procedure TSmartGitInsightWizard.RebuildMainMenuItems;
begin
  if FMainMenu = nil then
    Exit;

  FMainMenu.Clear;
  if AddTortoiseGitSubMenu(FMainMenu) then
    AddSeparator;

  AddAction('&Browse Repository', BrowseRepository);
  AddAction('&Status', ShowStatus);
  AddSeparator;
  AddAction('&Commit', Commit);
  AddAction('&Fetch', Fetch);
  AddAction('&Pull', Pull);
  AddAction('Pu&sh', Push);
  AddAction('Stas&h', Stash);
  AddSeparator;
  AddAction('Checkout &Branch', CheckoutBranch);
  AddAction('Create Bra&nch', CreateBranch);
  AddAction('&Merge Branch', MergeBranch);
  AddAction('&Rebase Branch', RebaseBranch);
  AddAction('Cherry &Pick', CherryPick);
  AddSeparator;
  AddAction('&Apply Patch', ApplyPatch);
  AddAction('&Format Patch', FormatPatch);
  AddAction('Manage Rem&otes', ManageRemotes);
  AddAction('Edit .&gitignore', EditGitIgnore);
  AddSeparator;
  AddAction('Git &Terminal', OpenTerminal);
  AddSeparator;
  AddAction('Se&ttings', ShowSettings);
  AddAction('&About', ShowAbout);
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

procedure TSmartGitInsightWizard.InstallEditorLocalMenu;
var
  Action: TAction;
  EditorLocalMenu: INTAEditorLocalMenu;
  EditorServices: IOTAEditorServices;
begin
  if FEditorMenuInstalled then
    Exit;

  if not Supports(BorlandIDEServices, IOTAEditorServices, EditorServices) then
    Exit;

  EditorLocalMenu := EditorServices.GetEditorLocalMenu;
  if EditorLocalMenu = nil then
    Exit;

  Action := TAction.Create(FEditorActionList);
  Action.ActionList := FEditorActionList;
  Action.Caption := SGIProductName;
  Action.Category := SGIEditorMenuCategory;

  if TSmartGitInsightTortoiseGit.IsEnabledAndAvailable then
  begin
    Action := TAction.Create(FEditorActionList);
    Action.ActionList := FEditorActionList;
    Action.Caption := 'TortoiseGit';
    Action.Category := SGIEditorTortoiseCategory;

    Action := TAction.Create(FEditorActionList);
    Action.ActionList := FEditorActionList;
    Action.Caption := 'Show Log';
    Action.Category := SGIEditorTortoiseCategory + '.Commands';
    Action.Tag := Ord(tgLog);
    Action.OnExecute := TortoiseGitCommand;

    Action := TAction.Create(FEditorActionList);
    Action.ActionList := FEditorActionList;
    Action.Caption := 'Diff';
    Action.Category := SGIEditorTortoiseCategory + '.Commands';
    Action.Tag := Ord(tgDiff);
    Action.OnExecute := TortoiseGitCommand;

    Action := TAction.Create(FEditorActionList);
    Action.ActionList := FEditorActionList;
    Action.Caption := 'Blame';
    Action.Category := SGIEditorTortoiseCategory + '.Commands';
    Action.Tag := Ord(tgBlame);
    Action.OnExecute := TortoiseGitCommand;
  end;

  Action := TAction.Create(FEditorActionList);
  Action.ActionList := FEditorActionList;
  Action.Caption := 'Diff Current File';
  Action.Category := SGIEditorNativeCategory;
  Action.OnExecute := DiffCurrentFile;

  Action := TAction.Create(FEditorActionList);
  Action.ActionList := FEditorActionList;
  Action.Caption := 'File History';
  Action.Category := SGIEditorNativeCategory;
  Action.OnExecute := FileHistory;

  Action := TAction.Create(FEditorActionList);
  Action.ActionList := FEditorActionList;
  Action.Caption := 'Blame Current File';
  Action.Category := SGIEditorNativeCategory;
  Action.OnExecute := BlameCurrentFile;

  Action := TAction.Create(FEditorActionList);
  Action.ActionList := FEditorActionList;
  Action.Caption := 'Stage Current File';
  Action.Category := SGIEditorNativeCategory;
  Action.OnExecute := StageCurrentFile;

  Action := TAction.Create(FEditorActionList);
  Action.ActionList := FEditorActionList;
  Action.Caption := 'Reset Current File Changes';
  Action.Category := SGIEditorNativeCategory;
  Action.OnExecute := ResetCurrentFile;

  EditorLocalMenu.RegisterActionList(FEditorActionList, SGIEditorMenuCategory, cEdMenuCatVersionControl);
  FEditorMenuInstalled := True;
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
    FProjectMenuNotifierIndex := ProjectManager.AddMenuItemCreatorNotifier(FProjectMenuNotifier);
  end;
end;

function TSmartGitInsightWizard.AddTortoiseGitSubMenu(ParentMenu: TMenuItem): Boolean;
var
  TortoiseMenu: TMenuItem;
begin
  Result := False;
  if not TSmartGitInsightTortoiseGit.IsEnabledAndAvailable then
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

procedure TSmartGitInsightWizard.ResetCurrentFile(Sender: TObject);
begin
  TSmartGitInsightGit.ResetActiveFile;
end;

procedure TSmartGitInsightWizard.StageCurrentFile(Sender: TObject);
begin
  TSmartGitInsightGit.StageActiveFile;
end;

procedure TSmartGitInsightWizard.TortoiseGitCommand(Sender: TObject);
var
  Command: TTortoiseGitCommand;
begin
  if Sender is TMenuItem then
    Command := TTortoiseGitCommand((Sender as TMenuItem).Tag)
  else if Sender is TAction then
    Command := TTortoiseGitCommand((Sender as TAction).Tag)
  else
    Exit;
  if Command in [tgDiff, tgPreviousDiff, tgBlame, tgResolve] then
    TSmartGitInsightTortoiseGit.RunForActiveFile(Command)
  else
    TSmartGitInsightTortoiseGit.RunForActiveRepository(Command);
end;

end.
