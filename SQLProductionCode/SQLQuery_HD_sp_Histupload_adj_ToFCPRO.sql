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
/****** Object:  StoredProcedure [JDE_DB_Alan].[sp_FCPRO_SlsHistory_adj]    Script Date: 4/02/2022 10:48:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [JDE_DB_Alan].[sp_FCPRO_SlsHistory_adj]
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

	--- 16/6/2020 ---

	--- This update happens when All Sales history data transformation is done except to 'remove' history noise - the input is manual here, so you review history and put SKU with abnormal demand ( with month in particular ) in an exception tbl, and join original sales data, this is last steop before loading sales data into forecasting system ------  12/6/2020
	--- This process could take 2 stages:
	--- 1) when month begin, overwrite history against SKU which you singled out/isolated last month, and overwrite history you get at beginnig of the month
	--- 2) after output sales history file ( with last month overwrite ) , review and try to find if  you have additional or need to remove any exceptions, then update both history table and exception table 

	--- 3/2/2022
	--- add logic for grouping so that code can pick up all valid records 

		--- update history with sales Adjustment ------

       

	----- First delete any records you put in today --- in case you run multiple time same day to avoid rubbish accumilation 12/6/2020
	--delete from JDE_DB_Alan.SlsHist_Excp_FCPro_upload 
	--where Date_Updated > dateadd(s,-1,dateadd(d, datediff(d,0, getdate()), 0)	)

	-- select * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload a where a.ValidStatus in ('Y')

    ------ Then update -----
	;update s
	set s.SalesQty_Adj = e.Value_Sls_Adj
		,s.ValidStatus = e.ValidStatus	
	from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload s inner join 
			  ( 
				--select * from ( select a.*,dense_rank()over(order by Date_Updated desc ) as rn				         --- use dense_rank, also use date_updated desc to pick up latest records 12/6/2020
	          select * from ( select a.*,dense_rank()over( partition by ItemNumber order by Date_Updated desc ) as rn	 -- need group by ItemNumber otherwise it will have error - 3/02/2022 . Use dense_rank, also use date_updated desc to pick up latest records 12/6/2020
			                         ,cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-37,0),126),'-',''),1,6) as integer) as Date_36m              --- use 36 month as benchmark to determine if you want to include adjustment or not
								from JDE_DB_Alan.SlsHist_Excp_FCPro_upload a 
								
								) b
						where b.rn = 1
						     and Date > Date_36m				--- exclude any sales old than 3 years as there is no need 
						--order by b.Date_Updated,b.ReportDate
			  ) e

			on s.ItemNumber = e.ItemNumber and s.CYM = e.Date
		where  e.ValidStatus = 'Y'
			-- and s.ItemNumber ='26.132.0204'	   set s.SalesQty_Adj = e.Value_Sls_Adj
		


END
