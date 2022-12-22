
create view [JDE_DB_Alan].[vw_NP_FC_Analysis] with schemabinding
as

  --- Syntax '*' is not allowed in schema-bound objects ! ---   So in your final Select you need to pick up All columns --- 12/3/2018
  --- it is OK to list all columns , so when you want to use View table you can select whatever columns you want ---
  --- Need to design a SP to automatically refresh the View every month or any time  your loaded your NP table --- 12/3/2018
 
 --drop view [JDE_DB_Alan].[vw_NP_FC_Analysis]

with _np as 
			( select npfc.ItemNumber,npfc.date,npfc.Value,npfc.DataType,npfc.CN_Number,npfc.Comment,npfc.Creator,npfc.LastUpdated,npfc.ReportDate 
				from JDE_DB_Alan.FCPRO_NP_tmp npfc left join JDE_DB_Alan.vw_Mast m on npfc.ItemNumber = m.ItemNumber
				where npfc.Value > 0
				      and npfc.ValidStatus = 'Y'               --- add 31/8/2018
					  --and m.StockingType not in ('O','U','Q','M')
					   and m.StockingType not in ('O','U')				--- need to include MTO type   --- 13/9/2019

					  )

	,np_ as ( select _np.ItemNumber,_np.Date,_np.Value,_np.DataType,_np.CN_Number,_np.Comment,_np.Creator,_np.LastUpdated,_np.ReportDate
					,min(_np.Date) over(partition by _np.ItemNumber) as BirthDate		---FcStartDate
					,max(_np.Date) over(partition by _np.ItemNumber) as MatureDate		---FcEndDate					
					,DATEADD(mm, DATEDIFF(m,0,GETDATE()),0) as CurrentMth_
					,sum(_np.value) over (partition by _np.ItemNumber) as FcTTL_12_Qty			--- note this is true 12 FC Qty regardless of when is your current month, FC in 'FCPRO_Fcst' will cut off whatever the month passed by --- 12/3/2018
					,avg(_np.value) over (partition by _np.ItemNumber) as FcTTL_12_Qty_MthlyAvg		--- note when calculating Averge, if there is 0 quantities it will skip and count less to be divided, so maybe it is safe to hard coded to be divided by 12 - just a thought? -- 12/3/2018
					,count(_np.date) over (partition by _np.ItemNumber) as FcMthCount
					,datediff(m,min(_np.Date) over(partition by _np.ItemNumber),DATEADD(mm, DATEDIFF(m,0,GETDATE()),0) ) as Mth_Birth_Elapsed
			from _np					 				 
			where 
					--_np.ItemNumber in ('34.513.000 ')	and	 
                     _np.Value >0									-- pick up all value great than 0 and use this also to determine Birth and Mature date !!
			)
                 
		--select * from np_	   
        ,tb as ( select np_.ItemNumber,np_.Date,np_.Value,np_.DataType,np_.CN_Number,np_.Comment,np_.Creator,np_.LastUpdated,np_.ReportDate 
					 ,np_.BirthDate,np_.MatureDate,np_.CurrentMth_,np_.FcTTL_12_Qty,np_.FcTTL_12_Qty_MthlyAvg,np_.FcMthCount,np_.Mth_Birth_Elapsed
				from np_
				--where np_.Mth_Elapsed > 7
				--where np_.ItemNumber in ('7501001000')
				--where np_.Mth_Birth_Elapsed <=12						-- 25/9/2018 -- how many month has been passed since its birth date
			   -- where np_.Mth_Birth_Elapsed <=10						-- 25/9/2018 -- how many month has been passed since its birth date, reason why choose 10 months rather than 12 months is concern that if it is too long, then safety stock might deviated too much since new product are very unpredictable.
				
				  where np_.Mth_Birth_Elapsed <=12					--- 2/9/2019, reintate to 12 months, concerns for safety stock ( too high or too low ) is legitmate, but really should leave decision making to Specific store procedure like sp_Safetystock to choose how many months of NP birth month passed, not here. Here you just defined parameters for General NP table.
				  and np_.Date >= np_.CurrentMth_					-- 19/2/2019 -- you can pick records which past today's date ( to exclude old data )
				          
				  )
            

          select z.ItemNumber,z.Date,z.Value,z.DataType,z.CN_Number,z.Comment,z.Creator,z.LastUpdated,z.ReportDate
				,z.BirthDate,z.MatureDate,z.CurrentMth_,z.FcTTL_12_Qty,z.FcTTL_12_Qty_MthlyAvg,z.FcMthCount,z.Mth_Birth_Elapsed
				,0 as mockcol
				from tb z 
         --where z.ItemNumber in ('34.731.001')
		  --select * from z where z.ItemNumber in ('34.734.001')
		  --select distinct z.ItemNumber from z

		--  select * from JDE_DB_Alan.FCPRO_NP_tmp
		
GO
