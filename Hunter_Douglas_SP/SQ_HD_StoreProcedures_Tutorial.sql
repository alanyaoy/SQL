---- create simple store procedure ------

USE AdventureWorks
GO

CREATE PROCEDURE dbo.uspGetAddress
AS
SELECT * FROM Person.Address
GO

EXEC dbo.uspGetAddress
-- or
EXEC uspGetAddress
--or just simply
uspGetAddress

-----~~~~~~~~~~~~~~~~~~~~~~~ Stored Procedure ~~~~~~~~~~~~~~~~~~~


DECLARE @CRLF char(2)
       ,@bodyText nvarchar(max)
     --  ,@field1  nvarchar(10)
         ,@field1 date
       ,@field2  nvarchar(10)
SELECT @CRLF=CHAR(13)+CHAR(10)
      --,@field1='your data'
         ,@field1= convert(varchar(10),GETDATE(),126)
      ,@field2='and more'

set @bodyText =
                N'Here is one line of text ' 
                +@CRLF+ N'It would be nice to have this on a 2nd line ' 
            --  +@CRLF+ N'Below is some data: ' + N' ' + N' ' + @field1 + N' ' + ISNULL(@field2 + N' ' ,'')
         --     +@CRLF+ N'Below is some data: ' + N' ' + N' ' + convert(varchar(10),GETDATE(),126) + N' ' + ISNULL(@field2 + N' ' ,'')		-- works
                +@CRLF+ N'Below is some data: ' + N' ' + N' ' + CAST(@field1 as nvarchar(20) ) + N' ' + ISNULL(@field2 + N' ' ,'')
                +@CRLF+ N'This is the last line' 
PRINT @bodyText


// --- 8/10/2014 ------


--- Create SP ---
create procedure spDeleteInsert
as 
select * 
from STAGING.dbo.FinalFcstShot_PRD a 
where ItemName = 'MX5W' 
and a.Whse in ('300') 
and a.DType in ('Units')
go


--- =Delete  SP --- 11/12/2014
drop procedure spDeleteInsert


create procedure spGetFcErrDataOutPut @ItemName varchar(63),@DownLoadDate date,@Whse varchar(10) output
AS
select a.ItemName,a.Whse,a.DataType,a.Date,a.Value,a.DownLoadDate
from STAGING.dbo.FinalFcstShot_PRD a 
Where
     a.ItemName = @ItemName
   and a.DownLoadDate = @DownLoadDate
   and a.DType in ('Units')
     
     
--- Modify SP ---
ALTER procedure [dbo].[spGetFcErrData] 
@ItemName nvarchar(63),
--@Whse nvarchar(10),
@DownLoadDate date
AS
        SET NOCOUNT ON
        select * 
        from STAGING.dbo.FinalFcstShot_PRD a 
        where 
                a.ItemName = @ItemName 
          --and a.Whse = @Whse 
          and a.DownLoadDate = @DownLoadDate
          and a.DType in ('Units')
         PRINT @@ROWCOUNT 

exec spGetFcErrData @ItemName = 'MX5W',@DownLoadDate = '2014-09-30'

declare @mydate date
set @mydate = convert(varchar(10),dateadd(mm,-3,convert(varchar(7),GETDATE(),126)+'-31'),126)
exec spGetFcErrData @ItemName='MX5W', @Whse = '200',@DownLoadDate = @mydate


declare @myItem as varchar(8000)
set @myItem = 'F6001,MX5W'
exec spGetFcErrData @ItemName=@myItem, @Whse = '200',@DownLoadDate = '2014-09-30'


declare @mydate date,@Whse varchar(10)
set @mydate = convert(varchar(10),dateadd(mm,-4,convert(varchar(7),getdate(),126)+'-31'),126)
exec spGetFcErrDataOutPut @ItemName = 'F6001', @DownLoadDate =@mydate , @Whse =@Whse output
select @Whse as WH



select convert(varchar(10),dateadd(mm,-3,convert(varchar(7),GETDATE(),126)+'-31'),126)
select distinct downloaddate from STAGING.dbo.FinalFcstShot_PRD a 

 select * from STAGING.dbo.FinalFcstShot_PRD a where a.itemname in ('834300W') and a.Whse in ('200') and a.DownLoadDate in ('2014-10-1')
 select * from STAGING.dbo.FinalFcstShot_PRD a where a.DataType in ('Adjusted History','Revenue History') and a.itemname in ('F7111') and a.Whse in ('300')



---------------------------------------
--- Preparation for SP ---
select * from STAGING.dbo.FinalFcstShot_ImportData a 

 Insert into STAGING.dbo.FinalFcstShot_ImportData  
 select * from STAGING.dbo.FinalFcstShot_PRD a 
 where a.DataType in ('Adjusted History','Revenue History') and a.itemname in ('F7111') and a.Whse in ('200')

 delete from STAGING.dbo.FinalFcstShot_ImportData where itemname in ('MX5W')
 truncate table  STAGING.dbo.FinalFcstShot_ImportData
  
--- Create SP ---

Create Procedure spDeleteInsert @ItemName1 nvarchar(63),@ItemName2 nvarchar(63)
AS
Delete from STAGING.dbo.FinalFcstShot_ImportData where ItemName = @ItemName1

Insert into STAGING.dbo.FinalFcstShot_ImportData 
 Select * from STAGING.dbo.FinalFcstShot_PRD a 
 where a.DataType in ('Adjusted History','Revenue History') 
 and a.itemname = @ItemName2 and a.Whse in ('200')
GO


exec spDeleteInsert @ItemName1 ('F7111','8511'),@ItemName2 ='MX5W'




------ SP Passing variables with Multi Values  --------- 4/12/2014

----- Simple excercise --- Using Type Table contains only one columns ( date type is Int - for Warehouse number ) -----
create type IntTable as Table
(
        val int null
)


CREATE PROCEDURE spMultiValue
(
        @Whse IntTable readonly
) as begin
        SELECT ItemName,c.Whse,c.DownLoadDate,c.Value
        FROM staging.dbo.FinalFcstShot_PRD c
             join @Whse w on w.val = c.Whse
        where c.ItemName in ('MX5W','F6001','R45T')
        order by c.ItemName,c.Whse,c.DownLoadDate
end


declare @MyTable IntTable
insert @MyTable
select 200 union all
select 300 

exec  spMultiValue @Whse = @MyTable


------ Real Example ------- pick up Item level record from Source Table 'FinalFcstShot_PRD' and join Type table 'StrTable'
create type StrTable as Table
(
        valN varchar(15) null
        ,valS varchar (3) null
        ,valW varchar (3) null
      ---  ,valR varchar (20) null
)

drop type StrTable

CREATE PROCEDURE spMultiValue_
(
        @ItemName StrTable readonly

) as begin
        SELECT ItemName,c.State,c.Whse,c.DownLoadDate,c.Value,w.valN
        FROM staging.dbo.FinalFcstShot_PRD c join @ItemName w
             on w.valN = c.ItemName
             and w.valS = c.State
             and w.valW = c.Whse
        where c.ItemName in ('MX5W','F6001','R45T')
        order by c.ItemName,c.Whse,c.DownLoadDate
end


declare @MyTable StrTable
insert @MyTable
select 'MX5W','QLD','400'
union all
select 'F6001','NSW','200'

exec  spMultiValue_ @ItemName = @MyTable


--------------------------------------------------------------------------------------
--- To get list of table type,columns and datatype for a user-defined table type ---

select tt.name AS table_Type
      ,c.name AS table_Type_col_name
      ,st.name AS table_Type_col_datatype
from sys.table_types tt
inner join sys.columns c on c.object_id = tt.type_table_object_id
INNER JOIN sys.systypes AS ST  ON ST.xtype = c.system_type_id

-------------------------------------------------------------------------

IF EXISTS (SELECT * FROM sys.types WHERE is_table_type = 1 AND name = 'StrTable')
 drop type StrTable
SELECT * FROM sys.types WHERE is_table_type = 1 AND name = 'IntTable'



---------------------------------------------------------------------------
--- To get Definition Text of SP --------- 15/12/2014

SELECT definition
FROM sys.sql_modules
WHERE object_id = (OBJECT_ID(N'dbo.spMultiValue_'));



-------------Passing multiple/dynamic values to Stored Procedures & Functions | Part 3 – by using #table 13/12/2017-----------------------------------------
https://sqlwithmanoj.com/2012/09/09/passing-multipledynamic-values-to-stored-procedures-functions-part3-by-using-table/
-- Create Stored Procedure with no parameter, it will use the temp table created outside the SP:
CREATE PROCEDURE uspGetPersonDetailsTmpTbl
AS
BEGIN
     
    SELECT BusinessEntityID, Title, FirstName, MiddleName, LastName, ModifiedDate
    FROM [Person].[Person] PER
    WHERE EXISTS (SELECT Name FROM #tblPersons tmp WHERE tmp.Name  = PER.FirstName)
    ORDER BY FirstName, LastName
 
END
GO
 
-- Now, create a temp table, insert records with same set of values we used in previous 2 posts:
CREATE TABLE #tblPersons (Name NVARCHAR(100))
 
INSERT INTO #tblPersons
SELECT Names FROM (VALUES ('Charles'), ('Jade'), ('Jim'), ('Luke'), ('Ken') ) AS T(Names)
 
-- Now execute the SP, it will use the above records as input and give you required results:
EXEC uspGetPersonDetailsTmpTbl
-- Check the output, objective achieved <img draggable="false" class="emoji" alt="🙂" src="https://s0.wp.com/wp-content/mu-plugins/wpcom-smileys/twemoji/2/svg/1f642.svg">
 
DROP TABLE #tblPersons
GO
 
-- Final Cleanup
DROP PROCEDURE uspGetPersonDetailsTmpTbl
GO


------Passing multiple/dynamic values to Stored Procedures & Functions | Part 4 – by using TVP 14/12/2017 ----------------
https://sqlwithmanoj.com/2012/09/10/passing-multipledynamic-values-to-stored-procedures-functions-part4-by-using-tvp/

--Let’s check how we can make use of this new feature (TVP):
--- First create a User-Defined Table type with a column that will store multiple values as multiple records:
CREATE TYPE dbo.tvpNamesList AS TABLE
(
    Name NVARCHAR(100) NOT NULL,
    PRIMARY KEY (Name)
)
GO
 
-- Create the SP and use the User-Defined Table type created above and declare it as a parameter:
CREATE PROCEDURE uspGetPersonDetailsTVP (
    @tvpNames tvpNamesList READONLY
)
AS
BEGIN
     
    SELECT BusinessEntityID, Title, FirstName, MiddleName, LastName, ModifiedDate
    FROM [Person].[Person] PER
    WHERE EXISTS (SELECT Name FROM @tvpNames tmp WHERE tmp.Name  = PER.FirstName)
    ORDER BY FirstName, LastName
 
END
GO
 
-- Now, create a Table Variable of type created above:
DECLARE @tblPersons AS tvpNamesList
 
INSERT INTO @tblPersons
SELECT Names FROM (VALUES ('Charles'), ('Jade'), ('Jim'), ('Luke'), ('Ken') ) AS T(Names)
 
-- Pass this table variable as parameter to the SP:
EXEC uspGetPersonDetailsTVP @tblPersons
GO
-- Check the output, objective achieved <img draggable="false" class="emoji" alt="🙂" src="https://s0.wp.com/wp-content/mu-plugins/wpcom-smileys/twemoji/2/svg/1f642.svg">
 
 
-- Final Cleanup
DROP PROCEDURE uspGetPersonDetailsTVP
GO



-------------------------------------------------------------------

-------------   Get Log for SP ------------------- 30/10/2017
-- https://dba.stackexchange.com/questions/124763/how-can-i-get-the-whole-execution-log-of-stored-procedure

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
FROM sys.dm_exec_procedure_stats 
ORDER BY AVG_LOGICAL_READS DESC