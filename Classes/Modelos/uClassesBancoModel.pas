unit uClassesBancoModel;

interface

uses
  Rtti,
  {$IF RTLVersion > 21.0}
    System.Generics.Collections;
  {$ELSE}
    Generics.Collections;
  {$IFEND}

type
  TBaseModel = class
    private
    public
  end;

  TColunaBase = class(TBaseModel)
    private
      FNome: String;
    public
      property Nome: String read FNome write FNome;

      constructor Create(const ANome: String); overload;

      constructor Create; overload;
  end;

  TColuna = TColunaBase;

  TColunas = TObjectList<TColuna>;

implementation

{ TColunaBase }

constructor TColunaBase.Create;
begin
  inherited Create;
end;

constructor TColunaBase.Create(const ANome: String);
begin
  inherited Create;

  FNome := ANome;
end;

end.
