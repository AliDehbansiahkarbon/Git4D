unit Git4D.Wizard;
{$WARN SYMBOL_DEPRECATED OFF}
interface

uses
  System.Classes,
  System.StrUtils,
  Vcl.ActnList,
  Vcl.Controls,
  Vcl.ExtCtrls,
  Vcl.Graphics,
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
    pmRoot,
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
    FProjectMenuLegacyNotifierIndex: Integer;
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
    procedure ShowWorkbench(Sender: TObject);
    procedure ShowSettings(Sender: TObject);
    procedure ShowAbout(Sender: TObject);
    procedure GitExtensionsCommand(Sender: TObject);
    procedure TortoiseSvnCommand(Sender: TObject);
    procedure ScheduleMainMenuRetry;
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
  Vcl.Imaging.pngimage,
  Vcl.Dialogs,
  Vcl.Forms,
  Winapi.Windows,
  Git4D.Constants,
  Git4D.Dialogs,
  Git4D.Git,
  Git4D.Options,
  Git4D.Repository,
  Git4D.Settings,
  Git4D.Workbench;

const
  G4DLegacyEditorActionListCategory = 'Git4D';
  G4DLegacyEditorActionListCategory2 = 'Git4D.EditorLocalMenu';
  G4DEditorPopupMenuName = 'Git4DEditorPopupMenu';
  G4DMainMenuName = 'Git4DToolsMenu';
  G4DMainMenuRetryLimit = 20;
  G4DMenuIconColor = $00F5F5F5;

type
  TGit4DMenuIconKey = (
    mikNone,
    mikFolderOpen,
    mikCommit,
    mikPull,
    mikPush,
    mikSync,
    mikAdd,
    mikDiff,
    mikHistory,
    mikBranch,
    mikCheckout,
    mikMerge,
    mikRebase,
    mikRestore,
    mikSettings,
    mikHelp,
    mikInfo
  );

var
  GMenuIconIndexes: array[TGit4DMenuIconKey] of Integer;
  GMenuImages: Vcl.Controls.TImageList;

{$R '..\resources\Git4DMenuIcons.res'}

function NormalizedCaption(const Caption: string): string;
begin
  Result := StringReplace(Caption, '&', '', [rfReplaceAll]);
end;

function IsProjectManagerContainerIdent(const Ident: string): Boolean;
begin
  Result := SameText(Ident, sBaseContainer) or
    SameText(Ident, sFileContainer) or
    SameText(Ident, sProjectContainer) or
    SameText(Ident, sProjectGroupContainer) or
    SameText(Ident, sCategoryContainer) or
    SameText(Ident, sDirectoryContainer) or
    SameText(Ident, sReferencesContainer) or
    SameText(Ident, sContainsContainer) or
    SameText(Ident, sRequiresContainer) or
    SameText(Ident, sVirtualFoldContainer) or
    SameText(Ident, sBuildConfigContainer) or
    SameText(Ident, sOptionSetContainer) or
    SameText(Ident, sTargetPlatformContainer);
end;

function IsProjectManagerSelectionSupported(const IdentList: TStrings): Boolean;
var
  LIdent: string;
  LIndex: Integer;
begin
  Result := False;
  if IdentList = nil then
    Exit;

  for LIndex := 0 to IdentList.Count - 1 do
  begin
    LIdent := IdentList[LIndex];
    if IsProjectManagerContainerIdent(LIdent) or FileExists(LIdent) or DirectoryExists(LIdent) then
      Exit(True);
  end;
end;

function ResolveProjectMenuRepository(const MenuContextList: IInterfaceList): TGit4DRepository;
var
  LDirectoryRepository: TGit4DRepository;
  LContext: IOTAMenuContext;
  LIndex: Integer;
  LMenuItemContext: IOTAProjectMenuContext;
  LSelectedIdent: string;
begin
  Result := Default(TGit4DRepository);

  if MenuContextList <> nil then
    for LIndex := 0 to MenuContextList.Count - 1 do
    begin
      if Supports(MenuContextList[LIndex], IOTAMenuContext, LContext) then
      begin
        LSelectedIdent := LContext.Ident;
        if FileExists(LSelectedIdent) or DirectoryExists(LSelectedIdent) then
        begin
          Result := DiscoverRepository(LSelectedIdent);
          if DirectoryExists(LSelectedIdent) then
            Result.ActiveFileName := '';
          Exit;
        end;
      end;

      if Supports(MenuContextList[LIndex], IOTAProjectMenuContext, LMenuItemContext) and
        (LMenuItemContext.Project <> nil) and (LMenuItemContext.Project.FileName <> '') then
      begin
        LDirectoryRepository := DiscoverRepository(LMenuItemContext.Project.FileName);
        LDirectoryRepository.ProjectFileName := LMenuItemContext.Project.FileName;
        Exit(LDirectoryRepository);
      end;
    end;
end;

function MenuIconResourceName(AKey: TGit4DMenuIconKey): string;
begin
  case AKey of
    mikFolderOpen: Result := 'ICON_FOLDER_OPEN';
    mikCommit: Result := 'ICON_COMMIT';
    mikPull: Result := 'ICON_PULL';
    mikPush: Result := 'ICON_PUSH';
    mikSync: Result := 'ICON_SYNC';
    mikAdd: Result := 'ICON_ADD';
    mikDiff: Result := 'ICON_DIFF';
    mikHistory: Result := 'ICON_HISTORY';
    mikBranch: Result := 'ICON_BRANCH';
    mikCheckout: Result := 'ICON_CHECKOUT';
    mikMerge: Result := 'ICON_MERGE';
    mikRebase: Result := 'ICON_REBASE';
    mikRestore: Result := 'ICON_RESTORE';
    mikSettings: Result := 'ICON_SETTINGS';
    mikHelp: Result := 'ICON_HELP';
    mikInfo: Result := 'ICON_INFO';
  else
    Result := '';
  end;
end;

procedure TintBitmapForDarkMenu(Bitmap: Vcl.Graphics.TBitmap);
var
  LColorValue: TColor;
  LX: Integer;
  LY: Integer;
begin
  if Bitmap = nil then
    Exit;

  Bitmap.PixelFormat := pf32bit;
  for LY := 0 to Bitmap.Height - 1 do
    for LX := 0 to Bitmap.Width - 1 do
    begin
      LColorValue := Bitmap.Canvas.Pixels[LX, LY];
      if (LColorValue <> Bitmap.TransparentColor) and
        (GetRValue(ColorToRGB(LColorValue)) < 80) and
        (GetGValue(ColorToRGB(LColorValue)) < 80) and
        (GetBValue(ColorToRGB(LColorValue)) < 80) then
        Bitmap.Canvas.Pixels[LX, LY] := TColor(G4DMenuIconColor);
    end;
end;

function CreateBitmapFromPngResource(const ResourceName: string): Vcl.Graphics.TBitmap;
var
  LBitmap: Vcl.Graphics.TBitmap;
  LPng: TPngImage;
  LStream: TResourceStream;
begin
  Result := nil;
  if ResourceName = '' then
    Exit;

  LStream := TResourceStream.Create(HInstance, ResourceName, RT_RCDATA);
  try
    LPng := TPngImage.Create;
    try
      LPng.LoadFromStream(LStream);
      LBitmap := Vcl.Graphics.TBitmap.Create;
      try
        LBitmap.SetSize(LPng.Width, LPng.Height);
        LBitmap.Transparent := True;
        LBitmap.Canvas.Brush.Color := clFuchsia;
        LBitmap.Canvas.FillRect(Rect(0, 0, LBitmap.Width, LBitmap.Height));
        LBitmap.TransparentColor := clFuchsia;
        LBitmap.Canvas.Draw(0, 0, LPng);
        TintBitmapForDarkMenu(LBitmap);
        Result := LBitmap;
        LBitmap := nil;
      finally
        LBitmap.Free;
      end;
    finally
      LPng.Free;
    end;
  finally
    LStream.Free;
  end;
end;

function GetMenuImages: Vcl.Controls.TImageList;
begin
  if GMenuImages = nil then
  begin
    GMenuImages := Vcl.Controls.TImageList.Create(nil);
    GMenuImages.Width := GetSystemMetrics(SM_CXSMICON);
    GMenuImages.Height := GetSystemMetrics(SM_CYSMICON);
  end;
  Result := GMenuImages;
end;

function GetMenuIconIndex(AKey: TGit4DMenuIconKey): Integer;
var
  LBitmap: Vcl.Graphics.TBitmap;
begin
  Result := GMenuIconIndexes[AKey];
  if (AKey = mikNone) or (Result >= 0) then
    Exit;

  LBitmap := CreateBitmapFromPngResource(MenuIconResourceName(AKey));
  try
    if LBitmap <> nil then
      GMenuIconIndexes[AKey] := GetMenuImages.AddMasked(LBitmap, clFuchsia);
  finally
    LBitmap.Free;
  end;
  Result := GMenuIconIndexes[AKey];
end;

function GitExtensionsIconKey(Command: TGitExtensionsCommand): TGit4DMenuIconKey;
begin
  case Command of
    geBrowse, geOpenRepo, geClone, geInit:
      Result := mikFolderOpen;
    geCommit:
      Result := mikCommit;
    gePull:
      Result := mikPull;
    gePush:
      Result := mikPush;
    geSynchronize, geCleanup, geMergeConflicts:
      Result := mikSync;
    geAdd, geAddFiles:
      Result := mikAdd;
    geApply, geApplyPatch, geDiffTool, geViewDiff, geViewPatch, geMergeTool, geGitIgnore:
      Result := mikDiff;
    geFileHistory, geSearchFile:
      Result := mikHistory;
    geBlame, geAbout:
      Result := mikInfo;
    geBranch, geTag, geRemotes:
      Result := mikBranch;
    geCheckout, geCheckoutBranch, geCheckoutRevision:
      Result := mikCheckout;
    geCherryPick, geMerge:
      Result := mikMerge;
    geRebase, geStash:
      Result := mikRebase;
    geReset, geRevert:
      Result := mikRestore;
    geSettings:
      Result := mikSettings;
    geHelp:
      Result := mikHelp;
    geFileEditor:
      Result := mikCommit;
  else
    Result := mikNone;
  end;
end;

function TortoiseGitIconKey(Command: TTortoiseGitCommand): TGit4DMenuIconKey;
begin
  case Command of
    tgFetch, tgPull:
      Result := mikPull;
    tgPush:
      Result := mikPush;
    tgSync, tgCleanup, tgResolve:
      Result := mikSync;
    tgCommit:
      Result := mikCommit;
    tgDiff, tgPreviousDiff:
      Result := mikDiff;
    tgLog, tgReflog:
      Result := mikHistory;
    tgBlame, tgAbout:
      Result := mikInfo;
    tgBrowseReferences, tgRevisionGraph, tgCreateBranch, tgCreateTag:
      Result := mikBranch;
    tgRepoBrowser, tgExport, tgWorktrees:
      Result := mikFolderOpen;
    tgRebase, tgBisectStart, tgStashSave:
      Result := mikRebase;
    tgRevert:
      Result := mikRestore;
    tgSwitchCheckout:
      Result := mikCheckout;
    tgMerge, tgCreatePatchSerial, tgApplyPatchSerial, tgSubmoduleAdd:
      Result := mikMerge;
    tgSettings:
      Result := mikSettings;
    tgHelp:
      Result := mikHelp;
  else
    Result := mikNone;
  end;
end;

function TortoiseSvnIconKey(Command: TTortoiseSvnCommand): TGit4DMenuIconKey;
begin
  case Command of
    svnUpdate:
      Result := mikPull;
    svnCommit:
      Result := mikCommit;
    svnDiff, svnPreviousDiff:
      Result := mikDiff;
    svnLog, svnRevisionGraph:
      Result := mikHistory;
    svnBlame, svnAbout:
      Result := mikInfo;
    svnRepoBrowser, svnExport:
      Result := mikFolderOpen;
    svnCheckForModifications, svnCleanup, svnResolved:
      Result := mikSync;
    svnAdd:
      Result := mikAdd;
    svnRevert:
      Result := mikRestore;
    svnSwitch, svnCheckout:
      Result := mikCheckout;
    svnMerge:
      Result := mikMerge;
    svnBranchTag:
      Result := mikBranch;
    svnSettings:
      Result := mikSettings;
    svnHelp:
      Result := mikHelp;
  else
    Result := mikNone;
  end;
end;

function InternalGitIconKey(const Caption: string): TGit4DMenuIconKey;
var
  LNormalized: string;
begin
  LNormalized := NormalizedCaption(Caption);
  if SameText(LNormalized, 'Browse Repository') or SameText(LNormalized, 'Open Repository') then
    Exit(mikFolderOpen);
  if SameText(LNormalized, 'Commit') then
    Exit(mikCommit);
  if SameText(LNormalized, 'Pull') or SameText(LNormalized, 'Fetch') then
    Exit(mikPull);
  if SameText(LNormalized, 'Push') then
    Exit(mikPush);
  if SameText(LNormalized, 'Stash') then
    Exit(mikRebase);
  if (Pos('Diff', LNormalized) > 0) or SameText(LNormalized, 'Edit .gitignore') or
    SameText(LNormalized, 'Apply Patch') or SameText(LNormalized, 'Format Patch') then
    Exit(mikDiff);
  if Pos('History', LNormalized) > 0 then
    Exit(mikHistory);
  if Pos('Blame', LNormalized) > 0 then
    Exit(mikInfo);
  if Pos('Stage', LNormalized) > 0 then
    Exit(mikAdd);
  if Pos('Reset', LNormalized) > 0 then
    Exit(mikRestore);
  if (Pos('Branch', LNormalized) > 0) or SameText(LNormalized, 'Manage Remotes') then
    Exit(mikBranch);
  if Pos('Checkout', LNormalized) > 0 then
    Exit(mikCheckout);
  if Pos('Merge', LNormalized) > 0 then
    Exit(mikMerge);
  if Pos('Rebase', LNormalized) > 0 then
    Exit(mikRebase);
  if SameText(LNormalized, 'Settings') then
    Exit(mikSettings);
  if SameText(LNormalized, 'Help') then
    Exit(mikHelp);
  if SameText(LNormalized, 'About') then
    Exit(mikInfo);
  Result := mikNone;
end;

function ProjectMenuKindIconKey(AKind: TGit4DProjectMenuKind): TGit4DMenuIconKey;
begin
  case AKind of
    pmStatus:
      Result := mikDiff;
    pmCommit:
      Result := mikCommit;
    pmPull:
      Result := mikPull;
    pmPush:
      Result := mikPush;
    pmDiff:
      Result := mikDiff;
    pmHistory:
      Result := mikHistory;
  else
    Result := mikNone;
  end;
end;

procedure ApplyMenuIcon(Item: TMenuItem; AKey: TGit4DMenuIconKey);
var
  LImageIndex: Integer;
begin
  if Item = nil then
    Exit;

  LImageIndex := GetMenuIconIndex(AKey);
  if LImageIndex >= 0 then
    Item.ImageIndex := LImageIndex;
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
  LCurrentMethod: TMethod;
  LHookEvent: TNotifyEvent;
  LHookMethod: TMethod;
begin
  Result := False;
  if FPopupMenu = nil then
    Exit;

  LCurrentMethod := TMethod(FPopupMenu.OnPopup);
  LHookEvent := PopupOpening;
  LHookMethod := TMethod(LHookEvent);
  Result := (LCurrentMethod.Code = LHookMethod.Code) and (LCurrentMethod.Data = LHookMethod.Data);
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
var
  LRepository: TGit4DRepository;
begin
  if FKind = pmRoot then
    Exit;

  try
    LRepository := ResolveProjectMenuRepository(MenuContextList);
    case FKind of
      pmStatus:
        TGit4DGit.RunGitConsole(LRepository, 'status --short --branch');
      pmCommit:
        TGit4DGit.RunGitConsole(LRepository, 'status --short && git add --patch && git commit');
      pmPull:
        TGit4DGit.RunGitConsole(LRepository, 'pull --stat');
      pmPush:
        TGit4DGit.RunGitConsole(LRepository, 'push');
      pmDiff:
        TGit4DGit.RunGitForFile(LRepository, 'diff');
      pmHistory:
        TGit4DGit.RunGitForFile(LRepository, 'log --follow --stat');
    end;
  except
    on E: Exception do
      MessageDlg(E.Message, mtInformation, [mbOK], 0);
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
const
  cGit4DProjectRootName = 'Git4DProjectRoot';
var
  LCommitMenu: TGit4DProjectMenuItem;
  LDiffMenu: TGit4DProjectMenuItem;
  LHistoryMenu: TGit4DProjectMenuItem;
  LPullMenu: TGit4DProjectMenuItem;
  LPushMenu: TGit4DProjectMenuItem;
  LRootMenu: TGit4DProjectMenuItem;
  LStatusMenu: TGit4DProjectMenuItem;
begin
  if not IsProjectManagerSelectionSupported(IdentList) then
    Exit;

  LRootMenu := TGit4DProjectMenuItem.Create(pmRoot, cG4DProductName, cGit4DProjectRootName);
  LRootMenu.SetPosition(1000);
  ProjectManagerMenuList.Add(LRootMenu as IOTAProjectManagerMenu);

  LStatusMenu := TGit4DProjectMenuItem.Create(pmStatus,
    cG4DProductName + ': Status', 'Git4DProjectStatus');
  LStatusMenu.SetParent(cGit4DProjectRootName);
  ProjectManagerMenuList.Add(LStatusMenu as IOTAProjectManagerMenu);

  LCommitMenu := TGit4DProjectMenuItem.Create(pmCommit,
    cG4DProductName + ': Commit', 'Git4DProjectCommit');
  LCommitMenu.SetParent(cGit4DProjectRootName);
  ProjectManagerMenuList.Add(LCommitMenu as IOTAProjectManagerMenu);

  LPullMenu := TGit4DProjectMenuItem.Create(pmPull,
    cG4DProductName + ': Pull', 'Git4DProjectPull');
  LPullMenu.SetParent(cGit4DProjectRootName);
  ProjectManagerMenuList.Add(LPullMenu as IOTAProjectManagerMenu);

  LPushMenu := TGit4DProjectMenuItem.Create(pmPush,
    cG4DProductName + ': Push', 'Git4DProjectPush');
  LPushMenu.SetParent(cGit4DProjectRootName);
  ProjectManagerMenuList.Add(LPushMenu as IOTAProjectManagerMenu);

  LDiffMenu := TGit4DProjectMenuItem.Create(pmDiff,
    cG4DProductName + ': Diff Current File', 'Git4DProjectDiff');
  LDiffMenu.SetParent(cGit4DProjectRootName);
  ProjectManagerMenuList.Add(LDiffMenu as IOTAProjectManagerMenu);

  LHistoryMenu := TGit4DProjectMenuItem.Create(pmHistory,
    cG4DProductName + ': File History', 'Git4DProjectHistory');
  LHistoryMenu.SetParent(cGit4DProjectRootName);
  ProjectManagerMenuList.Add(LHistoryMenu as IOTAProjectManagerMenu);
end;

procedure TGit4DProjectMenuNotifier.AddProjectCommand(Menu: TMenuItem;
  AKind: TGit4DProjectMenuKind; const ACaption: string);
var
  LItem: TMenuItem;
begin
  LItem := TMenuItem.Create(Menu);
  LItem.Caption := ACaption;
  LItem.Tag := Ord(AKind);
  LItem.OnClick := ProjectCommandClick;
  ApplyMenuIcon(LItem, ProjectMenuKindIconKey(AKind));
  Menu.Add(LItem);
end;

procedure TGit4DProjectMenuNotifier.AddProjectSeparator(Menu: TMenuItem);
var
  LItem: TMenuItem;
begin
  LItem := TMenuItem.Create(Menu);
  LItem.Caption := '-';
  Menu.Add(LItem);
end;

procedure TGit4DProjectMenuNotifier.AddProjectGitExtensionsCommand(Menu: TMenuItem;
  Command: TGitExtensionsCommand);
var
  LItem: TMenuItem;
begin
  LItem := TMenuItem.Create(Menu);
  LItem.Caption := TGit4DGitExtensions.CommandDisplayName(Command);
  LItem.Tag := Ord(Command);
  LItem.HelpContext := Ord(Command);
  LItem.OnClick := ProjectGitExtensionsClick;
  ApplyMenuIcon(LItem, GitExtensionsIconKey(Command));
  Menu.Add(LItem);
end;

procedure TGit4DProjectMenuNotifier.AddProjectTortoiseGitCommand(Menu: TMenuItem;
  Command: TTortoiseGitCommand);
var
  LItem: TMenuItem;
begin
  LItem := TMenuItem.Create(Menu);
  LItem.Caption := TGit4DTortoiseGit.CommandDisplayName(Command);
  LItem.Tag := Ord(Command);
  LItem.HelpContext := Ord(Command);
  LItem.OnClick := ProjectTortoiseGitClick;
  ApplyMenuIcon(LItem, TortoiseGitIconKey(Command));
  Menu.Add(LItem);
end;

procedure TGit4DProjectMenuNotifier.AddProjectTortoiseSvnCommand(Menu: TMenuItem;
  Command: TTortoiseSvnCommand);
var
  LItem: TMenuItem;
begin
  LItem := TMenuItem.Create(Menu);
  LItem.Caption := TGit4DTortoiseSVN.CommandDisplayName(Command);
  LItem.Tag := Ord(Command);
  LItem.HelpContext := Ord(Command);
  LItem.OnClick := ProjectTortoiseSvnClick;
  ApplyMenuIcon(LItem, TortoiseSvnIconKey(Command));
  Menu.Add(LItem);
end;

function TGit4DProjectMenuNotifier.AddMenu(const Ident: string): TMenuItem;
var
  LExternalMenuAdded: Boolean;
  LGitExtensionsMenu: TMenuItem;
  LTortoiseMenu: TMenuItem;
  LTortoiseSvnMenu: TMenuItem;
begin
  Result := TMenuItem.Create(nil);
  Result.Caption := cG4DProductName;
  Result.SubMenuImages := GetMenuImages;

  LExternalMenuAdded := False;
  if Git4DSettings.TortoiseSvnEnabled then
  begin
    LTortoiseSvnMenu := TMenuItem.Create(Result);
    LTortoiseSvnMenu.Caption := 'TortoiseSVN';
    LTortoiseSvnMenu.SubMenuImages := GetMenuImages;
    AddProjectTortoiseSvnCommand(LTortoiseSvnMenu, svnLog);
    AddProjectTortoiseSvnCommand(LTortoiseSvnMenu, svnDiff);
    AddProjectTortoiseSvnCommand(LTortoiseSvnMenu, svnBlame);
    AddProjectTortoiseSvnCommand(LTortoiseSvnMenu, svnCommit);
    AddProjectTortoiseSvnCommand(LTortoiseSvnMenu, svnUpdate);
    AddProjectTortoiseSvnCommand(LTortoiseSvnMenu, svnCheckForModifications);
    AddProjectTortoiseSvnCommand(LTortoiseSvnMenu, svnRepoBrowser);
    AddProjectTortoiseSvnCommand(LTortoiseSvnMenu, svnSettings);
    Result.Add(LTortoiseSvnMenu);
    LExternalMenuAdded := True;
  end;

  if Git4DSettings.TortoiseGitEnabled then
  begin
    LTortoiseMenu := TMenuItem.Create(Result);
    LTortoiseMenu.Caption := 'TortoiseGit';
    LTortoiseMenu.SubMenuImages := GetMenuImages;
    AddProjectTortoiseGitCommand(LTortoiseMenu, tgLog);
    AddProjectTortoiseGitCommand(LTortoiseMenu, tgDiff);
    AddProjectTortoiseGitCommand(LTortoiseMenu, tgCommit);
    AddProjectTortoiseGitCommand(LTortoiseMenu, tgPull);
    AddProjectTortoiseGitCommand(LTortoiseMenu, tgPush);
    AddProjectTortoiseGitCommand(LTortoiseMenu, tgSync);
    AddProjectTortoiseGitCommand(LTortoiseMenu, tgReflog);
    AddProjectTortoiseGitCommand(LTortoiseMenu, tgRepoBrowser);
    AddProjectTortoiseGitCommand(LTortoiseMenu, tgSettings);
    Result.Add(LTortoiseMenu);
    LExternalMenuAdded := True;
  end;

  if Git4DSettings.GitExtensionsEnabled then
  begin
    LGitExtensionsMenu := TMenuItem.Create(Result);
    LGitExtensionsMenu.Caption := 'Git Extensions';
    LGitExtensionsMenu.SubMenuImages := GetMenuImages;
    AddProjectGitExtensionsCommand(LGitExtensionsMenu, geBrowse);
    AddProjectGitExtensionsCommand(LGitExtensionsMenu, geCommit);
    AddProjectGitExtensionsCommand(LGitExtensionsMenu, gePull);
    AddProjectGitExtensionsCommand(LGitExtensionsMenu, gePush);
    AddProjectGitExtensionsCommand(LGitExtensionsMenu, geSynchronize);
    AddProjectGitExtensionsCommand(LGitExtensionsMenu, geFileHistory);
    AddProjectGitExtensionsCommand(LGitExtensionsMenu, geBlame);
    AddProjectGitExtensionsCommand(LGitExtensionsMenu, geDiffTool);
    AddProjectGitExtensionsCommand(LGitExtensionsMenu, geSettings);
    Result.Add(LGitExtensionsMenu);
    LExternalMenuAdded := True;
  end;

  if LExternalMenuAdded then
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
  Result := FileExists(Ident) or DirectoryExists(Ident);
end;

procedure TGit4DProjectMenuNotifier.ProjectCommandClick(Sender: TObject);
var
  LKind: TGit4DProjectMenuKind;
begin
  if not (Sender is TMenuItem) then
    Exit;

  LKind := TGit4DProjectMenuKind((Sender as TMenuItem).Tag);
  case LKind of
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
  LCommand: TGitExtensionsCommand;
  LCommandOrdinal: Integer;
begin
  try
    if not (Sender is TMenuItem) then
      Exit;

    LCommandOrdinal := (Sender as TMenuItem).HelpContext;
    if (LCommandOrdinal < Ord(Low(TGitExtensionsCommand))) or
      (LCommandOrdinal > Ord(High(TGitExtensionsCommand))) then
      raise Exception.CreateFmt('Invalid Git Extensions command id: %d', [LCommandOrdinal]);

    LCommand := TGitExtensionsCommand(LCommandOrdinal);
    if LCommand in [geAdd, geApply, geBlame, geDiffTool, geFileEditor, geFileHistory, geRevert, geViewPatch] then
      TGit4DGitExtensions.RunForActiveFile(LCommand)
    else
      TGit4DGitExtensions.RunForActiveRepository(LCommand);
  except
    on E: Exception do
      MessageDlg(E.Message, mtError, [mbOK], 0);
  end;
end;

procedure TGit4DProjectMenuNotifier.ProjectTortoiseGitClick(Sender: TObject);
var
  LCommand: TTortoiseGitCommand;
  LCommandOrdinal: Integer;
begin
  try
    if not (Sender is TMenuItem) then
      Exit;

    LCommandOrdinal := (Sender as TMenuItem).HelpContext;
    if (LCommandOrdinal < Ord(Low(TTortoiseGitCommand))) or
      (LCommandOrdinal > Ord(High(TTortoiseGitCommand))) then
      raise Exception.CreateFmt('Invalid TortoiseGit command id: %d', [LCommandOrdinal]);

    LCommand := TTortoiseGitCommand(LCommandOrdinal);
    if LCommand in [tgDiff, tgPreviousDiff, tgBlame, tgResolve] then
      TGit4DTortoiseGit.RunForActiveFile(LCommand)
    else
      TGit4DTortoiseGit.RunForActiveRepository(LCommand);
  except
    on E: Exception do
      MessageDlg(E.Message, mtError, [mbOK], 0);
  end;
end;

procedure TGit4DProjectMenuNotifier.ProjectTortoiseSvnClick(Sender: TObject);
var
  LCommand: TTortoiseSvnCommand;
  LCommandOrdinal: Integer;
begin
  try
    if not (Sender is TMenuItem) then
      Exit;

    LCommandOrdinal := (Sender as TMenuItem).HelpContext;
    if (LCommandOrdinal < Ord(Low(TTortoiseSvnCommand))) or
      (LCommandOrdinal > Ord(High(TTortoiseSvnCommand))) then
      raise Exception.CreateFmt('Invalid TortoiseSVN command id: %d', [LCommandOrdinal]);

    LCommand := TTortoiseSvnCommand(LCommandOrdinal);
    if LCommand in [svnDiff, svnPreviousDiff, svnBlame, svnResolved] then
      TGit4DTortoiseSVN.RunForActiveFile(LCommand)
    else
      TGit4DTortoiseSVN.RunForActiveRepository(LCommand);
  except
    on E: Exception do
      MessageDlg(E.Message, mtError, [mbOK], 0);
  end;
end;

constructor TGit4DWizard.Create;
begin
  inherited Create;
  FActionList := TActionList.Create(nil);
  FProjectMenuLegacyNotifierIndex := -1;
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
  ReleaseGit4DWorkbench;
  UninstallEditorLocalMenu;
  if FProjectMenuLegacyNotifierIndex >= 0 then
    try
      (BorlandIDEServices as IOTAProjectManager).RemoveMenuCreatorNotifier(FProjectMenuLegacyNotifierIndex);
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
  Result := cG4DWizardID;
end;

function TGit4DWizard.GetName: string;
begin
  Result := cG4DProductName;
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
  Result := cG4DProductName;
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
  LEditorLocalMenu: INTAEditorLocalMenu;
  LEditorServices: IOTAEditorServices;
begin
  try
    if Supports(BorlandIDEServices, IOTAEditorServices, LEditorServices) then
    begin
      LEditorLocalMenu := LEditorServices.GetEditorLocalMenu;
      if LEditorLocalMenu <> nil then
      begin
        try
          LEditorLocalMenu.UnregisterActionList(G4DLegacyEditorActionListCategory);
        except
        end;
        try
          LEditorLocalMenu.UnregisterActionList(G4DLegacyEditorActionListCategory2);
        except
        end;
      end;
    end;
  except
  end;
end;

procedure TGit4DWizard.HookEditorPopups;
var
  LComponentIndex: Integer;
  LEditWindow: INTAEditWindow;
  Form: TCustomForm;
  LPopupMenu: TPopupMenu;
  LServiceIndex: Integer;
  LServices: INTAEditorServices;
begin
  if not Git4DSettings.EditorPopupEnabled then
    Exit;

  if FEditorPopupHooks = nil then
    FEditorPopupHooks := TList.Create;

  if not Supports(BorlandIDEServices, INTAEditorServices, LServices) then
    Exit;

  for LServiceIndex := 0 to LServices.GetEditWindowCount - 1 do
  begin
    LEditWindow := LServices.GetEditWindow(LServiceIndex);
    if LEditWindow = nil then
      Continue;

    Form := LEditWindow.GetForm;
    if Form = nil then
      Continue;

    for LComponentIndex := 0 to Form.ComponentCount - 1 do
      if Form.Components[LComponentIndex] is TPopupMenu then
      begin
        LPopupMenu := TPopupMenu(Form.Components[LComponentIndex]);
        if IsCandidateEditorPopupMenu(LPopupMenu) then
          HookPopupMenu(LPopupMenu);
      end;
  end;
end;

procedure TGit4DWizard.HookPopupMenu(PopupMenu: TPopupMenu);
var
  LHook: TGit4DEditorPopupHook;
  LIndex: Integer;
begin
  if PopupMenu = nil then
    Exit;

  if FEditorPopupHooks = nil then
    FEditorPopupHooks := TList.Create;

  for LIndex := FEditorPopupHooks.Count - 1 downto 0 do
  begin
    LHook := TGit4DEditorPopupHook(FEditorPopupHooks[LIndex]);
    if LHook.PopupMenu = nil then
    begin
      LHook.Free;
      FEditorPopupHooks.Delete(LIndex);
    end
    else if LHook.PopupMenu = PopupMenu then
    begin
      LHook.EnsureHooked;
      Exit;
    end;
  end;

  FEditorPopupHooks.Add(TGit4DEditorPopupHook.Create(Self, PopupMenu));
end;

function TGit4DWizard.IsCandidateEditorPopupMenu(PopupMenu: TPopupMenu): Boolean;
var
  LOwnerName: string;
begin
  Result := False;
  if PopupMenu = nil then
    Exit;

  if SameText(PopupMenu.Name, 'EditorLocalMenu') or
    ContainsText(PopupMenu.Name, 'Editor') then
    Exit(True);

  if PopupMenu.Owner is TComponent then
    LOwnerName := TComponent(PopupMenu.Owner).Name
  else
    LOwnerName := '';

  Result := ContainsText(LOwnerName, 'Editor') or IsGit4DPopupMenu(PopupMenu);
end;

procedure TGit4DWizard.AddAction(const Caption: string; const Handler: TNotifyEvent;
  const Shortcut: TShortCut);
begin
  FMainMenu.Add(CreateActionItem(Caption, Handler, Shortcut));
end;

procedure TGit4DWizard.AddTortoiseGitCommand(Menu: TMenuItem; Command: TTortoiseGitCommand);
var
  LItem: TMenuItem;
begin
  LItem := CreateActionItem(TGit4DTortoiseGit.CommandDisplayName(Command), TortoiseGitCommand);
  LItem.Tag := Ord(Command);
  LItem.HelpContext := Ord(Command);
  ApplyMenuIcon(LItem, TortoiseGitIconKey(Command));
  Menu.Add(LItem);
end;

procedure TGit4DWizard.AddTortoiseSvnCommand(Menu: TMenuItem; Command: TTortoiseSvnCommand);
var
  LItem: TMenuItem;
begin
  LItem := CreateActionItem(TGit4DTortoiseSVN.CommandDisplayName(Command), TortoiseSvnCommand);
  LItem.Tag := Ord(Command);
  LItem.HelpContext := Ord(Command);
  ApplyMenuIcon(LItem, TortoiseSvnIconKey(Command));
  Menu.Add(LItem);
end;

procedure TGit4DWizard.AddGitExtensionsCommand(Menu: TMenuItem; Command: TGitExtensionsCommand);
var
  LItem: TMenuItem;
begin
  LItem := CreateActionItem(TGit4DGitExtensions.CommandDisplayName(Command), GitExtensionsCommand);
  LItem.Tag := Ord(Command);
  LItem.HelpContext := Ord(Command);
  ApplyMenuIcon(LItem, GitExtensionsIconKey(Command));
  Menu.Add(LItem);
end;

procedure TGit4DWizard.AddSeparator;
begin
  FMainMenu.Add(CreateSeparator);
end;

procedure TGit4DWizard.AddGitCommand(Menu: TMenuItem; const Caption: string; const Handler: TNotifyEvent);
var
  LItem: TMenuItem;
begin
  LItem := CreateActionItem(Caption, Handler);
  ApplyMenuIcon(LItem, InternalGitIconKey(Caption));
  Menu.Add(LItem);
end;

function TGit4DWizard.AddTortoiseSvnSubMenu(ParentMenu: TMenuItem): Boolean;
var
  LTortoiseSvnMenu: TMenuItem;
begin
  Result := False;
  if not Git4DSettings.TortoiseSvnEnabled then
    Exit;

  LTortoiseSvnMenu := TMenuItem.Create(ParentMenu);
  LTortoiseSvnMenu.Caption := 'TortoiseSVN';
  LTortoiseSvnMenu.SubMenuImages := GetMenuImages;

  AddTortoiseSvnCommand(LTortoiseSvnMenu, svnUpdate);
  AddTortoiseSvnCommand(LTortoiseSvnMenu, svnCommit);
  AddTortoiseSvnCommand(LTortoiseSvnMenu, svnDiff);
  AddTortoiseSvnCommand(LTortoiseSvnMenu, svnPreviousDiff);
  AddTortoiseSvnCommand(LTortoiseSvnMenu, svnLog);
  AddTortoiseSvnCommand(LTortoiseSvnMenu, svnBlame);
  AddTortoiseSvnCommand(LTortoiseSvnMenu, svnCheckForModifications);
  AddTortoiseSvnCommand(LTortoiseSvnMenu, svnRepoBrowser);
  AddTortoiseSvnCommand(LTortoiseSvnMenu, svnRevisionGraph);
  LTortoiseSvnMenu.Add(CreateSeparator);
  AddTortoiseSvnCommand(LTortoiseSvnMenu, svnAdd);
  AddTortoiseSvnCommand(LTortoiseSvnMenu, svnRevert);
  AddTortoiseSvnCommand(LTortoiseSvnMenu, svnCleanup);
  AddTortoiseSvnCommand(LTortoiseSvnMenu, svnResolved);
  LTortoiseSvnMenu.Add(CreateSeparator);
  AddTortoiseSvnCommand(LTortoiseSvnMenu, svnSwitch);
  AddTortoiseSvnCommand(LTortoiseSvnMenu, svnMerge);
  AddTortoiseSvnCommand(LTortoiseSvnMenu, svnBranchTag);
  AddTortoiseSvnCommand(LTortoiseSvnMenu, svnCheckout);
  AddTortoiseSvnCommand(LTortoiseSvnMenu, svnExport);
  LTortoiseSvnMenu.Add(CreateSeparator);
  AddTortoiseSvnCommand(LTortoiseSvnMenu, svnSettings);
  AddTortoiseSvnCommand(LTortoiseSvnMenu, svnHelp);
  AddTortoiseSvnCommand(LTortoiseSvnMenu, svnAbout);

  ParentMenu.Add(LTortoiseSvnMenu);
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
  GitExtensionsMenu.SubMenuImages := GetMenuImages;

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
  Result.SubMenuImages := GetMenuImages;

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
  LExistingMenu: TMenuItem;
  LIndex: Integer;
  LMainMenu: TMainMenu;
  LToolsMenu: TMenuItem;
begin
  if FMainMenuInstalled then
    Exit;

  if not Supports(BorlandIDEServices, INTAServices) then
  begin
    ScheduleMainMenuRetry;
    Exit;
  end;

  LMainMenu := (BorlandIDEServices as INTAServices).MainMenu;
  if LMainMenu = nil then
  begin
    ScheduleMainMenuRetry;
    Exit;
  end;

  LToolsMenu := FindToolsMenu(LMainMenu);
  if LToolsMenu = nil then
  begin
    ScheduleMainMenuRetry;
    Exit;
  end;

  if FMainMenuRetryTimer <> nil then
    FMainMenuRetryTimer.Enabled := False;

  LExistingMenu := nil;
  for LIndex := 0 to LToolsMenu.Count - 1 do
    if SameText(LToolsMenu.Items[LIndex].Name, G4DMainMenuName) or
      SameText(NormalizedCaption(LToolsMenu.Items[LIndex].Caption), cG4DProductName) then
    begin
      LExistingMenu := LToolsMenu.Items[LIndex];
      Break;
    end;

  if LExistingMenu <> nil then
  begin
    LToolsMenu.Remove(LExistingMenu);
    LExistingMenu.Free;
  end;

  FMainMenu := TMenuItem.Create(nil);
  FMainMenu.Name := G4DMainMenuName;
  FMainMenu.Caption := '&Git4D';
  FMainMenu.OnClick := MainMenuPopup;

  RebuildMainMenuItems;
  LToolsMenu.Add(FMainMenu);
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
  LExternalMenuAdded: Boolean;
  LWorkbenchItem: TMenuItem;
begin
  if FMainMenu = nil then
    Exit;

  FMainMenu.Clear;

  LWorkbenchItem := CreateActionItem('&Workbench', ShowWorkbench);
  ApplyMenuIcon(LWorkbenchItem, mikFolderOpen);
  FMainMenu.Add(LWorkbenchItem);
  AddSeparator;

  LExternalMenuAdded := AddTortoiseSvnSubMenu(FMainMenu);
  if AddTortoiseGitSubMenu(FMainMenu) then
    LExternalMenuAdded := True;
  if AddGitExtensionsSubMenu(FMainMenu) then
    LExternalMenuAdded := True;
  if LExternalMenuAdded then
    AddSeparator;
  AddGitSubMenu(FMainMenu);

  AddSeparator;
  AddAction('Se&ttings', ShowSettings);
  AddAction('&About', ShowAbout);
end;

function TGit4DWizard.IsGit4DPopupMenu(PopupMenu: TPopupMenu): Boolean;
var
  LCaptionText: string;
  LIndex: Integer;
begin
  Result := False;
  if PopupMenu = nil then
    Exit;

  if SameText(PopupMenu.Name, 'EditorLocalMenu') then
  begin
    Result := True;
    Exit;
  end;

  for LIndex := 0 to PopupMenu.Items.Count - 1 do
  begin
    LCaptionText := NormalizedCaption(PopupMenu.Items[LIndex].Caption);
    if SameText(LCaptionText, 'Smart CodeInsight') or
      SameText(LCaptionText, 'Editor Options') or
      SameText(LCaptionText, 'Code Preview Window') or
      SameText(LCaptionText, 'Open File at Cursor') or
      SameText(LCaptionText, 'Close All Other Pages') then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

procedure TGit4DWizard.RemoveGit4DPopupItem(PopupMenu: TPopupMenu);
var
  LIndex: Integer;
  LItem: TMenuItem;
begin
  if PopupMenu = nil then
    Exit;

  for LIndex := PopupMenu.Items.Count - 1 downto 0 do
  begin
    LItem := PopupMenu.Items[LIndex];
    if SameText(LItem.Name, G4DEditorPopupMenuName) or
      SameText(NormalizedCaption(LItem.Caption), cG4DProductName) then
    begin
      PopupMenu.Items.Remove(LItem);
      LItem.Free;
    end;
  end;
end;

procedure TGit4DWizard.RebuildEditorPopupMenu(PopupMenu: TPopupMenu);
var
  LExternalMenuAdded: Boolean;
  LFoundSmartCodeInsight: Boolean;
  LIndex: Integer;
  LInsertIndex: Integer;
  LItem: TMenuItem;
  LRootMenu: TMenuItem;
  LWorkbenchItem: TMenuItem;
begin
  if PopupMenu = nil then
    Exit;

  RemoveGit4DPopupItem(PopupMenu);
  if not IsGit4DPopupMenu(PopupMenu) then
    Exit;
  if not Git4DSettings.EditorPopupEnabled then
    Exit;

  LFoundSmartCodeInsight := False;
  LInsertIndex := PopupMenu.Items.Count;
  for LIndex := 0 to PopupMenu.Items.Count - 1 do
  begin
    LItem := PopupMenu.Items[LIndex];
    if SameText(NormalizedCaption(LItem.Caption), 'Smart CodeInsight') then
    begin
      LInsertIndex := LIndex + 1;
      LFoundSmartCodeInsight := True;
      Break;
    end;
  end;
  if not LFoundSmartCodeInsight then
    LInsertIndex := PopupMenu.Items.Count;
  if LInsertIndex > PopupMenu.Items.Count then
    LInsertIndex := PopupMenu.Items.Count;

  LRootMenu := TMenuItem.Create(PopupMenu);
  LRootMenu.Name := G4DEditorPopupMenuName;
  LRootMenu.Caption := cG4DProductName;

  LWorkbenchItem := CreateActionItem('&Workbench', ShowWorkbench);
  ApplyMenuIcon(LWorkbenchItem, mikFolderOpen);
  LRootMenu.Add(LWorkbenchItem);
  LRootMenu.Add(CreateSeparator);

  LExternalMenuAdded := AddTortoiseSvnSubMenu(LRootMenu);
  if AddTortoiseGitSubMenu(LRootMenu) then
    LExternalMenuAdded := True;
  if AddGitExtensionsSubMenu(LRootMenu) then
    LExternalMenuAdded := True;
  if LExternalMenuAdded then
    LRootMenu.Add(CreateSeparator);
  AddGitSubMenu(LRootMenu);
  LRootMenu.Add(CreateSeparator);
  LRootMenu.Add(CreateActionItem('Se&ttings', ShowSettings));
  LRootMenu.Add(CreateActionItem('&About', ShowAbout));

  if LRootMenu.Count = 0 then
    LRootMenu.Enabled := False;

  PopupMenu.Items.Insert(LInsertIndex, LRootMenu);
end;

procedure TGit4DWizard.MainMenuPopup(Sender: TObject);
begin
  RebuildMainMenuItems;
end;

function TGit4DWizard.FindToolsMenu(MainMenu: TMainMenu): TMenuItem;
var
  LCaptionText: string;
  LIndex: Integer;
begin
  Result := nil;
  for LIndex := 0 to MainMenu.Items.Count - 1 do
  begin
    LCaptionText := StringReplace(MainMenu.Items[LIndex].Caption, '&', '', [rfReplaceAll]);
    if SameText(LCaptionText, 'Tools') then
    begin
      Result := MainMenu.Items[LIndex];
      Exit;
    end;
  end;
end;

procedure TGit4DWizard.InstallProjectManagerMenu;
var
  LProjectManager: IOTAProjectManager;
begin
  if FProjectMenuLegacyNotifierIndex >= 0 then
    Exit;

  if Supports(BorlandIDEServices, IOTAProjectManager, LProjectManager) then
  begin
    FProjectMenuNotifier := TGit4DProjectMenuNotifier.Create;
    try
      FProjectMenuLegacyNotifierIndex := LProjectManager.AddMenuCreatorNotifier(FProjectMenuNotifier);
    except
    end;
  end;
end;

function TGit4DWizard.AddTortoiseGitSubMenu(ParentMenu: TMenuItem): Boolean;
var
  LTortoiseMenu: TMenuItem;
begin
  Result := False;
  if not Git4DSettings.TortoiseGitEnabled then
    Exit;

  LTortoiseMenu := TMenuItem.Create(ParentMenu);
  LTortoiseMenu.Caption := 'TortoiseGit';
  LTortoiseMenu.SubMenuImages := GetMenuImages;

  AddTortoiseGitCommand(LTortoiseMenu, tgPull);
  AddTortoiseGitCommand(LTortoiseMenu, tgPush);
  AddTortoiseGitCommand(LTortoiseMenu, tgSync);
  AddTortoiseGitCommand(LTortoiseMenu, tgCommit);
  AddTortoiseGitCommand(LTortoiseMenu, tgFetch);
  AddTortoiseGitCommand(LTortoiseMenu, tgDiff);
  AddTortoiseGitCommand(LTortoiseMenu, tgPreviousDiff);
  AddTortoiseGitCommand(LTortoiseMenu, tgLog);
  AddTortoiseGitCommand(LTortoiseMenu, tgReflog);
  AddTortoiseGitCommand(LTortoiseMenu, tgBrowseReferences);
  AddTortoiseGitCommand(LTortoiseMenu, tgDaemon);
  AddTortoiseGitCommand(LTortoiseMenu, tgRevisionGraph);
  AddTortoiseGitCommand(LTortoiseMenu, tgRepoBrowser);
  AddTortoiseGitCommand(LTortoiseMenu, tgRebase);
  AddTortoiseGitCommand(LTortoiseMenu, tgStashSave);
  AddTortoiseGitCommand(LTortoiseMenu, tgBisectStart);
  AddTortoiseGitCommand(LTortoiseMenu, tgResolve);
  AddTortoiseGitCommand(LTortoiseMenu, tgRevert);
  AddTortoiseGitCommand(LTortoiseMenu, tgCleanup);
  AddTortoiseGitCommand(LTortoiseMenu, tgSwitchCheckout);
  AddTortoiseGitCommand(LTortoiseMenu, tgMerge);
  AddTortoiseGitCommand(LTortoiseMenu, tgCreateBranch);
  AddTortoiseGitCommand(LTortoiseMenu, tgCreateTag);
  AddTortoiseGitCommand(LTortoiseMenu, tgExport);
  AddTortoiseGitCommand(LTortoiseMenu, tgWorktrees);
  AddTortoiseGitCommand(LTortoiseMenu, tgSubmoduleAdd);
  AddTortoiseGitCommand(LTortoiseMenu, tgCreatePatchSerial);
  AddTortoiseGitCommand(LTortoiseMenu, tgApplyPatchSerial);
  AddTortoiseGitCommand(LTortoiseMenu, tgSettings);
  AddTortoiseGitCommand(LTortoiseMenu, tgHelp);
  AddTortoiseGitCommand(LTortoiseMenu, tgAbout);

  ParentMenu.Add(LTortoiseMenu);
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
  LBranchName: string;
begin
  if InputQuery(cG4DProductName, 'Branch to checkout', LBranchName) then
    TGit4DGit.RunGitForActiveRepository('checkout ' + LBranchName);
end;

procedure TGit4DWizard.CreateBranch(Sender: TObject);
var
  LBranchName: string;
begin
  if InputQuery(cG4DProductName, 'New branch name', LBranchName) then
    TGit4DGit.RunGitForActiveRepository('checkout -b ' + LBranchName);
end;

procedure TGit4DWizard.MergeBranch(Sender: TObject);
var
  LBranchName: string;
begin
  if InputQuery(cG4DProductName, 'Branch to merge', LBranchName) then
    TGit4DGit.RunGitForActiveRepository('merge ' + LBranchName);
end;

procedure TGit4DWizard.RebaseBranch(Sender: TObject);
var
  LBranchName: string;
begin
  if InputQuery(cG4DProductName, 'Branch to rebase onto', LBranchName) then
    TGit4DGit.RunGitForActiveRepository('rebase ' + LBranchName);
end;

procedure TGit4DWizard.CherryPick(Sender: TObject);
var
  LCommitHash: string;
begin
  if InputQuery(cG4DProductName, 'Commit to cherry-pick', LCommitHash) then
    TGit4DGit.RunGitForActiveRepository('cherry-pick ' + LCommitHash);
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

procedure TGit4DWizard.ShowWorkbench(Sender: TObject);
begin
  ShowGit4DWorkbench;
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
  LCommand: TGitExtensionsCommand;
  LCommandOrdinal: Integer;
begin
  try
    if Sender is TMenuItem then
      LCommandOrdinal := (Sender as TMenuItem).HelpContext
    else if Sender is TAction then
      LCommandOrdinal := (Sender as TAction).HelpContext
    else
      Exit;

    if (LCommandOrdinal < Ord(Low(TGitExtensionsCommand))) or
      (LCommandOrdinal > Ord(High(TGitExtensionsCommand))) then
      raise Exception.CreateFmt('Invalid Git Extensions command id: %d', [LCommandOrdinal]);

    LCommand := TGitExtensionsCommand(LCommandOrdinal);
    if LCommand in [geAdd, geApply, geBlame, geDiffTool, geFileEditor, geFileHistory, geRevert, geViewPatch] then
      TGit4DGitExtensions.RunForActiveFile(LCommand)
    else
      TGit4DGitExtensions.RunForActiveRepository(LCommand);
  except
    on E: Exception do
      MessageDlg(E.Message, mtError, [mbOK], 0);
  end;
end;

procedure TGit4DWizard.TortoiseSvnCommand(Sender: TObject);
var
  LCommand: TTortoiseSvnCommand;
  LCommandOrdinal: Integer;
begin
  try
    if Sender is TMenuItem then
      LCommandOrdinal := (Sender as TMenuItem).HelpContext
    else if Sender is TAction then
      LCommandOrdinal := (Sender as TAction).HelpContext
    else
      Exit;

    if (LCommandOrdinal < Ord(Low(TTortoiseSvnCommand))) or
      (LCommandOrdinal > Ord(High(TTortoiseSvnCommand))) then
      raise Exception.CreateFmt('Invalid TortoiseSVN command id: %d', [LCommandOrdinal]);

    LCommand := TTortoiseSvnCommand(LCommandOrdinal);
    if LCommand in [svnDiff, svnPreviousDiff, svnBlame, svnResolved] then
      TGit4DTortoiseSVN.RunForActiveFile(LCommand)
    else
      TGit4DTortoiseSVN.RunForActiveRepository(LCommand);
  except
    on E: Exception do
      MessageDlg(E.Message, mtError, [mbOK], 0);
  end;
end;

procedure TGit4DWizard.TortoiseGitCommand(Sender: TObject);
var
  LCommand: TTortoiseGitCommand;
  LCommandOrdinal: Integer;
begin
  try
    if Sender is TMenuItem then
      LCommandOrdinal := (Sender as TMenuItem).HelpContext
    else if Sender is TAction then
      LCommandOrdinal := (Sender as TAction).HelpContext
    else
      Exit;

    if (LCommandOrdinal < Ord(Low(TTortoiseGitCommand))) or
      (LCommandOrdinal > Ord(High(TTortoiseGitCommand))) then
      raise Exception.CreateFmt('Invalid TortoiseGit command id: %d', [LCommandOrdinal]);

    LCommand := TTortoiseGitCommand(LCommandOrdinal);
    if LCommand in [tgDiff, tgPreviousDiff, tgBlame, tgResolve] then
      TGit4DTortoiseGit.RunForActiveFile(LCommand)
    else
      TGit4DTortoiseGit.RunForActiveRepository(LCommand);
  except
    on E: Exception do
      MessageDlg(E.Message, mtError, [mbOK], 0);
  end;
end;

initialization
  FillChar(GMenuIconIndexes, SizeOf(GMenuIconIndexes), $FF);

finalization
  GMenuImages.Free;

end.

