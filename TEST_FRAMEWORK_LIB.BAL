' ******************************************************************************
'
'Test Framework library
'
' Revision
' 25th July 2019
'

DIM m_test_count AS INTEGER(1000)
DIM m_test_read AS INTEGER(1000)
DIM m_test_write AS INTEGER(1000)
DIM m_read_err AS INTEGER(1000)
DIM m_write_err AS INTEGER(1000)

DIM m_open_count AS INTEGER(1000)
DIM m_open_err AS INTEGER(1000)

FUNCTION test_init()
    DIM i AS INTEGER
    FOR i = 0 TO 1000-1
        m_test_count(i)=0
        m_test_read(i)=0
        m_test_write(i)=0
        m_read_err(i)=0
        m_write_err(i)=0
    NEXT i
ENDFUNC

FUNCTION test_inc_read(test_id AS INTEGER, test_ok AS BOOLEAN)

    IF (test_ok ) THEN
        m_test_read(test_id) = m_test_read(test_id) + 1
    ELSE
        PRINT #5,"Error: read"
        m_read_err(test_id) = m_read_err(test_id) + 1
    ENDIF

ENDFUNC

FUNCTION test_inc_write(test_id AS INTEGER, test_ok AS BOOLEAN)
    IF (test_ok ) THEN
        m_test_write(test_id) = m_test_write(test_id) + 1
    ELSE
        PRINT #5,"Error: write"
        m_write_err(test_id) = m_write_err(test_id)+ 1
    ENDIF

ENDFUNC

FUNCTION test_inc_open(test_id AS INTEGER, test_ok AS BOOLEAN)
    IF (test_ok ) THEN
        m_open_count(test_id) = m_open_count(test_id) + 1
    ELSE
        PRINT #5,"Error: opening connection"
        m_open_err(test_id) = m_open_err(test_id)+ 1
    ENDIF

ENDFUNC

FUNCTION test_inc_test_and_display(test_id AS INTEGER)
    DIM i AS INTEGER
    m_test_count(test_id) = m_test_count(test_id) + 1

    IF m_test_count(test_id) MOD 10000 = 0 THEN
        PRINT #5,"Test Stats:"
        PRINT #5,"ID: open:read:write/open_errs:read_errs:write_errs"
        FOR i = 1 TO 3
            PRINT #5,i[0];": ";m_open_count(i)[0];":";m_test_read(i)[0];":";m_test_write(i)[0];"/"; _
                m_open_err(i)[0];":";m_read_err(i)[0];":";m_write_err(i)[0]
        NEXT i
        PRINT #5,""
    ENDIF

ENDFUNC

