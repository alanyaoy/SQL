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

/****** Object:  View [JDE_DB_Alan].[vw_FC]    Script Date: 23/05/2018 11:06:25 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--- 23/5/2018 ---
	ALTER view  [JDE_DB_Alan].[vw_FC] with schemabinding as 
	select f.ItemNumber,f.DataType1,f.Date,convert(varchar(7),f.Date,120) as FCDate_,datepart(year,f.date) fcyr,datepart(month,f.date) fcmth,DATEPART(day,f.date) fcdte				
			,f.Value as FC_Vol,f.ReportDate
		from JDE_DB_Alan.FCPRO_Fcst f 
		where f.DataType1 in ('Adj_FC')
GO


