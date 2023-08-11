; windows_injection_setwindowshookex.asm

extrn ExitProcess :PROC
extrn LoadLibraryA :PROC
extrn GetProcAddress :PROC
extrn CreateToolhelp32Snapshot :PROC
extrn Thread32First :PROC
extrn Thread32Next :PROC
extrn Sleep :PROC
extrn SetWindowsHookExA :PROC
extrn UnhookWindowsHookEx :PROC

_THREADENTRY32 STRUCT
    dwSize              DD ?
    cntUsage            DD ?
    th32ThreadID        DD ?
    th32OwnerProcessID  DD ?
    tpBasePri           DD ?
    tpDeltaPri          DD ?
    dwFlags             DD ?
_THREADENTRY32 ENDS

.data   
    dllPath             DB "C:\Users\User\Desktop\windows_create_dll_64.dll"
    myFunc              DB "_popup", 0
    PID                 DQ 9272

    te32                _THREADENTRY32 <>
    te32size            DD SIZEOF te32
    hDll                DQ ?
    hFunc               DQ ?
    hSnapshot           DQ ?
    hHook               DQ ?

.code
Start PROC
    SUB     rsp, 28h

    ; LoadLibraryA(dllPath)
    LEA     rcx, dllPath
    CALL    LoadLibraryA
    MOV     hDll, rax

    ; GetProcAddress(myFunc, hDll)
    MOV     rcx, hDll
    LEA     rdx, myFunc
    CALL    GetProcAddress
    MOV     hFunc, rax

    ; Snapshot of process to get threads
    MOV     rcx, 4
    MOV     rdx, PID
    CALL    CreateToolhelp32Snapshot
    MOV     hSnapshot, rax

    ; Get the first thread in the snapshot
    MOV     rcx, hSnapshot
    LEA     rdx, te32
    MOV     eax, te32size
    MOV     te32.dwSize, eax
    CALL    Thread32First

_loop_to_find_thread:
    MOV     rbx, PID
    CMP     te32.th32OwnerProcessID, ebx
    JZ      _thread_found
    MOV     rcx, hSnapshot
    LEA     rdx, te32
    MOV     eax, te32size
    MOV     te32.dwSize, eax
    CALL    Thread32Next
    JMP     _loop_to_find_thread

_thread_found:
    MOV     rcx, 2
    MOV     rdx, hFunc
    MOV     r8, hDll
    XOR     rax, rax
    MOV     eax, te32.th32ThreadID
    MOV     r9, rax
    CALL    SetWindowsHookExA
    MOV     hHook, rax
    MOV     rcx, 2710h
    CALL    Sleep
    MOV     rcx, hHook
    CALL    UnhookWindowsHookEx

_exit:
    XOR     rcx, rcx
    CALL    ExitProcess

Start ENDP
End
