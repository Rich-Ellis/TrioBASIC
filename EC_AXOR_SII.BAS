' ************************************************************
' Trio Axor SII EEPROM Programmer
'
' Date    : 6th June 2019
' Version : 1.0.0
'
' Notes
' 1. This program enables the base 8 addresses of a slaves SII
'    to be read and updated.
' 2. Set slv_pos to the position of the slave to be updated.
' 3. enable the call to write_slave_esi() to update the slave SII.
'

CONSTANT "comms", 5


DIM slv_esi AS INTEGER(8) 'Axor EEPROM
DIM slt AS INTEGER = 0
DIM slv_pos AS INTEGER = 0
DIM vr_index AS INTEGER = 100 ' Used for keyword status return


' Slave Data
' Set these values depending upon slave under test
slt = 0
slv_pos = 0


GOSUB config_esi
GOSUB display_esi_config
' Uncomment this line to program the slave drive SII
'GOSUB write_slave_esi
GOSUB read_slave_esi
STOP


read_slave_esi:
PRINT#comms, "Read SII Configuration data from slave"
PRINT#comms, "Pos", slv_pos[0]
FOR i = 0 TO 7
    IF ETHERCAT($61, slt, slv_pos, i, 2, vr_index) = TRUE THEN
        PRINT#comms, "0x"; HEX(i); ", = 0x"; HEX(VR(vr_index))
    ELSE
        PRINT#comms, "Error: failed to read slave at pos "; slv_pos[0]; ", addr 0x"; HEX(i)
    ENDIF

NEXT i
RETURN

' Setup programming data depending upon given flexslice type.
config_esi:

' Axor
slv_esi(0) = $0C08 'PDI Control - PDI deactivated (0x140:0x141)
slv_esi(1) = $EE02 'PDI Configuration (0x150:0x151)
slv_esi(2) = $0000 'Pulse Length Sync Signal (0x982:0x983)
slv_esi(3) = $0000 'Extended PDI Configuration (0x152:0x153)
slv_esi(4) = $0000 'Configured Station Alias (0x012:0x013)
slv_esi(5) = $0000 'Reserved
slv_esi(6) = $0000 'Reserved
slv_esi(7) = $007E 'CRC

RETURN

' Display programming data setup and ready to program slaves.
display_esi_config:
PRINT#comms, "Display SII Configuration Data"
FOR i = 0 TO 7
    PRINT#comms, "0x"; HEX(i); ", = 0x"; HEX(slv_esi(i))
NEXT i
RETURN


write_slave_esi:
PRINT#comms, "Write ESI Configuration data to slave"
FOR i = 0 TO 7
    IF ETHERCAT($60, slt, slv_pos, i, 2, slv_esi(i)) = TRUE THEN
        PRINT#comms, "0x"; HEX(i); ", = 0x"; HEX(slv_esi(i))
    ELSE
        PRINT#comms, "Error: failed to write slave at pos "; slv_pos[0]; ", addr 0x"; HEX(i)
    ENDIF

NEXT i
RETURN








