' ***************************************************************************************
' ProfiNET Demo Program
'
'
'
' Slot = -1 for internal profinet protocol support
'
' start protocol
' profinet(1,slt)
'
' Stop protocol
' profinet)(2,slt)
'
' Debug Information:
' profinet(5,slt,level)
' 0x00 : none
' 0x01 : errors
' 0x02 : warning
' 0x04 : info
' 0x08 : debug
'
' Configuration
' Display
' profinet(0,slt)



slt = -1

GOSUB pn_msg_level

GOSUB pn_config_trio2
PRINT"configured profinet"
GOSUB pn_display
PRINT"starting profinet"
GOSUB pn_start
PRINT"started profinet"
GOSUB pn_display

'GOSUB pn_main

STOP

' ***************************************************************************************
'
pn_config_trio:
' Configuration
' (func,slot,api,slot,sub-slot, data_source,index,type,count,direction [,endian])

'reset all
PRINT PROFINET(0,slt,-1)

'configuration
'signed 8 bit (Byte) sized
PRINT PROFINET(0,slt,0,1,1, 0,200,1,1,0,0) ' slot 1: vr(200), sint8, len 1, trio send
PRINT PROFINET(0,slt,0,2,1, 0,201,1,1,1,0) ' slot 2: vr(201), sint8, len 1, trio receive

PRINT PROFINET(0,slt,0,3,1, 0,202,1,1,0,0) ' slot 3: vr(202), sint8, len 1, trio send
PRINT PROFINET(0,slt,0,4,1, 0,203,1,1,1,0) ' slot 4: vr(203), sint8, len 1, trio receive

'signed 16 bit (word) sized (note endian swap)
PRINT PROFINET(0,slt,0,5,1, 0,204,2,1,0,1) ' slot 5: vr(204), sint16, len 1, trio send
PRINT PROFINET(0,slt,0,6,1, 0,205,2,1,1,1) ' slot 6: vr(205), sint16, len 1, trio receive

PRINT PROFINET(0,slt,0,7,1, 0,206,2,1,0,0) ' slot 7: vr(206), sint16, len 1, trio send
PRINT PROFINET(0,slt,0,8,1, 0,207,2,1,1,0) ' slot 8: vr(207), sint16, len 1, trio receive

'signed 32bit sized
PRINT PROFINET(0,slt,0,9,1, 0,208,3,1,0,0) ' slot 5: vr(208), sint32, len 1, trio send
PRINT PROFINET(0,slt,0,10,1, 0,209,3,1,1,0) ' slot 6: vr(209), sint32, len 1, trio receive

PRINT PROFINET(0,slt,0,11,1, 0,210,3,1,0,0) ' slot 7: vr(210), sint32, len 1, trio send
PRINT PROFINET(0,slt,0,12,1, 0,211,3,1,1,0) ' slot 8: vr(211), sint32, len 1, trio receive

'multiple values per slot

'unsigned

RETURN


' ***************************************************************************************
'
pn_config_trio2:
' Configuration
' (func,slot,api,profi_slot,profi_sub-slot, data_source,index,data_type,count,direction [,endian])
'  where
'   func
'       0 : add configuration
'   data_source
'       0: vr, 1: table
'   data type
'       1 : 8 bit signed int
'       2 : 16 bit signed int
'       3 : 32 bit signed int
'   count
'
'   direction
'       0: trio send
'       1: trio receive
'reset all
PRINT PROFINET(0,slt,-1)

basevr=200

'64 slots
FOR i = 1 TO 64 STEP 2

'32 slots - runs ok
'FOR i = 1 TO 32 STEP 2

'36 slots
'FOR i = 1 TO 34 STEP 2
    'signed 32bit sized
    ' func,slot,api,profinet_slot,sub_slot,data_source (0=vr),index,data_type,count,direction,endian)
    PRINT PROFINET(0,slt,0,i, 1,0,basevr+i,3,1,0,0)'sint32, len 1, trio send
    PRINT PROFINET(0,slt,0,i+1,1, 0,basevr+i+1,3,1,1,0)'sint32, len 1, trio receive

NEXT i

RETURN

' ***************************************************************************************
'
pn_start:
IF NOT PROFINET(1,slt) THEN
    PRINT "Error: failed to startup ProfiNET protocol."
ENDIF

RETURN

' ***************************************************************************************
'
pn_stop:
IF NOT PROFINET(2,slt) THEN
    PRINT "Error: failed to stop ProfiNET protocol."
ENDIF

RETURN

' ***************************************************************************************
'
pn_display:

' Display
' API Slot (sub-slot) : config
' where config is
'   data source: 0 = vr, 1 = table
'   Index : start position in data source
'   Data type :
'       pn_data_bool = 0,
'       pn_data_sint8 = 1,
'       pn_data_sint16 = 2,
'       pn_data_sint32 = 3,
'       pn_data_uint8 = 4,
'       pn_data_uint16 = 5,
'       pn_data_uint32 = 6,
'       pn_data_char = 7,
'       pn_data_enum = 8,
'       pn_data_sint64 = 16,
'       pn_data_uint64 = 17,
'       pn_data_float32 = 18
'   Elements (count) : number of datatypes mapped
'   Direction 0: TO (Trio Tx), 1: OT (Trio Rx)
'   Endian toggle 0: default, 1: swap

PROFINET(0,slt)

RETURN

' ***************************************************************************************
'
pn_msg_level:

'0x00 : none
'0x01 : errors
'0x02 : warning
'0x04 : info
'0x08 : debug
'set all
PROFINET(5,slt,$f)
RETURN


pn_main:
WDOG = ON
VR(200)=0
VR(204)=0
WHILE TRUE
    VR(200) = VR(200) + 1
    VR(204) = VR(204) - 1
    WA(500)
WEND


RETURN

