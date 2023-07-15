; windows_mailslots_reader.asm

extrn ExitProcess :PROC
extrn CreateMailslotA :PROC
extrn ReadFile :PROC
extrn CloseHandle :PROC

.data 
    mailslotName        DB '\\.\mailslot\MonPremierMailslot', 0     ; Nom du mailslot à créer
    hMailslot           DQ ?                                        ; Handle pour le mailslot
    buffer              DB 256 dup (?)                              ; Buffer pour lire les données du mailslot
    bytesRead           DW ?                                        ; Variable pour stocker le nombre d'octets lus

.code
Start PROC
    SUB     rsp, 28h                                                ; Espace d'ombre de la pile

_CreateMailslotA:
    LEA     rcx, mailslotName                                       ; Pointeur vers le nom du mailslot
    XOR     rdx, rdx                                                ; Message maximum (l) taille: aucun maximum
    XOR     r8, r8                                                  ; Lapse de temps d'attente du mailslot: aucun lapse de temps
    DEC     r8                                                      ; Rendre r8 égal à -1
    XOR     r9, r9                                                  ; Aucune sécurité
    CALL    CreateMailslotA                                         ; Créer le mailslot
    MOV     hMailslot, rax                                          ; Enregistrer le handle du mailslot

_ReadFile:
    MOV     rcx, hMailslot                                          ; Handle du fichier
    LEA     rdx, buffer                                             ; Buffer pour stocker les données lues
    MOV     r8, sizeof buffer                                       ; Nombre d'octets à lire
    LEA     r9, bytesRead                                           ; Nombre d'octets effectivement lus
    SUB     rsp, 40                                                 ; Réserver de l'espace pour lpOverlapped (non utilisé ici, donc juste pour l'alignement de la pile)
    XOR     rax, rax                                                ; lpOverlapped est NULL
    MOV     [rsp+32], rax                                           ; Écrire NULL dans la pile pour lpOverlapped
    CALL    ReadFile                                                ; Lire le fichier
    ADD     rsp, 40                                                 ; Restaurer le pointeur de pile

_exit:
    MOV     rcx, hMailslot                                          ; Handle du mailslot
    CALL    CloseHandle                                             ; Fermer le handle du mailslot

    XOR     rcx, rcx                                                ; Exit code
    CALL    ExitProcess                                             ; Terminer le processus

Start ENDP
End
