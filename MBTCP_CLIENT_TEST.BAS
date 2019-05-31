
' Notes
' Assumes ModbusTCP client handles are 0 ..9


' Program Constants
slt = -1

max_num_mb_clients = 10

'Program Data
DIM count_test_err AS INTEGER
DIM count_cmd_err AS INTEGER
DIM count_test AS INTEGER
DIM vr_index AS INTEGER
DIM vr_handle AS INTEGER
DIM test_fail AS BOOLEAN

DIM i AS INTEGER
DIM j AS INTEGER
DIM k AS INTEGER
DIM data_type AS INTEGER = 16
DIM mb_cmd_error AS INTEGER ' Handle of cnx which failed modbus command call.
DIM num_servers AS INTEGER = 0
DIM temp_handle AS INTEGER(2)
DIM client_handle AS INTEGER(10)
DIM test_err_code AS INTEGER
DIM error_code AS INTEGER(2)
DIM num_test_count AS INTEGER

' Least significant byte of IP address of servers
' 192.168.0.121 = MC664, 192.168.0.122 = F6Nano
' First index contains used length of array.
DIM server_ip_addr AS INTEGER(10)
server_ip_addr(0) = 2
server_ip_addr(1) = 121
server_ip_addr(2) = 122

DIM vr_src AS INTEGER = 100
DIM vr_dst AS INTEGER = 200
DIM num_regs AS INTEGER = 10


count_test_err = 0
count_cmd_err = 0
count_test = 0

vr_handle = 100 'Note avoid register addresses used in modbus function calls.
vr_index = 101

test_fail = FALSE


PRINT#comms, "Test Running"

'Ensure startup has been run
IF NOT(startup_completed) THEN
    PRINT#comms,"Error: 'run startup'"
    STOP
ENDIF


'Initialise class data
mbtcp_ctor()

'set message level
mbtcp_set_msg_level(msg_errors OR msg_warnings OR msg_info)

GOSUB init
'GOSUB test_open_close

num_test_count = 100000000
GOSUB test_run_2_clients


PRINT#comms, "Test Run completed, test count",count_test[0]
PRINT#comms,"test errs:",count_test_err[0],"cmd errs:",count_cmd_err[0]

STOP


' ******************************************************************************
' Test Handlers

' ******************************************************************************
'
test_open_close:

FOR i = 0 TO 100

    'Greater reliablity if pause before re-open connection.
    WA(10)

    'open connection
    IF NOT MODBUS(0,slt,192,168,0,ip_lsb_s1,502,vr_handle) THEN
        PRINT #comms,"Error: Failed to open connection"
        count_test_err = count_test_err + 1
        test_fail = TRUE
    ELSE
        'Check connection open
        IF NOT MODBUS(2,slt,VR(vr_handle),vr_index) THEN
            PRINT #comms,"Error: Failed to execute modbus check status command."
            count_cmd_err = count_cmd_err + 1
            test_fail = TRUE
        ELSEIF VR(vr_index) <> 1 THEN
            PRINT #comms,"Error: Port not open."
            count_test_err = count_test_err + 1
            test_fail = TRUE
        ENDIF

        IF ( NOT test_fail ) THEN
            'close connection open
            IF NOT MODBUS(1,slt,VR(vr_handle)) THEN
                PRINT #comms,"Error: Failed to close connection."
                count_cmd_err = count_cmd_err + 1
                test_fail = TRUE
            ENDIF

            'Check connection closed
            IF NOT test_fail THEN
                IF NOT MODBUS(2,slt,VR(vr_handle),vr_index) THEN
                    PRINT #comms,"Error: Failed to execute modbus check status command."
                    count_cmd_err = count_cmd_err + 1
                    test_fail = TRUE
                ELSEIF VR(vr_index) <> 0 THEN
                    PRINT #comms,"Error: Port not closed."
                    count_test_err = count_test_err + 1
                    test_fail = TRUE
                ENDIF
            ENDIF
        ENDIF
    ENDIF

    count_test = count_test + 1
    IF test_fail THEN EXIT_LOOP

NEXT i

PRINT#comms, "Test: open and close connection. Test count",count_test[0]
PRINT#comms,"test errs:",count_test_err[0],"cmd errs:",count_cmd_err[0]

RETURN


' ******************************************************************************
' Test, running 2 clients
'
test_run_2_clients:

GOSUB open_connections

' If we opened expected number of connections, then run test.
IF num_servers <> server_ip_addr(0) THEN
    'Error

ELSE
    ' Run test
    count_test = 0
    count_test_err = 0
    TICKS = 0

    FOR j = 0 TO num_test_count-1
        'Run test
        ' Write and read back incrementing values to each client
        FOR i = 0 TO num_servers-1
            test_err_code = 0

            ' Initialise vrs to be written out

            ' Clear vrs where the readback values will be stored.
            FOR k = 0 TO 9
                VR(100+k) = 100+k+j
                VR(200+k) = 0
            NEXT k

            'Params: reg_address, number registers, vr address
            IF NOT mbtcp_write_registers(client_handle(i), 1000, 10, 100 ) THEN
                'Error
                test_err_code = 1
                count_test_err = count_test_err + 1
                'params: reg_address, number registers, vr address
            ELSEIF NOT mbtcp_read_registers(client_handle(i), 1000, 10, 200 ) THEN
                'Error
                test_err_code = 2
                count_test_err = count_test_err + 1
                'ELSEIF mbtcp_verify_vr_data(100, 200, 10 ) THEN
            ELSEIF NOT mbtcp_verify_vr_data(vr_src, vr_dst, num_regs, data_type ) THEN
                'Error
                test_err_code = 3
                count_test_err = count_test_err + 1
            ENDIF

            IF test_err_code > 0 THEN
                'PRINT#comms,"Test Fail"
                'PRINT#comms,"Connection Handle: ";client_handle(i)[0]
                PRINT#6,"Test Fail"
                PRINT#6,"Connection Handle: ";client_handle(i)[0]

                IF test_err_code = 3 THEN
                    'PRINT#comms,"Error: test failed to verify"
                    PRINT#6,"Error: test failed to verify"
                ELSEIF mbtcp_get_last_error(client_handle(i), error_code ) THEN
                    'PRINT#comms,"Last Error: 0x";HEX(error_code(0))
                    PRINT#6,"Last Error: 0x";HEX(error_code(0))
                ENDIF
                EXIT_LOOP
            ENDIF

        NEXT i

        count_test = count_test + 1

        IF (test_err_code > 0) OR (count_test MOD 100 = 0) THEN
            PRINT#comms,"Test count: ";count_test[0];", Test Errors: ";count_test_err[0];", Time: ";-TICKS[0]
            TICKS = 0
        ENDIF

        'IF test_err_code > 0 THEN EXIT_LOOP
    NEXT j

ENDIF



RETURN


' ******************************************************************************
' Test Utility Handlers

' ******************************************************************************
'
init:

FOR i = 0 TO max_num_mb_clients

    IF NOT MODBUS(2,slt,i,vr_index) THEN
        PRINT #comms,"Error: Failed to execute modbus check status command."
        count_cmd_err = count_cmd_err + 1
        test_fail = TRUE
    ELSEIF VR(vr_index) THEN
        MODBUS(1,slt,i)

        IF NOT MODBUS(2,slt,i,vr_index) THEN
            PRINT #comms,"Error: Failed to execute modbus check status command."
            count_cmd_err = count_cmd_err + 1
            test_fail = TRUE
        ELSEIF VR(vr_index) THEN
            PRINT #comms,"Error: Failed to close port."
            count_cmd_err = count_cmd_err + 1
            test_fail = TRUE
        ENDIF

    ENDIF

    IF test_fail THEN EXIT_LOOP

NEXT i

RETURN


' ******************************************************************************
' Open connections, and update file global data.
'
open_connections:

num_servers = 0
mb_cmd_error = -1 ' contains index of connnection to which modbus call failed.

FOR i = 0 TO server_ip_addr(0)-1
    IF NOT mbtcp_open_connection( server_ip_addr(i+1), temp_handle) THEN
        ' Error
        mb_cmd_error = 0
    ELSE
        client_handle(i) = temp_handle(0)
        num_servers = num_servers + 1
    ENDIF

    IF mb_cmd_error>-1 THEN EXIT_LOOP

NEXT i

RETURN



