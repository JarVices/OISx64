; windows_hello_world_obfuscation.asm

extrn ExitProcess :PROC             ; Importe la fonction ExitProcess à partir de kernel32.dll pour terminer le processus
extrn GetProcAddress :PROC          ; Importe la fonction GetProcAddress à partir de kernel32.dll pour obtenir l'adresse d'une fonction exportée
extrn LoadLibraryA :PROC            ; Importe la fonction LoadLibraryA à partir de kernel32.dll pour charger une bibliothèque dynamique

.data                               ; Débute la section de données où les variables sont définies
    msg_enc DB 0B6h,9Bh,92h,92h,91h,0DEh,0A9h,91h,8Ch,92h,9Ah,0 ; Le message chiffré
    msg DB 50 dup (0)               ; Un tableau pour stocker le message déchiffré
    caption DB "Basic Obfuscation", 0   ; Le titre de la boîte de dialogue
    key DB 0FEh                         ; La clé de chiffrement XOR
    user32_lib DB "User32.dll", 0       ; Le nom de la bibliothèque contenant la fonction MessageBoxA
    MessageBoxA_func DB "MessageBoxA", 0 ; Le nom de la fonction à appeler

.code                            ; Débute la section de code où le code exécutable est écrit

Start PROC                       ; Déclare le début d'une procédure appelée "Start"
    SUB rsp, 28h                 ; Réserve de l'espace sur la pile pour les appels de fonction

    LEA rsi, msg_enc             ; Charge l'adresse du message chiffré
    LEA rdi, msg                 ; Charge l'adresse du tableau pour le message déchiffré
    XOR rcx, rcx                 ; Initialise le compteur à 0
while_loop:                      ; Début de la boucle pour déchiffrer le message
    MOV al, [rsi+rcx]            ; Charge le byte actuel du message chiffré
    CMP al, 0                    ; Vérifie si le byte actuel est le byte null (fin de la chaîne)
    JE message_box               ; Si c'est le cas, saute à l'étiquette "message_box"
    XOR al, key                  ; Sinon, déchiffre le byte actuel en utilisant une opération XOR avec la clé
    MOV [rdi+rcx], al            ; Stocke le byte déchiffré dans le tableau du message
    INC rcx                      ; Incrémente le compteur
    JMP while_loop               ; Répète la boucle

message_box:                     ; Étiquette pour la suite du programme après le déchiffrement
    LEA rcx, user32_lib          ; Charge l'adresse du nom de la bibliothèque "User32.dll"
    CALL LoadLibraryA            ; Charge la bibliothèque "User32.dll"

    MOV rcx, rax                 ; Met le handle de la bibliothèque chargée comme premier argument pour GetProcAddress
    LEA rdx, MessageBoxA_func    ; Charge l'adresse du nom de la fonction "MessageBoxA"
    CALL GetProcAddress          ; Obtient l'adresse de la fonction "MessageBoxA"

    XOR rcx, rcx                 ; Met le premier argument de MessageBoxA (HWND hWnd - handle de la fenêtre parente) à NULL
    LEA rdx, msg                 ; Charge l'adresse du message déchiffré dans le deuxième argument de MessageBoxA (LPCTSTR lpText)
    LEA r8, caption              ; Charge l'adresse de "caption" dans le troisième argument de MessageBoxA (LPCTSTR lpCaption)
    XOR r9, r9                   ; Met le quatrième argument de MessageBoxA (UINT uType - options de la boîte de dialogue) à 0 (MB_OK)
    CALL rax                     ; Appelle la fonction MessageBoxA pour afficher la boîte de dialogue

    XOR rcx, rcx                 ; Met le premier argument de ExitProcess (UINT uExitCode - code de sortie du processus) à 0
    CALL ExitProcess             ; Appelle la fonction ExitProcess pour terminer le processus

Start ENDP                      ; Marque la fin de la procédure "Start"

end                             ; Marque la fin du programme
