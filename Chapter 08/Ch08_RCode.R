# Business Analytics using Power BI with Excel
# Chapter 08 Code - R

# R as a data source
# Use the iris dataset
View(iris)

# Unpivot (melt) the data
# install.packages("reshape2")
library(reshape2)
irisMeltR <- melt(iris, id.vars = "Species")
View(irisMeltR)
# irisMeltR is the data source


# R Clustering
# install.packages("RODBC")
library(RODBC)

# K-Means Clustering
# Read SQL Server data
con <- odbcConnect("AWDW", uid = "RUser", pwd = "Pa$$w0rd")
TM <- sqlQuery(con,
"
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
 ROUND(
 (1.0*Age - AVG(Age) OVER()) /
  STDEV(Age) OVER(), 2) AS AgeScaledSQL,
 ROUND(
 (1.0*YearlyIncome - AVG(YearlyIncome) OVER()) /
  STDEV(YearlyIncome) OVER(), 2) AS IncomeScaledSQL,
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
 END AS MarStaNumeric
FROM dbo.vTargetMail;
")
close(con)
# View(TM)

# Order Education
TM$Education = factor(TM$Education, order = TRUE,
                      levels = c("Partial High School",
                                 "High School", "Partial College",
                                 "Bachelors", "Graduate Degree"))


# Select some numerical columns only
TM1 <- TM[, c("NumberCarsOwned", "NumberChildrenAtHome", 
              "BikeBuyer", "EducationNumeric",
              "AgeScaledSQL", "IncomeScaledSQL")]
# View(TM1)

# 20% sample
# install.packages("dplyr")
library(dplyr)
TM1 <- sample_frac(TM1, 0.2)
# View(TM1)

# Create the clustering model 
cl3 <- kmeans(TM1, centers=3)

# Centers and clusters for the original data
cl3$centers
cl3$cluster
# 3 centers, all cases cluster memberships

# Create a data frame with centers' coordinates
# for all cases
dfcenters <- cl3$centers[cl3$cluster, ]
View(dfcenters)

# Difference between original data and centers for each case
TM1 - dfcenters
# Row sums of differences
rowSums(TM1 - dfcenters)
# Distances
distances <- sqrt(rowSums((TM1 - dfcenters)^2))
View(distances)
# Find top 5 outliers
outliers <- order(distances, decreasing=T)[1:5]
outliers
View(TM1[outliers,])

# Plot data and centers and outliers
# Add the scaled variables Age and Income
plot(TM1[,c("IncomeScaledSQL", "AgeScaledSQL")], pch=19, col=cl3$cluster, cex=1)
points(cl3$centers[,c("IncomeScaledSQL", "AgeScaledSQL")], col=1:3, pch=15, cex=3)
points(TM1[outliers, c("IncomeScaledSQL", "AgeScaledSQL")], pch="+", col=4, cex=4)


# Decision tees from the base installation
library(rpart)
TMRP <- rpart(BikeBuyer ~
                MaritalStatus + TotalChildren + 
                NumberChildrenAtHome +
                Education + Occupation +
                HouseOwnerFlag + NumberCarsOwned + 
                CommuteDistance + Region +
                AgeDiscretized + IncomeDiscretized,
              data = TM, cp = 0.007)

# Plot the tree
# install.packages("rpart.plot")
library(rpart.plot)
rpart.plot(TMRP, box.palette = "auto", type = 0)
rpart.plot(TMRP, box.palette = "auto", type = 1)
rpart.plot(TMRP, box.palette = "auto", type = 2)
rpart.plot(TMRP, box.palette = "auto", type = 3)
rpart.plot(TMRP, box.palette = "auto", type = 4, tweak = 2.5)
rpart.plot(TMRP, 
           box.palette = c("tomato", "plum1", "yellow", "greenyellow", "green"), 
           type = 4, branch = 0.4, tweak = 1.5)

