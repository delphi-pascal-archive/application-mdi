object foEcranTest: TfoEcranTest
  Left = 287
  Top = 103
  Width = 979
  Height = 563
  Caption = 'Test d'#39#233'cean MDIChild'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsMDIChild
  OldCreateOrder = False
  Position = poDefault
  Visible = True
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 32
    Top = 16
    Width = 83
    Height = 13
    Caption = 'Renomer l'#39#233'cran :'
  end
  object eNouveauTitre: TEdit
    Left = 48
    Top = 32
    Width = 265
    Height = 21
    TabOrder = 0
    Text = 'Test d'#39#233'cean MDIChild'
  end
  object btnRenomer: TButton
    Left = 240
    Top = 56
    Width = 75
    Height = 25
    Caption = 'Renomer'
    TabOrder = 1
    OnClick = btnRenomerClick
  end
end
