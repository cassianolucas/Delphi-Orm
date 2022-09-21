unit uBancoUtils;

interface

uses
   {$IF RTLVersion > 21.0}
    System.Generics.Collections, System.Generics.Defaults,
    System.SysUtils,
  {$ELSE}
    Generics.Collections, Generics.Defaults, SysUtils,
  {$IFEND}
  uBaseModel, uAtributoBancoModel, Rtti;

type
  TResultadoItemSelect = TDictionary<String, Variant>;
  TResultadoSelect = TObjectList<TResultadoItemSelect>;

  TBancoDadosUtil<T: TBaseModel, constructor> = class
    private
      FContexto: TRttiContext;
      FTabela: TTabelaBanco;
      FColunas: TColunasBanco;
      FJoins: TJoinsBanco;
      FChavePrimaria: TChavePrimaria;
      FColunaChavePrimaria: TColunaBanco;

      FConexao: string;


      constructor Create(const AConexao: String);

      procedure Inicializar(ATipo: TRttiType);

      function BuscaTabela(ATipo: TRttiType): TTabelaBanco;

      function ExecutaSql(const ASql: String): TResultadoSelect;
    public
      destructor Destroy; override;

      function BuscarPorChavePrimaria(const AValor: Variant): T;

      class function New(const AConexao: String): TBancoDadosUtil<T>;
  end;

implementation

uses
  {$IF RTLVersion > 21.0}
    System.TypInfo, System.Variants,
    // externalizar após teste
    Data.SqlExpr, Data.DB,
  // fim externalização
  {$ELSE}
    TypInfo, Variants,
    // externalizar após teste
    SqlExpr, DB,
    // fim externalização
  {$IFEND}
  uExcecoesBanco;

{ TBancoDadosUtil<T> }

function TBancoDadosUtil<T>.BuscarPorChavePrimaria(const AValor: Variant): T;
const
  SQL_BUSCAR_ID = 'select %s from %s %s where %s.%s = %s';
var
  LValor: String;
  LSql: String;
  LResultados: TResultadoSelect;
  LResultado: TResultadoItemSelect;
begin
  case FChavePrimaria.Tipo.TypeKind of
    tkUString,
    tkWChar,
    tkLString,
    tkWString,
    tkChar,
    tkString: LValor := QuotedStr(VarToStr(AValor));
    else
      LValor := VarToStr(AValor);
  end;

  if (LValor = '') then
    raise TExcecaoValorChavePrimaria.Create;

  LSql := Format(SQL_BUSCAR_ID, [FColunas.ToString, FTabela.Nome,
    FJoins.ToString, FTabela.Nome, FColunaChavePrimaria.Nome, LValor]);

  LResultados := ExecutaSql(LSql);

  Result := T.Create;



//  for LResultado in LResultados do
//  begin
//
//  end;
end;

function TBancoDadosUtil<T>.BuscaTabela(ATipo: TRttiType): TTabelaBanco;
var
  LAtributo: TCustomAttribute;
begin
  for LAtributo in ATipo.GetAttributes do
  begin
    if (LAtributo is TTabelaBanco) then
      Result := TTabelaBanco(LAtributo);

    if Assigned(Result) then
      Exit;
  end;
end;

function TBancoDadosUtil<T>.ExecutaSql(
  const ASql: String): TResultadoSelect;
var
  LConexao: TSQLConnection;
  LTemp: TSQLQuery;
  LField: TField;
  LItem: TResultadoItemSelect;
begin
  // externalizar para não criar dependencia em classe

  Result := TResultadoSelect.Create;

  LConexao := TSQLConnection.Create(nil);
  LConexao.ConnectionName := FConexao;

  LTemp := TSQLQuery.Create(nil);
  LTemp.SQLConnection := LConexao;
  try
    LTemp.SQL.Text := ASql;
    LTemp.Open;

    while not(LTemp.Eof) do
    begin
      LItem := TResultadoItemSelect.Create;

      for LField in LTemp.Fields do
        LItem.Add(LField.FieldName, LField.Value);

      Result.Add(LItem);

      LTemp.Next;
    end;
  finally
    LTemp.Free;
    LConexao.Free;
  end;
end;

procedure TBancoDadosUtil<T>.Inicializar(ATipo: TRttiType);
var
  LTabela: TTabelaBanco;
  LTabelaDestino: TTabelaBanco;
  LPropriedade: TRttiProperty;
  LAtribuo: TCustomAttribute;
  LNomePropriedadeChavePrimaria: String;
begin
  if not(Assigned(FTabela)) then
    FTabela := BuscaTabela(ATipo);

  LTabela := BuscaTabela(ATipo);

  if not(Assigned(LTabela)) then
    raise TExcecaoTabelaNaoEncontrada.Create;

  for LPropriedade in ATipo.GetProperties do
  begin
    if (LPropriedade.Visibility < TMemberVisibility.mvPublic) then
      Continue;

    for LAtribuo in LPropriedade.GetAttributes do
    begin
      if (LAtribuo is TColunaBanco) then
      begin
        FColunas.Add(TColunaBanco.Create(TColunaBanco(LAtribuo).Nome, LTabela.Nome));

        if (LPropriedade.Name = LNomePropriedadeChavePrimaria) and not(Assigned(FColunaChavePrimaria)) then
          FColunaChavePrimaria := TColunaBanco.Create(TColunaBanco(LAtribuo).Nome, LTabela.Nome);
      end
      else if (LAtribuo is TJoinBanco) then
      begin
        LTabelaDestino := BuscaTabela(LPropriedade.PropertyType);

        if not(Assigned(LTabelaDestino)) then
          raise TExcecaoTabelaNaoEncontrada.Create;

        FJoins.Add(TJoinBanco.Create(LTabela.Nome, TJoinBanco(LAtribuo).Origem,
          LTabelaDestino.Nome, TJoinBanco(LAtribuo).Destino));
          
        Inicializar(LPropriedade.PropertyType);
      end
      else if (LAtribuo is TChavePrimaria) then
      begin        
        FChavePrimaria := TChavePrimaria(LAtribuo);
        FChavePrimaria.Tipo := LPropriedade.PropertyType;
        
        LNomePropriedadeChavePrimaria := LPropriedade.Name;
      end;
    end;
  end;
end;

constructor TBancoDadosUtil<T>.Create(const AConexao: String);
var
  LTipo: TRttiType;
begin
  inherited Create;

  FContexto := TRttiContext.Create;
  FColunas := TColunasBanco.Create;
  FJoins := TJoinsBanco.Create;

  LTipo := FContexto.GetType(TypeInfo(T));
  Inicializar(LTipo);

  FConexao := AConexao;
end;

destructor TBancoDadosUtil<T>.Destroy;
begin
  FContexto.Free;
  FColunas.Free;
  FJoins.Free;

  inherited;
end;

class function TBancoDadosUtil<T>.New(
  const AConexao: String): TBancoDadosUtil<T>;
begin
  Result := TBancoDadosUtil<T>.Create(AConexao);
end;

end.
