object FrmPic: TFrmPic
  Left = 0
  Top = 0
  BorderStyle = bsToolWindow
  Caption = #25209#37327#22270#29255#20462#25913' v0.1'
  ClientHeight = 170
  ClientWidth = 335
  Color = clWhite
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = #23435#20307
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Lbl2: TLabel
    Left = 12
    Top = 18
    Width = 56
    Height = 13
    Caption = #36716#25442#22823#23567
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = #23435#20307
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Lbl3: TLabel
    Left = 25
    Top = 46
    Width = 26
    Height = 13
    Caption = #23485#24230
  end
  object Lbl4: TLabel
    Left = 25
    Top = 76
    Width = 26
    Height = 13
    Caption = #39640#24230
  end
  object Lbl5: TLabel
    Left = 12
    Top = 108
    Width = 56
    Height = 13
    Caption = #20854#20182#21442#25968
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = #23435#20307
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Lbl6: TLabel
    Left = 25
    Top = 136
    Width = 26
    Height = 13
    Caption = #36136#37327
  end
  object SpinWidth: TSpinEdit
    Left = 68
    Top = 42
    Width = 115
    Height = 22
    MaxValue = 3264
    MinValue = 400
    TabOrder = 1
    Value = 1600
    OnChange = SpinWidthChange
  end
  object SpinHeight: TSpinEdit
    Left = 68
    Top = 73
    Width = 115
    Height = 22
    MaxValue = 2448
    MinValue = 300
    TabOrder = 2
    Value = 1200
    OnChange = SpinHeightChange
  end
  object Pnl1: TPanel
    Left = 200
    Top = 42
    Width = 120
    Height = 111
    BevelKind = bkFlat
    BevelOuter = bvNone
    Caption = #25302#25918#21040#36825#37324
    TabOrder = 4
  end
  object ChkTop: TCheckBox
    Left = 200
    Top = 17
    Width = 75
    Height = 17
    Caption = #31383#21475#32622#39030
    Checked = True
    State = cbChecked
    TabOrder = 0
    OnClick = ChkTopClick
  end
  object ComQuality: TComboBox
    Left = 68
    Top = 132
    Width = 115
    Height = 21
    Hint = #22270#29255#36136#37327#13#10#36136#37327#36234#22909#65292#30011#36136#23601#36234#22909#65292#21516#26102#25991#20214#20063#36234#22823#12290
    Style = csDropDownList
    ItemIndex = 2
    ParentShowHint = False
    ShowHint = True
    TabOrder = 3
    Text = #39640
    OnSelect = ComQualitySelect
    Items.Strings = (
      #20302
      #20013
      #39640
      #26368#20339)
  end
  object PnlProc: TPanel
    Left = 281
    Top = -5
    Width = 113
    Height = 41
    BevelOuter = bvNone
    ParentBackground = False
    ParentColor = True
    TabOrder = 5
    Visible = False
    object Lbl1: TLabel
      Left = 20
      Top = 30
      Width = 39
      Height = 13
      Caption = #36716#25442#20013
    end
    object LblFile: TLabel
      Left = 20
      Top = 114
      Width = 49
      Height = 13
      Caption = 'LblFile'
    end
    object LblCount: TLabel
      Left = 280
      Top = 30
      Width = 35
      Height = 13
      Caption = '10/10'
    end
    object Pb1: TProgressBar
      Left = 20
      Top = 68
      Width = 295
      Height = 17
      Max = 21
      Position = 21
      TabOrder = 0
    end
  end
end
