USE [TSQLV6]
GO

/* Demo 1:  Basic REGEXP_COUNT usage */
-- Count the number of digits in a string.
SELECT
    REGEXP_COUNT('Order 12345 placed on 2024-01-15', '\d') AS DigitCount;

-- Count the number of words (sequences of word characters).
SELECT
    REGEXP_COUNT('The quick brown fox jumps over the lazy dog', '\b\w+\b') AS WordCount;
GO



/* Demo 2:  Counting specific characters */
-- Remember the 10-nested-REPLACE chain from the opening?
-- REGEXP_COUNT handles that in one call.
-- Note: the consonant pattern counts any non-vowel, non-whitespace character,
-- which includes digits and punctuation if present.
SELECT
    REGEXP_COUNT('Regular Expressions', '[aeiou]', 1, 'i') AS VowelCount,
    REGEXP_COUNT('Regular Expressions', '[^aeiou\s]', 1, 'i') AS ConsonantCount;
GO



/* Demo 3:  Counting patterns in table data */
-- How many words are in each customer's company name?
SELECT
    c.custid,
    c.companyname,
    REGEXP_COUNT(c.companyname, '\b\w+\b') AS WordsInName
FROM Sales.Customers c
ORDER BY
    WordsInName DESC;
GO



/* Demo 4:  Count specific patterns */
-- Count the number of separator characters and digits in phone numbers.
SELECT
    c.custid,
    c.companyname,
    c.phone,
    REGEXP_COUNT(c.phone, '[.\-\s()]') AS SeparatorCount,
    REGEXP_COUNT(c.phone, '\d') AS DigitCount
FROM Sales.Customers c
ORDER BY
    SeparatorCount DESC;
GO
