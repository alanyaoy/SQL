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

/****** Object:  StoredProcedure [JDE_DB_Alan].[sp_FCPro_Portfolio_Analysis]    Script Date: 9/04/2021 2:08:15 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



/****** Object:  StoredProcedure [JDE_DB_Alan].[sp_FCPro_Portfolio_Analysis]    Script Date: 29/01/2018 9:17:10 AM ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [JDE_DB_Alan].[sp_FCPro_Portfolio_Analysis_old] 
	-- Add the parameters for the stored procedure here
	--<@Param1, sysname, @p1> <Datatype_For_Param1, , int> = <Default_Value_For_Param1, , 0>, 
	--<@Param2, sysname, @p2> <Datatype_For_Param2, , int> = <Default_Value_For_Param2, , 0>

	-- @Supplier_id varchar(8000) = null
	 @Item_id varchar(8000) = null
	-- ,@DataType varchar (100) = null
	--,@ItemNumber varchar(100) = null
	--,@ShortItemNumber varchar(100) = null
	--,@CenturyYearMonth int = null	
	,@Start datetime = null
	,@End datetime = null
	--,@OrderByClause varchar(1000) = null
	
	          --- Portfolio Report Store Procedure Update History ---
	--- Updated on 13/2/2020, to allow multiple columns in 'order by clause' with 'case' statement  -- Works Yeah --- https://stackoverflow.com/questions/26048976/case-statement-for-order-by-clause-with-multiple-columns-and-desc-asc-sort
    --- Updated 7/8/2020  to include calculation using latest 4 month sales history compared with 4 months FC to see if there is any abnormality ----
	--- Still got some performance issue for ML345 table when use cross join using FC table and calendar ( Alan's calendar ) 
	---- Tried to use View and Index but too much test needed --- 
	
	--- Note ROP Analysis Report borrow a lot of code from Portfolio Report ---	
	
	
	
		--- Note ROP Analysis borrow big chunk of Code from 'sp_FCPro_Portfolio_Analysis' ---
	------------------------------------------------------------------------------------------------------------------------------------------------------------
	--- Updated on 13/2/2020, to allow multiple columns in 'order by clause' with 'case' statement  -- Works Yeah --- https://stackoverflow.com/questions/26048976/case-statement-for-order-by-clause-with-multiple-columns-and-desc-asc-sort
    --- Updated 7/8/2020  to include calculation using latest 4 month sales history compared with 4 months FC to see if there is any abnormality ----
	--- Still got some performance issue for ML345 table when use cross join using FC table and calendar ( Alan's calendar ) 
	---- Tried to use View and Index but too much test needed --- 
	------------------------------------------------------------------------------------------------------------------------------------------------------------

	------------------  ROP Analysis ---------------------  23/3/2021
	--- -1. ROP need to be Reset/updated every month because Sales hits will change by month and forecast, SS will also change -----
	      --- it is likely that an Item is dormant/non active for a long time, and suddenly become active in one month and you need to plan stock ( could be AWF bought hugh stock at one time and let it just depleted, and then after 1 or 2 years order again --- this is hard to predict
	---  0. Also when Reset ROP each month, need to download V4102A report regardless and go from there to Reset all ROP to non_ROP ( Lot for Lot ) (filter by Stocking type - do not worry about if ROP but stocking type is I,O,U etc ) BECAUSE YOur ROP Analysis code only take care of Forecastable Items each month, so if An Item beCOMES Non forecast following month, then it is missing from your Radar and Orphan 'ROP' item will be sitting loosely in system which is not ideal, albeit you do not need to planning any stock and it is not clean in system
	      --- like Awning code 45.018.000, 45.035.000, 45.046.063 etc
	--- 1. Remove if else statement so no need to implement parameters whether you need to input Item_id or not ---
	--- 2. Remove if else statement so no need to implement parameters whether you need to input Item_id or not ---
		   
			 --- 29/3/2021 ---
	--- 3. How to capture accurately Awning seasonal FC ? If use 12 month avg, then it kind of dilute and high(peak) season, FC will be low; in low(valley) season, FC will be artificially high ( maybe to have bit extraa is not  totally bad thing ).
	   --  And if use only 6 immediately/recent 6 months fc, you might miss the items/wrongly calculate fc if SKU has sparadic sales history and valotile demand pattern ( like some month 0, some months has hits - hence future fc is like this way as well ), so if you 
	     -- use next 6 months avg or 4 month avg fc, you might get 0 fc for those products, where ROP has many products like that - it is nature/characristics of ROP ( C) pareto items.
		 -- where we have Awning product supply issues ( Folding arms/ Nordic ) in season 2020 for Salman, he claim that ROP value does not capture seasonal profile, it is not 100% ture, it capture some of them, not all of them while seasonal split is likely 40/60 or 35/65.
		 -- So pratical solutio might be to isolate Awning products ( if it is C pareto and falls in ROP class ), and calcualte its forecat separately.


   
		     ---22/03/2021 ---

   ----- Query the SS ... --- will be carried out in Seperate SQL Query -- See code in 'Master_Code' .... Below is snippet from 'Master_Code' -- appox line 3600

     --- New --- 1. Impersonate existing SS while using latest SS - lift 10% for A & B Item - this can be wind back when Covid period is concluded ( started in June/July 2020 )
	 --- Considerations:
	 --1) excluding MTO items; excluding some Selling group
	 --2) apply certain % to A,B,C paretos - this need to be reveiwed and wind back periodically
	 --3) raw calculations for safety stock in done in Store Procedure -- 'Cal_Safety_Stock'
	 --4) in Query, has to use 'vw_SafetyStock' table to fetch only 1 records per item/SKU to avoid duplicate because 'SafetyStock' table contains all history for SS each item/SKU
	 --5) Note 'Safety stock' table is appeneded/updated each month, so this table 'Safety sto;ck' has history of SS, be careful when query or update ( select/delete/update - DML command or create/drop/alter - DDL )



AS
BEGIN
-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	--set @OrderByClause = 'rnk'	

-- Insert statements for procedure here
	--SELECT <@Param1, sysname, @p1>, <@Param2, sysname, @p2>
	 
	if @Item_id is null and @Start is not null and @end is not null --and @OrderByClause is not null


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
						select top 48 t
									--,RIGHT('00'+CAST(n AS VARCHAR(3)),2) nmb,cast(SUBSTRING(REPLACE(CONVERT(char(10),start,126),'-',''),1,6) as integer) as [StartDate]		-- original name of '[StartDate]' in template
									,RIGHT('00'+CAST(n AS VARCHAR(3)),2) nmb,cast(SUBSTRING(REPLACE(CONVERT(char(10),start,126),'-',''),1,6) as integer) as [StartDt2]			-- 5/9/2018 , changed Name to 'StartDt2'
									,RIGHT('00'+CAST(n AS VARCHAR(3)),2) nmbr,cast(SUBSTRING(REPLACE(CONVERT(char(10),start,126),'-',''),1,6) as integer) as [StartDt]			-- 6/8/2020 , changed Name to 'StartDt2'
									,DATENAME(mm,start) MnthName,DATENAME(yyyy,start) YearName from CalendarFrame
					)
				 --select * from MonthlyCalendar

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



				,itm as ( select distinct h.ItemNumber as ItemNumber_ from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h )
				,list as ( select * from itm cross join MonthlyCalendar cldr 
							where --StartDate						-- original name of '[StartDate]' in template 
									StartDt
									 between replace(convert(varchar(8), DATEADD(mm, DATEDIFF(m,0,GETDATE())-12,0),126),'-','' )			-- last 12 months		
													 and  replace(convert(varchar(8), DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-','' )		-- last 12 months
						  )		
		
				 ,mylist as ( select * from itm cross join MthCal )	
		 	  
				 --select * from list m where m.ItemNumber_ in ('34.252.000')	
				-- select * from mylist m where m.ItemNumber_ in ('34.252.000')
		 		  	     
				----------------- Padded Item with all Months --------------------		
		  

					 --- below is tb padded Item with all Months ---
				,hist as																													
				(  select m.ItemNumber_
				            
							,h.CYM,h.CY,h.Month
							,h.ReportDate
							,case when h.SalesQty is null then 0 else h.SalesQty end as SalesQty_				
							,getdate() as ReportDate_												-- there is no different version of history, so do not bother to use old ReportData in History table UNLESS you need to join back to History table using ReportData as a key --- 5/9/2018
							,m.StartDt
							--,m.YY, m.rnk,m.month as mth						  
							,case 
								when h.CYM is null	then cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-',''),1,6) as integer) 		-- why use this ?						
								else h.CYM
							end as CYM_
							,case 
								when h.CYM is null	then m.StartDt					
								else h.CYM
							end as CYM_2
							,m.YY
							,m.rnk

					--from list m left join JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h on m.StartDt2 = h.CYM and  m.ItemNumber_ = h.ItemNumber			--- old  6/8/2020
					 from mylist m left join JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h on m.StartDt = h.CYM and  m.ItemNumber_ = h.ItemNumber			--- new 7/8/2020
					--where    list.StartDt = cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-',''),1,6) as integer)			-- Watch out use List.StartDt Not h.CYM !!!   --- 29/5/2018
							-- h.CYM = '201804' and																													-- Performance issue ?
							--c.rnk =24																												-- last month ( for last month Sales)
						--where  m.StartDt <= cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-',''),1,6) as integer)    --- old 6/9/2020  
						  where m.rnk <25 and m.rnk >12
						)

					-- select * from hist where hist.ItemNumber_ in ('38.001.001')

				--select * from hist h where h.ItemNumber_ in ('34.252.000')

				,histy as 
					( select x.ItemNumber_
					,count(isnull(x.CYM_2,0)) TTL_SlsMths			-- Or you can use --> count(isnull(x.StartDt2,0)) TTL_SlsMths
					,sum( case when salesqty_ <>0 then 1 else 0 end ) as Sls_freq
					,sum(x.SalesQty_) SlsVol_TTL_12 
					,sum( case when x.yy <5 then x.SalesQty_ else 0 end ) SlsVol_TTL_4 
					from hist x 
					group by x.ItemNumber_)
				--select * from histy where histy.ItemNumber_ in ('03.986.000','38.001.001')
				-- select * from histy where histy.ItemNumber_ in ('34.252.000')


				   --- remove 'SCRA' product by using 'except' or you can using left join, use 'not in' maybe not a best choice ---  14/12/2018
				,_stk as ( select * from JDE_DB_Alan.vw_Mast a where a.GLCat in ('SCRA') )
				,stk_ as ( select a.ItemNumber,a.QtyOnHand,a.StockValue from JDE_DB_Alan.vw_Mast a 
							except 
						   select b.ItemNumber as ItemNumber_,b.QtyOnHand as QtyOnHand_ ,b.StockValue as StockValue_ from _stk b
						   )

				,stk as (
							select a.ItemNumber,sum(coalesce(a.QtyOnHand,0)) SOHVol,sum(coalesce(a.StockValue,0)) SOHVal				--- 14/12/2018
							from stk_ a 
							group by a.ItemNumber
					
							)	
					
				--select * from JDE_DB_Alan.FCPRO_Fcst f where f.ItemNumber in ('34.252.000') and f.DataType1 in ('Adj_FC')	
				-- select * from JDE_DB_Alan.vw_FC f where f.ItemNumber in ('34.252.000') 
        

				 ---- No need since fc table is already clean and padded with all month ------
				--,fc_itm as ( select distinct f.ItemNumber as ItemNumber_ from JDE_DB_Alan.vw_FC f )
				--,fc_list as ( select * from fc_itm cross join MthCal l where l.rnk > 24 and l.rnk < 49 )	
				--select * from fc_list l where l.ItemNumber_ in ('34.252.000')

				--,myfcVol as (select * from fc_list l left join JDE_DB_Alan.vw_FC f on l.ItemNumber_ = f.ItemNumber and l.StartDt = f.FCDate2_
								--where l.rnk > 24 and l.rnk < 49
								--)		
			   --select * from fc_Vol_ f where f.ItemNumber in ('34.252.000') 
			   ,f_ as (
						   select f.*,rank() over (partition by DataType1,ItemNumber  order by date asc ) as rnk	 
							from JDE_DB_Alan.FCPRO_Fcst f 
							where  f.DataType1 in ('Adj_FC')

						)

				,_f as ( select
								f.DataType1,f.ItemNumber
								,sum( case when f.rnk <5 then f.Value else 0 end ) ItemLvlFCVol_TTL_4 
								--,sum(f.Value) over (partition by ItemNumber order by rnk ) as ItemLvlFCVol_TTL_4 
							from f_ f
							group by f.ItemNumber,f.DataType1

						)

			

				,my_fc_Vol as  
					( select f.DataType1,f.ItemNumber,sum(isnull(f.value,0)) as ItemLvlFCVol_1To24,count(isnull(f.Date,0)) Count_FC_Period   ---TTL_FCMths	
						 from JDE_DB_Alan.FCPRO_Fcst f					-- 22/1/2018 did not have  condition before --> where fct.DataType1 like ('%Adj_FC%')	
						 --  from _fc f
						  where f.DataType1 like ('%Adj_FC%')			-- 26/2/2018
								--and f.Date between '2021-03-01' and '2022-02-01'			-- For Signature New Product Post Launch Analysis --- 5/6/2018
								  and f.Date between @Start and @End
						group by f.DataType1,f.ItemNumber)	

		
				--- join table of 4 month FC with main FC table ---				
				,fc_Vol  as 
						(	Select f.*,_f.ItemLvlFCVol_TTL_4
								from my_fc_Vol f left join _f on f.ItemNumber = _f.ItemNumber	 

							)
	

		
				,fcVol as (	select fc_Vol.ItemNumber
								,fc_Vol.DataType1							
								,fc_Vol.ItemLvlFCVol_1To24	
								,fc_Vol.ItemLvlFCVol_TTL_4						
								,fcprt.Pareto
								,fc_Vol.Count_FC_Period
								--,sum(f.value) FCVol_ttl_24
							--from JDE_DB_Alan.FCPRO_Fcst f 		
							from fc_Vol inner join JDE_DB_Alan.FCPRO_Fcst_Pareto fcprt on fc_Vol.DataType1 = fcprt.DataType1 and fc_Vol.ItemNumber = fcprt.ItemNumber
					
							where fc_Vol.DataType1 like ('%Adj_FC%')		--26/2/2018
							--where fc_Vol.DataType1 like ('%default%')
							--where f.DataType1 like ('%point%') 		
							--group by f.ItemNumber,f.DataType1
								)

					--	select * from fcVol where fcvol.ItemNumber = '34.252.000'
						--where fcVol.ItemLvlFCVol_24 is null		-- where fc.ItemNumber = '18.615.024' --- fc about 10125 record

					   --- Item Level ----
				,comb_Vol as (select fc_Vol.ItemNumber,histy.SlsVol_TTL_12,histy.SlsVol_TTL_4,histy.Sls_Freq								
										,fc_Vol.ItemLvlFCVol_1To24
										,fc_Vol.ItemLvlFCVol_TTL_4
										,fc_Vol.Count_FC_Period
										,stk.SOHVol
										,stk.SOHVal
										--,coalesce(stk.SOHVol/(nullif(fc_Vol.ItemLvlFCVol_1To24/24,0)),0) as SOHWksCover						--if divisor is 0	
										,coalesce(stk.SOHVol/(nullif(fc_Vol.ItemLvlFCVol_1To24/fc_Vol.Count_FC_Period,0)),0) as SOHWksCover			--if divisor is 0 And FC month count varies --- 19/7/2018					 
								from fc_Vol left join histy on fc_Vol.ItemNumber = histy.ItemNumber_
											left join stk on stk.ItemNumber = histy.ItemNumber_
								)
				-- select * from comb_vol  where comb_Vol.SOHWksCover is null
				-- where comb_vol.ItemNumber = ('03.986.000')

				--select * from comb_Vol v where v.ItemNumber in ('34.252.000')   --- ok to run

				,combVol as ( select comb_Vol.*,px.StandardCost as Cost,px.WholeSalePrice as Price
								from comb_Vol left join JDE_DB_Alan.vw_Mast px on comb_Vol.ItemNumber = px.ItemNumber								--9/1/19
								--from comb_Vol left join JDE_DB_Alan.Px_AWF_HD_MT_FCPro_upload px on comb_Vol.ItemNumber = px.ItemNumber	        --8/1/19
								)

				,pareto as ( select p.ItemNumber,p.rnk,p.DataType1,p.Pareto from JDE_DB_Alan.FCPRO_Fcst_Pareto p where p.DataType1 like ('%Adj_FC%')			--26/2/2018
								)

				,comb_Amt as ( select c.*,P.Pareto,p.rnk,ss.SS_Adj

								  , case 
									when c.Sls_freq is null then 0
									when c.Sls_freq  = 0 then 0
								  --when c.Sls_freq  > 0 then ((c.ItemLvlFCVol_1To24/c.Count_FC_Period)-(c.SlsVol_TTL_12/c.Sls_freq))/(c.SlsVol_TTL_12/c.Sls_freq)		
								  --when c.Sls_freq  > 0 then ((c.ItemLvlFCVol_1To24/c.Count_FC_Period)-(c.SlsVol_TTL_12/12))/(c.SlsVol_TTL_12/12)				--- use diff from FC vs Sales then compare with Sales volume		---15/2/2019
								  --when c.Sls_freq  > 0 then coalesce((isnull(c.ItemLvlFCVol_1To24/c.Count_FC_Period,0)-isnull(c.SlsVol_TTL_12/12,0))/isnull(c.SlsVol_TTL_12/12,0),0)			--- use diff from FC vs Sales then compare with Sales volume		---24/09/2019	   
								 -- when c.Sls_freq  > 0 then coalesce(nullif(((c.ItemLvlFCVol_1To24/c.Count_FC_Period)-(c.SlsVol_TTL_12/12))/(c.SlsVol_TTL_12/12),0),0)						--- use diff from FC vs Sales then compare with Sales volume		---25/09/2019		-- https://stackoverflow.com/questions/861778/how-to-avoid-the-divide-by-zero-error-in-sql  --Select Case when divisor=0 then null Else dividend / divisor End; But here is a much nicer way of doing it: Select dividend / NULLIF(divisor, 0) ... ; In case you want to return zero, in case a zero devision would happen, you can use: SELECT COALESCE(dividend / NULLIF(divisor,0), 0) FROM sometable
									when c.Sls_freq  > 0 then coalesce(((c.SlsVol_TTL_12/12)-(c.ItemLvlFCVol_1To24/c.Count_FC_Period))/nullif((c.ItemLvlFCVol_1To24/c.Count_FC_Period),0),0)	--- use to compare forecast 13/8/2020	
							
									--when c.Sls_freq  > 0 then coalesce(nullif((c.ItemLvlFCVol_1To24/c.Count_FC_Period-c.SlsVol_TTL_12/12)/(c.SlsVol_TTL_12/12),0),0)						--- use diff from FC vs Sales then compare with Sales volume, to simplify, remove some unnecessary brackets within formula		---30/09/2019	  
									end as Ratio_Sls_FC

								  , case 
									when c.Sls_freq is null then 0
									when c.Sls_freq  = 0 then 0
									--when c.Sls_freq  > 0 then ((c.ItemLvlFCVol_1To24/c.Count_FC_Period)-(c.SlsVol_TTL_12/c.Sls_freq))/(c.SlsVol_TTL_12/c.Sls_freq)		
									--when c.Sls_freq  > 0 then ((c.ItemLvlFCVol_1To24/c.Count_FC_Period))/(c.SlsVol_TTL_12/12)											--- use diff from FC vs Sales then compare with Sales volume		---15/2/2019
									 --  when c.Sls_freq  > 0 then coalesce(nullif((c.ItemLvlFCVol_1To24/c.Count_FC_Period)/(c.SlsVol_TTL_12/12),0),0)	
									   when c.Sls_freq  > 0 then coalesce((c.SlsVol_TTL_12/12)/nullif((c.ItemLvlFCVol_1To24/c.Count_FC_Period),0),0)					--- 13/8/2020
									end as diff_Sls_FC									    ---4/9/2019
									-----
									--,((c.ItemLvlFCVol_TTL_4/4)-(c.SlsVol_TTL_4/4)) t
									--,c.SlsVol_TTL_4/4 as t1

								, case 
									when c.Sls_freq is null then 0
									when c.Sls_freq  = 0 then 0					  
									--when c.Sls_freq  > 0 then coalesce(((c.ItemLvlFCVol_TTL_4/4)-(c.SlsVol_TTL_4/4))/nullif(c.SlsVol_TTL_4/4,0),0)						--- use diff from FC vs Sales then compare with Sales volume		---25/09/2019		-- https://stackoverflow.com/questions/861778/how-to-avoid-the-divide-by-zero-error-in-sql  --Select Case when divisor=0 then null Else dividend / divisor End; But here is a much nicer way of doing it: Select dividend / NULLIF(divisor, 0) ... ; In case you want to return zero, in case a zero devision would happen, you can use: SELECT COALESCE(dividend / NULLIF(divisor,0), 0) FROM sometable
									  when c.Sls_freq  > 0 then coalesce(((c.SlsVol_TTL_4/4)-(c.ItemLvlFCVol_TTL_4/4))/nullif(c.ItemLvlFCVol_TTL_4/4,0),0)	
									end as Ratio_Sls_FC_4mth

								  , case 
									when c.Sls_freq is null then 0
									when c.Sls_freq  = 0 then 0
							
									  -- when c.Sls_freq  > 0 then coalesce((c.ItemLvlFCVol_TTL_4/4)/nullif(c.SlsVol_TTL_4/4,0),0)					--- 12/8/2020
										  when c.Sls_freq  > 0 then coalesce((c.SlsVol_TTL_4/4)/nullif((c.ItemLvlFCVol_TTL_4/4),0),0)					--- 13/8/2020						
									end as diff_Sls_FC_4mth									    
									------
								  ,(c.ItemLvlFCVol_1To24/c.Count_FC_Period) as FC_Avg_mth
								  ,(c.SlsVol_TTL_12/12) as Sales_Avg_mth
						   
									,c.SlsVol_ttl_12*c.price as SlsAmt_12
									,c.ItemLvlFCVol_1To24*c.price as FCAmt_1To24
									--,combVol.SOHVol*combVol.cost as SOHAmt										 
									,c.SOHVal as SOHAmt													--14/12/2018,note better use SOHVal which is original 'stockvalue' in R55ML345 table, some items has accounting impact like 'SCRA' item has stockvalue of 0 even though it has SOH quantities and cost'; there might be other situation where simply use SOH Qty * Cost will probably not be used by accounting as inventory value.  --14/12/2018					
									,c.Cost * c.ItemLvlFCVol_1To24 as StkAmt_12
									from combVol c left join pareto p on c.ItemNumber = p.ItemNumber
													--left join JDE_DB_Alan.FCPRO_SafetyStock ss on c.ItemNumber = ss.ItemNumber
													left join JDE_DB_Alan.vw_SafetyStock ss on c.ItemNumber = ss.ItemNumber						--- has to use 'vw_SafetyStock' to fetch only 1 records per item/SKU to avoid duplicate because 'SafetyStock' table contains all history for SS each item/SKU.
							)
				 --select * from comb_Amt where comb_Amt.SlsAmt_12 is null or comb_Amt.FCAmt_24 is null or SOHAmt  is null
				 --select * from comb_Amt v  where v.ItemNumber in ('18.018.027')
	
				 -------------------------------------------------------------------------------------

				,fl_ as ( select * 
									,sum(c.SlsVol_TTL_12) over() as SlsVol_Grd
									,sum(c.ItemLvlFCVol_1To24) over() as FCVol_Grd
									,sum(c.SOHVol) over() as SOHVol_Grd
									,sum(c.SlsAmt_12) over() as SlsAmt_Grd
									,sum(c.FCAmt_1To24) over() as FCAmt_Grd
									,sum(c.SOHAmt) over() as SOHAmt_Grd
								from comb_Amt c)

				--- Get Supplier name ---
				,_mas as ( select a.ShortItemNumber
							,a.ItemNumber
							,a.PrimarySupplier
							,case a.PlannerNumber when '20072' then 'Salman Saeed'
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
							,a.PlannerNumber
							,a.Description
							,a.LeadtimeLevel as LeadTime
							,a.UOM,a.ConvUOM,a.ConversionFactor
							,a.StockingType
							,a.SellingGroup,a.FamilyGroup,a.Family
							,a.SellingGroup_,a.FamilyGroup_,a.Family_0					
							,row_number() over(partition by a.itemnumber order by a.itemnumber) as rn 
							,a.SupplierName
							,a.Colour
							
						 --from JDE_DB_Alan.Master_ML345 a)
						   from JDE_DB_Alan.vw_Mast a )									--- 9/11/2018

				,mas as ( select * 
						from _mas where rn =1 )

				,_fl as ( select fl_.*
							   ,m.ShortItemNumber	
							   ,m.PrimarySupplier
							   ,m.PlannerNumber
							   ,m.Owner_,m.Description,m.SellingGroup,m.SupplierName,m.UOM,m.ConvUOM,m.ConversionFactor
							   ,m.StockingType,m.LeadTime
							 ,m.FamilyGroup_,m.Family_0,m.Colour,m.FamilyGroup,m.Family
							  ,getdate() as ReportDate

							from fl_ left join mas m on fl_.ItemNumber = m.ItemNumber) 

		
				------ Get New Prouduct Info ----------		19/2/2019	 
				,np as ( select distinct a.ItemNumber,'NP' as ProductCat from JDE_DB_Alan.vw_NP_FC_Analysis a )

				,_fl_ as ( select _fl.*
							   ,case when np.ProductCat is null then 'Not_NP'
									 when np.ProductCat is not null then np.ProductCat
								end as Prod_Cat

						 from _fl left join np  on _fl.ItemNumber = np.ItemNumber

						 )

		
				  --- Get Planning parameters --- 20/1/2021
				,flpl as ( select t.*
								 ,pm.Jde_ABC_1_Sls
								 ,pm.Order_Policy,pm.Order_Policy_Description,pm.Order_Policy_Value
								 ,pm.Planning_Code,pm.Planning_Code_Description
								 ,pm.Planning_Fence_Rule,pm.Plan_Time_Fence,pm.Planning_Fence_Rule_Description
								 ,pm.Msg_Time_Fence,pm.ROP,pm.ROP_EOQ,pm.Order_Multiple
							 from _fl_ as t left join JDE_DB_Alan.vw_Mast_Planning pm on t.ShortItemNumber = pm.Short_Item_Number )    

        
				   ---=================================---
				   ------- Add Purchase Order ( PO) ----------    	16/10/2019
				   ---=================================---

				 ,PO_Open as (
	 					  -- select tb.ItemNumber,tb.DataType1,tb.PODate_,tb.poyr,tb.pomth,tb.BuyerName,tb.BuyerNumber,tb.TransactionOriginator,tb.TransactionOrigName,tb.SupplierName
						 select tb.ItemNumber
								--,tb.DataType1,tb.PODate_,tb.poyr,tb.pomth,tb.SupplierName			-- 6/12/2018, cater for change Planner leaving business
								--,sum(tb.PO_Volume) as PO_Vol
								,sum(tb.QuantityOpen) as PO_Vol				--7/12/2018
								,sum(tb.quantityopen * m.StandardCost) as PO_Amt
						 from JDE_DB_Alan.vw_OpenPO tb left join JDE_DB_Alan.vw_Mast m on tb.ItemNumber = m.ItemNumber
							-- where tb.ItemNumber in  ( select splitdata from JDE_DB_Alan.dbo.fnSplitString(@Item_id,','))	
						--  group by tb.ItemNumber,tb.DataType1,tb.PODate_,tb.poyr,tb.pomth,tb.BuyerName,tb.BuyerNumber,tb.TransactionOriginator,tb.TransactionOrigName,tb.SupplierName
							-- where tb.ItemNumber in ('52.002.000')
						group by tb.ItemNumber
									--,tb.DataType1,tb.PODate_,tb.poyr,tb.pomth,tb.SupplierName			-- 6/12/2018, cater for change Planner leaving business
							
						)
				 --select * from po

          
				   ---================================================================================================---
					--- Add Open Sales customer Order ( SO ) ( does not differentiate by month - only SKU level )  ----------    	18/10/2019
					----- Note this funtion will also ignore null value when use 'Sum' aggregation function ----- https://blog.sqlauthority.com/2015/02/13/sql-server-warning-null-value-is-eliminated-by-an-aggregate-or-other-set-operation/
				   ---================================================================================================---
				 ,SO_Open as ( select s.Item_Number,sum(isnull(s.Qty_Ordered_LowestLvl,0) ) as Qty_OpenSO
													,sum(isnull(s.Extended_Cost,0)) as Amt_Cost_OpenSO
													,sum(isnull(s.Extended_Price,0)) as Amt_Price_OpenSO
								from JDE_DB_Alan.vw_SO_Inquiry_Super s
								where s.LastStatus in ('520','540','900','902','904')					--Open customer orders --> '520' Sales order entered;'540' Ready to pick;'900' Back order in S/O Entry
								--where s.LastStatus not in ('520','540','900')
								--where s.LastStatus in ('902','904','912','980')				-- '902' Backorder in Commitments;'904' Backorder in Ship. Conf.;'912'Added in Commitments';'980' Canceled in Order Entry
								  --  and (s.Item_Number is not null) and (s.Item_Number <>'')
									 and s.Item_Number <>''									--- exclude some line where Item no is blank ( not Null )
									-- and s.Item_Number in ('43.207.637M')
								group by s.Item_Number

								)


				  ,fl_ord_comb as														--- Now combine all orders data ( PO and SO )
							 ( select a.*
									   ,b.PO_Vol,b.PO_Amt
									   ,c.Qty_OpenSO,c.Amt_Price_OpenSO 
								from flpl a left join PO_Open b on a.ItemNumber = b.ItemNumber
											left join SO_Open c on a.ItemNumber = c.Item_Number
							  )

		 
				 --- **************************************** ---
				 --- Get your ROP Analysis ---- 19/3/2021
				  --- **************************************** ---

				 --- How to determine monthly fc  ? Note most ROP item is C items & has less than 3 sales and sales pattern is sparadic & volatile & unpredictable past sales ( ie month in which sales occured is random; quantity can be wildly different for those 3 months  )
				 --- 1. if use immediate 4 months FC, there could run risk of 0 forecast, or very high fc
				 --- 2. if use average 12 mth fc, in low season your forecast could be too high, whilst in peak season your fc will be low that is not ideal for Awning category - fc is diluted
				 --- 3. more sophiscated approach is break down 12 months into peak and non peak season and apply different calculations

				
						--- First Indentify and Determine ROP Items ---
				,_flRop as (  select a.*
						    ,case																	
								when a.Sls_freq <= 3 and a.Pareto in ('C') and a.Prod_Cat in ('Not_NP') and a.StockingType not in  ('Q','M','O','U') then 'ROP'		  --- use 'Not in' SQL Clause to remove MTO/BTO items; be careful of 'Null' value	-- Q is BTO and M is MTO,need to excluded from SS  --- 25/3/2021
								--when a.Sls_freq <= 3 and a.Pareto in ('C') and a.Prod_Cat in ('Not_NP') and a.StockingType in ('P','S','K') then 'ROP'			  --- Use 'in' SQL Clause to remove MTO/BTO items;        -- K is kit/parent item  
								--when a.Sls_freq <= 3 and a.Pareto in ('C') and a.Prod_Cat in ('Not_NP')	then 'ROP'												  --- Original code. If has less than 4 ( 1,2,3) sales hits, then ROP. This condition can be changed say less than 3 ( 2,1 )
								--when a.Sls_freq  >=4 then 'Non_ROP'														--- if more than 3 ( 4,5,6, ... ... ) then Not ROP.  This condition can be changed say greater than 2 (3,4,5,6,7 ... ... )
								else 'Non_ROP'																				--- if A/B has less than 4 hits, it will not qualify for ROP
							 end as ROP_Validate
						 						
						from fl_ord_comb a		
						)	      	


					  --- Second determine Critical values for Identitied ROP items ie, ROP qty, ROP $, EOQ ( if needed by Alan - Formula/Algorithm ) etc.
				,flRop_ as (  select a.*
								,case a.ROP_Validate
									 when 'ROP' then (a.SS_Adj + (a.FC_Avg_mth/30)*a.LeadTime)					--- how to determine monthly fc ? 			
									 when 'Non_ROP' then 0														
								 end as ROP_Suggt_Qty
					
								,case a.ROP_Validate
									 when 'ROP' then (a.SS_Adj + (a.FC_Avg_mth/30)*a.LeadTime)*a.Cost			--- how to determine monthly fc ? 					
									 when 'Non_ROP' then 0														
								 end as  ROP_Suggt_Dollars
						 					
							from _flrop a		
						  ) 				  
						 -- select * from _flRop a where a.ROP_Validate in ('ROP') and a.PlannerNumber in ('20005','20071','20072')
				  
             

					 --- Thirdly ( Finally) get your concise ROP records for HD Planners only ---
				,flRop as ( 
						 select  a.ShortItemNumber,a.ItemNumber,a.Sls_freq,a.SlsVol_TTL_12,a.ItemLvlFCVol_1To24,a.SlsVol_TTL_4,a.ItemLvlFCVol_TTL_4
								,a.StockingType,a.Pareto,a.SS_Adj,a.LeadTime
								,a.ROP,a.ROP_EOQ
								,a.ROP_Validate,a.ROP_Suggt_Qty,a.ROP_Suggt_Dollars
								,a.SOHVol,a.SOHVal,a.SOHAmt,a.Cost,a.Price					    -- A.sohAmt  is value calculated by Jde
								,a.Count_FC_Period

							   ,a.UOM,a.SOHWksCover,a.FamilyGroup_,a.Family_0
							   ,a.rnk,a.Ratio_Sls_FC,a.diff_Sls_FC
							   ,a.Ratio_Sls_FC_4mth,a.diff_Sls_FC_4mth
							   ,a.Sales_Avg_mth,a.FC_Avg_mth
							   --,a.SlsAmt_12,a.FCAmt_1To24,a.StkAmt_12						-- a.StkAmt_12 is inventory value in next 12 months
							  -- ,a.SlsVol_Grd,a.FCVol_Grd,a.SOHVol_Grd
							  -- ,a.SlsAmt_Grd,a.FCAmt_Grd,a.SOHAmt_Grd
							   ,a.PlannerNumber
							   ,a.Owner_,a.PrimarySupplier,a.SupplierName,a.Description,a.Colour,a.SellingGroup
							   ,a.Family,a.FamilyGroup
							   ,a.Prod_Cat
					   
							   ,a.PO_Vol,a.PO_Amt
							   ,a.Qty_OpenSO,a.Amt_Price_OpenSO

							   ,a.Order_Policy,a.Order_Policy_Description,a.Order_Policy_Value
								,a.Planning_Code,a.Planning_Code_Description
								,a.Planning_Fence_Rule,a.Planning_Fence_Rule_Description,a.Plan_Time_Fence
								,a.Msg_Time_Fence,a.Order_Multiple,a.Jde_ABC_1_Sls

								 --,a.ConvUOM,a.ConversionFactor

						from flRop_ a 

						where a.ROP_Validate in ('ROP')
							   and a.PlannerNumber in ('20005','20071','20072')				--- All planners,All A/B/C with Sales less than 4 hits( 2,251) ; only HD planners ( 1,574 inlcuding A/B/C )
							  -- and a.Pareto in ('C')										--- C Pareto only C f( 1,388 )	- HD planners only
							  -- and a.Prod_Cat in ('Not_NP')								--- If further exclude New Products and Only C items ( 1,248 SKU )  - NP Elegibility will be calculated each month in order to keep in line with dynamic of NP product life cycle - each month they may new 'NP' born ( 'Enter' into existence); and each month there are old 'NP' expired/become matured ( thus 'Exit' to become bigger part of pool ) 
		   
						)		

		
				  ------- Final table ------ 19/3/2021
				   ---For Portfolio report - To pick data from 'flRop_', Not 'flRop' becasue you this is portfolio report,you want to pick All data, not just ROP SKUs---
                   ---For ROP report	   - To pick data from 'flRop', Not 'flRop_' becasue you this is ROP report,you do not want to pick All data, just ROP SKUs---

				,fltb as 
				(          
				--select a.ShortItemNumber,a.ItemNumber,a.Order_Policy,a.Order_Policy_Value,a.Planning_Code,a.Planning_Fence_Rule,a.Plan_Time_Fence,a.Jde_ABC_1_Sls		--- For ROP Repport- these columns are for Upload Jde for ROP project
			     
				 select a.ItemNumber,a.Sls_freq,a.SlsVol_TTL_12,a.ItemLvlFCVol_1To24,a.SlsVol_TTL_4,a.ItemLvlFCVol_TTL_4			-- For Portfolio report
							,a.Sales_Avg_mth,a.FC_Avg_mth
						, a.SOHWksCover
						,a.StockingType,a.Pareto,a.SS_Adj
						,a.ROP_Validate,a.ROP,a.ROP_EOQ
						,a.rnk,a.Ratio_Sls_FC,a.diff_Sls_FC
						,a.Ratio_Sls_FC_4mth,a.diff_Sls_FC_4mth

						,a.SOHVol,a.SOHVal,a.SOHAmt,a.Cost,a.Price					    -- A.sohAmt  is value calculated by Jde								
						,a.LeadTime,a.Count_FC_Period

						,a.UOM,a.FamilyGroup_,a.Family_0							  
							  
						,a.SlsAmt_12,a.FCAmt_1To24,a.StkAmt_12						-- a.StkAmt_12 is inventory value in next 12 months
						-- ,a.SlsVol_Grd,a.FCVol_Grd,a.SOHVol_Grd
						-- ,a.SlsAmt_Grd,a.FCAmt_Grd,a.SOHAmt_Grd
						,a.PlannerNumber
						,a.Owner_,a.PrimarySupplier,a.SupplierName,a.Description,a.Colour,a.SellingGroup
						,a.Family,a.FamilyGroup
						,a.Prod_Cat
					   
						,a.PO_Vol,a.PO_Amt
						,a.Qty_OpenSO,a.Amt_Price_OpenSO

						,a.Order_Policy,a.Order_Policy_Description,a.Order_Policy_Value
						,a.Planning_Code,a.Planning_Code_Description
						,a.Planning_Fence_Rule,a.Planning_Fence_Rule_Description,a.Plan_Time_Fence
						,a.Msg_Time_Fence,a.Order_Multiple,a.Jde_ABC_1_Sls

							--,a.ConvUOM,a.ConversionFactor

					from flRop_ a												-- For Portfolio report
					--from flRop a												--- For ROP Repport		
				 )



				 select *
				 from fltb a

				--where a.ItemNumber in ('42.210.031','34.249.000','26.529.000')		 																			
			  

				--where _fl.SellingGroup in ('WC','AD')
				-- where _fl.ItemNumber in ('42.210.031')
				-- where fl_.ItemNumber like ('%85053100%')	
				-- where fl_.ItemNumber in ('7495500001')	
				-- where fl_.ItemNumber in (2974000000'	
				-- where fl_.ItemNumber in ('24.057.165s')					-- cannot find '24.057.165s' in ML345 file hence later table join will yield Null Value causing potential issue in coding - 29/1/18
		  
				-- m.PrimarySupplier in ( select data from JDE_DB_Alan.dbo.Split(@Supplier_id,','))
				--	fl_.ItemNumber in ( select data from JDE_DB_Alan.dbo.Split(@Item_id,','))
			   --order by fl_.SlsAmt_12 desc
			   --  order by fl_.rnk
	 			   order by a.ItemLvlFCVol_1To24 desc



		   --- does not work properly ---13/2/2020
			--order by 			 
			--			case when @OrderByClause ='ParetoAndFCAmt' then a.Pareto end asc,a.FCAmt_1To24 desc,
			--			case when @OrderByClause ='ParetoAndFCQty' then a.ItemLvlFCVol_1To24 end asc,a.Pareto desc,
			--			case when @OrderByClause ='rnk' then a.rnk end asc,
			--			case when @OrderByClause ='SlsAmt_12' then a.SlsAmt_12 end desc,
			--			case when @OrderByClause ='SOHAmt' then a.SOHAmt end desc,
			--			case when @OrderByClause ='Ratio_Sls_FC' then a.Ratio_Sls_FC end desc
	 
	 
	else if @Item_id is not null and @Start is not null and @end is not null --and @OrderByClause is not null
	begin

	    

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
						select top 48 t
									--,RIGHT('00'+CAST(n AS VARCHAR(3)),2) nmb,cast(SUBSTRING(REPLACE(CONVERT(char(10),start,126),'-',''),1,6) as integer) as [StartDate]		-- original name of '[StartDate]' in template
									,RIGHT('00'+CAST(n AS VARCHAR(3)),2) nmb,cast(SUBSTRING(REPLACE(CONVERT(char(10),start,126),'-',''),1,6) as integer) as [StartDt2]			-- 5/9/2018 , changed Name to 'StartDt2'
									,RIGHT('00'+CAST(n AS VARCHAR(3)),2) nmbr,cast(SUBSTRING(REPLACE(CONVERT(char(10),start,126),'-',''),1,6) as integer) as [StartDt]			-- 6/8/2020 , changed Name to 'StartDt2'
									,DATENAME(mm,start) MnthName,DATENAME(yyyy,start) YearName from CalendarFrame
					)
				 --select * from MonthlyCalendar

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



				,itm as ( select distinct h.ItemNumber as ItemNumber_ from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h )
				,list as ( select * from itm cross join MonthlyCalendar cldr 
							where --StartDate						-- original name of '[StartDate]' in template 
									StartDt
									 between replace(convert(varchar(8), DATEADD(mm, DATEDIFF(m,0,GETDATE())-12,0),126),'-','' )			-- last 12 months		
													 and  replace(convert(varchar(8), DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-','' )		-- last 12 months
						  )		
		
				 ,mylist as ( select * from itm cross join MthCal )	
		 	  
				 --select * from list m where m.ItemNumber_ in ('34.252.000')	
				-- select * from mylist m where m.ItemNumber_ in ('34.252.000')
		 		  	     
				----------------- Padded Item with all Months --------------------		
		  

					 --- below is tb padded Item with all Months ---
				,hist as																													
				(  select m.ItemNumber_
				            
							,h.CYM,h.CY,h.Month
							,h.ReportDate
							,case when h.SalesQty is null then 0 else h.SalesQty end as SalesQty_				
							,getdate() as ReportDate_												-- there is no different version of history, so do not bother to use old ReportData in History table UNLESS you need to join back to History table using ReportData as a key --- 5/9/2018
							,m.StartDt
							--,m.YY, m.rnk,m.month as mth						  
							,case 
								when h.CYM is null	then cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-',''),1,6) as integer) 		-- why use this ?						
								else h.CYM
							end as CYM_
							,case 
								when h.CYM is null	then m.StartDt					
								else h.CYM
							end as CYM_2
							,m.YY
							,m.rnk

					--from list m left join JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h on m.StartDt2 = h.CYM and  m.ItemNumber_ = h.ItemNumber			--- old  6/8/2020
					 from mylist m left join JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h on m.StartDt = h.CYM and  m.ItemNumber_ = h.ItemNumber			--- new 7/8/2020
					--where    list.StartDt = cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-',''),1,6) as integer)			-- Watch out use List.StartDt Not h.CYM !!!   --- 29/5/2018
							-- h.CYM = '201804' and																													-- Performance issue ?
							--c.rnk =24																												-- last month ( for last month Sales)
						--where  m.StartDt <= cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-',''),1,6) as integer)    --- old 6/9/2020  
						  where m.rnk <25 and m.rnk >12
						)

					-- select * from hist where hist.ItemNumber_ in ('38.001.001')

				--select * from hist h where h.ItemNumber_ in ('34.252.000')

				,histy as 
					( select x.ItemNumber_
					,count(isnull(x.CYM_2,0)) TTL_SlsMths			-- Or you can use --> count(isnull(x.StartDt2,0)) TTL_SlsMths
					,sum( case when salesqty_ <>0 then 1 else 0 end ) as Sls_freq
					,sum(x.SalesQty_) SlsVol_TTL_12 
					,sum( case when x.yy <5 then x.SalesQty_ else 0 end ) SlsVol_TTL_4 
					from hist x 
					group by x.ItemNumber_)
				--select * from histy where histy.ItemNumber_ in ('03.986.000','38.001.001')
				-- select * from histy where histy.ItemNumber_ in ('34.252.000')


				   --- remove 'SCRA' product by using 'except' or you can using left join, use 'not in' maybe not a best choice ---  14/12/2018
				,_stk as ( select * from JDE_DB_Alan.vw_Mast a where a.GLCat in ('SCRA') )
				,stk_ as ( select a.ItemNumber,a.QtyOnHand,a.StockValue from JDE_DB_Alan.vw_Mast a 
							except 
						   select b.ItemNumber as ItemNumber_,b.QtyOnHand as QtyOnHand_ ,b.StockValue as StockValue_ from _stk b
						   )

				,stk as (
							select a.ItemNumber,sum(coalesce(a.QtyOnHand,0)) SOHVol,sum(coalesce(a.StockValue,0)) SOHVal				--- 14/12/2018
							from stk_ a 
							group by a.ItemNumber
					
							)	
					
				--select * from JDE_DB_Alan.FCPRO_Fcst f where f.ItemNumber in ('34.252.000') and f.DataType1 in ('Adj_FC')	
				-- select * from JDE_DB_Alan.vw_FC f where f.ItemNumber in ('34.252.000') 
        

				 ---- No need since fc table is already clean and padded with all month ------
				--,fc_itm as ( select distinct f.ItemNumber as ItemNumber_ from JDE_DB_Alan.vw_FC f )
				--,fc_list as ( select * from fc_itm cross join MthCal l where l.rnk > 24 and l.rnk < 49 )	
				--select * from fc_list l where l.ItemNumber_ in ('34.252.000')

				--,myfcVol as (select * from fc_list l left join JDE_DB_Alan.vw_FC f on l.ItemNumber_ = f.ItemNumber and l.StartDt = f.FCDate2_
								--where l.rnk > 24 and l.rnk < 49
								--)		
			   --select * from fc_Vol_ f where f.ItemNumber in ('34.252.000') 
			   ,f_ as (
						   select f.*,rank() over (partition by DataType1,ItemNumber  order by date asc ) as rnk	 
							from JDE_DB_Alan.FCPRO_Fcst f 
							where  f.DataType1 in ('Adj_FC')							

						)

				,_f as ( select
								f.DataType1,f.ItemNumber
								,sum( case when f.rnk <5 then f.Value else 0 end ) ItemLvlFCVol_TTL_4 
								--,sum(f.Value) over (partition by ItemNumber order by rnk ) as ItemLvlFCVol_TTL_4 
							from f_ f
							group by f.ItemNumber,f.DataType1

						)

			
				,my_fc_Vol as  
					( select f.DataType1,f.ItemNumber,sum(isnull(f.value,0)) as ItemLvlFCVol_1To24,count(isnull(f.Date,0)) Count_FC_Period   ---TTL_FCMths	
						 from JDE_DB_Alan.FCPRO_Fcst f					-- 22/1/2018 did not have  condition before --> where fct.DataType1 like ('%Adj_FC%')	
						 --  from _fc f
						  where f.DataType1 like ('%Adj_FC%')			-- 26/2/2018
								--and f.Date between '2021-03-01' and '2022-02-01'			-- For Signature New Product Post Launch Analysis --- 5/6/2018
								  and f.Date between @Start and @End
						group by f.DataType1,f.ItemNumber)	

		
				--- join table of 4 month FC with main FC table ---				
				,fc_Vol  as 
						(	Select f.*,_f.ItemLvlFCVol_TTL_4
								from my_fc_Vol f left join _f on f.ItemNumber = _f.ItemNumber	 

							)


		
				,fcVol as (	select fc_Vol.ItemNumber
								,fc_Vol.DataType1							
								,fc_Vol.ItemLvlFCVol_1To24	
								,fc_Vol.ItemLvlFCVol_TTL_4						
								,fcprt.Pareto
								,fc_Vol.Count_FC_Period
								--,sum(f.value) FCVol_ttl_24
							--from JDE_DB_Alan.FCPRO_Fcst f 		
							from fc_Vol inner join JDE_DB_Alan.FCPRO_Fcst_Pareto fcprt on fc_Vol.DataType1 = fcprt.DataType1 and fc_Vol.ItemNumber = fcprt.ItemNumber
					
							where fc_Vol.DataType1 like ('%Adj_FC%')		--26/2/2018
							--where fc_Vol.DataType1 like ('%default%')
							--where f.DataType1 like ('%point%') 		
							--group by f.ItemNumber,f.DataType1
								)

					--	select * from fcVol where fcvol.ItemNumber = '34.252.000'
						--where fcVol.ItemLvlFCVol_24 is null		-- where fc.ItemNumber = '18.615.024' --- fc about 10125 record

					   --- Item Level ----
				,comb_Vol as (select fc_Vol.ItemNumber,histy.SlsVol_TTL_12,histy.SlsVol_TTL_4,histy.Sls_Freq								
										,fc_Vol.ItemLvlFCVol_1To24
										,fc_Vol.ItemLvlFCVol_TTL_4
										,fc_Vol.Count_FC_Period
										,stk.SOHVol
										,stk.SOHVal
										--,coalesce(stk.SOHVol/(nullif(fc_Vol.ItemLvlFCVol_1To24/24,0)),0) as SOHWksCover						--if divisor is 0	
										,coalesce(stk.SOHVol/(nullif(fc_Vol.ItemLvlFCVol_1To24/fc_Vol.Count_FC_Period,0)),0) as SOHWksCover			--if divisor is 0 And FC month count varies --- 19/7/2018					 
								from fc_Vol left join histy on fc_Vol.ItemNumber = histy.ItemNumber_
											left join stk on stk.ItemNumber = histy.ItemNumber_
								)
				-- select * from comb_vol  where comb_Vol.SOHWksCover is null
				-- where comb_vol.ItemNumber = ('03.986.000')

				--select * from comb_Vol v where v.ItemNumber in ('34.252.000')   --- ok to run

				,combVol as ( select comb_Vol.*,px.StandardCost as Cost,px.WholeSalePrice as Price
								from comb_Vol left join JDE_DB_Alan.vw_Mast px on comb_Vol.ItemNumber = px.ItemNumber								--9/1/19
								--from comb_Vol left join JDE_DB_Alan.Px_AWF_HD_MT_FCPro_upload px on comb_Vol.ItemNumber = px.ItemNumber	        --8/1/19
								)

				,pareto as ( select p.ItemNumber,p.rnk,p.DataType1,p.Pareto from JDE_DB_Alan.FCPRO_Fcst_Pareto p where p.DataType1 like ('%Adj_FC%')			--26/2/2018
								)

				,comb_Amt as ( select c.*,P.Pareto,p.rnk,ss.SS_Adj

								  , case 
									when c.Sls_freq is null then 0
									when c.Sls_freq  = 0 then 0
								  --when c.Sls_freq  > 0 then ((c.ItemLvlFCVol_1To24/c.Count_FC_Period)-(c.SlsVol_TTL_12/c.Sls_freq))/(c.SlsVol_TTL_12/c.Sls_freq)		
								  --when c.Sls_freq  > 0 then ((c.ItemLvlFCVol_1To24/c.Count_FC_Period)-(c.SlsVol_TTL_12/12))/(c.SlsVol_TTL_12/12)				--- use diff from FC vs Sales then compare with Sales volume		---15/2/2019
								  --when c.Sls_freq  > 0 then coalesce((isnull(c.ItemLvlFCVol_1To24/c.Count_FC_Period,0)-isnull(c.SlsVol_TTL_12/12,0))/isnull(c.SlsVol_TTL_12/12,0),0)			--- use diff from FC vs Sales then compare with Sales volume		---24/09/2019	   
								 -- when c.Sls_freq  > 0 then coalesce(nullif(((c.ItemLvlFCVol_1To24/c.Count_FC_Period)-(c.SlsVol_TTL_12/12))/(c.SlsVol_TTL_12/12),0),0)						--- use diff from FC vs Sales then compare with Sales volume		---25/09/2019		-- https://stackoverflow.com/questions/861778/how-to-avoid-the-divide-by-zero-error-in-sql  --Select Case when divisor=0 then null Else dividend / divisor End; But here is a much nicer way of doing it: Select dividend / NULLIF(divisor, 0) ... ; In case you want to return zero, in case a zero devision would happen, you can use: SELECT COALESCE(dividend / NULLIF(divisor,0), 0) FROM sometable
									when c.Sls_freq  > 0 then coalesce(((c.SlsVol_TTL_12/12)-(c.ItemLvlFCVol_1To24/c.Count_FC_Period))/nullif((c.ItemLvlFCVol_1To24/c.Count_FC_Period),0),0)	--- use to compare forecast 13/8/2020	
							
									--when c.Sls_freq  > 0 then coalesce(nullif((c.ItemLvlFCVol_1To24/c.Count_FC_Period-c.SlsVol_TTL_12/12)/(c.SlsVol_TTL_12/12),0),0)						--- use diff from FC vs Sales then compare with Sales volume, to simplify, remove some unnecessary brackets within formula		---30/09/2019	  
									end as Ratio_Sls_FC

								  , case 
									when c.Sls_freq is null then 0
									when c.Sls_freq  = 0 then 0
									--when c.Sls_freq  > 0 then ((c.ItemLvlFCVol_1To24/c.Count_FC_Period)-(c.SlsVol_TTL_12/c.Sls_freq))/(c.SlsVol_TTL_12/c.Sls_freq)		
									--when c.Sls_freq  > 0 then ((c.ItemLvlFCVol_1To24/c.Count_FC_Period))/(c.SlsVol_TTL_12/12)											--- use diff from FC vs Sales then compare with Sales volume		---15/2/2019
									 --  when c.Sls_freq  > 0 then coalesce(nullif((c.ItemLvlFCVol_1To24/c.Count_FC_Period)/(c.SlsVol_TTL_12/12),0),0)	
									   when c.Sls_freq  > 0 then coalesce((c.SlsVol_TTL_12/12)/nullif((c.ItemLvlFCVol_1To24/c.Count_FC_Period),0),0)					--- 13/8/2020
									end as diff_Sls_FC									    ---4/9/2019
									-----
									--,((c.ItemLvlFCVol_TTL_4/4)-(c.SlsVol_TTL_4/4)) t
									--,c.SlsVol_TTL_4/4 as t1

								, case 
									when c.Sls_freq is null then 0
									when c.Sls_freq  = 0 then 0					  
									--when c.Sls_freq  > 0 then coalesce(((c.ItemLvlFCVol_TTL_4/4)-(c.SlsVol_TTL_4/4))/nullif(c.SlsVol_TTL_4/4,0),0)						--- use diff from FC vs Sales then compare with Sales volume		---25/09/2019		-- https://stackoverflow.com/questions/861778/how-to-avoid-the-divide-by-zero-error-in-sql  --Select Case when divisor=0 then null Else dividend / divisor End; But here is a much nicer way of doing it: Select dividend / NULLIF(divisor, 0) ... ; In case you want to return zero, in case a zero devision would happen, you can use: SELECT COALESCE(dividend / NULLIF(divisor,0), 0) FROM sometable
									  when c.Sls_freq  > 0 then coalesce(((c.SlsVol_TTL_4/4)-(c.ItemLvlFCVol_TTL_4/4))/nullif(c.ItemLvlFCVol_TTL_4/4,0),0)	
									end as Ratio_Sls_FC_4mth

								  , case 
									when c.Sls_freq is null then 0
									when c.Sls_freq  = 0 then 0
							
									  -- when c.Sls_freq  > 0 then coalesce((c.ItemLvlFCVol_TTL_4/4)/nullif(c.SlsVol_TTL_4/4,0),0)					--- 12/8/2020
										  when c.Sls_freq  > 0 then coalesce((c.SlsVol_TTL_4/4)/nullif((c.ItemLvlFCVol_TTL_4/4),0),0)					--- 13/8/2020						
									end as diff_Sls_FC_4mth									    
									------
								  ,(c.ItemLvlFCVol_1To24/c.Count_FC_Period) as FC_Avg_mth
								  ,(c.SlsVol_TTL_12/12) as Sales_Avg_mth
						   
									,c.SlsVol_ttl_12*c.price as SlsAmt_12
									,c.ItemLvlFCVol_1To24*c.price as FCAmt_1To24
									--,combVol.SOHVol*combVol.cost as SOHAmt										 
									,c.SOHVal as SOHAmt													--14/12/2018,note better use SOHVal which is original 'stockvalue' in R55ML345 table, some items has accounting impact like 'SCRA' item has stockvalue of 0 even though it has SOH quantities and cost'; there might be other situation where simply use SOH Qty * Cost will probably not be used by accounting as inventory value.  --14/12/2018					
									,c.Cost * c.ItemLvlFCVol_1To24 as StkAmt_12
									from combVol c left join pareto p on c.ItemNumber = p.ItemNumber
													--left join JDE_DB_Alan.FCPRO_SafetyStock ss on c.ItemNumber = ss.ItemNumber
													left join JDE_DB_Alan.vw_SafetyStock ss on c.ItemNumber = ss.ItemNumber							--- has to use 'vw_SafetyStock' to fetch only 1 records per item/SKU to avoid duplicate because 'SafetyStock' table contains all history for SS each item/SKU.
							)
				 --select * from comb_Amt where comb_Amt.SlsAmt_12 is null or comb_Amt.FCAmt_24 is null or SOHAmt  is null
				 --select * from comb_Amt v  where v.ItemNumber in ('18.018.027')
	
				 -------------------------------------------------------------------------------------

				,fl_ as ( select * 
									,sum(c.SlsVol_TTL_12) over() as SlsVol_Grd
									,sum(c.ItemLvlFCVol_1To24) over() as FCVol_Grd
									,sum(c.SOHVol) over() as SOHVol_Grd
									,sum(c.SlsAmt_12) over() as SlsAmt_Grd
									,sum(c.FCAmt_1To24) over() as FCAmt_Grd
									,sum(c.SOHAmt) over() as SOHAmt_Grd
								from comb_Amt c)

				--- Get Supplier name ---
				,_mas as ( select a.ShortItemNumber
							,a.ItemNumber
							,a.PrimarySupplier
							,case a.PlannerNumber when '20072' then 'Salman Saeed'
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
							,a.PlannerNumber
							,a.Description
							,a.LeadtimeLevel as LeadTime
							,a.UOM,a.ConvUOM,a.ConversionFactor
							,a.StockingType
							,a.SellingGroup,a.FamilyGroup,a.Family
							,a.SellingGroup_,a.FamilyGroup_,a.Family_0					
							,row_number() over(partition by a.itemnumber order by a.itemnumber) as rn 
							,a.SupplierName
							,a.Colour
							
						 --from JDE_DB_Alan.Master_ML345 a)
						   from JDE_DB_Alan.vw_Mast a )									--- 9/11/2018

				,mas as ( select * 
						from _mas where rn =1 )

				,_fl as ( select fl_.*
							   ,m.ShortItemNumber	
							   ,m.PrimarySupplier
							   ,m.PlannerNumber
							   ,m.Owner_,m.Description,m.SellingGroup,m.SupplierName,m.UOM,m.ConvUOM,m.ConversionFactor
							   ,m.StockingType,m.LeadTime
							 ,m.FamilyGroup_,m.Family_0,m.Colour,m.FamilyGroup,m.Family
							  ,getdate() as ReportDate

							from fl_ left join mas m on fl_.ItemNumber = m.ItemNumber) 

		
				------ Get New Prouduct Info ----------		19/2/2019	 
				,np as ( select distinct a.ItemNumber,'NP' as ProductCat from JDE_DB_Alan.vw_NP_FC_Analysis a )

				,_fl_ as ( select _fl.*
							   ,case when np.ProductCat is null then 'Not_NP'
									 when np.ProductCat is not null then np.ProductCat
								end as Prod_Cat

						 from _fl left join np  on _fl.ItemNumber = np.ItemNumber

						 )

		
				  --- Get Planning parameters --- 20/1/2021
				,flpl as ( select t.*
								 ,pm.Jde_ABC_1_Sls
								 ,pm.Order_Policy,pm.Order_Policy_Description,pm.Order_Policy_Value
								 ,pm.Planning_Code,pm.Planning_Code_Description
								 ,pm.Planning_Fence_Rule,pm.Plan_Time_Fence,pm.Planning_Fence_Rule_Description
								 ,pm.Msg_Time_Fence,pm.ROP,pm.ROP_EOQ,pm.Order_Multiple
							 from _fl_ as t left join JDE_DB_Alan.vw_Mast_Planning pm on t.ShortItemNumber = pm.Short_Item_Number )    

        
				   ---=================================---
				   ------- Add Purchase Order ( PO) ----------    	16/10/2019
				   ---=================================---

				 ,PO_Open as (
	 					  -- select tb.ItemNumber,tb.DataType1,tb.PODate_,tb.poyr,tb.pomth,tb.BuyerName,tb.BuyerNumber,tb.TransactionOriginator,tb.TransactionOrigName,tb.SupplierName
						 select tb.ItemNumber
								--,tb.DataType1,tb.PODate_,tb.poyr,tb.pomth,tb.SupplierName			-- 6/12/2018, cater for change Planner leaving business
								--,sum(tb.PO_Volume) as PO_Vol
								,sum(tb.QuantityOpen) as PO_Vol				--7/12/2018
								,sum(tb.quantityopen * m.StandardCost) as PO_Amt
						 from JDE_DB_Alan.vw_OpenPO tb left join JDE_DB_Alan.vw_Mast m on tb.ItemNumber = m.ItemNumber
							-- where tb.ItemNumber in  ( select splitdata from JDE_DB_Alan.dbo.fnSplitString(@Item_id,','))	
						--  group by tb.ItemNumber,tb.DataType1,tb.PODate_,tb.poyr,tb.pomth,tb.BuyerName,tb.BuyerNumber,tb.TransactionOriginator,tb.TransactionOrigName,tb.SupplierName
							-- where tb.ItemNumber in ('52.002.000')
						group by tb.ItemNumber
									--,tb.DataType1,tb.PODate_,tb.poyr,tb.pomth,tb.SupplierName			-- 6/12/2018, cater for change Planner leaving business
							
						)
				 --select * from po

          
				   ---================================================================================================---
					--- Add Open Sales customer Order ( SO ) ( does not differentiate by month - only SKU level )  ----------    	18/10/2019
					----- Note this funtion will also ignore null value when use 'Sum' aggregation function ----- https://blog.sqlauthority.com/2015/02/13/sql-server-warning-null-value-is-eliminated-by-an-aggregate-or-other-set-operation/
				   ---================================================================================================---
				 ,SO_Open as ( select s.Item_Number,sum(isnull(s.Qty_Ordered_LowestLvl,0) ) as Qty_OpenSO
													,sum(isnull(s.Extended_Cost,0)) as Amt_Cost_OpenSO
													,sum(isnull(s.Extended_Price,0)) as Amt_Price_OpenSO
								from JDE_DB_Alan.vw_SO_Inquiry_Super s
								where s.LastStatus in ('520','540','900','902','904')					--Open customer orders --> '520' Sales order entered;'540' Ready to pick;'900' Back order in S/O Entry
								--where s.LastStatus not in ('520','540','900')
								--where s.LastStatus in ('902','904','912','980')				-- '902' Backorder in Commitments;'904' Backorder in Ship. Conf.;'912'Added in Commitments';'980' Canceled in Order Entry
								  --  and (s.Item_Number is not null) and (s.Item_Number <>'')
									 and s.Item_Number <>''									--- exclude some line where Item no is blank ( not Null )
									-- and s.Item_Number in ('43.207.637M')
								group by s.Item_Number

								)


				  ,fl_ord_comb as														--- Now combine all orders data ( PO and SO )
							 ( select a.*
									   ,b.PO_Vol,b.PO_Amt
									   ,c.Qty_OpenSO,c.Amt_Price_OpenSO 
								from flpl a left join PO_Open b on a.ItemNumber = b.ItemNumber
											left join SO_Open c on a.ItemNumber = c.Item_Number
							  )

		 
				 --- **************************************** ---
				 --- Get your ROP Analysis ---- 19/3/2021
				  --- **************************************** ---

				 --- How to determine monthly fc  ? Note most ROP item is C items & has less than 3 sales and sales pattern is sparadic & volatile & unpredictable past sales ( ie month in which sales occured is random; quantity can be wildly different for those 3 months  )
				 --- 1. if use immediate 4 months FC, there could run risk of 0 forecast, or very high fc
				 --- 2. if use average 12 mth fc, in low season your forecast could be too high, whilst in peak season your fc will be low that is not ideal for Awning category - fc is diluted
				 --- 3. more sophiscated approach is break down 12 months into peak and non peak season and apply different calculations


						--- First Indentify and Determine ROP Items ---
				,_flRop as (  select a.*
						    ,case																	
								when a.Sls_freq <= 3 and a.Pareto in ('C') and a.Prod_Cat in ('Not_NP') and a.StockingType not in  ('Q','M','O','U') then 'ROP'		  --- use 'Not in' SQL Clause to remove MTO/BTO items; be careful of 'Null' value	-- Q is BTO and M is MTO,need to excluded from SS  --- 25/3/2021
								--when a.Sls_freq <= 3 and a.Pareto in ('C') and a.Prod_Cat in ('Not_NP') and a.StockingType in ('P','S','K') then 'ROP'			  --- Use 'in' SQL Clause to remove MTO/BTO items;        -- K is kit/parent item  
								--when a.Sls_freq <= 3 and a.Pareto in ('C') and a.Prod_Cat in ('Not_NP')	then 'ROP'												  --- Original code. If has less than 4 ( 1,2,3) sales hits, then ROP. This condition can be changed say less than 3 ( 2,1 )
								--when a.Sls_freq  >=4 then 'Non_ROP'														--- if more than 3 ( 4,5,6, ... ... ) then Not ROP.  This condition can be changed say greater than 2 (3,4,5,6,7 ... ... )
								else 'Non_ROP'																				--- if A/B has less than 4 hits, it will not qualify for ROP
							 end as ROP_Validate
						 						
						from fl_ord_comb a		
						)	      	


					  --- Second determine Critical values for Identitied ROP items ie, ROP qty, ROP $, EOQ ( if needed by Alan - Formula/Algorithm ) etc.
				,flRop_ as (  select a.*
								,case a.ROP_Validate
									 when 'ROP' then (a.SS_Adj + (a.FC_Avg_mth/30)*a.LeadTime)					--- how to determine monthly fc ? 			
									 when 'Non_ROP' then 0														
								 end as ROP_Suggt_Qty
					
								,case a.ROP_Validate
									 when 'ROP' then (a.SS_Adj + (a.FC_Avg_mth/30)*a.LeadTime)*a.Cost			--- how to determine monthly fc ? 					
									 when 'Non_ROP' then 0														
								 end as  ROP_Suggt_Dollars
						 					
							from _flrop a		
						  ) 				  
						 -- select * from _flRop a where a.ROP_Validate in ('ROP') and a.PlannerNumber in ('20005','20071','20072')
				  
             

					 --- Thirdly ( Finally) get your concise ROP records for HD Planners only ---
				,flRop as ( 
						 select  a.ShortItemNumber,a.ItemNumber,a.Sls_freq,a.SlsVol_TTL_12,a.ItemLvlFCVol_1To24,a.SlsVol_TTL_4,a.ItemLvlFCVol_TTL_4
								,a.StockingType,a.Pareto,a.SS_Adj,a.LeadTime
								,a.ROP,a.ROP_EOQ
								,a.ROP_Validate,a.ROP_Suggt_Qty,a.ROP_Suggt_Dollars
								,a.SOHVol,a.SOHVal,a.SOHAmt,a.Cost,a.Price					    -- A.sohAmt  is value calculated by Jde
								,a.Count_FC_Period

							   ,a.UOM,a.SOHWksCover,a.FamilyGroup_,a.Family_0
							   ,a.rnk,a.Ratio_Sls_FC,a.diff_Sls_FC
							   ,a.Ratio_Sls_FC_4mth,a.diff_Sls_FC_4mth
							   ,a.Sales_Avg_mth,a.FC_Avg_mth
							   --,a.SlsAmt_12,a.FCAmt_1To24,a.StkAmt_12						-- a.StkAmt_12 is inventory value in next 12 months
							  -- ,a.SlsVol_Grd,a.FCVol_Grd,a.SOHVol_Grd
							  -- ,a.SlsAmt_Grd,a.FCAmt_Grd,a.SOHAmt_Grd
							   ,a.PlannerNumber
							   ,a.Owner_,a.PrimarySupplier,a.SupplierName,a.Description,a.Colour,a.SellingGroup
							   ,a.Family,a.FamilyGroup
							   ,a.Prod_Cat
					   
							   ,a.PO_Vol,a.PO_Amt
							   ,a.Qty_OpenSO,a.Amt_Price_OpenSO

							   ,a.Order_Policy,a.Order_Policy_Description,a.Order_Policy_Value
								,a.Planning_Code,a.Planning_Code_Description
								,a.Planning_Fence_Rule,a.Planning_Fence_Rule_Description,a.Plan_Time_Fence
								,a.Msg_Time_Fence,a.Order_Multiple,a.Jde_ABC_1_Sls

								 --,a.ConvUOM,a.ConversionFactor

						from flRop_ a 

						where a.ROP_Validate in ('ROP')
							   and a.PlannerNumber in ('20005','20071','20072')				--- All planners,All A/B/C with Sales less than 4 hits( 2,251) ; only HD planners ( 1,574 inlcuding A/B/C )
							  -- and a.Pareto in ('C')										--- C Pareto only C f( 1,388 )	- HD planners only
							  -- and a.Prod_Cat in ('Not_NP')								--- If further exclude New Products and Only C items ( 1,248 SKU )  - NP Elegibility will be calculated each month in order to keep in line with dynamic of NP product life cycle - each month they may new 'NP' born ( 'Enter' into existence); and each month there are old 'NP' expired/become matured ( thus 'Exit' to become bigger part of pool ) 
		   
						)		

		
				  ------- Final table ------ 19/3/2021
				  
				   ---For Portfolio report - To pick data from 'flRop_', Not 'flRop' becasue you this is portfolio report,you want to pick All data, not just ROP SKUs---
                   ---For ROP report	   - To pick data from 'flRop', Not 'flRop_' becasue you this is ROP report,you do not want to pick All data, just ROP SKUs---

				,fltb as 
				(          
				--select a.ShortItemNumber,a.ItemNumber,a.Order_Policy,a.Order_Policy_Value,a.Planning_Code,a.Planning_Fence_Rule,a.Plan_Time_Fence,a.Jde_ABC_1_Sls		--- For ROP Repport- these columns are for Upload Jde for ROP project
			     
				 select a.ItemNumber,a.Sls_freq,a.SlsVol_TTL_12,a.ItemLvlFCVol_1To24,a.SlsVol_TTL_4,a.ItemLvlFCVol_TTL_4			-- For Portfolio report
							,a.Sales_Avg_mth,a.FC_Avg_mth
						, a.SOHWksCover
						,a.StockingType,a.Pareto,a.SS_Adj
						,a.ROP_Validate,a.ROP,a.ROP_EOQ
						,a.rnk,a.Ratio_Sls_FC,a.diff_Sls_FC
						,a.Ratio_Sls_FC_4mth,a.diff_Sls_FC_4mth

						,a.SOHVol,a.SOHVal,a.SOHAmt,a.Cost,a.Price					    -- A.sohAmt  is value calculated by Jde								
						,a.LeadTime,a.Count_FC_Period

						,a.UOM,a.FamilyGroup_,a.Family_0							  
							  
						,a.SlsAmt_12,a.FCAmt_1To24,a.StkAmt_12						-- a.StkAmt_12 is inventory value in next 12 months
						-- ,a.SlsVol_Grd,a.FCVol_Grd,a.SOHVol_Grd
						-- ,a.SlsAmt_Grd,a.FCAmt_Grd,a.SOHAmt_Grd
						,a.PlannerNumber
						,a.Owner_,a.PrimarySupplier,a.SupplierName,a.Description,a.Colour,a.SellingGroup
						,a.Family,a.FamilyGroup
						,a.Prod_Cat
					   
						,a.PO_Vol,a.PO_Amt
						,a.Qty_OpenSO,a.Amt_Price_OpenSO

						,a.Order_Policy,a.Order_Policy_Description,a.Order_Policy_Value
						,a.Planning_Code,a.Planning_Code_Description
						,a.Planning_Fence_Rule,a.Planning_Fence_Rule_Description,a.Plan_Time_Fence
						,a.Msg_Time_Fence,a.Order_Multiple,a.Jde_ABC_1_Sls

							--,a.ConvUOM,a.ConversionFactor

					from flRop_ a										-- For Portfolio report
					--from flRop a										--- For ROP Repport
				 )



				 select *
				 from fltb a
				 where	a.ItemNumber in ( select splitdata from JDE_DB_Alan.dbo.fnSplitString(@Item_id,','))

				--where a.ItemNumber in ('42.210.031','34.249.000','26.529.000')		 																			
			  

				--where _fl.SellingGroup in ('WC','AD')
				-- where _fl.ItemNumber in ('42.210.031')
				-- where fl_.ItemNumber like ('%85053100%')	
				-- where fl_.ItemNumber in ('7495500001')	
				-- where fl_.ItemNumber in (2974000000'	
				-- where fl_.ItemNumber in ('24.057.165s')					-- cannot find '24.057.165s' in ML345 file hence later table join will yield Null Value causing potential issue in coding - 29/1/18
		  
				-- m.PrimarySupplier in ( select data from JDE_DB_Alan.dbo.Split(@Supplier_id,','))
				--	fl_.ItemNumber in ( select data from JDE_DB_Alan.dbo.Split(@Item_id,','))
			   --order by fl_.SlsAmt_12 desc
			   --  order by fl_.rnk
	 			   order by a.ItemLvlFCVol_1To24 desc



		   --- does not work properly ---13/2/2020
			--order by 			 
			--			case when @OrderByClause ='ParetoAndFCAmt' then a.Pareto end asc,a.FCAmt_1To24 desc,
			--			case when @OrderByClause ='ParetoAndFCQty' then a.ItemLvlFCVol_1To24 end asc,a.Pareto desc,
			--			case when @OrderByClause ='rnk' then a.rnk end asc,
			--			case when @OrderByClause ='SlsAmt_12' then a.SlsAmt_12 end desc,
			--			case when @OrderByClause ='SOHAmt' then a.SOHAmt end desc,
			--			case when @OrderByClause ='Ratio_Sls_FC' then a.Ratio_Sls_FC end desc		
		
		
		-----------------------------------------

	END


END
GO


