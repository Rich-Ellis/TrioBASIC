' *************************************************************
' EtherCAT Diagnostics Program
'
' Date: 13th Oct 2015
'
' Notes
'
' DS402 Data Types : (used by co_read_axis and co_read)
' 0x01	Boolean
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

comms = 0
verbose = TRUE
m_return_err = FALSE


'm_slv_pos is offset from master, hence first slave  = 0
'm_slv_pos = 0
'm_slv_addr= 1
m_slv_pos = 0
m_slv_addr= 1

m_num_slaves = 0
m_slt = -1
m_max_slt = -1

vr_index=400

' Notes

' When reading SDO Values, object index:sub-index is passed in using :
sdo_index = 0
sdo_subindex = 0
'and result is passed back in vr with index
'vr_index

'string display (how should strings be displayed
str_chr = 0
str_int = 1
str_hex = 2
sdo_str_display = str_chr

'display format
disp_hex = 16
disp_dec = 10
disp_format = disp_hex

'
DIM err_msg AS STRING(100)


' ****************************************************************************************
' Program Initialisation
'
GOSUB set_ec_slot_number
GOSUB set_m_num_slaves

' ****************************************************************************************
' Display Network Debug Information
'
begin:

'GOSUB reset_status_counters


' Network Configuration
GOSUB display_nw_config


' Display nw topology and link status for each slave on network.
GOSUB nw_topology
GOSUB display_port_link_lost_counters
GOSUB display_slv_interrupt
'GOSUB display_slv_dc_config
'GOSUB display_slv_dc_status
'GOSUB display_slv_coe_dc_config
GOSUB display_system_slv_errs

HALT


' ****************************************************************************************
' API Library - Network Information

' ********************************************************************
'Find which slot the ethercat module is in, and record in program
'global 'm_slt' variable
set_ec_slot_number:

m_slt=-1
m_max_slt = 0

IF CONTROL = 432 OR CONTROL = 499 THEN
    m_slt = 0
ELSEIF CONTROL = 464 OR CONTROL = 266 OR CONTROL = 665 THEN
    m_max_slt = 8
ENDIF

i = 0
WHILE (i < m_max_slt) AND (m_slt = -1)
    IF COMMSTYPE SLOT(i) = 42 THEN
        m_slt = i
    ELSE
        i = i + 1
    ENDIF
WEND

RETURN

' ********************************************************************
set_m_num_slaves:
IF NOT ETHERCAT($3,m_slt,vr_index) THEN
    err_msg = "Err: failed to read number of slaves on network."
    GOSUB err_handler
ELSE
    m_num_slaves = VR(vr_index)
ENDIF

RETURN

' ********************************************************************
display_nw_state:
IF NOT ETHERCAT($6,m_slt,vr_index) THEN
    err_msg = "Err: failed to read network state."
    GOSUB err_handler
ELSE
    PRINT "Network ESM state is:    ";
    IF VR(vr_index)=0 THEN
        PRINT "Init"
    ELSEIF VR(vr_index)=1 THEN
        PRINT "Pre-operational"
    ELSEIF VR(vr_index)=2 THEN
        PRINT "Safe-operational"
    ELSEIF VR(vr_index)=3 THEN
        PRINT "Operational"
    ELSE
        PRINT "Unknown state"
    ENDIF
ENDIF

RETURN

display_slot:
PRINT "EtherCAT Module Slot Number:",m_slt[0]
RETURN

' ****************************************************************************************
' Display Network Configuration
'
display_nw_config:

GOSUB display_star_line
PRINT "Network Configuration"
PRINT ""

PRINT#comms,"Controller Servo Period:";SERVO_PERIOD[0]
GOSUB display_slot
GOSUB display_nw_state
PRINT#comms,"Number of Slaves on network:";m_num_slaves[0]

PRINT ""
PRINT "EtherCAT Network Information"
PRINT ""
ETHERCAT($87,m_slt)

PRINT ""
PRINT "Description of information above:"
PRINT "EtherCAT Configuration (slot)"
PRINT "Slave information: product name : pos on network, alias (switch) address, configured address"
PRINT "For axes = (axis number), for IO = addr:len, with inputs then outputs, digital then analogue"
PRINT ""

RETURN

' ****************************************************************************************
' API Library - General Display Handlers

display_star_line:
PRINT""
PRINT"*********************************************************************** "
PRINT""
RETURN

' ****************************************************************************************
' API Library - Slave Config Access
'

' NB could also get from ESC reg 10
get_slave_config_addr:
ec_slave_config_addr = -1
IF NOT ETHERCAT($4,m_slt,ec_slave_pos,vr_index) THEN
    err_msg = "Err: failed to get slave address, for slot "' + m_slt + ", slave at pos " + ec_slave_pos
    GOSUB err_handler
ELSE
    ec_slave_config_addr = VR(vr_index)
ENDIF

RETURN

' ****************************************************************************************
' API Library - ESC Access
'

' ********************************************************************
'
get_esc:
VR(vr_index) = 0
IF NOT ETHERCAT($31,m_slt,ec_slave_pos,esc_reg,esc_len,vr_index) THEN
    err_msg = "Err: failed to read ESC 0x" + HEX(esc_reg)
    GOSUB err_handler
ELSE
    esc_data = VR(vr_index)
ENDIF

RETURN

' ********************************************************************
'
set_esc:
IF NOT ETHERCAT($30,m_slt,ec_slave_pos,esc_reg,esc_len,esc_data) THEN
    err_msg = "Err: failed to set ESC 0x" + HEX(esc_reg) ' + "to value" + esc_data
    GOSUB err_handler
ENDIF

RETURN

' ********************************************************************
'
display_esc_reg_name:
IF esc_reg = $10 THEN
    PRINT#comms, "(Configured Station Address)"
ELSEIF esc_reg = $130 THEN
    PRINT#comms, "(AL Status)"
ELSEIF esc_reg = $134 THEN
    PRINT#comms, "(AL Code)"
ELSEIF (esc_reg AND $f0f) = $600 THEN
    PRINT#comms, "(FMMU Logical Address)"
ELSEIF (esc_reg AND $f0f) = $604 THEN
    PRINT#comms, "(FMMU Length)"
ELSEIF ((esc_reg AND $f0f) = $800) OR ((esc_reg AND $f0f) = $808) THEN
    PRINT#comms, "(SM Logical Address)"
ELSEIF ((esc_reg AND $f0f) = $802) OR ((esc_reg AND $f0f) = $80A) THEN
    PRINT#comms, "(SM Length)"
ELSEIF ((esc_reg AND $f0f) = $804) OR ((esc_reg AND $f0f) = $80c) THEN
    PRINT#comms, "(SM Control Reg)"
ELSEIF ((esc_reg AND $f0f) = $805) OR ((esc_reg AND $f0f) = $80d) THEN
    PRINT#comms, "(SM Status Reg)"
ELSEIF ((esc_reg AND $f0f) = $806) OR ((esc_reg AND $f0f) = $80e) THEN
    PRINT#comms, "(SM Activate Reg)"
ELSEIF ((esc_reg AND $f0f) = $807) OR ((esc_reg AND $f0f) = $80f) THEN
    PRINT#comms, "(SM PDI Control Reg)"
ELSE
    PRINT ""
ENDIF
RETURN

' ****************************************************************************************
' API Library - Diagnostics


' ********************************************************************
'
nw_topology:

on_trunk = TRUE
on_branch = FALSE

FOR i = 0 TO m_num_slaves-1

    ec_slave_pos = i
    esc_data = 0
    esc_reg = $110
    esc_len = 2
    GOSUB get_esc

    GOSUB get_slave_config_addr

    j = 0

    PRINT#comms,"Slave at Pos",i[0],"Configured Address",ec_slave_config_addr[0]
    IF NOT esc_data.4 THEN PRINT#comms,"Error port 0 not open"

    IF esc_data.5 THEN
        IF on_trunk THEN PRINT#comms,"On Trunk"
        IF on_branch THEN PRINT#comms,"On Branch"
        j = j + 1
    ENDIF

    IF esc_data.6 THEN
        PRINT#comms,"Start Branch on Port 2"
        j = j + 1
        on_trunk = FALSE
        on_branch = TRUE
    ENDIF

    IF esc_data.7 THEN
        PRINT#comms,"Start Branch on Port 3"
        j = j + 1
        on_trunk = FALSE
        on_branch = TRUE
    ENDIF

    IF j = 0 THEN
        IF on_trunk THEN PRINT#coms,"On Trunk"
        PRINT#coms,"End of the line"
        on_branch = FALSE
        on_trunk = TRUE
    ENDIF


    PRINT#comms,""

NEXT i

RETURN


' ********************************************************************
'
reset_status_counters:

esc_data = 0
FOR i = 0 TO m_num_slaves-1
    ec_slave_pos = i

    ' All link lost counters are reset by a write to any one of them
    esc_reg = $310
    esc_len = 1
    GOSUB set_esc

    'rx error, invalid frame, port fwd error counters
    esc_reg = $300
    esc_len = 1
    GOSUB set_esc

NEXT i

RETURN


' ********************************************************************
'
' Notes:
'
' Link lost (0x110 bits 4..7 only counts if loop is auto, and open.)
'
' Stable Comms Check: if in standard link detection mode then it only
' reflects the link status. If in enhanced link detection on an MII,
' the bit is reset if PHY detects > 32 RX_ER events in 10 usec. If in
' enhanced link detection using EBUS stablility based on handshake
' protocol between nodes.
'
'
'
'
display_port_link_lost_counters:

on_trunk = TRUE
on_branch = FALSE
DIM link_lost AS INTEGER(4)
DIM link_stable AS INTEGER(4)
DIM link_open AS INTEGER(4)

DIM invalid_frame_count AS INTEGER(4)
DIM rx_error_count AS INTEGER(4)
DIM port_fwd_error_count AS INTEGER(4)

FOR i = 0 TO m_num_slaves-1

    link_open = 0,0,0,0
    link_stable = 0,0,0,0
    num_ports_open = 0
    j = 0

    ec_slave_pos = i

    GOSUB get_slave_config_addr
    PRINT#comms,"Slave at Pos",i[0],"Configured Address",ec_slave_config_addr[0]

    esc_data = 0
    esc_reg = $110
    esc_len = 2
    GOSUB get_esc
    link_data = esc_data

    ' Port 0
    link_open(j) = link_data.4
    link_stable(j) = link_data.9
    j = j + 1

    ' Port 1
    link_open(j) = link_data.5
    link_stable(j) = link_data.11
    IF link_data.5 THEN
        IF on_trunk THEN PRINT#comms,"On Trunk"
        IF on_branch THEN PRINT#comms,"On Branch"
        num_ports_open = num_ports_open + 1
    ENDIF
    j = j + 1

    ' Port 2
    link_open(j) = link_data.6
    link_stable(j) = link_data.13
    IF link_data.6 THEN
        PRINT#comms,"Start Branch on Port 2"
        on_trunk = FALSE
        on_branch = TRUE
        num_ports_open = num_ports_open + 1
    ENDIF
    j = j + 1

    ' Port 3
    link_open(j) = link_data.7
    link_stable(j) = link_data.15
    IF link_data.7 THEN
        PRINT#comms,"Start Branch on Port 3"
        on_trunk = FALSE
        on_branch = TRUE
        num_ports_open = num_ports_open + 1
    ENDIF
    j = j + 1

    IF num_ports_open = 0 THEN
        IF on_trunk THEN PRINT#coms,"On Trunk"
        PRINT#coms,"End of the line"
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
        esc_data = 0
        esc_len = 1
        esc_reg = $310 + j
        GOSUB get_esc
        link_lost(j) = esc_data

        'Invalid frame and Rx error counter
        esc_data = 0
        esc_len = 2
        esc_reg = $300 + j
        GOSUB get_esc
        invalid_frame_count(j) = esc_data AND $FF
        rx_error_count(j) = (esc_data >> 8 ) AND $FF

        'Port Forwarding Error
        esc_data = 0
        esc_len = 2
        esc_reg = $308 + j
        GOSUB get_esc
        port_fwd_error_count(j) = esc_data

    NEXT j

    'ECAT Processing Unit Error
    esc_data = 0
    esc_len = 1
    esc_reg = $30C
    m_return_err = TRUE
    GOSUB get_esc
    IF LEN(err_msg) > 0 THEN
        ecat_proc_error_count = -1
    ELSE
        ecat_proc_error_count = esc_data
    ENDIF
    m_return_err = FALSE

    ' Display Data
    FOR j = 0 TO 3

        PRINT#comms,"Port ";j[0];":";
        IF link_open(j) THEN
            PRINT#comms, " Open:  ";
        ELSE
            PRINT#comms, " Closed:";
        ENDIF

        IF link_open(j) THEN
            PRINT#comms," link lost ";link_lost(j)[0];", Stable ";link_stable(j)[0]

            PRINT#comms,"                ";
            PRINT#comms,"rx errors ";rx_error_count(j)[0];", invalid frames ";invalid_frame_count(j)[0]

            PRINT#comms,"                ";
            PRINT#comms,"fwd errors ";port_fwd_error_count(j)[0]

        ELSE
            PRINT#comms,""
        ENDIF

        IF j = 0 AND link_open(j)=0 THEN PRINT#comms,"ERROR, Port 0 not open"
        IF link_open(j)=1 AND link_stable(j)=0 THEN PRINT#comms,"ERROR, Port open but not stable"

    NEXT j

    PRINT#comms,"ECAT Processing frame errors ";ecat_proc_error_count[0]

    PRINT#comms,""

NEXT i

RETURN

' ****************************************************************************************
' API Library - Synchronisation Diagnostics

' ********************************************************************
'


' ********************************************************************
' Read Slave DC Configuration Configuration
'
display_slv_dc_config:
GOSUB display_star_line

PRINT#comms, "Display Slave ESC Distributed Clock Configuration"
PRINT#comms, "Slave on slot ";m_slt[0];" at position ";m_slv_pos[0]
PRINT#comms,""

ec_slave_pos = m_slv_pos

disp_format = disp_hex

'DC Sync Out Unit
PRINT#comms,"Enable DC Sync Out (ESC 0x140)"
PRINT#comms,"Reg 0x140 and 0x141 are loaded from SII address 0"
PRINT#comms,"0x141.2 = 1 to Enable DC Sync out unit."
esc_reg = $140
esc_len = 2
GOSUB read_esc
PRINT#comms,""

' Sync/Latch PDI Config Register (initialised by SII)
PRINT#comms,"Sync/Latch PDI Config Register (ESC 0x151)"
PRINT#comms,"Reg 0x150 and 0x151 are loaded from SII address 1"
PRINT#comms,"0x151:0,1 = b10 for push pull active high. 0x151:0,1 = b11 for open source active high."
PRINT#comms,"0x151.2 = 1 for sync0 output"
PRINT#comms,"0x151.3 = 1 TO enable sync0 mapped to AL event regsiter 0x0220.2, = 0 disabled"
esc_reg = $151
esc_len = 1
GOSUB read_esc
PRINT#comms,""

'Pulse Length register (initialised by SII Addr. 2)
PRINT#comms,"Pulse Length register (ESC 0x982:0x983)"
PRINT#comms,"Reg 0x982:0x983 are loaded from SII address 2"
esc_reg = $982
esc_len = 2
GOSUB read_esc
PRINT#comms,""

'Assign Sync Unit to ECAT or PDI
PRINT#comms,"Assign Sync Unit to ECAT or PDI (ESC 0x980)"
PRINT#comms,"Reg 0x980 is set by Master"
PRINT#comms,"0x980.0 = 0 for ECAT or = 1 for PDI control."
esc_reg = $980
esc_len = 1
GOSUB read_esc
PRINT#comms,""

' Set Cyclic Time of Sync 0
PRINT#comms,"Cyclic Time of Sync0"
PRINT#comms,"Sync0 Cycle Time: Reg 0x9A0:0x9A3 are set by Master"
esc_reg = $9A0
esc_len = 4
disp_format = disp_dec
GOSUB read_esc
PRINT#comms,""
disp_format = disp_hex

' Set Cyclic Time of Sync 1
PRINT#comms,"Sync1 Cycle Time: Reg 0x9A4:0x9A7 are set by Master"
PRINT#comms,"Note that this value is the delay after the Sync0 at which point the sync1 is triggered"
esc_reg = $9A4
esc_len = 4
GOSUB read_esc
PRINT#comms,""

' Set Start time of cyclic operation (NB must have been greater than
' current time, and allow for writing start time and activation)
PRINT#comms,"DC Start time"
PRINT#comms,"Reg 0x990:0x997 are set by Master"
esc_reg = $990
esc_len = 8
GOSUB read_esc
PRINT#comms,""

'Activate cyclic operation
PRINT#comms,"Activate Cyclic Operation"
PRINT#comms,"Reg 0x981 is set by Master"
PRINT#comms,"Set 0x981.0 to activate Sync signals, and 0x981.1 for Sync 0 and 0x981.2 for Sync1"
esc_reg = $981
esc_len = 1
GOSUB read_esc
PRINT#comms,""

PRINT#comms,""

RETURN

' ********************************************************************
' Read Slave DC Configuration Status
'
display_slv_dc_status:
GOSUB display_star_line

PRINT#comms, "Display Slave ESC Distributed Clock Status"
PRINT#comms, "Slave on slot ";m_slt[0];" at position ";m_slv_pos[0]
PRINT#comms,""

ec_slave_pos = m_slv_pos

disp_format = disp_hex

'AL Status and Error Code
PRINT#comms,"AL Status (ESC 0x130)"
esc_reg = $130
esc_len = 2
GOSUB read_esc
PRINT#comms,""

'AL Status and Error Code
PRINT#comms,"AL Error Status (ESC 0x134)"
esc_reg = $134
esc_len = 2
GOSUB read_esc
PRINT#comms,""

'System Time Diff
PRINT#comms,"System Time Diff (ESC 0x92C)"
esc_reg = $92c
esc_len = 4
GOSUB read_esc
PRINT#comms,""


PRINT#comms,""

RETURN


' ****************************************************************************************
' Display Slave CoE DC Configuration
'
'Data

display_slv_coe_dc_config:

GOSUB display_star_line
PRINT#comms, "Display Slave CoE Distributed Clock Configuration"
PRINT#comms, "Slave on slot ";slt[0];" at position ";slv_pos[0]
PRINT#comms,""

disp_format = disp_dec

PRINT#comms,"Network Cycle Time"
sdo_index = $1c32
sdo_subindex = 2
sdo_type = 4
GOSUB read_sdo
PRINT#comms,""

PRINT#comms,"Slave Min Cycle Time"
sdo_index = $1c32
sdo_subindex = 5
sdo_type = 4
GOSUB read_sdo
PRINT#comms,""

PRINT#comms,"Input Shift Time"
sdo_index = $1c33
sdo_subindex = 3
sdo_type = 4
GOSUB read_sdo
PRINT#comms,""

PRINT#comms,"Output Shift Time"
sdo_index = $1c32
sdo_subindex = 3
sdo_type = 4
GOSUB read_sdo
PRINT#comms,""

PRINT#comms,"Input Calc and Copy Time"
sdo_index = $1c33
sdo_subindex = 6
sdo_type = 4
GOSUB read_sdo
PRINT#comms,""

PRINT#comms,"Output Calc and Copy Time"
PRINT#comms,"(Min time between slave rx telegram and sync0"
sdo_index = $1c32
sdo_subindex = 6
sdo_type = 4
GOSUB read_sdo
PRINT#comms,""

PRINT#comms,"Input Delay Time"
sdo_index = $1c33
sdo_subindex = 9
sdo_type = 4
GOSUB read_sdo
PRINT#comms,""

PRINT#comms,"Output Delay Time"
sdo_index = $1c32
sdo_subindex = 9
sdo_type = 4
GOSUB read_sdo
PRINT#comms,""


PRINT#comms,"Input Sync Error"
sdo_index = $1c33
sdo_subindex = 32
sdo_type = 4
GOSUB read_sdo
PRINT#comms,""

PRINT#comms,"Output Sync Error"
sdo_index = $1c32
sdo_subindex = 32
sdo_type = 4
GOSUB read_sdo
PRINT#comms,""

disp_format = disp_hex

RETURN


' ****************************************************************************************
' Display system slave error registers

display_system_slv_errs:

GOSUB display_star_line
PRINT#comms,"Display Network Slave Status Registers"

IF NOT ETHERCAT($3,slt,vr_index) THEN
    PRINT "Err: reading slave ESC status registers - failed to read number of slaves on network."
ELSE
    num_slvs = VR(vr_index)
ENDIF

orig_slv_pos = slv_pos

'For each slave in the network
FOR j = 0 TO num_slvs-1

    slv_pos = j

    PRINT#comms,""
    PRINT#comms, "Slave on slot ";slt[0];" at position ";slv_pos[0]

    '
    esc_reg = $300
    esc_len = 1
    FOR i = 0 TO 3
        PRINT#comms,""
        PRINT#comms,"Port",i[0]
        PRINT#comms,"Invalid Frame Counter"
        GOSUB read_esc
        esc_reg = esc_reg + 1

        PRINT#comms,"Rx Error Counter"
        GOSUB read_esc
        esc_reg = esc_reg + 1

    NEXT i


    '
    esc_reg = $308
    esc_len = 1
    FOR i = 0 TO 3
        PRINT#comms,""
        PRINT#comms,"Port",i[0]
        PRINT#comms,"Forwarded Rx Error Counter"
        GOSUB read_esc
        esc_reg = esc_reg + 1
    NEXT i

    '
    esc_reg = $30C
    esc_len = 1
    PRINT#comms,""
    PRINT#comms,"ECAT Processing Unit Error Counter"
    GOSUB read_esc

    '
    esc_reg = $30D
    esc_len = 1
    PRINT#comms,""
    PRINT#comms,"PDI Error Counter"
    GOSUB read_esc

    esc_reg = $30E
    esc_len = 1
    PRINT#comms,""
    PRINT#comms,"SPI/uC PDI Error Counter"
    GOSUB read_esc

    '
    esc_reg = $310
    esc_len = 1
    FOR i = 0 TO 3
        PRINT#comms,""
        PRINT#comms,"Port",i[0]
        PRINT#comms,"Lost Link Counter"
        GOSUB read_esc
        esc_reg = esc_reg + 1
    NEXT i

NEXT j

slv_pos = orig_slv_pos

RETURN

' ********************************************************************
' Read Slave Interrupt Configuration Status
'
display_slv_interrupt:
GOSUB display_star_line

PRINT#comms, "Display Slave ESC Distributed Clock Status"
PRINT#comms, "Slave on slot ";m_slt[0];" at position ";m_slv_pos[0]
PRINT#comms,""

ec_slave_pos = m_slv_pos

disp_format = disp_hex

'
PRINT#comms,"ECAT Event Mask (ESC 0x200=0x201)"
esc_reg = $200
esc_len = 2
GOSUB read_esc
PRINT#comms,""

'AL
PRINT#comms,"PDI AL Event Mask (ESC 0x204-0x207)"
esc_reg = $204
esc_len = 4
GOSUB read_esc
PRINT#comms,""

'
PRINT#comms,"ECAT Event Request (ESC 0x210-0x211)"
esc_reg = $210
esc_len = 2
GOSUB read_esc
PRINT#comms,""

PRINT#comms,"AL ECAT Event Request (ESC 0x220-0x223)"
esc_reg = $220
esc_len = 4
GOSUB read_esc
PRINT#comms,""

PRINT#comms,"AL Control (ESC 0x120)"
esc_reg = $120
esc_len = 2
GOSUB read_esc
PRINT#comms,""

PRINT#comms,"AL Status (ESC 0x130)"
esc_reg = $130
esc_len = 2
GOSUB read_esc
PRINT#comms,""

PRINT#comms,"AL Status Code (ESC 0x134)"
esc_reg = $134
esc_len = 2
GOSUB read_esc
PRINT#comms,""


PRINT#comms,""

RETURN

' ****************************************************************************************
' API Library - Diagnostics
err_handler:

'If we are not returning the error to the caller, then process here.
IF NOT m_return_err THEN
    PRINT#comms,err_msg
    HALT
ENDIF
RETURN

' ****************************************************************************************
' API Library - CoE Application Layer Access
'

' ********************************************************************
'
read_sdo:
VR(vr_index) = 0
IF NOT ETHERCAT($41,m_slt,m_slv_addr,sdo_index,sdo_subindex,sdo_type,vr_index) THEN
    PRINT#comms, "Err: failed to read SDO 0x";HEX(sdo_index);":";HEX(sdo_subindex)
ELSE
    PRINT#comms, "SDO 0x";HEX(sdo_index);":";HEX(sdo_subindex),"= ";
    IF disp_format = disp_hex THEN
        PRINT#comms,"0x";HEX(VR(vr_index))
    ELSE
        PRINT#comms,VR(vr_index)[0]
    ENDIF
ENDIF

RETURN


' ********************************************************************
'
read_esc:
VR(vr_index) = 0
IF NOT ETHERCAT($31,m_slt,m_slv_pos,esc_reg,esc_len,vr_index) THEN
    PRINT#comms, "Err: failed to read ESC 0x";HEX(esc_reg)
ELSE
    PRINT#comms, "ESC 0x";HEX(esc_reg),"= ";
    IF disp_format = disp_hex THEN
        PRINT#comms,"0x";HEX(VR(vr_index));
    ELSE
        PRINT#comms,VR(vr_index)[0]
    ENDIF
    PRINT#comms," ";
    GOSUB display_esc_reg_name
ENDIF

RETURN

