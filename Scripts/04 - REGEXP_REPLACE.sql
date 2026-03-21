USE [TSQLV6]
GO

/* Demo 1:  Basic REGEXP_REPLACE usage */
-- Replace all digits with '#'.
SELECT
    REGEXP_REPLACE('Call me at 555-1234 or 555-5678', '\d', '#') AS Masked;

-- Replace only the first occurrence of a word.
SELECT
    REGEXP_REPLACE('aaa bbb ccc', '\b\w+\b', 'XXX', 1, 1) AS ReplaceFirst;

-- Replace only the second occurrence.
SELECT
    REGEXP_REPLACE('aaa bbb ccc', '\b\w+\b', 'XXX', 1, 2) AS ReplaceSecond;
GO



/* Demo 2:  Data cleansing -- whitespace and non-numeric characters */
-- Remove extra whitespace: a common data cleansing task.
SELECT
    TRIM(REGEXP_REPLACE('  Hello    World   !  ', '\s+', ' ')) AS FullyCleaned;

-- Extract just the digits from messy phone numbers.
-- Works on any format!
SELECT
    REGEXP_REPLACE('(555) 123-4567', '[^\d]', '') AS DigitsOnly1,
    REGEXP_REPLACE('555.123.4567', '[^\d]', '') AS DigitsOnly2,
    REGEXP_REPLACE('+1 (555) 123-4567', '[^\d]', '') AS DigitsOnly3;
GO



/* Demo 3:  Reformatting data with backreferences */
-- Backreferences (\1, \2, \3) refer to captured groups in the pattern.
-- Reformat a date from MM/DD/YYYY to YYYY-MM-DD.
SELECT
    REGEXP_REPLACE('01/15/2025', '(\d{2})/(\d{2})/(\d{4})', '\3-\1-\2') AS ISODate;

-- Reformat a phone number from digits to a standard format.
SELECT
    REGEXP_REPLACE('5551234567', '(\d{3})(\d{3})(\d{4})', '(\1) \2-\3') AS FormattedPhone;
GO



/* Demo 4:  Redacting sensitive data */
-- Note: SQL Server 2025 uses the ICU regex engine, which does NOT support
-- lookaheads (?=...) or lookbehinds (?<=...).  We need alternative approaches.

-- Mask a credit card number, showing only the last 4 digits.
-- Strategy: capture the first 12 digits and the last 4 separately,
-- then replace the first group with asterisks using REPLICATE.
SELECT
    REGEXP_REPLACE('4111111111111234', '(\d{12})(\d{4})',
        REPLICATE('*', 12) + '\2') AS MaskedCard;
-- Result: ************1234

-- Mask everything AFTER "SSN:" in a string.
-- Strategy: capture the prefix in a group, replace the sensitive part.
SELECT
    REGEXP_REPLACE('SSN: 123-45-6789', '(SSN:\s)\S+', '\1***-**-****') AS RedactedSSN;
-- The parentheses capture "SSN: " as \1, and we replace the rest.
GO



/* Demo 5:  CamelCase to snake_case conversion */
-- Insert an underscore between a lowercase letter and an uppercase letter.
-- Backreferences \1 and \2 preserve the original letters.
SELECT
    LOWER(REGEXP_REPLACE('CustomerOrderDate', '([a-z])([A-Z])', '\1_\2')) AS SnakeCase;
GO



/* Demo 6:  Remove HTML tags */
-- Strip HTML tags from a string.
-- The pattern <[^>]+> uses a negated character class: one or more
-- characters that are NOT >.  This avoids the greedy matching problem
-- we saw in the fundamentals.
DECLARE @HTML NVARCHAR(500) = N'<p>This is <strong>bold</strong> and <em>italic</em> text.</p>';
SELECT
    REGEXP_REPLACE(@HTML, '<[^>]+>', '') AS PlainText;
GO
