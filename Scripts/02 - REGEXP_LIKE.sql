USE [TSQLV6]
GO

/* Demo 1:  Basic REGEXP_LIKE usage */
-- Find all customers whose company name starts with a vowel.
SELECT
    c.custid,
    c.companyname
FROM Sales.Customers c
WHERE
    REGEXP_LIKE(c.companyname, '^Customer [AEIOU]', 'i')
ORDER BY
    c.companyname;
GO



/* Demo 2:  What LIKE can't do */
-- LIKE can handle simple wildcard patterns...
SELECT
    c.custid,
    c.companyname
FROM Sales.Customers c
WHERE
    c.companyname LIKE '%[0-9]%'
ORDER BY
    c.companyname;

-- ...but it can't express multi-character patterns like "two consecutive vowels."
-- There's no LIKE equivalent of [aeiou]{2}.
SELECT
    c.custid,
    c.companyname,
    c.contactname
FROM Sales.Customers c
WHERE
    REGEXP_LIKE(c.contactname, '[aeiou]{2}', 'i')
ORDER BY
    c.contactname;
GO



/* Demo 3:  Validating data formats */
-- Check if phone numbers match a specific pattern.
-- Let's look at what phone numbers look like first.
SELECT
    c.custid,
    c.companyname,
    c.phone
FROM Sales.Customers c
ORDER BY
    c.custid;

-- Find phone numbers that start with an area code in parentheses.
SELECT
    c.custid,
    c.companyname,
    c.phone
FROM Sales.Customers c
WHERE
    REGEXP_LIKE(c.phone, '^\(\d+\)')
ORDER BY
    c.companyname;
GO



/* Demo 4:  Filtering with complex patterns */
-- Find orders shipped to addresses containing a number
-- followed by a street type (St, Ave, Rd, etc.)
-- Note: (?:...) is a non-capturing group -- we don't need to capture
-- the street type, just match against the alternatives.
SELECT
    o.orderid,
    o.custid,
    o.shipaddress
FROM Sales.Orders o
WHERE
    REGEXP_LIKE(o.shipaddress, '\d+\s+\w+\s+(?:St|Ave|Rd|Blvd|Dr|Ln|Way|Ct)', 'i')
ORDER BY
    o.orderid;
GO



/* Demo 5:  REGEXP_LIKE in a CASE expression */
-- Classify customers by the format of their phone numbers.
SELECT
    c.custid,
    c.companyname,
    c.phone,
    CASE
        WHEN REGEXP_LIKE(c.phone, '^\(\d+\)\s*\d+-\d+$')
            THEN 'Standard with area code'
        WHEN REGEXP_LIKE(c.phone, '^\d{3}-\d{4}$')
            THEN 'Local format'
        WHEN REGEXP_LIKE(c.phone, '^\d+\.\d+\.\d+')
            THEN 'Dot-separated'
        ELSE 'Other format'
    END AS PhoneFormat
FROM Sales.Customers c
ORDER BY
    c.companyname;
GO
