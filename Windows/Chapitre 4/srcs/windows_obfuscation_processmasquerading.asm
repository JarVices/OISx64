; windows_obfuscation_processmasquerading.asm

extrn ExitProcess :PROC
extrn MessageBoxA :PROC

_UNICODE_STRING STRUCT
    _Length         DW ?
    _MaximumLength  DW ?
    padding         DD 0
    _Buffer         DQ ?
_UNICODE_STRING ENDS

.data
    ; C:\Windows\System32\notepad.exe
    r   DB "C", 0, ":", 0, "\", 0, "W", 0
        DB "i", 0, "n", 0, "d", 0, "o", 0
        DB "w", 0, "s", 0, "\", 0, "S", 0
        DB "y", 0, "s", 0, "t", 0, "e", 0
        DB "m", 0, "3", 0, "2", 0, "\", 0
        DB "n", 0, "o", 0, "t", 0, "e", 0
        DB "p", 0, "a", 0, "d", 0, ".", 0
        DB "e", 0, "x", 0, "e", 0

    szText          DB "Process Masquerading", 0
    szCaption       DB "Process Masquerading", 0
    imagePathName   _UNICODE_STRING <62, 0BCh, 0, r>
    commandLine     _UNICODE_STRING <62, 0BCh, 0, r>
    windowTitle     _UNICODE_STRING <62, 0BCh, 0, r>

.code

Start PROC

    SUB     rsp, 28h

_pebAddress:
    XOR     rax, rax
    ADD     rax, 60h
    MOV     rax, gs:[rax]
    MOV     rax, [rax+20h]

_modifyImagePathName:
    MOV     rbx, rax
    ADD     rbx, 60h

    MOV     cx, imagePathName._Length
    MOV     word ptr [rbx], cx
    MOV     cx, imagePathName._MaximumLength
    MOV     word ptr [rbx+2], cx
    MOV     rcx, ImagePathName._Buffer
    MOV     [rbx+8], rcx

_modifyCommandLine:
    MOV     rbx, rax
    ADD     rbx, 70h

    MOV     cx, commandLine._Length
    MOV     word ptr [rbx], cx
    MOV     cx, commandLine._MaximumLength
    MOV     word ptr [rbx+2], cx
    MOV     rcx, commandLine._Buffer
    MOV     [rbx+8], rcx

_modifyWindowTitle:
    MOV     rbx, rax
    ADD     rbx, 0B0h

    MOV     cx, windowTitle._Length
    MOV     word ptr [rbx], cx
    MOV     cx, windowTitle._MaximumLength
    MOV     word ptr [rbx+2], cx
    MOV     rcx, windowTitle._Buffer
    MOV     [rbx+8], rcx

_messageBox:
    XOR     rcx, rcx
    LEA     rdx, szText
    LEA     r8, szCaption
    XOR     r9, r9
    CALL    MessageBoxA

_exit:
    XOR     rcx, rcx
    CALL    ExitProcess
    RET

Start ENDP

END