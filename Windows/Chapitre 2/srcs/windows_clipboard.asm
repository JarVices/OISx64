; windows_clipboard.asm

; Définition des procédures externes
extrn GetLastError :PROC            ; Procédure pour obtenir le dernier code d'erreur
extrn ExitProcess :PROC             ; Procédure pour quitter le processus
extrn OpenClipboard :PROC           ; Procédure pour ouvrir le presse-papiers
extrn GetClipboardData :PROC        ; Procédure pour obtenir des données du presse-papiers
extrn CloseClipboard :PROC          ; Procédure pour fermer le presse-papiers
extrn GlobalLock :PROC              ; Procédure pour verrouiller un segment de mémoire global
extrn GlobalUnlock :PROC            ; Procédure pour déverrouiller un segment de mémoire global
extrn MessageBoxA :PROC             ; Procédure pour créer une boîte de message

.data 
    hClipboard      DQ ?            ; Variable pour stocker le handle du presse-papiers
    pStr            db  "Inside Clipboard", 0 ; Chaîne de caractères pour le titre de la MessageBox

.code

Start PROC
    SUB     rsp, 28h                ; Création de l'espace d'ombre pour la pile

_OpenClipboard:
    XOR     rcx, rcx                ; Paramètre NULL pour OpenClipboard
    CALL    OpenClipboard           ; Ouverture du presse-papiers

_GetClipboardData:
    MOV     rcx, 1                  ; Paramètre CF_TEXT pour GetClipboardData
    CALL    GetClipboardData        ; Obtention des données du presse-papiers
    MOV     hClipboard, rax         ; Stockage du handle du presse-papiers

_GlobalLock:
    MOV     rcx, hClipboard         ; Paramètre hMem pour GlobalLock
    CALL    GlobalLock              ; Verrouillage du segment de mémoire

    XOR     rcx, rcx                ; Paramètre hWnd pour MessageBoxA (NULL pour le parent par défaut)
    MOV     rdx, rax                ; Paramètre lpText pour MessageBoxA (texte de la boîte de message)
    MOV     r8, OFFSET pStr         ; Paramètre lpCaption pour MessageBoxA (titre de la boîte de message)
    XOR     r9, r9                  ; Paramètre uType pour MessageBoxA (type de boîte de message)
    CALL    MessageBoxA             ; Création de la boîte de message

_GlobalUnlock:
    MOV     rcx, hClipboard         ; Paramètre hMem pour GlobalUnlock
    CALL    GlobalUnlock            ; Déverrouillage du segment de mémoire

_CloseClipboard:
    CALL    CloseClipboard          ; Fermeture du presse-papiers

_exit:
    XOR     rcx, rcx                ; Paramètre uExitCode pour ExitProcess
    CALL    ExitProcess             ; Fin du processus

Start ENDP
End
