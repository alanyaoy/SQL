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
/****** Object:  StoredProcedure [JDE_DB_Alan].[sp_Exp_SO_Inquiry_Super_Mast]    Script Date: 17/10/2019 3:31:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE  [JDE_DB_Alan].[sp_Exp_SO_Inquiry_Super_Mast]  
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

	--- export Test order details in conjunction with Test CO, also include Master data info

		--;with tb as
		--	( select s.Order_Number,s.Ship_To_Number,s.Address_Number,s.Item_Number,m.Description,m.StockingType,s.Or_Ty,s.Business_Unit
		--			,s.UM_UM,s.PR_UM,s.Qty_Ordered,s.Qty_Ordered_LowestLvl
		--			,s.Unit_Cost,s.Unit_Price,s.Extended_Cost,s.Extended_Price,s.Primary_Supplier,s.Buyer_Number,s.Reference
				
		--			,m.FamilyGroup
		--			,m.Family
		--			,m.FamilyGroup_
		--			,m.Family_0
		--			,s.LastStatus
		--			,s.NextStatus

		--			,s.Transaction_Originator,s.Unit_List_Price
		--			,s.Request_Date
		--			,cast(SUBSTRING(REPLACE(CONVERT(char(10),s.Request_Date,126),'-',''),1,6) as integer) as [Date_Req]		
		--			,datepart(year,s.Request_Date)  Yr_Req,datepart(month,s.Request_Date) Mth_Req,DATEPART(day,s.Request_Date) Dte_Req
		--			,s.Invoice_Date
		--			,cast(SUBSTRING(REPLACE(CONVERT(char(10),s.Invoice_Date,126),'-',''),1,6) as integer) as [Date_Inv]		
		--			,datepart(year,s.Invoice_Date)  Yr_Inv,datepart(month,s.Invoice_Date) Mth_Inv,DATEPART(day,s.Invoice_Date) Dte_Inv
		--			,s.Order_Date
		--			,cast(SUBSTRING(REPLACE(CONVERT(char(10),s.Order_Date,126),'-',''),1,6) as integer) as [Date_Ord]		
		--			,datepart(year,s.Order_Date)  Yr_Ord,datepart(month,s.Order_Date) Mth_Ord,DATEPART(day,s.Order_Date) Dte_Ord

		--			,s.ReportDate
				
		--			,cast(SUBSTRING(REPLACE(CONVERT(char(10),s.ReportDate,126),'-',''),1,8) as integer) as [Date_Report]

		--		from JDE_DB_Alan.SO_Inquiry_Super s left join JDE_DB_Alan.vw_Mast m on s.Item_Number = m.ItemNumber
		--		where s.Item_Number in ('82336.2800.00.01')
			     

		--		)	             

		--	select * from tb

		select * from JDE_DB_Alan.vw_SO_Inquiry_Super

 END
