unit FrmPrincipal;

interface

uses
  {$IF RTLVersion > 21.0}
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.Generics.Collections,
    Vcl.StdCtrls, FireDAC.Stan.Intf,
    FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
    FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
    Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, Data.FMTBcd, Data.SqlExpr,
  {$ELSE}
    Windows, Messages, SysUtils, Variants, Classes, Graphics,
    Controls, Forms, Dialogs, Generics.Collections,
    StdCtrls,
    DB, FMTBcd, WideStrings, SqlExpr,
  {$IFEND}
  uClassesBancoModel,
  uAtributoBancoModel;

type
  TForm1 = class(TForm)
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  [TTabelaBanco('Employees')]
  TCliente = class(TBaseModel)
  private
    FEmployeId: Integer;
    FFirstName: String;
  public
    [TChavePrimaria('pk_id'), TColunaBanco('EmployeeID')]
    property EmployeId: Integer read FEmployeId write FEmployeId;

    [TColunaBanco('FirstName')]
    property FirstName: String read FFirstName write FFirstName;
  end;

  TPedidoItem = class(TBaseModel)
    private
    public
  end;

  TPedidoItens = class(TList<TPedidoItem>);

  [TTabelaBanco('Orders')]
  TPedido = class(TBaseModel)
  private
    FOrderId: Integer;
    FShipName: String;
    FCliente: TCliente;
  public
    constructor Create;

    destructor Destroy; override;

    [TChavePrimaria('pk_id'), TColunaBanco('OrderID')]
    property OrderId: Integer read FOrderId write FOrderId;

    [TColunaBanco('ShipName')]
    property ShipName: String read FShipName write FShipName;

    [TJoinBanco('EmployeeID', 'EmployeeID')]
    property Cliente: TCliente read FCliente write FCliente;
  end;

var
  Form1: TForm1;

implementation

uses
  uBancoUtils, uConexaoFiredacModule;

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
var
  LPedido: TPedido;
begin
  LPedido := TBancoDadosUtil<TPedido>.New(TDmConexaoFiredac.New).BuscarPorChavePrimaria(10248);

  ShowMessage(IntToStr(LPedido.OrderId));
end;

{ TPedido }

constructor TPedido.Create;
begin
  FCliente := TCliente.Create;
//  Itens := TPedidoItens.Create;
end;

destructor TPedido.Destroy;
begin
  FCliente.Free;
//  Itens.Free;

  inherited;
end;

end.
