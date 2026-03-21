USE [TSQLV6]
GO

/* Demo 1:  E-mail address validation */
-- A reasonable (not perfect!) e-mail validation pattern.
DECLARE @Emails TABLE (Email NVARCHAR(200));
INSERT INTO @Emails (Email) VALUES
    (N'user@example.com'),
    (N'first.last@company.co.uk'),
    (N'invalid-email'),
    (N'user@'),
    (N'@domain.com'),
    (N'user@domain'),
    (N'user+tag@example.com'),
    (N'user@123.456.789.0'),
    (N'valid_user-name@sub.domain.org');

SELECT
    e.Email,
    CASE WHEN REGEXP_LIKE(e.Email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') THEN 1 ELSE 0 END AS IsValid
FROM @Emails e;

-- Note the limitations!
-- user@123.456.789.0 passes: the pattern checks structure, not whether the domain exists.
-- user@domain fails: no TLD (no dot after the domain).
-- Regex can validate format but not existence.
GO



/* Demo 2:  US phone number validation and formatting */
DECLARE @Phones TABLE (Phone NVARCHAR(50));
INSERT INTO @Phones (Phone) VALUES
    (N'(555) 123-4567'),
    (N'555-123-4567'),
    (N'555.123.4567'),
    (N'5551234567'),
    (N'+1 555 123 4567'),
    (N'123'),
    (N'555-1234'),
    (N'1-800-555-1234');

-- Validate: does this look like a 10-digit US phone number?
SELECT
    p.Phone,
    CASE WHEN REGEXP_LIKE(p.Phone, '^\+?1?[\s.-]?\(?\d{3}\)?[\s.-]?\d{3}[\s.-]?\d{4}$') THEN 1 ELSE 0 END AS IsValidUSPhone,
    REGEXP_REPLACE(p.Phone, '[^\d]', '') AS DigitsOnly
FROM @Phones p;
GO



/* Demo 3:  Parsing log entries */
-- A common scenario: parsing semi-structured log data.
DECLARE @Logs TABLE (LogEntry NVARCHAR(500));
INSERT INTO @Logs (LogEntry) VALUES
    (N'2025-01-15 10:30:45.123 [INFO] UserService - User login successful for user_id=1042'),
    (N'2025-01-15 10:30:46.456 [ERROR] OrderService - Failed to process order #98765: timeout after 30s'),
    (N'2025-01-15 10:30:47.789 [WARN] PaymentService - Retry attempt 3/5 for transaction TX-2025-00142'),
    (N'2025-01-15 10:31:01.000 [INFO] UserService - User logout for user_id=1042'),
    (N'2025-01-15 10:31:05.234 [ERROR] DatabaseService - Connection pool exhausted, 0/50 available');

SELECT
    l.LogEntry,
    REGEXP_SUBSTR(l.LogEntry, '^\d{4}-\d{2}-\d{2}') AS LogDate,
    REGEXP_SUBSTR(l.LogEntry, '\d{2}:\d{2}:\d{2}\.\d{3}') AS LogTime,
    REGEXP_SUBSTR(l.LogEntry, '\[(INFO|ERROR|WARN)\]', 1, 1, '', 1) AS LogLevel,
    REGEXP_SUBSTR(l.LogEntry, '\] (\w+)', 1, 1, '', 1) AS ServiceName,
    REGEXP_SUBSTR(l.LogEntry, '- (.+)$', 1, 1, '', 1) AS Message
FROM @Logs l;
GO



/* Demo 4:  Data cleansing pipeline */
-- A common ETL scenario: clean and standardize incoming data.
DECLARE @RawData TABLE (RawName NVARCHAR(200), RawPhone NVARCHAR(50), RawEmail NVARCHAR(200));
INSERT INTO @RawData (RawName, RawPhone, RawEmail) VALUES
    (N'  John   Q.  Smith  ', N'(555) 123-4567', N'JOHN.SMITH@EXAMPLE.COM'),
    (N'Jane    Doe', N'555.987.6543', N'jane_doe@company.org'),
    (N'  Bob    Jones   III  ', N'555 555 1212', N'bob.jones@email');

SELECT
    -- Clean up name: trim and remove extra whitespace.
    TRIM(REGEXP_REPLACE(rd.RawName, '\s+', ' ')) AS CleanedName,
    -- Standardize phone: extract digits, then reformat.
    REGEXP_REPLACE(
        REGEXP_REPLACE(rd.RawPhone, '[^\d]', ''),
        '(\d{3})(\d{3})(\d{4})',
        '(\1) \2-\3'
    ) AS StandardizedPhone,
    -- Validate e-mail.
    LOWER(rd.RawEmail) AS NormalizedEmail,
    CASE WHEN REGEXP_LIKE(rd.RawEmail, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') THEN 1 ELSE 0 END AS EmailIsValid
FROM @RawData rd;
GO



/* Demo 5:  Unicode property escapes -- the ICU advantage */
-- SQL Server 2025 uses the ICU regex engine, which supports Unicode properties.
-- This is something LIKE and PATINDEX simply cannot do.

-- \p{L}  = any Unicode letter (Latin, Cyrillic, Chinese, Arabic, etc.)
-- \p{N}  = any Unicode number (not just 0-9)
-- \p{Sc} = any currency symbol ($, €, £, ¥, etc.)
-- \p{P}  = any punctuation character

DECLARE @UnicodeData TABLE (Val NVARCHAR(200));
INSERT INTO @UnicodeData (Val) VALUES
    (N'Hello'),
    (N'Привет'),
    (N'你好'),
    (N'مرحبا'),
    (N'Price: $100'),
    (N'Prix: €200'),
    (N'価格: ¥300');

-- \p{L}+ matches words in ANY language.
SELECT
    u.Val,
    CASE WHEN REGEXP_LIKE(u.Val, '\p{L}+') THEN 1 ELSE 0 END AS HasLetters,
    REGEXP_SUBSTR(u.Val, '\p{Sc}') AS CurrencySymbol,
    REGEXP_SUBSTR(u.Val, '\p{Sc}\s*(\d+)', 1, 1, '', 1) AS Amount
FROM @UnicodeData u;

-- Compare: [A-Za-z] only matches ASCII, but \p{L} matches everything.
SELECT
    CASE WHEN REGEXP_LIKE(N'Привет', '^[A-Za-z]+$') THEN 1 ELSE 0 END AS AsciiOnlyMatch,
    CASE WHEN REGEXP_LIKE(N'Привет', '^\p{L}+$') THEN 1 ELSE 0 END AS UnicodeLetterMatch;
GO



/* Demo 6:  Extracting structured data from free text */
-- Parsing product descriptions to extract dimensions.
DECLARE @Products TABLE (ProductDescription NVARCHAR(500));
INSERT INTO @Products (ProductDescription) VALUES
    (N'Heavy-duty shelf, 48in x 24in x 72in, steel construction, 500lb capacity'),
    (N'Small box 12x8x6 inches, cardboard, lightweight'),
    (N'Monitor stand: dimensions 20" x 10" x 5.5", aluminum'),
    (N'No dimensions listed for this product');

SELECT
    p.ProductDescription,
    REGEXP_SUBSTR(p.ProductDescription, '(\d+\.?\d*)\s*[x"]\s*(\d+\.?\d*)\s*[x"]\s*(\d+\.?\d*)', 1, 1, 'i', 1) AS Width,
    REGEXP_SUBSTR(p.ProductDescription, '(\d+\.?\d*)\s*[x"]\s*(\d+\.?\d*)\s*[x"]\s*(\d+\.?\d*)', 1, 1, 'i', 2) AS Depth,
    REGEXP_SUBSTR(p.ProductDescription, '(\d+\.?\d*)\s*[x"]\s*(\d+\.?\d*)\s*[x"]\s*(\d+\.?\d*)', 1, 1, 'i', 3) AS Height
FROM @Products p;
GO
