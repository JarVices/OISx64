; windows_loader64bits_ntwritevirtualmemory.asm

extrn VirtualAlloc :PROC
extrn GetCurrentProcess :PROC
extrn NtWriteVirtualMemory :PROC

.data
    shellcode   DB 90h, 90h, 90h, 90h, 90h, 0
    hProcess    DQ ?
    baseAddr    DQ ?

.code
Start PROC
    SUB     rsp, 28h

    XOR     rcx, rcx
    MOV     rdx, 100h
    MOV     r8, 100h ; MEM_COMMIT
    MOV     r9, 40h ; PAGE_EXECUTE_READWRITE
    CALL    VirtualAlloc
    MOV     baseAddr, rax

    CALL    GetCurrentProcess
    MOV     hProcess, rax

    MOV     rcx, hProcess
    MOV     rdx, baseAddr
    LEA     r8, shellcode
    MOV     r9, SIZEOF shellcode
    SUB     rsp, 40
    MOV     qword ptr [rsp+32], 0
    CALL    NtWriteVirtualMemory
    ADD     rsp, 40

    CALL    baseAddr

Start ENDP
END