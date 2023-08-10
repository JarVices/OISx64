; windows_obfuscation_ppidspoofing.asm

extrn ExitProcess :PROC
extrn MessageBoxA :PROC
extrn OpenProcess :PROC
extrn InitializeProcThreadAttributeList :PROC
extrn VirtualAlloc :PROC
extrn UpdateProcThreadAttribute :PROC
extrn CreateProcessA :PROC

_STARTUPINFOA STRUCT
    cb              DWORD ?
    padding1        DB 4 DUP (?)
    lpReserved      QWORD ?
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
    wShowWindow     WORD  ?
    cbReserved2     WORD  ?
    padding2        DB 4 DUP (?)
    lpReserved2     QWORD ?
    hStdInput       QWORD ?
    hStdOutput      QWORD ?
    hStdError       QWORD ?
_STARTUPINFOA ENDS

_STARTUPINFOEXA STRUCT
    StartupInfo     _STARTUPINFOA <>
    lpAttributeList QWORD ?
_STARTUPINFOEXA ENDS

_PROCESS_INFORMATION STRUCT
    hProcess        QWORD ?
    hThread         QWORD ?
    dwProcessId     QWORD ?
    dwThreadId      QWORD ?
_PROCESS_INFORMATION ENDS

.data
    ALIGN 16
    startinfoex     _STARTUPINFOEXA <>
    ALIGN 16
    procinfo        _PROCESS_INFORMATION <>

    PID             DQ 1912
    hProcess        DQ ?
    attributeSize   DQ ?

    prog            DB "C:\Windows\System32\notepad.exe", 0

.code
Start PROC
    SUB     rsp, 28h

_InitializeProcThreadAttributeList:
    XOR     rcx, rcx
    MOV     rdx, 1
    XOR     r8, r8
    LEA     r9, attributeSize
    CALL    InitializeProcThreadAttributeList

_VirtualAlloc:
    XOR     rcx, rcx
    MOV     rdx, attributeSize
    MOV     r8, 1000h
    MOV     r9, 4
    CALL    VirtualAlloc

    MOV     startinfoex.lpAttributeList, rax

_InitializeProcThreadAttributeList_again:
    MOV     rcx, startinfoex.lpAttributeList
    XOR     rdx, rdx
    INC     rdx
    XOR     r8, r8
    LEA     r9, attributeSize
    CALL    InitializeProcThreadAttributeList

_OpenProcess:
    MOV     rcx, 80h
    XOR     rdx, rdx
    MOV     r8, PID
    CALL    OpenProcess
    CMP     rax, 0
    JZ      _exit
    MOV     hProcess, rax

_UpdateProcThreadAttribute:
    MOV     rcx, startinfoex.lpAttributeList
    XOR     rdx, rdx
    MOV     r8, 20000h
    LEA     r9, hProcess
    SUB     rsp, 38h
    MOV     rax, sizeof hProcess
    MOV     [rsp+32], rax
    XOR     rax, rax
    MOV     [rsp+40], rax
    MOV     [rsp+48], rax
    CALL    UpdateProcThreadAttribute
    ADD     rsp, 38h

_CreateProcessA:
    XOR     rcx, rcx
    LEA     rdx, prog
    XOR     r8, r8
    XOR     r9, r9
    SUB     rsp, 50h
    XOR     rax, rax
    MOV     [rsp+32], rax
    MOV     rax, 80000h
    MOV     [rsp+40], rax
    XOR     rax, rax
    MOV     [rsp+48], rax
    MOV     [rsp+56], rax
    LEA     rax, startinfoex
    MOV     [rsp+64], rax
    LEA     rax, procinfo
    MOV     [rsp+72], rax
    CALL    CreateProcessA
    ADD     rsp, 50h

_exit:
    XOR     rcx, rcx
    CALL    ExitProcess
    RET

Start ENDP

END