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
/****** Object:  StoredProcedure [JDE_DB_Alan].[sp_Z_FC_Hist_Summary]    Script Date: 16/11/2018 2:29:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE  [JDE_DB_Alan].[sp_Z_FC_Hist_Summary]  
	-- Add the parameters for the stored procedure here
	--<@Param1, sysname, @p1> <Datatype_For_Param1, , int> = <Default_Value_For_Param1, , 0>, 
	--<@Param2, sysname, @p2> <Datatype_For_Param2, , int> = <Default_Value_For_Param2, , 0>

	-- This Store Procedure Refresh vw_NP_FC_Analysis  --- 12/3/2018 
	--- Is this Robust way to refresh View in SQL Server ? --- At least you need to implement Schemabinding in View !
AS

 BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	--SELECT <@Param1, sysname, @p1>, <@Param2, sysname, @p2>

	--select  cast(DATEADD(mm, DATEDIFF(mm, 0, GETDATE())-1, 0) as datetime)				--- Last Month


	  --- a Nice Table show all Records and Break down on each Upload date For Monthly Cycle------ 7/12/2017
	  -- can use OLAP sum or Running Total Function to get your result ---
	  --use JDE_DB_Alan
	  --go

	  -- Revised on 16/11/2018 to include aggregated Forecast Quantities & Values
	  with cte as 
		  (
			  select convert(varchar(13),fh.ReportDate,120) as Date_Uploaded
						,count(*)  as Records_Uploaded
						,sum(fh.FC_Vol) as FC_Qty 
						,sum(fh.FC_Vol*m.WholeSalePrice) as FC_Val
			  from JDE_DB_Alan.vw_FC_Hist fh
			           left join JDE_DB_Alan.vw_Mast m on fh.ItemNumber = m.ItemNumber
			  --from JDE_DB_Alan.FCPRO_Fcst_History fh
			  --  where fh.ItemNumber in ('42.210.031') and fh.myReportDate4 = 20181115
			  group by  convert(varchar(13),fh.ReportDate,120) 
			 -- order by Date_Uploaded       
			   )
  
	  select *
			, sum(cte.Records_Uploaded) over (order by Date_Uploaded) TTL_Records_HistTbl 	        
	  from cte 
	  --where cte.Date_Uploaded > '2018-11-06' and cte.Date_Uploaded < '2018-11-26 14:59:00'
	  order by cte.Date_Uploaded asc
	  


 END
