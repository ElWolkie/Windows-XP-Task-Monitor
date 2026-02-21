unit Main; // Define la unidad del programa

interface // Comienza la sección de la interfaz

uses
  SysUtils, // Proporciona rutinas de utilidad del sistema
  LCLIntf, LCLType, // Parte de la Capa de Compatibilidad de Lazarus (LCL)
  Variants, // Proporciona soporte para el tipo de datos Variant
  Classes, // Define clases fundamentales como TComponent y TStream
  Controls, // Define la clase base TControl para todos los controles visuales
  Forms, // Proporciona la clase TForm, que se utiliza para crear y manejar ventanas
  Dialogs, // Proporciona clases para los cuadros de diálogo comunes
  Menus, // Proporciona clases para crear y manejar menús y barras de menús
  ComCtrls, // Proporciona clases para varios controles comunes
  ExtCtrls, // Proporciona clases para controles adicionales
  Basic_Task_Manager, // Llamado de Biblioteca personalizada para manejar todo los procesos del sistema (Nombres, Rutas, ID, CPU, Memoria, Estado, Prioridad)
  Windows; // Proporciona acceso a las API de Windows

type

  { TForm2 } // Define una nueva clase TForm2

  TForm2 = class(TForm) // TForm2 es una subclase de TForm

  TaskLv: TListView; //Lista en donde se mostraran los procesos

  //Elementos del TPopupMenu ---- Ordenado de acuerdo aparezcan.
   PopupMenu1: TPopupMenu; //Menu que aparece al dar click derecho

      ListTasks1: TMenuItem; //Lista de Tareas del TpopupMenu

      N1: TMenuItem; //Separador de elementos del TpopupMenu

      EndProcess1: TMenuItem; //Finalizar proceso del TPopupMenu

      N2: TMenuItem; //Separador de elementos del TpopupMenu

      OpenApp: TMenuItem;  // Elemento del TpopupMenu, en este caso la de Abrir aplicación

      ChangePriority: TMenuItem; // Elemento del TpopupMenu, en este caso la de Cambiar Autoridad
        RealTime: TMenuItem;  // Subelementos del TpopupMenu, en este caso la de "Tiempo Real" que pertenece a Cambiar Prioridad
        Highest: TMenuItem;   // Subelementos del TpopupMenu, en este caso la de "Alta" que pertenece a Cambiar Prioridad
        AboveNormal: TMenuItem; // Subelementos del TpopupMenu, en este caso la de "Por encima de lo normal" que pertenece a Cambiar Prioridad
        Normal: TMenuItem; // Subelementos del TpopupMenu, en este caso la de "Normal" que pertenece a Cambiar Prioridad
        BelowNormal: TMenuItem; // Subelementos del TpopupMenu, en este caso la de "Por debajo de lo normal" que pertenece a Cambiar Prioridad
        Lowest: TMenuItem; // Subelementos del TpopupMenu, en este caso la de "Baja" que pertenece a Cambiar Prioridad

  //Finaliza el TPopupMenu

  N3: TMenuItem; //Separador de elementos del TpopupMenu

  Autores: TMenuItem; // Elementos del TpopupMenu, en este caso la de Autores

  OpenAppDialog: TOpenDialog; // Ventana de Dialogo que se muestra despues de abrir aplicacion, para abrir una "solo que sea (.exe)"

  Timer1: TTimer; //Temporizador para que se actualize la lista (Cada 5 segundos)

  //Se definen los procedimientos
    procedure AboveNormalClick(Sender: TObject);
    procedure AutoresClick(Sender: TObject);
    procedure BelowNormalClick(Sender: TObject);
    procedure HighestClick(Sender: TObject);
    procedure ListTasks1Click(Sender: TObject);
    procedure EndProcess1Click(Sender: TObject);
    procedure LowestClick(Sender: TObject);
    procedure NormalClick(Sender: TObject);
    procedure RealTimeClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure OpenAppClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2; // Declara una variable global Form2 de tipo TForm2

implementation  //Empieza a implementar

{$R *.lfm}  // Enlaza el archivo de formulario Lazarus (lfm) con la unidad

//Acción que realizara el OpenApp al hacerle click (dentro del TPopupMenu), este abrira la ventana para abrir aplicaciones
procedure TForm2.OpenAppClick(Sender: TObject);
var
  OpenDialog: TOpenDialog;
begin
  OpenDialog := TOpenDialog.Create(nil);
  try
    OpenDialog.Title := 'Seleccione la aplicación que desea abrir';
    OpenDialog.Filter := 'Archivos ejecutables|*.exe|Todos los archivos|*.*';
    if OpenDialog.Execute then
      OpenDocument(OpenDialog.FileName);
  finally
    OpenDialog.Free;
  end;
end;

//Acción que realizara el EndProcess al hacerle click (dentro del TPopupMenu), este finalizará los procesos
procedure TForm2.EndProcess1Click(Sender: TObject);
Var
  TmpPid:Integer;
begin
TmpPid := 0;
TmpPid := StrToInt(TaskLv.Selected.SubItems.Strings[1]);

if TmpPid <> 0 then
  begin
    if TerminateProcessbyPID(TmpPid) then
      begin
        ShowMessage('Proceso Finalizado con éxito! PID : '+IntToStr(TmpPid));
      end
    Else
      begin
        ShowMessage('Ha ocurrido un error al finalizar el proceso.');
      end;
  end;

end;

//Comienzo de los procedimientos para Cambiar las prioridades de los procesos

  //Cambiar Prioridad a "Tiempo Real"
  procedure TForm2.RealTimeClick(Sender: TObject);
  var
    TmpPid: Integer;
    ProcessHandle: THandle;
  begin
    TmpPid := StrToInt(TaskLv.Selected.SubItems.Strings[1]);
    ProcessHandle := OpenProcess(PROCESS_SET_INFORMATION, False, TmpPid);
    if ProcessHandle <> 0 then
    begin
      if SetPriorityClass(ProcessHandle, REALTIME_PRIORITY_CLASS) then
        ShowMessage('La prioridad del proceso se cambió a Tiempo Real.')
      else
        ShowMessage('Error al cambiar la prioridad del proceso.');
      CloseHandle(ProcessHandle);
    end;
  end;

  //Cambiar Prioridad a "Alto"
  procedure TForm2.HighestClick(Sender: TObject);
  var
    TmpPid: Integer;
    ProcessHandle: THandle;
  begin
    TmpPid := StrToInt(TaskLv.Selected.SubItems.Strings[1]);
    ProcessHandle := OpenProcess(PROCESS_SET_INFORMATION, False, TmpPid);
    if ProcessHandle <> 0 then
    begin
      if SetPriorityClass(ProcessHandle, HIGH_PRIORITY_CLASS) then
        ShowMessage('La prioridad del proceso se cambió a Alta.')
      else
        ShowMessage('Error al cambiar la prioridad del proceso.');
      CloseHandle(ProcessHandle);
    end;
  end;

  //Cambiar Prioridad a "Por encima de lo normal"
  procedure TForm2.AboveNormalClick(Sender: TObject);
  var
    TmpPid: Integer;
    ProcessHandle: THandle;
  begin
    TmpPid := StrToInt(TaskLv.Selected.SubItems.Strings[1]);
    ProcessHandle := OpenProcess(PROCESS_SET_INFORMATION, False, TmpPid);
    if ProcessHandle <> 0 then
    begin
      if SetPriorityClass(ProcessHandle, ABOVE_NORMAL_PRIORITY_CLASS) then
        ShowMessage('La prioridad del proceso se cambió a Por encima de lo normal.')
      else
        ShowMessage('Error al cambiar la prioridad del proceso.');
      CloseHandle(ProcessHandle);
    end;
  end;

  //Cambiar Prioridad a "Normal"
  procedure TForm2.NormalClick(Sender: TObject);
  var
    TmpPid: Integer;
    ProcessHandle: THandle;
  begin
    TmpPid := StrToInt(TaskLv.Selected.SubItems.Strings[1]);
    ProcessHandle := OpenProcess(PROCESS_SET_INFORMATION, False, TmpPid);
    if ProcessHandle <> 0 then
    begin
      if SetPriorityClass(ProcessHandle, NORMAL_PRIORITY_CLASS) then
        ShowMessage('La prioridad del proceso se cambió a Normal.')
      else
        ShowMessage('Error al cambiar la prioridad del proceso.');
      CloseHandle(ProcessHandle);
    end;
  end;

  //Cambiar Prioridad a "Por debajo de lo normal"
  procedure TForm2.BelowNormalClick(Sender: TObject);
  var
    TmpPid: Integer;
    ProcessHandle: THandle;
  begin
    TmpPid := StrToInt(TaskLv.Selected.SubItems.Strings[1]);
    ProcessHandle := OpenProcess(PROCESS_SET_INFORMATION, False, TmpPid);
    if ProcessHandle <> 0 then
    begin
      if SetPriorityClass(ProcessHandle, BELOW_NORMAL_PRIORITY_CLASS) then
        ShowMessage('La prioridad del proceso se cambió a Por debajo de lo normal.')
      else
        ShowMessage('Error al cambiar la prioridad del proceso.');
      CloseHandle(ProcessHandle);
    end;
  end;

  //Cambiar Prioridad a "Bajo"
  procedure TForm2.LowestClick(Sender: TObject);
  var
    TmpPid: Integer;
    ProcessHandle: THandle;
  begin
    TmpPid := StrToInt(TaskLv.Selected.SubItems.Strings[1]);
    ProcessHandle := OpenProcess(PROCESS_SET_INFORMATION, False, TmpPid);
    if ProcessHandle <> 0 then
    begin
      if SetPriorityClass(ProcessHandle, IDLE_PRIORITY_CLASS) then
        ShowMessage('La prioridad del proceso se cambió a Baja.')
      else
        ShowMessage('Error al cambiar la prioridad del proceso.');
      CloseHandle(ProcessHandle);
    end;
  end;

//Finaliza el procedimiento para cambiar prioridades

//Acción que realizara el ListTasks al hacerle click (dentro del TPopupMenu), este mostrará los procesos
procedure TForm2.ListTasks1Click(Sender: TObject);
begin
ListProcessToLv(TaskLv);
end;

//Acción que realizara Autores al hacerle click (dentro del TPopupMenu), este mostrara un mensaje de los Autores del Proyecto
procedure TForm2.AutoresClick(Sender: TObject);
begin
  showmessage('Todos los Derechos reservados ©                                        Emulador de Administrador de Tareas --- Diseñado por:             Edgar Bello                                                                                             Anthony Martinez                                                                                 Jesús Gonzalez                                                                                        Angel Castellanos                                                                                   Fabian Arellano'); //No encontre otra forma de bajar los nombres xD
end;

//Acción del TTimer, este es necesario para actualizar los procesos (en este caso es cada 5 Segundos)
procedure TForm2.Timer1Timer(Sender: TObject);
begin
  ListProcessToLv(TaskLv);
end;

end. // Finaliza la unidad

