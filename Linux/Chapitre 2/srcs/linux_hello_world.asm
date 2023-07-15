; linux_hello_world.asm

global _start     									; Déclare _start comme étant le point d'entrée du programme. 

section .data     									; Débute la section ".data" pour les données initialisées.
	my_string:		DB "Hello World", 0x00, 0x0A  	; Déclare un tableau de bytes pour stocker la chaîne de caractères "Hello World", suivie d'un caractère null (0x00) et d'un retour à la ligne (0x0A).
	my_string_length:	EQU $ - my_string  			; Calcule la longueur de la chaîne en soustrayant le pointeur actuel ($) de l'adresse de my_string.

section .text     									; Débute la section ".text" pour le code du programme.

_start:           									; Définit le point d'entrée du programme.
	; write()
	MOV	rax, 1  									; Définit le numéro de l'appel système pour "write" (1).
	MOV	rdi, 1  									; Définit le premier argument de "write" comme 1, qui est le descripteur de fichier pour stdout.
	MOV	rsi, my_string  							; Définit le deuxième argument de "write" comme l'adresse de my_string.
	MOV	rdx, my_string_length  						; Définit le troisième argument de "write" comme la longueur de my_string.
	SYSCALL  										; Exécute l'appel système.

	; exit()
	MOV	rax, 60  									; Définit le numéro de l'appel système pour "exit" (60).
	MOV 	rdi, 0  								; Définit le premier argument de "exit" comme 0, ce qui signifie que le programme s'est terminé avec succès.
	SYSCALL  										; Exécute l'appel système.
