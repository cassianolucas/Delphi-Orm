unit uBancoUtils;

interface

uses
  {$IFDEF CONDITIONALEXPRESSIONS}
    {$IF CompilerVersion >= 17.0}
      System.Generics.Collections, System.Generics.Defaults,
      System.SysUtils,
    {$ELSE}
      Generics.Defaults, SysUtils,
    {$IFEND}
  {$ENDIF}
  uBaseModel, uAtributoBancoModel, Rtti;

type
  TResultadoItemSelect = TDictionary<String, Variant>;
  TResultadoSelect = TObjectList<TResultadoItemSelect>;

  TBancoDadosUtil<T: TBaseModel, constructor> = class
    private
      FConexao: string;
      LContexto: TRttiContext;

      constructor Create(const AConexao: String);

      function BuscaTabela(ATipo: TRttiType): TTabelaBanco;

      function BuscarCampos(ATipo: TRttiType): TColunasBanco;

      function BuscarJoins(ATipo: TRttiType): TJoinsBanco;

      function ExecutaSql(const ASql: String): TResultadoSelect;
    public
      destructor Destroy; override;

      function BuscarPorId(const AId: Variant): T;

      class function New(const AConexao: String): TBancoDadosUtil<T>;
  end;

implementation

uses
  {$IFDEF CONDITIONALEXPRESSIONS}
    {$IF CompilerVersion >= 17.0}
      System.TypInfo, System.Variants,
    {$ELSE}
      TypInfo, Variants,
    {$IFEND}
  {$ENDIF}
  // externalizar após teste
  Data.SqlExpr, Data.DB,
  // fim externalização
  uExcecoesBanco;

{ TBancoDadosUtil<T> }

function TBancoDadosUtil<T>.BuscarCampos(ATipo: TRttiType): TColunasBanco;
var
  LTabela: TTabelaBanco;
  LPropriedade: TRttiProperty;
  LAtribuo: TCustomAttribute;
begin
  LTabela := BuscaTabela(ATipo);

  if not(Assigned(LTabela)) then
    raise TExcecaoTabelaNaoEncontrada.Create;

  Result := TColunasBanco.Create;

  for LPropriedade in ATipo.GetProperties do
  begin
    if (LPropriedade.Visibility < TMemberVisibility.mvPublic) then
      Continue;

    for LAtribuo in LPropriedade.GetAttributes do
    begin
      if (LAtribuo is TColunaBanco) then
        Result.Add(TColunaBanco.Create(TColunaBanco(LAtribuo).Nome, LTabela.Nome))
      else if (LAtribuo is TJoinBanco) then
        Result.AddRange(BuscarCampos(LPropriedade.PropertyType));
    end;
  end;
end;

function TBancoDadosUtil<T>.BuscarJoins(ATipo: TRttiType): TJoinsBanco;
var
  LTabela,
  LTabelaDestino: TTabelaBanco;
  LPropriedade: TRttiProperty;
  LAtribuo: TCustomAttribute;
begin
  LTabela := BuscaTabela(ATipo);

  if not(Assigned(LTabela)) then
    raise TExcecaoTabelaNaoEncontrada.Create;

  Result := TJoinsBanco.Create;

  for LPropriedade in ATipo.GetProperties do
  begin
    if (LPropriedade.Visibility < TMemberVisibility.mvPublic) then
      Continue;

    for LAtribuo in LPropriedade.GetAttributes do
    begin
      if (LAtribuo is TJoinBanco) then
      begin
        LTabelaDestino := BuscaTabela(LPropriedade.PropertyType);

        if not(Assigned(LTabelaDestino)) then
          raise TExcecaoTabelaNaoEncontrada.Create;

        Result.Add(TJoinBanco.Create(LTabela.Nome, TJoinBanco(LAtribuo).Origem,
          LTabelaDestino.Nome, TJoinBanco(LAtribuo).Destino));
      end;
    end;
  end;
end;

function TBancoDadosUtil<T>.BuscarPorId(const AId: Variant): T;
const
  SQL_BUSCAR_ID = 'select %s from %s %s where %s.id = %s';
var
  LTipo: TRttiType;
  LTabela: TTabelaBanco;
  LColunas: TColunasBanco;
  LJoins: TJoinsBanco;
  LSql: String;
  LResultados: TResultadoSelect;
  LResultado: TResultadoItemSelect;
begin
  LTipo := LContexto.GetType(TypeInfo(T));

  LTabela := BuscaTabela(LTipo);

  LColunas := BuscarCampos(LTipo);

  LJoins := BuscarJoins(LTipo);

  LSql := Format(SQL_BUSCAR_ID, [LColunas.ToString, LTabela.Nome, LJoins.ToString, LTabela.Nome, VarToStr(AId)]);

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

constructor TBancoDadosUtil<T>.Create(const AConexao: String);
begin
  inherited Create;

  LContexto := TRttiContext.Create;

  FConexao := AConexao;
end;

destructor TBancoDadosUtil<T>.Destroy;
begin
  LContexto.Free;

  inherited;
end;

class function TBancoDadosUtil<T>.New(
  const AConexao: String): TBancoDadosUtil<T>;
begin
  Result := TBancoDadosUtil<T>.Create(AConexao);
end;

end.
