-- AWDW Dates Second Update

-- Basic dates
SET NOCOUNT ON;

SELECT Year(OrderDate) AS cYear, COUNT(*) AS cnt,
 SUM(SalesAmount) AS SalesAmount, SUM(OrderQuantity) AS Quatity
FROM dbo.FactInternetSales
GROUP BY Year(OrderDate) 
ORDER BY cYear;

SELECT Year(OrderDate) AS cYear, COUNT(*) AS cnt,
 SUM(SalesAmount) AS SalesAmount, SUM(OrderQuantity) AS Quatity
FROM dbo.FactResellerSales
GROUP BY Year(OrderDate) 
ORDER BY cYear;

/* Deleting from dbo.DimDate 
SELECT COUNT(*)
FROM dbo.DimDate;
GO

-- Drop foreign keys 
ALTER TABLE FactCurrencyRate DROP CONSTRAINT FK_FactCurrencyRate_DimDate; 
ALTER TABLE FactFinance DROP CONSTRAINT FK_FactFinance_DimDate; 
ALTER TABLE FactInternetSales DROP CONSTRAINT FK_FactInternetSales_DimDate; 
ALTER TABLE FactInternetSales DROP CONSTRAINT FK_FactInternetSales_DimDate1; 
ALTER TABLE FactInternetSales DROP CONSTRAINT FK_FactInternetSales_DimDate2; 
ALTER TABLE FactProductInventory DROP CONSTRAINT FK_FactProductInventory_DimDate; 
ALTER TABLE FactResellerSales DROP CONSTRAINT FK_FactResellerSales_DimDate; 
ALTER TABLE FactResellerSales DROP CONSTRAINT FK_FactResellerSales_DimDate1;
ALTER TABLE FactResellerSales DROP CONSTRAINT FK_FactResellerSales_DimDate2; 
ALTER TABLE FactSurveyResponse DROP CONSTRAINT FK_FactSurveyResponse_DateKey; 
ALTER TABLE [dbo].[FactCallCenter] DROP CONSTRAINT [FK_FactCallCenter_DimDate];
ALTER TABLE [dbo].[FactSalesQuota] DROP CONSTRAINT [FK_FactSalesQuota_DimDate];
GO

-- Delete date rows
BEGIN TRANSACTION
DELETE FROM dbo.DimDate
WHERE DateKey < 20140101;
SELECT COUNT(*)
FROM dbo.DimDate;
-- ROLLBACK TRANSACTION
COMMIT
-- Add back CONSTRAINTS

ALTER TABLE [dbo].[FactCurrencyRate]  WITH CHECK ADD  CONSTRAINT [FK_FactCurrencyRate_DimDate] FOREIGN KEY([DateKey])
REFERENCES [dbo].[DimDate] ([DateKey]);
ALTER TABLE [dbo].[FactCurrencyRate] CHECK CONSTRAINT [FK_FactCurrencyRate_DimDate];

ALTER TABLE [dbo].[FactFinance]  WITH CHECK ADD  CONSTRAINT [FK_FactFinance_DimDate] FOREIGN KEY([DateKey])
REFERENCES [dbo].[DimDate] ([DateKey]);
ALTER TABLE [dbo].[FactFinance] CHECK CONSTRAINT [FK_FactFinance_DimDate];

ALTER TABLE [dbo].[FactInternetSales]  WITH CHECK ADD  CONSTRAINT [FK_FactInternetSales_DimDate] FOREIGN KEY([OrderDateKey])
REFERENCES [dbo].[DimDate] ([DateKey]);
ALTER TABLE [dbo].[FactInternetSales] CHECK CONSTRAINT [FK_FactInternetSales_DimDate];

ALTER TABLE [dbo].[FactInternetSales]  WITH CHECK ADD  CONSTRAINT [FK_FactInternetSales_DimDate1] FOREIGN KEY([DueDateKey])
REFERENCES [dbo].[DimDate] ([DateKey]);
ALTER TABLE [dbo].[FactInternetSales] CHECK CONSTRAINT [FK_FactInternetSales_DimDate1];

ALTER TABLE [dbo].[FactInternetSales]  WITH CHECK ADD  CONSTRAINT [FK_FactInternetSales_DimDate2] FOREIGN KEY([ShipDateKey])
REFERENCES [dbo].[DimDate] ([DateKey]);
ALTER TABLE [dbo].[FactInternetSales] CHECK CONSTRAINT [FK_FactInternetSales_DimDate2];

ALTER TABLE [dbo].[FactProductInventory]  WITH CHECK ADD  CONSTRAINT [FK_FactProductInventory_DimDate] FOREIGN KEY([DateKey])
REFERENCES [dbo].[DimDate] ([DateKey]);
ALTER TABLE [dbo].[FactProductInventory] CHECK CONSTRAINT [FK_FactProductInventory_DimDate];

ALTER TABLE [dbo].[FactResellerSales]  WITH CHECK ADD  CONSTRAINT [FK_FactResellerSales_DimDate] FOREIGN KEY([OrderDateKey])
REFERENCES [dbo].[DimDate] ([DateKey]);
ALTER TABLE [dbo].[FactResellerSales] CHECK CONSTRAINT [FK_FactResellerSales_DimDate];

ALTER TABLE [dbo].[FactResellerSales]  WITH CHECK ADD  CONSTRAINT [FK_FactResellerSales_DimDate1] FOREIGN KEY([DueDateKey])
REFERENCES [dbo].[DimDate] ([DateKey]);
ALTER TABLE [dbo].[FactResellerSales] CHECK CONSTRAINT [FK_FactResellerSales_DimDate1];

ALTER TABLE [dbo].[FactResellerSales]  WITH CHECK ADD  CONSTRAINT [FK_FactResellerSales_DimDate2] FOREIGN KEY([ShipDateKey])
REFERENCES [dbo].[DimDate] ([DateKey]);
ALTER TABLE [dbo].[FactResellerSales] CHECK CONSTRAINT [FK_FactResellerSales_DimDate2]

ALTER TABLE [dbo].[FactSurveyResponse]  WITH CHECK ADD  CONSTRAINT [FK_FactSurveyResponse_DateKey] FOREIGN KEY([DateKey])
REFERENCES [dbo].[DimDate] ([DateKey]);
ALTER TABLE [dbo].[FactSurveyResponse] CHECK CONSTRAINT [FK_FactSurveyResponse_DateKey];

ALTER TABLE [dbo].[FactCallCenter]  WITH CHECK ADD  CONSTRAINT [FK_FactCallCenter_DimDate] FOREIGN KEY([DateKey])
REFERENCES [dbo].[DimDate] ([DateKey]);
ALTER TABLE [dbo].[FactCallCenter] CHECK CONSTRAINT [FK_FactCallCenter_DimDate];

ALTER TABLE [dbo].[FactSalesQuota]  WITH CHECK ADD  CONSTRAINT [FK_FactSalesQuota_DimDate] FOREIGN KEY([DateKey])
REFERENCES [dbo].[DimDate] ([DateKey]);
ALTER TABLE [dbo].[FactSalesQuota] CHECK CONSTRAINT [FK_FactSalesQuota_DimDate];
GO
*/

SELECT MIN(DateKey) AS minDate, MAX(DateKey) AS maxDate
FROM dbo.DimDate;

-- Distribution of orders by day of the week
SELECT DATENAME(WEEKDAY, OrderDate) AS TheDay,
 COUNT(*) AS cnt
FROM dbo.FactInternetSales
GROUP BY DATENAME(WEEKDAY, OrderDate);
GO

/* Make customers 18 years younger 
SELECT BirthDate, 
 DATEADD(year, 18, BirthDate) AS NewBirthDate
FROM dbo.DimCustomer;

UPDATE dbo.DimCustomer
   SET BirthDate = DATEADD(year, 18, BirthDate);
GO
*/

-- Customers' age 
SELECT MIN(Age) AS minAge, MAX(Age) AS maxAge, AVG(1.0*Age) AS avgAge
FROM dbo.vTargetMail;

-- Customers' birth date
SELECT MIN(BirthDate) AS minBD, MAX(BirthDate) AS maxBD
FROM dbo.DimCustomer;

/* Make employees 10 years younger,
hired 10 years later

UPDATE dbo.DimEmployee
   SET BirthDate = DATEADD(year, 10, BirthDate),
       HireDate = DATEADD(year, 10, HireDate);
*/

-- Employees employed at age
SELECT MIN(DATEDIFF(year, BirthDate, HireDate)) AS EmployeedAtMinAge,
 MAX(DATEDIFF(year, BirthDate, HireDate)) AS EmployeedAtMaxAge
FROM dbo.DimEmployee;

-- Employees' birth and hire date
SELECT MIN(BirthDate) AS minBD, MAX(BirthDate) AS maxBD,
 MIN(HireDate) AS minHD, MAX(HireDate) AS maxHD
FROM dbo.DimEmployee;
GO

/*
cYear       cnt         SalesAmount           Quatity
----------- ----------- --------------------- -----------
2019        14          43421.0364            14
2020        2216        7075525.9291          2216
2021        3397        5842485.1952          3397
2022        52801       16351550.34           52801
2023        1970        45694.72              1970


cYear       cnt         SalesAmount           Quatity
----------- ----------- --------------------- -----------
2019        352         489328.5787           820
2020        9830        18192802.7143         28572
2021        22133       28193631.5321         81328
2022        28540       33574834.1572         103658


minDate     maxDate
----------- -----------
20140101    20231231


TheDay                         cnt
------------------------------ -----------
Wednesday                      8457
Saturday                       8919
Monday                         8558
Sunday                         8594
Friday                         8754
Thursday                       8611
Tuesday                        8505


minAge      maxAge      avgAge
----------- ----------- ---------------------------------------
18          89          35.394827


minBD      maxBD
---------- ----------
1934-02-10 2004-06-25


EmployeedAtMinAge EmployeedAtMaxAge
----------------- -----------------
18                71


minBD      maxBD      minHD      maxHD
---------- ---------- ---------- ----------
1949-07-11 2000-12-29 2016-01-28 2022-12-28

*/
