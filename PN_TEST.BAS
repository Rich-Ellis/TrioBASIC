
DIM i AS INTEGER
DIM ticks_val AS INTEGER
DIM counter AS INTEGER

DIM max_t AS INTEGER
DIM min_t AS INTEGER
DIM average AS INTEGER
DIM t AS INTEGER


'GOSUB performance_test
'GOSUB gert_test
GOSUB update_test

STOP


update_test:
counter =0
max_t = 0
min_t=1000

WHILE TRUE

    TICKS = 0
    VR(201) = counter
    WHILE (VR(202) <> counter)
        WA(1)
    WEND
    t = -TICKS
    average_t = average_t + t
    IF t > max_t THEN max_t = t
    IF t < min_t THEN min_t = t

    counter = counter + 1

    IF counter MOD 100 = 0 THEN
        PRINT #5, "Min",min_t[0]
        PRINT #5, "Max",max_t[0]
        PRINT #5, "Average",average_t/100[0]
        average_t = 0
    ENDIF



WEND

RETURN


gert_test:

REPEAT
    IF VR(10)>=1 THEN
        VR(50)=1
    ELSE
        VR(50)=0
    ENDIF
    'WA(1)' remove this AND you loose the PROFINET.
UNTIL FALSE

RETURN


performance_test:
TICKS = 0
ticks_val = TICKS
VR(202) = NOT ticks_val
VR(201)= ticks_val
WHILE VR(202) <> ticks_val
    WA(1)
WEND
PRINT "update time",-TICKS
RETURN


