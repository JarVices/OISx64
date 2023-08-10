; windows_obfuscation_calculatehash.asm

extrn ExitProcess :PROC
extrn CryptAcquireContextA :PROC
extrn CryptCreateHash :PROC
extrn CryptHashData :PROC
extrn CryptGetHashParam :PROC
extrn CryptDestroyHash :PROC
extrn CryptReleaseContext :PROC

.data
    sGetProcAddress     DB "GetProcAddress", 0
    hCryptProv          DQ ?
    hMD5                DQ ?
    hashMD5             DB 16 DUP (?)
    hashSize            DD 16

.code
Start PROC
    SUB     rsp, 28h

    LEA     rcx, hCryptProv
    XOR     rdx, rdx
    XOR     r8, r8
    MOV     r9, 1
    SUB     rsp, 28h
    XOR     rax, rax
    MOV     [rsp+32], rax
    CALL    CryptAcquireContextA
    ADD     rsp, 28h

    MOV     rcx, hCryptProv
    MOV     rdx, 8003h
    XOR     r8, r8
    XOR     r9, r9
    SUB     rsp, 28h
    LEA     rax, hMD5
    MOV     qword ptr [rsp+32], rax
    CALL    CryptCreateHash
    ADD     rsp, 28h

    MOV     rcx, hMD5   
    LEA     rdx, sGetProcAddress
    MOV     r8, 14
    MOV     r9, 1
    CALL    CryptHashData

    MOV     rcx, hMD5
    MOV     rdx, 2
    LEA     r8, hashMD5
    LEA     r9, hashSize
    SUB     rsp, 28h 
    XOR     rax, rax
    MOV     [rsp+32], rax
    CALL    CryptGetHashParam
    ADD     rsp, 28h

    MOV     rcx, hMD5
    CALL    CryptDestroyHash

    MOV     rcx, hCryptProv
    XOR     rdx, rdx
    CALL    CryptReleaseContext

_exit:
    XOR     rcx, rcx
    CALL    ExitProcess

Start ENDP

END