program picpixel;

uses
  Vcl.Forms,
  uFrmPic in 'Source\uFrmPic.pas' {FrmPic};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmPic, FrmPic);
  Application.Run;
end.
