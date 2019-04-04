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

/****** Object:  View [JDE_DB_Alan].[vw_FC_Hist]    Script Date: 27/03/2019 12:15:01 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

	
	
 CREATE view  [JDE_DB_Alan].[vw_SO] with schemabinding as 
	
	       select s.Order_Number,s.Order_Type,s.Sold_To,s.Sold_To_Name,s.second_Item_Number as ItemNumber,s.Description_1,s.Quantity,s.UOM,s.Secondary_Quantity,s.Secondary_UOM
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

		 from JDE_DB_Alan.TestSO s
GO


