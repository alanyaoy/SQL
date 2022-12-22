/*    ==Scripting Parameters==

    Source Server Version : SQL Server 2016 (13.0.4259)
    Source Database Engine Edition : Microsoft SQL Server Express Edition
    Source Database Engine Type : Standalone SQL Server

    Target Server Version : SQL Server 2016
    Target Database Engine Edition : Microsoft SQL Server Express Edition
    Target Database Engine Type : Standalone SQL Server
*/

USE [JDE_DB_Alan]
GO

/****** Object:  View [JDE_DB_Alan].[vw_OpenPO]    Script Date: 8/08/2022 1:23:55 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




--- 8/8/2022 ---
--- Adjust code, if Jde report has no 'Promised Delivery date' ( 'Due Date') then use 'Order Date' + Lead Time in days to make assumption for delivery date -- is it fair ?

ALTER view [JDE_DB_Alan].[vw_OpenPO] with schemabinding as
   
   select p.ItemNumber,'WIP' as DataType1,OrderNumber,QuantityOrdered as PO_Volume,QuantityReceived,QuantityOpen
		  ,OrderDate,ExSupplierShipDate,DueDate
		  ,case when p.DueDate is not null then convert(varchar(7),p.DueDate,120)
		        when p.DueDate is null then  convert(varchar(7),dateadd(d,convert(int,a.LeadtimeLevel),datediff(d,0,p.OrderDate)),120)		
				end  as PODate_
          ,case when p.DueDate is not null then datepart(year,p.DueDate)
		        when p.DueDate is null then  datepart(year,convert(varchar(10),dateadd(d,convert(int,a.LeadtimeLevel),datediff(d,0,p.OrderDate)),120)	)	
				end  as poyr
           ,case when p.DueDate is not null then datepart(month,p.DueDate)
		        when p.DueDate is null then  datepart(month,convert(varchar(10),dateadd(d,convert(int,a.LeadtimeLevel),datediff(d,0,p.OrderDate)),120)	)	
				end  as pomth
           ,case when p.DueDate is not null then datepart(day,p.DueDate)
		        when p.DueDate is null then  datepart(day,convert(varchar(10),dateadd(d,convert(int,a.LeadtimeLevel),datediff(d,0,p.OrderDate)),120)	)	
				end  as podte
		  
		  --,convert(varchar(7),p.DueDate,120) as PODate_,datepart(year,p.DueDate) poyr,datepart(month,p.DueDate ) pomth,datepart(day,p.DueDate ) pomdte
		  ,InTransitDays,BuyerNumber,BuyerName,TransactionOriginator,TransactionOrigName,SupplierNumber,p.SupplierName,ShipmentNumber,ShpSts,ShipStatus,Reportdate,OpenPOID           
   --from JDE_DB_Alan.OpenPO p
   from JDE_DB_Alan.OpenPO p left join JDE_DB_Alan.vw_Mast a on p.ItemNumber = a.ItemNumber
   where  --p.DueDate < DATEADD(mm, DATEDIFF(m,0,GETDATE())+11,0)
         ( p.DueDate is null or  p.DueDate < DATEADD(mm, DATEDIFF(m,0,GETDATE())+11,0) ) 
		-- and p.ItemNumber in ('24.7127.0155')
GO


