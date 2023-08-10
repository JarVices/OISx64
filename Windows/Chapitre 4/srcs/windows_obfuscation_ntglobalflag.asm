; windows_obfuscation_ntglobalflag.asm

extrn ExitProcess :PROC
extrn MessageBoxA :PROC

.data
    szText      DB "Obfuscation - NtGlobalFlag", 0
    szCaption   DB "Obfuscation - NtGlobalFlag", 0

.code

Start PROC
    SUB     rsp, 28h
    MOV     rax, gs:[60h]
    MOV     al, [rax+0BCh]
    AND     al, 70h
    CMP     al, 70h
    JE      _continue
    CALL    _popup

_continue:
    XOR     rcx, rcx
    CALL    ExitProcess
Start ENDP

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

END