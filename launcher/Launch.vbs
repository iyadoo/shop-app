Set sh = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")
d = fso.GetParentFolderName(WScript.ScriptFullName)
extra = ""
For Each a In WScript.Arguments
  If LCase(a) = "direct" Then extra = extra & " -Direct"
  If LCase(a) = "server" Then extra = extra & " -ServerOnly"
  If LCase(a) = "pos" Then extra = extra & " -Mode pos"
  If LCase(a) = "acc" Then extra = extra & " -Mode acc"
Next
sh.Run "powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File """ & d & "\Start.ps1""" & extra, 0, False
