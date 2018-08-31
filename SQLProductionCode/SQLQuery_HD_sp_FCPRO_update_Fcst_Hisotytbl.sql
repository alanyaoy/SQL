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
/****** Object:  StoredProcedure [JDE_DB_Alan].[sp_FCPro_upd_Fcst_Hist]    Script Date: 25/05/2018 12:13:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE  [JDE_DB_Alan].[sp_FCPro_upd_Fcst_Hist]  
	-- Add the parameters for the stored procedure here
	--<@Param1, sysname, @p1> <Datatype_For_Param1, , int> = <Default_Value_For_Param1, , 0>, 
	--<@Param2, sysname, @p2> <Datatype_For_Param2, , int> = <Default_Value_For_Param2, , 0>

	-- This Store Procedure is to Append FC Table each month So that You will have FC History --- 7/12/2017
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	--SELECT <@Param1, sysname, @p1>, <@Param2, sysname, @p2>

	--select  cast(DATEADD(mm, DATEDIFF(mm, 0, GETDATE())-1, 0) as datetime)				--- Last Month
	insert into JDE_DB_Alan.FCPRO_Fcst_History select * from JDE_DB_Alan.FCPRO_Fcst f 
			where f.Date > cast(DATEADD(mm, DATEDIFF(mm, 0, GETDATE()), 0) as datetime)			-- this picks up 23 month data, Pick up the forecast exclude current month,always from next month for KPI measurements 13/12/2017
			      --f.Date > cast(DATEADD(mm, DATEDIFF(mm, 0, GETDATE())-1, 0) as datetime)             -- Maybe need to pick up current month FC - this will pick up 24 month data ? -- 25/5/2018 --- but Just need to remember if you do analysis, you need to be careful to pick data - maybe there could be a need to exclude current month data ? Because normally you do not want to change fc in current month you are in.
				 -- and f.ItemNumber in ('27.176.320')                                          
				 -- and f.DataType1 in ('Ajd_FC')     -- wrong spelling no data will be loaded   1/3/2018
				    and f.DataType1 in ('Adj_FC') 

END
