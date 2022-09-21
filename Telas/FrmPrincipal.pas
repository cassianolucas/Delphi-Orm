unit FrmPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.Generics.Collections,
  uAtributoBancoModel, Vcl.StdCtrls, uBaseModel, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, Data.FMTBcd, Data.SqlExpr;

type
  TForm1 = class(TForm)
    Button1: TButton;
    SQLQuery: TSQLQuery;
    SQLConnection: TSQLConnection;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  [TTabelaBanco('cliente')]
  TCliente = class(TBaseModel)
    private
      FCodigo: String;
      FNome: String;
    public
      [TColunaBanco('codigo')]
      property Codigo: String read FCodigo write FCodigo;

      [TColunaBanco('nome')]
      property Nome: String read FNome write FNome;
  end;

  TPedidoItem = class(TBaseModel)
    private
    public
  end;

  TPedidoItens = class(TList<TPedidoItem>);

  [TTabelaBanco('pedido')]
  TPedido = class(TBaseModel)
    private
      FId: Int64;
      FCodigo: String;
      FCliente: TCliente;
      FItens: TPedidoItens;
    public
      constructor Create;

      destructor Destroy; override;

      [TChavePrimaria('pk_id'), TColunaBanco('id')]
      property Id: Int64 read FId write FId;

      [TColunaBanco('codigo')]
      property Codigo: String read FCodigo write FCodigo;

      [TJoinBanco('id', 'idcliente')]
      property Cliente: TCliente read FCliente write FCliente;

      property Itens: TPedidoItens read FItens write FItens;

  end;

var
  Form1: TForm1;

implementation

uses
  uBancoUtils;

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
begin
  TBancoDadosUtil<TPedido>.New('').BuscarPorChavePrimaria(1);
end;

{ TPedido }

constructor TPedido.Create;
begin
  FCliente := TCliente.Create;
  Itens := TPedidoItens.Create;
end;

destructor TPedido.Destroy;
begin
  FCliente.Free;
  Itens.Free;

  inherited;
end;

end.
