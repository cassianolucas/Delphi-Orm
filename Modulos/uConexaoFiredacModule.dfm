object DmConexaoFiredac: TDmConexaoFiredac
  OldCreateOrder = False
  Height = 151
  Width = 226
  object FDConnection: TFDConnection
    Params.Strings = (
      'ConnectionDef=SQLite_Demo')
    LoginPrompt = False
    Transaction = FDTransaction
    Left = 32
    Top = 16
  end
  object FDQuery: TFDQuery
    Connection = FDConnection
    Left = 32
    Top = 80
  end
  object FDTransaction: TFDTransaction
    Connection = FDConnection
    Left = 112
    Top = 16
  end
end
