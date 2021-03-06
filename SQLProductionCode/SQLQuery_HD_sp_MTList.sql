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
/****** Object:  StoredProcedure [JDE_DB_Alan].[sp_GetMTquery]    Script Date: 31/10/2017 11:59:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [JDE_DB_Alan].[sp_GetMTquery]
    --@PropertyValueID int,
    --@Value varchar(max) = NULL,
    --@UnitValue float = NULL,
    --@UnitOfMeasureID int = NULL,
    --@DropDownOptionID int = NULL
	@ItemNumber varchar(100) = null,
	@ShortItemNumber varchar(100) = null,
	@CenturyYearMonth int = null
AS
BEGIN   
    -- If the Property has a @Value, Update it.
	
	
	IF @ShortItemNumber IS NULL and @CenturyYearMonth is null
    BEGIN
	      with cte as (
			 select a.*
 				,case  
					when a.FinancialMonth  >= 10  then concat(a.Century,a.FinancialYear,format(a.FinancialMonth,'0')) 		
					when a.FinancialMonth  <10  then concat(a.Century,a.FinancialYear,format(a.FinancialMonth,'00')) 
					end as CYM

			 from  JDE_DB_Alan.SalesHistoryMT a   )
		select * from cte
		--where cte.ItemNumber in ('18.615.024') and cte.CYM in ('201508')
		  where (cte.ItemNumber LIKE '%' + ISNULL(@ItemNumber,ItemNumber) + '%' )	
    END

	-- Check if you want to use ItemNumber to query the data 
    ELSE IF @ShortItemNumber IS NULL
    BEGIN
	      with cte as (
			 select a.*
 				,case  
					when a.FinancialMonth  >= 10  then concat(a.Century,a.FinancialYear,format(a.FinancialMonth,'0')) 		
					when a.FinancialMonth  <10  then concat(a.Century,a.FinancialYear,format(a.FinancialMonth,'00')) 
					end as CYM

			 from  JDE_DB_Alan.SalesHistoryMT a   )
		select * from cte
		--where cte.ItemNumber in ('18.615.024') and cte.CYM in ('201508')
		  where (cte.ItemNumber LIKE '%' + ISNULL(@ItemNumber,ItemNumber) + '%' )	and cte.CYM = @CenturyYearMonth
    END
    -- Else check if it has a @ItemNumber
	-- Check if you want to use ShortItemNumber to query the data 

    ELSE IF @ItemNumber IS NULL 
    BEGIN

		   with cte as (
			 select a.*
 				,case  
					when a.FinancialMonth  >= 10  then concat(a.Century,a.FinancialYear,format(a.FinancialMonth,'0')) 		
					when a.FinancialMonth  <10  then concat(a.Century,a.FinancialYear,format(a.FinancialMonth,'00')) 
					end as CYM

			 from  JDE_DB_Alan.SalesHistoryMT a   )
		select * from cte
		--where cte.ItemNumber in ('18.615.024') and cte.CYM in ('201508')
		  where (cte.ShortItemNumber LIKE '%' + ISNULL(@ShortItemNumber,ShortItemNumber) + '%') and cte.CYM =	@CenturyYearMonth	       
    END
    
END