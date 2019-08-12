' ******************************************************************************
' Startup
'
' Revision
' 24th July 2019
'

'define constants
' Clear existing constants
CONSTANT

'Communication default output channel
CONSTANT "comms",5

'Define Message levels
CONSTANT "msg_none",$0
CONSTANT "msg_errors",$1
CONSTANT "msg_warnings",$2
CONSTANT "msg_info",$4
CONSTANT "msg_trace",$8

'Define server datatypes
CONSTANT "datatype_int16",0
CONSTANT "datatype_int32",1
CONSTANT "datatype_fp32",2
CONSTANT "datatype_fp64",3
CONSTANT "datatype_uint16",4

CONSTANT "startup_completed",TRUE
