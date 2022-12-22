
CREATE view [JDE_DB_Alan].[vw_MI_FC_Analysis_old] with schemabinding
as

  --- Syntax '*' is not allowed in schema-bound objects ! ---   So in your final Select you need to pick up All columns --- 12/3/2018
  --- it is OK to list all columns , so when you want to use View table you can select whatever columns you want ---
  --- Need to design a SP to automatically refresh the View every month or any time  your loaded your NP table --- 12/3/2018
 
 --drop view [JDE_DB_Alan].[vw_NP_FC_Analysis]


-- select * from JDE_DB_Alan.FCPRO_MI_tmp m1 where m1.ItemNumber in ('82.691.901')

 -- select * from JDE_DB_Alan.FCPRO_MI_2_tmp m2 where m2.ItemNumber in ('18.010.035')
 -- select * from JDE_DB_Alan.FCPRO_MI_2_Raw_Data_tmp m2 where m2.ItemID in ('18.010.035')



        --- *************** Consolidation *****************************************************************************************************************
		--- Consolidate into One SKU for Mi_1 --- 29/4/2021
		--- For Mi_1 although it is the value directluy overwrite FC, you might have 2 inputs for same SKU in Mi_1 file, so need to consolidate into 1 SKU; for Mi_2 , you already have a process to look after this. 29/4/221
		--- Note, so birth date might not be real one if you have duplicate SKUs with differernt MIi_1, but most distant Mature date should be final Mature date for Mi_1 data.
		--- ****************************************************************************************************************************************************
		
with   mymi_1 as 
	          ( select  a.ItemNumber,a.Date,a.ValidStatus,a.LastUpdated,a.DataType,sum(a.Value) as fc_Value
						 from JDE_DB_Alan.FCPRO_MI_tmp a
						--where a.ValidStatus in ('Y') 
									--and a.Date >= DATEADD(mm, DATEDIFF(m,0,GETDATE()),0) 					--- 29/4/2021,Get records with date great than today 
						 group by a.ItemNumber,a.Date,a.ValidStatus,a.LastUpdated,a.DataType
			 )
          
      ,mymi_1_ as ( select a.ItemNumber,a.DataType,a.ValidStatus,sum(a.fc_value) as fc_ttl
					from mymi_1 a
					group by a.ItemNumber,a.DataType,a.ValidStatus
					)
      --select * from mymi_1_ a where a.ItemNumber in ('24.7221.0952')	               



	,_mi1 as 
			( select mi1fc.ItemNumber,mi1fc.date,mi1fc.Value,mi1fc.DataType,mi1fc.CN_Number,mi1fc.Comment,mi1fc.Creator,mi1fc.LastUpdated,mi1fc.ReportDate 
				--from JDE_DB_Alan.FCPRO_MI_2_Raw_Data_tmp  mi1fc left join JDE_DB_Alan.vw_Mast m on mi1fc.ItemID = m.ItemNumber            -- not recommend to use because you need to do whole lot of works like aggregated data from different project to arrive on SKU level 3/9/2019
				  from JDE_DB_Alan.FCPRO_MI_tmp  mi1fc left join JDE_DB_Alan.vw_Mast m on mi1fc.ItemNumber = m.ItemNumber					-- 'FCPRO_MI_2_tmp' is clean table,but you need to refresh beginning of each month, otherwise you could use last month data ! 3/9/2019
				where mi1fc.Value > 0
				      and mi1fc.ValidStatus = 'Y'                   --- add 31/8/2018
					 -- and m.StockingType not in ('O','U','Q','M')   --- for MTO ( 'M') or BTO ( 'Q') there is no need to generate FC   3/9/2019
					  and m.StockingType not in ('O','U')   --- for MTO ( 'M') or BTO ( 'Q') need to generate FC   13/9/2019 according to Nic
					  )
					                           
	,mi1_ as ( select _mi1.ItemNumber,_mi1.Date,_mi1.Value,_mi1.DataType,_mi1.CN_Number,_mi1.Comment,_mi1.Creator,_mi1.LastUpdated,_mi1.ReportDate
					,min(_mi1.Date) over(partition by _mi1.ItemNumber) as BirthDate		---FcStartDate
					,max(_mi1.Date) over(partition by _mi1.ItemNumber) as MatureDate		---FcEndDate					
					,DATEADD(mm, DATEDIFF(m,0,GETDATE()),0) as CurrentMth_
					,sum(_mi1.value) over (partition by _mi1.ItemNumber) as FcTTL_12_Qty			--- note this is true 12 FC Qty regardless of when is your current month, FC in 'FCPRO_Fcst' will cut off whatever the month passed by --- 12/3/2018
					,avg(_mi1.value) over (partition by _mi1.ItemNumber) as FcTTL_12_Qty_MthlyAvg		--- note when calculating Averge, if there is 0 quantities it will skip and count less to be divided, so maybe it is safe to hard coded to be divided by 12 - just a thought? -- 12/3/2018
					,count(_mi1.date) over (partition by _mi1.ItemNumber) as FcMthCount
					,datediff(m,min(_mi1.Date) over(partition by _mi1.ItemNumber),DATEADD(mm, DATEDIFF(m,0,GETDATE()),0) ) as Mth_Birth_Elapsed
			from _mi1					 				 
			where 
					--_mi1.ItemNumber in ('34.513.000 ')	and	 
                     _mi1.Value >0									-- pick up all value great than 0 and use this also to determine Birth and Mature date !!
			)
                 
		--select * from mi2_	where mi2_.ItemNumber in ('18.010.035') 

        ,tb as ( select mi1_.ItemNumber,mi1_.Date,mi1_.Value,mi1_.DataType,mi1_.CN_Number,mi1_.Comment,mi1_.Creator,mi1_.LastUpdated,mi1_.ReportDate 
					 ,mi1_.BirthDate,mi1_.MatureDate,mi1_.CurrentMth_,mi1_.FcTTL_12_Qty,mi1_.FcTTL_12_Qty_MthlyAvg,mi1_.FcMthCount,mi1_.Mth_Birth_Elapsed
				from mi1_
				--where mi1_.Mth_Elapsed > 7
				--where mi1_.ItemNumber in ('7501001000')
				--where mi1_.Mth_Birth_Elapsed <=12						-- 25/9/2018 -- how many month has been passed since its birth date
			   -- where mi1_.Mth_Birth_Elapsed <=10						-- 25/9/2018 -- how many month has been passed since its birth date, reason why choose 10 months rather than 12 months is concern that if it is too long, then safety stock might deviated too much since new product are very unpredictable.
				
				  --where mi1_.Mth_Birth_Elapsed <=12					--- 2/9/2019, reintate to 12 months, concerns for safety stock ( too high or too low ) is legitmate, but really should leave decision making to Specific store procedure like sp_Safetystock to choose how many months of NP birth month passed, not here. Here you just defined parameters for General NP table.
				  where mi1_.Date >= mi1_.CurrentMth_					-- 19/2/2019 -- you can pick records which past today's date ( to exclude old data )
				          
				  )
            

          select z.ItemNumber,z.Date,z.Value,z.DataType,z.CN_Number,z.Comment,z.Creator,z.LastUpdated,z.ReportDate
				,z.BirthDate,z.MatureDate,z.CurrentMth_,z.FcTTL_12_Qty,z.FcTTL_12_Qty_MthlyAvg,z.FcMthCount,z.Mth_Birth_Elapsed from tb z 
         -- where z.ItemNumber in ('82.691.901')
		  --select * from z where z.ItemNumber in ('34.734.001,34.731.000')
		  --select distinct z.ItemNumber from z

		--  select * from JDE_DB_Alan.FCPRO_NP_tmp
GO
