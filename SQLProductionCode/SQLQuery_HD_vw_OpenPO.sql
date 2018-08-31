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

/****** Object:  View [JDE_DB_Alan].[vw_OpenPO]    Script Date: 23/05/2018 11:05:34 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


--- 23/5/2018 ---
ALTER view [JDE_DB_Alan].[vw_OpenPO] with schemabinding as
   
   select ItemNumber,'WIP' as DataType1,OrderNumber,QuantityOrdered as PO_Volume,QuantityReceived,QuantityOpen
		  ,OrderDate,ExSupplierShipDate,DueDate,convert(varchar(7),p.DueDate,120) as PODate_,datepart(year,p.DueDate) poyr,datepart(month,p.DueDate ) pomth,datepart(day,p.DueDate ) pomdte
		  ,InTransitDays,BuyerNumber,BuyerName,TransactionOriginator,TransactionOrigName,SupplierNumber,SupplierName,ShipmentNumber,ShpSts,ShipStatus,Reportdate,OpenPOID           
   from JDE_DB_Alan.OpenPO p
   where  p.DueDate < DATEADD(mm, DATEDIFF(m,0,GETDATE())+5,0)
GO


