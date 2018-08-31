/*    ==Scripting Parameters==

    Source Server Version : SQL Server 2016 (13.0.4001)
    Source Database Engine Edition : Microsoft SQL Server Express Edition
    Source Database Engine Type : Standalone SQL Server

    Target Server Version : SQL Server 2016
    Target Database Engine Edition : Microsoft SQL Server Express Edition
    Target Database Engine Type : Standalone SQL Server
*/

USE [JDE_DB_Alan]
GO

/****** Object:  StoredProcedure [JDE_DB_Alan].[sp_FCPro_upd_Fcst_Hist]    Script Date: 12/03/2018 10:53:43 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE  [JDE_DB_Alan].[sp_Refresh_View_NP_Analysis]  
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

	select * from JDE_DB_Alan.vw_NP_FC_Analysis

 END
GO


