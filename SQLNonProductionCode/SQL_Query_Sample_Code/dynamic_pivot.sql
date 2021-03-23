
CREATE DATABASE SqlHintsYearlyData
GO
USE SqlHintsYearlyData
GO
--Create Temporary Sales Table
CREATE TABLE #Sales
(SalesId INT IDENTITY(1,1), SalesDate DateTime)
GO
--Populate 1000 Sample Sales Records With 
--Random past 0 to 5 years as sales date
INSERT INTO #Sales(SalesDate)
VALUES(DATEADD(YEAR, - ROUND(5 * RAND(), 0),GETDATE()))
GO 1000

select * from #Sales
select  distinct left(s.SalesDate,4) y  from #Sales s

select  distinct year(s.Salesdate) from #Sales s

select  (DATEADD(month, - ROUND(5 * RAND(), 0),GETDATE()))	


declare @FromDate date = '2015-01-01'
declare @ToDate date = '2020-12-31'

select dateadd(day, 
               rand(checksum(newid()))*(1+datediff(day, @FromDate, @ToDate)), 
               @FromDate)

SELECT YEAR(SalesDate) [Year],  Count(1)  [Sales Count]   
    INTO #PivotSalesData
FROM #Sales
GROUP BY YEAR(SalesDate) 

select * from #PivotSalesData


DECLARE @DynamicPivotQuery AS NVARCHAR(MAX)
DECLARE @ColumnName AS NVARCHAR(MAX)
 

--Get distinct values of the PIVOT Column 
SELECT @ColumnName= ISNULL(@ColumnName + ',','') 
       + QUOTENAME([Year])
FROM (SELECT DISTINCT [Year] FROM #PivotSalesData) AS Years

--Prepare the PIVOT query using the dynamic 
SET @DynamicPivotQuery = 
  N'SELECT ' + @ColumnName + '
    FROM #PivotSalesData
    PIVOT(SUM( [Sales Count]   ) 
          FOR [Year] IN (' + @ColumnName + ')) AS PVTTable'
--Execute the Dynamic Pivot Query
EXEC sp_executesql @DynamicPivotQuery


