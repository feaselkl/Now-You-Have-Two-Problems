USE [TSQLV6]
GO

/* Demo 1:  Basic REGEXP_SUBSTR usage */
-- Extract the first sequence of digits from a string.
SELECT
    REGEXP_SUBSTR('Order number: 12345, placed on 2025-01-15', '\d+') AS FirstNumber;

-- The 4th parameter selects which occurrence to extract.
SELECT
    REGEXP_SUBSTR('Order number: 12345, placed on 2025-01-15', '\d+', 1, 1) AS FirstNumber,
    REGEXP_SUBSTR('Order number: 12345, placed on 2025-01-15', '\d+', 1, 2) AS SecondNumber,
    REGEXP_SUBSTR('Order number: 12345, placed on 2025-01-15', '\d+', 1, 3) AS ThirdNumber;
GO



/* Demo 2:  Capture groups and the subexpression parameter */
-- REGEXP_SUBSTR has 6 parameters:
--   REGEXP_SUBSTR(string, pattern, position, occurrence, flags, subexpression)
-- The 6th parameter (subexpression) extracts a specific capture group.
-- Let's build up to it.

DECLARE @Email NVARCHAR(100) = N'feasel@catallaxyservices.com';

-- Without the subexpression parameter, we get the entire match:
SELECT
    REGEXP_SUBSTR(@Email, '@(.+)$') AS FullMatch;
-- Returns: @catallaxyservices.com  (the whole match including @)

-- With subexpression = 1, we get just what's inside the first ():
SELECT
    REGEXP_SUBSTR(@Email, '@(.+)$', 1, 1, '', 1) AS Domain;
-- Returns: catallaxyservices.com  (just the captured group)

-- Extract other parts of the email:
SELECT
    REGEXP_SUBSTR(@Email, '@([^.]+)', 1, 1, '', 1) AS DomainName,
    REGEXP_SUBSTR(@Email, '^([^@]+)', 1, 1, '', 1) AS Username;
GO



/* Demo 3:  Extracting from structured text */
-- Parse a key-value pair connection string.
-- Each pattern captures the value after the key= prefix.
DECLARE @Config NVARCHAR(200) = N'server=myserver;database=mydb;user=admin;password=secret123';

SELECT
    REGEXP_SUBSTR(@Config, 'server=([^;]+)', 1, 1, '', 1) AS ServerName,
    REGEXP_SUBSTR(@Config, 'database=([^;]+)', 1, 1, '', 1) AS DatabaseName,
    REGEXP_SUBSTR(@Config, 'user=([^;]+)', 1, 1, '', 1) AS UserName;
GO



/* Demo 4:  Extracting data from table columns */
-- Extract the numeric and alphabetic portions of ship postal codes.
SELECT
    o.orderid,
    o.shippostalcode,
    REGEXP_SUBSTR(o.shippostalcode, '\d+') AS NumericPortion,
    REGEXP_SUBSTR(o.shippostalcode, '[A-Za-z]+') AS AlphaPortion
FROM Sales.Orders o
WHERE
    o.shippostalcode IS NOT NULL
ORDER BY
    o.orderid;
GO



/* Demo 5:  Extracting from addresses */
-- Extract the street number and street name from addresses.
SELECT
    o.orderid,
    o.shipaddress,
    o.shipcity,
    REGEXP_SUBSTR(o.shipaddress, '^\d+') AS StreetNumber,
    REGEXP_SUBSTR(o.shipaddress, '^\d+\s+(.+)$', 1, 1, '', 1) AS StreetName
FROM Sales.Orders o
WHERE
    REGEXP_LIKE(o.shipaddress, '^\d')
ORDER BY
    o.orderid;
GO
