; windows_namedpipe_writer.asm

extrn ExitProcess :PROC
extrn CreateNamedPipeA :PROC
extrn ConnectNamedPipe :PROC
extrn CloseHandle :PROC
extrn WriteFile :PROC

.data 
    bytesWritten    DW ?                                ; Définit un espace pour stocker le nombre d'octets écrits par l'appel à WriteFile
    hPipe           DQ ?                                ; Définit un espace pour stocker le descripteur du pipe nommé
    pipeName        DB '\\.\Pipe\MsfMania', 0           ; Définit le nom du pipe
    testWrite       DB 'Premier test des namedPipes'    ; Définit la chaîne à écrire dans le pipe
    lenTestWrite    EQU $ - testWrite                   ; Calcule la longueur de la chaîne à écrire

.code
Start PROC
    SUB     rsp, 28h            ; shadow stack

_CreateNamedPipeA:
    LEA     rcx, pipeName       ; Charge l'adresse du nom du pipe dans rcx. rcx est le premier argument pour CreateNamedPipeA.
    MOV     rdx, 3              ; Définit le deuxième argument, PIPE_ACCESS_DUPLEX, qui indique que le pipe est en duplex complet (lecture/écriture).
    MOV     r8, 4               ; Définit le troisième argument, PIPE_TYPE_MESSAGE, qui indique que le pipe fonctionne en mode message (au lieu du mode byte stream).
    MOV     r9, 1               ; Définit le quatrième argument, qui indique le nombre maximal d'instances du pipe qui peuvent être créées.
    SUB     rsp, 64             ; Prépare la pile pour le passage de plusieurs autres paramètres à CreateNamedPipeA.
    MOV     rax, 1024           ; Définit une taille de 1024 octets pour le buffer de sortie et d'entrée.
    MOV     [rsp+32], rax       ; Paramètre de sortie (nOutBufferSize).
    MOV     [rsp+40], rax       ; Paramètre d'entrée (nInBufferSize).
    XOR     rax, rax            ; Réinitialise rax à 0.
    MOV     [rsp+48], rax       ; Paramètre du temps d'attente par défaut (nDefaultTimeOut).
    MOV     [rsp+56], rax       ; Paramètre de sécurité par défaut (lpSecurityAttributes).
    CALL    CreateNamedPipeA    ; Appelle la fonction CreateNamedPipeA avec les arguments précédemment définis.
    ADD     rsp, 64             ; Réinitialise le pointeur de la pile après l'appel à la fonction.
    MOV     hPipe, rax          ; Stocke le descripteur de pipe renvoyé par CreateNamedPipeA dans la variable hPipe.

_ConnectNamedPipe:
    MOV     rcx, hPipe          ; rcx est le premier argument pour ConnectNamedPipe. Il s'agit du descripteur du pipe créé précédemment avec CreateNamedPipeA.
    XOR     rdx, rdx            ; rdx est le deuxième argument pour ConnectNamedPipe. L'utilisation de XOR pour mettre rdx à 0 indique qu'aucun chevauchement n'est utilisé (paramètre lpOverlapped).
    CALL    ConnectNamedPipe    ; Appelle la fonction ConnectNamedPipe avec les arguments précédemment définis. Cette fonction attend qu'un client se connecte au pipe nommé.
    CMP     rax, 0              ; Compare la valeur retournée par ConnectNamedPipe (dans rax) à 0. Une valeur de 0 indique une erreur.
    JE      _exit               ; Si la valeur est 0 (c'est-à-dire si l'opération ConnectNamedPipe a échoué), saute à l'étiquette _exit.

_WriteFile:
    MOV     rcx, hPipe          ; rcx est le premier argument pour WriteFile. Il s'agit du descripteur du pipe où nous voulons écrire.
    LEA     rdx, testWrite      ; rdx est le deuxième argument pour WriteFile. Il contient l'adresse des données à écrire dans le pipe.
    MOV     r8, lenTestWrite    ; r8 est le troisième argument pour WriteFile. Il contient la longueur des données à écrire.
    LEA     r9, bytesWritten    ; r9 est le quatrième argument pour WriteFile. Il s'agit d'un pointeur vers la variable qui recevra le nombre de bytes réellement écrits.
    SUB     rsp, 40             ; Alloue de l'espace sur la pile pour la structure d'overlapping. 
    XOR     rax, rax            ; Met rax à zéro.
    MOV     [rsp+32], rax       ; Initialise la structure d'overlapping à zéro.
    CALL    WriteFile           ; Appelle la fonction WriteFile avec les arguments précédemment définis. Cette fonction écrit les données dans le pipe.
    ADD     rsp, 40             ; Restaure la pile à sa position d'origine.


_exit:
    MOV     rcx, hPipe          ; Utilise le descripteur du pipe
    CALL    CloseHandle         ; Ferme le pipe

    XOR     rcx, rcx
    CALL    ExitProcess         ; Termine le processus

Start ENDP
End