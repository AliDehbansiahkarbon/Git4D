object Git4DWorkbenchForm: TGit4DWorkbenchForm
  Left = 0
  Top = 0
  Caption = 'Git4D Workbench'
  ClientHeight = 520
  ClientWidth = 760
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poDesigned
  TextHeight = 15
  object TopPanel: TPanel
    Left = 0
    Top = 0
    Width = 760
    Height = 112
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object HeaderPanel: TPanel
      Left = 0
      Top = 0
      Width = 760
      Height = 74
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 0
      object FRepositoryLabel: TLabel
        Left = 10
        Top = 8
        Width = 520
        Height = 20
        Anchors = [akLeft, akTop, akRight]
        AutoSize = False
        Caption = 'Repository:'
      end
      object FBranchLabel: TLabel
        Left = 10
        Top = 30
        Width = 520
        Height = 20
        Anchors = [akLeft, akTop, akRight]
        AutoSize = False
        Caption = 'Branch:'
      end
      object FStatusLabel: TLabel
        Left = 10
        Top = 52
        Width = 520
        Height = 20
        Anchors = [akLeft, akTop, akRight]
        AutoSize = False
        Caption = 'Ready'
      end
      object ConnectToLabel: TLabel
        Left = 512
        Top = 9
        Width = 76
        Height = 20
        Anchors = [akTop, akRight]
        AutoSize = False
        Caption = 'Connect to:'
      end
      object FClientCombo: TComboBox
        Left = 590
        Top = 6
        Width = 160
        Height = 23
        Anchors = [akTop, akRight]
        Style = csDropDownList
        TabOrder = 0
      end
    end
    object ToolbarPanel: TPanel
      Left = 0
      Top = 78
      Width = 760
      Height = 34
      Align = alBottom
      BevelOuter = bvNone
      Padding.Left = 8
      Padding.Top = 2
      Padding.Right = 8
      Padding.Bottom = 2
      TabOrder = 1
      object RefreshButton: TButton
        AlignWithMargins = True
        Left = 8
        Top = 4
        Width = 82
        Height = 26
        Margins.Left = 0
        Margins.Top = 2
        Margins.Right = 5
        Margins.Bottom = 2
        Align = alLeft
        Caption = 'Refresh'
        TabOrder = 0
      end
      object StatusButton: TButton
        AlignWithMargins = True
        Left = 95
        Top = 4
        Width = 82
        Height = 26
        Margins.Left = 0
        Margins.Top = 2
        Margins.Right = 5
        Margins.Bottom = 2
        Align = alLeft
        Caption = 'Status'
        TabOrder = 1
      end
      object DiffButton: TButton
        AlignWithMargins = True
        Left = 182
        Top = 4
        Width = 82
        Height = 26
        Margins.Left = 0
        Margins.Top = 2
        Margins.Right = 5
        Margins.Bottom = 2
        Align = alLeft
        Caption = 'Diff'
        TabOrder = 2
      end
      object StageButton: TButton
        AlignWithMargins = True
        Left = 269
        Top = 4
        Width = 82
        Height = 26
        Margins.Left = 0
        Margins.Top = 2
        Margins.Right = 5
        Margins.Bottom = 2
        Align = alLeft
        Caption = 'Stage'
        TabOrder = 3
      end
      object ResetButton: TButton
        AlignWithMargins = True
        Left = 356
        Top = 4
        Width = 82
        Height = 26
        Margins.Left = 0
        Margins.Top = 2
        Margins.Right = 5
        Margins.Bottom = 2
        Align = alLeft
        Caption = 'Reset'
        TabOrder = 4
      end
      object CommitButton: TButton
        AlignWithMargins = True
        Left = 443
        Top = 4
        Width = 82
        Height = 26
        Margins.Left = 0
        Margins.Top = 2
        Margins.Right = 5
        Margins.Bottom = 2
        Align = alLeft
        Caption = 'Commit'
        TabOrder = 5
      end
      object PullButton: TButton
        AlignWithMargins = True
        Left = 530
        Top = 4
        Width = 82
        Height = 26
        Margins.Left = 0
        Margins.Top = 2
        Margins.Right = 5
        Margins.Bottom = 2
        Align = alLeft
        Caption = 'Pull'
        TabOrder = 6
      end
      object PushButton: TButton
        AlignWithMargins = True
        Left = 617
        Top = 4
        Width = 82
        Height = 26
        Margins.Left = 0
        Margins.Top = 2
        Margins.Right = 5
        Margins.Bottom = 2
        Align = alLeft
        Caption = 'Push'
        TabOrder = 7
      end
    end
  end
  object GapPanel: TPanel
    Left = 0
    Top = 112
    Width = 760
    Height = 10
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
  end
  object FContentPanel: TPanel
    Left = 0
    Top = 122
    Width = 760
    Height = 398
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 2
    object FLeftPanel: TPanel
      Left = 0
      Top = 0
      Width = 510
      Height = 398
      Align = alLeft
      BevelOuter = bvNone
      TabOrder = 0
      object FChangedFiles: TListView
        Left = 0
        Top = 0
        Width = 510
        Height = 398
        Align = alClient
        Columns = <
          item
            Caption = 'File'
            Width = 470
          end
          item
            Caption = 'State'
            Width = 150
          end
          item
            Caption = 'Code'
            Width = 60
          end>
        ReadOnly = True
        RowSelect = True
        TabOrder = 0
        ViewStyle = vsReport
      end
    end
    object FMainSplitter: TSplitter
      Left = 510
      Top = 0
      Width = 9
      Height = 398
      Align = alLeft
      Beveled = True
      MinSize = 160
    end
    object FRightPanel: TPanel
      Left = 519
      Top = 0
      Width = 241
      Height = 398
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 1
      object FTerminalPanel: TPanel
        Left = 0
        Top = 222
        Width = 241
        Height = 176
        Align = alBottom
        BevelOuter = bvNone
        TabOrder = 0
        object TerminalHeaderPanel: TPanel
          Left = 0
          Top = 0
          Width = 241
          Height = 24
          Align = alTop
          BevelOuter = bvNone
          Padding.Left = 6
          TabOrder = 0
          object FTerminalTitleLabel: TLabel
            Left = 6
            Top = 0
            Width = 235
            Height = 24
            Align = alClient
            Caption = 'Terminal'
            Layout = tlCenter
          end
        end
        object CommandPanel: TPanel
          Left = 0
          Top = 148
          Width = 241
          Height = 28
          Align = alBottom
          BevelOuter = bvNone
          Padding.Left = 6
          Padding.Top = 3
          Padding.Right = 6
          Padding.Bottom = 3
          TabOrder = 1
          object FTerminalPromptLabel: TLabel
            Left = 6
            Top = 3
            Width = 130
            Height = 22
            Align = alLeft
            AutoSize = False
            Caption = 'terminal>'
            Layout = tlCenter
          end
          object FTerminalInput: TEdit
            Left = 136
            Top = 3
            Width = 99
            Height = 22
            Align = alClient
            TabOrder = 0
            TextHint = 'git status'
          end
        end
        object FTerminalOutput: TMemo
          Left = 0
          Top = 24
          Width = 241
          Height = 124
          Align = alClient
          ReadOnly = True
          ScrollBars = ssVertical
          TabOrder = 2
          WordWrap = True
        end
      end
      object FTerminalSplitter: TSplitter
        Left = 0
        Top = 214
        Width = 241
        Height = 8
        Cursor = crVSplit
        Align = alBottom
        Beveled = True
        MinSize = 70
      end
      object FLastOutput: TMemo
        Left = 0
        Top = 0
        Width = 241
        Height = 214
        Align = alClient
        ReadOnly = True
        ScrollBars = ssBoth
        TabOrder = 1
        WordWrap = False
      end
    end
  end
end
