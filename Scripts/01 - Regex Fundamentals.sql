/* ============================================================
   WHY REGEX?  A motivating example.
   ============================================================ */

-- How many vowels are in this string?
-- The old way: a deeply nested chain of REPLACE calls.
DECLARE @TestString NVARCHAR(200) = N'Regular Expressions';
SELECT
    LEN(@TestString) - LEN(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
        REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
            @TestString,
            'a', ''), 'e', ''), 'i', ''), 'o', ''), 'u', ''),
            'A', ''), 'E', ''), 'I', ''), 'O', ''), 'U', ''))
    AS VowelCountOldWay;

-- The regex way: one function call.
SELECT
    REGEXP_COUNT('Regular Expressions', '[aeiou]', 1, 'i') AS VowelCount;
GO



/* Demo 1:  Literal matching */
-- The simplest regex is a literal string.
-- REGEXP_LIKE returns 1 if the pattern matches, 0 otherwise.
WITH records AS (
    SELECT 'The cat sat on the mat' AS [Text]
    UNION ALL SELECT 'The dog sat on the log'
    UNION ALL SELECT 'The bird flew over the word'
)
SELECT *
FROM records
WHERE
    REGEXP_LIKE([Text], 'cat');

-- Case sensitivity matters by default!
-- Only the row with lowercase 'cat' matches.
WITH tests AS (
    SELECT * FROM (VALUES
        ('The cat sat on the mat'),
        ('The Cat sat on the mat')
    ) AS v([Text])
)
SELECT * FROM tests WHERE REGEXP_LIKE([Text], 'cat');

-- Use the 'i' flag for case-insensitive matching.
-- Now both rows match.
WITH tests AS (
    SELECT * FROM (VALUES
        ('The cat sat on the mat'),
        ('The Cat sat on the mat')
    ) AS v([Text])
)
SELECT * FROM tests WHERE REGEXP_LIKE([Text], 'cat', 'i');
GO



/* Demo 2:  The dot metacharacter and character classes */
-- The dot (.) matches any single character.
-- 'cat' and 'cot' match c.t, but 'ct' does not (no character between c and t).
WITH tests AS (
    SELECT * FROM (VALUES
        ('cat'), ('cot'), ('ct')
    ) AS v([Text])
)
SELECT * FROM tests WHERE REGEXP_LIKE([Text], 'c.t');

-- Square brackets define a character class: a specific set of characters.
-- [aeiou] matches any one vowel.
WITH tests AS (
    SELECT * FROM (VALUES
        ('Hello'), ('Rhythm')
    ) AS v([Text])
)
SELECT * FROM tests WHERE REGEXP_LIKE([Text], '[aeiou]');

-- Ranges: [a-z] matches any lowercase letter, [0-9] matches any digit.
WITH tests AS (
    SELECT * FROM (VALUES
        ('abc123'), ('abcdef')
    ) AS v([Text])
)
SELECT * FROM tests WHERE REGEXP_LIKE([Text], '[0-9]');

-- Negation: [^...] matches anything NOT in the set.
-- [^0-9] matches any character that is NOT a digit.
WITH tests AS (
    SELECT * FROM (VALUES
        ('hello'), ('12345')
    ) AS v([Text])
)
SELECT * FROM tests WHERE REGEXP_LIKE([Text], '[^0-9]');
GO



/* Demo 3:  Shorthand character classes */
-- \d = digit [0-9], \w = word character [A-Za-z0-9_], \s = whitespace
-- Uppercase versions negate: \D = non-digit, \W = non-word, \S = non-whitespace

-- Which of these contain one or more digits?
WITH tests AS (
    SELECT * FROM (VALUES
        ('Order 12345'),
        ('Hello World'),
        ('no_spaces_here')
    ) AS v([Text])
)
SELECT * FROM tests WHERE REGEXP_LIKE([Text], '\d+');

-- Which of these contain whitespace?
WITH tests AS (
    SELECT * FROM (VALUES
        ('Order 12345'),
        ('Hello World'),
        ('no_spaces_here')
    ) AS v([Text])
)
SELECT * FROM tests WHERE REGEXP_LIKE([Text], '\s');
GO



/* Demo 4:  Quantifiers and greedy vs. lazy */
-- * = zero or more, + = one or more, ? = zero or one
-- {n} = exactly n, {n,m} = between n and m

-- a{3} matches strings containing 3 consecutive a's.
WITH tests AS (
    SELECT * FROM (VALUES
        ('aaa'), ('aa'), ('aaaa'), ('a')
    ) AS v([Text])
)
SELECT * FROM tests WHERE REGEXP_LIKE([Text], 'a{3}');

-- a{2,4} matches strings containing 2 to 4 consecutive a's.
WITH tests AS (
    SELECT * FROM (VALUES
        ('aaa'), ('aa'), ('aaaa'), ('a')
    ) AS v([Text])
)
SELECT * FROM tests WHERE REGEXP_LIKE([Text], 'a{2,4}');

-- + means "one or more"
WITH tests AS (
    SELECT * FROM (VALUES
        ('abc'), ('abc123')
    ) AS v([Text])
)
SELECT * FROM tests WHERE REGEXP_LIKE([Text], '[0-9]+');

-- ? means "zero or one" -- great for optional characters.
-- colou?r matches both "color" and "colour"
WITH tests AS (
    SELECT * FROM (VALUES
        ('color'), ('colour'), ('colouur')
    ) AS v([Text])
)
SELECT * FROM tests WHERE REGEXP_LIKE([Text], 'colou?r');

-- Greedy vs. lazy: quantifiers are greedy by default (match as much as possible).
-- Add ? after a quantifier to make it lazy (match as little as possible).
-- This is the #1 source of "my regex matches too much!" bugs.
-- (REGEXP_SUBSTR extracts matching text -- we'll cover it in detail later.)
SELECT
    REGEXP_SUBSTR('<b>bold</b> and <i>italic</i>', '<.+>') AS GreedyMatch,
    REGEXP_SUBSTR('<b>bold</b> and <i>italic</i>', '<.+?>') AS LazyMatch;
GO



/* Demo 5:  Anchors and word boundaries */
-- ^ = start of string, $ = end of string
WITH tests AS (
    SELECT * FROM (VALUES
        ('Hello World'),
        ('Say Hello')
    ) AS v([Text])
)
SELECT * FROM tests WHERE REGEXP_LIKE([Text], '^Hello');

WITH tests AS (
    SELECT * FROM (VALUES
        ('Hello World'),
        ('World Hello')
    ) AS v([Text])
)
SELECT * FROM tests WHERE REGEXP_LIKE([Text], 'World$');

-- Combine anchors to match the entire string.
-- "Does this string contain ONLY digits?"
WITH tests AS (
    SELECT * FROM (VALUES
        ('12345'), ('123a5')
    ) AS v([Text])
)
SELECT * FROM tests WHERE REGEXP_LIKE([Text], '^\d+$');

-- \b marks a word boundary: the edge between a word character and a non-word character.
-- Useful for matching whole words only.
SELECT
    REGEXP_COUNT('cat concatenate catalog', '\bcat\b') AS WholeWordCatCount,
    REGEXP_COUNT('cat concatenate catalog', 'cat') AS AnyCatCount;
GO



/* Demo 6:  Alternation and grouping */
-- The pipe character | means "or"
WITH tests AS (
    SELECT * FROM (VALUES
        ('I have a cat'),
        ('I have a dog'),
        ('I have a fish')
    ) AS v([Text])
)
SELECT * FROM tests WHERE REGEXP_LIKE([Text], 'cat|dog');

-- Parentheses group alternatives and create capture groups.
WITH tests AS (
    SELECT * FROM (VALUES
        ('gray'), ('grey'), ('groy')
    ) AS v([Text])
)
SELECT * FROM tests WHERE REGEXP_LIKE([Text], 'gr(a|e)y');

-- Non-capturing groups (?:...) group alternatives without creating a capture group.
-- (a|e) creates capture group 1.  (?:a|e) groups but does NOT capture.
-- This will matter when we use REGEXP_SUBSTR to extract captured groups later.
WITH tests AS (
    SELECT * FROM (VALUES
        ('gray'), ('grey'), ('groy')
    ) AS v([Text])
)
SELECT * FROM tests WHERE REGEXP_LIKE([Text], 'gr(?:a|e)y');
-- Same matching behavior as (a|e), but the difference shows up in extraction.
GO
