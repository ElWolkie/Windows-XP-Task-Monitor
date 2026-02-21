object Form2: TForm2
  Left = 399
  Height = 430
  Top = 141
  Width = 447
  Caption = 'Simple Task Manager V1'
  ClientHeight = 0
  ClientWidth = 0
  Color = clBtnFace
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  LCLVersion = '3.2.0.0'
  object TaskLv: TListView
    Left = 3
    Height = 414
    Top = 8
    Width = 439
    Columns = <    
      item
        Caption = 'Process Name'
        Width = 100
      end    
      item
        Caption = 'Process Path '
        Width = 230
      end    
      item
        Caption = 'Process Id'
        Width = 100
      end>
    PopupMenu = PopupMenu1
    TabOrder = 0
    ViewStyle = vsReport
  end
  object PopupMenu1: TPopupMenu
    Left = 136
    Top = 144
    object ListTasks1: TMenuItem
      Caption = 'List Tasks'
      OnClick = ListTasks1Click
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object EndProcess1: TMenuItem
      Caption = 'End Process'
      OnClick = EndProcess1Click
    end
  end
end
