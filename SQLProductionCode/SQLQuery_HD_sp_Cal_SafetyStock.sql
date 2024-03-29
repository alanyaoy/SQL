/*    ==Scripting Parameters==

    Source Server Version : SQL Server 2016 (13.0.4259)
    Source Database Engine Edition : Microsoft SQL Server Express Edition
    Source Database Engine Type : Standalone SQL Server

    Target Server Version : SQL Server 2017
    Target Database Engine Edition : Microsoft SQL Server Standard Edition
    Target Database Engine Type : Standalone SQL Server
*/

USE [JDE_DB_Alan]
GO
/****** Object:  StoredProcedure [JDE_DB_Alan].[sp_Cal_SafetyStock]    Script Date: 31/10/2022 9:56:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


			 --- 8/10/2020 ---

----- Need to run SS Adjustment code after run this SS calculation ---- See separate Store procedure for Safety stock Adjustment ---


           ---22/03/2021 ---

   ----- Query the SS ... --- will be carried out in Seperate SQL Query -- See code in 'Master_Code' .... Below is snippet from 'Master_Code' -- appox line 3600

     --- New --- 1. Impersonate existing SS while using latest SS - lift 10% for A & B Item - this can be wind back when Covid period is concluded ( started in June/July 2020 )
	 --- Considerations:
	 --1) excluding MTO items; excluding some Selling group
	 --2) apply certain % to A,B,C paretos - this need to be reveiwed and wind back periodically
	 --3) raw calculations for safety stock in done in Store Procedure -- 'Cal_Safety_Stock'
	 --4) in Query, has to use 'vw_SafetyStock' table to fetch only 1 records per item/SKU to avoid duplicate because 'SafetyStock' table contains all history for SS each item/SKU
	 --5) Note 'Safety stock' table is appeneded/updated each month, so this table 'Safety sto;ck' has history of SS, be careful when query or update ( select/delete/update - DML command or create/drop/alter - DDL )
	 --6) running time is appox 15 mins ( 14'41" ) - after code updated to include safety stock history	--- 13/5/2022



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


				--- Removed this clause March 2021 --- 
	 -- delete from JDE_DB_Alan.FCPRO_SafetyStock
	 --- So build history of SS, so everytime you generate SS, it is like append the original table ---> will it be better to create a separate 'Safetystock_History' table ???
	 --- I think it will be worthwhile to eventually create a 'SafetyStock_Hist' table to make it a clean handling of history of SS and monthly SS generation, becasue you might
	 --- inadvertantly change the value if you put all value ( inlcude history ) in one table !!! Especially when you do SQL 'Update' statement !
	

	      ------  Safety stock ------ 25/7/19	      
		  ------------- Original code for Calendar --------------------------


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
			  ,list as ( select * from itm cross join cldr)			--- 24/7/2019
			  ,mylist as ( select * from itm cross join MthCal )			--- 25/7/2019
				--select * from list where list.ItemNumber_ in ('18.615.024')  order by list.ItemNumber_,list.eom_ 

				 -- Padded Item with all Months ---
			 ,hist as 
			  (  --select list.ItemNumber_,case when h.SalesQty is null then 0 else h.SalesQty end as SalesQty_,list.eom_,list.t
			     --from list left join JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h on list.eom_ = h.CYM and list.ItemNumber_ = h.ItemNumber
				   select mylist.ItemNumber_,case when h.SalesQty_Adj is null then 0 else h.SalesQty_Adj end as SalesQty_,mylist.StartDt as eom_,mylist.xx
				   from mylist left join JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h on mylist.StartDt = h.CYM and mylist.ItemNumber_ = h.ItemNumber
				   where mylist.rnk <25 and mylist.rnk >12													--- last 12 months in MthCal table
				--where list.ItemNumber in ('18.615.024') 		
			   )
			 -- select * from hist 
			   --where hist.ItemNumber_ in ('34.481.000')
			 -- where hist.ItemNumber_ in ('KIT9205')
			 --  order by hist.eom_

			  ,stdv_ as ( 
						select hist.ItemNumber_ 
						,sum(hist.salesqty_)/count(hist.eom_) as Avg_Itm					-- Be careful , some month doesnot have sales, so affect avg
						,sum(hist.salesqty_) as ItmSls_12m
						,sum( case when salesqty_ >0 then 1 else 0 end ) as ItmSls_Freq		-- count numb of month that has positive sales
						,max(hist.salesqty_) as Sls_12m_Max
						,min(hist.salesqty_) as Sls_12m_Min
						,count(hist.eom_) as ItmSlsMth_Count			
						,STDEV(salesqty_) as Stdev_Item
						,STDEVP(salesqty_) as Stdevp_Item
																					 ---  STDEV is used when the group of numbers being evaluated are only a partial sampling of the whole population. The denominator for dividing the sum of squared deviations is N-1, where N is the number of observations ( a count of items in the data set ). Technically, subtracting the 1 is referred to as "non-biased."
																					---   STDEVP is used when the group of numbers being evaluated is complete - it's the entire population of values. In this case, the 1 is NOT subtracted and the denominator for dividing the sum of squared deviations is simply N itself, the number of observations ( a count of items in the data set ). Technically, this is referred to as "biased." Remembering that the P in STDEVP stands for "population" may be helpful. Since the data set is not a mere sample, but constituted of ALL the actual values, this standard deviation function can return a more precise result.	
																					---   In statistics there are two types of standard deviations: one for a sample and one for a population. The sample standard deviation, generally notated by the letter s, is used as an estimate of the population standard deviation. The population standard deviation, generally notated by the Greek letter lower case sigma, is used when the data constitutes the complete population. It is difficult to answer your question directly -- sample or population -- because it is difficult to tell what you are working with: a sample or a population. It often depends on context. Consider the following example. If I want to know the standard deviation of the age of students in my class, then I u=would use STDEVP because the class is my population. But if I want the use my class as a sample of the population of all students in the school (this would be what is known as a convenience sample, and would likely be biased, but I digress), then I would use STDEV because my class is a sample. The resulting value would be my best estimate of STDEVP. As mentioned above (1) for large sample sizes (say, more than thirty), the difference between the two becomes trivial, and (2) generally you should use STDEV, not STDEVP, because in practice we usually don't have access to the population. Indeed, one could argue that if we always had access to populations, then we wouldn't need statistics. The entire point of inferential statistics is to be able to make inferences about a population based on the sample.
						from hist
						group by hist.ItemNumber_ )
              --  select * from stdv_ where stdv_.ItemNumber_ in ('42.210.031') 
               --  select * from stdv_ where stdv_.ItemNumber_ in ('45.124.000') 
			 --  select * from stdv_ where stdv_.ItemNumber_ in ('45.648.100')   
			  --select * from stdv_ where stdv_.ItemNumber_ in ('18.615.024')
			   --select * from stdv_ where stdv_.ItemNumber_ in ('2974000000','24.7206.0000')
			   -- select * from stdv_ where stdv_.ItemNumber_ in ('7501001000')

			   --- Get Your Pareto & Z-Score (Service Level )--
			  ,parto as ( select * 
						from JDE_DB_Alan.FCPRO_Fcst_Pareto p left join stdv_ on p.ItemNumber = stdv_.ItemNumber_
						     
					   )
  
			  ,parto_ as ( select parto.ItemNumber,parto.Stdevp_Item,parto.Stdev_Item,parto.ItmSls_12m,parto.ItmSls_Freq,parto.Sls_12m_Max,parto.Sls_12m_Min
						 ,parto.Pareto

						,case parto.Pareto 
								when 'A'  then 1.65			-- 98%		-- 2.58 99.50%  -- 2.88 99.80%   -- 3.09 99.90%  -- 3.72 99.99%			-- 16/2/2018
								when 'B'  then 1.65			-- 97%		-- 2.33 99%  --2.05 98%  -- 1.88 97%  -- 1.75 96%
								when 'C'  then 1.65           --95%

						
							--	when 'A'  then 2.05			-- 98%		-- 2.58 99.50%  -- 2.88 99.80%   -- 3.09 99.90%  -- 3.72 99.99%			-- 16/2/2018
							--	when 'B'  then 1.88			-- 97%		-- 2.33 99%  --2.05 98%  -- 1.88 97%  -- 1.75 96%
							--	when 'C'  then 1.65           --95%

							--when 'A'  then 2.33			-- 99%		-- 15/2/2018
							--when 'B'  then 1.65			-- 95%		
							--when 'C'  then 1.65           --95%
						  end as Z        
						from parto 
						--where comb.ItemNumber in ('18.615.024')
					 )
			  --select *, parto_.Stdevp_Item * parto_.Z as SS from parto_
			  --where parto_.ItemNumber in ('18.615.024')
			 -- where parto_.ItemNumber in ('34.481.000')

			  --- Get your Leadtime ---
			  ,ldtm as (
					select m.ItemNumber as Item_Number,m.LeadtimeLevel,m.WholeSalePrice,m.StockingType
						,row_number() over(partition by m.itemNumber order by m.itemNumber ) rn  
						from JDE_DB_Alan.Master_ML345 m
					)
			  ,ldtm_ as (
					select * from ldtm
					where rn = 1 )

			  ,comb as 
				( select *					
					,parto_.Stdevp_Item* SQRT(ldtm_.leadtimeLevel/30)*parto_.Z as SS_stdevp
					,parto_.Stdev_Item* SQRT(ldtm_.leadtimeLevel/30)*parto_.Z as SS_stdev
					from parto_ left join ldtm_ on parto_.ItemNumber = ldtm_.Item_Number
					 --where parto_.ItemNumber in ('18.615.024')
				)
              --select * from comb 
			   --where comb.Item_Number in ('34.481.000')
			  --where comb.Item_Number in ('7742140182')										--- Dubug here ! 21/5/2021						
			 


			  ------------------- Forecast ---------------------				          
              ,fc as ( --select f.ItemNumber,sum(f.value) as FC_12mth	
			             --select *  from  JDE_DB_Alan.vw_FC f where f.ItemNumber in ('42.210.031')	  
			            select f.ItemNumber,sum(f.FC_Vol) as FC_12m,avg(f.FC_Vol) as FC_12m_Avg
						from  JDE_DB_Alan.vw_FC f left join MthCal cal on f.FCDate2_ =cal.StartDt
						 where  cal.rnk > 24 and cal.rnk < 37					               ------ next 12 month
						     -- and  f.ItemNumber in ('42.210.031','43.211.004') 						      
						 group by f.ItemNumber
                       )
             --select * from fc where fc.FC_12m_Avg =0
             
			  ,_fltb as 
				( select cb.ItemNumber,cb.ItmSls_12m,cb.ItmSls_Freq,cb.Pareto,cb.StockingType
						,cast(cb.Stdevp_Item as decimal(16,2)) as Stdevp_Item				        
						,cast(cb.LeadtimeLevel as decimal(16,2)) as LeadtimeLevel
						,cb.rn
						,cast(cb.SS_stdev as decimal(16,2)) as SS_1
						,cast(cb.SS_stdevp as decimal(16,2)) as SS_2
						,cast(cb.SS_stdevp as decimal(16,2)) as SS_											--- Important: Actually use Stdevp as your choice for calculation - entire population --- 31/5/22021
						
						,cast(fc.FC_12m_Avg as decimal(16,2)) as FC_12m_Avg
						,cast(coalesce(cb.SS_stdevp /nullif(fc.FC_12m_Avg,0),0) as decimal(16,2)) as Diff				--- handle if divisor is 0 ( then assign null value );then coalesce null to 0, https://stackoverflow.com/questions/861778/how-to-avoid-the-divide-by-zero-error-in-sql
						--,GETDATE() as ReportDate
						,cast(fc.FC_12m as decimal(16,2)) as FC_12m		
						,cast(fc.FC_12m * cb.WholeSalePrice as decimal(16,2)) as FC_12m_$							
						,m.PlannerNumber
						,case m.PlannerNumber 
							when '20072' then 'Salman Saeed'
							when '20004' then 'Margaret Dost'	
							when '20005' then 'Imelda Chan'
							when '20071' then 'Rosie Ashpole'
							when '20003' then 'Lee Rose'
							when '30036' then 'Violet Glodoveza'
							when '30039' then 'Ben'
							when '29917' then 'Metals Planner'
							when '20065' then 'AWF RollForming'
							when '2519718' then 'CutLength Planner'
							--when '20071' then 'Domenic Cellucci'
							else 'Unknown'
						end as Owner_
					  ,cast(m.StandardCost as decimal(16,2)) as StandardCost,cb.Sls_12m_Max,cb.Sls_12m_Min 

					from comb cb left join fc on cb.ItemNumber = fc.ItemNumber 
								 left join JDE_DB_Alan.vw_Mast m on cb.ItemNumber = m.ItemNumber
					--where fc.FC_12m_Avg >0 and cb.SS is not null
				--   where comb.ItemNumber in ('18.615.024','26.803.676','34.307.000','52.417.905','24.043.165S')

				     --select * from JDE_DB_Alan.vw_Mast m where m.ItemNumber in ('34.481.000')
				 )
             
			 
			 --select * from _fltb f where f.ItemNumber in ('34.481.000')  
             --select * from fltb --where fltb.ItemNumber in ('7501001000')
			 --select * from _fltb f where f.SS_ is null  --- f.FC_12m_Avg =0
			

		-------------------- Exception handling 1 ---- First get your Exception list -----  29/7/2019 , only 25 items ----------------------------------
		--------------- For Any items which has volatile ( very high sales history ) to cleanse out to avoid unrealistic high Safety stock level ---------
			,excp_1 as (
					select f.ItemNumber,f.ItmSls_12m,f.ItmSls_Freq,f.Pareto,f.Stdevp_Item,f.LeadtimeLevel
								 ,f.rn
								,f.SS_,f.FC_12m_Avg					
								,f.Diff							
								,f.FC_12m,f.FC_12m_$,f.PlannerNumber,f.Owner_,f.StandardCost		
								,Sls_12m_Max,Sls_12m_Min 	        
					 from _fltb f
						   --where fltb.ItemNumber in ('42.210.031','43.211.004')	
					where 
						  ( f.Pareto in ('A','B')											-- only A pareto ( 20 items ?)		
																							-- only B pareto ( 11 items ?)		
						   and cast((f.SS_ /f.FC_12m_Avg) as decimal(16,2)) >=6			-- if ratio greater than 6 or over 6 months stock ( SS is 6 times greater than monthly FC )
						   and f.ItmSls_Freq >=6   									    -- has 6 or more than 6 sales hits, revised on 11/6/2021 from 7 hits to 6 hits ( example 43.211.004 see Imelda's email 11/6/2021 ).
						   and f.ItmSls_12m >100
							 )
						--   or 
						--   ( f.Pareto in ('C')										-- do not implement C Yet, as C is lower value and very volatile --- 29/7/2019
						--     and f.FC_12m_$ > 1000
						--	 and cast((f.SS_ /f.FC_12m_Avg) as decimal(16,2)) >=12
						 --  and f.FC_12m >1000
						--	 )						   
				 
					 --order by f.Pareto,	(f.SS_ - f.FC_12m_Avg)/f.FC_12m_Avg  desc  
					 -- order by f.Pareto,f.SS_ desc
					 )
             -- select * from excp

	     
		 ,fltb_ as ( select f.ItemNumber,f.ItmSls_12m,f.ItmSls_Freq,f.Pareto,f.StockingType,f.Stdevp_Item,f.LeadtimeLevel,f.rn		                     
							,f.SS_ as statSS_,e.SS_ as excpSS_
							,case 
								 when e.SS_ is null then f.SS_			-- if there is no match, then there is no match, all good/OK
								 else f.FC_12m_Avg *6						-- if there is match then this is excption,we will use 5 month forecast as SS ( because in some cases statSS has more than 12 month fc; possible exception --> but again you need to validate if fc is legitmate ( maybe forecast are too small ).
							  end as mySS_
							,f.FC_12m_Avg
							,f.Diff 
							,f.FC_12m,f.FC_12m_$,f.PlannerNumber,f.Owner_,f.StandardCost
							,f.Sls_12m_Max,f.Sls_12m_Min 
		             from _fltb f left join excp_1 e on f.ItemNumber = e.ItemNumber 

					 )
            --select * from fltb_

           ,_fltb_ as ( select f.ItemNumber,f.ItmSls_12m,f.Pareto,f.StockingType,f.Stdevp_Item,f.LeadtimeLevel,f.rn
							,f.mySS_,f.mySS_ as SS_Adj_1,'N' as ValidStatus_Adj_Flg					--- 12/6/2020, reset every month  ( everything will rely on exception tbl )-  defaul Validstatus is 'N' , which means No it is not qualified for Adjustment, you need to adjust sales history.
						    ,f.PlannerNumber
					   from fltb_ f
					   --where f.ItemNumber in ('43.211.004','42.210.031')
					   where f.StockingType not in ('O','U','Q','M')					 -- Q is BTO and M is MTO,need to excluded from SS  --- 2/9/2019
							 -- and f.SellingGroup in ('AD','TM','WC','FI')							 
					   )

			-- select * from _fltb_ a where a.ItemNumber in ('42.210.031','12.171.033')
		
		
		------------------- Exception handling 2 ---- First get your Exception list -----  
		
		--------- 27/5/2021 , lift 10% A & B items ( A/B - total 1915 (A -840/B -1075)  items for all planners, HD planners 1360 SKUs, total A/B Pareto $5m to $6.5m so 10% is around $500K  to $650K--------
		--------- 17/3/2021 , lift 15% only C items ( C - total 3167 items for all planners, HD planners 2200 SKUs, total C Pareto $650K to $700K SS value, so 15% is around $100K --------


           ,excp_2 as ( select * 		   
						from _fltb_ a
						where a.Pareto in ('A','B','C')
						      and a.PlannerNumber in ('20005','20071','20072')				-- only pick HD planners
						)
         
		   ,flt as (  select a.ItemNumber,a.ItmSls_12m,a.Pareto,a.StockingType,a.Stdevp_Item,a.LeadtimeLevel,a.rn,a.PlannerNumber
						,a.mySS_,a.SS_Adj_1,e.mySS_ as s1,e.SS_Adj_1 as s2
						,case 
								 when e.SS_Adj_1 is null then a.SS_Adj_1					-- if there is no match, then there is no match, all good/OK
								 when e.SS_Adj_1 is not null then							-- if there is match then this is excption,we will use 1.1 xforecast as SS ( this can be wind back later )
														(case 
																--when e.Pareto in ('A','B') then  a.SS_Adj_1 *1.1
																--when e.Pareto in ('C') then a.SS_Adj_1 *1.15
																when e.Pareto in ('A','B') then  a.SS_Adj_1 *1
																when e.Pareto in ('C') then a.SS_Adj_1 *1
														 end
														)			
							  end as SS_Adj_2
						
						,a.ValidStatus_Adj_Flg
		              from _fltb_ a left join excp_2 e on a.ItemNumber = e.ItemNumber

		             )		
		     --select * from flt where flt.ItemNumber in ('42.210.031','12.171.033')
		
			

			--- 24/7/2020 --- change code to include fc_avg and cost for analysis purpose ---
			,_fl as (
					select f.*
							,f.SS_Adj_2 as SS_Adj
							,m.StandardCost,fc.fc_avg
					from flt f left join JDE_DB_Alan.vw_Mast m on f.ItemNumber = m.ItemNumber
								left join ( 
										 select a.ItemNumber,avg(a.FC_Vol) as fc_avg from JDE_DB_Alan.vw_FC a
											 where --a.FCDate2_ < 202012 
											        a.FCDate2_ < cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())+6,0),126),'-',''),1,6) as integer)			--- next 6 month
											 group by a.ItemNumber 
									 ) fc							  	
								on f.ItemNumber = fc.ItemNumber
						)
		
			
			 ----------------------- Final SS Table --------------------------------  30/7/2019
			, fl as ( select f.ItemNumber,f.ItmSls_12m,f.Pareto,f.StockingType							
							,f.mySS_,f.SS_Adj,f.ValidStatus_Adj_Flg
							,f.Stdevp_Item,f.LeadtimeLevel,f.rn
							--,f.PlannerNumber
							,f.StandardCost
							
							 ,p.Order_Policy,p.Order_Policy_Description
							 ,p.Planning_Code,p.Planning_Code_Description
							 ,Planning_Fence_Rule,Planning_Fence_Rule_Description	
							 
							 ,getdate() as ReportDate

					 from _fl f left join JDE_DB_Alan.vw_Mast_Planning p on f.ItemNumber = p.Item_Number
					 -- where f.ItemNumber in ('34.481.000')
					
						 )
		    
			--select  a.*  from fl a 
			--order by a.Pareto


			-- where fl.ItemNumber in ('42.210.031','12.171.033')
			 --where fl.ItemNumber in ('34.481.000','7456500182')
			 --where fl.ItemNumber in ('24.7257.0952')
			-- where a.ItemNumber in ('7742140182')

		 -------------------------------------------------------------------------------------------------------------------------------------------
               insert into JDE_DB_Alan.FCPRO_SafetyStock select * from fl
				select * from JDE_DB_Alan.FCPRO_SafetyStock ss
				--order by ss.Pareto,ss.ItemNumber


           --select * into JDE_DB_Alan.FCPRO_SafetyStock_ from JDE_DB_Alan.FCPRO_SafetyStock
     
	        ------------------------------------
	         --- Some Debug tools ---
			 ------------------------------------
	        -- select count(*) from JDE_DB_Alan.FCPRO_SafetyStock ss
	        -- select distinct ss.ReportDate from JDE_DB_Alan.FCPRO_SafetyStock ss
			--  select * from JDE_DB_Alan.FCPRO_SafetyStock ss  where dateadd(d, datediff(d,0, ss.ReportDate), 0) = dateadd(d, datediff(d,0, getdate()), 0)		-- today's record
			--   select * from JDE_DB_Alan.FCPRO_SafetyStock ss  where ss.ItemNumber in ('34.481.000')
			--    select * from JDE_DB_Alan.FCPRO_SafetyStock ss  where ss.ReportDate > dateadd(s,-1, dateadd(d, datediff(d,0, getdate()), 0))		-- any new record sinc middle night yesterday

			--   delete from JDE_DB_Alan.FCPRO_SafetyStock  where ReportDate > dateadd(s,-1, dateadd(d, datediff(d,0, getdate()), 0))				--- delete test data

			----------------------------------------------


			-- Below code will be result with calculation on each line/month level ---
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
      

	    ------ Update only latest records, not all historical items ------ 9/3/2021
	  ; with _ss as 
	             
				 ( select a.ItemNumber,a.SS_,a.SS_Adj,a.Pareto
				       --  ,max(a.ReportDate) over(partition by a.itemNumber) as SS_Latest_upd_date	
						--,min(a.ReportDate) over(partition by a.itemNumber) as SS_Oldest_upd_date
						--,rank() over ( partition by a.itemNumber order by a.reportdate Desc) rk_0
						--,rank() over ( partition by a.itemNumber order by a.reportdate desc) rk_1
						,rk_num_dense = dense_rank() over ( partition by a.itemNumber order by a.reportdate desc )
					  from JDE_DB_Alan.FCPRO_SafetyStock a
					  --where a.ReportDate = max(a.ReportDate)
					  --group by a.ItemNumber,a.SS_,a.SS_Adj			
					)

              ,ss as ( select * from _ss a where a.rk_num_dense = 1)

	  update ss
	 -- set ss.SS_ = (vwnp.FcTTL_12_Qty_MthlyAvg/4)*6					-- SS qty to be capped at 6 week
	     -- ,ss.SS_adj = (vwnp.FcTTL_12_Qty_MthlyAvg/4)*6				--- do not forget ss_adj value !!!   24/7/2020

      set ss.SS_ = (vwnp.FcTTL_12_Qty_MthlyAvg/4)*8					-- SS qty to be capped at 8 week
	      ,ss.SS_adj = (vwnp.FcTTL_12_Qty_MthlyAvg/4)*8				--- do not forget ss_adj value !!!   29/10/2020

	  from 	 ss 
			inner join JDE_DB_Alan.vw_NP_FC_Analysis vwnp on  ss.ItemNumber = vwnp.ItemNumber
	   where  
				exists ( select distinct _vwnp.ItemNumber from JDE_DB_Alan.vw_NP_FC_Analysis  _vwnp   where ss.ItemNumber = _vwnp.ItemNumber
						 )  
			-- and ss.SS_  is null							-- no need since you are using inner join
			--and  ss.ItemNumber = '34.522.000'
		 
			--and vwnp.Mth_Elapsed < 9					--- allow 8 month for NP   21/2/2019
			and vwnp.Mth_Birth_Elapsed <= 8					--- allow 8 month for NP   22/2/2019


      ------------------------- 17/3/2021 Update C pareto SS-------------------------------------------------------------------
	  --- You can do 2nd 'update' SQL here,but need a filter to avoid update all C pareto in the past history !!
	  --- better to do it in front 

	--select * from JDE_DB_Alan.FCPRO_SafetyStock tb where tb.ItemNumber in ('42.210.031')
	
	--  update tb
    --  set tb.SS_Adj = tb.SS_ *1.1
	 -- from 	JDE_DB_Alan.FCPRO_SafetyStock tb 
	 -- where tb.Pareto in ('C')
	     ---     and tb.ReportDate =''


			
			
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
