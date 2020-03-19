' *************************************************************
' Ethernetip Status
'
' v1.0 20th June 2018, Hefei
'
' Note : use ethernetip($12,slt) to reset error log.

vr_index = 0
slt = -1
comms =5

' Introduction
PRINT#comms,"EtherNet/IP Status"

'Check EIP connection status
FOR i = 0 TO 3
    IF NOT ETHERNETIP(2,slt,i,vr_index) THEN
        PRINT#comms,"ETHIP : failed to read cnx handle",i[0]
    ELSE
        SELECT_CASE i
            CASE 0
                PRINT#comms,"ETHIP TCP1: ",VR(vr_index)[0]
            CASE 1
                PRINT#comms,"ETHIP TCP2: ",VR(vr_index)[0]
            CASE 2
                PRINT#comms,"ETHIP UDP : ",VR(vr_index)[0]
            CASE 3
                PRINT#comms,"ETHIP IO  : ",VR(vr_index)[0]
            CASE ELSE
                PRINT#comms,"ETHIP : unknown cnx handle",i[0]
        END_CASE
    ENDIF
NEXT i

'Check EIP error log
IF NOT ETHERNETIP($11,slt,vr_index) THEN
    PRINT#comms,"ETHIP : failed to read error log count"
ELSEIF VR(vr_index)= 0 THEN
    PRINT#comms,"ETHIP : error log empty"
ELSE
    num_entries = VR(vr_index)
    FOR i = 0 TO num_entries-1
        IF NOT ETHERNETIP($10,slt,i,vr_index) THEN
            PRINT#comms,"ETHIP : failed to read error log entry",i[0]
        ELSE
            PRINT#comms,"ETHIP : error log entry",i[0],"error code",VR(vr_index)[0],"(0x";HEX(VR(vr_index));")"
        ENDIF
    NEXT i
ENDIF


