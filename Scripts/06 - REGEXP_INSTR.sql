USE [TSQLV6]
GO

/* Demo 1:  Basic REGEXP_INSTR usage */
-- Find the position of the first digit in a string.
SELECT
    REGEXP_INSTR('Order ABC-12345', '\d') AS FirstDigitPos;

-- Compare to PATINDEX: same result for simple cases...
SELECT
    PATINDEX('%[0-9]%', 'Order ABC-12345') AS PatindexResult,
    REGEXP_INSTR('Order ABC-12345', '\d') AS RegexpInstrResult;

-- ...but REGEXP_INSTR supports full regex syntax that PATINDEX can't.
-- For example, find the position of the first sequence of 3+ digits:
SELECT
    REGEXP_INSTR('AB1 CD2 EF345 GH6789', '\d{3,}') AS ThreeOrMoreDigitsPos;
GO



/* Demo 2:  Finding the Nth occurrence */
-- REGEXP_INSTR can find the position of the 2nd, 3rd, etc. match.
-- PATINDEX can only find the first!
DECLARE @TestString NVARCHAR(200) = N'abc 123 def 456 ghi 789';

SELECT
    REGEXP_INSTR(@TestString, '\d+', 1, 1) AS FirstNumberPos,
    REGEXP_INSTR(@TestString, '\d+', 1, 2) AS SecondNumberPos,
    REGEXP_INSTR(@TestString, '\d+', 1, 3) AS ThirdNumberPos;
GO



/* Demo 3:  Return option -- start vs end of match */
-- return_option = 0 (default): position where the match starts
-- return_option = 1: position AFTER the match ends
DECLARE @TestString NVARCHAR(200) = N'Hello World 12345 Test';

SELECT
    REGEXP_INSTR(@TestString, '\d+', 1, 1, 0) AS MatchStart,
    REGEXP_INSTR(@TestString, '\d+', 1, 1, 1) AS MatchEnd;
-- MatchStart = 13, MatchEnd = 18
-- The match occupies positions 13 through 17 (5 digits).
GO
