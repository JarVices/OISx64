; windows_create_svc_64.asm

extrn ExitProcess :PROC
extrn StartServiceCtrlDispatcherA :PROC
extrn RegisterServiceCtrlHandlerA :PROC
extrn SetServiceStatus :PROC
extrn CreateEventA :PROC
extrn CloseHandle :PROC
extrn SetEvent :PROC
extrn CreateFileA :PROC

_SERVICE_STATUS STRUCT
    dwServiceType               DWORD ?
    dwCurrentState              DWORD ?
    dwControlsAccepted          DWORD ?
    dwWin32ExitCode             DWORD ?
    dwServiceSpecificExitCode   DWORD ?
    dwCheckPoint                DWORD ?
    dwWaitHint                  DWORD ?
_SERVICE_STATUS ENDS

_SERVICE_TABLE_ENTRYA STRUCT
    lpServiceName               QWORD ?
    lpServiceProc               QWORD ?
_SERVICE_TABLE_ENTRYA ENDS

.data
    appName             DB "Killian à votre service", 0

    filename            DB "C:\Users\User\Desktop\hello_world.txt", 0

    servStat            _SERVICE_STATUS <>
    servTable           _SERVICE_TABLE_ENTRYA <>

    hServStat           DQ ?
    hEvent              DQ ?


.code
Start PROC
    SUB     rsp, 28h ; shadow space

    LEA     rax, appName
    MOV     servTable.lpServiceName, rax
    LEA     rax, ServiceMain
    MOV     servTable.lpServiceProc, rax

    LEA     rcx, servTable
    CALL    StartServiceCtrlDispatcherA
    CMP     rax, 0
    JE      _exit
    CALL    ServiceMain

_exit:
    XOR     rax, rax
    MOV     rcx, rax
    CALL    ExitProcess

Start ENDP

ServiceMain PROC
    SUB     rsp, 28h ; shadow space

    LEA     rcx, appName
    LEA     rdx, ServiceControlHandler
    CALL    RegisterServiceCtrlHandlerA
    MOV     hServStat, rax
    CMP     rax, 0
    JE      _ret

    MOV     servStat.dwServiceType, 10h ; SERVICE_WIN32_OWN_PROCESS
    MOV     servStat.dwControlsAccepted, 0
    MOV     servStat.dwWin32ExitCode, 0 ; NO_ERROR
    MOV     servStat.dwServiceSpecificExitCode, 0 ; NO_ERROR
    MOV     servStat.dwCheckPoint, 0
    MOV     servStat.dwWaitHint, 0

    MOV     servStat.dwCurrentState, 2 ; SERVICE_START_PENDING
    MOV     rcx, hServStat
    LEA     rdx, servStat
    CALL    SetServiceStatus

    XOR     rcx, rcx
    XOR     rdx, rdx
    XOR     r8, r8
    XOR     r9, r9
    CALL    CreateEventA
    MOV     hEvent, rax

    ; SERVICE_ACCEPT_STOP + SERVICE_ACCEPT_SHUTDOWN
    MOV     servStat.dwControlsAccepted, 5

    MOV     servStat.dwCurrentState, 4 ; SERVICE_RUNNING
    MOV     rcx, hServStat
    LEA     rdx, servStat
    CALL    SetServiceStatus

    CALL    MyFunction

    MOV     servStat.dwCurrentState, 3 ; SERVICE_STOP_PENDING
    MOV     rcx, hServStat
    LEA     rdx, servStat
    CALL    SetServiceStatus

    MOV     rcx, hEvent
    CALL    CloseHandle
    MOV     hEvent, 0

    ; SERVICE_ACCEPT_STOP + SERVICE_ACCEPT_SHUTDOWN
    MOV     servStat.dwControlsAccepted, 5

    MOV     servStat.dwCurrentState, 1 ; SERVICE_STOPPED
    MOV     rcx, hServStat
    LEA     rdx, servStat
    CALL    SetServiceStatus

    MOV     rcx, hEvent
    CALL    CloseHandle
    MOV     hEvent, 0

_ret:
    ADD     rsp, 28h
    RET
ServiceMain ENDP

; The procedure to handle the service controls
ServiceControlHandler PROC controlcode:DWORD
    SUB     rsp, 28h ; shadow space

    CMP     controlcode, 1 ; SERVICE_CONTROL_STOP
    JE      SERVICE_CONTROL_STOP

    CMP     controlcode, 3 ; SERVICE_STOP_PENDING
    JE      SERVICE_STOP_PENDING

    JMP     _end

SERVICE_CONTROL_STOP:
    MOV     servStat.dwCurrentState, 3 ; SERVICE_STOPPED
    MOV     rcx, hServStat
    LEA     rdx, servStat
    CALL    SetServiceStatus

    MOV     rcx, hEvent
    CALL    SetEvent

    ADD     rsp, 28h
    RET

SERVICE_STOP_PENDING:
    MOV     servStat.dwCurrentState, 3 ; SERVICE_STOP_PENDING
    MOV     rcx, hServStat
    LEA     rdx, servStat
    CALL    SetServiceStatus

    MOV     rcx, hEvent
    CALL    SetEvent

    ADD     rsp, 28h
    RET

_end:
    ADD     rsp, 28h
ServiceControlHandler ENDP

MyFunction PROC
    SUB     rsp, 28h ; shadow space

    LEA     rcx, filename
    MOV     rdx, 10000000h ; GENERIC_ALL (winnt.h)
    MOV     r8, 3 ; FILE_SHARE_WRITE (2) | FILE_SHARE_READ (1)
    XOR     r9, r9
    SUB     rsp, 56 ; 3 more parameters
    MOV     rax, 2
    MOV     [rsp+32], rax ; dwCreationDisposition CREATE_ALWAYS
    MOV     rax, 80h
    MOV     [rsp+40], rax ; dwFlagsAndAttributes FILE_ATTRIBUTE_NORMAL
    XOR     rax, rax
    MOV     [rsp+48], rax ; hTemplateFile
    CALL    CreateFileA
    ADD     rsp, 56

    ADD     rsp, 28h
    RET

MyFunction ENDP
END