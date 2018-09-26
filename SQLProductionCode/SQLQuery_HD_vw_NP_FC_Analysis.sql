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

/****** Object:  View [JDE_DB_Alan].[vw_NP_FC_Analysis]    Script Date: 25/09/2018 10:27:39 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER view [JDE_DB_Alan].[vw_NP_FC_Analysis] with schemabinding
as

  --- Syntax '*' is not allowed in schema-bound objects ! ---   So in your final Select you need to pick up All columns --- 12/3/2018
  --- it is OK to list all columns , so when you want to use View table you can select whatever columns you want ---
  --- Need to design a SP to automatically refresh the View every month or any time  your loaded your NP table --- 12/3/2018
 
 --drop view [JDE_DB_Alan].[vw_NP_FC_Analysis]

with _np as 
			( select npfc.ItemNumber,npfc.date,npfc.Value,npfc.DataType,npfc.CN_Number,npfc.Comment,npfc.Creator,npfc.LastUpdated,npfc.ReportDate 
				from JDE_DB_Alan.FCPRO_NP_tmp npfc
				where npfc.Value > 0
				      and npfc.ValidStatus = 'Y'               --- add 31/8/2018
					  )

	,np_ as ( select _np.ItemNumber,_np.Date,_np.Value,_np.DataType,_np.CN_Number,_np.Comment,_np.Creator,_np.LastUpdated,_np.ReportDate
					,min(_np.Date) over(partition by _np.ItemNumber) as FcStartDate
					,max(_np.Date) over(partition by _np.ItemNumber) as FcEndDate					
					,DATEADD(mm, DATEDIFF(m,0,GETDATE()),0) as CurrentMth_
					,sum(_np.value) over (partition by _np.ItemNumber) as FcTTL_12_Qty			--- note this is true 12 FC Qty regardless of when is your current month, FC in 'FCPRO_Fcst' will cut off whatever the month passed by --- 12/3/2018
					,avg(_np.value) over (partition by _np.ItemNumber) as FcTTL_12_Qty_MthlyAvg		--- note when calculating Averge, if there is 0 quantities it will skip and count less to be divided, so maybe it is safe to hard coded to be divided by 12 - just a thought? -- 12/3/2018
					,count(_np.date) over (partition by _np.ItemNumber) as FcMthCount
					,datediff(m,min(_np.Date) over(partition by _np.ItemNumber),DATEADD(mm, DATEDIFF(m,0,GETDATE()),0) ) as Mth_Elapsed
			from _np					 				 
			where 
					--_np.ItemNumber in ('34.513.000 ')	and	 
                     _np.Value >0
			)
                 
		--select * from np_	   
        select np_.ItemNumber,np_.Date,np_.Value,np_.DataType,np_.CN_Number,np_.Comment,np_.Creator,np_.LastUpdated,np_.ReportDate 
					 ,np_.FcStartDate,np_.FcEndDate,np_.CurrentMth_,np_.FcTTL_12_Qty,np_.FcTTL_12_Qty_MthlyAvg,np_.FcMthCount,np_.Mth_Elapsed
				from np_
				--where np_.Mth_Elapsed > 7
				--where np_.ItemNumber in ('7501001000')
				where np_.Mth_Elapsed <=8									-- 25/9/2018
GO


