use JDE_DB_Alan
go


--- FC Accuracy --- 22/5/2018
	 
	with CalendarFrame as (
				--select -24 as t,1 as n,cast(DATEADD(mm, DATEDIFF(mm, 0, GETDATE())-24, 0) as datetime) as start
					select 1 as t,1 as n,cast(DATEADD(mm, DATEDIFF(mm, 0, GETDATE())-24, 0) as datetime) as start
				union all
				select case when t +1 >24 then 1 else t+1 end ,case when n=12 then 1 else n+1 end,dateadd(mm, 1, start)
				-- select t+1 ,case when n=12 then 1 else n+1 end,dateadd(mm, 1, start)
				from CalendarFrame
			)
			--select top 50 * from CalendarFrame
		 ,MonthlyCalendar as
				(
				select top 48 t, RIGHT('00'+CAST(n AS VARCHAR(3)),2) nmb,cast(SUBSTRING(REPLACE(CONVERT(char(10),start,126),'-',''),1,6) as integer) as [StartDate],
				DATENAME(mm,start) MnthName,DATENAME(yyyy,start) YearName from CalendarFrame
			)
		 --select * from MonthlyCalendar
		--cldr as
		--		(select mc.t
		--			,left(mc.eom,6)  as eom_
		--		from MonthlyCalendar mc 
		--		--where left(mc.eom,4)=2015
		--		where mc.eom> replace(convert(varchar(8), DATEADD(mm, DATEDIFF(m,0,GETDATE())-13,0),126),'-','')		--last 12 months
		--	),

		 --hist_ as ( select *,					
			--					case 
			--						when h.Month >= 10 then format(h.Month,'0') 
			--						--else right('000'+cast(a.financialMonth as varchar(2)),3) 
			--						when h.Month <10 then format(h.Month,'00') 
			--					end as MM
			--			from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h
			--			),
			--hist as ( select *,concat(hist_.CY,hist_.MM) as CYM_
			--				from hist_
			--			), 
			--histy as (select x.ItemNumber,count(x.CYM_) Sls_freq,sum(isnull(x.SalesQty,0)) SlsVol_TTL_12
			--			from hist x 
			--			--where x.ItemNumber in ('26.353.000') and x.CYM >201612
			--			where x.cym_ >replace(convert(varchar(8), DATEADD(mm, DATEDIFF(m,0,GETDATE())-13,0),126),'-','')				-- last 12 months
			--			group by x.ItemNumber )	,				--- sales about 9139 records
      

		,itm as ( select distinct h.ItemNumber as ItemNumber_ from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h )
		,list as ( select * from itm cross join MonthlyCalendar cldr 
					where StartDate between replace(convert(varchar(8), DATEADD(mm, DATEDIFF(m,0,GETDATE())-12,0),126),'-','' )			-- last 12 months		
											 and  replace(convert(varchar(8), DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-','' )		-- last 12 months
				  )		     
		-- Padded Item with all Months ---
		,_hist as 
		(  select list.ItemNumber_ ,case when h.SalesQty is null then 0 else h.SalesQty end as SalesQty_
				,list.StartDate as CYM,list.t
			from list left join JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h on list.StartDate = h.CYM and list.ItemNumber_ = h.ItemNumber
		--where list.ItemNumber in ('18.615.024') 		
		)
	  --select * from _hist where _hist.ItemNumber_ in ('27.252.713')
	   
	   ----- Get last month sales history ------ 25/5/2018
	   ,_hist_lmth as ( select l.ItemNumber_,l.SalesQty_,l.CYM,l.t, ROW_NUMBER() over(partition by l.ItemNumber_ order by l.t desc) maxrnk
						from _hist l
											)  
       ,hist_lmth as ( select * 
						from _hist_lmth
						where _hist_lmth.maxrnk =1							
					 )
      --  select * from hist_lmth where hist_lmth.ItemNumber_ in ('27.252.713') 

	   ,hist as ( select _hist.ItemNumber_,_hist.SalesQty_,_hist.CYM,_hist.t,hist_lmth.maxrnk,hist_lmth.SalesQty_ as Sale_lmth
						from _hist left join hist_lmth
						             on  _hist.ItemNumber_ = hist_lmth.ItemNumber_ 
					)
       
	   --select * from hist where hist.ItemNumber_ in ('27.252.713','82.391.901') order by hist.ItemNumber_,hist.CYM

		,histy as 
			( select x.ItemNumber_
			,count(isnull(x.CYM,0)) TTL_Mths
			,sum( case when salesqty_ >0 then 1 else 0 end ) as Sls_freq
			,sum(x.SalesQty_) SlsVol_TTL_12 
			,avg(x.Sale_lmth) SlsVol_lmth
			from hist x 
			group by x.ItemNumber_)
		--select * from histy where histy.ItemNumber_ in ('27.252.713','82.391.901')

		,stk as (
					select a.ItemNumber,sum(coalesce(a.QtyOnHand,0)) SOHVol 
					from JDE_DB_Alan.Master_ML345 a 
					--from m
					--where a.ItemNumber in ('24.7206.0000')
					--where a.ItemNumber in ('03.986.000')
					-- where a.ItemNumber in ('24.057.165s')   -- cannot find '24.057.165s' in ML345 file hence later table join will yield Null Value causing potential issue in coding - 29/1/18
					group by a.ItemNumber
					)					
		
		--- Get FCVol_23 ( is extracted from Fcst_History table ) --- you probably do not need for Forecast Accuracy Report purpose --- 25/5/2018
		,fc_Vol_ as  
			( select fh.DataType1,fh.ItemNumber,sum(isnull(fh.value,0)) as ItemLvlFCVol_23	
				from JDE_DB_Alan.FCPRO_Fcst_History fh					-- 22/1/2018 did not have  condition before --> where fct.DataType1 like ('%Adj_FC%')	
				  where fh.DataType1 like ('%Adj_FC%')			-- 26/2/2018
				        and convert(varchar(10),fh.ReportDate,120) = convert(varchar(10),dateadd(d,-1,DATEADD(mm, DATEDIFF(m,0,GETDATE()),0)),120)  ---Get data which is saved last last month - because every month you save FC exclude current month, say if you are in May, to get May forecast you need to go back to Reportdata of Apri but since your SQL Code's time function is quite unique ( look your code ) you do not use m-1 ! try run the code and see youself -- do not be fooled by parameters until you run the code and see it - 25/5/2018
                      --    and fh.Date = convert(varchar(10), DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),120)
				group by fh.DataType1,fh.ItemNumber
				)			
		
		--- Get saved forecast ( is extracted from Fcst_History table ) --- 25/5/2018
		,fc_Vol_lmth as  
			( select fh.DataType1,fh.ItemNumber,isnull(fh.value,0) as ItemLvlFCVol_lmth	
			         ,fh.Date,fh.ReportDate
				from JDE_DB_Alan.FCPRO_Fcst_History fh				-- 24/5/2018 did not have  condition before --> where fct.DataType1 like ('%Adj_FC%')	
				  where fh.DataType1 like ('%Adj_FC%')				-- 24/5/2018
				        	and convert(varchar(10),fh.ReportDate,120) = convert(varchar(10),dateadd(d,-1,DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0)),120)		---Get data which is saved last last month - because every month you save FC exclude current month, say if you are in May, to get May forecast you need to go back to Reportdata of Apri but since your SQL Code's time function is quite unique ( look your code ) you do not use m-1 ! try run the code and see youself -- do not be fooled by parameters until you run the code and see it - 25/5/2018
							and fh.Date = convert(varchar(10), DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),120)					--- Get last month FC and used it compared with History, in future need to use leadtime offset FC.  Say this month is June ( you are in June ) then, go back to fetch FC save in last day of May which is 31/5 ( which will have FC in May,in June, in July, in Aug etc), then you pick up May forecast and compared with History, in future you need to pick up May forecast saved 3 month earliery ( in Mar - depends on leadtime ) which is leadtime offset and compared with May Sales to get forecast accuracy. Also remember it is important to save forecast at last day of each month because 1) SQL code is based this date 2) it will save fc in the month you are in otherwise if you do it in June you will last May forecast ( the logic is in SQL code )
							--and fh.ItemNumber = '42.210.031'
				 )	
            --select * from JDE_DB_Alan.FCPRO_Fcst_History fh	where fh.ItemNumber in ('42.210.031') and fh.ReportDate = select dateadd(d,-1,DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0))
		  -- select * from fc_Vol where fc_Vol.ItemNumber in ('42.210.031')
		 --  select * from fc_Vol_lmth where fc_Vol_lmth.ItemNumber in ('42.210.031')
		  -- select convert(varchar(10), DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),120)
		  -- select  convert(varchar(10),dateadd(d,-1,DATEADD(mm, DATEDIFF(m,0,GETDATE()),0)),120)	
         ,fc_vol as ( select fc_Vol_lmth.DataType1,fc_Vol_lmth.ItemNumber,fc_Vol_lmth.ItemLvlFCVol_lmth,fc_Vol_.ItemLvlFCVol_23
		               from fc_Vol_lmth left  join fc_Vol_ on fc_Vol_lmth.ItemNumber = fc_Vol_.ItemNumber
					   )

		,fcVol as (	select fc_Vol.ItemNumber
						,fc_Vol.DataType1														
						,fc_vol.ItemLvlFCVol_lmth					
						,fc_Vol.ItemLvlFCVol_23	
						,fcprt.Pareto
						--,sum(f.value) FCVol_ttl_24
					--from JDE_DB_Alan.FCPRO_Fcst f 		
					from fc_Vol inner join JDE_DB_Alan.FCPRO_Fcst_Pareto fcprt on fc_Vol.DataType1 = fcprt.DataType1 and fc_Vol.ItemNumber = fcprt.ItemNumber
					
					where fc_Vol.DataType1 like ('%Adj_FC%')		--26/2/2018
					--where fc_Vol.DataType1 like ('%default%')
					--where f.DataType1 like ('%point%') 		
					--group by f.ItemNumber,f.DataType1
						)

				--select * from fcVol where fcvol.ItemNumber = '03.986.000'
				--where fcVol.ItemLvlFCVol_24 is null		-- where fc.ItemNumber = '18.615.024' --- fc about 10125 record

			   --- Item Level ----
		,comb_Vol as (select fc_Vol.ItemNumber,histy.SlsVol_TTL_12,histy.SlsVol_lmth,histy.Sls_Freq
								,stk.SOHVol
								,fc_vol.ItemLvlFCVol_lmth
								,fc_Vol.ItemLvlFCVol_23								
								,coalesce(stk.SOHVol/(nullif(fc_Vol.ItemLvlFCVol_23/24,0)),0) as SOHWksCover						--if divisor is 0						 
						from fc_Vol left join histy on fc_Vol.ItemNumber = histy.ItemNumber_
									left join stk on stk.ItemNumber = histy.ItemNumber_
						)
         --   select * from comb_Vol where comb_Vol.ItemNumber in ('42.210.031')
		-- select * from comb_vol  where comb_Vol.SOHWksCover is null
		-- where comb_vol.ItemNumber = ('03.986.000')

		,combVol as ( select comb_Vol.*,px.StandardCost as Cost,px.WholeSalePrice as Price
						from comb_Vol left join JDE_DB_Alan.Px_AWF_HD_MT_FCPro_upload px on comb_Vol.ItemNumber = px.ItemNumber
						)

		,pareto as ( select p.ItemNumber,p.rnk,p.DataType1,p.Pareto from JDE_DB_Alan.FCPRO_Fcst_Pareto p where p.DataType1 like ('%Adj_FC%')			--26/2/2018
						)

		,comb_Amt as ( select combVol.*,Pareto.Pareto,pareto.rnk,ss.SS_
							,combVol.SlsVol_ttl_12*combVol.price as SlsAmt_12
							,combVol.SlsVol_lmth * combVol.Price as SlsAmt_lmth
							,combVol.ItemLvlFCVol_23*combVol.price as FCAmt_23
							,combVol.SOHVol*combVol.cost as SOHAmt										 
							from combVol left join pareto on combVol.ItemNumber = pareto.ItemNumber
											left join JDE_DB_Alan.FCPRO_SafetyStock ss on combVol.ItemNumber = ss.ItemNumber
					)
          select * from  comb_Amt where comb_Amt.ItemNumber in ('42.210.031')
		 --select * from comb_Amt where comb_Amt.SlsAmt_12 is null or comb_Amt.FCAmt_24 is null or SOHAmt  is null

		,fl_ as ( select * 
							,sum(comb_Amt.SlsVol_TTL_12) over() as SlsVol_Grd
							,sum(comb_Amt.ItemLvlFCVol_23) over() as FCVol_Grd
							,sum(comb_Amt.SOHVol) over() as SOHVol_Grd
							,sum(comb_Amt.SlsAmt_12) over() as SlsAmt_Grd
							,sum(comb_Amt.FCAmt_23) over() as FCAmt_Grd
							,sum(comb_Amt.SOHAmt) over() as SOHAmt_Grd
						from comb_Amt)
           select * from fl_ where fl_.ItemNumber in ('42.210.031')


        --- Get Supplier name ---
		,_m as ( select a.ItemNumber
					,a.PrimarySupplier
					,case a.PlannerNumber when '20072' then 'Salman Saeed'
						when '20004' then 'Margaret Dost'	
						when '20005' then 'Imelda Chan'
						when '20071' then 'Domenic Cellucci'
						else 'Unknown'
					end as Owner_
					,a.Description
					,row_number() over(partition by a.itemnumber order by a.itemnumber) as rn 
				 from JDE_DB_Alan.Master_ML345 a)
		,m as ( select * 
				from _m where rn =1 )
        ,_fl as ( select fl_.*,m.PrimarySupplier,m.Owner_,m.Description from fl_ left join m on fl_.ItemNumber = m.ItemNumber) 

		select * from _fl
		 where _fl.ItemNumber in ('27.252.713','82.391.901','42.210.031')
			-- where fl_.ItemNumber like ('%85053100%')	
		-- where fl_.ItemNumber in ('7495500001')	
	  -- where fl_.ItemNumber in (2974000000'	
		-- where fl_.ItemNumber in ('24.057.165s')					-- cannot find '24.057.165s' in ML345 file hence later table join will yield Null Value causing potential issue in coding - 29/1/18
		  
		-- m.PrimarySupplier in ( select data from JDE_DB_Alan.dbo.Split(@Supplier_id,','))
		--	fl_.ItemNumber in ( select data from JDE_DB_Alan.dbo.Split(@Item_id,','))
	   --order by fl_.SlsAmt_12 desc
	   --  order by fl_.rnk
		--order by 			 
			--		case when @OrderByClause ='rnk' then _fl.rnk end,
			--		case when @OrderByClause ='SlsAmt_12' then _fl.SlsAmt_12 end desc,
			--		case when @OrderByClause ='SOHAmt' then _fl.SOHAmt end desc			
			
			
						 				 
	 
select * from JDE_DB_Alan.Px_AWF_HD_MT_FCPro_upload px where px.ItemNumber in ('24.023.165')	
-------------------------------- test To Update FC History 25/5/2018 -------------------------------------------
select convert(varchar(10),dateadd(d,-1,DATEADD(mm, DATEDIFF(m,0,GETDATE())-2,0)),120)        --- 2018-02-28
select convert(varchar(10),dateadd(d,-1,DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0)),120)        --- 2018-03-31
select convert(varchar(10),dateadd(d,-1,DATEADD(mm, DATEDIFF(m,0,GETDATE()),0)),120)        --- 2018-04-31
select convert(varchar(10), DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),120)							--2018-04-01
select * from JDE_DB_Alan.FCPRO_Fcst_History 
select distinct fh.DataType1 from JDE_DB_Alan.FCPRO_Fcst_History fh where convert(varchar(10),fh.ReportDate,120) = convert(varchar(10),dateadd(d,-1,DATEADD(mm, DATEDIFF(m,0,GETDATE()),0)),120)


--- change ( add more records ) to FC history table ---
insert into JDE_DB_Alan.FCPRO_Fcst_History 
select fh.ItemNumber,fh.DataType1,fh.Date,isnull(fh.value,0) as Value,'2018-03-31 15:00:00.000' as ReportDate
      -- ,fh.ReportDate as OriginalRP
	from JDE_DB_Alan.FCPRO_Fcst_History fh				-- 24/5/2018 did not have  condition before --> where fct.DataType1 like ('%Adj_FC%')	
		where fh.DataType1 like ('%Adj_FC%')				-- 24/5/2018
				and convert(varchar(10),fh.ReportDate,120) = convert(varchar(10),dateadd(d,-1,DATEADD(mm, DATEDIFF(m,0,GETDATE())-2,0)),120)		---Get data which is saved last last month - because every month you save FC exclude current month, say if you are in May, to get May forecast you need to go back to Reportdata of Apri but since your SQL Code's time function is quite unique ( look your code ) you do not use m-1 ! try run the code and see youself -- do not be fooled by parameters until you run the code and see it - 25/5/2018
				and fh.Date = convert(varchar(10), DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),120)					--- Get last month FC and used it compared with History, in future need to use leadtime offset FC.  Say this month is June ( you are in June ) then, go back to fetch FC save in last day of May which is 31/5 ( which will have FC in May,in June, in July, in Aug etc), then you pick up May forecast and compared with History, in future you need to pick up May forecast saved 3 month earliery ( in Mar - depends on leadtime ) which is leadtime offset and compared with May Sales to get forecast accuracy. Also remember it is important to save forecast at last day of each month because 1) SQL code is based this date 2) it will save fc in the month you are in otherwise if you do it in June you will last May forecast ( the logic is in SQL code )
				and fh.ItemNumber in ('42.210.031')


--- validate after change the records ( afer insert additional records into table )
select * from JDE_DB_Alan.FCPRO_Fcst_History fh
where fh.DataType1 like ('%Adj_FC%')
      and convert(varchar(10),fh.ReportDate,120) = convert(varchar(10),dateadd(d,-1,DATEADD(mm, DATEDIFF(m,0,GETDATE()),0)),120)
	  --and fh.Date = convert(varchar(10), DATEADD(mm, DATEDIFF(m,0,GETDATE()),0),120)
	  --and fh.ItemNumber in ('42.210.031')
	  --  and fh.ItemNumber in ('03.986.000')
order by fh.ItemNumber,fh.Date

--- delete test records --- be very careful when deleting data !
delete from JDE_DB_Alan.FCPRO_Fcst_History
where DataType1 like ('%Adj_FC%')
      and convert(varchar(10),ReportDate,120) = convert(varchar(10),dateadd(d,-1,DATEADD(mm, DATEDIFF(m,0,GETDATE()),0)),120)
	  and Date = convert(varchar(10), DATEADD(mm, DATEDIFF(m,0,GETDATE()),0),120)
	  and ItemNumber in ('42.210.031')


------------------------------
select * from JDE_DB_Alan.FCPRO_Fcst_History fh
where fh.DataType1 like ('%Adj_FC%')
      and convert(varchar(10),fh.ReportDate,120) = convert(varchar(10),dateadd(d,-1,DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0)),120)
	  --and fh.Date = convert(varchar(10), DATEADD(mm, DATEDIFF(m,0,GETDATE()),0),120)
	  and fh.ItemNumber in ('42.210.031')
order by fh.ItemNumber,fh.Date