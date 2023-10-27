# Business Analytics using Power BI with Excel
# Chapter 09 Code - R


# Sampling with R
# install.packages("RODBC")
library(RODBC)

# Read SQL Server data
con <- odbcConnect("AWDW", uid = "RUser", pwd = "Pa$$w0rd")
TMRandR <- sqlQuery(con,
"
SELECT 
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
FROM dbo.vTargetMail;
")
close(con)
# View(TMRandR)

# 30% sample
# install.packages("dplyr")
library(dplyr)
TMRandR <- sample_frac(TMRandR, 0.3)
# View(TMRandR)
