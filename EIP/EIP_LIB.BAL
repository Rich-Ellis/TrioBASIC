' ******************************************************************************
'
'EthernetIP Library
'
'
'

DIM m_comms AS INTEGER
DIM m_slot AS INTEGER
DIM m_vr_index AS INTEGER

m_comms = 5
m_slot = -1
m_vr_index = 100


' *******************************************************
'

FUNCTION eip_display_tags()
    GET_EIP_TAG
ENDFUNC


' Add EIP to the Store
' Params:
' mem: 1:vr, 2:table
' addr: address of vr/table entry to which the Tag is mapped
' dtype: data type of Tag, 3: UINT16, 4: UINT32, 7: INT16, 8: INT32
'
FUNCTION eip_add_tag(name AS STRING, mem AS INTEGER, addr AS INTEGER, dtype AS INTEGER)
    IF NOT SET_EIP_TAG(name,mem,addr,dtype) THEN
        PRINT#m_comms,"Failed to add EIP Tag '";name;"'"
    ELSE
        PRINT#m_comms,"Successfully added EIP Tag '";name;"'"
    ENDIF
ENDFUNC


' Delete all Tags
FUNCTION eip_reset_tags()
    SET_EIP_TAG
ENDFUNC


' *******************************************************
' Debug
' Slot based ethernetip() command handlers
'

FUNCTION eip_get_log_count() AS INTEGER
    IF ETHERNETIP($11,-1,m_vr_index) = -1 THEN
        RETURN VR(m_vr_index)
    ELSE
        RETURN -1
    ENDIF
ENDFUNC


' *******************************************************
' Slot based ethernetip() command handlers
' Tag handlers (use set/get_eip_tag() instead)
'

FUNCTION eip_display_tags_slt(slt AS INTEGER)
    ETHERNETIP($33,slt)
ENDFUNC


' Add EIP to the Store
' Params:
' mem: 1:vr, 2:table
' addr: address of vr/table entry to which the Tag is mapped
' dtype: data type of Tag, 3: UINT16, 4: UINT32, 7: INT16, 8: INT32
'
FUNCTION eip_add_tag_slt(slt AS INTEGER, name AS STRING, mem AS INTEGER, addr AS INTEGER, dtype AS INTEGER)
    IF NOT ETHERNETIP($30,slt,name,mem,addr,dtype) THEN
        PRINT#m_comms,"Failed to add EIP Tag '";name;"'"
    ELSE
        PRINT#m_comms,"Successfully added EIP Tag '";name;"'"
    ENDIF
ENDFUNC


' Delete all Tags
FUNCTION eip_reset_tags_slt(slt AS INTEGER)
    ETHERNETIP($32,slt)
ENDFUNC

