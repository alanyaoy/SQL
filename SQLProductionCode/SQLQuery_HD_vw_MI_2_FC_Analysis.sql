
create view [JDE_DB_Alan].[vw_MI_2_FC_Analysis] with schemabinding
as

  --- Syntax '*' is not allowed in schema-bound objects ! ---   So in your final Select you need to pick up All columns --- 12/3/2018
  --- it is OK to list all columns , so when you want to use View table you can select whatever columns you want ---
  --- Need to design a SP to automatically refresh the View every month or any time  your loaded your NP table --- 12/3/2018
 
 --drop view [JDE_DB_Alan].[vw_NP_FC_Analysis]


-- select * from JDE_DB_Alan.FCPRO_MI_tmp m1 where m1.ItemNumber in ('27.264.850')
 -- select * from JDE_DB_Alan.FCPRO_MI_2_tmp m2 where m2.ItemNumber in ('18.010.035')
 -- select * from JDE_DB_Alan.FCPRO_MI_2_Raw_Data_tmp m2 where m2.ItemID in ('18.010.035')

with _mi2 as 
			( select mi2fc.ItemNumber,mi2fc.date,mi2fc.Value,mi2fc.DataType,mi2fc.CN_Number,mi2fc.Comment,mi2fc.Creator,mi2fc.LastUpdated,mi2fc.ReportDate 
				--from JDE_DB_Alan.FCPRO_MI_2_Raw_Data_tmp  mi2fc left join JDE_DB_Alan.vw_Mast m on mi2fc.ItemID = m.ItemNumber            -- not recommend to use because you need to do whole lot of works like aggregated data from different project to arrive on SKU level 3/9/2019
				  from JDE_DB_Alan.FCPRO_MI_2_tmp  mi2fc left join JDE_DB_Alan.vw_Mast m on mi2fc.ItemNumber = m.ItemNumber					-- 'FCPRO_MI_2_tmp' is clean table,but you need to refresh beginning of each month, otherwise you could use last month data ! 3/9/2019
				where mi2fc.Value > 0
				      and mi2fc.ValidStatus = 'Y'                   --- add 31/8/2018
					 -- and m.StockingType not in ('O','U','Q','M')   --- for MTO ( 'M') or BTO ( 'Q') there is no need to generate FC   3/9/2019
					  and m.StockingType not in ('O','U')   --- for MTO ( 'M') or BTO ( 'Q') there is need to generate FC   13/9/2019 --- according to Nic
					  )
					                           
	,mi2_ as ( select _mi2.ItemNumber,_mi2.Date,_mi2.Value,_mi2.DataType,_mi2.CN_Number,_mi2.Comment,_mi2.Creator,_mi2.LastUpdated,_mi2.ReportDate
					,min(_mi2.Date) over(partition by _mi2.ItemNumber) as BirthDate		---FcStartDate
					,max(_mi2.Date) over(partition by _mi2.ItemNumber) as MatureDate		---FcEndDate					
					,DATEADD(mm, DATEDIFF(m,0,GETDATE()),0) as CurrentMth_
					,sum(_mi2.value) over (partition by _mi2.ItemNumber) as FcTTL_12_Qty			--- note this is true 12 FC Qty regardless of when is your current month, FC in 'FCPRO_Fcst' will cut off whatever the month passed by --- 12/3/2018
					,avg(_mi2.value) over (partition by _mi2.ItemNumber) as FcTTL_12_Qty_MthlyAvg		--- note when calculating Averge, if there is 0 quantities it will skip and count less to be divided, so maybe it is safe to hard coded to be divided by 12 - just a thought? -- 12/3/2018
					,count(_mi2.date) over (partition by _mi2.ItemNumber) as FcMthCount
					,datediff(m,min(_mi2.Date) over(partition by _mi2.ItemNumber),DATEADD(mm, DATEDIFF(m,0,GETDATE()),0) ) as Mth_Birth_Elapsed
			from _mi2					 				 
			where 
					--_mi2.ItemNumber in ('34.513.000 ')	and	 
                     _mi2.Value >0									-- pick up all value great than 0 and use this also to determine Birth and Mature date !!
			)
                 
		--select * from mi2_	where mi2_.ItemNumber in ('18.010.035') 

        ,tb as ( select mi2_.ItemNumber,mi2_.Date,mi2_.Value,mi2_.DataType,mi2_.CN_Number,mi2_.Comment,mi2_.Creator,mi2_.LastUpdated,mi2_.ReportDate 
					 ,mi2_.BirthDate,mi2_.MatureDate,mi2_.CurrentMth_,mi2_.FcTTL_12_Qty,mi2_.FcTTL_12_Qty_MthlyAvg,mi2_.FcMthCount,mi2_.Mth_Birth_Elapsed
				from mi2_
				--where mi2_.Mth_Elapsed > 7
				--where mi2_.ItemNumber in ('7501001000')
				--where mi2_.Mth_Birth_Elapsed <=12						-- 25/9/2018 -- how many month has been passed since its birth date
			   -- where mi2_.Mth_Birth_Elapsed <=10						-- 25/9/2018 -- how many month has been passed since its birth date, reason why choose 10 months rather than 12 months is concern that if it is too long, then safety stock might deviated too much since new product are very unpredictable.
				
				  --where mi2_.Mth_Birth_Elapsed <=12					--- 2/9/2019, reintate to 12 months, concerns for safety stock ( too high or too low ) is legitmate, but really should leave decision making to Specific store procedure like sp_Safetystock to choose how many months of NP birth month passed, not here. Here you just defined parameters for General NP table.
				  where mi2_.Date >= mi2_.CurrentMth_					-- 19/2/2019 -- you can pick records which past today's date ( to exclude old data )
				          
				  )
            

          select z.ItemNumber,z.Date,z.Value,z.DataType,z.CN_Number,z.Comment,z.Creator,z.LastUpdated,z.ReportDate
				,z.BirthDate,z.MatureDate,z.CurrentMth_,z.FcTTL_12_Qty,z.FcTTL_12_Qty_MthlyAvg,z.FcMthCount,z.Mth_Birth_Elapsed from tb z 
         -- where z.ItemNumber in ('18.010.035')
		  --select * from z where z.ItemNumber in ('34.734.001,34.731.000')
		  --select distinct z.ItemNumber from z

		--  select * from JDE_DB_Alan.FCPRO_NP_tmp
GO
