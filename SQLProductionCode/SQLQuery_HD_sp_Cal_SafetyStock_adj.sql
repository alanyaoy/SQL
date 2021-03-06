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
/****** Object:  StoredProcedure [JDE_DB_Alan].[sp_Cal_SafetyStock_Adj]    Script Date: 9/03/2021 12:46:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [JDE_DB_Alan].[sp_Cal_SafetyStock_Adj]
	-- Add the parameters for the stored procedure here
	--<@Param1, sysname, @p1> <Datatype_For_Param1, , int> = <Default_Value_For_Param1, , 0>, 
	--<@Param2, sysname, @p2> <Datatype_For_Param2, , int> = <Default_Value_For_Param2, , 0>
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	--SELECT <@Param1, sysname, @p1>, <@Param2, sysname, @p2>

	----- Need to run this SS Adjustment fter run SS calculation ---- 


	-- 8/10/2020 ---
	-- consideratoin need to make:
	-- 1. how long will be exception last, will you design a mechanism to remove the manual change ? add another field as duration of period ? - OK , rank by updated will take care of it
	-- 2. what about every time you add a mamual override of SS, will you copy all previous valid reconds so 'dense mark' will work properly? what if in new month you make a override and code will pick up change made last period anyway --- OK , rank by 'updated date ' will look after it


		--- 16/6/2020 ---
	--- This update happens when All Sales history data transformation is done except to 'remove' history noise - the input is manual here, so you review history and put SKU with abnormal demand ( with month in particular ) in an exception tbl, and join original sales data, this is last steop before loading sales data into forecasting system ------  12/6/2020
	--- This process could take 2 stages:
	--- 1) when month begin, overwrite history against SKU which you singled out/isolated last month, and overwrite history you get at beginnig of the month
	--- 2) after output sales history file ( with last month overwrite ) , review and try to find if  you have additional or need to remove any exceptions, then update both history table and exception table 



		--- update history with sales Adjustment ------

       

	----- First delete any records you put in today --- in case you run multiple time same day to avoid rubbish accumilation 12/6/2020
	--delete from JDE_DB_Alan.SlsHist_Excp_FCPro_upload 
		--where Date_Updated > dateadd(s,-1,dateadd(d, datediff(d,0, getdate()), 0)	)

   -- select * from JDE_DB_Alan.FCPRO_SafetyStock s where s.ValidStatus in ('Y')

    ------ Then update -----


	   ------ Update only latest records, not all historical items ------ 9/3/2021

	  ; with _s as 
	             
				 ( select a.ItemNumber,a.SS_,a.SS_Adj,a.ValidStatus_Adj_Flag
				       --  ,max(a.ReportDate) over(partition by a.itemNumber) as SS_Latest_upd_date	
						--,min(a.ReportDate) over(partition by a.itemNumber) as SS_Oldest_upd_date
						--,rank() over ( partition by a.itemNumber order by a.reportdate Desc) rk_0
						--,rank() over ( partition by a.itemNumber order by a.reportdate desc) rk_1
						,rk_num_dense = dense_rank() over ( partition by a.itemNumber order by a.reportdate desc )
					  from JDE_DB_Alan.FCPRO_SafetyStock a
					  --where a.ReportDate = max(a.ReportDate)
					  --group by a.ItemNumber,a.SS_,a.SS_Adj			
					)

              ,s as ( select * from _s a where a.rk_num_dense = 1)

	update s
	set s.SS_Adj = e.SS_New
		,s.ValidStatus_Adj_Flag = e.ValidStatus
	--select * 
	from  s inner join 
			  ( 
				select * from ( select a.*,dense_rank()over(order by Date_Updated desc ) as rn				--- use dense_rank, also use date_updated desc to pick up latest records 12/6/2020
								from JDE_DB_Alan.FCPRO_SafetyStock_Excp a ) b
						where b.rn = 1 
						--order by b.Date_Updated,b.ReportDate
			  ) e

			on s.ItemNumber = e.ItemNumber --and s.CYM = e.Date
		where  e.ValidStatus = 'Y'
			-- and s.ItemNumber ='26.132.0204'	   set s.SalesQty_Adj = e.Value_Sls_Adj
		


END
