; msgbox.asm

extrn ExitProcess :PROC
extrn MessageBoxA :PROC

.data 
    szText      DB "Hello IAT", 0
    szCaption   DB "Hello IAT", 0

.code

Start PROC
    SUB     rsp, 28h

    XOR     rcx, rcx
    LEA     rdx, szText
    LEA     r8, szText
    XOR     r9, r9
    CALL    MessageBoxA

_exit:
    XOR     rcx, rcx
    CALL    ExitProcess
    RET

Start ENDP
END