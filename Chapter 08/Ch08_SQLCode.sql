-- Business Analytics using Power BI with Excel
-- Chapter 08 Code - SQL

USE AdventureWorksDW2019;
GO

-- vTargetMail view with derived variables
SELECT CustomerKey,
 Age, YearlyIncome AS Income, 
 BikeBuyer, MaritalStatus,
 TotalChildren, NumberChildrenAtHome,
 CASE EnglishEducation 
  WHEN N'Partial High School' THEN N'1 - Partial High School'
  WHEN N'High School' THEN N'2 - High School'
  WHEN N'Partial College' THEN N'3 - Partial College'
  WHEN N'Bachelors' THEN N'4 - Bachelors'
  WHEN N'Graduate Degree' THEN N'5 - Graduate Degree'
  ELSE N'0 - Unknown'         -- Handling possible NULLs
 END AS EducationOrdered,
 EnglishEducation AS Education,
 EnglishOccupation AS Occupation,
 HouseOwnerFlag, NumberCarsOwned,
 CommuteDistance, Region,
 NTILE(3) OVER(ORDER BY Age) AS AgeDiscretized,
 NTILE(3) OVER(ORDER BY YearlyIncome) AS IncomeDiscretized,
 CASE EnglishEducation 
  WHEN N'Partial High School' THEN 1
  WHEN N'High School' THEN 2
  WHEN N'Partial College' THEN 3
  WHEN N'Bachelors' THEN 4
  WHEN N'Graduate Degree' THEN 5
  ELSE 0         -- Handling possible NULLs
 END AS EducationNumeric,
 CASE CommuteDistance 
  WHEN N'0-1 Miles' THEN 1
  WHEN N'1-2 Miles' THEN 2
  WHEN N'2-5 Miles' THEN 3
  WHEN N'5-10 Miles' THEN 4
  WHEN N'10+ Miles' THEN 5
 END AS CommDistNumeric,
 CASE Region
  WHEN N'Europe' THEN 1
  WHEN N'North America' THEN 2
  WHEN N'Pacific' THEN 3
 END AS RegionNumeric,
 CASE MaritalStatus
  WHEN N'S' THEN 0
  WHEN N'M' THEN 1
 END AS MarStaNumeric,
 ROUND(
 (1.0*Age - AVG(1.0*Age) OVER()) /
  STDEV(1.0*Age) OVER(), 2) AS AgeScaledSQL,
 ROUND(
 (1.0*YearlyIncome - AVG(1.0*YearlyIncome) OVER()) /
  STDEV(1.0*YearlyIncome) OVER(), 2) AS IncomeScaledSQL
FROM dbo.vTargetMail;
GO


-- Forecasting
SELECT TimeIndex, SUM(Quantity) AS Quantity, SUM(Amount) AS Amount,
  DATEFROMPARTS(TimeIndex / 100, TimeIndex % 100, 1) AS DateIndex
FROM dbo.vTimeSeries
WHERE TimeIndex > 201912    -- December 2019 outlier, too small value
GROUP BY TimeIndex
ORDER BY TimeIndex;
GO


-- Text Analytics
SELECT TOP 10 p.ProductKey, 
 p.EnglishProductName AS ProductName,
 p.EnglishDescription AS ProductDescription,
 s.EnglishProductSubcategoryName AS ProductSubcategory
FROM dbo.DimProduct AS p
 INNER JOIN dbo.DimProductSubcategory AS s
  ON p.ProductSubcategoryKey = s.ProductSubcategoryKey
WHERE EnglishDescription IS NOT NULL
ORDER BY NEWID();

-- Vision
SELECT TOP 10 p.ProductKey, 
 p.EnglishProductName AS ProductName,
 s.EnglishProductSubcategoryName AS ProductSubcategory,
 p.LargePhoto
FROM dbo.DimProduct AS p
 INNER JOIN dbo.DimProductSubcategory AS s
  ON p.ProductSubcategoryKey = s.ProductSubcategoryKey
WHERE EnglishDescription IS NOT NULL
ORDER BY NEWID();


-- Allow external scripts
USE master;
EXEC sys.sp_configure 'show advanced options', 1;
RECONFIGURE
EXEC sys.sp_configure 'external scripts enabled', 1; 
RECONFIGURE;
GO


-- Execute Python script
USE AdventureWorksDW2019;
EXECUTE sys.sp_execute_external_script
  @language = N'Python'
 ,@script = N'
# Imports
import numpy as np
import pandas as pd

# GMM clustering
from sklearn.mixture import GaussianMixture

# Define and train the model
X = TM[["BikeBuyer", "TotalChildren",
        "NumberChildrenAtHome","HouseOwnerFlag",
        "NumberCarsOwned", "AgeDiscretized",
        "IncomeDiscretized", "EducationNumeric",
        "RegionNumeric", "MarStaNumeric"]]
model = GaussianMixture(n_components = 3, covariance_type = "full")
model.fit(X)
# Get the clusters vector
y_gmm = model.predict(X)

# Adding cluster membership to the original
TM["Cluster"] = y_gmm
TMPy = TM[["CustomerKey", "Cluster", "Education", "CommuteDistance", "Occupation", "NumberCarsOwned"]]
'
 ,@input_data_1 = N'
SET QUOTED_IDENTIFIER OFF;   -- Double quotes as string delimiters
SELECT CustomerKey,
 Age, CAST(YearlyIncome AS INT) AS Income,   -- money data type not supported
 BikeBuyer, MaritalStatus,
 TotalChildren, NumberChildrenAtHome,
 EnglishEducation AS Education,
 EnglishOccupation AS Occupation,
 HouseOwnerFlag, NumberCarsOwned,
 CommuteDistance, Region,
 ROUND(
 (1.0*Age - AVG(Age) OVER()) /
  STDEV(Age) OVER(), 2) AS AgeScaled,
 ROUND(
 (1.0*YearlyIncome - AVG(YearlyIncome) OVER()) /
  STDEV(YearlyIncome) OVER(), 2) AS IncomeScaled,
 NTILE(3) OVER(ORDER BY Age) AS AgeDiscretized,
 NTILE(3) OVER(ORDER BY YearlyIncome) AS IncomeDiscretized,
 CASE EnglishEducation 
  WHEN "Partial High School" THEN 1
  WHEN "High School" THEN 2
  WHEN "Partial College" THEN 3
  WHEN "Bachelors" THEN 4
  WHEN "Graduate Degree" THEN 5
  ELSE 0         -- Handling possible NULLs - not needed here, just an example
 END AS EducationNumeric,
 CASE CommuteDistance 
  WHEN "0-1 Miles" THEN 1
  WHEN "1-2 Miles" THEN 2
  WHEN "2-5 Miles" THEN 3
  WHEN "5-10 Miles" THEN 4
  WHEN "10+ Miles" THEN 5
 END AS CommDistNumeric,
 CASE Region
  WHEN "Europe" THEN 1
  WHEN "North America" THEN 2
  WHEN "Pacific" THEN 3
 END AS RegionNumeric,
 CASE MaritalStatus
  WHEN "S" THEN 0
  WHEN "M" THEN 1
 END AS MarStaNumeric
FROM dbo.vTargetMail;
'
 ,@input_data_1_name =  N'TM'
 ,@output_data_1_name = N'TMPy'
WITH RESULT SETS 
(
 ([CustomerKey]		INT NOT NULL,
  [Cluster]			INT NOT NULL,
  [Education]		NVARCHAR(20) NOT NULL,
  [CommuteDistance]	NVARCHAR(20) NOT NULL,
  [Occupation]		NVARCHAR(20) NOT NULL,
  [NumberCarsOwned]	INT NOT NULL)
);
GO

-- Term extraction SQL

-- Check whether Full-Text and Semantic search is installed
SELECT SERVERPROPERTY('IsFullTextInstalled');
-- Full Text Languages
SELECT *
FROM sys.fulltext_languages
ORDER BY name;
GO

-- Extracting key terms
WITH TOP10Products AS
(
SELECT TOP 10
 ProductKey, 
 EnglishProductName AS ProductName,
 EnglishDescription AS ProductDescription
FROM dbo.DimProduct
WHERE EnglishDescription IS NOT NULL
ORDER BY NEWID()
),
KeyPhrases AS
(
SELECT p.ProductKey, 
 p.ProductName,
 p.ProductDescription,
 t.display_term
FROM TOP10Products AS p
 CROSS APPLY sys.dm_fts_parser('"' + REPLACE(p.ProductDescription,'"','') + '"', 1033, 0, 0) AS t
WHERE t.special_term = N'Exact Match')
SELECT ProductKey, 
 MIN(ProductName) AS ProductName,
 MIN(ProductDescription) AS ProductDescription,
 STRING_AGG (display_term, ', ') AS KeyTerms
FROM KeyPhrases
GROUP BY ProductKey;
GO


