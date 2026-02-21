unit Basic_Task_Manager; // Define la unidad del programa, que es llamada de la unidad principal Main.

interface // Comienza la sección de la interfaz

uses  //Librerias o Bibliotecas..

  SysUtils, // Proporciona rutinas de utilidad del sistema
  LCLIntf, LCLType, // Parte de la Capa de Compatibilidad de Lazarus (LCL)
  JwaTlHelp32, // Proporciona funciones para interactuar con el Sistema de ayuda de Windows. //Librerias JEDI
  JwaPsApi, //Proporciona funciones relacionadas con la administración de procesos en Windows. //Librerias JEDI
  ComCtrls, // Proporciona clases para varios controles comunes
  Windows; // Proporciona acceso a las API de Windows

// Procedimiento para listar los procesos en un ListView
procedure ListProcessToLv(CListView:TListView);

// Función para terminar un proceso por su ID
function TerminateProcessbyPID(iPID:Integer):Boolean;

type   //CPU
  _FILETIME = record  // Define una estructura llamada _FILETIME que representa una marca de tiempo de archivo.
    dwLowDateTime: DWORD; // Representa la parte baja de la marca de tiempo, en este caso del Kernel de windows para medir el tiempo del CPU
    dwHighDateTime: DWORD; // Representa la parte alta de la marca de tiempo, en este caso del Kernel de windows para medir el tiempo del CPU
end;

  //Declaración de variables a utilizar en el apartado del CPU.
var
  CreationTime, ExitTime, KernelTime, UserTime: FILETIME;
  SysTime: TSystemTime;
  ProcessTime: DWORD;
  ProcessEntry: TProcessEntry32;
  phandle: HANDLE;


// Estructura para almacenar información sobre el uso de memoria de un proceso
type //MEMORIA
  PROCESS_MEMORY_COUNTERS = record
    cb: DWORD;
    PageFaultCount: DWORD;
    PeakWorkingSetSize: SIZE_T;
    WorkingSetSize: SIZE_T;
    QuotaPeakPagedPoolUsage: SIZE_T;
    QuotaPagedPoolUsage: SIZE_T;
    QuotaPeakNonPagedPoolUsage: SIZE_T;
    QuotaNonPagedPoolUsage: SIZE_T;
    PagefileUsage: SIZE_T;
    PeakPagefileUsage: SIZE_T;
  end;

  TProcessMemoryCounters = PROCESS_MEMORY_COUNTERS;
  PProcessMemoryCounters = ^TProcessMemoryCounters;

// Función para obtener información sobre el uso de memoria de un proceso
function GetProcessMemoryInfo(Process: THandle; ppsmemCounters: PProcessMemoryCounters; cb: DWORD): BOOL; stdcall; external 'psapi.dll';

implementation

// Implementación de la función para terminar un proceso por su ID
function TerminateProcessbyPID(iPID:Integer):Boolean;
var
  ProcessHandle:Cardinal;
begin
  Result := False;
  ProcessHandle := OpenProcess(PROCESS_TERMINATE, False, iPID);
  if ProcessHandle <> 0 then begin
    If TerminateProcess(ProcessHandle, 0) then
      Result := True;
  End;
end;

// Implementación del procedimiento y declaración de variables para listar los procesos en un ListView
procedure ListProcessToLv(CListView:TListView);
Var
  pHandle      :THandle; // Se utiliza para realizar operaciones en un proceso específico, como abrirlo o cerrarlo.

  hSnapShot     :THandle; // Se utiliza para acceder a la información de los procesos en el sistema.

  ProcessEntry  :TProcessEntry32; // Se utiliza para recopilar información detallada sobre los procesos mientras se recorre la lista de procesos en el sistema.

  ppath         :string = ''; // Se inicializa como una cadena vacía para almacenar la ruta del proceso cuando se encuentre.

  i: Integer;  // Entero que se utiliza como contador en bucles o para indexar elementos en una lista.

  found: Boolean;  // found: Es una variable booleana que se utiliza para indicar si se ha encontrado o no un proceso específico.

  CreationTime, ExitTime, KernelTime, UserTime: FILETIME; //Son estructuras FILETIME que representan diferentes tiempos asociados con un proceso.
  // Estos tiempos incluyen el momento en que se creó el proceso, el tiempo de salida, el tiempo de CPU del kernel y el tiempo de CPU del usuario.

  SysTime: TSystemTime; //Es una estructura TSystemTime que se utiliza para almacenar la hora y la fecha de un proceso en un formato legible para el usuario.

  ProcessTime: DWORD; //Es un DWORD que representa el tiempo total de CPU utilizado por un proceso, en milisegundos.

  pmc: TProcessMemoryCounters; //Es una estructura TProcessMemoryCounters que contiene información sobre el uso de memoria de un proceso.
  // Se utiliza para recopilar información sobre la cantidad de memoria que utiliza un proceso.

  ListItem: TListItem; // Es una estructura TListItem que se utiliza para representar un elemento en una lista visual, como en este caso una lista de procesos en una interfaz de usuario.

  ProcessStatus: string; // Es una cadena que representa el estado actual de un proceso, como "Ejecutándose", "Suspendido", etc.

  ProcessPriority: DWORD; //Representa la prioridad de un proceso en el sistema operativo.
// Se utiliza para determinar la prioridad de un proceso en relación con otros procesos en ejecución.


//Comienza el Begin mayor o El comienzo de los procesos.
Begin
  CListView.Clear; //Limpia el TlistView
  hSnapShot := CreateToolHelp32SnapShot(TH32CS_SNAPALL,0); // Crea una instantánea de los procesos
  ProcessEntry.dwSize := SizeOf(TProcessEntry32);
  try
    Process32First(hSnapShot, ProcessEntry); // Va al primer registro
    repeat  // Repite a través de todos los registros
      phandle := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ, False, ProcessEntry.th32ProcessID);
      SetLength(ppath, MAX_PATH);
      if (GetModuleFileNameExA(phandle, 0, PChar(ppath), MAX_PATH)) > 0 then begin;
        SetLength(ppath, length(PChar(ppath)));
      end else begin
        ppath := 'System Process [Access Denied]'; // No se puede obtener la ruta, no tiene permisos
        //Continue; //Comentar si quiero mostrar los procesos del sistema también. En mi PC si funciona Win10 64Bits
      end;

      // Obtiene los tiempos del proceso, para los estados del proceso
      if GetProcessTimes(phandle, CreationTime, ExitTime, KernelTime, UserTime) then
      begin
        // Convierte el tiempo del kernel (tiempo de CPU del sistema) a milisegundos
        FileTimeToSystemTime(KernelTime, SysTime);
        ProcessTime := (SysTime.wHour * 3600000) + (SysTime.wMinute * 60000) + (SysTime.wSecond * 1000) + SysTime.wMilliseconds;
        if (ExitTime.dwLowDateTime = 0) and (ExitTime.dwHighDateTime = 0) then
          ProcessStatus := 'En ejecución'
        else
          ProcessStatus := 'En suspensión';
      end;

      if phandle <> 0 then
        begin
          // Obtiene la información de memoria del proceso
          if GetProcessMemoryInfo(phandle, @pmc, SizeOf(pmc)) then
          begin
            // Busca un elemento existente
            for i := 0 to CListView.Items.Count - 1 do
              if CListView.Items[i].Caption = ProcessEntry.szExeFile then
              begin
                ListItem := CListView.Items[i];
                // ...
                ListItem.SubItems.Add(FloatToStrF(pmc.WorkingSetSize / 1024 / 1024, ffFixed, 8, 2) + ' MB');
                // ...
              end;

            if not Assigned(ListItem) then
            begin
              // Crea un nuevo elemento
              ListItem := CListView.Items.Add;
              // ...
              ListItem.SubItems.Add(FloatToStrF(pmc.WorkingSetSize / 1024 / 1024, ffFixed, 8, 2) + ' MB');
              // ...
            end;
          end;
        end;

      found := False;
      for i := 0 to CListView.Items.Count - 1 do
        if CListView.Items[i].Caption = ProcessEntry.szExeFile then
        begin
          found := True;
          // Actualiza el elemento existente
          CListView.Items[i].SubItems[0] := pPath;  // Ruta del proceso
          CListView.Items[i].SubItems[1] := IntToStr(ProcessEntry.th32ProcessID); // ID del proceso
          CListView.Items[i].SubItems[2] := IntToStr(ProcessTime); // Tiempo de CPU del proceso
          Break;
        end;

       if not found then
  begin
    // Añade un nuevo elemento
    with CListView.Items.Add do
    begin
      Caption := ProcessEntry.szExeFile; // Nombre del proceso
      SubItems.Add(pPath);  // Ruta del proceso
      SubItems.Add(IntToStr(ProcessEntry.th32ProcessID)); // ID del proceso
      SubItems.Add(IntToStr(ProcessTime)); // Tiempo de CPU del proceso
      SubItems.Add(FloatToStrF(pmc.WorkingSetSize / 1024 / 1024, ffFixed, 8, 2) + ' MB'); // Memoria del proceso
      SubItems.Add(ProcessStatus); // Estado del proceso
      // Añade la prioridad del proceso a la lista

  ProcessPriority := NORMAL_PRIORITY_CLASS;
  // Obtiene la prioridad del proceso
  ProcessPriority := GetPriorityClass(phandle);
      case ProcessPriority of
      IDLE_PRIORITY_CLASS:
        SubItems.Add('Baja');
      BELOW_NORMAL_PRIORITY_CLASS:
        SubItems.Add('Por debajo de lo normal');
      NORMAL_PRIORITY_CLASS:
        SubItems.Add('Normal');
      ABOVE_NORMAL_PRIORITY_CLASS:
        SubItems.Add('Por encima de lo normal');
      HIGH_PRIORITY_CLASS:
        SubItems.Add('Alta');
      REALTIME_PRIORITY_CLASS:
        SubItems.Add('Tiempo real');
    else
      SubItems.Add('Desconocida');
    end;
      ImageIndex := 0;
    end;
      end;

    until not Process32Next(hSnapShot, ProcessEntry); // Continúa hasta que no queden más
  finally
    CloseHandle(hSnapShot); // Libera la instantánea
  end;
end;
end. // Finaliza la unidad

