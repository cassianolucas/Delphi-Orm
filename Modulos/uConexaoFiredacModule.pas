unit uConexaoFiredacModule;

interface

uses
  uClassesBancoModel, uConexaoBancoModel,
  System.SysUtils, System.Classes,
  FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Comp.Client, Data.DB, FireDAC.Comp.DataSet, FireDAC.Phys.MSAcc,
  FireDAC.Phys.MSAccDef, FireDAC.Phys.IB, FireDAC.Phys.IBDef,
  FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteWrapper.Stat;

type
  TDmConexaoFiredac = class (TConexaoBanco)
    FDConnection: TFDConnection;
    FDQuery: TFDQuery;
    FDTransaction: TFDTransaction;
  protected
    procedure Inicializar; override;
  public
    constructor Create(AComponent: TComponent); override;

    function ExecutaSql(const ASql: TSql): TResultadoItemBanco; override;
  published
    class function New: TConexaoBanco; override;
  end;


implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

{ TDmConexaoFiredac }

constructor TDmConexaoFiredac.Create(AComponent: TComponent);
begin
  inherited Create(nil);

  Inicializar;
end;

function TDmConexaoFiredac.ExecutaSql(const ASql: TSql): TResultadoItemBanco;
begin
  FDQuery.SQL.Text := ASql;
  FDQuery.Active := True;
  try
    Result := ProcessaResultadoSimplesSql(FDQuery);
  finally
    FDQuery.Active := False;
  end;
end;

procedure TDmConexaoFiredac.Inicializar;
begin
  inherited;

  ValidaConexao(FDConnection.Params.Database);
end;

class function TDmConexaoFiredac.New: TConexaoBanco;
begin
  Result := Self.Create(nil);
end;

end.
