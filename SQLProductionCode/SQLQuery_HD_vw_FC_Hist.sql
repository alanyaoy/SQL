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

/****** Object:  View [JDE_DB_Alan].[vw_Sls_History_HD]    Script Date: 1/12/2020 4:56:32 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER view  [JDE_DB_Alan].[vw_Sls_History_HD] with schemabinding as 	
	 
	 
	 ------- Create a Clean Sales History ----- 6/12/2019   
  
	  with  CalendarFrame as 
				(
				  select 1 as t,cast(DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,GETDATE())-35,0)) as datetime) as eom
				  union all
				  select t+1,dateadd(mm, 1, eom)
				  from CalendarFrame
				)
				,MonthlyCalendar as
				 (
				  select top 36 t,cast(replace(convert(varchar(8),[eom],126),'-','') as integer) [eom] 
				  from CalendarFrame
				 )

			   ,cldr as
				(select mc.t
					 ,left(mc.eom,6)  as eom_
				from MonthlyCalendar mc 
					--where left(mc.eom,4)=2015
					 where mc.eom> replace(convert(varchar(8), DATEADD(mm, DATEDIFF(m,0,GETDATE())-13,0),126),'-','')		--last 12 months
				)
		  -- select * from cldr

    	    ------------- Alan's New code for Calendar ------------------ 1/6/2018 -------------------------------
		  ,R(N,_T,T_,T,XX,YY,start) AS
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
			  -- select * from MthCal

				--select * from cldr
			  ,itm as ( select distinct h.ItemNumber as ItemNumber_ from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h )
			 -- ,list as ( select * from itm cross join cldr)			--- 24/7/2019
			  ,mylist as ( select i.ItemNumber_,c.month,c.month_name,c.rnk,c.StartDt,c.XX,c.year,c.YY   
							from itm i cross join MthCal c )			--- 25/7/2019
				--select * from list where list.ItemNumber_ in ('18.615.024')  order by list.ItemNumber_,list.eom_ 

				 -- Padded Item with all Months ---
			 ,hist as 
			  (  --select list.ItemNumber_,case when h.SalesQty is null then 0 else h.SalesQty end as SalesQty_,list.eom_,list.t
			     --from list left join JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h on list.eom_ = h.CYM and list.ItemNumber_ = h.ItemNumber
				   select mylist.ItemNumber_,case when h.SalesQty is null then 0 else h.SalesQty end as SalesQty_,mylist.StartDt as eom_,mylist.xx
				   from mylist left join JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h on mylist.StartDt = h.CYM and mylist.ItemNumber_ = h.ItemNumber
				   where mylist.rnk <25 and mylist.rnk >12													--- last 12 months in MthCal table
				--where list.ItemNumber in ('18.615.024') 		
			   )
			 -- select * from hist 
			 -- where hist.ItemNumber_ in ('42.210.031')

		,histy as 
			( select x.ItemNumber_
			,count(isnull(x.eom_,0)) TTL_SlsMths			-- Or you can use --> count(isnull(x.StartDt2,0)) TTL_SlsMths
			,sum( case when x.SalesQty_ <>0 then 1 else 0 end ) as Sls_freq
			,sum(x.SalesQty_) SlsVol_TTL_12 
			,max(x.eom_) as SlsMth_latest
			from hist x 
			group by x.ItemNumber_)

		select h.ItemNumber_,h.Sls_freq,h.SlsVol_TTL_12,h.TTL_SlsMths,h.SlsMth_latest
		from histy h 
		--where h.ItemNumber_ in ('42.210.031','44.011.007')
		--order by h.SlsVol_TTL_12 desc
		
		
GO


