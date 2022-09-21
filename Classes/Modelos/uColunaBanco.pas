unit uColunaBanco;

interface

uses
  Rtti, System.Generics.Collections;

type
  TColuna = class
    private
      FColuna: String;
      FValor: TValue;
    public
      property Nome: String read FColuna write FColuna;
      property Valor: TValue read FValor write FValor;
  end;

  TColunas = TList<TColuna>;

implementation

end.
