set PATH=C:\Progs\MinGW\bin;%PATH%
nim cpp --debugger:native --out:"output\test" test.nim
rem gdb  --fullname output\handlers.exe
pause