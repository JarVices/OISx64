extrn ExitProcess :PROC
extrn CreateFileA :PROC
extrn WriteFile :PROC
extrn CloseHandle :PROC

.data
    mailslotName        DB '\\.\mailslot\MonPremierMailslot', 0  ; Nom du mailslot
    testWrite           DB 'Ceci est un premier message mailslot', 0  ; Message à écrire dans le mailslot
    lenTestWrite        EQU $ - testWrite                          ; Longueur du message à écrire
    bytesWritten        DW ?                                       ; Nombre d'octets écrits
    hFile               DQ ?                                       ; Descripteur de fichier pour le mailslot

.code

Start PROC
    SUB     rsp, 28h                                               ; Espace d'ombre pour la pile

_CreateFileA:
    LEA     rcx, mailslotName                                      ; Pointeur vers le nom du mailslot
    MOV     rdx, 0C0000000h                                        ; Droits d'accès (GENERIC_READ | GENERIC_WRITE)
    XOR     r8, r8                                                 ; Sécurité du fichier (NULL)
    XOR     r9, r9                                                 ; Mode de partage (0)
    SUB     rsp, 56                                                ; Pour aligner la pile
    MOV     rax, 3                                                 ; Ouverture du fichier (OPEN_EXISTING)
    MOV     [rsp+32], rax                                          ; Stocke OPEN_EXISTING à la bonne place sur la pile pour l'appel de fonction
    XOR     rax, rax                                               ; Aucun modèle de fichier
    MOV     [rsp+40], rax                                          ; Stocke NULL à la bonne place sur la pile pour l'appel de fonction
    MOV     [rsp+48], rax                                          ; Aucun attribut d'ouverture de fichier
    CALL    CreateFileA                                            ; Ouvre le mailslot
    ADD     rsp, 56                                                ; Rétablit la pile
    MOV     hFile, rax                                             ; Enregistre le descripteur de fichier pour le mailslot

_WriteFile:
    MOV     rcx, hFile                                             ; Descripteur de fichier pour le mailslot
    LEA     rdx, testWrite                                         ; Pointeur vers le message à écrire
    MOV     r8, lenTestWrite                                       ; Nombre d'octets à écrire
    LEA     r9, bytesWritten                                       ; Pointeur vers la variable qui recevra le nombre d'octets écrits
    SUB     rsp, 40                                                ; Pour aligner la pile
    XOR     rax, rax                                               ; Aucun chevauchement
    MOV     [rsp+32], rax                                          ; Stocke NULL à la bonne place sur la pile pour l'appel de fonction
    CALL    WriteFile                                              ; Écrit dans le mailslot
    ADD     rsp, 40                                                ; Rétablit la pile

_exit:
    MOV     rcx, hFile                                             ; Descripteur de fichier pour le mailslot
    CALL    CloseHandle                                            ; Ferme le mailslot

    XOR     rcx, rcx                                               ; Code de sortie du processus
    CALL    ExitProcess                                            ; Termine le processus

Start ENDP
End
