program Orm;

uses
  {$IF RTLVersion > 21.0}
    Vcl.Forms,
  {$ELSE}
    Forms,
  {$IFEND}
  FrmPrincipal in '..\Telas\FrmPrincipal.pas' {Form1},
  uAtributoBancoModel in '..\Classes\Modelos\uAtributoBancoModel.pas',
  uBancoUtils in '..\Classes\Utils\uBancoUtils.pas',
  uBaseModel in '..\Classes\Modelos\uBaseModel.pas',
  uClassesBancoModel in '..\Classes\Modelos\uClassesBancoModel.pas',
  uExcecoesBanco in '..\Classes\Comum\uExcecoesBanco.pas';  

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
