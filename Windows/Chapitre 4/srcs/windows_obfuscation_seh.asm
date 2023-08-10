; windows_obfuscation_seh.asm

extrn ExitProcess :PROC
extrn MessageBoxA :PROC

.data 
    szText      DB "Hello SEH", 0
    szCaption   DB "Hello SEH", 0

.code

TryExcept PROC
    JMP     Exception
TryExcept ENDP

Start PROC FRAME:TryExcept
    .ENDPROLOG
    SUB     rsp, 28h

    XOR     rax, rax
    MOV     [rax], rax
_continue::
    JMP     _exit

_exit:
    XOR     rcx, rcx
    CALL    ExitProcess
    RET
Start ENDP

Exception PROC
    SUB     rsp, 28h

    XOR     rcx, rcx
    LEA     rdx, szText
    LEA     r8, szCaption
    XOR     r9, r9
    CALL    MessageBoxA

    ADD     rsp, 28h
    JMP     _continue
Exception ENDP

END