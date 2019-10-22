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

/****** Object:  StoredProcedure [JDE_DB_Alan].[sp_Exp_Test_SO_mast]    Script Date: 3/10/2019 4:40:24 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO







-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE  [JDE_DB_Alan].[sp_Exp_SO_Inquiry_mast]  
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

	;with tb as
	   ( select s.Order_Number,s.Order_Type,s.Sold_To,s.Sold_To_Name,s.second_Item_Number as ItemNumber,s.Description_1,s.Quantity,s.UOM,s.Secondary_Quantity,s.Secondary_UOM
				,s.Requested_Date
				,cast(SUBSTRING(REPLACE(CONVERT(char(10),s.Requested_Date,126),'-',''),1,6) as integer) as [Date_Req]		
				,datepart(year,s.Requested_Date)  Yr_Req,datepart(month,s.Requested_Date) Mth_Req,DATEPART(day,s.Requested_Date) Dte_Req
				,s.Ship_To,s.Ship_To_Description
				,s.Third_Item_Number,s.Parent_Number,s.Pick_Number,s.Unit_Price,s.Extended_Amount,s.Pricing_UOM
				,s.Order_Date,s.Short_Item_No,s.Document_Number,s.Doument_Type,s.Actual_Ship_Date
				,s.Invoice_Date
				,cast(SUBSTRING(REPLACE(CONVERT(char(10),s.Invoice_Date,126),'-',''),1,6) as integer) as [Date_Inv]		
				,datepart(year,s.Invoice_Date)  Yr_Inv,datepart(month,s.Invoice_Date) Mth_Inv,DATEPART(day,s.Invoice_Date) Dte_Inv
				,s.GL_Date,s.Promised_Delivery_Date,s.Business_Unit
				,s.Line_Type,s.Sls_Cd1,s.Sls_Cd2,s.Sls_Cd3,s.Sls_Cd4,s.Quantity_Ordered,s.Quantity_Shipped,s.Quantity_Backordered,s.Quantity_Canceled,s.Price_Effective_Date
				,s.Unit_Cost,s.Transaction_Originator
				,s.ReportDate
				--,cast(SUBSTRING(REPLACE(CONVERT(char(10),s.ReportDate,126),'-',''),1,8) as integer) as [Date_Report]

		 from JDE_DB_Alan.SO_Inquiry s

		 )	 
            

		select * from tb

 END
GO


