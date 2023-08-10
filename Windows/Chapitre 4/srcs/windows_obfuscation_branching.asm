; windows_obfuscation_branching.asm

extrn ExitProcess :PROC
extrn MessageBoxA :PROC

.data
    szText      DB "Obfuscation - branching", 0
    szCaption   DB "Obfuscation - branching", 0

.code

Start PROC
    SUB     rsp, 28h ; shadow space
    CALL    _get_rip   
    POP     rbx
    ADD     rbx, 8
    JMP     rbx

    DB      0E8h
    LEA     rdx, _popup
    CALL    rdx

    XOR     rcx, rcx
    CALL    ExitProcess
START ENDP

_popup PROC
    MOV     rbp, rsp
    SUB     rsp, 28h

    XOR     rcx, rcx
    LEA     rdx, szText
    LEA     r8, szCaption
    XOR     r9, r9
    CALL    MessageBoxA

    ADD     rsp, 28h
    MOV     rsp, rbp

    ret
_popup ENDP

_get_rip PROC
    PUSH    [rsp]
    ret
_get_rip ENDP

End