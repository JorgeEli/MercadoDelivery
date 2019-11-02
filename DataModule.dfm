object DM: TDM
  OldCreateOrder = False
  Height = 290
  Width = 574
  object Connection: TFDConnection
    Params.Strings = (
      
        'Database=C:\Users\Jorge\Documents\Embarcadero\Studio\Projects\Pr' +
        'ojetoGit\DataBase\MERCADO_DELIVERY.FDB'
      'Password=masterkey'
      'User_Name=SYSDBA'
      'DriverID=FB')
    Connected = True
    LoginPrompt = False
    Transaction = Transaction
    Left = 56
    Top = 40
  end
  object Transaction: TFDTransaction
    Connection = Connection
    Left = 136
    Top = 40
  end
  object Driver: TFDPhysFBDriverLink
    Left = 216
    Top = 41
  end
end
