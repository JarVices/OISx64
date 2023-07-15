; linux_first_step.asm

global _start 			; Définit le point d'entrée du programme

section .text 			; Débute la section du code exécutable

_start:
	PUSH	0x42 		; Empile la valeur hexadécimale 42 sur la pile
	PUSH	0x13 		; Empile la valeur hexadécimale 13 sur la pile
	PUSH	0x27 		; Empile la valeur hexadécimale 27 sur la pile
	
	POP	rax 			; Dépile une valeur (27) de la pile dans le registre rax 
	POP	rax 			; Dépile une autre valeur (13) de la pile dans le registre rax

	MOV	rax, 60 		; Définit la valeur du registre rax à 60 (correspond à SYS_exit dans le noyau Linux)
	MOV	rdi, 0 			; Définit la valeur du registre rdi à 0 (le code de sortie de l'appel système)
	SYSCALL				; Déclenche l'appel système avec les valeurs des registres définies précédemment
