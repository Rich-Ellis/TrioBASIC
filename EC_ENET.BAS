DIM comms AS INTEGER = 5
DIM enet_offset AS INTEGER = $30be0000


'GOSUB display_all_mib
GOSUB display_mib

STOP


display_mib:

PRINT#comms,"*************************************************************"
PRINT#comms,"ENET1 Registers - Brief"

PRINT#comms,"Interrupts"
PRINT#comms,"EIR : 0x";
PRINT#comms,HEX(PEEK(enet_offset+$0004,4))

PRINT#comms,"EIMR : 0x";
PRINT#comms,HEX(PEEK(enet_offset+$0008,4))

PRINT#comms,"Control Registers"
PRINT#comms,"Control ECR  : 0x";
PRINT#comms,HEX(PEEK(enet_offset+$0024,4))

PRINT#comms,"Receive RCR  : 0x";
PRINT#comms,HEX(PEEK(enet_offset+$0084,4))

PRINT#comms,"Transmit TCR : 0x";
PRINT#comms,HEX(PEEK(enet_offset+$00C4,4))


PRINT#comms,""
PRINT#comms,"ENET1 Buffer"
PRINT#comms,"RDAR : 0x";
PRINT#comms,HEX(PEEK(enet_offset+$0010,4))
PRINT#comms,"TDAR : 0x";
PRINT#comms,HEX(PEEK(enet_offset+$0014,4))


PRINT#comms,""
PRINT#comms,"MIB Statistics"
PRINT#comms,""
PRINT#comms,"Tx Registers"
PRINT#comms,"Tx Packet Count Statistic Register";
PRINT#comms,":",PEEK(enet_offset+$0204,4)

PRINT#comms,"Frames Transmitted OK Statistic Register";
PRINT#comms,":",PEEK(enet_offset+$024C,4)

PRINT#comms,"Rx Registers"
PRINT#comms,"Rx Packet Count Statistic Register";
PRINT#comms,":",PEEK(enet_offset+$0284,4)

PRINT#comms,"Rx Packets with CRC/Align Error Statistic Register";
PRINT#comms,":",PEEK(enet_offset+$0290,4)

PRINT#comms,"Rx Packets Less Than 64 Bytes and Bad CRC Statistic";
PRINT#comms,":",PEEK(enet_offset+$029C,4)

PRINT#comms,"Rx Packets Greater Than MAX_FL Bytes and Bad CRC";
PRINT#comms,":",PEEK(enet_offset+$02A0,4)

PRINT#comms,"Frames Received OK Statistic Register";
PRINT#comms,":",PEEK(enet_offset+$02CC,4)

PRINT#comms,"Frames Received with CRC Error Statistic Register";
PRINT#comms,":",PEEK(enet_offset+$02D0,4)

PRINT#comms,"Frames Received with Alignment Error Statistic Register";
PRINT#comms,":",PEEK(enet_offset+$02D4,4)

PRINT#comms,"Receive FIFO Overflow Count Statistic Register";
PRINT#comms,":",PEEK(enet_offset+$02D8,4)

PRINT#comms,"Flow Control Pause Frames Received Statistic Register";
PRINT#comms,":",PEEK(enet_offset+$02DC,4)

RETURN


display_all_mib:

PRINT#comms,"*************************************************************"
PRINT#comms,"ENET1 Registers - Full"

PRINT#comms,"Interrupts"
PRINT#comms,"EIR : 0x";
PRINT#comms,HEX(PEEK(enet_offset+$0004,4))

PRINT#comms,"EIMR : 0x";
PRINT#comms,HEX(PEEK(enet_offset+$0008,4))

PRINT#comms,"Control Registers"
PRINT#comms,"Control ECR  : 0x";
PRINT#comms,HEX(PEEK(enet_offset+$0024,4))

PRINT#comms,"Receive RCR  : 0x";
PRINT#comms,HEX(PEEK(enet_offset+$0084,4))

PRINT#comms,"Transmit TCR : 0x";
PRINT#comms,HEX(PEEK(enet_offset+$00C4,4))


PRINT#comms,""
PRINT#comms,"ENET1 Buffer"
PRINT#comms,"RDAR : 0x";
PRINT#comms,HEX(PEEK(enet_offset+$0010,4))
PRINT#comms,"TDAR : 0x";
PRINT#comms,HEX(PEEK(enet_offset+$0014,4))


PRINT#comms,""
PRINT#comms,"MIB Statistics"
PRINT#comms,""
PRINT#comms,"Tx Registers"
PRINT#comms,"Tx Packet Count Statistic Register";
PRINT#comms,":",PEEK(enet_offset+$0204,4)

PRINT#comms,"Tx Broadcast Packets Statistic Register";
PRINT#comms,":",PEEK(enet_offset+$0208,4)

PRINT#comms,"Tx Multicast Packets Statistic Register";
PRINT#comms,":",PEEK(enet_offset+$020C,4)

PRINT#comms,"Tx Packets with CRC/Align Error Statistic Register";
PRINT#comms,":",PEEK(enet_offset+$0210,4)

PRINT#comms,"Tx Packets Less Than Bytes and Good CRC Statistic";
PRINT#comms,":",PEEK(enet_offset+$0214,4)

PRINT#comms,"Tx Packets GT MAX_FL bytes and Good CRC Statistic";
PRINT#comms,":",PEEK(enet_offset+$0218,4)

PRINT#comms,"Tx Packets Less Than 64 Bytes and Bad CRC Statistic";
PRINT#comms,":",PEEK(enet_offset+$021C,4)

PRINT#comms,"Tx Packets Greater Than MAX_FL bytes and Bad CRC";
PRINT#comms,":",PEEK(enet_offset+$0220,4)

PRINT#comms,"Tx Collision Count Statistic Register";
PRINT#comms,":",PEEK(enet_offset+$0224,4)

PRINT#comms,"Tx 64-Byte Packets Statistic Register";
PRINT#comms,":",PEEK(enet_offset+$0228,4)

PRINT#comms,"Tx 65- to 127-byte Packets Statistic Register";
PRINT#comms,":",PEEK(enet_offset+$022C,4)

PRINT#comms,"tx 128- TO 255-byte packets statistic register";
PRINT#comms,":",PEEK(enet_offset+$0230,4)

PRINT#comms,"Tx 256- to 511-byte Packets Statistic Register";
PRINT#comms,":",PEEK(enet_offset+$0234,4)

PRINT#comms,"Tx 512- to 1023-byte Packets Statistic Register";
PRINT#comms,":",PEEK(enet_offset+$0238,4)

PRINT#comms,"Tx 1024- to 2047-byte Packets Statistic Register";
PRINT#comms,":",PEEK(enet_offset+$023C,4)

PRINT#comms,"Tx Packets Greater Than 2048 Bytes Statistic Register";
PRINT#comms,":",PEEK(enet_offset+$0240,4)

PRINT#comms,"Tx Octets Statistic Register";
PRINT#comms,":",PEEK(enet_offset+$0244,4)

PRINT#comms,"Reserved Statistic Register";
PRINT#comms,":",PEEK(enet_offset+$0248,4)

PRINT#comms,"Frames Transmitted OK Statistic Register";
PRINT#comms,":",PEEK(enet_offset+$024C,4)

PRINT#comms,"Frames Transmitted with Single Collision Statistic Register";
PRINT#comms,":",PEEK(enet_offset+$0250,4)

PRINT#comms,"Frames Transmitted with Multiple Collisions Statistic";
PRINT#comms,":",PEEK(enet_offset+$0254,4)

PRINT#comms,"Frames Transmitted after Deferral Delay Statistic Register";
PRINT#comms,":",PEEK(enet_offset+$0258,4)

PRINT#comms,"Frames Transmitted with Late Collision Statistic Register";
PRINT#comms,":",PEEK(enet_offset+$025C,4)

PRINT#comms,"Frames Transmitted with Excessive Collisions Statistic";
PRINT#comms,":",PEEK(enet_offset+$0260,4)

PRINT#comms,"Frames Transmitted with Tx FIFO Underrun Statistic";
PRINT#comms,":",PEEK(enet_offset+$0264,4)

PRINT#comms,"Frames Transmitted with Carrier Sense Error Statistic";
PRINT#comms,":",PEEK(enet_offset+$0268,4)

PRINT#comms,"Reserved Statistic Register";
PRINT#comms,":",PEEK(enet_offset+$026C,4)

PRINT#comms,"Flow Control Pause Frames Transmitted Statistic Register";
PRINT#comms,":",PEEK(enet_offset+$0270,4)

PRINT#comms,"Octet Count for Frames Transmitted w/o Error Statistic";
PRINT#comms,":",PEEK(enet_offset+$0274,4)

PRINT#comms,"Rx Registers"
PRINT#comms,"Rx Packet Count Statistic Register";
PRINT#comms,":",PEEK(enet_offset+$0284,4)

PRINT#comms,"Rx Broadcast Packets Statistic Register";
PRINT#comms,":",PEEK(enet_offset+$0288,4)

PRINT#comms,"Rx Multicast Packets Statistic Register";
PRINT#comms,":",PEEK(enet_offset+$028C,4)

PRINT#comms,"Rx Packets with CRC/Align Error Statistic Register";
PRINT#comms,":",PEEK(enet_offset+$0290,4)

PRINT#comms,"Rx Packets with Less Than 64 Bytes and Good CRC";
PRINT#comms,":",PEEK(enet_offset+$0294,4)

PRINT#comms,"Rx Packets Greater Than MAX_FL and Good CRC Statistic";
PRINT#comms,":",PEEK(enet_offset+$0298,4)

PRINT#comms,"Rx Packets Less Than 64 Bytes and Bad CRC Statistic";
PRINT#comms,":",PEEK(enet_offset+$029C,4)

PRINT#comms,"Rx Packets Greater Than MAX_FL Bytes and Bad CRC";
PRINT#comms,":",PEEK(enet_offset+$02A0,4)

PRINT#comms,"Reserved Statistic Register";
PRINT#comms,":",PEEK(enet_offset+$02A4,4)

PRINT#comms,"Rx 64-Byte Packets Statistic Register";
PRINT#comms,":",PEEK(enet_offset+$02A8,4)

PRINT#comms,"Rx 65- to 127-Byte Packets Statistic Register";
PRINT#comms,":",PEEK(enet_offset+$02AC,4)

PRINT#comms,"Rx 128- to 255-Byte Packets Statistic Register";
PRINT#comms,":",PEEK(enet_offset+$02B0,4)

PRINT#comms,"Rx 256- to 511-Byte Packets Statistic Register";
PRINT#comms,":",PEEK(enet_offset+$02B4,4)

PRINT#comms,"Rx 512- to 1023-Byte Packets Statistic Register";
PRINT#comms,":",PEEK(enet_offset+$02B8,4)

PRINT#comms,"Rx 1024- to 2047-Byte Packets Statistic Register";
PRINT#comms,":",PEEK(enet_offset+$02BC,4)

PRINT#comms,"Rx Packets Greater than 2048 Bytes Statistic Register";
PRINT#comms,":",PEEK(enet_offset+$02C0,4)

PRINT#comms,"Rx Octets Statistic Register";
PRINT#comms,":",PEEK(enet_offset+$02C4,4)

PRINT#comms,"Frames not Counted Correctly Statistic Register";
PRINT#comms,":",PEEK(enet_offset+$02C8,4)

PRINT#comms,"Frames Received OK Statistic Register";
PRINT#comms,":",PEEK(enet_offset+$02CC,4)

PRINT#comms,"Frames Received with CRC Error Statistic Register";
PRINT#comms,":",PEEK(enet_offset+$02D0,4)

PRINT#comms,"Frames Received with Alignment Error Statistic Register";
PRINT#comms,":",PEEK(enet_offset+$02D4,4)

PRINT#comms,"Receive FIFO Overflow Count Statistic Register";
PRINT#comms,":",PEEK(enet_offset+$02D8,4)

PRINT#comms,"Flow Control Pause Frames Received Statistic Register";
PRINT#comms,":",PEEK(enet_offset+$02DC,4)

PRINT#comms,"Octet Count for Frames Received without Error Statistic";
PRINT#comms,":",PEEK(enet_offset+$02E0,4)

RETURN


clear_eib:
POKE(enet_offset+$0004,$ffffffff,4)
RETURN
