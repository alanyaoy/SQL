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

/****** Object:  View [JDE_DB_Alan].[vw_SO_Inquiry_Super]    Script Date: 21/10/2019 2:51:40 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



---------------- Created 17/10/2019 ------------------

ALTER view  [JDE_DB_Alan].[vw_SO_Inquiry_Super] with schemabinding as 

with tb as
	   ( select s.Order_Number,s.Ship_To_Number,s.Address_Number,s.Item_Number,m.Description,m.StockingType,s.Or_Ty,s.Business_Unit
				,s.UM_UM,s.PR_UM,s.Qty_Ordered,s.Qty_Ordered_LowestLvl
	            ,s.Unit_Cost,s.Unit_Price,s.Extended_Cost,s.Extended_Price,s.Primary_Supplier,s.Buyer_Number,s.Reference
				
				,m.FamilyGroup
				,m.Family
				--,m.FamilyGroup_
				--,m.Family_0
				,s.LastStatus
				,s.NextStatus

				,s.Transaction_Originator,s.Unit_List_Price
               	,s.Order_Date				
				,convert(varchar(7),s.Order_Date,120) as YM_Ord_c	
				--,SUBSTRING(CONVERT(char(10),s.Order_Date,126),1,7) as YM_Ord_c
				,cast(SUBSTRING(REPLACE(CONVERT(char(10),s.Order_Date,126),'-',''),1,6) as integer) as YM_Ord				
				,datepart(year,s.Order_Date)  Yr_Ord,datepart(month,s.Order_Date) Mth_Ord,DATEPART(day,s.Order_Date) Dte_Ord
				,s.Request_Date
				,convert(varchar(7),s.Request_Date,120) as YM_Req_c	
				,cast(SUBSTRING(REPLACE(CONVERT(char(10),s.Request_Date,126),'-',''),1,6) as integer) as YM_Req		
				,datepart(year,s.Request_Date)  Yr_Req,datepart(month,s.Request_Date) Mth_Req,DATEPART(day,s.Request_Date) Dte_Req
		        ,s.Invoice_Date
				,convert(varchar(7),s.Invoice_Date,120) as YM_Inv_c	
				,cast(SUBSTRING(REPLACE(CONVERT(char(10),s.Invoice_Date,126),'-',''),1,6) as integer) as YM_Inv	
				,datepart(year,s.Invoice_Date)  Yr_Inv,datepart(month,s.Invoice_Date) Mth_Inv,DATEPART(day,s.Invoice_Date) Dte_Inv

				,s.ReportDate
				
				--,cast(SUBSTRING(REPLACE(CONVERT(char(10),s.ReportDate,126),'-',''),1,8) as integer) as [Date_Report]

			from JDE_DB_Alan.SO_Inquiry_Super s left join JDE_DB_Alan.vw_Mast m on s.Item_Number = m.ItemNumber
			--where s.Item_Number in ('82336.2800.00.01')
			--where s.Qty_Ordered_LowestLvl is null											-- 99.999.999/42.062.000,43.295.537
			where s.Qty_Ordered_LowestLvl is not null

		 )
		 --select * from tb

		select t.Order_Number,t.Ship_To_Number,t.Address_Number,t.Item_Number,t.Description,t.StockingType,t.Or_Ty,t.Business_Unit
				,t.UM_UM,t.PR_UM,t.Qty_Ordered,t.Qty_Ordered_LowestLvl
				,t.Unit_Cost,t.Unit_Price,t.Extended_Cost,t.Extended_Price,t.Primary_Supplier,t.Buyer_Number,t.Reference
				,t.FamilyGroup,t.Family
				,t.LastStatus,t.NextStatus
				,t.Transaction_Originator,t.Unit_List_Price
				,t.Order_Date,t.Yr_Ord,t.YM_Ord,t.YM_Ord_c
				,t.Request_Date,Yr_Req,YM_Req,t.YM_Req_c
				,t.Invoice_Date,t.Yr_Inv,t.YM_Inv,YM_Inv_c			
				,t.ReportDate

		 from tb as t


GO


