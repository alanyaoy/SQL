--use JDE_DB_Alan
--go

--======================================
--- FC Accuracy Final --- 25/5/2018
---======================================


	 --- Peter's Old Code ---
	--;with CalendarFrame as (
	--				select -24 as t,1 as n,cast(DATEADD(mm, DATEDIFF(mm, 0, GETDATE())-24, 0) as datetime) as start
	--					select 1 as t,1 as n,cast(DATEADD(mm, DATEDIFF(mm, 0, GETDATE())-24, 0) as datetime) as start
	--				union all
	--				select case when t +1 >24 then 1 else t+1 end ,case when n=12 then 1 else n+1 end,dateadd(mm, 1, start)
	--				 select t+1 ,case when n=12 then 1 else n+1 end,dateadd(mm, 1, start)
	--				from CalendarFrame
	--				where t<50
				
	--			)
	--			select  top 50 * from CalendarFrame
	--		 ,MonthlyCalendar as
	--				(
	--				select top 48 t, RIGHT('00'+CAST(n AS VARCHAR(3)),2) nmb,cast(SUBSTRING(REPLACE(CONVERT(char(10),start,126),'-',''),1,6) as integer) as [StartDate],
	--				DATENAME(mm,start) MnthName,DATENAME(yyyy,start) YearName from CalendarFrame
	--			)
		
		--select top 50 * from MonthlyCalendar


----=========================== Start of CTE Try ====================================================================================================================
  ---------------  CTE Try 1 ------------------------------------------------------------------------------------------
 ----- Last 12 month-----

 ------ Get past 12 month and future 12 month -- below is my work draft - 28/5/2018
;WITH R(N,_T,T_,T,X,X2,XX,YY,start) AS
	(
	 select 1 as N,-24 as _T,24 as T_,-23 as T,24 as X,24 as X2
			,24 as XX,24 as YY,cast(DATEADD(mm, DATEDIFF(mm, 0, GETDATE())-24, 0) as datetime) as start
	 UNION ALL
	 select  N+1, _T+1,T_-1,case when T+1<0 then T+1 else case when T+1 =0 then 1 else T+1 end end as T	
							,case when X-1 >= 0  then X-1			-- this algorithm is complicated
							   else  					   
								      case when X > 1 then X+1
										 else X+ 1  
                                      end
								end as X
                             
                            ,case when N >= 24  then _T+1			-- this is simple algorithm because use N 
							   else  					   
								     X
								end as X2

                            ,case when N >= 24  then _T+1
							   else  					   
								     X-1
								end as XX
                           ,case when N >= 24  then T							     
							   else  
							       YY-1
								end as YY
			 ,dateadd(mm,1,start)
	  from R
	 where N < 49
	)
select * from r
select R.N,case when R._T < 0 then R.T_ else R._T end as T, start  
----------------- Below is production code----------------------------------------------------

;WITH R(N,_T,T_,T,XX,YY,start) AS
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
select * from r
--select R.N,case when R._T < 0 then R.T_ else R._T end as T, start  
--from R

------------------------------
;WITH R(N) AS
(
SELECT 0
UNION ALL
SELECT N+1 
FROM R
WHERE N < 12
)
SELECT  n as rnk
		,LEFT(datename(month,dateadd(month,N,GETDATE())),3) AS [month_name]
        ,datepart(month,dateadd(month,-N,GETDATE())) AS [month]
        ,datepart(year,dateadd(month,-N,GETDATE())) AS [year]		
FROM R
order by rnk desc


 ---------------  CTE Try 2 ---------------------------------------------------------------------------------------------------------
  ------------- Alan's New code ------------------ 29/5/2018 -------------------------------------------------------------------
	 ;WITH R(N,_T,T_,T,XX,YY,start) AS
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
						 ,YY 
						,cast(SUBSTRING(REPLACE(CONVERT(char(10),start,126),'-',''),1,6) as integer) as [StartDt]		
						,LEFT(datename(month,start),3) AS [month_name]
						,datepart(month,start) AS [month]
						,datepart(year,start) AS [year]				
				       from R  )
     -- select * from MthCal

------------------ CTE Try 3 ----------------------------------------------------------------
------------- Alan's New code ------------------ 29/5/2018 -------------------------------------------------------------------
	 ;WITH R(N,_T,T_,T,XX,YY,start) AS
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
						 ,YY 
						,cast(SUBSTRING(REPLACE(CONVERT(char(10),start,126),'-',''),1,6) as integer) as [StartDt]		
						,LEFT(datename(month,start),3) AS [month_name]
						,datepart(month,start) AS [month]
						,datepart(year,start) AS [year]				
				       from R  )
     -- select * from MthCal

----------------------- CTE Try 4 ---------------------------------------------------------------
	 ------------- Alan's New code ------------------ 29/5/2018 -------------------------------------------------------------------
	 ;WITH R(N,_T,T_,T,XX,YY,start) AS
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
						 ,YY 
						,cast(SUBSTRING(REPLACE(CONVERT(char(10),start,126),'-',''),1,6) as integer) as [StartDt]		
						,LEFT(datename(month,start),3) AS [month_name]
						,datepart(month,start) AS [month]
						,datepart(year,start) AS [year]				
				       from R  )
     -- select * from MthCal
----=========================== End of CTE Try =====================================================================================


---*************************************************************************************************************************-----------------------

	 ---------- Alan's New code  Draft ( too much table involved )------------------
	 ;WITH R(N,_T,T_,T,XX,YY,start) AS
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
		  ,MonthlyCalendar as (
						select  n as rnk
						 ,YY 
						,cast(SUBSTRING(REPLACE(CONVERT(char(10),start,126),'-',''),1,6) as integer) as [StartDate]		
						,LEFT(datename(month,start),3) AS [month_name]
						,datepart(month,start) AS [month]
						,datepart(year,start) AS [year]				
				       from R  )

           --select * from MonthlyCalendar
		,itm as ( select distinct h.ItemNumber as ItemNumber_ from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h )
		,list as ( select * from itm cross join MonthlyCalendar cldr 
					where StartDate between replace(convert(varchar(8), DATEADD(mm, DATEDIFF(m,0,GETDATE())-12,0),126),'-','' )			-- last 12 months		
											 and  replace(convert(varchar(8), DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-','' )		-- last 12 months
				  )		     
		-- Padded Item with all Months ---
		,_hist as 
		(  select list.ItemNumber_ ,case when h.SalesQty is null then 0 else h.SalesQty end as SalesQty_
				,list.StartDate as CYM,list.rnk as t
			from list left join JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h on list.StartDate = h.CYM and list.ItemNumber_ = h.ItemNumber
		--where list.ItemNumber in ('18.615.024') 		
		)
	  --select * from _hist where _hist.ItemNumber_ in ('27.252.713')
	   
	   ----- Get last month sales history ------ 25/5/2018 -- rather using rnk to get last month sales you can use datetime function to pick last month sales -- 28/5/2018  --- do not overcomplicate
	   ,_hist_lmth as ( select l.ItemNumber_,l.SalesQty_,l.CYM,l.t, ROW_NUMBER() over(partition by l.ItemNumber_ order by l.t desc) maxrnk
						from _hist l )  
      --  select * from _hist_lmth h where h.ItemNumber_ in ('27.252.713')

       ,hist_lmth as ( select * 
						from _hist_lmth
						where _hist_lmth.maxrnk =1							
					 )

	   ,hist as ( select _hist.ItemNumber_,_hist.SalesQty_,_hist.CYM,_hist.t,hist_lmth.maxrnk,hist_lmth.SalesQty_ as Sale_lmth
						from _hist left join hist_lmth
						             on  _hist.ItemNumber_ = hist_lmth.ItemNumber_ 
					)

		,histy as 
			( select x.ItemNumber_
			,count(isnull(x.CYM,0)) TTL_Mths
			,sum( case when salesqty_ >0 then 1 else 0 end ) as Sls_freq
			,sum(x.SalesQty_) SlsVol_TTL_12 
			,avg(x.Sale_lmth) SlsVol_lmth
			from hist x 
			group by x.ItemNumber_)
		--select * from histy where histy.ItemNumber_ in ('27.252.713','82.391.901')
	
		
		--- Get saved forecast ( is extracted from Fcst_History table ) --- 25/5/2018
		,fc_Vol_lmth as  
			( select fh.DataType1,fh.ItemNumber,isnull(fh.value,0) as ItemLvlFCVol_lmth	
			         ,fh.Date,fh.ReportDate
				from JDE_DB_Alan.FCPRO_Fcst_History fh				-- 24/5/2018 did not have  condition before --> where fct.DataType1 like ('%Adj_FC%')	
				         
				  where fh.DataType1 like ('%Adj_FC%')				-- 24/5/2018
				        	--and convert(varchar(10),fh.ReportDate,120) = convert(varchar(10),dateadd(d,-1,DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0)),120)		---Get data which is saved last last month - because every month you save FC exclude current month, say if you are in May, to get May forecast you need to go back to Reportdata of Apri but since your SQL Code's time function is quite unique ( look your code ) you do not use m-1 ! try run the code and see youself -- do not be fooled by parameters until you run the code and see it - 25/5/2018
							--and fh.Date = select convert(varchar(10), DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),120)				--2018-04-01	--- Get last month FC and used it compared with History, in future need to use leadtime offset FC.  Say this month is June ( you are in June ) then, go back to fetch FC save in last day of May which is 31/5 ( which will have FC in May,in June, in July, in Aug etc), then you pick up May forecast and compared with History, in future you need to pick up May forecast saved 3 month earliery ( in Mar - depends on leadtime ) which is leadtime offset and compared with May Sales to get forecast accuracy. Also remember it is important to save forecast at last day of each month because 1) SQL code is based this date 2) it will save fc in the month you are in otherwise if you do it in June you will last May forecast ( the logic is in SQL code )
							and fh.ReportDate = '2018-03-31 15:00:00.000'
							and fh.Date = '2018-04-01 00:00:00.000'

							--and fh.ItemNumber = '42.210.031'
				 )	
        ,fc_vol as ( select * from fc_Vol_lmth )

		,fcVol as (	select fc_Vol.ItemNumber
						,fc_Vol.DataType1														
						,fc_vol.ItemLvlFCVol_lmth				
						,fcprt.Pareto	
						,fc_vol.Date
						,fc_vol.ReportDate									
					from fc_Vol left join JDE_DB_Alan.FCPRO_Fcst_Pareto fcprt on fc_Vol.DataType1 = fcprt.DataType1 and fc_Vol.ItemNumber = fcprt.ItemNumber					
					where fc_Vol.DataType1 like ('%Adj_FC%')		--26/2/2018		
						)

			   --- Item Level ----
		,comb_Vol as (select fc_Vol.ItemNumber					
								,fc_vol.ItemLvlFCVol_lmth
								,fc_vol.Date
								,fc_vol.ReportDate
								,histy.SlsVol_lmth
								,histy.Sls_Freq,histy.SlsVol_TTL_12																						 
						from fc_Vol left join histy on fc_Vol.ItemNumber = histy.ItemNumber_									
						)

        --    select * from comb_Vol where comb_Vol.ItemNumber in ('42.210.031')
		-- select * from comb_vol  where comb_Vol.SOHWksCover is null
		-- where comb_vol.ItemNumber = ('03.986.000')

		,combVol as ( select comb_Vol.*,px.StandardCost as Cost,px.WholeSalePrice as Price
						from comb_Vol left join JDE_DB_Alan.Px_AWF_HD_MT_FCPro_upload px on comb_Vol.ItemNumber = px.ItemNumber
						)

		,pareto as ( select p.ItemNumber,p.rnk,p.DataType1,p.Pareto from JDE_DB_Alan.FCPRO_Fcst_Pareto p where p.DataType1 like ('%Adj_FC%')			--26/2/2018
						)

		,comb_Amt as ( select combVol.*						
							,combVol.SlsVol_lmth * combVol.Price as SlsAmt_lmth
							,combVol.ItemLvlFCVol_lmth * combVol.Price as FCAmt_lmth												 
							,Pareto.Pareto,pareto.rnk	
							from combVol left join pareto on combVol.ItemNumber = pareto.ItemNumber
										
					)
         -- select * from  comb_Amt 
		  --option (maxrecursion 0)
		  --where comb_Amt.ItemNumber in ('42.210.031')
		 --select * from comb_Amt where comb_Amt.SlsAmt_12 is null or comb_Amt.FCAmt_24 is null or SOHAmt  is null

		 ,fl_ as ( select * from comb_Amt)

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
		 --where _fl.ItemNumber in ('27.252.713')
		-- where _fl.ItemNumber in ('82.391.901')
		 --where _fl.ItemNumber in ('27.252.713','82.391.901','42.210.031')
		--where _fl.Price is null
		 --option (maxrecursion 0)
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
	 


	 -------
	 use JDE_DB_Alan
	 go

	 select distinct fch.ItemNumber from JDE_DB_Alan.FCPRO_Fcst_History fch  where fch.ReportDate = '2018-02-28 15:00:00.000' and fch.Date = '2018-04-01 00:00:00.000'
	     --where --fch.ReportDate = select dateadd(d,-1,DATEADD(mm, DATEDIFF(m,0,GETDATE())-2,0)) and	    --2018-02-28 00:00:00.000
			   --fch.ItemNumber in ('42.210.031') and fch.ReportDate = '2018-02-28 15:00:00.000'
	  select * from JDE_DB_Alan.vw_Mast m where m.ItemNumber in ('42.210.031')
	  select * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h where h.ItemNumber in ('42.210.031')


	----------------- Alan's New code ------------------ 1/6/2018 -------------------------------------------------------------------
	 ;WITH R(N,_T,T_,T,XX,YY,start) AS
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
						 ,YY 
						,cast(SUBSTRING(REPLACE(CONVERT(char(10),start,126),'-',''),1,6) as integer) as [StartDt]		
						,LEFT(datename(month,start),3) AS [month_name]
						,datepart(month,start) AS [month]
						,datepart(year,start) AS [year]				
				       from R  )
     -- select * from MthCal
	 ,f as ( select fch.*
					,cast(SUBSTRING(REPLACE(CONVERT(char(10),fch.ReportDate,126),'-',''),1,6) as integer) as [StartDate]						
			  from JDE_DB_Alan.FCPRO_Fcst_History fch
					-- where h.ItemNumber in ('42.210.031')
					)
	  ,fc as ( select f.ItemNumber as Itm,f.DataType1,f.Date,f.StartDate,f.Value,f.ReportDate,c.*							--- join cal to get YY value which is your month rank/order
				    
				from f left join MthCal c on f.StartDate = c.StartDt												--- no need to cross join cal table as FC tb always has data in 24 mth				
			  -- where fc.ItemNumber = ('42.210.031') order by fc.ItemNumber,fc.StartDt,fc.Date
	            )
       
	   ------------------------------------      
		--- LT offset FC ---
      ,fct as ( -- select *
	            select fc.Itm,fc.DataType1,fc.Date,fc.StartDt,fc.Value,fc.ReportDate,fc.YY,fc.rnk,fc.month				 -- inner join --- so remove all records which does not meet condition - In another words I am only interested and only want SKU that has 3 month lead time. Of course you can use Left join to achiece same result, if you use inner join it is important to include all records of Master data in vw_Mast table though, otherwise you will lose some data --- 30/5/2018
	            from fc inner join JDE_DB_Alan.vw_Mast m on fc.Itm = m.ItemNumber and fc.YY= m.Leadtime_Mth+1			-- LT calculation: LT plus 1 month since FC was saved last day of month - if 2 month then need to consider 60 days, 3 month need to consider 90 days
				where fc.Date =  DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0)											-- get monthly fc in this case --> FC of '2018-04-01' this is FC you want to measure
				       --and fc.Date =  '2018-04-01 00:00:00.000'	
				)	
							
		  --- Non LT offset FC ---
      ,fctt as ( -- select *
	            select fc.Itm,fc.DataType1,fc.Date,fc.StartDt,fc.Value,fc.ReportDate,fc.YY,fc.rnk,fc.month				 -- inner join
	            from fc 																							  --- No Need to use Join you simply fetch last month FC
				where    fc.StartDt	 = cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-2,0),126),'-',''),1,6) as integer)  	--LT calculation: Capped to 2 mth ago, since last month you will have FC only for next month   --- '201803'   -- Performance issue ?
						  --and fc.StartDt = '201803'																									-- hard coded LT			
						  --and fc.YY = 2 and fc.rnk = 23																		-- 	Capped to 2 mth ago	
						  and fc.Date = DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0)											-- get monthly fc in this case --> FC of '2018-04-01' this is FC you want to measure
							--and fc.Date =  '2018-04-01 00:00:00.000'	
					)			
										
	    --select * from fctt  where fct.Itm in ('82.501.904','42.210.031')
		--select * from fctt  where fctt.Itm in ('42.210.031')			

	  ------- Last Month Histry --- If you are in May, Need April History ( compared with April FC though) ,Not May History !  --------------

		  		----- below is tb NOT padded with 0 sales history --- straight from SlsHist tb
		,histt as ( select h.ItemNumber,h.CYM,h.CY,h.Month,h.SalesQty,h.ReportDate
							,c.YY,c.rnk,c.StartDt,c.month as mth
	               from  JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h left join MthCal c on h.CYM = c.StartDt	
				   where     h.CYM = cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-',''),1,6) as integer)			-- Performance issue ?
				           -- h.CYM = '201804' and
				           --c.rnk =24						--- last month ( for last month Sales)
				   )

		,SlsItm as ( select distinct h.ItemNumber as ItemNumber_ from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h )
		,SlsList as ( select * from SlsItm cross join MthCal c 
					 -- where   c.StartDt between replace(convert(varchar(8), DATEADD(mm, DATEDIFF(m,0,GETDATE())-12,0),126),'-','' )			-- last 12 months		
					  --				 and  replace(convert(varchar(8), DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-','' )		   -- last 12 months
							)		     
			
		     ----- below is tb padded Item with all Months ---
		,hist as																													
		(  select list.ItemNumber_,h.CYM,h.CY,h.Month
					,case when h.SalesQty is null then 0 else h.SalesQty end as SalesQty,h.ReportDate
			       ,list.YY,list.rnk,list.StartDt,list.month as mth
				  ,case 
						when h.CYM is null	then cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-',''),1,6) as integer) 
						else h.CYM
					end as CYM_
			from SlsList list left join JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h on list.StartDt = h.CYM and  list.ItemNumber_ = h.ItemNumber
			where    list.StartDt = cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-',''),1,6) as integer)			-- Watch out use List.StartDt Not h.CYM !!!   --- 29/5/2018
					-- h.CYM = '201804' and																													-- Performance issue ?
					--c.rnk =24																												-- last month ( for last month Sales)
				)
          -- select * from hist where hist.ItemNumber_ in ('82.501.904')

		   --- **************************************
		   --- Accuracy use Non-Lead Time offset
		   --- **************************************
		  ,comVoll_ as 
		   ( select 'Units' as DataType,fctt.Itm,hist.ItemNumber_,hist.SalesQty as Sales,fctt.Value as Fcst,fctt.StartDt
		            ,SalesQty - fctt.Value as Bias,ABS(SalesQty -  fctt.Value) as ABS
		       from fctt full outer join hist on fctt.Itm = hist.ItemNumber_)		
			   
			 -- select * from comVol_ c where c.ItemNumber_ in ('TUFA20') 				   				           
	     ,_comVoll as 
		   ( select 'Units' as DataType
					,case when fctt.Itm is null then hist.ItemNumber_ else fctt.Itm end as Item					
					,isnull(hist.SalesQty,0) as Sales,isnull(fctt.Value,0) as Fcst
					,fctt.Date
					,case when fctt.Date is null then DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0) else fctt.Date end as Date_				--- 
					,fctt.StartDt
		            ,isnull((SalesQty - fctt.Value),0)as BiasVol,isnull(ABS(SalesQty -  fctt.Value),0) as ABSVol
					,coalesce(isnull(abs(SalesQty - fctt.Value),0)/nullif(hist.SalesQty,0),0) as ErrPct
					,1-(coalesce(isnull(abs(SalesQty - fctt.Value),0)/nullif(hist.SalesQty,0),0)) as AccuracyPct
		       from fctt full outer join hist on fctt.Itm = hist.ItemNumber_
			   )
            
         ,zeroo as ( select * from _comVoll where _comVoll.Fcst =0 and _comVoll.Sales=0)
		--select * from zero		
		,comVoll as (   select * from _comVoll 
						-- where _comVoll.Item not in ( select zeroo.Item from zeroo )					  --- works but not ideal usijng 'Not in'   -1/6/2018
						 where not exists ( select zeroo.Item from zeroo where zeroo.Item = _comVoll.Item)   -- better using 'Not exists' --- https://stackoverflow.com/questions/1662902/when-to-use-except-as-opposed-to-not-exists-in-transact-sql --  Also note ,if any row of that subquery returns NULL, the entire NOT IN operator will evaluate to either FALSE or UNKNOWN and no records will be returned
		             --  where comVol.Item in ('82.501.904')

			          )
         ,f_comVoll as ( select c.*,m.Description,m.Family_0,m.FamilyGroup_
								,m.WholeSalePrice
								,c.Sales*m.WholeSalePrice as SlsAmt
								,c.Fcst*m.WholeSalePrice  as FcstAmt
								,BiasVol * m.WholeSalePrice as Bias_Amt
								,ABSVol * m.WholeSalePrice as ABS_Amt
								,coalesce((ABSVol * m.WholeSalePrice)/nullif(c.Sales*m.WholeSalePrice,0),0) as ErrPct_Amt
								,1-(coalesce((ABSVol * m.WholeSalePrice)/nullif(c.Sales*m.WholeSalePrice,0),0)) as AccuracyPct_Amt
								,m.PrimarySupplier,m.PlannerNumber
		                 from _comVoll c left join JDE_DB_Alan.vw_Mast m on c.Item = m.ItemNumber )
           -- select * from f_comVoll

         ,combb as ( select fl.DataType,fl.Item,fl.Sales,fl.Fcst,fl.Date_,fl.StartDt,fl.BiasVol as Bias,fl.ABSVol as ABS_,fl.ErrPct,fl.AccuracyPct,fl.Description,fl.Family_0,fl.FamilyGroup_,fl.PrimarySupplier,fl.PlannerNumber
						from f_comVoll fl
                    union all
					select 'Dollars' as DataType,fl.Item,fl.SlsAmt,fl.FcstAmt,fl.Date_,fl.StartDt,fl.Bias_Amt as Bias,fl.ABS_Amt as ABS_,fl.ErrPct_Amt,fl.AccuracyPct_Amt,fl.Description,fl.Family_0,fl.FamilyGroup_,fl.PrimarySupplier,fl.PlannerNumber  
					   from f_comVoll fl
		           )

         --select * from combb
		   --- **************************************
		   --- Accuracy use Lead Time offset
		   --- **************************************

		  	,comVol_ as 
		   ( select 'Units' as DataType,fct.Itm,hist.ItemNumber_,hist.SalesQty as Sales,fct.Value as Fcst,fct.StartDt
		            ,SalesQty - fct.Value as Bias,ABS(SalesQty -  fct.Value) as ABS
		       from fct full outer join hist on fct.Itm = hist.ItemNumber_)		
			   
			-- select * from comVol_ c where c.ItemNumber_ in ('18.317.005') 				   				           
	      ,_comVol as 
		   ( select 'Units' as DataType
					,case when fct.Itm is null then hist.ItemNumber_ else fct.Itm end as Item					
					,isnull(hist.SalesQty,0) as Sales,isnull(fct.Value,0) as Fcst
					,fct.Date,case when fct.Date is null then DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0) else fct.Date end as Date_
					,fct.StartDt
		            ,isnull((SalesQty - fct.Value),0)as BiasVol,isnull(ABS(SalesQty -  fct.Value),0) as ABSVol
					,coalesce(isnull(abs(SalesQty - fct.Value),0)/nullif(hist.SalesQty,0),0) as ErrPct
					,1-(coalesce(isnull(abs(SalesQty - fct.Value),0)/nullif(hist.SalesQty,0),0)) as AccuracyPct
		       from fct full outer join hist on fct.Itm = hist.ItemNumber_
			   )
			   	
		,zero as ( select * from _comVol where _comVol.Fcst =0 and _comVol.Sales=0)
		--select * from zero		
		,comVol as ( select * from _comVol 
						-- where _comVol.Item not in ( select zero.Item from zero )					  --- works but not ideal usijng 'Not in'   -1/6/2018
						 where not exists ( select zero.Item from zero where zero.Item = _comVol.Item)   -- better using 'Not exists' --- https://stackoverflow.com/questions/1662902/when-to-use-except-as-opposed-to-not-exists-in-transact-sql -- Also note ,if any row of that subquery returns NULL, the entire NOT IN operator will evaluate to either FALSE or UNKNOWN and no records will be returned
		             --  where comVol.Item in ('82.501.904')
				
			          )
         ,f_comVol as ( select c.*,m.Description,m.Family_0,m.FamilyGroup_
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

         ,comb as ( select fl.DataType,fl.Item,fl.Sales,fl.Fcst,fl.Date_,fl.StartDt,fl.BiasVol as Bias,fl.ABSVol as ABS_,fl.ErrPct,fl.AccuracyPct,fl.Description,fl.Family_0,fl.FamilyGroup_,fl.PrimarySupplier,fl.PlannerNumber,getdate() as ReportDate
						from f_comVol fl
                    union all
					select 'Dollars' as DataType,fl.Item,fl.SlsAmt,fl.FcstAmt,fl.Date_,fl.StartDt,fl.Bias_Amt as Bias,fl.ABS_Amt as ABS_,fl.ErrPct_Amt,fl.AccuracyPct_Amt,fl.Description,fl.Family_0,fl.FamilyGroup_,fl.PrimarySupplier,fl.PlannerNumber,getdate() as ReportDate  
					   from f_comVol fl
		           )
          
		  --select * from combb
       		insert into JDE_DB_Alan.FCPRO_Fcst_Accuracy  select * from comb
			select * from JDE_DB_Alan.FCPRO_Fcst_Accuracy

