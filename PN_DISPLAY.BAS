
slt=-1

' ***************************************************************************************
'
pn_display:

' Display
' API Slot (sub-slot) : config
' where config is
'   active
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




