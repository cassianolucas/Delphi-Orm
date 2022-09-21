unit uAtributoBancoModel;

interface

uses
  Rtti,
    {$IF RTLVersion > 21.0}
      System.Generics.Collections;
  {$ELSE}
      Generics.Collections;
  {$IFEND}

type
  TAtributoBanco = class abstract (TCustomAttribute);

  TAtributoBase = class abstract (TAtributoBanco)
    private
      FNome: String;
    public
      constructor Create(const ANome: String); overload;
      property Nome: String read FNome write FNome;
  end;

  TTabelaBanco = class(TAtributoBase);

  TColunaBanco = class(TAtributoBase)
    private
      FTabela: String;
    public
      property Tabela: String read FTabela write FTabela;

      constructor Create(const ANome, ATabela: String); overload;
  end;

  TColunasBanco = class(TObjectList<TColunaBanco>)
    public
      function ToString: String; override;
  end;

  TJoinBanco = class(TAtributoBanco)
    private
      FOrigem: String;
      FDestino: String;
      FTabelaOrigem,
      FTabelaDestino: String;
    public
      constructor Create(const AOrigem, ADestino: String); overload;

      constructor Create(const ATabelaOrigem, AOrigem,
        ATabelaDestino, ADestino: String); overload;

      property Origem: String read FOrigem write FOrigem;
      property Destino: String read FDestino write FDestino;
      property TabelaOrigem: String read FTabelaOrigem write FTabelaOrigem;
      property TabelaDestino: String read FTabelaDestino write FTabelaDestino;

      function ToString: String; override;
  end;

  TJoinsBanco = class(TObjectList<TJoinBanco>)
    public
      function ToString: String; override;
  end;

  TChavePrimaria = class(TAtributoBase)
    private
      FTipo: TRttiType;
    public
      property Tipo: TRttiType read FTipo write FTipo;
  end;

implementation

uses
  {$IF RTLVersion > 21.0}
      System.SysUtils;
  {$ELSE}
      SysUtils;
  {$IFEND}

{ TAtributoBase }

constructor TAtributoBase.Create(const ANome: String);
begin
  inherited Create;

  FNome := ANome;
end;

{ TJoinBanco }

constructor TJoinBanco.Create(const AOrigem, ADestino: String);
begin
  inherited Create;

  FOrigem := AOrigem;
  FDestino := ADestino;
end;

constructor TJoinBanco.Create(const ATabelaOrigem, AOrigem,
  ATabelaDestino, ADestino: String);
begin
  Create(AOrigem, ADestino);

  FTabelaOrigem := ATabelaOrigem;
  FTabelaDestino := ATabelaDestino;
end;

function TJoinBanco.ToString: String;
const
  FORMATO = 'join %s on %s.%s = %s.%s ';
begin
  Result := Format(FORMATO, [TabelaDestino, TabelaDestino, Origem, TabelaOrigem, Destino]);
end;

{ TColunaBanco }

constructor TColunaBanco.Create(const ANome, ATabela: String);
begin
  inherited Create(ANome);

  FTabela := ATabela;
end;

{ TColunas }

function TColunasBanco.ToString: String;
const
  FORMATO = '%s.%s,';
var
  LColuna: TColunaBanco;
begin
  for LColuna in Self do
    Result := Concat(Result, Format(FORMATO, [LColuna.Tabela, LColuna.Nome]));

  if Copy(Result, Length(Result), 1) = ',' then
    Result := Copy(Result, 0, Length(Result) -1);
end;

{ TJoinsBanco }

function TJoinsBanco.ToString: String;
var
  LJoin: TJoinBanco;
begin
  for LJoin in Self do
    Result := Concat(Result, LJoin.ToString);
end;

end.
