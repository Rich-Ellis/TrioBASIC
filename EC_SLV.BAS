' ************************************************************
' Trio Flexslice SII EEPROM Programmer
'
' Date : 14th Dec 2017
'
' Added in P375 rev 4, with microprocessor PDI control.
'

CONSTANT "comms", 5
' Trio Vendor ID
CONSTANT "vid_lsw", $02de
CONSTANT "vid_msw", 0


DIM p366_esi AS INTEGER(16) 'P366 Coupler
DIM p371_esi AS INTEGER(16) 'P371 16 DOUT PNP
DIM p372_esi AS INTEGER(16) 'P372 16 DIN PNP
DIM p374_esi AS INTEGER(16) 'P374 servo emulator
DIM p375_esi AS INTEGER(16) 'P375 3 axes stepper
DIM p376_esi AS INTEGER(16) 'P376 16 DOUT NPN
DIM p377_esi AS INTEGER(16) 'P377 16 DIN NPN
DIM p378_esi AS INTEGER(16) 'P378 Analog Output
DIM p379_esi AS INTEGER(16) 'P379 Analog Input
DIM p600_esi AS INTEGER(16) 'P600 Analog Input
DIM esi_data AS INTEGER(16) 'generic array

DIM flexslice AS STRING(16)

' Program Data
' Do not change these values.
vr_index = 100
sn_lsw = 0
sn_msw = 0
rn_lsw = 0
rn_msg = 0

' Slave Data
' Set these values depending upon slave under test
slt = 0
slv_pos = 0
'flexslice = "P374 'Servo emulator
'flexslice = "P378" 'aout
flexslice = "P366" '
ec_serial_number = $1
ec_revision = 1


GOSUB init

GOSUB config_esi
GOSUB display_esi_config
GOSUB write_slave_esi
'GOSUB write_estun_es8200
GOSUB read_slave_esi
STOP


read_slave_esi:
PRINT#comms, "Read SII Configuration data from slave"
PRINT#comms, "Pos", slv_pos[0]
FOR i = 0 TO 20 '$F
    IF ETHERCAT($61, slt, slv_pos, i, 2, vr_index) = TRUE THEN
        PRINT#comms, "0x"; HEX(i); ", = 0x"; HEX(VR(vr_index))
    ELSE
        PRINT#comms, "Error: failed to read slave at pos "; slv_pos[0]; ", addr 0x"; HEX(i)
    ENDIF

NEXT i
RETURN

' Setup programming data depending upon given flexslice type.
config_esi:
FOR i = 0 TO 15
    IF flexslice = "P366" THEN esi_data(i) = p366_esi(i)
    IF flexslice = "P371" THEN esi_data(i) = p371_esi(i)
    IF flexslice = "P372" THEN esi_data(i) = p372_esi(i)
    IF flexslice = "P374" THEN esi_data(i) = p374_esi(i)
    IF flexslice = "P375" THEN esi_data(i) = p375_esi(i)
    IF flexslice = "P376" THEN esi_data(i) = p376_esi(i)
    IF flexslice = "P377" THEN esi_data(i) = p377_esi(i)
    IF flexslice = "P378" THEN esi_data(i) = p378_esi(i)
    IF flexslice = "P379" THEN esi_data(i) = p379_esi(i)
    IF flexslice = "P600" THEN esi_data(i) = p600_esi(i)
NEXT i
RETURN

' Display programming data setup and ready to program slaves.
display_esi_config:
PRINT#comms, "Display SII Configuration Data"
FOR i = 0 TO $F
    PRINT#comms, "0x"; HEX(i); ", = 0x"; HEX(esi_data(i))
NEXT i
RETURN


write_slave_esi:
PRINT#comms, "Write ESI Configuration data to slave"
FOR i = 0 TO $F
    IF ETHERCAT($60, slt, slv_pos, i, 2, esi_data(i)) = TRUE THEN
        PRINT#comms, "0x"; HEX(i); ", = 0x"; HEX(esi_data(i))
    ELSE
        PRINT#comms, "Error: failed to write slave at pos "; slv_pos[0]; ", addr 0x"; HEX(i)
    ENDIF

NEXT i
RETURN

' Initialise database
init:

' Slave Data
sn_lsw = ec_serial_number AND $ffff
sn_msw = (ec_serial_number >> 16) AND $ffff
rn_lsw = ec_revision AND $ffff
rn_msg = (ec_revision >> 16) AND $ffff

' P366 - coupler
p366_esi(0) = $0100 'PDI Control - PDI deactivated (0x140:0x141)
p366_esi(1) = $0000 'PDI Configuration (0x150:0x151)
p366_esi(2) = $000A 'Pulse Length Sync Signal (0x982:0x983)
p366_esi(3) = $0000 'Extended PDI Configuration (0x152:0x153)
p366_esi(4) = $0000 'Configured Station Alias (0x012:0x013)
p366_esi(5) = $0000 'Reserved
p366_esi(6) = $0000 'Reserved
p366_esi(7) = $003D 'CRC
p366_esi(8) = vid_lsw 'Vendor ID (lsw)
p366_esi(9) = vid_msw 'Vendor ID (msw)
p366_esi(10) = $016E 'Product Code (lsw)
p366_esi(11) = $0000 'Product Code (msw)
p366_esi(12) = rn_lsw 'Revision Number (lsw)
p366_esi(13) = rn_msw 'Revision Number (msw)
p366_esi(14) = sn_lsw 'Serial number (lsw)
p366_esi(15) = sn_msw 'Serial Number (msw)

' P600 - F6-Nano coupler
p600_esi(0) = $0100 'PDI Control - PDI deactivated (0x140:0x141)
p600_esi(1) = $0000 'PDI Configuration (0x150:0x151)
p600_esi(2) = $000A 'Pulse Length Sync Signal (0x982:0x983)
p600_esi(3) = $0000 'Extended PDI Configuration (0x152:0x153)
p600_esi(4) = $0000 'Configured Station Alias (0x012:0x013)
p600_esi(5) = $0000 'Reserved
p600_esi(6) = $0000 'Reserved
p600_esi(7) = $003D 'CRC
p600_esi(8) = vid_lsw 'Vendor ID (lsw)
p600_esi(9) = vid_msw 'Vendor ID (msw)
p600_esi(10) = $0258 'Product Code (lsw)
p600_esi(11) = $0000 'Product Code (msw)
p600_esi(12) = rn_lsw 'Revision Number (lsw)
p600_esi(13) = rn_msw 'Revision Number (msw)
p600_esi(14) = sn_lsw 'Serial number (lsw)
p600_esi(15) = sn_msw 'Serial Number (msw)

' P371 - DOUT 16 PNP
p371_esi(0) = $0104 'PDI Control - PDI Digital I/O & DC (0x140:0x141)
p371_esi(1) = $0001 'PDI Configuration - active low (0x150:0x151)
p371_esi(2) = $0000 'Pulse Length Sync Signal (0x982:0x983)
p371_esi(3) = $00FF 'Extended PDI Configuration - digital outputs (0x152:0x153)
p371_esi(4) = $0000 'Configured Station Alias (0x012:0x013)
p371_esi(5) = $0000 'Reserved
p371_esi(6) = $0000 'Reserved
p371_esi(7) = $00BF 'CRC
p371_esi(8) = vid_lsw 'Vendor ID (lsw)
p371_esi(9) = vid_msw 'Vendor ID (msw)
p371_esi(10) = $0173 'Product Code (lsw)
p371_esi(11) = $0000 'Product Code (msw)
p371_esi(12) = rn_lsw 'Revision Number (lsw)
p371_esi(13) = rn_msw 'Revision Number (msw)
p371_esi(14) = sn_lsw 'Serial number (lsw)
p371_esi(15) = sn_msw 'Serial Number (msw)

' P376 - DOUT 16 NPN
p376_esi(0) = p371_esi(0)
p376_esi(1) = p371_esi(1)
p376_esi(2) = p371_esi(2)
p376_esi(3) = p371_esi(3)
p376_esi(4) = p371_esi(4)
p376_esi(5) = p371_esi(5)
p376_esi(6) = p371_esi(6)
p376_esi(7) = p371_esi(7)
p376_esi(8) = p371_esi(8)
p376_esi(9) = p371_esi(9)
p376_esi(10) = $0178 'Product Code (lsw) = 376
p376_esi(11) = $0000 'Product Code (msw)
p376_esi(12) = rn_lsw 'Revision Number (lsw)
p376_esi(13) = rn_msw 'Revision Number (msw)
p376_esi(14) = sn_lsw 'Serial number (lsw)
p376_esi(15) = sn_msw 'Serial Number (msw)

' P372 DIN 16 PNP
p372_esi(0) = $0104 'PDI Control - PDI Digital I/O & DC (0x140:0x141)
p372_esi(1) = $0001 'PDI Configuration - active low (0x150:0x151)
p372_esi(2) = $0000 'Pulse Length Sync Signal (0x982:0x983)
p372_esi(3) = $0000 'Extended PDI Configuration - digital inputs (0x152:0x153)
p372_esi(4) = $0000 'Configured Station Alias (0x012:0x013)
p372_esi(5) = $0000 'Reserved
p372_esi(6) = $0000 'Reserved
p372_esi(7) = $0064 'CRC
p372_esi(8) = vid_lsw 'Vendor ID (lsw)
p372_esi(9) = vid_msw'Vendor ID (msw)
p372_esi(10) = $0174 'Product Code (lsw) ( = 372)
p372_esi(11) = $0000 'Product Code (msw)
p372_esi(12) = rn_lsw 'Revision Number (lsw)
p372_esi(13) = rn_msw 'Revision Number (msw)
p372_esi(14) = sn_lsw 'Serial number (lsw)
p372_esi(15) = sn_msw 'Serial Number (msw)

' P374 - Servo emulator
' PDI control : SPI slave, esm emulation off (slave controls ESM changes),
' Enhanced link detection on, and DC sync out enabled. (Written to ESC 0x140:0x141)
p374_esi(0) = $0405
' PDI Configuration:
'ESC 0x150: SPI Mode 3, SPI_IRQ output driver/polarity: 00 - Push-Pull active low; SPI_SEL polarity: 0 - Active low;
'Data Out sample mode: 0 - Normal sample (SPI_DO and SPI_DI are sampled at the same SPI_CLK edge)
'ESC 0x151: active low, sync0 and sync1 active
p374_esi(1) = $4403
p374_esi(2) = $000A 'Pulse Length Sync Signal (0x982:0x983), 100 nsec
p374_esi(3) = $0000 'Extended PDI Configuration - (0x152:0x153)
p374_esi(4) = $0000 'Configured Station Alias (0x012:0x013)
p374_esi(5) = $0000 'Reserved
p374_esi(6) = $0000 'Reserved
p374_esi(7) = $00C1'CRC
p374_esi(8) = vid_lsw 'Vendor ID (lsw)
p374_esi(9) = vid_msw 'Vendor ID (msw)
p374_esi(10) = $0176 'Product Code (lsw)
p374_esi(11) = $0000 'Product Code (msw)
p374_esi(12) = rn_lsw 'Revision Number (lsw)
p374_esi(13) = rn_msw 'Revision Number (msw)
p374_esi(14) = sn_lsw 'Serial number (lsw)
p374_esi(15) = sn_msw 'Serial Number (msw)

' P377 DIN 16 NPN
p377_esi(0) = p372_esi(0)
p377_esi(1) = p372_esi(1)
p377_esi(2) = p372_esi(2)
p377_esi(3) = p372_esi(3)
p377_esi(4) = p372_esi(4)
p377_esi(5) = p372_esi(5)
p377_esi(6) = p372_esi(6)
p377_esi(7) = p372_esi(7)
p377_esi(8) = p372_esi(8)
p377_esi(9) = p372_esi(9)
p377_esi(10) = $0179 'Product Code (lsw) ( = 377)
p377_esi(11) = $0000 'Product Code (msw)
p377_esi(12) = rn_lsw 'Revision Number (lsw)
p377_esi(13) = rn_msw 'Revision Number (msw)
p377_esi(14) = sn_lsw 'Serial number (lsw)
p377_esi(15) = sn_msw 'Serial Number (msw)

' P375 - 3 Axes Stepper Output
IF (ec_revision < 4) THEN
    p375_esi(0) = $0505 'PDI Control - PDI SPI (0x140:0x141)
    p375_esi(1) = $4403 'PDI Configuration - active low (0x150:0x151)
    p375_esi(2) = $0005 'Pulse Length Sync Signal (0x982:0x983)
    p375_esi(3) = $0000 'Extended PDI Configuration - digital inputs (0x152:0x153)
    p375_esi(4) = $0000 'Configured Station Alias (0x012:0x013)
    p375_esi(5) = $0000 'Reserved
    p375_esi(6) = $0000 'Reserved
    p375_esi(7) = $0003 'CRC
ELSE
    'Use config as per servo emulator.
    p375_esi(0) = $0405 'PDI Control - PDI SPI (0x140:0x141)
    p375_esi(1) = $4403 'PDI Configuration - active low (0x150:0x151)
    p375_esi(2) = $000A 'Pulse Length Sync Signal (0x982:0x983)
    p375_esi(3) = $0000 'Extended PDI Configuration - digital inputs (0x152:0x153)
    p375_esi(4) = $0000 'Configured Station Alias (0x012:0x013)
    p375_esi(5) = $0000 'Reserved
    p375_esi(6) = $0000 'Reserved
    p375_esi(7) = $00C1 'CRC
ENDIF
p375_esi(8) = vid_lsw 'Vendor ID (lsw)
p375_esi(9) = vid_msw 'Vendor ID (msw)
p375_esi(10) = $0177 'Product Code (lsw)
p375_esi(11) = $0000 'Product Code (msw)
p375_esi(12) = rn_lsw 'Revision Number (lsw)
p375_esi(13) = rn_msw 'Revision Number (msw)
p375_esi(14) = sn_lsw 'Serial number (lsw)
p375_esi(15) = sn_msw 'Serial Number (msw)

' P378 - EtherCAT Analog output
' PDI control : SPI slave, esm emulation on (slave follows master requested ESM),
' Enhanced link detection on, and DC sync out enabled. (Written to ESC 0x140:0x141)
IF (ec_revision = 1) THEN
    p378_esi(0) = $0505
    p378_esi(7) = $0055'CRC
ELSE
    p378_esi(0) = $0405
    p378_esi(7) = $00C1'CRC
ENDIF

' PDI Configuration:
'ESC 0x150: SPI Mode 3, SPI_IRQ output driver/polarity: 00 - Push-Pull active low; SPI_SEL polarity: 0 - Active low;
'Data Out sample mode: 0 - Normal sample (SPI_DO and SPI_DI are sampled at the same SPI_CLK edge)
'ESC 0x151: active low, sync0 and sync1 active
p378_esi(1) = $4403
p378_esi(2) = $000A 'Pulse Length Sync Signal (0x982:0x983), 100 nsec
p378_esi(3) = $0000 'Extended PDI Configuration - (0x152:0x153)
p378_esi(4) = $0000 'Configured Station Alias (0x012:0x013)
p378_esi(5) = $0000 'Reserved
p378_esi(6) = $0000 'Reserved
p378_esi(8) = vid_lsw 'Vendor ID (lsw)
p378_esi(9) = vid_msw 'Vendor ID (msw)
p378_esi(10) = $017A 'Product Code (lsw)
p378_esi(11) = $0000 'Product Code (msw)
p378_esi(12) = rn_lsw 'Revision Number (lsw)
p378_esi(13) = rn_msw 'Revision Number (msw)
p378_esi(14) = sn_lsw 'Serial number (lsw)
p378_esi(15) = sn_msw 'Serial Number (msw)

IF (ec_revision = 1) THEN
    'Rev 1, no CoE, 2zSMs
    ' P379 - EtherCAT Analog input ( config as per analog output)
    p379_esi(0) = p378_esi(0)
    p379_esi(1) = p378_esi(1)
    p379_esi(2) = p378_esi(2)
    p379_esi(3) = p378_esi(3)
    p379_esi(4) = p378_esi(4)
    p379_esi(5) = p378_esi(5)
    p379_esi(6) = p378_esi(6)
    p379_esi(7) = p378_esi(7)
    p379_esi(8) = p378_esi(8)
    p379_esi(9) = p378_esi(9)
    p379_esi(10) = $017B 'Product Code (lsw)
    p379_esi(11) = $0000 'Product Code (msw)
    p379_esi(12) = rn_lsw 'Revision Number (lsw)
    p379_esi(13) = rn_msw 'Revision Number (msw)
    p379_esi(14) = sn_lsw 'Serial number (lsw)
    p379_esi(15) = sn_msw 'Serial Number (msw)
ELSE
    ' coe versions
' P379 - EtherCAT Analog input ( config as per analog output)
    p379_esi(0) = $0405
    p379_esi(1) = $4403
    p379_esi(2) = $000A
    p379_esi(3) = $0000
    p379_esi(4) = $0000
    p379_esi(5) = $0000
    p379_esi(6) = $0000
    p379_esi(7) = $00C1
    p379_esi(8) = $02DE
    p379_esi(9) = $0000
    p379_esi(10) = $017B 'Product Code (lsw)
    p379_esi(11) = $0000 'Product Code (msw)
    p379_esi(12) = rn_lsw 'Revision Number (lsw)
    p379_esi(13) = rn_msw 'Revision Number (msw)
    p379_esi(14) = sn_lsw 'Serial number (lsw)
    p379_esi(15) = sn_msw 'Serial Number (msw)
ENDIF


RETURN

test:

base_io = 24
num_io = 16

'num_io = 192
mask = 2 ^ 32 - 1
block_io = 16

IF num_io < block_io THEN block_io = num_io

WHILE TRUE

    FOR i = 0 TO num_io - 1 STEP 16
        OP(base_io + i, base_io + block_io + i, $FFFF)
        WA(100)
        OP(base_io + i, base_io + block_io + i, 0)
    NEXT i

    FOR i = 0 TO num_io - 1 STEP 16
        OP(base_io + i, base_io + block_io + i, $FFFF)
        WA(100)
    NEXT i
    WA(250)
    FOR i = 0 TO num_io - 1 STEP 16
        OP(base_io + i, base_io + block_io + i, $0000)
    NEXT i
    WA(250)

    FOR i = 0 TO num_io - 1
        OP(base_io + i, ON)
        WA(10)
        OP(base_io + i, OFF)
    NEXT i

WEND

RETURN

init_sm:

FOR i = 1 TO 12

    PRINT ETHERCAT($30, slt, i, $806, 2, 0)
    PRINT ETHERCAT($30, slt, i, $80E, 2, 0)

    PRINT ETHERCAT($30, slt, i, $802, 2, 1)
    PRINT ETHERCAT($30, slt, i, $80A, 2, 1)

    PRINT ETHERCAT($30, slt, i, $806, 2, 1)
    PRINT ETHERCAT($30, slt, i, $80E, 2, 1)

NEXT i
RETURN

init_fmmu:

'PRINT ETHERCAT($30,slt,slv_pos,$61C,1,0)
PRINT ETHERCAT($30, slt, slv_pos, $610, 2, 0)
PRINT ETHERCAT($30, slt, slv_pos, $612, 2, 0)
PRINT ETHERCAT($30, slt, slv_pos, $614, 2, 0)
PRINT ETHERCAT($30, slt, slv_pos, $616, 2, 0)
PRINT ETHERCAT($30, slt, slv_pos, $618, 2, 0)
PRINT ETHERCAT($30, slt, slv_pos, $61A, 2, 0)
PRINT ETHERCAT($30, slt, slv_pos, $61C, 2, 0)


RETURN







