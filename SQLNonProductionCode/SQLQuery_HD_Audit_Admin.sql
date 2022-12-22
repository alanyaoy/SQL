



print 'hi'
go

print 'Fatal error, script will not continue!'

set noexec on
print 'ho'
go



use JDE_DB_Alan
go

  --- Hot KEy

  -- Fn + end , Fn + home to begining / end of line
  -- Ctrl + KU , to select whole line, then F5 to execute
  -- Alt + break to stop run
 -- CTRL+HOME - Top of the current query window
 -- CTRL+END - End of the query window
 --F5, CTRL + E or ALT + X — Execute the currently selected code


--- Get Computer and Instance name easily --- 16/12/2017
select @@version
select @@servername -- yield -DESKTOP-ANE9ABR\HOME_2016EXPAD'
select @@servicename -- yield 'HOME_2016EXPAD'

use demandplanning
go


create database TestDb


SELECT  createdate as Sql_Server_Install_Date 
FROM    sys.syslogins 
where   sid = 0x010100000000000512000000

--- installed server info ---
DECLARE @GetInstances TABLE
( Value nvarchar(100),
 InstanceNames nvarchar(100),
 Data nvarchar(100))

Insert into @GetInstances
EXECUTE xp_regread
  @rootkey = 'HKEY_LOCAL_MACHINE',
  @key = 'SOFTWARE\Microsoft\Microsoft SQL Server',
  @value_name = 'InstalledInstances'

Select InstanceNames from @GetInstances 

---------------------------------

SELECT 
    DB_NAME(dbid) as DBName, 
    COUNT(dbid) as NumberOfConnections,
    loginame as LoginName
FROM
    sys.sysprocesses
WHERE 
    dbid > 0
GROUP BY 
    dbid, loginame


----------------------------------------
use JDE_DB_Alan
go


----- find out SQL server version ----------
select @@version
select @@servername

SELECT
  CASE 
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '8%' THEN 'SQL2000'
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '9%' THEN 'SQL2005'
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '10.0%' THEN 'SQL2008'
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '10.5%' THEN 'SQL2008 R2'
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '11%' THEN 'SQL2012'
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '12%' THEN 'SQL2014'
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '13%' THEN 'SQL2016'     
     ELSE 'unknown'
  END AS MajorVersion,
  SERVERPROPERTY('ProductLevel') AS ProductLevel,
  SERVERPROPERTY('Edition') AS Edition,
  SERVERPROPERTY('ProductVersion') AS ProductVersion

--- 27/9/17 ---
---------- check the file size -----

select
a.FILEID,
[FILE_SIZE_MB] = 
convert(decimal(12,2),round(a.size/128.000,2)),
[SPACE_USED_MB] =
convert(decimal(12,2),round(fileproperty(a.name, 'SpaceUsed')/128.000,2)),
[FREE_SPACE_MB] =
convert(decimal(12,2),round((a.size-fileproperty(a.name, 'SpaceUsed'))/128.000,2)) ,
NAME = left(a.NAME,15),
FILENAME = left(a.FILENAME,30)
from
dbo.sysfiles a


--------------------------------------------------------------------------
https://social.technet.microsoft.com/wiki/contents/articles/33766.sql-server-troubleshooting-how-to-recover-views-and-procedures-dropped-by-mistake.aspx

----- Recover Accidently deleted View or Store procedure ------ 15/6/2020
SELECT  Convert(varchar(Max),Substring([RowLog Contents 0],33,LEN([RowLog Contents 0]))) as [Script] 
FROM fn_dblog(DEFAULT, DEFAULT) 
Where [Operation]='LOP_DELETE_ROWS' And [Context]='LCX_MARK_AS_GHOST' And [AllocUnitName]='sys.sysobjvalues.clst'

--If you want to try, just:

create view Technet as
select 1 as one,2 as two,3 as three,4 as fourth

--drop the view:
drop view technet

--and, let's try also with a procedure:

create procedure forum as
declare @st int
set @st=1
print @st
drop the procedure:

drop procedure forum
--Just execute abbove code:

--------------------------------------------------------------------------


---------- Check When SP is runned -------------------

SELECT CASE WHEN database_id = 32767 then 'Resource' ELSE DB_NAME(database_id)END AS DBName
      ,OBJECT_SCHEMA_NAME(object_id,database_id) AS [SCHEMA_NAME] 
      ,OBJECT_NAME(object_id,database_id)AS [OBJECT_NAME]
      ,cached_time
      ,last_execution_time
      ,execution_count
      ,total_worker_time / execution_count AS AVG_CPU
      ,total_elapsed_time / execution_count AS AVG_ELAPSED
      ,total_logical_reads / execution_count AS AVG_LOGICAL_READS
      ,total_logical_writes / execution_count AS AVG_LOGICAL_WRITES
      ,total_physical_reads  / execution_count AS AVG_PHYSICAL_READS
FROM sys.dm_exec_procedure_stats st
order by st.last_execution_time desc
--ORDER BY AVG_LOGICAL_READS DESC


----------------Checl when Store procedure is created and updated---------------------------------------------------

SELECT name, create_date, modify_date 
FROM sys.objects
WHERE type = 'P'
ORDER BY modify_date DESC

select 1

SELECT
    txt.TEXT AS [SQL Statement],
    qs.EXECUTION_COUNT [No. Times Executed],
    qs.LAST_EXECUTION_TIME AS [Last Time Executed], 
    DB_NAME(txt.dbid) AS [Database]
FROM SYS.DM_EXEC_QUERY_STATS AS qs
    CROSS APPLY SYS.DM_EXEC_SQL_TEXT(qs.SQL_HANDLE) AS txt
ORDER BY qs.LAST_EXECUTION_TIME DESC


---------- check / identify all stored procedures referring a particular table -------------

 SELECT Name
FROM sys.procedures
--WHERE OBJECT_DEFINITION(OBJECT_ID) LIKE '%TableNameOrWhatever%'
  WHERE OBJECT_DEFINITION(OBJECT_ID) LIKE '%Master_Vendor_Item_CrossRef%'



---~~~~~~~~~~~~~~~~~~~~~ List All tables its columns and datatype 19/11/2017 use first one------------------------
declare @tblname varchar(100) = ('%pareto%')
SELECT sch.name AS 'schema', 
		tb.name AS Table_Name
		,c.name AS Column_Name, c.column_id	
		,tp.name AS data_type_name
		--,tp.is_user_defined, tp.is_assembly_type
		, case c.is_nullable when 1 then 'Yes' else 'No' end as nullable, c.PRECISION precision_,c.scale,SCHEMA_NAME(tp.schema_id) AS DataTypeSchema,tp.max_length as data_type_maxLng,c.max_length,i.rows as RecordCount
FROM sys.columns AS c
	 INNER JOIN sys.types AS tp ON c.user_type_id=tp.user_type_id	
	 INNER JOIN sys.tables tb ON tb.OBJECT_ID = c.OBJECT_ID	
	 INNER JOIN sys.schemas sch ON sch.schema_id = tb.schema_id	
	 inner join INFORMATION_SCHEMA.COLUMNS schCol on schcol.TABLE_SCHEMA = sch.name and schcol.TABLE_NAME = tb.name and schcol.COLUMN_NAME = c.name
	 inner join sys.sysindexes i on tb.object_id = i.id
where tb.name like @tblname and i.rows<>0
 -- where tb.name like ('%pare%') and i.rows<>0
ORDER BY sch.name, tb.name, c.column_id
---------

SELECT T.name AS Table_Name,C.name AS Column_Name,c.column_id,P.name AS Data_Type ,P.max_length AS Size ,CAST(P.precision AS VARCHAR) + '/' + CAST(P.scale AS VARCHAR) AS Precision_Scale
FROM sys.objects AS T JOIN sys.columns AS C ON T.object_id = C.object_id JOIN sys.types AS P ON C.system_type_id = P.system_type_id
where t.name not like ('sys%')
where t.name like ('%stk%') order by c.column_id

SELECT TABLE_SCHEMA ,TABLE_NAME ,COLUMN_NAME ,ORDINAL_POSITION ,COLUMN_DEFAULT ,DATA_TYPE ,CHARACTER_MAXIMUM_LENGTH ,NUMERIC_PRECISION ,NUMERIC_PRECISION_RADIX ,NUMERIC_SCALE ,DATETIME_PRECISION
FROM INFORMATION_SCHEMA.COLUMNS;

---~~~~~~~~~~~~~~~~~~~~~ Check Tables Rows count , good for storge planning and partition 19/11/2017------------------------
select * from sys.tables
select * from sys.sysindexes i where i.id = 245575913

select t.name as TableName, SCHEMA_NAME(t.schema_id) as SchemaName,t.object_id,i.rows as RecordCount,getdate() as Reportdate
from sys.tables t inner join sys.sysindexes i on t.object_id = i.id 
where i.rows <>0
order by SchemaName, TableName



---~~~~~~~~~~~~~~~~~~~ List Table name / data type / primary key etc Meta data --------  20/1/2021
SELECT COUNT(*) 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE 
   TABLE_NAME = 'table_name'

SELECT COUNT(*) 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE 
   TABLE_NAME = 'Master_V4102A'

--- To Get all the metadata you require For a table except for the Pk information ---
 select COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, 
       NUMERIC_PRECISION, DATETIME_PRECISION, 
       IS_NULLABLE 
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME='Master_V4102A'


SELECT 
    c.name 'Column Name',
    t.Name 'Data type',
    c.max_length 'Max Length',
    c.precision ,
    c.scale ,
    c.is_nullable,
    ISNULL(i.is_primary_key, 0) 'Primary Key'
FROM    
    sys.columns c
INNER JOIN 
    sys.types t ON c.user_type_id = t.user_type_id
LEFT OUTER JOIN 
    sys.index_columns ic ON ic.object_id = c.object_id AND ic.column_id = c.column_id
LEFT OUTER JOIN 
    sys.indexes i ON ic.object_id = i.object_id AND ic.index_id = i.index_id
WHERE
    c.object_id = OBJECT_ID('JDE_DB_Alan.Master_V4102A')

	
--~~~~~~~~~~~~~~~~~~~~~ Check When a table is update ------------- very good

select  DB_NAME(x.database_id) AS [Database],
		us.database_id,t.object_id,t.name as TabelName,t.create_date as SystemCreateDate,t.modify_date as SystemModifyDate
		,last_user_update,last_user_scan		
FROM   sys.dm_db_index_usage_stats us
       JOIN sys.tables t  ON t.object_id = us.object_id
	   inner join sys.databases x on x.database_id = us.database_id		-- OK works

WHERE   --   database_id = '5'							-- JDE_DB_Alan
        --    us.database_id = db_id('JDE_DB_Alan')      -- works
             DB_NAME(x.database_id)='JDE_DB_Alan'
       --AND t.object_id = object_id('dbo.YourTable') 
	   --AND t.object_id = '1858105660'
	   and t.name like ('%ML345%')
	     and t.name like ('SlsHist%')
	   --and t.name like ('%Superss%')
	    and  t.name like ('%hd%')

order by us.last_user_update desc --,t.modify_date desc

select * from sys.tables t where t.name like ('SalesHist%')
select * from sys.dm_db_index_usage_stats where object_id like ('%85010%')

SELECT DB_NAME(database_id) AS [Database], database_id FROM sys.databases;  

---~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--- below to check who access the table -- does not work


select * from sys.dm_db_index_usage_stats
select * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload x

---- below check which table is most frequently used --- good for house keeping 8/11/2017
;with cte_recent as 
( 
select SCHEMA_NAME(B.schema_id) +'.'+object_name(b.object_id) as tbl_name, 
(select MAX(last_user_dt) from (values (last_user_seek),(last_user_scan),(last_user_lookup)) as all_val(last_user_dt)) as access_datetime FROM sys.dm_db_index_usage_stats a 
right outer join sys.tables b on a.object_id =  b.object_id 
) 
select tbl_name,max(access_datetime) as recent_datetime  from cte_recent 
group by tbl_name 
order by recent_datetime desc , 1

--- access to the db ---
https://social.msdn.microsoft.com/Forums/sqlserver/en-US/03b701b2-7301-456c-bbde-17246fb55d64/who-has-accessed-ms-sql-server-which-tables?forum=transactsql
SELECT 
   I.NTUserName,
   I.loginname,
   I.SessionLoginName,
   I.databasename,
   Min(I.StartTime) as first_used,
   Max(I.StartTime) as last_used,
   S.principal_id,
   S.sid,
   S.type_desc,
   S.name
FROM
   sys.traces T CROSS Apply
   ::fn_trace_gettable(CASE 
                          WHEN CHARINDEX( '_',T.[path]) <> 0 THEN 
                               SUBSTRING(T.PATH, 1, CHARINDEX( '_',T.[path])-1) + '.trc' 
                          ELSE T.[path] 
                       End, T.max_files) I LEFT JOIN
   sys.server_principals S ON
       CONVERT(VARBINARY(MAX), I.loginsid) = S.sid  
WHERE
    T.id = 1 And
    I.LoginSid is not null
Group By
   I.NTUserName,
   I.loginname,
   I.SessionLoginName,
   I.databasename,
   S.principal_id,
   S.sid,
   S.type_desc,
   S.name
order by last_used desc


----------- Schema and Table object property ------------ good 
USE [JDE_DB_Alan]; 
SELECT name AS object_name 
  ,SCHEMA_NAME(schema_id) AS schema_name
  ,type_desc
  ,create_date
  ,modify_date
FROM sys.objects
WHERE modify_date > GETDATE() - 10
ORDER BY modify_date;


----------- Tables and Columns property ------------ very good 3/11/2017
--USE [Northwind]; 
USE [JDE_DB_Alan]; 
SELECT OBJECT_SCHEMA_NAME(T.[object_id],DB_ID()) AS [Schema],   
        T.[name] AS [table_name], AC.[name] AS [column_name],   
        TY.[name] AS system_data_type, AC.[max_length],  
        AC.[precision], AC.[scale], AC.[is_nullable], AC.[is_ansi_padded]  
FROM sys.[tables] AS T   
  INNER JOIN sys.[all_columns] AC ON T.[object_id] = AC.[object_id]  
 INNER JOIN sys.[types] TY ON AC.[system_type_id] = TY.[system_type_id] AND AC.[user_type_id] = TY.[user_type_id]   
WHERE T.[is_ms_shipped] = 0  
ORDER BY T.[name], AC.[column_id]




---====================================================================================
--- Create INdex ---
USE AdventureWorks2012;  
GO  
-- Create a new table with three columns.  
CREATE TABLE dbo.TestTable  
    (TestCol1 int NOT NULL,  
     TestCol2 nchar(10) NULL,  
     TestCol3 nvarchar(50) NULL);  
GO  
-- Create a clustered index called IX_TestTable_TestCol1  
-- on the dbo.TestTable table using the TestCol1 column.  
CREATE CLUSTERED INDEX IX_TestTable_TestCol1   
    ON dbo.TestTable (TestCol1);   
GO  
---====================================================================================
https://www.brentozar.com/archive/2013/02/disabling-vs-dropping-indexes/
-------------- INDEX 5/11/2017 ---------------------
CREATE INDEX index_name ON table_name (column1, column2, ...);			--- Duplicate values are allowed:
CREATE UNIQUE INDEX index_name ON table_name (column1, column2, ...);   --- Duplicate values are NOT allowed:

CREATE INDEX i1 ON t1 (col1);							-- Create a nonclustered index on a table or view  
CREATE CLUSTERED INDEX i1 ON d1.s1.t1 (col1);			-- Create a clustered index on a table and use a 3-part name for the table  

-- Syntax for SQL Server and Azure SQL Database
-- Create a nonclustered index with a unique constraint 
-- on 3 columns and specify the sort order for each column  
CREATE UNIQUE INDEX i1 ON t1 (col1 DESC, col2 ASC, col3 DESC);  


CREATE INDEX idx_pname ON Persons (LastName, FirstName);				--- Example
CREATE NONCLUSTERED INDEX FC_ItemNumber ON JDE_DB_Alan.SalesHistoryAWFHDMTuploadToFCPRO(ItemNumber)


-- disable and re-enable index ---
ALTER INDEX IX_IndexName ON Schema.TableName DISABLE;
ALTER INDEX IX_IndexName ON Schema.TableName REBUILD;
alter index FC_ItemNumber on JDE_DB_Alan.SalesHistoryAWFHDMTuploadToFCPRO disable

-- drop index ---
DROP INDEX IndexName ON Schema.TableName;


--------------- check Index status of an object ------------------------
declare @tbl varchar(100)
set @tbl = 'JDE_DB_Alan.SalesHistoryAWFHDMTuploadToFCPRO'
select
sys.objects.name
,sys.indexes.name
,sys.indexes.type_desc AS [Index Type]
	,sys.indexes.index_id AS [Index ID]
	,is_disabled = case is_disabled
					when '1' then 'disabled'
					when '0' then 'enabled' End 
from sys.indexes
inner join sys.objects on sys.objects.object_id = sys.indexes.object_id
--where sys.indexes.is_disabled = 1
-- where sys.objects.object_id = OBJECT_ID(@tbl) 
order by
sys.objects.name,
sys.indexes.name
---------------------------------------------------
--- check if field has special character ---
DECLARE @MyString VARCHAR(100)
SET @MyString = 'adgkjb$'

IF (@MyString LIKE '%[^a-zA-Z0-9]%')
PRINT 'Contains "special" characters'
ELSE
PRINT 'Does not contain "special" characters'

SELECT * FROM tableName WHERE columnName LIKE "%#%" OR columnName LIKE "%$%" OR (etc.)
---------------------------------

CREATE NONCLUSTERED INDEX NI_Salary
ON Employee (Salary DESC)
GO

ALTER INDEX NI_Salary ON
Employee DISABLE
GO

--------------------- check constraint ------------------------------------------
------ Check constraint syntax ------
CREATE TABLE Products_2
(
ProductID int PRIMARY KEY,
UnitPrice money,
CONSTRAINT CK_UnitPrice2 CHECK(UnitPrice > 0 AND UnitPrice < 100)
)
ALTER TABLE Employees_2 ADD CONSTRAINT CK_HireDate CHECK(hiredate < GETDATE())
ALTER TABLE Employees_2 WITH NOCHECK ADD CONSTRAINT CK_Salary CHECK(Salary > 0)

--- drop constraint if exist ---
IF (OBJECT_ID('FK_TableName_TableName2', 'F') IS NOT NULL)
BEGIN
    ALTER TABLE dbo.TableName DROP CONSTRAINT FK_TableName_TableName2
END

--- check if comma exist ---
drop table JDE_DB_Alan.test
create table JDE_DB_Alan.test (mycol char(20) ,constraint ck_illegal_char check(charindex(',',mycol)=0 ))					  -- do not allow comma	
create table JDE_DB_Alan.test (mycol char(20) ,constraint ck_illegal_char check (len(mycol) - len(replace(mycol,',',''))>0))   -- allow comma
create table JDE_DB_Alan.test (mycol char(20) )
--insert into JDE_DB_Alan.test values('tes,t')
insert into JDE_DB_Alan.test select 'test'
union all select 'test,'
union all select 'tes,t'
union all select ',test'
union all select 'ab'
select * from JDE_DB_Alan.test
select charindex(',','test')
select len('test') - len(replace('test',',',''))


declare @t table (sfilenames varchar(20))
insert @t
select 'test,'
union all select 'test'
union all select 'tes,t'
union all select ',test'
union all select 'ab'

--select * from @t where charindex(',',sfilenames ) > 0
select * from @t where len(sfilenames) - len(replace(sfilenames,',',''))>0


select sfilenames 
from tablefiles 
where sfilenames LIKE '%,%'

select sfilenames from tablefiles where charindex(',',sfilenames ) > 0

---
--Try this if you want 040713 08:07AM

declare @strings varchar(50)
select @strings ='1OF2. 040713 08:07 AM'

select (case when @strings like'%.%' then 
right(@strings, charindex('.', @strings) +10) else @strings end)

-------------------------------------------
--Extract a substring from a string:
SELECT SUBSTRING('SQL Tutorial', 1, 100) AS ExtractString;


---------- Check constraint ------------------

CONSTRAINT <constraint name> CHECK (<search condition>)


------------------------------------------------------------------------------------------------------------


SELECT name AS 'Pool Name', 
cache_memory_kb/1024.0 AS [cache_memory_MB], 
used_memory_kb/1024.0 AS [used_memory_MB] 
FROM sys.dm_resource_governor_resource_pools;


--------------------------------------------------------------------------------------------------------------------------
------ Check All tables & Size/Space -------- 13/7/2018 -- very good --- https://stackoverflow.com/questions/7892334/get-size-of-all-tables-in-database

SELECT 
    t.NAME AS TableName,
    s.Name AS SchemaName,
    p.rows AS RowCounts,
    SUM(a.total_pages) * 8 AS TotalSpaceKB, 
    CAST(ROUND(((SUM(a.total_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)) AS TotalSpaceMB,
    SUM(a.used_pages) * 8 AS UsedSpaceKB, 
    CAST(ROUND(((SUM(a.used_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)) AS UsedSpaceMB, 
    (SUM(a.total_pages) - SUM(a.used_pages)) * 8 AS UnusedSpaceKB,
    CAST(ROUND(((SUM(a.total_pages) - SUM(a.used_pages)) * 8) / 1024.00, 2) AS NUMERIC(36, 2)) AS UnusedSpaceMB
FROM 
    sys.tables t
INNER JOIN      
    sys.indexes i ON t.OBJECT_ID = i.object_id
INNER JOIN 
    sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
INNER JOIN 
    sys.allocation_units a ON p.partition_id = a.container_id
LEFT OUTER JOIN 
    sys.schemas s ON t.schema_id = s.schema_id
WHERE 
    t.NAME NOT LIKE 'dt%' 
    AND t.is_ms_shipped = 0
    AND i.OBJECT_ID > 255 
GROUP BY 
    t.Name, s.Name, p.Rows
ORDER BY 
    t.Name


--- spaced used by index ---

SELECT
    OBJECT_NAME(i.OBJECT_ID) AS TableName,
    i.name AS IndexName,
    i.index_id AS IndexID,
    8 * SUM(a.used_pages) AS 'Indexsize(KB)'
FROM
    sys.indexes AS i JOIN 
    sys.partitions AS p ON p.OBJECT_ID = i.OBJECT_ID AND p.index_id = i.index_id JOIN 
    sys.allocation_units AS a ON a.container_id = p.partition_id
GROUP BY
    i.OBJECT_ID,
    i.index_id,
    i.name
ORDER BY
    OBJECT_NAME(i.OBJECT_ID),
    i.index_id



 ---================ How to Skip SQL Query --- Method 1   30/7/2018==================================================================
 select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('42.210.031')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('18.013.089')

GOTO SKIP_3;


select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('18.010.035')


SKIP_3:
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('28.617.002')



GOTO END_EXIT; 

select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('82.391.912')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('24.7250.4459')


END_EXIT:

 ---=================How to Skip SQL Query --- Method 2   30/7/2018= =================================================================


 WHILE 1 = 1
BEGIN
   -- Do work here
   -- If you need to stop execution then use a BREAK

   select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('42.210.031')
	select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('18.013.089')

    BREAK; --Make sure to have this break at the end to prevent infinite loop

	select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('18.010.035')
END


 ---=================How to Skip SQL Query --- Method 3   30/7/2018= =================================================================
 https://stackoverflow.com/questions/659188/sql-server-stop-or-break-execution-of-a-sql-script?noredirect=1&lq=1
print 'hi'
go

print 'Fatal error, script will not continue!'
set noexec on

print 'ho'
go

-- last line of the script
set noexec off -- Turn execution back on; only needed in SSMS, so as to be able 
               -- to run this script again in the same session.


----------------Checl when Store procedure is created and updated---------------------------------------------------

SELECT name, create_date, modify_date 
FROM sys.objects
WHERE type = 'P'
ORDER BY modify_date DESC







----- ALWAYS ENTER YOUR CODE ABOVE THIS LINE -------- ----- ALWAYS ENTER YOUR CODE ABOVE THIS LINE -------- ----- ALWAYS ENTER YOUR CODE ABOVE THIS LINE --------
----- NEVER ENTER YOUR CODE BELOW THIS LINE --------- ----- NEVER ENTER YOUR CODE BELOW THIS LINE --------- ----- NEVER ENTER YOUR CODE BELOW THIS LINE ---------

 ---&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&------------------
-- END_EXIT:

-- last line of the script
set noexec off -- Turn execution back on; only needed in SSMS, so as to be able 
               -- to run this script again in the same session.
