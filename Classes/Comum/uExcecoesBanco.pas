unit uExcecoesBanco;

interface

uses
  {$IFDEF CONDITIONALEXPRESSIONS}
    {$IF CompilerVersion >= 17.0}
      System.SysUtils;
    {$ELSE}
      SysUtils;
    {$IFEND}
  {$ENDIF}

type
  TExcecaoTabelaNaoEncontrada = class(Exception)
    public
      constructor Create;
  end;

  TExcecaoValorChavePrimaria = class(Exception)
    public constructor Create;
  end;

implementation

{ TExcecaoTabela }

constructor TExcecaoTabelaNaoEncontrada.Create;
begin
  inherited Create('Tabela n�o encontrada!');
end;

{ TExcecaoValorChavePrimaria }

constructor TExcecaoValorChavePrimaria.Create;
begin
  inherited Create('Valor de chave primaria inv�lido!');
end;

end.
