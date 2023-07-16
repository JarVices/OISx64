; windows_first_dll.asm

.code

LibMain PROC
    PUSH    rcx
    PUSH    rdx
    PUSH    r8

    CMP     rdx, 1
    JE      DLL_PROCESS_ATTACH
    CMP     rdx, 3
    JE      DLL_THREAD_DETACH
    CMP     rdx, 2
    JE      DLL_THREAD_ATTACH
    CMP     rdx, 0
    JE      DLL_PROCESS_DETACH
    JMP     _exit_ko

DLL_PROCESS_ATTACH:
    JMP     _exit_ok
DLL_THREAD_DETACH:
    JMP     _exit_ok
DLL_THREAD_ATTACH:
    JMP     _exit_ok
DLL_PROCESS_DETACH:
    JMP     _exit_ok

_exit_ok:
    POP     r8
    POP     rdx
    POP     rcx
    MOV     rax, 1
    RET

_exit_ko:
    POP     r8
    POP     rdx
    POP     rcx
    XOR     rax, rax
    RET

LibMain ENDP
End