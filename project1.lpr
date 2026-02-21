program project1;  // Este es el nombre del programa.

uses
  Forms, tachartlazaruspkg, Interfaces,  // Importa los módulos necesarios para el programa.
  Unit1 in 'Main.pas' {Form2};  // Importa el formulario Form2 desde el archivo Main.pas.

{$R *.res}  // Incluye recursos binarios en el proyecto.

begin
  RequireDerivedFormResource:=True;  // Requiere recursos adicionales para los formularios derivados.
  Application.Scaled:=True;  // Escala automáticamente la IU según la configuración del sistema.
  Application.Initialize;  // Inicializa la aplicación.
  Application.CreateForm(TForm2, Form2);  // Crea una instancia del formulario Form2.
  Application.Run;  // Ejecuta la aplicación.
end.  // Fin del programa.


