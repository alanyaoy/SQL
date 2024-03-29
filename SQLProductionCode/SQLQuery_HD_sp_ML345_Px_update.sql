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
/****** Object:  StoredProcedure [JDE_DB_Alan].[sp_ML345_upd_Px]    Script Date: 10/01/2018 10:17:59 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [JDE_DB_Alan].[sp_ML345_upd_Px]
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
		update p
		set p.WholeSalePrice= ( case 
										when p.WholeSalePrice >9998 then 1
										when p.WholeSalePrice = 0 or p.WholeSalePrice is null then
											(case 
													when p.StandardCost=0 or p.StandardCost is null then 0.01
													else p.StandardCost 
													end)							 
										else p.WholeSalePrice
										end )
			,p.StandardCost= ( case 
										when p.StandardCost = 0 or p.StandardCost is null then
											(case 
													when p.WholeSalePrice=0 or p.WholeSalePrice is null then 0.01
													else p.WholeSalePrice 
													end)							 
										else p.StandardCost
										end )
			--- remove "/" slash in Description
			,p.Description =( case 
									 when CHARINDEX(',',p.Description) >0 then REPLACE(p.Description,',','/')
										 else p.Description
										 end )
								 										
		from JDE_DB_Alan.Master_ML345 p 


END
