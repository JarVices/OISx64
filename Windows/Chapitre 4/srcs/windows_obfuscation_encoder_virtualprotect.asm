; windows_obfuscation_encoder_virtualprotect.asm

extrn ExitProcess :PROC
extrn VirtualProtect :PROC

.data 
    key         DB 42h
    sizePayload DQ ?
    oldProtect  DQ ?

.code

Start PROC
    SUB     rsp, 28h

    LEA     rsi, _startPayload
    LEA     rdi, _endPayload
    SUB     rdi, rsi
    MOV     sizePayload, rdi

_VirtualProtect:
    LEA     rcx, _startPayload
    MOV     rdx, sizePayload
    MOV     r8, 40h
    LEA     r9, oldProtect
    CALL    VirtualProtect

    XOR     rcx, rcx

_startEnc:
    MOV     al, byte ptr [rsi+rcx]
    XOR     al, key
    MOV     [rsi+rcx], al
_nextEnc:
    INC     rcx
    CMP     rcx, sizePayload
    JGE     _endEnc
    JMP     _startEnc
_endEnc:

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