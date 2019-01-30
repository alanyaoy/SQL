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

/****** Object:  View [JDE_DB_Alan].[vw_FC_Hist]    Script Date: 29/01/2019 3:01:43 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


	
	
	
	CREATE view  [JDE_DB_Alan].[vw_Hist_RM] with schemabinding as 
	
	with _tb as 
	(select  h.BU,h.ShortItemNumber,h.ItemNumber,h.Hierarchy,h.GLCategory,h.SalesChannel,h.DocumentType,h.UOM
			,h.Quantity,h.Quantity *(-1) as fQty
			,h.Century,h.FinancialYear,h.FinancialMonth
			,cast(h.Century as varchar(10))+ cast(h.FinancialYear as varchar(10)) as CY					
					,case  
						 when h.FinancialMonth  >= 10  then format(h.FinancialMonth,'0') 
						 --else right('000'+cast(a.financialMonth as varchar(2)),3)  
						 when h.FinancialMonth  <10  then format(h.FinancialMonth,'00') 
					end as MM
		
		from JDE_DB_Alan.SlsHistoryRM h
		)

	 ,tb_ as ( select t.bu,t.ShortItemNumber,t.ItemNumber,t.Hierarchy,t.GLCategory,t.SalesChannel,t.DocumentType,t.UOM
	                ,t.fQty
					,t.Century,t.FinancialYear,t.FinancialMonth
					,cast(concat(t.CY,t.MM) as integer) as CYM
					,cast(concat(t.CY,t.MM,'01') as integer ) as CYMD
					,CONVERT(datetime,concat(t.CY,t.MM,'01'),112) as Date
				from  _tb as t )

		select  t.bu,t.ShortItemNumber,t.ItemNumber,t.Hierarchy,t.GLCategory,t.SalesChannel,t.DocumentType,t.UOM
	                ,t.fQty
					,t.Century,t.FinancialYear,t.FinancialMonth
					,t.CYM,t.CYMD,t.Date
		 from tb_ as t
		--where t.ItemNumber in ('09.400.907')
GO


