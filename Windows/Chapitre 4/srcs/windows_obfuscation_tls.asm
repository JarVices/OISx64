; windows_obfuscation_tls.asm

extrn ExitProcess :PROC
extrn MessageBoxA :PROC

PUBLIC _tls_index
PUBLIC _tls_used

.data
    szText      DB "Obfuscation - SEH", 0
    szCaption   DB "Obfuscation - SEH", 0

    ; TLS structure

    IMAGE_TLS_DIRECTORY STRUCT
        StartAddressOfRawData       QWORD   ?
        EndAddressOfRawData         QWORD   ?
        AddressOfIndex              QWORD   ?
        AddressOfCallbacks          QWORD   ?
        SizeOfZeroFill              QWORD   ?
        Characteristics             QWORD   ?
    IMAGE_TLS_DIRECTORY ENDS

    _tls_index              QWORD 0
    array_tls_index         QWORD _tls_index, 0
    array_tls_functions     QWORD callback_1, callback_2, 0
    _tls_used               IMAGE_TLS_DIRECTORY <0, 0, array_tls_index, array_tls_functions, 0, 0>

.code

Start PROC
    XOR     rcx, rcx
    CALL    ExitProcess
Start ENDP

callback_1 PROC
    MOV     rbp, rsp
    SUB     rsp, 28h

    XOR     rcx, rcx
    LEA     rdx, szText
    LEA     r8, szCaption
    XOR     r9, r9
    CALL    MessageBoxA

    ADD     rsp, 28h
    MOV     rsp, rbp

    RET
callback_1 ENDP

callback_2 PROC
    XOR     rax, rax
    RET
callback_2 ENDP

End