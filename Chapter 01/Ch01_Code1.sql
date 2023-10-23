-- Business Analytics using Power BI with Excel
-- Chapter 01 Code

USE AdventureWorksDW2019;
GO
SET NOCOUNT ON;
GO
-- Tables for the compression test
CREATE TABLE dbo.UniqueIntegers
(col1 INT NOT NULL);
CREATE TABLE dbo.UniqueGUIDs
(col1 UNIQUEIDENTIFIER NOT NULL);
CREATE TABLE dbo.BigCardinalityIntegers
(col1 INT NOT NULL);
CREATE TABLE dbo.SmallCardinalityStrings
(col1 NVARCHAR(10) NOT NULL);
GO

-- Insert the data
-- Unique integers
INSERT INTO dbo.UniqueIntegers(col1)
SELECT ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS rn 
FROM
 (SELECT TOP 1000 CustomerKey
  FROM dbo.DimCustomer) AS c1(col1)
 CROSS JOIN 
 (SELECT TOP 1000 CustomerKey
  FROM dbo.DimCustomer) AS c2(col2);
-- GUIDs
INSERT INTO dbo.UniqueGUIDs(col1)
SELECT NEWID()
FROM dbo.UniqueIntegers;
-- High cardinality integers
INSERT INTO dbo.BigCardinalityIntegers(col1)
SELECT (col1 - 1) / 50 +1 AS col1
FROM dbo.UniqueIntegers;
-- Low cardinality strings
INSERT INTO dbo.SmallCardinalityStrings(col1)
SELECT CAST(col1 % 5 AS NCHAR(1)) + N'AAAA' AS col1
FROM dbo.UniqueIntegers;
GO

-- Creating clustered indices
CREATE CLUSTERED INDEX cix_UniqueIntegers
 ON dbo.UniqueIntegers(col1);
CREATE CLUSTERED INDEX cix_UniqueGUIDs 
 ON dbo.UniqueGUIDs(col1);
CREATE CLUSTERED INDEX cix_BigCardinalityIntegers 
 ON dbo.BigCardinalityIntegers(col1);
CREATE CLUSTERED INDEX cix_SmallCardinalityStrings
 ON dbo.SmallCardinalityStrings(col1);
GO

-- Check the cardinality
SELECT '1. unInt' AS testData, COUNT(DISTINCT col1) AS cntDist
FROM dbo.UniqueIntegers
UNION
SELECT '2. GUIDs' AS testData, COUNT(DISTINCT col1) AS cntDist
FROM dbo.UniqueGUIDs
UNION ALL
SELECT '3. bcInt' AS testData, COUNT(DISTINCT col1) AS cntDist
FROM dbo.BigCardinalityIntegers
UNION ALL
SELECT '4. lcStr' AS testData, COUNT(DISTINCT col1) AS cntDist
FROM dbo.SmallCardinalityStrings
ORDER BY testData;
GO


-- Estimating row and page compression savings
EXEC sys.sp_estimate_data_compression_savings
 N'dbo', N'UniqueIntegers', NULL, NULL, N'ROW';
EXEC sys.sp_estimate_data_compression_savings
 N'dbo', N'UniqueIntegers', NULL, NULL, N'PAGE';
EXEC sys.sp_estimate_data_compression_savings
 N'dbo', N'UniqueGUIDs', NULL, NULL, N'ROW';
EXEC sys.sp_estimate_data_compression_savings
 N'dbo', N'UniqueGUIDs', NULL, NULL, N'PAGE';
EXEC sys.sp_estimate_data_compression_savings
 N'dbo', N'BigCardinalityIntegers', NULL, NULL, N'ROW';
EXEC sys.sp_estimate_data_compression_savings
 N'dbo', N'BigCardinalityIntegers', NULL, NULL, N'PAGE';
EXEC sys.sp_estimate_data_compression_savings
 N'dbo', N'SmallCardinalityStrings', NULL, NULL, N'ROW';
EXEC sys.sp_estimate_data_compression_savings
 N'dbo', N'SmallCardinalityStrings', NULL, NULL, N'PAGE';
GO

-- Checking the space used and creating the columnar storage
-- First time without LZ77 compression
EXEC sys.sp_spaceused N'dbo.UniqueIntegers', @updateusage = N'TRUE';
CREATE CLUSTERED COLUMNSTORE INDEX cix_UniqueIntegers
  ON dbo.UniqueIntegers
  WITH (DROP_EXISTING = ON);
EXEC sys.sp_spaceused N'dbo.UniqueIntegers', @updateusage = N'TRUE';
GO
EXEC sys.sp_spaceused N'dbo.UniqueGUIDs', @updateusage = N'TRUE';
CREATE CLUSTERED COLUMNSTORE INDEX cix_UniqueGUIDs
  ON dbo.UniqueGUIDs
  WITH (DROP_EXISTING = ON);
EXEC sys.sp_spaceused N'dbo.UniqueGUIDs', @updateusage = N'TRUE';
GO
EXEC sys.sp_spaceused N'dbo.BigCardinalityIntegers', @updateusage = N'TRUE';
CREATE CLUSTERED COLUMNSTORE INDEX cix_BigCardinalityIntegers
  ON dbo.BigCardinalityIntegers
  WITH (DROP_EXISTING = ON);
EXEC sys.sp_spaceused N'dbo.BigCardinalityIntegers', @updateusage = N'TRUE';
GO
EXEC sys.sp_spaceused N'dbo.SmallCardinalityStrings', @updateusage = N'TRUE';
CREATE CLUSTERED COLUMNSTORE INDEX cix_SmallCardinalityStrings
  ON dbo.SmallCardinalityStrings
  WITH (DROP_EXISTING = ON);
EXEC sys.sp_spaceused N'dbo.SmallCardinalityStrings', @updateusage = N'TRUE';
GO

-- Checking the space used and creating the columnar storage
-- Second time with LZ77 compression
EXEC sys.sp_spaceused N'dbo.UniqueIntegers', @updateusage = N'TRUE';
ALTER INDEX cix_UniqueIntegers
  ON dbo.UniqueIntegers
  REBUILD WITH (DATA_COMPRESSION = COLUMNSTORE_ARCHIVE);
EXEC sys.sp_spaceused N'dbo.UniqueIntegers', @updateusage = N'TRUE';
GO
EXEC sys.sp_spaceused N'dbo.UniqueGUIDs', @updateusage = N'TRUE';
ALTER INDEX cix_UniqueGUIDs
  ON dbo.UniqueGUIDs
  REBUILD WITH (DATA_COMPRESSION = COLUMNSTORE_ARCHIVE);
EXEC sys.sp_spaceused N'dbo.UniqueGUIDs', @updateusage = N'TRUE';
GO
EXEC sys.sp_spaceused N'dbo.BigCardinalityIntegers', @updateusage = N'TRUE';
ALTER INDEX cix_BigCardinalityIntegers
  ON dbo.BigCardinalityIntegers
  REBUILD WITH (DATA_COMPRESSION = COLUMNSTORE_ARCHIVE);
EXEC sys.sp_spaceused N'dbo.BigCardinalityIntegers', @updateusage = N'TRUE';
GO
EXEC sys.sp_spaceused N'dbo.SmallCardinalityStrings', @updateusage = N'TRUE';
ALTER INDEX cix_SmallCardinalityStrings
  ON dbo.SmallCardinalityStrings
  REBUILD WITH (DATA_COMPRESSION = COLUMNSTORE_ARCHIVE);
EXEC sys.sp_spaceused N'dbo.SmallCardinalityStrings', @updateusage = N'TRUE';
GO

-- Clean up
DROP TABLE IF EXISTS dbo.UniqueIntegers;
DROP TABLE IF EXISTS dbo.UniqueGUIDs;
DROP TABLE IF EXISTS dbo.BigCardinalityIntegers;
DROP TABLE IF EXISTS dbo.SmallCardinalityStrings;
GO
