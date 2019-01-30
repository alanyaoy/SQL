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

/****** Object:  StoredProcedure [JDE_DB_Alan].[sp_Cal_SafetyStock]    Script Date: 30/01/2019 3:02:50 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [JDE_DB_Alan].[sp_Cal_SafetyStock_RM]  
	
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

			delete from JDE_DB_Alan.FCPRO_SafetyStock_RM

			
			---==========================================================
			--- Safety stock for Textile Raw Material --------  301/2019
			---==========================================================

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

						  ,itm as ( select distinct h.ItemNumber as ItemNumber_,h.bu from JDE_DB_Alan.vw_Hist_RM h )
						  ,list as ( select * from itm cross join cldr)
							--select * from list where list.ItemNumber in ('18.615.024')  order by list.ItemNumber,list.eom_ 

							 -- Padded Item with all Months ---
							 --- Also, since RM does not have FC, I will use History as a guide for requirement/demand ref   --- 30/1/2019
						 ,hist as 
						  (  select list.ItemNumber_,case when h.fQty is null then 0 else h.fQty end as SalesQty_,list.eom_,list.t,m.StandardCost
									,case when h.fQty * m.StandardCost is null then 0 else h.fQty * m.StandardCost end as CostAmt	--- get Amt ready for Pareto Calculation for Textile RM -- Again Use History not FC as RM does not have FC --- 30/1/2018
									,list.bu
							from list left join JDE_DB_Alan.vw_Hist_RM h on list.eom_ = h.CYM and list.ItemNumber_ = h.ItemNumber
									  left join JDE_DB_Alan.vw_Mast m on list.ItemNumber_ = m.ItemNumber							
							--where list.ItemNumber in ('18.615.024') 		
						   )
						 -- select * from hist 
						 -- where hist.ItemNumber_ in ('09.566.000')
						  -- order by hist.eom_

						  ,stdv_ as ( 
									select hist.bu,hist.ItemNumber_						
									,sum(hist.salesqty_)/count(hist.eom_) as Avg_Itm					-- Be careful , some month doesnot have sales, so affect avg
									,sum(hist.salesqty_) as TTL_Itm
									,sum( case when salesqty_ >0 then 1 else 0 end ) as Num_ItmSls		-- count numb of month that has positive sales
									,count(hist.eom_) as TTL_ItmSlsMth			
									,STDEVP(salesqty_) as Stdevp_Item
									,sum(hist.CostAmt) as Amt_Itm
									from hist 
									group by hist.bu,hist.ItemNumber_ )
						 -- select * from stdv_ where stdv_.ItemNumber_ in ('09.400.951','09.566.000') 


						  ---**** Get Your Pareto & Z-Score (Service Level ) ***---
						   --- Get Pareto for RM using CostAmt (sales/transfer Qty not FC Qty RM has no FC)-- 

						,x as (
							select *
								,sum(sm.Amt_Itm) over(partition by sm.BU) as GrandTTL
								,cast(coalesce(sm.Amt_Itm/nullif(sum(sm.Amt_Itm) over(partition by sm.BU),0),0) as decimal(18,12)) as Pct
							--,(select sum(value) from FCPRO_Fcst where id<=t.id)/(select sum(value) from FCPRO_Fcst ) as Running_Percent	 
							from stdv_ sm
						--order by FCPRO_Fcst.value
							),

							--select * from x order by x.DataType1,x.ItemLvlFC_24 desc
							--- Sort the records First Very important !---
						y as ( select x.*,row_number() over ( partition by x.bu order by x.Pct desc) as rnk
									from x ),

						tbl as (
									select y.*,sum(y.Amt_Itm) over (partition by y.BU order by y.rnk ) as RunningTTL from y ),


							--- Calculate Percentage ( And if there is an% sign in number remove it first )
						ftb as ( select tbl.ItemNumber_ as _ItemNUmber,tbl.bu as _bu
										,tbl.Amt_Itm as _Amt_Item,tbl.RunningTTL,tbl.GrandTTL,tbl.Pct,(tbl.RunningTTL/tbl.GrandTTL) as RunningTTLPct,tbl.rnk
											, (case 
													when convert(decimal(18,2),replace((tbl.RunningTTL/tbl.GrandTTL),'%','')) <=0.800001 then 'A'		---20
													when convert(decimal(18,5),replace((tbl.RunningTTL/tbl.GrandTTL),'%','')) < 0.95 then 'B'		---30
													else 'C' end ) as Pareto																		---50
							
										from tbl
										)
						 --select * from ftb   

						  ,parto as ( select * 
									from ftb as p left join stdv_ on p._ItemNumber = stdv_.ItemNumber_
						     
								   )
  
						  ,parto_ as ( select p.ItemNumber_,p.Stdevp_Item,p.TTL_Itm,p.Pareto,p.Amt_Itm,p.rnk
									,case p.Pareto 
											when 'A'  then 2.05			-- 98%		-- 2.58 99.50%  -- 2.88 99.80%   -- 3.09 99.90%  -- 3.72 99.99%			-- 16/2/2018
											when 'B'  then 1.88			-- 97%		-- 2.33 99%  --2.05 98%  -- 1.88 97%  -- 1.75 96%
											when 'C'  then 1.65           --95%

										--when 'A'  then 2.33			-- 99%		-- 15/2/2018
										--when 'B'  then 1.65			-- 95%		
										--when 'C'  then 1.65           --95%
									  end as Z        
									from parto p
									--where comb.ItemNumber in ('18.615.024')
								 )
 
							--select * from parto_ p 
							--where p.ItemNumber_ in ('09.400.951','09.566.000','82.865.000') 
							--order by p.Pareto,rnk
						  --select *, parto_.Stdevp_Item * parto_.Z as SS from parto_
						  --where parto_.ItemNumber in ('18.615.024')

						  --- Get your Leadtime ---
						  ,ldtm as (
								select m.ItemNumber as Item_Number,m.LeadtimeLevel,m.Description
									,row_number() over(partition by m.itemNumber order by m.itemNumber ) rn  
									from JDE_DB_Alan.Master_ML345 m
								)
						  ,ldtm_ as (
								select * from ldtm
								where rn = 1 )

						  ,comb as 
							( select *,parto_.Stdevp_Item* SQRT(ldtm_.leadtimeLevel/30)*parto_.Z as SS
								from parto_ left join ldtm_ on parto_.ItemNumber_ = ldtm_.Item_Number
								 --where parto_.ItemNumber in ('18.615.024')
							)

						  ,fltb as 
							( select comb.ItemNumber_,comb.TTL_Itm as Sales_12mth,comb.Pareto,comb.Stdevp_Item,comb.LeadtimeLevel,comb.rnk
							          ,comb.Amt_Itm as SalesAmt_12mth_Cost
									,comb.rn
							         ,comb.ss as SS_
									,comb.Description
									,GETDATE() as ReportDate
								from comb 
							--   where comb.ItemNumber in ('18.615.024','26.803.676','34.307.000','52.417.905','24.043.165S')
							 )

						 ,z as ( select t.ItemNumber_,t.Sales_12mth,t.Pareto,t.Stdevp_Item,t.LeadtimeLevel,t.rnk,t.SS_,t.ReportDate
						       from fltb t
								-- where fltb.ItemNumber_ in ('09.400.951','09.566.000','82.865.000')
								--order by t.rnk
								)
  
                 insert into JDE_DB_Alan.FCPRO_SafetyStock_RM select * from z
				select * from JDE_DB_Alan.FCPRO_SafetyStock_RM

     
	  -------------- Refresh Safety Stock for NP ----------------  Added 12/3/201 ------ You can seprate and run this step independently -- this will be particularly beneficial for Debugging purpose -- if you need to see what is before Applying Refresh and after Refreshing for NP --- 12/3/2018
      
	 -- update ss
	 --  set ss.SS_ = (vwnp.FcTTL_12_Qty_MthlyAvg/4)*6					-- SS qty to be capped at 6 week
	 -- from JDE_DB_Alan.FCPRO_SafetyStock_RM ss inner join JDE_DB_Alan.vw_NP_FC_Analysis vwnp on  ss.ItemNumber = vwnp.ItemNumber
	 --  where  
	 --			exists ( select distinct _vwnp.ItemNumber from JDE_DB_Alan.vw_NP_FC_Analysis  _vwnp   where ss.ItemNumber = _vwnp.ItemNumber
	 --					 )  
			-- and ss.SS_  is null							-- no need since you are using inner join
			--and  ss.ItemNumber = '34.522.000'
		 
	  --	and vwnp.Mth_Elapsed < 9					--- allow 8 month for NP 
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
GO


