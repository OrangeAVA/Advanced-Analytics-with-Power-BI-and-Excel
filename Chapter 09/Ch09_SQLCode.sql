-- Business Analytics using Power BI with Excel
-- Chapter 09 Code - SQL

USE AdventureWorksDW2019;
GO

-- dbo.FactInternetSales with calendar hierarchy for the Id
SELECT CAST(RIGHT(SalesOrderNumber, 5) + 
 CAST(SalesOrderLineNumber AS CHAR(1)) AS INT) AS Id,
 YEAR(OrderDate) AS CYear,
 MONTH(OrderDate) AS CMonth,
 DAY(OrderDate) AS CDay,
 OrderQuantity, SalesAmount
FROM dbo.FactInternetSales;
GO


-- Sampling with T-SQL
SELECT TOP 30 PERCENT
 CustomerKey,
 YearlyIncome AS Income, 
 BikeBuyer, Region,
 CASE EnglishEducation 
  WHEN N'Partial High School' THEN N'1 - Partial High School'
  WHEN N'High School' THEN N'2 - High School'
  WHEN N'Partial College' THEN N'3 - Partial College'
  WHEN N'Bachelors' THEN N'4 - Bachelors'
  WHEN N'Graduate Degree' THEN N'5 - Graduate Degree'
  ELSE N'0 - Unknown'         -- Handling possible NULLs
 END AS Education
FROM dbo.vTargetMail
ORDER BY CAST(CRYPT_GEN_RANDOM(4) AS INT);
GO


-- Query folding

-- Measuring time
SET STATISTICS TIME ON;
GO

-- Query folding query
select top 20
    [_].[EnglishCountryRegionName] as [Country],
    [_].[City] as [City],
    [_].[AvgIncome] as [AvgIncome],
    [_].[SumChildren] as [SumChildren],
    [_].[FirstCustByName] as [FirstCustByName]
from 
(
    select [_].[EnglishCountryRegionName],
        [_].[City],
        [_].[AvgIncome],
        [_].[SumChildren],
        [_].[FirstCustByName]
    from 
    (
        select [_].[EnglishCountryRegionName],
            [_].[City],
            [_].[AvgIncome],
            [_].[SumChildren],
            [_].[FirstCustByName]
        from 
        (
            select [rows].[EnglishCountryRegionName] as [EnglishCountryRegionName],
                [rows].[City] as [City],
                avg(convert(float, [rows].[YearlyIncome])) as [AvgIncome],
                sum([rows].[TotalChildren]) as [SumChildren],
                min([rows].[FullName]) as [FirstCustByName]
            from 
            (
                select [_].[CustomerKey] as [CustomerKey],
                    [_].[YearlyIncome] as [YearlyIncome],
                    [_].[TotalChildren] as [TotalChildren],
                    [_].[EnglishEducation] as [EnglishEducation],
                    [_].[EnglishOccupation] as [EnglishOccupation],
                    [_].[City] as [City],
                    [_].[EnglishCountryRegionName] as [EnglishCountryRegionName],
                    ([_].[FirstName] + ' ') + [_].[LastName] as [FullName]
                from 
                (
                    select [_].[CustomerKey],
                        [_].[FirstName],
                        [_].[LastName],
                        [_].[YearlyIncome],
                        [_].[TotalChildren],
                        [_].[EnglishEducation],
                        [_].[EnglishOccupation],
                        [_].[City],
                        [_].[EnglishCountryRegionName]
                    from 
                    (
                        select [$Outer].[CustomerKey],
                            [$Outer].[FirstName],
                            [$Outer].[LastName],
                            [$Outer].[YearlyIncome],
                            [$Outer].[TotalChildren],
                            [$Outer].[EnglishEducation],
                            [$Outer].[EnglishOccupation],
                            [$Inner].[City],
                            [$Inner].[EnglishCountryRegionName]
                        from 
                        (
                            select [_].[CustomerKey] as [CustomerKey],
                                [_].[GeographyKey] as [GeographyKey2],
                                [_].[CustomerAlternateKey] as [CustomerAlternateKey],
                                [_].[Title] as [Title],
                                [_].[FirstName] as [FirstName],
                                [_].[MiddleName] as [MiddleName],
                                [_].[LastName] as [LastName],
                                [_].[NameStyle] as [NameStyle],
                                [_].[BirthDate] as [BirthDate],
                                [_].[MaritalStatus] as [MaritalStatus],
                                [_].[Suffix] as [Suffix],
                                [_].[Gender] as [Gender],
                                [_].[EmailAddress] as [EmailAddress],
                                [_].[YearlyIncome] as [YearlyIncome],
                                [_].[TotalChildren] as [TotalChildren],
                                [_].[NumberChildrenAtHome] as [NumberChildrenAtHome],
                                [_].[EnglishEducation] as [EnglishEducation],
                                [_].[SpanishEducation] as [SpanishEducation],
                                [_].[FrenchEducation] as [FrenchEducation],
                                [_].[EnglishOccupation] as [EnglishOccupation],
                                [_].[SpanishOccupation] as [SpanishOccupation],
                                [_].[FrenchOccupation] as [FrenchOccupation],
                                [_].[HouseOwnerFlag] as [HouseOwnerFlag],
                                [_].[NumberCarsOwned] as [NumberCarsOwned],
                                [_].[AddressLine1] as [AddressLine1],
                                [_].[AddressLine2] as [AddressLine2],
                                [_].[Phone] as [Phone],
                                [_].[DateFirstPurchase] as [DateFirstPurchase],
                                [_].[CommuteDistance] as [CommuteDistance]
                            from [dbo].[DimCustomer] as [_]
                        ) as [$Outer]
                        left outer join [dbo].[DimGeography] as [$Inner] on ([$Outer].[GeographyKey2] = [$Inner].[GeographyKey])
                    ) as [_]
                    where ([_].[EnglishCountryRegionName] <> 'France' or [_].[EnglishCountryRegionName] is null) and ([_].[EnglishCountryRegionName] <> 'Germany' or [_].[EnglishCountryRegionName] is null)
                ) as [_]
            ) as [rows]
            group by [EnglishCountryRegionName],
                [City]
        ) as [_]
        where (((((((([_].[SumChildren] <> 8 or [_].[SumChildren] is null) and ([_].[SumChildren] <> 0 or [_].[SumChildren] is null)) and ([_].[SumChildren] <> 1 or [_].[SumChildren] is null)) and ([_].[SumChildren] <> 2 or [_].[SumChildren] is null)) and ([_].[SumChildren] <> 3 or [_].[SumChildren] is null)) and ([_].[SumChildren] <> 4 or [_].[SumChildren] is null)) and ([_].[SumChildren] <> 5 or [_].[SumChildren] is null)) and ([_].[SumChildren] <> 6 or [_].[SumChildren] is null)) and ([_].[SumChildren] <> 7 or [_].[SumChildren] is null)
    ) as [_]
) as [_]
order by [_].[SumChildren] desc
--    CPU time = 31 ms,  elapsed time = 44 ms.

-- Query folding query rewritten
SELECT TOP 20
 g.EnglishCountryRegionName AS Country,
 g.City,
 AVG(YearlyIncome) AS AvgIncome,
 CAST(SUM(c.TotalChildren) AS INT) AS SumChildren,
 MIN(c.FirstName + ' ' + c.LastName) AS FirstCustByName
FROM dbo.DimCustomer AS c
 INNER JOIN dbo.DimGeography AS g
  ON c.GeographyKey = g.GeographyKey
WHERE g.EnglishCountryRegionName IN
       (N'Australia', N'Canada', 
	    N'United Kingdom', N'United States')
GROUP BY g.EnglishCountryRegionName, g.City
HAVING SUM(c.TotalChildren) > 8
ORDER BY SumChildren DESC;
--   CPU time = 15 ms,  elapsed time = 16 ms.
GO

-- Stop measuring time
SET STATISTICS TIME OFF;
GO

-- Using a query as the source
SELECT CustomerKey,
 FirstName + ' ' + LastName AS FullName,
 YearlyIncome, TotalChildren,
 EnglishEducation,  -- Renaming the column in PQ
 EnglishOccupation  -- Renaming the column in PQ
FROM dbo.DimCustomer;
GO

-- Creating a view for the source
CREATE VIEW dbo.vDimCustomer
AS
SELECT CustomerKey,
 FirstName + ' ' + LastName AS FullName,
 YearlyIncome, TotalChildren,
 EnglishEducation,  -- Renaming the column in PQ
 EnglishOccupation  -- Renaming the column in PQ
FROM dbo.DimCustomer;
GO

-- Query and view for customers from France and Germany
SELECT c.CustomerKey,
 g.EnglishCountryRegionName AS Country,
 g.City,
 c.YearlyIncome AS Income,
 c.TotalChildren
FROM dbo.DimCustomer AS c
 INNER JOIN dbo.DimGeography AS g
  ON c.GeographyKey = g.GeographyKey
WHERE g.EnglishCountryRegionName IN
       (N'France', N'Germany');
GO

CREATE VIEW dbo.vCustFranceGermany
AS
SELECT c.CustomerKey,
 g.EnglishCountryRegionName AS Country,
 g.City,
 c.YearlyIncome AS Income,
 c.TotalChildren
FROM dbo.DimCustomer AS c
 INNER JOIN dbo.DimGeography AS g
  ON c.GeographyKey = g.GeographyKey
WHERE g.EnglishCountryRegionName IN
       (N'France', N'Germany');
GO

-- Clean up
DROP VIEW dbo.vDimCustomer;
DROP VIEW dbo.vCustFranceGermany;
GO
