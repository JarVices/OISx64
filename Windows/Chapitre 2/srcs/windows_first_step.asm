; windows_first_stem.asm

extrn ExitProcess :PROC     ; Importe la fonction ExitProcess du fichier externe de 
                            ; la DLL du noyau de Windows (kernel32.dll)

.code                       ; Débute la section du code exécutable

Start PROC                  ; Débute la procédure 'Start'
    MOV     rax, 1          ; Charge le registre rax avec la valeur 1
    ROR     rax, 4          ; Effectue une rotation à droite du contenu de rax par 4 bits
    ROL     rax, 8          ; Effectue une rotation à gauche du contenu de rax par 8 bits
    
    XOR     rax, rax        ; Effectue un XOR bit à bit entre rax et lui-même, ce qui met rax à zéro
    MOV     rcx, rax        ; Copie la valeur de rax (qui est zéro) dans rcx
    CALL    ExitProcess     ; Appelle la fonction ExitProcess, avec rcx comme argument (c'est le code de sortie du programme)

Start ENDP                  ; Termine la procédure 'Start'

end                         ; Termine le programme