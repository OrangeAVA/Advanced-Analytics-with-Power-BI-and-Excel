# Business Analytics using Power BI with Excel
# Chapter 08 Code - Python

# Imports
import numpy as np
import pandas as pd
import pyodbc
import matplotlib as mpl
import matplotlib.pyplot as plt
import seaborn as sns

# Reading the data from SQL Server into a pandas data frame
con = pyodbc.connect('DSN=AWDW;UID=RUser;PWD=Pa$$w0rd')
query = """SELECT CustomerKey,
 Age, YearlyIncome AS Income, 
 BikeBuyer, MaritalStatus,
 TotalChildren, NumberChildrenAtHome,
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
"""
TM = pd.read_sql(query, con)

# N of rows and cols
print (TM.shape)
# First 10 rows
print (TM.head(10))

# Define Education as categorical
TM['Education'] = TM['Education'].astype('category')
TM['Education']
# dtype: category, incorrect order
# Reorder
TM['Education'].cat.reorder_categories(
    ["Partial High School", 
     "High School","Partial College", 
     "Bachelors", "Graduate Degree"], inplace=True)
TM['Education']
# dtype: category, correct order

# Define CommuteDistance as ordinal
TM['CommuteDistance'] = TM['CommuteDistance'].astype('category')
TM['CommuteDistance'].cat.reorder_categories(
    ["0-1 Miles", 
     "1-2 Miles","2-5 Miles", 
     "5-10 Miles", "10+ Miles"], inplace=True)
# Define Occupation as ordinal
TM['Occupation'] = TM['Occupation'].astype('category')
TM['Occupation'].cat.reorder_categories(
    ["Manual", 
     "Clerical","Skilled Manual", 
     "Professional", "Management"], inplace=True)

# GMM clustering
from sklearn.mixture import GaussianMixture
# Define and train the model
X = TM[["BikeBuyer", "TotalChildren",
        "NumberChildrenAtHome","HouseOwnerFlag",
        "NumberCarsOwned", "AgeDiscretized",
        "IncomeDiscretized", "EducationNumeric",
        "RegionNumeric", "MarStaNumeric"]]
model = GaussianMixture(n_components = 3, covariance_type = 'full')
model.fit(X)
# Get the clusters vector
y_gmm = model.predict(X)

# Adding cluster membership to the original
TM['Cluster'] = y_gmm
TM.head()

# Seaborn countplot
sns.countplot(x="CommuteDistance", hue="Cluster", data=TM);
plt.show()
# Seaborn countplot
sns.countplot(x="Occupation", hue="Cluster", data=TM);
plt.show()
# Seaborn countplot
sns.countplot(x="Education", hue="Cluster", data=TM);
plt.show()


TMPy = TM[["CustomerKey", "Cluster", "Education", "CommuteDistance", "Occupation", "NumberCarsOwned"]]
TMPy.head()
