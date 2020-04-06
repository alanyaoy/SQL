	

use JDE_DB_Alan
go

	
	------ Forecast accuracy report new ---
	
	--  if @Measurement_id = 'LT'
	

	 ------------- Alan's New code ------------------ 1/6/2018 -------------------------------------------------------------------
		WITH R(N,_T,T_,T,XX,YY,start) AS
					(
					 select 1 as N,-24 as _T,24 as T_,-23 as T,24 as XX,24 as YY,cast(DATEADD(mm, DATEDIFF(mm, 0, GETDATE())-24, 0) as datetime) as start      -- pay attention T starts -23,you need this so you can get XXX Column/Field in current month you start as 1, otherwise you can use XX field
					 UNION ALL
					 select  N+1, _T+1,T_-1,case when T+1<0 then T+1 else case when T+1 =0 then 1 else T+1 end end as T						
											,case when N >= 24  then _T+1
											   else  
												   XX-1
												end as XX
											 ,case when N >= 24  then T							     
											   else  
												   YY-1
												end as YY
							 ,dateadd(mm,1,start)
					  from R
					 where N < 49
					)
				--select * from r
				--select R.N,case when R._T < 0 then R.T_ else R._T end as T, start from R
				--select R.N,case when R._T < 0 then R.T_ else R.YY end as T, start from R
			  ,MthCal as (
								select  n as rnk
								 ,XX
								 ,YY 
								,cast(SUBSTRING(REPLACE(CONVERT(char(10),start,126),'-',''),1,6) as integer) as [StartDt]		-- [StartDt] is calendar date in MthCal
								,LEFT(datename(month,start),3) AS [month_name]
								,datepart(month,start) AS [month]
								,datepart(year,start) AS [year]				
							   from R  )
			  --select * from MthCal
			 
			 ,f as ( select fch.*
							,cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,fch.date),0),126),'-',''),1,6) as integer) as FC_date		-- FC_date is FC period in FC table but in Integer format -- FC date in YYYY-mm format--- 5/9/2018	, changed position on 11/1/2019							
							,cast(SUBSTRING(REPLACE(CONVERT(char(10),fch.ReportDate,126),'-',''),1,6) as integer) as [StartDate]	--this [StartDate] is ReportDate in FC table but in Integer format					
					  from JDE_DB_Alan.FCPRO_Fcst_History fch
							-- where h.ItemNumber in ('42.210.031')
							 --  where fch.ItemNumber in ('26.045.0696')
							)
			  ,fc as ( select f.ItemNumber as Itm
							,f.DataType1
							,f.Date										-- FC date ( FC Period )  in YYYY-mm-dd 00:00:00.000 format
							,f.FC_date							
							,f.Value					
							,f.ReportDate								-- this is ReportDate  in YYYY-mm-dd 00:00:00.000 format
							,f.StartDate								-- this is ReportDate  in Integer format , in YYYY-mm format
							,c.*													--- join cal to get YY value which is your month rank/order
				    
					from f left join MthCal c on  f.StartDate = c.StartDt												--- no need to cross join cal table as FC tb always has data in 24 mth				
					-- where fc.ItemNumber = ('42.210.031') order by fc.ItemNumber,fc.StartDt,fc.Date
					)  
               
			   --   select * from fc where fc.Itm in ('26.045.0696')										---20/8/2019			
			   -- select * from fc where fc.Itm in ('42.210.031')
			   -- select * from JDE_DB_Alan.vw_Mast m where m.ItemNumber in ('42.210.031')
			   -----------------------------------------------------------------      
				--- LT offset FC ---
			  ,fct as ( -- select *
						--select fc.Itm,fc.DataType1,fc.Date,fc.StartDt,fc.Value,fc.ReportDate,fc.YY,fc.rnk,fc.month			 -- inner join --- so remove all records which does not meet condition - In another words I am only interested and only want SKU that has 3 month lead time. Of course you can use Left join to achiece same result, if you use inner join it is important to include all records of Master data in vw_Mast table though, otherwise you will lose some data --- 30/5/2018  -- Use YY
						select fc.Itm,fc.DataType1,fc.Date,fc.StartDt,fc.Value,fc.ReportDate,fc.XX,fc.rnk,fc.month				 -- inner join --- so remove all records which does not meet condition - In another words I am only interested and only want SKU that has 3 month lead time. Of course you can use Left join to achiece same result, if you use inner join it is important to include all records of Master data in vw_Mast table though, otherwise you will lose some data --- 11/1/2019  -- Use XX
						from fc inner join JDE_DB_Alan.vw_Mast m on fc.Itm = m.ItemNumber and fc.XX= m.Leadtime_Mth+1			-- LT calculation: LT plus 1 month since FC was saved last day of month - if 2 month then need to consider 60 days, 3 month need to consider 90 days; it will also depend how what value you are using for benchmarking -->  XX or YY  ? 11/1/2019
						where fc.Date =  DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0)											-- Get monthly fc in this case --> FC of '2018-04-01' this is FC you want to measure			   -- fc.Date is Forecast Period
							   --and fc.Date =  '2018-04-01 00:00:00.000'	
						)	
			   --select * from fct where fct.Itm in ('26.045.0696','42.210.031')							---20/8/2019, there will be no fc for 26.045.0696 as it is beyond LT limit	( if you are in Aug, first FC starts in April which is only 4 months away)
			
				--- Non LT offset FC --- Version 1, based on, in each month, forecast was saved from Next month onwards. (not including current month FC ie, in May 2019, Saved forecast data in SQL DB are 06/19,17/19,18/19 ... etc ) ---20/5/2019
			  ,fctt_1 as ( -- select *
						--select fc.Itm,fc.DataType1,fc.Date,fc.StartDt,fc.Value,fc.ReportDate,fc.YY,fc.rnk,fc.month				 -- inner join -- Use YY
						select fc.Itm,fc.DataType1,fc.Date,fc.StartDt,fc.Value,fc.ReportDate,fc.XX,fc.rnk,fc.month					 -- inner join -- Use XX 
						from fc 																							  --- No Need to use Join you simply fetch last month FC
						where     fc.StartDt	 = cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-2,0),126),'-',''),1,6) as integer)  	-- Get FC saved 30 days ago. LT calculation: Get data captured 1 mth ago, since last month you will have FC only for next month, do get fooled that you are only retriveing forecast 30 days ago ( it looks like 2 month ago ) but this is most recent fc you can get for fc you want to measure !   --- '201803'   -- Performance issue ? --- fc.StartDt is ReportDate ( Date when fc was saved )   --- 10/1/19
								 -- fc.StartDt	 = cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-',''),1,6) as integer)   -- Use so called 'last mth' FC ( use minus 1 in formula ),use fc saved 1 day ago ?  You cannot do this, since last month you only saved next month forecast--- 11/1/19 
								  --and fc.StartDt = '201803'																									-- hard coded LT			
								  --and fc.YY = 2 and fc.rnk = 23																		-- 	Capped to 2 mth ago	
								  and fc.Date = DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0)											-- get monthly fc in this case --> FC of '2018-04-01' this is FC you want to measure		-- fc.Date is Forecast Period
									--and fc.Date =  '2018-04-01 00:00:00.000'	
							)			

             	  --- Non LT offset FC --- Version 2, based on, in each month, forecast was saved from This month onwards (including current month FC ie, in May 2019, Saved forecast data in SQL DB are 05/19,06/19,17/19,18/19 ... etc )  --- 20/5/2019
			  ,fctt_2 as ( -- select *
						--select fc.Itm,fc.DataType1,fc.Date,fc.StartDt,fc.Value,fc.ReportDate,fc.YY,fc.rnk,fc.month				 -- inner join -- Use YY
						select fc.Itm,fc.DataType1,fc.Date,fc.StartDt,fc.Value,fc.ReportDate,fc.XX,fc.rnk,fc.month					 -- inner join -- Use XX 
						from fc 																							  --- No Need to use Join you simply fetch last month FC
						where     fc.StartDt	 = cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-',''),1,6) as integer)  	-- Get FC saved 30 days ago. LT calculation: Get data captured 1 mth ago, since last month you will have FC only for next month, do get fooled that you are only retriveing forecast 30 days ago ( it looks like 2 month ago ) but this is most recent fc you can get for fc you want to measure !   --- '201803'   -- Performance issue ? --- fc.StartDt is ReportDate ( Date when fc was saved )   --- 10/1/19
								 -- fc.StartDt	 = cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-',''),1,6) as integer)   -- Use so called 'last mth' FC ( use minus 1 in formula ),use fc saved 1 day ago ?  You cannot do this, since last month you only saved next month forecast--- 11/1/19 
								  --and fc.StartDt = '201803'																									-- hard coded LT			
								  --and fc.YY = 2 and fc.rnk = 23																		-- 	Capped to 2 mth ago	
								  and fc.Date = DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0)											-- get monthly fc in this case --> FC of '2018-04-01' this is FC you want to measure		-- fc.Date is Forecast Period
									--and fc.Date =  '2018-04-01 00:00:00.000'	
							)		

				,fctt as (  --select * from fctt_1
							select * from fctt_2								-- Use Version 2
							)
				-- select * from fctt  where fctt.Itm in ('26.045.256')						
				--select * from fct  where fct.Itm in ('42.210.031','32.379.200')
			   -- select * from fctt  where fctt.Itm in ('42.210.031')			
              ---------------------------------------------------------------------			  
			   
			  ------- Last Month Histry --- If you are in May, Need April History ( compared with April FC though) ,Not May History !  --------------

				  ------- Below is tb NOT padded with 0 sales history -------- straight from SlsHist tb  ------ do not use this one ?
				,hist as ( select h.ItemNumber,h.CYM,h.CY,h.Month,h.SalesQty,h.ReportDate
									,c.YY,c.rnk,c.StartDt,c.month as mth
						   from  JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h left join MthCal c on h.CYM = c.StartDt	
						   where     h.CYM = cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-',''),1,6) as integer)			-- Performance issue ?
								   -- h.CYM = '201804' and
								   --c.rnk =24						--- last month ( for last month Sales)
						   )

				,SlsItm as ( select distinct h.ItemNumber as ItemNumber_ from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h )
				,m as ( select * from SlsItm cross join MthCal c 
							 -- where   c.StartDt between replace(convert(varchar(8), DATEADD(mm, DATEDIFF(m,0,GETDATE())-12,0),126),'-','' )			-- last 12 months		
							  --				 and  replace(convert(varchar(8), DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-','' )		   -- last 12 months
									)		     
			
				  -------- Below is tb padded Item with all Months ------- straight from SlsHist tb  ------ use this one
				,histy as																													
				(  select m.ItemNumber_
							,h.CYM,h.CY,h.Month
							,h.ReportDate
							,case when h.SalesQty is null then 0 else h.SalesQty end as SalesQty
							--,case when h.ReportDate is null then getdate() else h.ReportDate end as ReportDate_
							--  ,case when h.ReportDate is null then getdate() else h.ReportDate end as ReportDate_
							,getdate() as ReportDate_												-- there is no different version of history, so do not bother to use old ReportData in History table UNLESS you need to join back to History table using ReportData as a key --- 5/9/2018
							,m.YY, m.rnk,m.StartDt,m.month as mth						  
							,case 
								when h.CYM is null	then cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-',''),1,6) as integer) 		-- why use this ?						
								else h.CYM
							end as CYM_
							,case 
								when h.CYM is null	then m.StartDt						
								else h.CYM
							end as CYM_2

					from m left join JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h on m.StartDt = h.CYM and  m.ItemNumber_ = h.ItemNumber
					--where    list.StartDt = cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-',''),1,6) as integer)			-- Watch out use List.StartDt Not h.CYM !!!   --- 29/5/2018
							-- h.CYM = '201804' and																													-- Performance issue ?
							--c.rnk =24																												-- last month ( for last month Sales)
						--where  m.StartDt <= cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-',''),1,6) as integer)			-- 30/10/20018
						  where  m.StartDt = cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-',''),1,6) as integer)			-- 31/10/20018
						)
					--select * from hist where hist.ItemNumber_ in ('82.501.904')
					-- select * from hist where hist.ItemNumber in ('42.210.031')
					--select * from hist where hist.ItemNumber in ('38.001.001')

				--	select * from histy where histy.ItemNumber_   in ('26.045.0696','42.210.031')				--- 20/8/2019, OK Got it both 
				   -----------------------------------------------------------------------------------  
					 -------------------------------------------------------------------------- 
				   --- **************************************
				   --- Accuracy use Lead Time offset
				   --- **************************************

		  			,comVol_ as																			-- *** comVol_ can be made obsoleted code *** ---
				   ( select 'Units' as DataType,fct.Itm,histy.ItemNumber_
							 --,histy.SalesQty as Sales,fct.Value as Fcst													--19/8/2019
							 ,isnull(histy.SalesQty,0) as Sales,isnull(fct.Value,0) as Fcst									--20/8/2019							
							,fct.StartDt
							--,SalesQty - fct.Value as Bias,ABS(SalesQty -  fct.Value) as ABS													--19/8/2019
							,(isnull(SalesQty,0) - isnull(fct.Value,0)) as Bias,ABS(isnull(SalesQty,0) -  isnull(fct.Value,0)) as ABS			--20/8/2019	
					   from fct full outer join histy on fct.Itm = histy.ItemNumber_)		
			   
					-- select * from comVol_ c where c.ItemNumber_ in ('18.317.005','26.045.256') 	
					--select * from comVol_ c where c.ItemNumber_ in ('42.210.031','26.045.0696') 	            --- 20/8/2019
								   				           
				  ,_comVol as																			-- *** _comVol can be used as new code *** ---
				   ( select 'Units' as DataType
							,case when fct.Itm is null then histy.ItemNumber_ else fct.Itm end as Item					
							,isnull(histy.SalesQty,0) as Sales,isnull(fct.Value,0) as Fcst
							,fct.Date,case when fct.Date is null then DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0) else fct.Date end as Date_
							,fct.StartDt
							--,isnull((SalesQty - fct.Value),0)as BiasVol,isnull(ABS(SalesQty -  fct.Value),0) as ABSVol							--19/8/2019   ( this code does yields Null for fct hence BiasVol and ABSVol will be resulting in null when subtracts null value) - if this is what you what to see/report , you can re instate this line of code  --21/8/2019    -- has sales but not forecasted,like VB 25 coil stock, lead time is 5 month, we did not have fc 5 months ago ( if I am in Aug to measure FC accuracy)
							--,coalesce(isnull(abs(SalesQty - fct.Value),0)/nullif(histy.SalesQty,0),0) as ErrPct									--19/8/2019   ( this will yields 0 for Err when assign null to fct.value)                                            - if this is what you what to see/report , you can re instate this line of code          -- 21/8/2019		 -- has sales but not forecasted,like VB 25 coil stock, lead time is 5 month, we did not have fc 5 months ago ( if I am in Aug to measure FC accuracy)
							--,1-(coalesce(isnull(abs(SalesQty - fct.Value),0)/nullif(histy.SalesQty,0),0)) as AccuracyPct							--19/8/2019   ( this will yields 1 for Acc when Err is 0 because of fct.value is assigned null value)				- if this is what you what to see/report , you can re instate this line of code          -- 21/8/2019        -- has sales but not forecasted,like VB 25 coil stock, lead time is 5 month, we did not have fc 5 months ago ( if I am in Aug to measure FC accuracy)

							,(isnull(SalesQty,0) - isnull(fct.Value,0)) as BiasVol, ABS(isnull(SalesQty,0) -  isnull(fct.Value,0)) as ABSVol		--20/8/2019
							,coalesce(abs(isnull(SalesQty,0) - isnull(fct.Value,0))/nullif(histy.SalesQty,0),0) as Errpc
							, case 
								when coalesce(abs(isnull(SalesQty,0) - isnull(fct.Value,0))/nullif(histy.SalesQty,0),0) between -1 and 1 then coalesce(abs(isnull(SalesQty,0) - isnull(fct.Value,0))/nullif(histy.SalesQty,0),0)							   
								else 0
								 end  as ErrPct
							, case 
								when coalesce(abs(isnull(SalesQty,0) - isnull(fct.Value,0))/nullif(histy.SalesQty,0),0) between -1 and 1 then 1- coalesce(abs(isnull(SalesQty,0) - isnull(fct.Value,0))/nullif(histy.SalesQty,0),0)							   
								else 0
								 end  as AccuracyPct						

					   from fct full outer join histy on fct.Itm = histy.ItemNumber_
					   )

                   --select * from _comVol c where c.Item in ('42.210.031','26.045.0696')
			   	
					,zero as ( select * from _comVol where _comVol.Fcst =0 and _comVol.Sales=0)
					--zero as ( select * from _comVol where _comVol.Fcst =0 )
					--select * from zero		
					,comVol as ( select * from _comVol															  --- comVol table is not used in main query but it is good to have it for sanity check 	
									-- where _comVol.Item not in ( select zero.Item from zero )					  --- works but not ideal usijng 'Not in'   -1/6/2018
									 where not exists ( select zero.Item from zero where zero.Item = _comVol.Item)   -- better using 'Not exists' --- https://stackoverflow.com/questions/1662902/when-to-use-except-as-opposed-to-not-exists-in-transact-sql -- Also note ,if any row of that subquery returns NULL, the entire NOT IN operator will evaluate to either FALSE or UNKNOWN and no records will be returned
								 --  where comVol.Item in ('82.501.904')				
								  )

					 ,f_comVol as 
							( select c.*,m.Description,m.Family_0,m.FamilyGroup_
									,m.WholeSalePrice
									,c.Sales*m.WholeSalePrice as SlsAmt
									,c.Fcst*m.WholeSalePrice  as FcstAmt
									,BiasVol * m.WholeSalePrice as Bias_Amt
									,ABSVol * m.WholeSalePrice as ABS_Amt
									,coalesce((ABSVol * m.WholeSalePrice)/nullif(c.Sales*m.WholeSalePrice,0),0) as ErrPct_Amt
									,1-(coalesce((ABSVol * m.WholeSalePrice)/nullif(c.Sales*m.WholeSalePrice,0),0)) as AccuracyPct_Amt
									,m.PrimarySupplier,m.PlannerNumber
							  from _comVol c left join JDE_DB_Alan.vw_Mast m on c.Item = m.ItemNumber )
					  --select * from f_comVol

					 ,_comb as ( select fl.DataType,fl.Item,fl.Sales,fl.Fcst,fl.Date_,fl.StartDt,fl.BiasVol as Bias,fl.ABSVol as ABS_,fl.ErrPct,fl.AccuracyPct,fl.Description,fl.Family_0,fl.FamilyGroup_,fl.PrimarySupplier,fl.PlannerNumber
									from f_comVol fl
								union all
								select 'Dollars' as DataType,fl.Item,fl.SlsAmt,fl.FcstAmt,fl.Date_,fl.StartDt,fl.Bias_Amt as Bias,fl.ABS_Amt as ABS_,fl.ErrPct_Amt,fl.AccuracyPct_Amt,fl.Description,fl.Family_0,fl.FamilyGroup_,fl.PrimarySupplier,fl.PlannerNumber
								   from f_comVol fl
							   )

					 ,comb as ( select x.*,m.StockingType,m.Leadtime_Mth,GETDATE() as ReportDate 
								from _comb x left join JDE_DB_Alan.vw_Mast m on x.Item= m.ItemNumber	
								where m.FamilyGroup not in ('943','950','998','999','TPA')					---Exclude 991/ Screen door, 943 / TMS,950 /  Finised Blinds,998 / Advertising Swatching,999 / Miscellaneous,TPA / TN MISCELLANEOUS        --- 19/9/2019
								      and m.StockingType in ('P','S')								 	---- 26/9/2019		only include active items ? and Exclude MTO and BTO ?
									 -- and m.StockingType in ('P','S','Q','M')								 	---- 26/9/2019		only include active items ? and Exclude MTO and BTO ?
								)

					   -- select * from comb
						--where comb.Item in ('26.045.0696')
						--  where comb.Item in ('42.210.031','26.045.0696') 				 

				  -----------------------------------------------------------------------------------------------
				   --- **************************************
				   --- Accuracy use Non-Lead Time offset
				   --- **************************************
				  ,comVoll_ as																 --- comVoll_ can be made obsoleted code  --- 
				   ( select 'Units' as DataType,fctt.Itm,histy.ItemNumber_
							--,histy.SalesQty as Sales,fctt.Value as Fcst											--19/8/2019
							,isnull(histy.SalesQty,0) as Sales,isnull(fctt.Value,0) as Fcst							--20/8/2019
							,fctt.StartDt
							--,SalesQty - fctt.Value as Bias,ABS(SalesQty -  fctt.Value) as ABS														--19/8/2019
							,(isnull(SalesQty,0) - isnull(fctt.Value,0)) as Bias,ABS(isnull(SalesQty,0) - isnull(fctt.Value,0)) as ABS				--20/8/2019
					   from fctt full outer join histy on fctt.Itm = histy.ItemNumber_)		
			   
					 -- select * from comVol_ c where c.ItemNumber_ in ('TUFA20') 				   				           
                     -- select * from comVol_ c where c.ItemNumber_ in ('26.045.256') 		
					  		   				           
				 ,_comVoll as																 --- _comVoll can be used as new code  ---						
				   ( select 'Units' as DataType
							,case when fctt.Itm is null then histy.ItemNumber_ else fctt.Itm end as Item					
							,isnull(histy.SalesQty,0) as Sales,isnull(fctt.Value,0) as Fcst
							,fctt.Date
							,case when fctt.Date is null then DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0) else fctt.Date end as Date_				--- 
							,fctt.StartDt
							--,isnull((SalesQty - fctt.Value),0)as BiasVol,isnull(ABS(SalesQty -  fctt.Value),0) as ABSVol								--19/8/2019   ( this code does yields Null for fct hence BiasVol and ABSVol will be resulting in null when subtracts null value) - if this is what you what to see/report , you can re instate this line of code  --21/8/2019    -- has sales but not forecasted,like VB 25 coil stock, lead time is 5 month, we did not have fc 5 months ago ( if I am in Aug to measure FC accuracy)
							--,coalesce(isnull(abs(SalesQty - fctt.Value),0)/nullif(histy.SalesQty,0),0) as ErrPct										--19/8/2019   ( this will yields 0 for Err when assign null to fct.value)                                            - if this is what you what to see/report , you can re instate this line of code          -- 21/8/2019		 -- has sales but not forecasted,like VB 25 coil stock, lead time is 5 month, we did not have fc 5 months ago ( if I am in Aug to measure FC accuracy)	
							--,1-(coalesce(isnull(abs(SalesQty - fctt.Value),0)/nullif(histy.SalesQty,0),0)) as AccuracyPct                             --19/8/2019   ( this will yields 1 for Acc when Err is 0 because of fct.value is assigned null value)				- if this is what you what to see/report , you can re instate this line of code          -- 21/8/2019        -- has sales but not forecasted,like VB 25 coil stock, lead time is 5 month, we did not have fc 5 months ago ( if I am in Aug to measure FC accuracy)


                         ,(isnull(SalesQty,0) - isnull(fctt.Value,0)) as BiasVol, ABS(isnull(SalesQty,0) -  isnull(fctt.Value,0)) as ABSVol		--20/8/2019
						 ,coalesce(abs(isnull(SalesQty,0) - isnull(fctt.Value,0))/nullif(histy.SalesQty,0),0) as Errpc
							, case 
								when coalesce(abs(isnull(SalesQty,0) - isnull(fctt.Value,0))/nullif(histy.SalesQty,0),0) between -1 and 1 then coalesce(abs(isnull(SalesQty,0) - isnull(fctt.Value,0))/nullif(histy.SalesQty,0),0)							   
								else 0
								 end  as ErrPct
							, case 
								when coalesce(abs(isnull(SalesQty,0) - isnull(fctt.Value,0))/nullif(histy.SalesQty,0),0) between -1 and 1 then 1- coalesce(abs(isnull(SalesQty,0) - isnull(fctt.Value,0))/nullif(histy.SalesQty,0),0)							   
								else 0
								 end  as AccuracyPct	


					   from fctt full outer join histy on fctt.Itm = histy.ItemNumber_
					   )

                 --   select * from _comVoll c where c.Item in ('26.045.256')
            
				 ,zeroo as ( select * from _comVoll where _comVoll.Fcst =0 and _comVoll.Sales=0)
				 --zero as ( select * from _comVol where _comVol.Fcst =0 )
				--select * from zero		
				,comVoll as (   select * from _comVoll															  --- comVoll table is not used in main query but it is good to have it for sanity check 	
								-- where _comVoll.Item not in ( select zeroo.Item from zeroo )					  --- works but not ideal usijng 'Not in'   -1/6/2018
								 where not exists ( select zeroo.Item from zeroo where zeroo.Item = _comVoll.Item)   -- better using 'Not exists' --- https://stackoverflow.com/questions/1662902/when-to-use-except-as-opposed-to-not-exists-in-transact-sql --  Also note ,if any row of that subquery returns NULL, the entire NOT IN operator will evaluate to either FALSE or UNKNOWN and no records will be returned
							 --  where comVol.Item in ('82.501.904')

							  )
				 ,f_comVoll as 
							( select c.*,m.Description,m.Family_0,m.FamilyGroup_
									,m.WholeSalePrice
									,c.Sales*m.WholeSalePrice as SlsAmt
									,c.Fcst*m.WholeSalePrice  as FcstAmt
									,BiasVol * m.WholeSalePrice as Bias_Amt
									,ABSVol * m.WholeSalePrice as ABS_Amt
									,coalesce((ABSVol * m.WholeSalePrice)/nullif(c.Sales*m.WholeSalePrice,0),0) as ErrPct_Amt
									,1-(coalesce((ABSVol * m.WholeSalePrice)/nullif(c.Sales*m.WholeSalePrice,0),0)) as AccuracyPct_Amt
									,m.PrimarySupplier,m.PlannerNumber
							   from _comVoll c left join JDE_DB_Alan.vw_Mast m on c.Item = m.ItemNumber 
							   where m.SellingGroup in ('AD','TM','WC')												--- 17/1/2019 filter out division no longer applicable
							   )
				   -- select * from f_comVoll

				 ,_combb as ( select fl.DataType,fl.Item,fl.Sales,fl.Fcst,fl.Date_,fl.StartDt,fl.BiasVol as Bias,fl.ABSVol as ABS_,fl.ErrPct,fl.AccuracyPct,fl.Description,fl.Family_0,fl.FamilyGroup_,fl.PrimarySupplier,fl.PlannerNumber
								from f_comVoll fl
							union all
							select 'Dollars' as DataType,fl.Item,fl.SlsAmt,fl.FcstAmt,fl.Date_,fl.StartDt,fl.Bias_Amt as Bias,fl.ABS_Amt as ABS_,fl.ErrPct_Amt,fl.AccuracyPct_Amt,fl.Description,fl.Family_0,fl.FamilyGroup_,fl.PrimarySupplier,fl.PlannerNumber
							   from f_comVoll fl
						   )

				 
				 ,combb as ( select x.*,m.StockingType,m.Leadtime_Mth,GETDATE() as ReportDate									--- Pick 'StockingType'
							 from _combb x left join JDE_DB_Alan.vw_Mast m on x.Item = m.ItemNumber 
							 where m.FamilyGroup not in ('943','950','998','999','TPA')						--- Exclude 943 / TMS,950 /  Finised Blinds,998 / Advertising Swatching,999 / Miscellaneous,TPA / TN MISCELLANEOUS
	                              and m.StockingType in ('P','S')										--- 26/9/2019	only include active items ? and Exclude MTO and BTO
								 -- and m.StockingType in ('P','S','Q','M')										--- 26/9/2019	only include active items ? and Exclude MTO and BTO
								)
				 
				-- select * from combb b
				-- where b.Item in ('38.001.005')	          		         
		  
				--insert into JDE_DB_Alan.FCPRO_Fcst_Accuracy  select * from comb
				  --select * from JDE_DB_Alan.FCPRO_Fcst_Accuracy  	 


				select * from comb b
				where b.Item in ('38.001.005')	 

-----------------------------------------------------------------------------------------

             --- Forecast accuracy on Family Group level ---  25/2/2020
with _t as 
   (
	select a.FamilyGroup_,sum(a.Sales) as Sls_fgrp,sum(a.Fcst) as FC_fgrp
	from  JDE_DB_Alan.FCPRO_FC_Accy_SKU a 
	where a.DataType in ('Units') and a.FamilyGroup_ <> ('991 / SCREEN DOOR')
	group by a.FamilyGroup_
	  )

 ,t_ as (  select _t.*, sum(_t.Sls_fgrp) over() as Sls_grp_Gnd, sum(_t.FC_fgrp) over() as FC_grp_Gnd
			from  _t
        
		  )
select * from t_

     
	        --- Forecast accuracy on Family level ---  25/2/2020

;with _t as 
   (
	select a.Family_0,sum(a.Sales) as Sls_family,sum(a.Fcst) as FC_family
	from  JDE_DB_Alan.FCPRO_FC_Accy_SKU a 
	where a.DataType in ('Units') and a.FamilyGroup_ <> ('991 / SCREEN DOOR')
	group by a.Family_0
	  )

 ,t_ as (  select _t.*, sum(_t.Sls_family) over() as Sls_family_Gnd, sum(_t.FC_family) over() as FC_family_Gnd
			from  _t
        
		  )

select * from t_


-------------------------- combined together --------------------------- 25/2/2020

    --- family group, level 1 data --- using it own Bias ( V1), not bias from Family ( V2)  or SKU (V3) ---
;with _t as 
   (
	select a.DataType,a.FamilyGroup_ as Hierarchy_,a.LT_Type,sum(a.Sales) as Sls_agrg,sum(a.Fcst) as FC_agrg
	from  JDE_DB_Alan.FCPRO_FC_Accy_SKU a 
	where 
		     a.FamilyGroup_ <> ('991 / SCREEN DOOR')
			--and a.DataType in ('Units')												-- only measure 'Unit' at the moment,if need, can include 'Dollars' in future --- 26/2/2020
	group by a.DataType,a.FamilyGroup_,a.LT_Type
	  )

 ,t_ as (  select _t.*
			, sum(_t.Sls_agrg) over(partition by _t.DataType order by _t.DataType) as Sls_Gnd, sum(_t.FC_agrg) over(partition by _t.DataType order by _t.DataType) as FC_Gnd,'FamilyGroup_' as Hierarchy_Descp,'V1' as Version
			from  _t
        
		  )

   --select * from t_

    --- family, level 1 data --- using it own Bias ( V1), not bias from SKU ( V3) ---
 ,_tt as 
   (
	select a.DataType,a.Family_0 as Hierarchy_,a.LT_Type,sum(a.Sales) as Sls_aggrg,sum(a.Fcst) as FC_aggrg
	from  JDE_DB_Alan.FCPRO_FC_Accy_SKU a 
	where 
			   a.FamilyGroup_ <> ('991 / SCREEN DOOR')
			-- and a.DataType in ('Units')												-- only measure 'Unit' at the moment,if need, can include 'Dollars' in future   --26/2/2020
	group by a.DataType,a.Family_0,a.LT_Type
	  )

 ,tt_ as (  select _tt.*, sum(_tt.Sls_aggrg) over(partition by _tt.DataType order by _tt.DataType) as Sls_Gnd, sum(_tt.FC_aggrg) over(partition by _tt.DataType order by _tt.DataType) as FC_Gnd,'Family_' as Hierarchy_Descp,'V1' as Version
			from  _tt
        
		  )

 ,_comb as ( select * from t_
              union all
            select * from tt_
			)

 ,_comb_ as (select b.DataType,b.Hierarchy_,b.Sls_agrg as Sls_,b.FC_agrg as FC_            
			,b.Sls_Gnd,b.FC_Gnd,b.Hierarchy_Descp,b.Version,b.LT_Type

			 from _comb b
			--order by b.Hierarchy_Descp desc,b.Hierarchy_ desc
			)

 ,comb_ as ( select b.DataType,b.Hierarchy_,b.Sls_,b.FC_,(b.Sls_ - b.FC_) as Bias_,abs(b.Sls_ - b.FC_) as Abs_                    
					,b.Sls_Gnd,b.FC_Gnd,b.Hierarchy_Descp,b.Version,b.LT_Type
              from _comb_ b

			  )

 , comb as ( select b.DataType,b.Hierarchy_,b.Sls_,b.FC_,b.Bias_,b.Abs_
                    ,sum(b.Bias_) over(partition by b.DataType, Hierarchy_Descp ) as Bias_ttl
					,sum(b.Abs_) over(partition by b.DataType, Hierarchy_Descp ) as Abs_ttl
					,b.Sls_Gnd,b.FC_Gnd,b.Hierarchy_Descp,b.Version,b.LT_Type
					,getdate() as Reportdate
              from comb_ b
			  )

 select * from comb b
 --where b.DataType in ('Units')
   --where b.DataType in ('Dollars')
     -- and b.Hierarchy_Descp in ('Family_')
	  -- and b.Hierarchy_Descp in ('FamilyGroup_')
 order by b.DataType desc,b.Hierarchy_Descp desc,b.Hierarchy_ asc

  ----------------------------------------------------------------------
select * from JDE_DB_Alan.FCPRO_FC_Accy_SKU a where a.Item in ('38.005.001')
