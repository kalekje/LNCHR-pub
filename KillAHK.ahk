#Requires Autohotkey v2.0+

PID:=DllCall("GetCurrentProcessId")
for process in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Process where name = 'Autohotkey.exe' and processID  <> " PID )
   ProcessClose(process.ProcessId)
for process in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Process where name = 'Autohotkey64.exe' and processID  <> " PID )
   ProcessClose(process.ProcessId)
ProcessClose(PID) ; If you want to close also this script