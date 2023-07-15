; windows_hello_world.asm

extrn ExitProcess :PROC     ; Importe la fonction ExitProcess à partir de kernel32.dll pour terminer le processus
extrn MessageBoxA :PROC     ; Importe la fonction MessageBoxA à partir de user32.dll pour afficher une boîte de dialogue

.data                       ; Débute la section de données où les variables sont définies
    caption DB "Hello", 0   ; Définit une chaîne null "Hello" et étiquette cette chaîne comme "caption"
    msg     DB "World", 0   ; Définit une autre chaîne null "World" étiquette cette chaîne comme "msg"

.code                       ; Débute la section de code où le code exécutable est écrit

Start PROC                  ; Déclare le début d'une procédure appelée "Start"
    SUB     rsp, 28h        ; Réserve de l'espace sur la pile pour les appels de fonction

    XOR     rcx, rcx        ; Met le premier argument de MessageBoxA (HWND hWnd - handle de la fenêtre parente) à NULL
    LEA     rdx, msg        ; Charge l'adresse de "msg" dans le deuxième argument de MessageBoxA (LPCTSTR lpText - le message à afficher)
    LEA     r8, caption     ; Charge l'adresse de "caption" dans le troisième argument de MessageBoxA (LPCTSTR lpCaption - le titre de la boîte de dialogue)
    XOR     r9, r9          ; Met le quatrième argument de MessageBoxA (UINT uType - options de la boîte de dialogue) à 0 (MB_OK)
    CALL    MessageBoxA     ; Appelle la fonction MessageBoxA pour afficher la boîte de dialogue

    XOR     rcx, rcx        ; Met le premier argument de ExitProcess (UINT uExitCode - code de sortie du processus) à 0
    CALL    ExitProcess     ; Appelle la fonction ExitProcess pour terminer le processus

Start ENDP                  ; Marque la fin de la procédure "Start"

end                         ; Marque la fin du programme
