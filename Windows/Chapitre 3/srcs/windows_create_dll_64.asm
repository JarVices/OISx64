; windows_create_dll_64.asm

extrn MessageBoxA :PROC

.data
    szText          DB 'My first DLL', 0
    szCaption       DB 'My first DLL', 0

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
;   CALL    _popup
    JMP     _exit_ok
DLL_THREAD_DETACH:
;   CALL    _popup
    JMP     _exit_ok
DLL_THREAD_ATTACH:
;   CALL    _popup
    JMP     _exit_ok
DLL_PROCESS_DETACH:
;   CALL    _popup
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

_popup PROC
    SUB     rsp, 28h ; shadow stack
    XOR     rcx, rcx
    LEA     rdx, szText
    LEA     r8, szCaption
    XOR     r9, r9
    CALL    MessageBoxA
    ADD     rsp, 28h
    RET
_popup ENDP
End
