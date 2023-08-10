; c.asm

extrn ExitProcess :PROC
extrn MessageBoxA :PROC

.data   
    szText      DB "Obfuscation - Indirect IsDebuggerPresent", 0
    szCaption   DB "Obfuscation - Indirect IsDebuggerPresent", 0

.code

Start PROC
    SUB     rsp, 28h

    MOV     rax, gs:[60h]
    MOV     al, [rax+2]
    CMP     al, 0
    JNZ     _continue
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
