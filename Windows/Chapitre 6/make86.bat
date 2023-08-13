@echo off

REM Définir les variables pour les chemins
set ml_path="C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Tools\MSVC\14.36.32532\bin\Hostx64\x86\ml.exe"
set kernel32_lib_path="C:\Program Files (x86)\Windows Kits\10\Lib\10.0.22000.0\um\x86\kernel32.lib"
set mincore_lib_path="C:\Program Files (x86)\Windows Kits\10\Lib\10.0.22000.0\um\x86\mincore.lib"
set ntdll_lib_path="C:\Program Files (x86)\Windows Kits\10\Lib\10.0.22000.0\um\x86\ntdll.lib"
set user32_lib_path="C:\Program Files (x86)\Windows Kits\10\Lib\10.0.22000.0\um\x86\user32.lib"

REM Définir les dossiers pour les sources, binaires et fichiers temporaires
set srcs=srcs
set binaries=binaries

REM Demander le nom du programme
set /p prog=[+] program name (without extension): 

REM Compiler et lier le programme
%ml_path% %srcs%\%prog%.asm /link /subsystem:console /defaultlib:%kernel32_lib_path% /defaultlib:%mincore_lib_path% /defaultlib:%ntdll_lib_path% /defaultlib:%user32_lib_path% /entry:Start /out:%binaries%\%prog%.exe /RELEASE

REM Supprimer les fichiers intermédiaires
del *.obj
del *.lnk

pause