unit uClassesBancoModel;

interface

uses
  System.Generics.Collections;

type
  TBaseModel = class
  end;

  TSql = String;

  TResultadoItemBanco = TDictionary<String, Variant>;

  TResultadosBanco = TObjectList<TResultadoItemBanco>;

implementation

end.
