' ******************************************************************************
' EtherCAT Library
'
' Version 0.1
' Date 12th August 2019
'
' Notes
' 1. The user should define a free vr to be used by the library, and
'    the comms channel to output messages, and the message level.
'    These values can be defined by calling ec_ctor().
' 2. 'display_' functions will read the slave parameter and display it.
' 3. 'read_' functions will read and return a slave parameter.
' 4. DS402 Data Types : (used by co_read_axis and co_read) :
' 0x01    Boolean
' 0x02 integer8
' 0x03 integer16
' 0x04 integer32
' 0x05 unsigned8
' 0x06 unsigned16
' 0x07 unsigned32
' 0x08 real32 (NOT implemented yet)
' 0x09 visible STRING (read only)
' 0011 real64 (NOT TO implemented yet)
' 0x15 integer64 (NOT implemented yet)
' 0x1b unsigned64 (NOT implemented yet)
'
' 0x0b SoE IDN array
'



' ******************************************************************************
' Library Data
'Data types

DIM k_disp_chr AS INTEGER
k_disp_chr = 0
DIM k_disp_int AS INTEGER
k_disp_int = 1
DIM k_disp_hex AS INTEGER
k_disp_hex = 2

DIM mec_vr_index AS INTEGER
mec_vr_index = 0

'Define Message levels
DIM mec_msg_none AS INTEGER = $0
DIM mec_msg_err AS INTEGER = $1
DIM mec_msg_wrn AS INTEGER = $2
DIM mec_msg_info AS INTEGER = $4
DIM mec_msg_trace AS INTEGER = $10

DIM mec_msg_level AS INTEGER = 7

'Message channel
DIM mec_comms AS INTEGER = 5

DIM m_sdo_str_display AS INTEGER
m_sdo_str_display = k_disp_chr

' ******************************************************************************
' Library Operations

' ******************************************************************************
' Initialisation

' ******************************************************************************
'Initialise class data (data identifier initialisation values don't work
'in libraries in fw v2.0296)
FUNCTION ec_ctor( vr_index, comms, msg_level AS INTEGER)

    mec_vr_index = vr_index
    mec_comms = comms
    mec_msg_level = msg_level

ENDFUNC

' ******************************************************************************
'
FUNCTION ec_set_msg_level( level AS INTEGER)
    mec_msg_level = level
ENDFUNC

' ******************************************************************************
'
FUNCTION ec_comms( comms AS INTEGER)
    mec_comms = comms
ENDFUNC


' ******************************************************************************
' Display Handlers

FUNCTION ec_display_star_line()
    PRINT#mec_comms,""
    PRINT#mec_comms,"*********************************************************************** "
    PRINT#mec_comms,""
ENDFUNC

' ********************************************************************
FUNCTION ec_display_nw_state(slt AS INTEGER)
    IF NOT ETHERCAT($6,slt,mec_vr_index) THEN
        IF (mec_msg_level AND mec_msg_err) THEN PRINT #mec_comms,"Err(EC): failed to read network state."
    ELSE
        PRINT#mec_comms,"Network ESM state is:    ";
        IF VR(mec_vr_index)=0 THEN
            PRINT#mec_comms,"Init"
        ELSEIF VR(mec_vr_index)=1 THEN
            PRINT#mec_comms,"Pre-operational"
        ELSEIF VR(mec_vr_index)=2 THEN
            PRINT#mec_comms,"Safe-operational"
        ELSEIF VR(mec_vr_index)=3 THEN
            PRINT#mec_comms,"Operational"
        ELSE
            PRINT#mec_comms,"Err(EC): Unknown state"
        ENDIF
    ENDIF

ENDFUNC

' ******************************************************************************
' Display Network Configuration
'( irrspective of library message level.)
'
FUNCTION ec_display_nw_config( slt AS INTEGER )

    DIM num_slaves AS INTEGER = 0


    ec_display_star_line()
    PRINT#mec_comms,"Network Configuration"
    PRINT#mec_comms,""

    PRINT#mec_comms,"Controller Servo Period: ";SERVO_PERIOD[0]
    PRINT#mec_comms,"EtherCAT Module Slot Number:",slt[0]
    ec_display_nw_state(slt)

    num_slaves = ec_get_num_slaves(slt)
    PRINT#mec_comms,"Number of Slaves on network:";num_slaves[0]

    PRINT#mec_comms,""
    PRINT#mec_comms,"EtherCAT Network Information"
    PRINT#mec_comms,""
    ETHERCAT($87,slt)

    PRINT#mec_comms,""
    PRINT#mec_comms,"Description of information above:"
    PRINT#mec_comms,"EtherCAT Configuration (slot)"
    PRINT#mec_comms,"Slave information: product name : pos on network, alias (switch) address, configured address"
    PRINT#mec_comms,"For axes = (axis number), for IO = addr:len, with inputs then outputs, digital then analogue"
    PRINT#mec_comms,""

ENDFUNC

' ******************************************************************************
' Display Network Topology
FUNCTION ec_display_nw_topology( slt AS INTEGER )

    DIM on_trunk AS BOOLEAN = TRUE
    DIM on_branch AS BOOLEAN = FALSE
    DIM num_slaves AS INTEGER = 0
    DIM pos, j AS INTEGER
    DIM esc_reg, esc_len, slv_cfg_addr AS INTEGER
    DIM esc_data AS INTEGER(2)

    num_slaves = ec_get_num_slaves(slt)

    FOR pos = 0 TO num_slaves-1

        IF NOT ec_get_slave_config_addr(slt, pos, esc_data) THEN CONTINUE
        slv_cfg_addr = esc_data(0)

        ' Read slave ESC register 0x110, len 2 bytes
        IF NOT ec_get_esc_reg(slt, pos, $110, 2, esc_data) THEN CONTINUE

        j = 0

        PRINT#mec_comms,"Slave at Pos",pos[0],"Configured Address",slv_cfg_addr[0]
        IF NOT esc_data(0).4 THEN PRINT#mec_comms,"Error port 0 not open"

        IF esc_data(0).5 THEN
            IF on_trunk THEN PRINT#mec_comms,"On Trunk"
            IF on_branch THEN PRINT#mec_comms,"On Branch"
            j = j + 1
        ENDIF

        IF esc_data(0).6 THEN
            PRINT#mec_comms,"Start Branch on Port 2"
            j = j + 1
            on_trunk = FALSE
            on_branch = TRUE
        ENDIF

        IF esc_data(0).7 THEN
            PRINT#mec_comms,"Start Branch on Port 3"
            j = j + 1
            on_trunk = FALSE
            on_branch = TRUE
        ENDIF

        IF j = 0 THEN
            IF on_trunk THEN PRINT#mec_comms,"On Trunk"
            PRINT#mec_comms,"End of the line"
            on_branch = FALSE
            on_trunk = TRUE
        ENDIF

        PRINT#mec_comms,""

    NEXT pos

ENDFUNC


' ********************************************************************
' Function: ec_display_port_link_lost_cntrs
'
' Description:
'
' Link lost (0x110 bits 4..7 only counts if loop is auto, and open.)
'
' Stable Comms Check: if in standard link detection mode then it only
' reflects the link status. If in enhanced link detection on an MII,
' the bit is reset if PHY detects > 32 RX_ER events in 10 usec. If in
' enhanced link detection using EBUS stablility based on handshake
' protocol between nodes.
'
' Sometimes it is not possible to read all these registers on a slave,
' hence the function continues with what was possible.
'
FUNCTION ec_display_port_link_lost_cntrs(slt AS INTEGER)

    DIM on_trunk AS BOOLEAN = TRUE
    DIM on_branch AS BOOLEAN = FALSE

    DIM link_lost AS INTEGER(4)
    DIM link_stable AS INTEGER(4)
    DIM link_open AS INTEGER(4)
    DIM num_ports_open AS INTEGER

    DIM invalid_frame_count AS INTEGER(4)
    DIM rx_error_count AS INTEGER(4)
    DIM port_fwd_error_count AS INTEGER(4)
    DIM esc_data AS INTEGER (2)
    DIM link_data AS INTEGER
    DIM ecat_proc_error_count AS INTEGER

    DIM num_slaves AS INTEGER = 0
    DIM slv_cfg_addr, pos, j AS INTEGER

    num_slaves = ec_get_num_slaves(slt)

    FOR pos = 0 TO num_slaves-1

        link_open = 0,0,0,0
        link_stable = 0,0,0,0
        num_ports_open = 0
        j = 0

        IF NOT ec_get_slave_config_addr(slt, pos, esc_data) THEN CONTINUE
        slv_cfg_addr = esc_data(0)

        PRINT#mec_comms,"Slave at Pos",pos[0],"Configured Address",slv_cfg_addr[0]

        ' Read slave ESC register 0x110, len 2 bytes
        IF NOT ec_get_esc_reg(slt, pos, $110, 2, esc_data) THEN CONTINUE
        link_data = esc_data(0)

        ' Port 0
        link_open(j) = link_data.4
        link_stable(j) = link_data.9
        j = j + 1

        ' Port 1
        link_open(j) = link_data.5
        link_stable(j) = link_data.11
        IF link_data.5 THEN
            IF on_trunk THEN PRINT#mec_comms,"On Trunk"
            IF on_branch THEN PRINT#mec_comms,"On Branch"
            num_ports_open = num_ports_open + 1
        ENDIF
        j = j + 1

        ' Port 2
        link_open(j) = link_data.6
        link_stable(j) = link_data.13
        IF link_data.6 THEN
            PRINT#mec_comms,"Start Branch on Port 2"
            on_trunk = FALSE
            on_branch = TRUE
            num_ports_open = num_ports_open + 1
        ENDIF
        j = j + 1

        ' Port 3
        link_open(j) = link_data.7
        link_stable(j) = link_data.15
        IF link_data.7 THEN
            PRINT#mec_comms,"Start Branch on Port 3"
            on_trunk = FALSE
            on_branch = TRUE
            num_ports_open = num_ports_open + 1
        ENDIF
        j = j + 1

        IF num_ports_open = 0 THEN
            IF on_trunk THEN PRINT#mec_comms,"On Trunk"
            PRINT#mec_comms,"End of the line"
            on_branch = FALSE
            on_trunk = TRUE
        ENDIF

        ' Collect Data
        link_lost = 0,0,0,0
        invalid_frame_count = 0,0,0,0
        rx_error_count = 0,0,0,0
        port_fwd_error_count = 0,0,0,0

        FOR j = 0 TO 3

            ' Link Lost Count
            IF ec_get_esc_reg(slt, pos, $310 + j, 1, esc_data) THEN
                link_lost(j) = esc_data(0)
            ENDIF


            'Invalid frame and Rx error counter
            IF ec_get_esc_reg(slt, pos, $300 + j, 2, esc_data) THEN
                invalid_frame_count(j) = esc_data(0) AND $FF
                rx_error_count(j) = (esc_data(0) >> 8 ) AND $FF
            ENDIF

            'Port Forwarding Error
            IF ec_get_esc_reg(slt, pos, $308 + j, 2, esc_data) THEN
                port_fwd_error_count(j) = esc_data(0)
            ENDIF

        NEXT j

        'ECAT Processing Unit Error
        IF NOT ec_get_esc_reg(slt, pos, $30C, 1, esc_data) THEN
            ecat_proc_error_count = -1
        ELSE
            ecat_proc_error_count = esc_data(0)
        ENDIF

        ' Display Data
        FOR j = 0 TO 3

            PRINT#mec_comms,"Port ";j[0];":";
            IF link_open(j) THEN
                PRINT#mec_comms, " Open:  ";
            ELSE
                PRINT#mec_comms, " Closed:";
            ENDIF

            IF link_open(j) THEN
                PRINT#mec_comms," link lost ";link_lost(j)[0];", Stable ";link_stable(j)[0]

                PRINT#mec_comms,"                ";
                PRINT#mec_comms,"rx errors ";rx_error_count(j)[0];", invalid frames ";invalid_frame_count(j)[0]

                PRINT#mec_comms,"                ";
                PRINT#mec_comms,"fwd errors ";port_fwd_error_count(j)[0]

            ELSE
                PRINT#mec_comms,""
            ENDIF

            IF j = 0 AND link_open(j)=0 THEN PRINT#mec_comms,"ERROR, Port 0 not open"
            IF link_open(j)=1 AND link_stable(j)=0 THEN PRINT#mec_comms,"ERROR, Port open but not stable"

        NEXT j

        PRINT#mec_comms,"ECAT Processing frame errors ";ecat_proc_error_count[0]

        PRINT#mec_comms,""

    NEXT pos

ENDFUNC

' ********************************************************************
' Function: ec_display_slv_interrupt
'
' Description:
' Read Slave Interrupt Configuration Status
'
FUNCTION ec_display_slv_interrupt(slt, pos AS INTEGER)

    DIM esc_data AS INTEGER(2)

    ec_display_star_line()

    PRINT#mec_comms, "Display Slave ESC Distributed Clock Status"
    PRINT#mec_comms, "Slave on slot ";slt[0];" at position ";pos[0]
    PRINT#mec_comms,""

    'ECAT Event Mask
    PRINT#mec_comms,"ECAT Event Mask (ESC 0x200=0x201)"
    IF ec_get_esc_reg(slt, pos, $200, 2, esc_data) THEN
        PRINT#mec_comms, "ESC 0x200 = 0x";HEX(esc_data(0))
        PRINT#mec_comms,""
    ENDIF

    'AL
    PRINT#mec_comms,"PDI AL Event Mask (ESC 0x204-0x207)"
    IF ec_get_esc_reg(slt, pos, $204, 4, esc_data) THEN
        PRINT#mec_comms, "ESC 0x204 = 0x";HEX(esc_data(0))
        PRINT#mec_comms,""
    ENDIF

    '
    PRINT#mec_comms,"ECAT Event Request (ESC 0x210-0x211)"
    IF ec_get_esc_reg(slt, pos, $210, 2, esc_data) THEN
        PRINT#mec_comms, "ESC 0x210 = 0x";HEX(esc_data(0))
        PRINT#mec_comms,""
    ENDIF

    PRINT#mec_comms,"AL ECAT Event Request (ESC 0x220-0x223)"
    IF ec_get_esc_reg(slt, pos, $220, 4, esc_data) THEN
        PRINT#mec_comms, "ESC 0x220 = 0x";HEX(esc_data(0))
        PRINT#mec_comms,""
    ENDIF

    PRINT#mec_comms,"AL Control (ESC 0x120)"
    IF ec_get_esc_reg(slt, pos, $120, 2, esc_data) THEN
        PRINT#mec_comms, "ESC 0x120 = 0x";HEX(esc_data(0))
        PRINT#mec_comms,""
    ENDIF

    PRINT#mec_comms,"AL Status (ESC 0x130)"
    IF ec_get_esc_reg(slt, pos, $130, 2, esc_data) THEN
        PRINT#mec_comms, "ESC 0x130 = 0x";HEX(esc_data(0))
        PRINT#mec_comms,""
    ENDIF

    PRINT#mec_comms,"AL Status Code (ESC 0x134)"
    IF ec_get_esc_reg(slt, pos, $134, 2, esc_data) THEN
        PRINT#mec_comms, "ESC 0x134 = 0x";HEX(esc_data(0))
        PRINT#mec_comms,""
    ENDIF

    PRINT#mec_comms,""
ENDFUNC


' ********************************************************************
' Function: ec_reset_link_cntrs
'
FUNCTION ec_reset_all_link_cntrs(slt AS INTEGER)
    DIM pos AS INTEGER
    DIM num_slaves AS INTEGER

    num_slaves = ec_get_num_slaves(slt)

    FOR pos = 0 TO num_slaves-1

        ' All link lost counters are reset by a write to any one of them
        ec_set_esc_reg(slt, pos, $310, 1, 0)

        'rx error, invalid frame, port fwd error counters
        ec_set_esc_reg(slt, pos, $300, 1, 0)

    NEXT pos

ENDFUNC

' ******************************************************************************
' DC Handlers
'

' ********************************************************************
' Function: ec_display_slv_dc_status
'
' Description:
' Read Slave DC Configuration Status
'
FUNCTION ec_display_slv_dc_status(slt, pos AS INTEGER)

    DIM esc_data AS INTEGER(2)

    PRINT#mec_comms,"Display Slave ESC Distributed Clock Status"
    PRINT#mec_comms,"Slave on slot ";slt[0];" at position ";pos[0]
    PRINT#mec_comms,""

    'AL Status and Error Code
    PRINT#comms,"AL Status (ESC 0x130)"
    IF ec_get_esc_reg(slt, pos, $130, 2, esc_data) THEN
        PRINT#mec_comms, "ESC 0x130 = 0x";HEX(esc_data(0))
        PRINT#mec_comms,""
    ENDIF

    'AL Status and Error Code
    PRINT#comms,"AL Error Status (ESC 0x134)"
    IF ec_get_esc_reg(slt, pos, $134, 2, esc_data) THEN
        PRINT#mec_comms, "ESC 0x134 = 0x";HEX(esc_data(0))
        PRINT#mec_comms,""
    ENDIF

    'System Time Diff
    PRINT#comms,"System Time Diff (ESC 0x92C)"
    IF ec_get_esc_reg(slt, pos, $92c, 4, esc_data) THEN
        PRINT#mec_comms, "ESC 0x92c = ";esc_data(0)[0]
        PRINT#mec_comms,""
    ENDIF

    PRINT#mec_comms,""

ENDFUNC

' ********************************************************************
' Function: display_slv_dc_config:
'
' Description:
' Read Slave DC Configuration defined by ESC registers
'
FUNCTION ec_display_slv_dc_config(slt,pos AS INTEGER)

    DIM esc_data AS INTEGER(2)

    ec_display_star_line()

    PRINT#mec_comms, "Display Slave ESC Distributed Clock Configuration"
    PRINT#mec_comms, "Slave on slot ";slt[0];" at position ";pos[0]
    PRINT#mec_comms,""

    'DC Sync Out Unit
    PRINT#mec_comms,"Enable DC Sync Out (ESC 0x140)"
    PRINT#mec_comms,"Reg 0x140 and 0x141 are loaded from SII address 0"
    PRINT#mec_comms,"0x141.2 = 1 to Enable DC Sync out unit."
    IF ec_get_esc_reg(slt, pos, $140, 2, esc_data) THEN
        PRINT#mec_comms, "ESC 0x140 = 0x";HEX(esc_data(0))
        PRINT#mec_comms,""
    ENDIF

    ' Sync/Latch PDI Config Register (initialised by SII)
    PRINT#mec_comms,"Sync/Latch PDI Config Register (ESC 0x151)"
    PRINT#mec_comms,"Reg 0x150 and 0x151 are loaded from SII address 1"
    PRINT#mec_comms,"0x151:0,1 = b10 for push pull active high. 0x151:0,1 = b11 for open source active high."
    PRINT#mec_comms,"0x151.2 = 1 for sync0 output"
    PRINT#mec_comms,"0x151.3 = 1 TO enable sync0 mapped to AL event regsiter 0x0220.2, = 0 disabled"
    IF ec_get_esc_reg(slt, pos, $151, 1, esc_data) THEN
        PRINT#mec_comms, "ESC 0x151 = 0x";HEX(esc_data(0))
        PRINT#mec_comms,""
    ENDIF

    'Pulse Length register (initialised by SII Addr. 2)
    PRINT#mec_comms,"Pulse Length register (ESC 0x982:0x983)"
    PRINT#mec_comms,"Reg 0x982:0x983 are loaded from SII address 2"
    IF ec_get_esc_reg(slt, pos, $982, 2, esc_data) THEN
        PRINT#mec_comms, "ESC 0x982 = 0x";HEX(esc_data(0))
        PRINT#mec_comms,""
    ENDIF

    'Assign Sync Unit to ECAT or PDI
    PRINT#mec_comms,"Assign Sync Unit to ECAT or PDI (ESC 0x980)"
    PRINT#mec_comms,"Reg 0x980 is set by Master"
    PRINT#mec_comms,"0x980.0 = 0 for ECAT or = 1 for PDI control."
    IF ec_get_esc_reg(slt, pos, $980, 1, esc_data) THEN
        PRINT#mec_comms, "ESC 0x980 = 0x";HEX(esc_data(0))
        PRINT#mec_comms,""
    ENDIF

    ' Set Cyclic Time of Sync 0
    PRINT#mec_comms,"Cyclic Time of Sync0"
    PRINT#mec_comms,"Sync0 Cycle Time: Reg 0x9A0:0x9A3 are set by Master"
    IF ec_get_esc_reg(slt, pos, $9A0, 4, esc_data) THEN
        PRINT#mec_comms, "ESC 0x9A0 = ";esc_data(0)
        PRINT#mec_comms,""
    ENDIF

    ' Set Cyclic Time of Sync 1
    PRINT#mec_comms,"Sync1 Cycle Time: Reg 0x9A4:0x9A7 are set by Master"
    PRINT#mec_comms,"Note that this value is the delay after the Sync0 at which point the sync1 is triggered"
    IF ec_get_esc_reg(slt, pos, $9A4, 4, esc_data) THEN
        PRINT#mec_comms, "ESC 0x9A4 = 0x";HEX(esc_data(0))
        PRINT#mec_comms,""
    ENDIF

    ' Set Start time of cyclic operation (NB must have been greater than
    ' current time, and allow for writing start time and activation)
    PRINT#mec_comms,"DC Start time"
    PRINT#mec_comms,"Reg 0x990:0x997 are set by Master"
    IF ec_get_esc_reg(slt, pos, $990, 4, esc_data) THEN
        DIM lsw AS INTEGER
        lsw = esc_data(0)
        IF ec_get_esc_reg(slt, pos, $994, 4, esc_data) THEN
            PRINT#mec_comms, "ESC 0x990 = ";(esc_data(0)<<8) OR lsw
            PRINT#mec_comms,""
        ENDIF
    ENDIF

    'Activate cyclic operation
    PRINT#mec_comms,"Activate Cyclic Operation"
    PRINT#mec_comms,"Reg 0x981 is set by Master"
    PRINT#mec_comms,"Set 0x981.0 to activate Sync signals, and 0x981.1 for Sync 0 and 0x981.2 for Sync1"
    IF ec_get_esc_reg(slt, pos, $981, 1, esc_data) THEN
        PRINT#mec_comms, "ESC 0x981 = 0x";HEX(esc_data(0))
        PRINT#mec_comms,""
    ENDIF

    PRINT#mec_comms,""

ENDFUNC

' ********************************************************************
' Function: ec_display_slv_coe_dc_config:
' Parameters:
' slt: slot
' addr: conigured address of required slave
'
' Description:
' Read Slave DC Configuration from CoE defined by objects
'
FUNCTION ec_display_slv_coe_dc_config(slt,addr AS INTEGER)

    DIM sdo_data AS INTEGER(2)

    PRINT#mec_comms, "Display Slave CoE Distributed Clock Configuration"
    PRINT#mec_comms, "Slave on slot ";slt[0];" with configured addr ";addr[0]
    PRINT#mec_comms,""

    PRINT#mec_comms,"Network Cycle Time"
    '  Datatype: 0x04 integer32
    IF ec_read_sdo(slt, addr, $1c32, 2, 4, sdo_data) THEN
        PRINT#mec_comms, "SDO 0x1C32:2 = ";sdo_data(0)
        PRINT#mec_comms,""
    ENDIF

    PRINT#comms,"Slave Min Cycle Time"
    IF ec_read_sdo(slt, addr, $1c32, 5, 4, sdo_data) THEN
        PRINT#mec_comms, "SDO 0x1C32:5 = ";sdo_data(0)
        PRINT#mec_comms,""
    ENDIF

    PRINT#comms,"Input Shift Time"
    IF ec_read_sdo(slt, addr, $1c33, 3, 4, sdo_data) THEN
        PRINT#mec_comms, "SDO 0x1C33:5 = ";sdo_data(0)
        PRINT#mec_comms,""
    ENDIF

    PRINT#comms,"Output Shift Time"
    IF ec_read_sdo(slt, addr, $1c32, 3, 4, sdo_data) THEN
        PRINT#mec_comms, "SDO 0x1C32:3 = ";sdo_data(0)
        PRINT#mec_comms,""
    ENDIF

    PRINT#comms,"Input Calc and Copy Time"
    IF ec_read_sdo(slt, addr, $1c33, 6, 4, sdo_data) THEN
        PRINT#mec_comms, "SDO 0x1C33:6 = ";sdo_data(0)
        PRINT#mec_comms,""
    ENDIF

    PRINT#comms,"Output Calc and Copy Time"
    PRINT#comms,"(Min time between slave rx telegram and sync0"
    IF ec_read_sdo(slt, addr, $1c32, 6, 4, sdo_data) THEN
        PRINT#mec_comms, "SDO 0x1C32:6 = ";sdo_data(0)
        PRINT#mec_comms,""
    ENDIF

    PRINT#comms,"Input Delay Time"
    IF ec_read_sdo(slt, addr, $1c33, 9, 4, sdo_data) THEN
        PRINT#mec_comms, "SDO 0x1C33:9 = ";sdo_data(0)
        PRINT#mec_comms,""
    ENDIF

    PRINT#comms,"Output Delay Time"
    IF ec_read_sdo(slt, addr, $1c32, 9, 4, sdo_data) THEN
        PRINT#mec_comms, "SDO 0x1C32:9 = ";sdo_data(0)
        PRINT#mec_comms,""
    ENDIF


    PRINT#comms,"Input Sync Error"
    IF ec_read_sdo(slt, addr, $1c33, 32, 4, sdo_data) THEN
        PRINT#mec_comms, "SDO 0x1C33:32 = 0x";sdo_data(0)
        PRINT#mec_comms,""
    ENDIF

    PRINT#comms,"Output Sync Error"
    IF ec_read_sdo(slt, addr, $1c32, 32, 4, sdo_data) THEN
        PRINT#mec_comms, "SDO 0x1C32:32 = ";sdo_data(0)
        PRINT#mec_comms,""
    ENDIF

ENDFUNC


' ******************************************************************************
' SDO Handlers

' ******************************************************************************
'
' *******************************************************************************
' Read and return (non string ) CoE object and return.
'
' Params:
'   comms: if > -1 the display message to given comms port if error.
'
FUNCTION ec_read_sdo(slt, addr, index, sub_index, data_type AS INTEGER, value AS INTEGER()) AS BOOLEAN

    DIM rd_status AS BOOLEAN = FALSE

    VR(mec_vr_index) = 0

    rd_status = ETHERCAT($41,slt,addr,index,sub_index,data_type,mec_vr_index)
    IF NOT rd_status THEN
        IF (mec_msg_level AND mec_msg_err) THEN
            PRINT #mec_comms,"Err(EC): failed to read SDO 0x";HEX(index);":";HEX(sub_index);", slave addr: ";addr[0]
        ENDIF
    ELSE
        IF (mec_msg_level AND mec_msg_trace) THEN
            PRINT #mec_comms,"Trace(EC): read SDO 0x";HEX(index);":";HEX(sub_index);", slave addr: ";addr[0]
        ENDIF
        value(0) = VR(mec_vr_index)
    ENDIF

    RETURN rd_status

ENDFUNC

' ********************************************************************
' Function: ec_display_coe_slv_errs
'
FUNCTION ec_display_coe_slv_errs(slt AS INTEGER)
    
    DIM num_slaves AS INTEGER
    DIM sdo_data AS INTEGER(2)
    DIM pos,addr AS INTEGER
    
    PRINT#mec_comms,"Display Network Slave CoE Error Status"
    
    num_slaves = ec_get_num_slaves(slt)
    
    'For each slave in the network
    FOR pos = 0 TO num_slaves-1
        
        PRINT#mec_comms,""
        
        '  Datatype: 0x04 integer32
        IF NOT ec_get_config_addr(slt, pos, sdo_data) THEN CONTINUE
        addr = sdo_data(0)
        
        PRINT#mec_comms, "Slave on slot ";slt[0];" at pos: ";pos[0];" config addr: ";addr[0]
        
        IF ec_read_sdo(slt, addr, $603F, 0, 4, sdo_data) THEN
            PRINT#mec_comms, "SDO 0x603F:0 = ";sdo_data(0)[0];" (0x";HEX(sdo_data(0));")"
            PRINT#mec_comms,""
        ENDIF
        
    NEXT pos
    
ENDFUNC

' ********************************************************************
' Function: ec_display_coe_slv_errs
'
' Parameters
' slt: slot
' pos : position of slave on network, or if -1 then read all.
' index: CoE object index
' sub_index: CoE object sub-iundex
' data_type : DS402 data type.
'
FUNCTION ec_display_coe_value(slt,pos,index,sub_index,data_type AS INTEGER)
    
    DIM num_slaves AS INTEGER
    DIM sdo_data AS INTEGER(2)
    DIM i,addr AS INTEGER
    
    PRINT#mec_comms,"Display Network/Slave CoE Value"
    
    num_slaves = ec_get_num_slaves(slt)
    
    'For each slave in the network
    FOR i = 0 TO num_slaves-1
        
        PRINT#mec_comms,""
        'Check if only required to access one slave.
        IF pos <> -1 THEN i = pos
        
        '  Datatype: 0x04 integer32
        IF NOT ec_get_config_addr(slt, i, sdo_data) THEN CONTINUE
        addr = sdo_data(0)
        
        PRINT#mec_comms, "Slave on slot ";slt[0];" at pos: ";i[0];" config addr: ";addr[0]
        
        IF ec_read_sdo(slt, addr, index, sub_index, data_type, sdo_data) THEN
            PRINT#mec_comms, "SDO 0x";HEX(index);":";sub_index[0];" = ";sdo_data(0)[0];" (0x";HEX(sdo_data(0));")"
            PRINT#mec_comms,""
        ENDIF
        
        'Exit if only required to access one slave.
        IF pos <> -1 THEN i = num_slaves
    NEXT i
    
ENDFUNC

' *******************************************************************************
' Write (non string) data to the given CoE object.
'
FUNCTION ec_write_sdo(slt, addr, index, sub_index, data_type, vr_index, value AS INTEGER) AS BOOLEAN

    DIM wr_status AS BOOLEAN = FALSE

    wr_status = ETHERCAT($40,slt,addr,index,sub_index,data_type,-1,value)
    IF NOT wr_status THEN
        IF (mec_msg_level AND mec_msg_err) THEN
            PRINT #mec_comms,"Err(EC): failed to write SDO 0x";HEX(index);":";HEX(sub_index);", slave addr: ";addr[0]
        ENDIF
    ELSE
        IF (mec_msg_level AND mec_msg_trace) THEN
            PRINT #mec_comms,"Trace(EC): write SDO 0x";HEX(index);":";HEX(sub_index);", slave addr: ";addr[0]
        ENDIF
    ENDIF

    RETURN wr_status

ENDFUNC


' ******************************************************************************
' ESC Handlers

' ******************************************************************************
' Function: ec_get_slave_config_addr
' NB could also get from ESC reg 10
FUNCTION ec_get_slave_config_addr(slt, pos AS INTEGER, addr AS INTEGER()) AS BOOLEAN

    DIM rd_status AS BOOLEAN = FALSE

    addr(0) = 0
    rd_status = ETHERCAT($4,slt,pos,mec_vr_index)
    IF NOT rd_status THEN
        IF (mec_msg_level AND mec_msg_err) THEN
            PRINT #mec_comms,"Err(EC): failed to get config addr, slave at pos: ";pos[0]
        ENDIF
    ELSE
        IF (mec_msg_level AND mec_msg_trace) THEN
            PRINT #mec_comms,"Trace(EC): read config addr, slave at pos: ";pos[0]
        ENDIF
        addr(0) = VR(mec_vr_index)
    ENDIF
    RETURN rd_status

ENDFUNC

' ******************************************************************************
' Function: ec_get_esc_reg
' parameters:
' addr : position on network
' reg  : address of ESC register
' size : number of bytes to be read
' value : return value read from ESC in value(0)
'
' return : true if read ok, false otherwise
'
FUNCTION ec_get_esc_reg(slt, pos, reg, size AS INTEGER, value AS INTEGER()) AS BOOLEAN
    DIM rd_status AS BOOLEAN

    value(0) = 0
    rd_status = ETHERCAT($31, slt, pos, reg, size, mec_vr_index)
    IF NOT rd_status THEN
        IF (mec_msg_level AND mec_msg_err) THEN
            PRINT #mec_comms,"Err(EC): failed to read ESC reg: 0x";HEX(reg);", slave at pos: ";pos[0]
        ENDIF
    ELSE
        IF (mec_msg_level AND mec_msg_trace) THEN
            PRINT #mec_comms,"Trace(EC): read ESC reg: 0x";HEX(reg);", slave at pos: ";pos[0]
        ENDIF
        value(0) = VR(mec_vr_index)
    ENDIF
    RETURN rd_status
ENDFUNC

' ******************************************************************************
' Function: ec_set_esc_reg
' parameters:
' addr : position on network
' reg  : address of ESC register
' size : number of bytes to be read
' value : return value read from ESC in value(0)
'
' return : true if read ok, false otherwise
'
FUNCTION ec_set_esc_reg(slt, pos, reg, size AS INTEGER, value AS INTEGER) AS BOOLEAN
    DIM wr_status AS BOOLEAN

    wr_status = ETHERCAT($30, slt, pos, reg, size, value)
    IF NOT wr_status THEN
        IF (mec_msg_level AND mec_msg_err) THEN
            PRINT #mec_comms,"Err(EC): failed write ESC reg: 0x";HEX(reg);", value: ";value[0];", slave at pos: ";pos[0]
        ENDIF
    ELSE
        IF (mec_msg_level AND mec_msg_trace) THEN
            PRINT #mec_comms,"Trace(EC): write ESC reg: 0x";HEX(reg);", value: ";value[0];", slave at pos: ";pos[0]
        ENDIF
    ENDIF
    RETURN wr_status
ENDFUNC

' ********************************************************************
' Function: ec_display_esc_reg_name
'
FUNCTION ec_display_esc_reg_name( addr AS INTEGER)

    IF addr < $600 THEN
        SELECT_CASE addr
            CASE $10
                PRINT#mec_comms,"(Configured Station Address)"
            CASE $130
                PRINT#mec_comms,"(AL Status)"
            CASE $134
                PRINT#mec_comms,"(AL Code)"
            CASE ELSE
                PRINT#mec_comms,""
        END_CASE
    ELSE
        SELECT_CASE (addr AND $F0F)
            CASE $600
                PRINT#mec_comms,"(FMMU Logical Address)"
            CASE $604
                PRINT#mec_comms,"(FMMU Length)"
            CASE $800, $808
                PRINT#mec_comms,"(SM Logical Address)"
            CASE $802,$80a
                PRINT#mec_comms,"(SM Length)"
            CASE $804,$80C
                PRINT#mec_comms,"(SM Control Reg)"
            CASE $805,$80D
                PRINT#mec_comms,"(SM Status Reg)"
            CASE $806, $80e
                PRINT#mec_comms,"(SM Activate Reg)"
            CASE $807,$80F
                PRINT#mec_comms,"(SM PDI Control Reg)"
            CASE ELSE
                PRINT#mec_comms,""
        END_CASE
    ENDIF

ENDFUNC


' ****************************************************************************************
' SII Handlers

' ********************************************************************
' Function: ec_get_next_slot
'
FUNCTION ec_get_sii(slt, pos, sii_addr, sii_len AS INTEGER, value AS INTEGER()) AS BOOLEAN

    DIM rd_status AS BOOLEAN = FALSE

    rd_status = ETHERCAT($61, slt, pos, sii_addr, sii_len, mec_vr_index)
    IF NOT rd_status THEN
        IF (mec_msg_level AND mec_msg_err) THEN
            PRINT #mec_comms,"Err(EC): failed to read SII: 0x";HEX(sii_addr);", slave at pos: ";pos[0]
        ENDIF
    ELSE
        IF (mec_msg_level AND mec_msg_trace) THEN
            PRINT #mec_comms,"Trace(EC): read SII: 0x";HEX(sii_addr);", slave at pos: ";pos[0]
        ENDIF
        value(0) = VR(mec_vr_index)
    ENDIF
    RETURN rd_status

ENDFUNC

' ********************************************************************
' Function: ec_display_sii_addr_name
'
FUNCTION ec_display_sii_addr_name(sii_addr AS INTEGER) AS BOOLEAN

    IF sii_addr = $0 THEN
        PRINT#mec_comms, "(PDI Control)"
    ELSEIF sii_addr = $1 THEN
        PRINT#mec_comms, "(PDI Configuration)"
    ELSEIF sii_addr = $2 THEN
        PRINT#mec_comms, "(Sync Impulse Len)"
    ELSEIF sii_addr = $3 THEN
        PRINT#mec_comms, "(PDI Configuration 2)"
    ELSEIF sii_addr = $4 THEN
        PRINT#mec_comms, "(Configured Station Alias)"
    ELSEIF sii_addr = $5 OR sii_addr = 6 THEN
        PRINT#mec_comms, "(Reserved)"
    ELSEIF sii_addr = $7 THEN
        PRINT#mec_comms, "(Checksum)"
    ELSEIF sii_addr = $8 THEN
        PRINT#mec_comms, "(Vendor ID (LSW))"
    ELSEIF sii_addr = $9 THEN
        PRINT#mec_comms, "(Vendor ID (MSW))"
    ELSEIF sii_addr = $a THEN
        PRINT#mec_comms, "(Product Code)"
    ELSEIF sii_addr = $c THEN
        PRINT#mec_comms, "(Revision Number)"
    ELSEIF sii_addr = $e THEN
        PRINT#mec_comms, "(Serial Number)"
    ELSEIF sii_addr = $10 THEN
        PRINT#mec_comms, "(Execution Delay)"
    ELSEIF sii_addr = $11 THEN
        PRINT#mec_comms, "(Port 0 Delay)"
    ELSEIF sii_addr = $12 THEN
        PRINT#mec_comms, "(Port 1 Delay)"
    ELSEIF sii_addr = $18 THEN
        PRINT#mec_comms, "(Standard Receive Mailbox Offset)"
    ELSEIF sii_addr = $19 THEN
        PRINT#mec_comms, "(Standard Receive Mailbox Size)"
    ELSEIF sii_addr = $1A THEN
        PRINT#mec_comms, "(Standard Send Mailbox Offset)"
    ELSEIF sii_addr = $1b THEN
        PRINT#mec_comms, "(Standard Send Mailbox Size)"
    ELSEIF sii_addr = $1c THEN
        PRINT#mec_comms, "(Mailbox Protocol)"
    ELSEIF sii_addr = $3F THEN
        PRINT#mec_comms, "(Version)"
    ELSE
        PRINT#mec_comms, ""
    ENDIF

    RETURN TRUE

ENDFUNC

' ********************************************************************
' Function: ec_display_sii
'
' Description:
' Write (non string) data to the given CoE object.
'
FUNCTION ec_display_sii(slt, pos, sii_addr, sii_len AS INTEGER) AS BOOLEAN

    DIM rd_status AS BOOLEAN = FALSE
    DIM value AS INTEGER(2)

    rd_status = ec_get_sii(slt, pos, sii_addr, sii_len, value)

    IF rd_status THEN
        PRINT#mec_comms, "SII 0x"; HEX(sii_addr), "=", "0x"; HEX(value(0)); " ";
        ec_display_sii_addr_name(sii_addr)
    ENDIF

    RETURN rd_status

ENDFUNC


' ****************************************************************************************
' Slave Information


' *******************************************************************************
' Write (non string) data to the given CoE object.
'
FUNCTION ec_get_config_addr(slt, pos AS INTEGER, addr AS INTEGER()) AS BOOLEAN
    
    DIM status AS BOOLEAN = FALSE
    
    status = ETHERCAT($4, slt, pos, mec_vr_index)
    IF NOT status THEN
        IF (mec_msg_level AND mec_msg_err) THEN
            PRINT #mec_comms,"Err(EC): failed to get configured address, slave at: ";pos[0]
        ENDIF
    ELSE
        IF (mec_msg_level AND mec_msg_trace) THEN
            PRINT #mec_comms,"Trace(EC): read config addr of: ";VR(mec_vr_index)[0];", slave at: ";pos[0]
        ENDIF
        addr(0) = VR(mec_vr_index)
    ENDIF
    
    RETURN status
    
ENDFUNC


' ****************************************************************************************
' Network Information

' ********************************************************************
' Function: ec_get_next_slot
'
' Description:
' Find which slot the ethercat module is in, and return. Start search
' from given (from_slt + 1)
'
FUNCTION ec_get_next_slot(from_slt AS INTEGER) AS INTEGER

    DIM next_slt AS INTEGER
    DIM max_slt AS INTEGER
    DIM i AS INTEGER

    next_slt = -1
    max_slt = 0

    ' If MC is MC4NE, PCM-CAT ,MC6NE or F6Nano
    IF CONTROL = 432 OR CONTROL = 499 OR CONTROL = 632 OR CONTROL = 600 THEN
        max_slt = 0
    ELSEIF CONTROL = 464 OR CONTROL = 266 OR CONTROL = 664 OR CONTROL = 665 THEN
        ' MC464, MC64, MC664, MC664X
        max_slt = 8
    ENDIF

    i = from_slt + 1
    WHILE (i < max_slt) AND (next_slt = -1)
        IF COMMSTYPE SLOT(i) = 42 THEN
            next_slt = i
        ELSE
            i = i + 1
        ENDIF
    WEND

    IF (mec_msg_level AND mec_msg_trace) THEN PRINT #mec_comms,"Trace(EC): EtherCAT slot:",next_slt[0]

    RETURN next_slt
ENDFUNC


' ********************************************************************
' Function: ec_get_num_slaves
'
FUNCTION ec_get_num_slaves( slt AS INTEGER ) AS INTEGER
    DIM num_slaves AS INTEGER = 0

    IF NOT ETHERCAT($3,slt,mec_vr_index) THEN
        IF (mec_msg_level AND mec_msg_err) THEN PRINT #mec_comms,"Err(EC): failed to read number of slaves on network."
    ELSE
        num_slaves = VR(mec_vr_index)
    ENDIF

    IF (mec_msg_level AND mec_msg_trace) THEN PRINT #mec_comms,"Trace(EC): EtherCAT number slaves:",num_slaves[0]

    RETURN num_slaves
ENDFUNC


' ********************************************************************
' EtherCAT Error status information
'


' ********************************************************************
' Function: ec_display_system_and_slv_errs
'
FUNCTION ec_display_system_and_slv_errs(slt AS INTEGER)

    DIM num_slaves AS INTEGER
    DIM esc_data AS INTEGER(2)

    DIM esc_reg AS INTEGER
    DIM i,pos AS INTEGER

    PRINT#mec_comms,"Display Network Slave Status Registers"

    num_slaves = ec_get_num_slaves(slt)


    'For each slave in the network
    FOR pos = 0 TO num_slaves-1

        PRINT#mec_comms,""
        PRINT#mec_comms, "Slave on slot ";slt[0];" at position ";pos[0]

        esc_reg = $300
        FOR i = 0 TO 3
            PRINT#mec_comms,"Port",i[0]
            PRINT#mec_comms,"Invalid Frame Counter"
            IF ec_get_esc_reg(slt, pos, esc_reg, 1, esc_data) THEN
                PRINT#mec_comms, "ESC 0x",HEX(esc_reg);" = "; esc_data(0)
                PRINT#mec_comms,""
            ENDIF
            esc_reg = esc_reg + 1

            PRINT#mec_comms,"Rx Error Counter"
            IF ec_get_esc_reg(slt, pos, esc_reg, 1, esc_data) THEN
                PRINT#mec_comms, "ESC 0x",HEX(esc_reg);" = "; esc_data(0)
                PRINT#mec_comms,""
            ENDIF
            esc_reg = esc_reg + 1

        NEXT i
        
        esc_reg = $308
        FOR i = 0 TO 3
            PRINT#mec_comms,"Port",i[0]
            PRINT#mec_comms,"Forwarded Rx Error Counter"
            IF ec_get_esc_reg(slt, pos, esc_reg, 1, esc_data) THEN
                PRINT#mec_comms, "ESC 0x",HEX(esc_reg);" = "; esc_data(0)
                PRINT#mec_comms,""
            ENDIF
        NEXT i

        esc_reg = $30C
        PRINT#mec_comms,"ECAT Processing Unit Error Counter"
        IF ec_get_esc_reg(slt, pos, esc_reg, 1, esc_data) THEN
            PRINT#mec_comms, "ESC 0x",HEX(esc_reg);" = "; esc_data(0)
            PRINT#mec_comms,""
        ENDIF

        esc_reg = $30D
        PRINT#mec_comms,"PDI Error Counter"
        IF ec_get_esc_reg(slt, pos, esc_reg, 1, esc_data) THEN
            PRINT#mec_comms, "ESC 0x",HEX(esc_reg);" = "; esc_data(0)
            PRINT#mec_comms,""
        ENDIF

        esc_reg = $30E
        PRINT#mec_comms,"SPI/uC PDI Error Counter"
        IF ec_get_esc_reg(slt, pos, esc_reg, 1, esc_data) THEN
            PRINT#mec_comms, "ESC 0x",HEX(esc_reg);" = "; esc_data(0)
            PRINT#mec_comms,""
        ENDIF

        esc_reg = $310
        FOR i = 0 TO 3
            PRINT#mec_comms,"Port",i[0]
            PRINT#mec_comms,"Lost Link Counter"
            IF ec_get_esc_reg(slt, pos, esc_reg, 1, esc_data) THEN
                PRINT#mec_comms, "ESC 0x",HEX(esc_reg);" = "; esc_data(0)
                PRINT#mec_comms,""
            ENDIF
            esc_reg = esc_reg + 1
        NEXT i

    NEXT pos

ENDFUNC


' ********************************************************************
' Controller EtherCAT Debug Information
'

' ********************************************************************
' Function: ec_display_nw_debug_stats
'
FUNCTION display_nw_debug_stats(slt AS INTEGER)

    ' Telegram, including wk cnt errors.
    PRINT #mec_comms,""
    PRINT #mec_comms,"Network Telegram Statistics:"
    PRINT ETHERCAT($1D0,slt,0)

    ' MAC stats
    PRINT #mec_comms,""
    PRINT #mec_comms,"MAC Statistics:"
    PRINT ETHERCAT($1D1,slt)

    ' Network status stats
    PRINT #mec_comms,""
    PRINT #mec_comms,"Network Status Statistics:"
    PRINT ETHERCAT($1D2,slt)

    ' Telegram Information
    PRINT #mec_comms,""
    PRINT #mec_comms,"Telegram Information:"
    PRINT ETHERCAT($1D3,slt)

ENDFUNC


' ********************************************************************
' Sandbox
'

FUNCTION get_string(addr, obj, si AS INTEGER)
    VR(100) = 0
    PRINT ETHERCAT($41, 0, addr, obj, si, 9, 30, 100)
    PRINT VRSTRING(100)
ENDFUNC

' check EC_EXTEND.  -1 means OK
FUNCTION cec()
    PRINT ETHERCAT($101)
ENDFUNC


' *******************************************************************************
' Read and display string CoE object (using the SDO mailbox service
' channel) using the vr variables to store the data object.
'
' Params:
'   comms: if > -1 then display result to given comm port.
'
' This function uses the Vrs to read the CoE object string (datatype VS),
' however it is also possible to read string into a TrioBASIC string.
'
FUNCTION display_sdo_string(slt, slv_addr, index, sub_index, str_len, vr_index, str_display, comms AS INTEGER) AS _
        BOOLEAN

    DIM i AS INTEGER
    DIM result AS BOOLEAN

    result = FALSE

    FOR i = 0 TO str_len
        VR(vr_index + i) = 0
    NEXT i

    'Params: slt,slv_addr,sdo_index,sdo_subindex,9,sdo_str_len,vr_index
    IF NOT ETHERCAT($41, slt, slv_addr, index, sub_index, 9, str_len, vr_index) THEN
        PRINT#comms, "Err: failed to read string, 0x"; HEX(index); ":"; sub_index[0]
    ELSE
        FOR i = 0 TO str_len
            IF m_sdo_str_display = k_disp_chr THEN
                ' chars
                IF VR(vr_index + i) = 0 THEN
                    i = str_len ' exit loop
                ELSE
                    PRINT#comms, CHR(VR(vr_index + i));
                ENDIF
            ELSEIF m_sdo_str_display = k_disp_int THEN
                ' ints
                PRINT#comms, (VR(vr_index + i)); " ";
            ELSEIF m_sdo_str_display = k_disp_hex THEN
                ' hex
                PRINT#comms, HEX(VR(vr_index + i)); " ";
            ENDIF
        NEXT i
        PRINT#comms, ""
        result = TRUE
    ENDIF

    RETURN result

ENDFUNC

' *******************************************************************************
' Read and display string CoE object (using the SDO mailbox service
' channel), using TrioBASIC string variable to store object.
'
' Params:
'   comms: if > -1 then display result to given comm port.
'
' This function uses a TrioBASIC string to read the CoE object string.
'
FUNCTION display_sdo_string_ex(slt, slv_addr, index, sub_index, str_len, str_display, comms AS INTEGER) AS _
        BOOLEAN

    DIM str_value AS STRING(256)
    DIM result AS BOOLEAN

    result = FALSE

    'Params: slt,slv_addr,sdo_index,sdo_subindex,9,sdo_str_len,vr_index
    IF ( str_len > 256 ) THEN
        PRINT#comms, "Err: requested string length exceeds max permitted value."
    ELSEIF NOT ETHERCAT($41, slt, slv_addr, index, sub_index, 9, str_len, str_value) THEN
        PRINT#comms, "Err: failed to read string, 0x"; HEX(index); ":"; sub_index[0]
    ELSE
        PRINT#comms,str_value
        PRINT#comms,"string length",LEN(str_value)
        PRINT#comms, ""
        result = TRUE
    ENDIF

    RETURN result

ENDFUNC

' *******************************************************************************
' Read and display string CoE object (using the SDO mailbox service
' channel) using the vr variables to store the data object.
'
' Params:
'   comms: if > -1 then display result to given comm port.
'
' This function uses the Vrs to read the CoE object string (datatype VS),
' however it is also possible to read string into a TrioBASIC string.
'
FUNCTION display_sdo_string_vr(slt, slv_addr, index, sub_index, str_len, vr_index, str_display, comms AS INTEGER) AS _
        BOOLEAN

    DIM i AS INTEGER
    DIM result AS BOOLEAN

    result = FALSE

    FOR i = 0 TO str_len
        VR(vr_index + i) = 0
    NEXT i

    'Params: slt,slv_addr,sdo_index,sdo_subindex,9,sdo_str_len,vr_index
    IF NOT ETHERCAT($41, slt, slv_addr, index, sub_index, 9, str_len, vr_index) THEN
        PRINT#comms, "Err: failed to read string, 0x"; HEX(index); ":"; sub_index[0]
    ELSE
        FOR i = 0 TO str_len
            IF m_sdo_str_display = k_disp_chr THEN
                ' chars
                IF VR(vr_index + i) = 0 THEN
                    i = str_len ' exit loop
                ELSE
                    PRINT#comms, CHR(VR(vr_index + i));
                ENDIF
            ELSEIF m_sdo_str_display = k_disp_int THEN
                ' ints
                PRINT#comms, (VR(vr_index + i)); " ";
            ELSEIF m_sdo_str_display = k_disp_hex THEN
                ' hex
                PRINT#comms, HEX(VR(vr_index + i)); " ";
            ENDIF
        NEXT i
        PRINT#comms, ""
        result = TRUE
    ENDIF

    RETURN result

ENDFUNC


'**********************************************************
'
' The express startup method does not explicitly clear drive
' signalled errors on startup, hence run routine to do this
' if necessary
' Note that default timeout is 100 msec
'
FUNCTION clear_drive_errors( slt, num_first_axis, num_last_axis, ec_timeout, comms AS INTEGER) AS BOOLEAN

    DIM result AS BOOLEAN
    DIM ax_reset AS INTEGER
    DIM ax AS INTEGER

    result = TRUE

    FOR ax = num_first_axis TO num_last_axis
        'Number of reset attempts
        ax_reset = 2
        'Check and reset axis and system error(s) if necessary
        WHILE (AXISSTATUS AXIS(ax)).3 AND (ax_reset > 0)
            PRINT#comms, "Resetting Axis error, axis",ax[0]
            ETHERCAT($64,ax,0,ec_timeout)
            WA(2)
            DATUM(0) AXIS(ax)
            WA(2)
            ax_reset = ax_reset-1
        WEND

        'Check for emergency message errors
        IF (SYSTEM_ERROR AND $100000) THEN
            UNIT_CLEAR
            'wait to ensure cleared before check again.
            WA(2)
        ENDIF

        IF (AXISSTATUS AXIS(ax)).3 OR (SYSTEM_ERROR AND $100000) THEN
            'Error - return error if any axis still in error.
            result = FALSE
        ENDIF
    NEXT ax

    RETURN result

ENDFUNC


