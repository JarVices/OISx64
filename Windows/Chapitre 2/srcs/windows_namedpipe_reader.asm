; windows_namedpipe_reader.asm

extrn ExitProcess :PROC
extrn WaitNamedPipeA :PROC
extrn CreateFileA :PROC
extrn ReadFile :PROC
extrn CloseHandle :PROC

.data
    pipeName        DB '\\.\Pipe\MsfMania', 0   ; Le nom du pipe
    hPipe           DQ ?                        ; Le handle du pipe
    buffer          DB 256 DUP (?)              ; Le tampon de lecture
    bytesRead       DW ?                        ; Le nombre d'octets lus

.code
Start PROC
    SUB     rsp, 28h ; shadow stack

_WaitNamedPipeA:
    LEA     rcx, pipeName                       ; Met l'adresse du nom du pipe dans rcx
    MOV     rdx, 0FFFFh                         ; Met le temps d'attente à l'infini dans rdx
    CALL    WaitNamedPipeA                      ; Attend que le pipe soit disponible

_CreateFileA:
    LEA     rcx, pipeName                       ; Met l'adresse du nom du pipe dans rcx
    MOV     rdx, 0C0000000h                     ; Donne les droits de lecture et d'écriture
    XOR     r8, r8                              ; Null ou 0 pour le troisième paramètre (lpSecurityAttributes)
    XOR     r9, r9                              ; Null ou 0 pour le quatrième paramètre (dwCreationDisposition)
    SUB     rsp, 56                             ; Réserve de l'espace sur la pile pour des paramètres supplémentaires
    MOV     rax, 3                              ; Mode OPEN_EXISTING pour le cinquième paramètre (dwCreationDisposition)
    MOV     [rsp+32], rax                       ; Ouvre un fichier existant
    XOR     rax, rax                            ; Null ou 0 pour le sixième paramètre (dwFlagsAndAttributes) et le septième paramètre (hTemplateFile)
    MOV     [rsp+40], rax                       ; Place le sixième paramètre sur la pile
    MOV     [rsp+48], rax                       ; Place le septième paramètre sur la pile
    CALL    CreateFileA                         ; Ouvre le pipe
    ADD     rsp, 56                             ; Restaure le pointeur de pile
    MOV     hPipe, rax                          ; Stocke le handle du pipe

_ReadFile:
    MOV     rcx, hPipe                          ; Met le handle du pipe dans rcx
    LEA     rdx, buffer                         ; Met l'adresse du tampon dans rdx
    MOV     r8, sizeof buffer                   ; Met la taille du tampon dans r8
    LEA     r9, bytesRead                       ; Met l'adresse du compteur d'octets lus dans r9
    SUB     rsp, 40                             ; Réserve 40 octets sur la pile pour stocker les données temporaires.
    XOR     rax, rax                            ; Réinitialise le registre rax à 0.
    MOV     [rsp+32], rax                       ; Met 0 dans la mémoire à l'adresse pointée par (rsp+32), ce qui efface les 8 derniers octets des 40 octets réservés précédemment sur la pile.
    CALL    ReadFile                            ; Lit le pipe
    ADD     rsp, 40                             ; Restaure le pointeur de pile à sa position d'origine

_exit:
    MOV     rcx, hPipe                          ; Met le handle du pipe dans rcx
    CALL    CloseHandle                         ; Ferme le handle du pipe

    XOR     rcx, rcx
    CALL    ExitProcess                         ; Termine le processus

Start ENDP
End
