' ******************************************************************************
'
'ModbusTCP library
'
' Revision
' 24th July 2019
'
' Notes
'
' v2.0296 fails to initialise data when using the value with the data declaration,
' eg DIM result AS BOOLEAN = FALSE
'
' 1. A vr entry must be reserved for transferring data out of the Modbus TrioBASIC
'    commands. The index of this entry is stored in 'mbtcp_vr_index'
'
' 2. Library requires constant defintions

' ******************************************************************************
' Class Process Data
'

DIM mbtcp_vr_index AS INTEGER = 0 ' used to return results from MODBUS command calls.

DIM mbtcp_msg_level AS INTEGER = 1
DIM mbtcp_slt AS INTEGER = -1
DIM mbtcp_max_vr AS INTEGER = 4095


' ******************************************************************************
' Class Interface
'

' ******************************************************************************
'Initialise class data (data identifier initialisation values don't work
'in libraries in fw v2.0296)
FUNCTION mbtcp_ctor()

    mbtcp_vr_index = 0
    mbtcp_msg_level = 1
    mbtcp_slt = -1
    mbtcp_max_vr = 4095

ENDFUNC


' ******************************************************************************
'
FUNCTION mbtcp_open_connection( lsb AS INTEGER, handle AS INTEGER()) AS BOOLEAN

    DIM result AS BOOLEAN = FALSE

    result = FALSE

    IF NOT MODBUS(0,mbtcp_slt,192,168,0,lsb,502,mbtcp_vr_index) THEN
        IF (mbtcp_msg_level AND msg_errors) THEN PRINT #comms,"MBTCPLib Error: Failed to open connection"
    ELSE
        handle(0) = VR(mbtcp_vr_index)
        IF (mbtcp_msg_level AND msg_info) THEN
            PRINT#comms,"MBTCPLib: opened connection at: 192.168.0.";lsb[0];", Handle: ";handle(0)
        ENDIF
        result = TRUE
    ENDIF

    RETURN result

ENDFUNC


' ******************************************************************************
' Read Holding Registers
'
' reg_addr: value to be used in modbus message
' tgt_addr: base address of vr's into which returned values are stored
FUNCTION mbtcp_read_registers(handle AS INTEGER, reg_addr AS INTEGER, num_regs AS INTEGER, tgt_addr AS INTEGER ) _
        AS BOOLEAN

    DIM result AS BOOLEAN = FALSE

    result = FALSE

    IF NOT MODBUS(3, mbtcp_slt, handle, 3, reg_addr, num_regs, tgt_addr) THEN
        IF (mbtcp_msg_level AND msg_errors) THEN PRINT #comms,"MBTCPLib Error: Failed to read registers"
    ELSE
        IF (mbtcp_msg_level AND msg_trace) THEN
            PRINT #comms,"MBTCPLib: read registers, handle:";handle[0];", addr:";reg_addr[0];", num: ";num_regs[0];
            PRINT #comms,", into vrs at: ";tgt_addr[0]
        ENDIF
        result = TRUE
    ENDIF

    RETURN result

ENDFUNC

' ******************************************************************************
' Read Holding Registers

FUNCTION mbtcp_write_registers(handle AS INTEGER, reg_addr AS INTEGER, num_regs AS INTEGER, src_addr AS INTEGER) AS _
        BOOLEAN

    DIM result AS BOOLEAN = FALSE

    result = FALSE

    IF NOT MODBUS(3, mbtcp_slt, handle, 16, reg_addr, num_regs, src_addr) THEN
        IF (mbtcp_msg_level AND msg_errors) THEN PRINT #comms,"MBTCPLib Error: Failed to write registers"
    ELSE
        IF (mbtcp_msg_level AND msg_trace) THEN
            PRINT #comms,"MBTCPLib: write registers, handle:";handle[0];", addr:";reg_addr[0];", num: ";num_regs[0];
            PRINT #comms,", from vrs at: ";src_addr[0]
        ENDIF
        result = TRUE
    ENDIF

    RETURN result

ENDFUNC

' ******************************************************************************
' Get connection status
'
FUNCTION mbtcp_is_open(handle AS INTEGER) AS BOOLEAN

    DIM result AS BOOLEAN = FALSE

    result = FALSE

    IF NOT MODBUS($2, mbtcp_slt, handle, mbtcp_vr_index )THEN
        IF (mbtcp_msg_level AND msg_errors) THEN PRINT #comms,"MBTCPLib Error: Failed to get connection status"
    ELSEIF VR(mbtcp_vr_index) = 1 THEN
        result = TRUE
    ENDIF

    RETURN result

ENDFUNC

' ******************************************************************************
' Set server datatype
'
FUNCTION mbtcp_set_server_datatype(data_type AS INTEGER)

    IF (datatype < 0) OR (data_type>datatype_uint16) THEN
        PRINT #comms,"MBTCPLib Error: attempt to assign out of range server datatype."
    ELSE
        'ModbusTCP endpoint index: 0, Datatype parameter index: 2
        'Datatype: 0 = 16 bit integer
        'Datatype: 1 = 32 bit integer
        'Datatype: 2 = 32 bit FP
        'Datatype: 3 = 64 bit FP
        'Datatype: 4 = 16 bit unsiged integer
        ETHERNET(1,mbtcp_slt,14,0,2,data_type)
    ENDIF

ENDFUNC


' ******************************************************************************
' Set client datatype
' Updates all clients.
'
FUNCTION mbtcp_set_all_client_datatype( data_type AS INTEGER)

    IF (datatype < 0) OR (data_type>datatype_uint16) THEN
        PRINT #comms,"MBTCPLib Error: attempt to assign out of range client datatype."
    ELSE
        'ModbusTCP endpoint index: 6, Datatype parameter index: 2
        'Datatype: 0 = 16 bit integer
        'Datatype: 1 = 32 bit integer
        'Datatype: 2 = 32 bit FP
        'Datatype: 3 = 64 bit FP
        'Datatype: 4 = 16 bit unsiged integer
        ETHERNET(1,mbtcp_slt,14,6,2,data_type)
    ENDIF

ENDFUNC

' ******************************************************************************
' Set client datatype
' Updates given client
'
FUNCTION mbtcp_set_client_datatype( handle AS INTEGER, data_type AS INTEGER) AS BOOLEAN
    DIM result AS BOOLEAN = FALSE

    IF (datatype < 0) OR (data_type>datatype_uint16) THEN
        IF (mbtcp_msg_level AND msg_errors) THEN
            PRINT #comms,"MBTCPLib Error: attempt to assign out of range client data type."
        ENDIF
    ELSE
        IF NOT MODBUS($22, mbtcp_slt, handle, 2, -1, data_type ) THEN
            PRINT #comms,"MBTCPLib Error: failed to change client datatype."
        ELSE
            result = TRUE
        ENDIF
    ENDIF

    RETURN result

ENDFUNC

' ******************************************************************************
' Get client datatype
'
FUNCTION mbtcp_get_client_datatype( handle AS INTEGER, data_type AS INTEGER()) AS BOOLEAN
    DIM result AS BOOLEAN = FALSE
    DIM data_type_value AS INTEGER = 0

    IF NOT MODBUS($23, mbtcp_slt, handle, 2, mbtcp_vr_index) THEN
        IF (mbtcp_msg_level AND msg_errors) THEN
            PRINT #comms,"MBTCPLib Error: failed to read client datatype."
        ENDIF
    ELSE
        data_type(0)= VR(mbtcp_vr_index)
        result = TRUE
    ENDIF

    RETURN result

ENDFUNC


' ******************************************************************************
' Get last error
'
FUNCTION mbtcp_get_last_error(handle AS INTEGER, error_code AS INTEGER()) AS BOOLEAN

    DIM result AS BOOLEAN = FALSE

    result = FALSE

    IF NOT MODBUS($11, mbtcp_slt, handle, mbtcp_vr_index )THEN
        IF (mbtcp_msg_level AND msg_errors) THEN
            PRINT #comms,"MBTCPLib Error: Failed to get error log count"
        ENDIF
    ELSEIF VR(mbtcp_vr_index) = 0 THEN
        ' No error recorded, return 0
        error_code(0) = 0
        result = TRUE
    ELSEIF NOT MODBUS($10, mbtcp_slt, handle, 0, mbtcp_vr_index) = TRUE THEN
        IF (mbtcp_msg_level AND msg_errors) THEN PRINT #comms,"MBTCPLib Error: Failed to get last error"
    ELSE
        error_code(0) = VR(mbtcp_vr_index)
        result = TRUE
    ENDIF

    RETURN result

ENDFUNC

' ******************************************************************************
' verify vr data arrays are equal
'
FUNCTION mbtcp_verify_vr_data(src_addr AS INTEGER, dst_addr AS INTEGER, num_registers AS INTEGER, data_type AS INTEGER)_
        AS BOOLEAN

    DIM result AS BOOLEAN = TRUE
    DIM i AS INTEGER
    DIM mask AS INTEGER = $FFFFFFFF

    result = TRUE

    IF data_type = 16 THEN mask= $FFFF


    FOR i = 0 TO num_registers - 1

        ' range check (max value only)
        IF (src_addr+i > mbtcp_max_vr) OR (dst_addr+i > mbtcp_max_vr) THEN
            IF (mbtcp_msg_level AND msg_errors) THEN PRINT #comms,"MBTCPLib Error: attempt to access out of range vr"
            result = FALSE
            EXIT_LOOP
        ENDIF

        'verify source = destination
        IF (VR(src_addr+i) AND mask) <> (VR(dst_addr+i) AND mask) THEN
            IF (mbtcp_msg_level AND msg_info) THEN
                PRINT#comms,"MBTCPLib MBTCP: failed vr verify check: "
                PRINT#comms,"src vr addr";(src_addr+i)[0];" value: ";VR(src_addr+i)
                PRINT#comms,"dest vr addr";(dst_addr+i)[0];" value: ";VR(dst_addr+i)
            ENDIF
            result = FALSE
        ENDIF

        'exit if fail comparison
        IF NOT result THEN EXIT_LOOP

    NEXT i

    RETURN result

ENDFUNC



' ******************************************************************************
' Library Object Data Accessors
'
FUNCTION mbtcp_set_vr_index( vr_index AS INTEGER )
    mbtcp_vr_index = vr_index
ENDFUNC

FUNCTION mbtcp_set_msg_level (level AS INTEGER )
    mbtcp_msg_level = level
ENDFUNC



