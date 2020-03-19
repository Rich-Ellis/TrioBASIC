' *************************************************************
' EtherCAT Diagnostics Program
'
' Note - this program requires the EC_LIB Ethercat library file.
'
' Revision History:
' 13 Oct 2015 - initial issue
' 12 Aug 2019 - Revised to use EtherCAT library file.
'  6 Mar 2020 - Read andd display SM Watchdog configuration.
' 19 Mar 2020 - added call to ec_display_nw_telegram_stats
'

DIM m_slt AS INTEGER = -1
DIM m_vr_index AS INTEGER = 200
DIM m_comms AS INTEGER = 0

' ****************************************************************************************
' Program Initialisation
'

' Initialise EtherCAT library, and configure vr index, comms channel, & message level
ec_ctor(m_vr_index, m_comms, $07)

' Get EtherCAT comms interface slot.
m_slt = ec_get_next_slot(-1)
IF m_slt = -1 THEN
    PRINT #m_comms, "Err: EtherCAT slot not found."
    STOP
ENDIF

' ****************************************************************************************
'
begin:

' Example to find and display all EtherCAT networks.
'GOSUB display_all_nws

' Network Configuration
ec_display_nw_config(m_slt)

'View topology, and hence check all expected slaves are
'present - and if not then we have idenified cable break.
GOSUB display_nw_topology

'Read and display CoE error code object (0x603F:00) of all slaves on network.
'ec_display_coe_slv_errs(m_slt)

'Read and display particular CoE object from all slaves on network.
'(Note that particular slave can be chosen by changing pos from -1 to
' pos of slave required.)
'ec_display_coe_value(m_slt,-1,$6040,0,4)

'ec_display_system_and_slv_errs(m_slt)

' Display slave infromation, slot = 1 slave at pos = 0
'ec_display_slv_interrupt(1,0)
'ec_display_slv_dc_config(1,0)
'ec_display_slv_dc_status(1,0)

' Display network link errors.
GOSUB display_nw_link_errs

'Display SM status
ec_display_sm_watchdog(slt)

' Display Trio firmware debug information
ec_display_nw_telegram_stats(slt)

STOP


' ************************************************************
' Enumerate and display all ethercat networks.
' Note that m_slt is left as -1.
'
display_all_nws:
' Get EtherCAT comms interface slot.
m_slt = ec_get_next_slot(-1)
WHILE m_slt > -1
    ec_display_nw_config(m_slt)
    m_slt = ec_get_next_slot(m_slt)
WEND
RETURN

' ************************************************************
' Display network link errors.
'
display_nw_link_errs:

'Display current link lost counters to the output stream.
ec_display_port_link_lost_cntrs(m_slt)

'Reset all counters to zero.
ec_reset_all_link_cntrs(m_slt)

RETURN

' ************************************************************
' Display network topology
' Provides ability to verify network layout, and slaves
' present.
display_nw_topology:

' Display nw topology and link status for each slave on network.
ec_display_nw_topology(m_slt)

RETURN