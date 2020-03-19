

'TrioBASIC Constants
mem_vr = 1
mem_table = 2

' CIP spec, Vol1 sec C-6.1
int16 = $C3
int32 = $C4
uint16 = $C7
uint32 = $C8

'Program Contants
slt = -1

'Data

vr_index = 0

vr_index = 100
eip_add_tag("x_pos", mem_vr, vr_index, int16)

vr_index = vr_index + 1
eip_add_tag("y_pos", mem_vr, vr_index, uint16)

vr_index = vr_index + 1
eip_add_tag("z_pos", mem_vr, vr_index, int16)

GOSUB display_tags

HALT


display_tags:
eip_display_tags()

RETURN
