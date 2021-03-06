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
/****** Object:  StoredProcedure [JDE_DB_Alan].[sp_Exp_Test_WO_mast]    Script Date: 24/10/2018 12:15:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE  [JDE_DB_Alan].[sp_Exp_Test_WO_mast]  
	-- Add the parameters for the stored procedure here
	--<@Param1, sysname, @p1> <Datatype_For_Param1, , int> = <Default_Value_For_Param1, , 0>, 
	--<@Param2, sysname, @p2> <Datatype_For_Param2, , int> = <Default_Value_For_Param2, , 0>

	-- This Store Procedure Refresh vw_NP_FC_Analysis  --- 12/3/2018 
	--- Is this Robust way to refresh View in SQL Server ? --- At least you need to implement Schemabinding in View  !
AS

 BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	--SELECT <@Param1, sysname, @p1>, <@Param2, sysname, @p2>

	--select  cast(DATEADD(mm, DATEDIFF(mm, 0, GETDATE())-1, 0) as datetime)				--- Last Month

	--- export Test order details in conjunction with Test CO, also include Master data info

	;with tb as
	   ( select w.ItemNumber,w.OrderQuantity,w.UM,w.WONumber,c.OrderNumber as CO,c.CustomerName
				,c.ItemNumber as FinItemNumber,c.ItemDescription as FinItemDesp,c.SlsCd2,SlsCd3,c.CO_Name as Proj_Name,c.StateCode2
				,c.OrderTakenBy as Comments,w.Reportdate
			from JDE_DB_Alan.TestWO w left join JDE_DB_Alan.TestCO c 
				   on w.WONumber = c.RelatedWONum

		 )
	   ,tbl as ( select tb.ItemNumber,tb.OrderQuantity,tb.UM,tb.CO,tb.WONumber,tb.CustomerName
						,tb.FinItemNumber,tb.FinItemDesp,tb.SlsCd2,tb.SlsCd3,tb.Proj_Name,tb.StateCode2						
						,m.StockingType,m.WholeSalePrice
						--,tb.OrderQuantity*m.WholeSalePrice as Amt
						,m.Description
						,tb.Comments
						,tb.Reportdate
					from tb left join JDE_DB_Alan.vw_Mast m
							on tb.ItemNumber = m.ItemNumber
							)
            

		select * from tbl
		order by tbl.Reportdate,tbl.WONumber,tbl.ItemNumber



 END
