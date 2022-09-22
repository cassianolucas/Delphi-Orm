unit uBancoUtils;

interface

uses
  {$IF RTLVersion > 21.0}
    System.TypInfo,
    System.Generics.Collections, System.Generics.Defaults,
    System.SysUtils,
  {$ELSE}
    TypInfo,
    Generics.Collections, Generics.Defaults, SysUtils,
  {$IFEND}
  uAtributoBancoModel,
  uConexaoBancoModel, uClassesBancoModel,
  Rtti;

type
  TBancoDadosUtil<T: TBaseModel, constructor> = class
    private
      FContexto: TRttiContext;
      FTabela: TTabelaBanco;
      FColunas: TColunasBanco;
      FJoins: TJoinsBanco;
      FChavePrimaria: TChavePrimaria;
      FColunaChavePrimaria: TColunaBanco;
      FConexao: TConexaoBanco;

      constructor Create(const AConexao: TConexaoBanco);

      procedure Inicializar(ATipo: TRttiType);

      function BuscaTabela(ATipo: TRttiType): TTabelaBanco;

      function AjustaParametro(const AParametro: Variant): String;

      function CarregaClasse(ATipo: PTypeInfo; AResultadoSql: TResultadoItemBanco): T;
    public
      destructor Destroy; override;

      function BuscarPorChavePrimaria(const AParametro: Variant): T;

      class function New(const AConexao: TConexaoBanco): TBancoDadosUtil<T>;
  end;

implementation

uses
  {$IF RTLVersion > 21.0}
    System.Variants,
  {$ELSE}
    Variants,
  {$IFEND}
  uExcecoesBanco;

{ TBancoDadosUtil<T> }

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

constructor TBancoDadosUtil<T>.Create(const AConexao: TConexaoBanco);
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
  FChavePrimaria.Free;
  FColunaChavePrimaria.Free;
  FConexao.Free;

  inherited;
end;

function TBancoDadosUtil<T>.AjustaParametro(const AParametro: Variant): String;
begin
  case FChavePrimaria.Tipo.TypeKind of
    tkUString,
    tkWChar,
    tkLString,
    tkWString,
    tkChar,
    tkString: Result := QuotedStr(VarToStr(AParametro));
    else
      Result := VarToStr(AParametro);
  end;
end;

function TBancoDadosUtil<T>.CarregaClasse(ATipo: PTypeInfo;
  AResultadoSql: TResultadoItemBanco): T;
var
  LTipoRetorno: PTypeInfo;
  LTipo: TRttiType;
  LTabela: TTabelaBanco;
  LPropriedade: TRttiProperty;
  LAtributo: TCustomAttribute;
  LValor: Variant;
begin
  Result := T.Create;

  LTipoRetorno := TypeInfo(T);

  LTipo := FContexto.GetType(LTipoRetorno.TypeData.ClassType);

  LTabela := BuscaTabela(LTipo);

  for LPropriedade in LTipo.GetProperties do
  begin
    for LAtributo in LPropriedade.GetAttributes do
    begin
      if (LAtributo is TColunaBanco) then
      begin
        AResultadoSql.TryGetValue(UpperCase(TColunaBanco(LAtributo).Nome), LValor);

        LPropriedade.SetValue(LTipo, TValue.FromVariant(LValor));
      end
      else if (LAtributo is TJoinBanco) then
      begin
        // recursivo

      end;
    end;
  end;
end;

class function TBancoDadosUtil<T>.New(
  const AConexao: TConexaoBanco): TBancoDadosUtil<T>;
begin
  Result := TBancoDadosUtil<T>.Create(AConexao);
end;

function TBancoDadosUtil<T>.BuscarPorChavePrimaria(const AParametro: Variant): T;
const
  SQL_BUSCAR_ID = 'select %s from %s %s where %s.%s = %s';
var
  LParametro: String;
  LSql: String;
  LTipo: PTypeInfo;
begin
  LParametro := AjustaParametro(AParametro);

  if (LParametro = '') then
    raise TExcecaoValorChavePrimaria.Create;

  LSql := Format(SQL_BUSCAR_ID, [FColunas.ToString, FTabela.Nome,
    FJoins.ToString, FTabela.Nome, FColunaChavePrimaria.Nome, LParametro]);

  // verificar se classe tem método create sem parametros
  // quando não houver retornar exceção

  LTipo := TypeInfo(T);

  Result := CarregaClasse(LTipo, FConexao.ExecutaSql(LSql));
end;

end.
