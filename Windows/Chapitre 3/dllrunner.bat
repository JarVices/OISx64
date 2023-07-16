@echo off

set binaries=binaries

REM Demander le nom de la DLL
set /p prog=[+] DLL name (without extension):

REM Demander le nom de la fonction
set /p func=[+] Func name:


rundll32.exe %binaries%\%prog%.dll,%func%

pause