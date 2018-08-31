use JDE_DB_Alan
go


 ---=========================================================================================================
 ---  This is Final Version Safety Stock Calculation --- 11/1/2018 - Works Yeah !
 ---=========================================================================================================

--- Get Your Calendar --- it will calculate Safety stock using Demand History of past rolling 12 ( or whatever months you want ) months ---
--- it will padded with each item in case if they do not have sales in a particular months so that you wont miss sales and division is correct ( 12 ) ---
--- SS = stdevp x sqrt of leadtime x Z-score ---

delete from JDE_DB_Alan.FCPRO_SafetyStock

;with  CalendarFrame as 
	(
	  select 1 as t,cast(DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,GETDATE())-35,0)) as datetime) as eom
	  union all
	  select t+1,dateadd(mm, 1, eom)
	  from CalendarFrame
	),
	MonthlyCalendar as
	 (
	  select top 36 t,cast(replace(convert(varchar(8),[eom],126),'-','') as integer) [eom] 
	  from CalendarFrame
	 ),

   cldr as
	(select mc.t
		 ,left(mc.eom,6)  as eom_
	from MonthlyCalendar mc 
		--where left(mc.eom,4)=2015
		 where mc.eom> replace(convert(varchar(8), DATEADD(mm, DATEDIFF(m,0,GETDATE())-13,0),126),'-','')		--last 12 months
	),
	--select * from cldr
  itm as ( select distinct h.ItemNumber as ItemNumber_ from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h ),
  list as ( select * from itm cross join cldr),
	--select * from list where list.ItemNumber in ('18.615.024')  order by list.ItemNumber,list.eom_ 

	 -- padded Item with all Months ---
 hist as 
  (  select list.ItemNumber_,case when h.SalesQty is null then 0 else h.SalesQty end as SalesQty_,list.eom_,list.t
	from list left join JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h on list.eom_ = h.CYM and list.ItemNumber_ = h.ItemNumber
	--where list.ItemNumber in ('18.615.024') 		
   ),
  -- select * from hist 
  -- where hist.ItemNumber in ('18.615.024')
  -- order by hist.eom_

  stdv_ as ( 
			select hist.ItemNumber_ 
			,avg(hist.salesqty_) as Avg_Itm
			,sum(hist.salesqty_) as TTL_Itm
			,sum( case when salesqty_ >0 then 1 else 0 end ) as Num_ItmSls		-- count numb of month that has positive sales
			,count(hist.salesqty_) as TTL_ItmSlsMth			
			,STDEVP(salesqty_) as Stdevp_Item
			from hist
			group by hist.ItemNumber_ ),
  --select * from stdv where stdv.ItemNumber in ('18.615.024')

   --- Get Your Pareto & Z-Score (Service Level )--
  parto as ( select * 
			from JDE_DB_Alan.FCPRO_Fcst_Pareto p left join stdv_ on p.ItemNumber = stdv_.ItemNumber_
						     
		   ),
  
  parto_ as ( select parto.ItemNumber,parto.Stdevp_Item,parto.TTL_Itm,parto.Pareto
			,case parto.Pareto 
					when 'A'  then 2.33			-- 99%		
					when 'B'  then 1.65			-- 95%		-- 2.05 98%
					when 'C'  then 1            --85%
              end as Z        
			from parto 
			--where comb.ItemNumber in ('18.615.024')
         ),  
  --select *, parto_.Stdevp_Item * parto_.Z as SS from parto_
  --where parto_.ItemNumber in ('18.615.024')

  --- Get your Leadtime ---
  ldtm as (
		select m.ItemNumber as Item_Number,m.LeadtimeLevel
			,row_number() over(partition by m.itemNumber order by m.itemNumber ) rn  
			from JDE_DB_Alan.Master_ML345 m
		),
  ldtm_ as (
		select * from ldtm
		where rn = 1 ),

  comb as 
	( select *,parto_.Stdevp_Item* SQRT(ldtm_.leadtimeLevel/4.33)*parto_.Z as SS
		from parto_ left join ldtm_ on parto_.ItemNumber = ldtm_.Item_Number
		 --where parto_.ItemNumber in ('18.615.024')
    ),

   fltb as (
	 select comb.ItemNumber,comb.TTL_Itm,comb.Pareto,comb.LeadtimeLevel,comb.rn,comb.ss as SS_,GETDATE() as ReportDate
    from comb
    --  where comb.ItemNumber in ('18.615.024','26.803.676','34.307.000','52.417.905','24.043.165S')
     )
   --select * from fltb

   insert into JDE_DB_Alan.FCPRO_SafetyStock select * from fltb