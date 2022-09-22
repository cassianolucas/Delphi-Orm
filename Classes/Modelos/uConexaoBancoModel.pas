unit uConexaoBancoModel;

interface

uses
  System.Classes, Data.DB,
  uClassesBancoModel;

type
  TConexaoBancoBase = class(TDataModule)
    private
      FConexao: TCustomConnection;
    public
      property Conexao: TCustomConnection read FConexao write FConexao;

      function ExecutaSql(const ASql: TSql): TResultadoItemBanco; virtual; abstract;

      function ProcessaResultadoSimplesSql(ADataSet: TDataSet): TResultadoItemBanco; virtual; abstract;
  end;

  TConexaoBanco = class (TConexaoBancoBase)
    protected
      procedure ValidaConexao(const AConexao: String);

      procedure Inicializar; virtual; abstract;

      class function New: TConexaoBanco; virtual; abstract;
    public
      function ProcessaResultadoSimplesSql(ADataSet: TDataSet): TResultadoItemBanco; override;
  end;

implementation

uses
  System.SysUtils,
  uExcecoesBanco;

{ TConexaoBanco }

function TConexaoBanco.ProcessaResultadoSimplesSql(
  ADataSet: TDataSet): TResultadoItemBanco;
var
  LField: TField;
begin
  // filtrar por chave primaria da tabela para verificar se há mais de um registro
  // quando houver, retornar exceção

  Result := TResultadoItemBanco.Create;

  if (ADataSet.IsEmpty) then
    Exit;

  for LField in ADataSet.Fields do
    Result.Add(UpperCase(LField.FieldName), LField.Value);
end;

procedure TConexaoBanco.ValidaConexao(const AConexao: String);
begin
  if (AConexao = '') then
    raise TExcecaoBancoDadosInexistente.Create;

  if not(FileExists(AConexao)) then
    raise TExcecaoBancoDadosInexistente.Create;
end;

end.
