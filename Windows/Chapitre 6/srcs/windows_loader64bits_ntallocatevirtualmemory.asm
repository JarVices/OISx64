; windows_loader64bits_ntallocatevirtualmemory.asm

extrn NtAllocateVirtualMemory :PROC
extrn GetCurrentProcess :PROC
extrn WriteProcessMemory :PROC

.data
    shellcode   DB 90h, 90h, 90h, 90h, 90h, 0
    hProcess    DQ ?
    baseAddr    DQ ?
    bufsize     DQ 100h

.code
Start PROC
    SUB     rsp, 28h

    CALL    GetCurrentProcess
    MOV     hProcess, rax

    MOV     rcx, hProcess
    LEA     rdx, baseAddr
    XOR     r8, r8
    LEA     r9, bufsize
    SUB     rsp, 48
    MOV     rax, 1000h ; MEM_COMMIT
    MOV     qword ptr [rsp+32], rax
    MOV     rax, 40h ; PAGE_EXECUTE_READWRITE
    MOV     qword ptr [rsp+40], rax
    CALL    NtAllocateVirtualMemory
    ADD     rsp, 48

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