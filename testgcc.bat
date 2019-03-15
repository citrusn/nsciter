set PATH=C:\Progs\MinGW\bin;%PATH%
nim cpp --debugger:native ouput\handlers.nim
gdb  --fullname output\handlers.exe
pause