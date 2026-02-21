program SimpleTaskManager;

uses
  Vcl.Forms,
  Main in 'Main.pas' {Form2},
  Basic_Task_Manager in 'Basic_Task_Manager.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
