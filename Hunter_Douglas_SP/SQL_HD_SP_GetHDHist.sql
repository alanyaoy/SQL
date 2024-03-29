/*    ==Scripting Parameters==

    Source Server Version : SQL Server 2016 (13.0.4001)
    Source Database Engine Edition : Microsoft SQL Server Express Edition
    Source Database Engine Type : Standalone SQL Server

    Target Server Version : SQL Server 2017
    Target Database Engine Edition : Microsoft SQL Server Standard Edition
    Target Database Engine Type : Standalone SQL Server
*/

USE [JDE_DB_Alan]
GO
/****** Object:  StoredProcedure [JDE_DB_Alan].[sp_GetMyHDHist]    Script Date: 19/10/2017 3:56:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [JDE_DB_Alan].[sp_GetMyHDHist]
    --@PropertyValueID int,
    --@Value varchar(max) = NULL,
    --@UnitValue float = NULL,
    --@UnitOfMeasureID int = NULL,
    --@DropDownOptionID int = NULL
	@ItemNumber varchar(100) = null,
	@ShortItemNum varchar(100) = null,
	@CenturyYearMonth int = null
AS
BEGIN   
    -- If the Property has a @Value, Update it.
    IF @ShortItemNum IS NULL
    BEGIN
	      with cte as (
			 select a.*
 				,case  
					when a.FinancialMonth  >= 10  then concat(a.Century,a.FinancialYear,format(a.FinancialMonth,'0')) 		
					when a.FinancialMonth  <10  then concat(a.Century,a.FinancialYear,format(a.FinancialMonth,'00')) 
					end as CYM

			 from  JDE_DB_Alan.SalesHistoryHDAWF a   )
		select * from cte
		--where cte.ItemNumber in ('18.615.024') and cte.CYM in ('201508')
		  where (cte.ItemNumber LIKE '%' + ISNULL(@ItemNumber,ItemNumber) + '%' )	and cte.CYM = @CenturyYearMonth
    END
    -- Else check if it has a @ItemNumber
    ELSE IF @ItemNumber IS NULL 
    BEGIN

		   with cte as (
			 select a.*
 				,case  
					when a.FinancialMonth  >= 10  then concat(a.Century,a.FinancialYear,format(a.FinancialMonth,'0')) 		
					when a.FinancialMonth  <10  then concat(a.Century,a.FinancialYear,format(a.FinancialMonth,'00')) 
					end as CYM

			 from  JDE_DB_Alan.SalesHistoryHDAWF a   )
		select * from cte
		--where cte.ItemNumber in ('18.615.024') and cte.CYM in ('201508')
		  where (cte.ShortItemNum LIKE '%' + ISNULL(@ShortItemNum,ShortItemNum) + '%') and cte.CYM =	@CenturyYearMonth	       
    END
    
END



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