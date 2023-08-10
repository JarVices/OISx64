; windows_obfuscation_findfunctionaddress.asm

extrn ExitProcess :PROC

.data
    sGetProcAddress         DB "GetProcAddress", 0
    sLoadLibraryA           DB "LoadLibraryA", 0
    sizeGetProcAddress      DQ 14
    sizeLoadLibraryA        DQ 12
    pGetProcAddress         DQ ?
    pLoadLibraryA           DQ ?
    numberOfNames           DQ ?
    pKernelBase             DQ ?
    pAddressOfNames         DQ ?
    pAddressOfFuncs         DQ ?
    funcName                DQ ?
    funcAddress             DQ ?

.code

Start PROC
    SUB     rsp, 28h

    LEA     rdi, sGetProcAddress
    MOV     r15, sizeGetProcAddress
    CALL    FindAddress
    MOV     pGetProcAddress, rax

    LEA     rdi, sLoadLibraryA
    MOV     r15, sizeLoadLibraryA
    CALL    FindAddress
    MOV     pLoadLibraryA, rax

_exit:
    XOR     rcx, rcx
    CALL    ExitProcess
    RET

Start ENDP

FindAddress PROC
    XOR     r10, r10
    XOR     r11, r11
    XOR     r12, r12
    XOR     r13, r13
    XOR     r14, r14

_findKernelbase:
    XOR     rax, rax
    ADD     rax, 60h
    MOV     rax, gs:[rax]

    MOV     rax, [rax+18h]
    MOV     rbx, [rax+30h]
    MOV     rbx, [rbx]
    MOV     r10, [rbx+10h]
    MOV     pKernelBase, r10

_findExportDirectoryRVAKernelBase:
    MOV     r10, pKernelBase
    XOR     rbx, rbx
    MOV     ebx, dword ptr [r10+03Ch]
    XOR     rdx, rdx
    MOV     edx, dword ptr [r10+rbx+88h]
    ADD     rdx, r10

_findAddressOfNames:
    XOR     r11, r11
    MOV     r11d, dword ptr [rdx+20h]
    ADD     r11, r10
    MOV     pAddressOfNames, r11

_findNumberOfNames:
    XOR     r12, r12
    MOV     r12d, dword ptr [rdx+18h]
    MOV     numberOfNames, r12

_findAddressOfFuncs:
    XOR     r13, r13
    MOV     r13d, dword ptr [rdx+1Ch]
    ADD     r13, 10
    MOV     pAddressOfFuncs, r13

    MOV     r12, numberOfNames
    XOR     rcx, rcx

_findFunctionsName:
    MOV     rax, pAddressOfNames
    MOV     r14d, dword ptr [rax+rcx*4]
    ADD     r14, r10
    MOV     funcName, r14
    MOV     rsi, funcName

    PUSH    rcx
    XOR     rcx, rcx

_functionComparaison:
    MOV     al, [rsi+rcx]
    MOV     ah, [rdi+rcx]
    CMP     al, ah
    JNE     _endFunctionComparaison
    CMP     rcx, r15
    JE      _functionFound

_nextFunctionComparaison:
    INC     rcx
    JMP     _functionComparaison

_endFunctionComparaison:
    POP     rcx
    JNZ     _nextFindFunctionsName

_functionFound:
    POP     rcx
    INC     rcx
    XOR     r14, r14
    MOV     rax, pAddressOfFuncs
    MOV     r14d, dword ptr [rax+rcx*4]
    ADD     r14, r10
    MOV     funcAddress, r14
    MOV     rax, funcAddress
    JMP     _endFindFunctionsName

_nextFindFunctionsName:
    XOR     rax, rax
    CMP     rcx, r12
    JE      _endFindFunctionsName
    INC     rcx
    JMP     _findFunctionsName

_endFindFunctionsName:
    RET
FindAddress ENDP

END
