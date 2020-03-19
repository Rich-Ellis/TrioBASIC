' ********************************************************************
' Mailbox Test
' GD
' Version 1.0

' timing test for CO_READ_AXIS

DIM counter AS INTEGER
DIM comms AS INTEGER = 5
DIM vr_base AS INTEGER = 200
DIM co_index AS INTEGER
DIM co_sub AS INTEGER
DIM co_size AS INTEGER
DIM mintime AS INTEGER
DIM maxtime AS INTEGER
DIM eflag AS INTEGER
DIM eaxis AS INTEGER
DIM enode AS INTEGER
DIM t AS INTEGER

DIM i AS INTEGER

enode = 1
eaxis = 1

vr_base = 20

co_index = $6061
co_sub = 0
co_size = 4

SYSTEM_LOAD_MAX = 0

eflag = TRUE
TICKS = 0
FOR i = 0 TO 999
    IF eflag = FALSE THEN
        VR(vr_base + 1) = VR(vr_base + 1) + 1
    ENDIF
NEXT i
VR(vr_base + 2) = -TICKS

mintime = 1000
maxtime = 0
TRIGGER

TICKS = 0
counter = 0

WHILE TRUE

    FOR i = 0 TO 999
        TICKS = 0
        eflag = CO_READ_AXIS(eaxis, co_index, co_sub, co_size, vr_base)
        t = -TICKS
        IF eflag = FALSE THEN
            VR(vr_base + 1) = VR(vr_base + 1) + 1
        ELSE
            't = last_t - TICKS
            'last_t = TICKS
            IF t > maxtime THEN maxtime = t
            IF t < mintime THEN mintime = t
            ACCEL AXIS(10) = t
        ENDIF
    NEXT i
    VR(vr_base + 3) = -TICKS

    'divisor = 1000000 / SERVO_PERIOD
    PRINT#comms,""
    PRINT#comms,"SYTEM_LOAD: "; SYSTEM_LOAD; "    SYSTEM_LOAD_MAX: "; SYSTEM_LOAD_MAX
    SELECT_CASE SERVO_PERIOD
        CASE 500:
            PRINT#comms,"Min = "; mintime/2; "  Max = "; maxtime/2
            PRINT#comms,"Servo period is 500usec"
        CASE 1000
            PRINT#comms,"Min = "; mintime; "  Max = "; maxtime
            PRINT#comms,"Servo period is 1000usec"
        CASE ELSE
            PRINT#comms,"Error - unknown servo period."
    END_CASE

    PRINT#comms,"Test Count", counter[0]
    counter = counter + 1
WEND


