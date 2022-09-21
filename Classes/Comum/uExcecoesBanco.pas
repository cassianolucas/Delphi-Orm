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

implementation

{ TExcecaoTabela }

constructor TExcecaoTabelaNaoEncontrada.Create;
begin
  inherited Create('Tabela não encontrada!');
end;

end.
