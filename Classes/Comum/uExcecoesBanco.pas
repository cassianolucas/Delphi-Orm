unit uExcecoesBanco;

interface

uses
  {$IF RTLVersion > 21.0}
      System.SysUtils;
    {$ELSE}
      SysUtils;
  {$IFEND}

type
  TExcecaoTabelaNaoEncontrada = class(Exception)
    public
      constructor Create;
  end;

  TExcecaoValorChavePrimaria = class(Exception)
    public
      constructor Create;
  end;

  TExcecaoBancoDadosInexistente = class(Exception)
    public
      constructor Create;
  end;

implementation

{ TExcecaoTabela }

constructor TExcecaoTabelaNaoEncontrada.Create;
begin
  inherited Create('Tabela não encontrada!');
end;

{ TExcecaoValorChavePrimaria }

constructor TExcecaoValorChavePrimaria.Create;
begin
  inherited Create('Valor de chave primaria inválido!');
end;

{ TExcecaoBancoDadosInexistente }

constructor TExcecaoBancoDadosInexistente.Create;
begin
  inherited Create('Banco de dados não encontrado!');
end;

end.
