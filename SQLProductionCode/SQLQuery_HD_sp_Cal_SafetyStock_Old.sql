/*    ==Scripting Parameters==

    Source Server Version : SQL Server 2016 (13.0.4001)
    Source Database Engine Edition : Microsoft SQL Server Express Edition
    Source Database Engine Type : Standalone SQL Server

    Target Server Version : SQL Server 2017
    Target Database Engine Edition : Microsoft SQL Server Standard Edition
    Target Database Engine Type : Standalone SQL Server
*/

USE [JDE_DB_Alan]
GO
/****** Object:  StoredProcedure [JDE_DB_Alan].[sp_Cal_SafetyStock]    Script Date: 4/03/2019 3:54:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [JDE_DB_Alan].[sp_Cal_SafetyStock]  
	
	--- Note for this Store Procedure You can only pass 1 ItemNumber, or 1 SupplierNumber one time , cannot do mulitple value, if it is required, use more Versatile version of SQL Code in Master COde file  14/128/2017
     -- @ItemNumber varchar(3500)=null,   
	--  @SupplierNumber varchar(100)=null    
	--@ShortItemNumber varchar(100) = null,
	--@CenturyYearMonth int = null
AS

BEGIN   

    -- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
  
	--- if  donot specify details, Export ALL FC from FC PRo ---
	--IF @ItemNumber is NULL and @SupplierNumber is null
    
			 ---=========================================================================================================
			 --- Safety Stock Calculation ---  This is Final Version  --- 11/1/2018 - Works Yeah !
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
				--select * from cldr
			  ,itm as ( select distinct h.ItemNumber as ItemNumber_ from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h )
			  ,list as ( select * from itm cross join cldr)
				--select * from list where list.ItemNumber in ('18.615.024')  order by list.ItemNumber,list.eom_ 

				 -- Padded Item with all Months ---
			 ,hist as 
			  (  select list.ItemNumber_,case when h.SalesQty is null then 0 else h.SalesQty end as SalesQty_,list.eom_,list.t
				from list left join JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h on list.eom_ = h.CYM and list.ItemNumber_ = h.ItemNumber
				--where list.ItemNumber in ('18.615.024') 		
			   )
			  -- select * from hist 
			  -- where hist.ItemNumber in ('18.615.024')
			  -- order by hist.eom_

			  ,stdv_ as ( 
						select hist.ItemNumber_ 
						,sum(hist.salesqty_)/count(hist.eom_) as Avg_Itm					-- Be careful , some month doesnot have sales, so affect avg
						,sum(hist.salesqty_) as TTL_Itm
						,sum( case when salesqty_ >0 then 1 else 0 end ) as Num_ItmSls		-- count numb of month that has positive sales
						,count(hist.eom_) as TTL_ItmSlsMth			
						,STDEVP(salesqty_) as Stdevp_Item
						from hist
						group by hist.ItemNumber_ )
               --  select * from stdv_ where stdv_.ItemNumber_ in ('45.124.000') 
			 --  select * from stdv_ where stdv_.ItemNumber_ in ('45.648.100')   
			  --select * from stdv_ where stdv_.ItemNumber_ in ('18.615.024')
			   --select * from stdv_ where stdv_.ItemNumber_ in ('2974000000','24.7206.0000')
			   -- select * from stdv_ where stdv_.ItemNumber_ in ('7501001000')

			   --- Get Your Pareto & Z-Score (Service Level )--
			  ,parto as ( select * 
						from JDE_DB_Alan.FCPRO_Fcst_Pareto p left join stdv_ on p.ItemNumber = stdv_.ItemNumber_
						     
					   )
  
			  ,parto_ as ( select parto.ItemNumber,parto.Stdevp_Item,parto.TTL_Itm,parto.Pareto
						,case parto.Pareto 
								when 'A'  then 2.05			-- 98%		-- 2.58 99.50%  -- 2.88 99.80%   -- 3.09 99.90%  -- 3.72 99.99%			-- 16/2/2018
								when 'B'  then 1.88			-- 97%		-- 2.33 99%  --2.05 98%  -- 1.88 97%  -- 1.75 96%
								when 'C'  then 1.65           --95%

							--when 'A'  then 2.33			-- 99%		-- 15/2/2018
							--when 'B'  then 1.65			-- 95%		
							--when 'C'  then 1.65           --95%
						  end as Z        
						from parto 
						--where comb.ItemNumber in ('18.615.024')
					 )
			  --select *, parto_.Stdevp_Item * parto_.Z as SS from parto_
			  --where parto_.ItemNumber in ('18.615.024')

			  --- Get your Leadtime ---
			  ,ldtm as (
					select m.ItemNumber as Item_Number,m.LeadtimeLevel
						,row_number() over(partition by m.itemNumber order by m.itemNumber ) rn  
						from JDE_DB_Alan.Master_ML345 m
					)
			  ,ldtm_ as (
					select * from ldtm
					where rn = 1 )

			  ,comb as 
				( select *,parto_.Stdevp_Item* SQRT(ldtm_.leadtimeLevel/30)*parto_.Z as SS
					from parto_ left join ldtm_ on parto_.ItemNumber = ldtm_.Item_Number
					 --where parto_.ItemNumber in ('18.615.024')
				)

			  ,fltb as 
				( select comb.ItemNumber,comb.TTL_Itm,comb.Pareto,comb.Stdevp_Item,comb.LeadtimeLevel,comb.rn,comb.ss as SS_,GETDATE() as RdportDate
					from comb 
				--   where comb.ItemNumber in ('18.615.024','26.803.676','34.307.000','52.417.905','24.043.165S')
				 )

              --select * from fltb where fltb.ItemNumber in ('7501001000')

               insert into JDE_DB_Alan.FCPRO_SafetyStock select * from fltb
				select * from JDE_DB_Alan.FCPRO_SafetyStock
     
			-- below code will be result with calculation on each line/month level ---
			--tb as (
			--select *
			--    ,count(hist.salesqty) over(partition by hist.itemnumber) as count_
			--	,avg(hist.salesqty) over(partition by hist.itemnumber) as avg_	
			--	,SalesQty - avg(hist.salesqty) over(partition by hist.itemnumber)  as diff_
			--	,POWER((SalesQty - avg(hist.salesqty) over(partition by hist.itemnumber)),2) diff_powwer2
			--	,POWER((SalesQty - avg(hist.salesqty) over(partition by hist.itemnumber)),2) /count(hist.salesqty) over(partition by hist.itemnumber) as  var_
			--	,POWER((SalesQty - avg(hist.salesqty) over(partition by hist.itemnumber)),2) /12 as  var_12m
			--	,STDEVP(hist.salesqty) over(partition by hist.itemnumber) as stdev_
			--from hist
			--   )

			--select *
			--	  ,sum(tb.var_) over() as varsum_	   
			--from tb
			--order by tb.ItemNumber,tb.CYM
  
     
	  -------------- Refresh Safety Stock for NP ----------------  Added 12/3/201 ------ You can seprate and run this step independently -- this will be particularly beneficial for Debugging purpose -- if you need to see what is before Applying Refresh and after Refreshing for NP --- 12/3/2018
      
	  update ss
	  set ss.SS_ = (vwnp.FcTTL_12_Qty_MthlyAvg/4)*6					-- SS qty to be capped at 6 week
	  from JDE_DB_Alan.FCPRO_SafetyStock ss inner join JDE_DB_Alan.vw_NP_FC_Analysis vwnp on  ss.ItemNumber = vwnp.ItemNumber
	   where  
				exists ( select distinct _vwnp.ItemNumber from JDE_DB_Alan.vw_NP_FC_Analysis  _vwnp   where ss.ItemNumber = _vwnp.ItemNumber
						 )  
			-- and ss.SS_  is null							-- no need since you are using inner join
			--and  ss.ItemNumber = '34.522.000'
		 
			--and vwnp.Mth_Elapsed < 9					--- allow 8 month for NP   21/2/2019
			and vwnp.Mth_Birth_Elapsed <= 8					--- allow 8 month for NP   22/2/2019
	  -- order by ss.ItemNumber

	 -----------------------------------------------------
	 
	 --- Check how many records need to be updated for SS stock for NP SKUs ---
	--select *  from JDE_DB_Alan.FCPRO_SafetyStock ss 	
    --where exists ( select distinct vwnprd.ItemNumber from JDE_DB_Alan.vw_NP_FC_Analysis vwnprd   where ss.ItemNumber = vwnprd.ItemNumber  )  
			--and   ss.SS_ is null


	-- select * from JDE_DB_Alan.FCPRO_SafetyStock ss where ss.ItemNumber  in ('34.522.000')
	--select vw.ItemNumber,vw.FcTTL_12_Qty_Avg from JDE_DB_Alan.vw_NP_FC_Analysis vw where vw.ItemNumber in ('34.522.000')
	-- select distinct vw.ItemNumber,vw.FcTTL_12_Qty_Avg from JDE_DB_Alan.vw_NP_FC_Analysis vw 

    
END
