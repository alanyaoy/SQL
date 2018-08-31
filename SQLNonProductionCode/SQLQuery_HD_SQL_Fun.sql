
---- select all columns but one ---- 3/11/2017
/* Get the data into a temp table */
SELECT * INTO #TempTable
FROM YourTable
/* Drop the columns that are not needed */
ALTER TABLE #TempTable
DROP COLUMN ColumnToDrop
/* Get results and drop temp table */
SELECT * FROM #TempTable
DROP TABLE #TempTable




-------------- 4/4/2018 ----------------------------------------------------
--- Number of distinct users in the last 3, 6, 9, 12 months SQL? ---
--- lie in hear to solution for this problems is running total ---

Declare @a table(yr int,[month] int,[user] varchar(20))
insert into @A values(2015,7,'user1'),(2015,3,'user2'),(2015,2,'user3'),(2014,10,'user4'),(2014,8,'user5')

select  distinct [user], datediff(month,datefromparts([Yr],[Month],1),getdate())/3 dtMonth 
from @a 

Select distinct Sum(Case when dtMonth=0 Then  1   End) Over() [3MONTH],
Sum(Case when dtMonth IN (0,1)  Then  1   End) Over() [6MONTH],
Sum(Case when dtMonth IN (0,1,2)  Then 1   End) Over() [9MONTH], 
Sum(Case when dtMonth IN (0,1,2,3)  Then 1   End) Over() [12MONTH] 
 from (
select  distinct [user], datediff(month,datefromparts([Yr],[Month],1),getdate())/3 dtMonth 
from @a ) t



Select * ,convert(date,cast(yr as varchar(4))+ '-'+ right('0'+ cast([month] as varchar(3)),2)+'-'+ +'01') dt
from @a

Select 
'Unique users',
count( distinct case when datediff(m,dt,getdate())<=3 then [User] else null  end) months3,
count(distinct case when datediff(m,dt,getdate())<=6 then [User] else null  end) months6,
count(distinct case when datediff(m,dt,getdate())<=12 then [User] else null  end) months12
from (Select * ,convert(date,cast(yr as varchar(4))+ '-'+ right('0'+ cast([month] as varchar(3)),2)+'-'+ +'01') dt
from @a) bc
where bc.dt >= dateadd(YY,-1,getdate())


CREATE TABLE [A] (
    [Year] INTEGER NULL,
    [Month] INTEGER NULL,
    [User] VARCHAR(255) NULL);

GO


-------------- 4/4/2018 ----------------------------------------------------
--- Number of distinct users in the last 3, 6, 9, 12 months SQL? ---
--- lie in hear to solution for this problems is running total ---

--- https://social.msdn.microsoft.com/Forums/sqlserver/en-US/bb224ca7-215b-46ef-8166-bb2e9cf58fcd/number-of-distinct-users-in-the-last-3-6-9-12-months-sql?forum=transactsql

Declare @a table([Year] int,[month] int,[user] varchar(20))
insert into @A
([Year],[Month],[User]) 
VALUES
(2016,8,'Giacomo'),
(2016,9,'Leila'),
(2016,10,'Melodie'),
(2016,11,'Cora'),
(2016,12,'Amanda'),
(2017,1,'Stone'),
(2017,2,'Kaitlin'),
(2017,3,'Gloria'),
(2017,4,'Petra'),
(2017,5,'Kirsten'),
(2017,6,'Cally'),
(2017,7,'Alexander'),
(2017,8,'Ciaran');


;WITH Cte AS
(
SELECT CAST(LTRIM(STR(Year))+'-'+LTRIM(STR(Month))+'-01' AS DATE) DT, [User] FROM @A
)
,Cte2 AS
(
--SELECT DT,[USER],(DENSE_RANK() OVER(ORDER BY DT))  GrpBy FROM Cte --WHERE DT>= DATEADD(MONTH,DATEDIFF(MONTH,0,GETDATE())-12,0)
SELECT DT,[USER],(DENSE_RANK() OVER(ORDER BY DT)-1)/3 GrpBy FROM Cte --WHERE DT>= DATEADD(MONTH,DATEDIFF(MONTH,0,GETDATE())-12,0)
)

,Cte3 AS
(
SELECT GrpBy,COUNT([User]) UserCnt 
FROM CTE2 
GROUP BY GrpBy
)
--select * from cte3

,Cte4 AS
(
SELECT GrpBy,UserCnt2
 FROM CTE3 c3	CROSS APPLY
		( SELECT SUM(UserCnt) UserCnt2 FROM Cte3 WHERE GrpBy<=c3.GrpBy ) c  
)

select * from Cte4

SELECT [0] AS [3 Months],[1] AS [6 Months],[2] AS [9 Months],[3] AS [12 Months] FROM CTE4
PIVOT
(
MAX(UserCnt2) FOR GrpBy IN([0],[1],[2],[3])
)p

--DROP TABLE A 

------------------------------------------------------------------------

DECLARE @Today DATETIME, @nMonths TINYINT
SET @Today = GETDATE()
SET @nMonths = 12

--- Month End Date ---
SELECT MonthEndDate = DATEADD(dd, -1, DATEADD(month, n.n + DATEDIFF(month, 0, @Today),0)) 
FROM (SELECT TOP(@nMonths) n = ROW_NUMBER() OVER (ORDER BY NAME) FROM master.dbo.syscolumns) n

--- Month Begin Date ---
SELECT MonthBeginDate =  DATEADD(month, n.n + DATEDIFF(month, 0, @Today),0)
FROM (SELECT TOP(@nMonths) n = ROW_NUMBER() OVER (ORDER BY NAME) FROM master.dbo.syscolumns) n

SELECT top 12 ROW_NUMBER() OVER (ORDER BY NAME) FROM master.dbo.syscolumns
select * from master.dbo.syscolumns
