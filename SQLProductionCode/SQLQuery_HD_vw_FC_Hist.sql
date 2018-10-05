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

/****** Object:  View [JDE_DB_Alan].[vw_FC_Hist]    Script Date: 5/10/2018 10:30:07 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



	
	
	
	
	
	
	ALTER view  [JDE_DB_Alan].[vw_FC_Hist] with schemabinding as 
	select f.ItemNumber,f.DataType1
			,f.Date
			,convert(varchar(7),f.Date,120) as myDate1		
			,cast(SUBSTRING(REPLACE(CONVERT(char(10),f.Date,126),'-',''),1,6) as integer) as [myDate2]		
			,datepart(year,f.date) fcyr
			,datepart(month,f.date) fcmth,DATEPART(day,f.date) fcdte				
			,f.Value as FC_Vol
			,f.ReportDate
			,convert(varchar(7),f.ReportDate,120) as myReportDate1
			,cast(SUBSTRING(REPLACE(CONVERT(char(10),f.ReportDate,126),'-',''),1,6) as integer) as [myReportDate2]	
			,convert(varchar(10),f.ReportDate,120) as myReportDate3
			,cast(SUBSTRING(REPLACE(CONVERT(char(10),f.ReportDate,126),'-',''),1,8) as integer) as [myReportDate4]
		from JDE_DB_Alan.FCPRO_Fcst_History f 
		where f.DataType1 in ('Adj_FC')
		     -- and f.ItemNumber in ('42.210.031')
GO


