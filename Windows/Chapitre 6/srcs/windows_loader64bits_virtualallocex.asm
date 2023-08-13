; windows_loader64bits_virtualallocex.asm

extrn VirtualAllocEx :PROC
extrn GetCurrentProcess :PROC
extrn WriteProcessMemory :PROC

.data 
    shellcode   DB 90h, 90h, 90h, 90h, 90h, 0
    hProcess    DQ ?
    baseAddr    DQ ?

.code
Start PROC
    SUB     rsp, 28h

    CALL    GetCurrentProcess
    MOV     hProcess, rax

    MOV     rcx, hProcess
    XOR     rdx, rdx
    MOV     r8, 100h
    MOV     r9, 1000h ; MEM_COMMIT
    SUB     rsp, 8
    MOV     rax, 40h ; PAGE_EXECUTE_READWRITE
    MOV     qword ptr [rsp+32], rax
    CALL    VirtualAllocEx
    ADD     rsp, 8
    MOV     baseAddr, rax

    MOV     rcx, hProcess
    MOV     rdx, baseAddr
    LEA     r8, shellcode
    MOV     r9, SIZEOF shellcode
    SUB     rsp, 40
    MOV     qword ptr [rsp+32], 0
    CALL    WriteProcessMemory
    ADD     rsp, 40

    CALL    baseAddr 

Start ENDP
END