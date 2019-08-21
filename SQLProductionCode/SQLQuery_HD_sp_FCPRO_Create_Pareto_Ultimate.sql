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
/****** Object:  StoredProcedure [JDE_DB_Alan].[sp_Cal_Create_Pareto_Ultimate]    Script Date: 7/08/2019 11:45:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [JDE_DB_Alan].[sp_Cal_Create_Pareto_Ultimate] 
	-- Add the parameters for the stored procedure here
	--<@Param1, sysname, @p1> <Datatype_For_Param1, , int> = <Default_Value_For_Param1, , 0>, 
	--<@Param2, sysname, @p2> <Datatype_For_Param2, , int> = <Default_Value_For_Param2, , 0>
	@DataType1 varchar(100) = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from interfering with SELECT statements.
	SET NOCOUNT ON;  
	   
			------Method 1. use Order by works this is fastest takes 2 sec awesome !-----------
				--- Get ItemLvl FC ---

		delete from JDE_DB_Alan.FCPRO_Fcst_Pareto			

					--- \\\Note this code borrow some code from Portofolio \\\---

		;with 
				  ---=============================
				   --- old way of calendar ------
                  ---=============================
			  CalendarFrame as (
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
									,DATENAME(mm,start) MnthName,DATENAME(yyyy,start) YearName from CalendarFrame
					)    
                ---===========================
			    --- new way of calendar ------
				---===========================
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
											 ,YY
											,_T
											,cast(SUBSTRING(REPLACE(CONVERT(char(10),start,126),'-',''),1,6) as integer) as [StartDt]		
											,LEFT(datename(month,start),3) AS [month_name]
											,datepart(month,start) AS [month]
											,datepart(year,start) AS [year]				
										   from R  )
					--select * from MthCal

				,itm as ( select distinct h.ItemNumber as ItemNumber_ from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h )
				,m as ( select * from itm cross join MthCal cldr 
							where --StartDate						-- original name of '[StartDate]' in template 
									StartDt 
									 between replace(convert(varchar(8), DATEADD(mm, DATEDIFF(m,0,GETDATE())-12,0),126),'-','' )			-- last 12 months		
													 and  replace(convert(varchar(8), DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-','' )		-- last 12 months
						  )	
				  
				 --  select * from m where m.ItemNumber_ in ('42.210.031')	
		 		  	     
				----------------- Padded Item with all Months --------------------				 
				,hist as																													
				(  select m.ItemNumber_
				            
							,h.CYM,h.CY,h.Month
							,h.ReportDate
							,case when h.SalesQty is null then 0 else h.SalesQty end as SalesQty_
							--,case when h.ReportDate is null then getdate() else h.ReportDate end as ReportDate_
							--  ,case when h.ReportDate is null then getdate() else h.ReportDate end as ReportDate_
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

					from m left join JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h on m.StartDt = h.CYM and  m.ItemNumber_ = h.ItemNumber
					--where    list.StartDt = cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-',''),1,6) as integer)			-- Watch out use List.StartDt Not h.CYM !!!   --- 29/5/2018
							-- h.CYM = '201804' and																													-- Performance issue ?
							--c.rnk =24																												-- last month ( for last month Sales)
						where  m.StartDt <= cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-',''),1,6) as integer)
						)

				--select * from hist where hist.ItemNumber_ in ('38.001.001')
					
				,histy as 
					( select x.ItemNumber_
					,count(isnull(x.CYM_2,0)) TTL_SlsMths			-- Or you can use --> count(isnull(x.StartDt2,0)) TTL_SlsMths
					,sum( case when salesqty_ >0 then 1 else 0 end ) as Sls_freq
					,sum(x.SalesQty_) SlsVol_TTL_12 
					from hist x 
					group by x.ItemNumber_)
				--select * from histy where histy.ItemNumber_ in ('03.986.000','38.001.001')

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
							--select a.ItemNumber,sum(coalesce(a.QtyOnHand,0)) SOHVol,sum(coalesce(a.StockValue,0)) SOHVol				--- 13/12/2018
							--from JDE_DB_Alan.vw_Mast a 
							--where a.GLCat not in ('SCRA')
							-- Note 
							--1) unlike 'in' and 'exist', 'Not in' and 'Not exist' behaviour differently - this is more related if Subquery involved - not necessarily in 'not in ('SCRA') simple statment. 'not in' will filter out 'null' value but still return other values. while  in 'where value Not in ( select value from tb) ' will return empty if there is null value). - If the subquery of items to not be IN contains NULL no results will be returned because nothing equals NULL and nothing does not equal NULL (Not even NULL).
							-- 2) https://stackoverflow.com/questions/1699424/whats-the-difference-between-not-in-and-not-exists --> not exists (select 1 from test_b where test_b.col1 = test_a.col1); -- will return some result normally without/remove 'null' 
							-- 3) https://stackoverflow.com/questions/1662902/when-to-use-except-as-opposed-to-not-exists-in-transact-sql --> if your subquery use 'select null from ...' then your result will return some result including 'null' value
							-- 4) use 'except' is better ( except will treat null as matching ) -- https://stackoverflow.com/questions/1662902/when-to-use-except-as-opposed-to-not-exists-in-transact-sql -- look example of using 'except' in this link
								 -- SELECT  *
								--	FROM    q
								--	EXCEPT
								--	SELECT  *
								--	FROM    p																																																						
							-- 5)
					
							--select a.ItemNumber,sum(coalesce(a.QtyOnHand,0)) SOHVol				--- 11/07/2018  old code -- does not exclude 'SCRA', so include 'SCRA' value for total inventory is not correct
							--from JDE_DB_Alan.Master_ML345 a 
							--from m
							--where a.ItemNumber in ('24.7206.0000')
							--where a.ItemNumber in ('03.986.000')
							-- where a.ItemNumber in ('24.057.165s')   -- cannot find '24.057.165s' in ML345 file hence later table join will yield Null Value causing potential issue in coding - 29/1/18
							--group by a.ItemNumber

							--select * from JDE_DB_Alan.vw_Mast a
							--where a.GLCat is null not in ('SCRA')
							-- where a.ItemNumber in ('05.980.000')
							)					
				,fc_Vol as  
					( select fct.DataType1,fct.ItemNumber,sum(isnull(fct.FC_Vol,0)) as ItemLvlFCVol_1To12,count(isnull(fct.Date,0)) Count_FC_Period   ---TTL_FCMths	
						--select * from JDE_DB_Alan.FCPRO_Fcst fct					-- 22/1/2018 did not have  condition before --> where fct.DataType1 like ('%Adj_FC%')	
						  from JDE_DB_Alan.vw_FC fct
						  where fct.DataType1 like ('%Adj_FC%')			-- 26/2/2018
							   --   and fct.Date < DATEADD(mm, DATEDIFF(m,0,GETDATE())+12,0)		--- 9/1/2019 this will Kill the query as Calculate time is the Killer to performance, use Integer rather Time in calculation ( comparison ) will be better. 9/1/2019
							   -- and fct.Date between '2019-01-01' and '2019-12-01'			-- For Signature New Product Post Launch Analysis --- 5/6/2018
								 and fct.FCDate2_ <= cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())+11,0),126),'-',''),1,6) as integer)  -- next 12 month, Using Integer not the Time in Calculation !
								--  and fct.Date between @Start and @End
						group by fct.DataType1,fct.ItemNumber)	      
		
				,fcVol as (	select fc_Vol.ItemNumber
								,fc_Vol.DataType1							
								,fc_Vol.ItemLvlFCVol_1To12							
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

				--select * from fc_Vol where fc_vol.ItemNumber = '03.986.000'
				--where fcVol.ItemLvlFCVol_24 is null		-- where fc.ItemNumber = '18.615.024' --- fc about 10125 record

					   --- Item Level ----
				,comb_Vol as (select fc_Vol.ItemNumber,fc_Vol.DataType1,histy.SlsVol_TTL_12,histy.Sls_Freq								
										,fc_Vol.ItemLvlFCVol_1To12
										,fc_Vol.Count_FC_Period
										,stk.SOHVol
										,stk.SOHVal
										--,coalesce(stk.SOHVol/(nullif(fc_Vol.ItemLvlFCVol_1To24/24,0)),0) as SOHWksCover						--if divisor is 0	
										,coalesce(stk.SOHVol/(nullif(fc_Vol.ItemLvlFCVol_1To12/fc_Vol.Count_FC_Period,0)),0) as SOHWksCover			--if divisor is 0 And FC month count varies --- 19/7/2018					 
								from fc_Vol left join histy on fc_Vol.ItemNumber = histy.ItemNumber_
											left join stk on stk.ItemNumber = histy.ItemNumber_
								)
				 --select * from comb_Vol

				,combVol as ( select c.*,px.StandardCost as Cost,px.WholeSalePrice as Price,(px.WholeSalePrice - px.StandardCost) as Margin		                      
									 ,c.ItemLvlFCVol_1To12 * (px.WholeSalePrice - px.StandardCost) as MargAmt
									 ,c.ItemLvlFCVol_1To12 *px.WholeSalePrice as FCAmt							 							 
								from comb_Vol c left join JDE_DB_Alan.vw_Mast px on c.ItemNumber = px.ItemNumber
								 -- from comb_Vol c left join JDE_DB_Alan.Px_AWF_HD_MT_FCPro_upload px on c.ItemNumber = px.ItemNumber
								)

				 --select * from combvol  --where comb_Vol.SOHWksCover is null
				--where comb_vol.ItemNumber = ('03.986.000')
				--where combvol.ItemNumber = ('42.210.031') 
		
				  ---============================
				  ----- 1. Pareto by Velocity ----            
				 ---==============================

					--- Note there  is no point to Sort when comes to Velocity --- so tbl1 has no practical use, here just get familiarize with rank and dense_rank function --- 9/1/2019
				 ,tbl1 as ( select sm.*
								  ,rank() over ( partition by sm.DataType1 order by Sls_Freq desc) as rnk1						
								 ,DENSE_RANK () over(partition by sm.Datatype1 order by Sls_Freq asc) as dr1						
							from combVol sm )

				 ,ftbl1 as ( select *
									,(case 
										   when tbl.Sls_Freq >= 10 then 'A'				-- more than 9 hits treats as A
										   when tbl.Sls_Freq >= 7 then 'B'				-- more than 6 hits treats as B	
										   else  'C'
										   end ) as Pareto_Velc
							 from tbl1 as tbl
							 )
     
			   --select * from ftbl1

			   ---============================
  				----- 2. Pareto by Margin ----
				---============================
		            
				,x2 as (
					select *
							,sum(sm.MargAmt) over(partition by sm.DataType1) as GrandTTL_MargAmt
							,cast(coalesce(sm.MargAmt/nullif(sum(sm.MargAmt) over(partition by sm.DataType1),0),0) as decimal(18,12)) as Pct_MargAmt
						--,(select sum(value) from FCPRO_Fcst where id<=t.id)/(select sum(value) from FCPRO_Fcst ) as Running_Percent	 
					--from combVol sm
					  from ftbl1 sm
					--order by FCPRO_Fcst.value
						)
				 --select * from x -- where x.ItemNumber in ('42.210.031')

			   --- Sort the records First Very important !---
				,y2 as ( select x.*,row_number() over ( partition by x.DataType1 order by x.Pct_MargAmt desc) as rnk_MargAmt
						from x2 as x )

				,tbl2 as (
						select y.*,sum(y.MargAmt) over ( partition by y.DataType1 order by y.rnk_MargAmt ) as RunningTTL_MargAmt from y2 as y )

    			--- Calculate Percentage ( And if there is an% sign in number remove it first )
				,ftbl2 as ( select tbl.*
							--tbl.ItemNumber,tbl.DataType1,tbl.FCAmt,tbl.MargAmt,tbl.RunningTTL_MargAmt,tbl.GrandTTL_MargAmt,tbl.Pct_MargAmt,tbl.rnk_MargAmt
							,(tbl.RunningTTL_MargAmt/tbl.GrandTTL_MargAmt) as RunningTTLPct_MargAmt
								, (case 
										when convert(decimal(18,2),replace((tbl.RunningTTL_MargAmt/tbl.GrandTTL_MargAmt),'%','')) <=0.800001 then 'A'		---20
										when convert(decimal(18,5),replace((tbl.RunningTTL_MargAmt/tbl.GrandTTL_MargAmt),'%','')) < 0.95 then 'B'		---30
										else 'C' end ) as Pareto_MargAmt																		---50
                    
							from tbl2 as tbl
							)
						--select * from ftbl2

				---============================
	  			--- 3. Pareto by Revenu ----            
				---============================

				,x3 as (
					select *
							,sum(sm.FCAmt) over(partition by sm.DataType1) as GrandTTL_FCAmt
							,cast(coalesce(sm.FCAmt/nullif(sum(sm.FCAmt) over(partition by sm.DataType1),0),0) as decimal(18,12)) as Pct_FCAmt
						--,(select sum(value) from FCPRO_Fcst where id<=t.id)/(select sum(value) from FCPRO_Fcst ) as Running_Percent	 
					--from combVol sm
					  from ftbl2 as sm
					--order by FCPRO_Fcst.value
						)
					--select * from x -- where x.ItemNumber in ('42.210.031')

			   --- Sort the records First Very important !---
				,y3 as ( select x.*,row_number() over ( partition by x.DataType1 order by x.Pct_FCAmt desc) as rnk_FCAmt
						from x3 as x )

				,tbl3 as (
						select y.*,sum(y.FCAmt) over ( partition by y.DataType1 order by y.rnk_FCAmt ) as RunningTTL_FCAmt from y3 as y )

    			--- Calculate Percentage ( And if there is an% sign in number remove it first )
				,ftbl3 as ( select tbl.*
								--tbl.ItemNumber,tbl.DataType1,tbl.FCAmt,tbl.MargAmt,tbl.RunningTTL_FCAmt,tbl.GrandTTL_FCAmt,tbl.Pct_FCAmt,,tbl.rnk_FCAmt
								,(tbl.RunningTTL_FCAmt/tbl.GrandTTL_FCAmt) as RunningTTLPct_FCAmt
								, (case 
										when convert(decimal(18,2),replace((tbl.RunningTTL_FCAmt/tbl.GrandTTL_FCAmt),'%','')) <=0.800001 then 'A'		---20
										when convert(decimal(18,5),replace((tbl.RunningTTL_FCAmt/tbl.GrandTTL_FCAmt),'%','')) < 0.95 then 'B'		---30
										else 'C' end ) as Pareto_FCRev																		---50
                    
							from tbl3 as tbl
							)
			  --select * from ftbl3

			  ----- Assign the Digital Weight value to Pareto in different category ---
			  ,_tb as (
						select *
								,( case 
									 when t.Pareto_Velc = 'A' then 9
									 when t.Pareto_Velc = 'B' then 6
									 when t.Pareto_Velc = 'C' then 1
									 else 0  end ) as Score_Velc
								, ( case 
									 when t.Pareto_MargAmt = 'A' then 6
									 when t.Pareto_MargAmt = 'B' then 4
									 when t.Pareto_MargAmt = 'C' then 2
									 else 0  end ) as Score_Marg
								,( case
									  when t.Pareto_FCRev = 'A' then 3
									  when t.Pareto_FCRev = 'B' then 2
									  when t.Pareto_FCRev = 'C' then 1
									  end  ) as Score_Rev
						from ftbl3 t 
						)

			  ,tb_ as ( select *
							  ,(Score_Velc + Score_Marg + Score_Rev) as f_Score 
							  , ( case 
									 when (Score_Velc + Score_Marg + Score_Rev) >=14 then 'A'
									 when (Score_Velc + Score_Marg + Score_Rev) >=12 then 'B'
									 when (Score_Velc + Score_Marg + Score_Rev) >=4 then 'C'
									 else 'D' end ) as f_Pareto

						from _tb as t
						)

			 ,tb as ( select t.*
							,m.StockingType,m.PlannerNumber,m.Owner_,m.PrimarySupplier,m.SupplierName
							,m.SellingGroup_,m.FamilyGroup_,m.Family_0
					  from tb_ t left join JDE_DB_Alan.vw_Mast m on t.ItemNumber = m.ItemNumber
								 --left join JDE_DB_Alan.MasterSupplier s on s.SupplierNumber = m.PrimarySupplier
					  )
			   --select * from tb  order by f_Score desc

			 ,fltb as (select *,GETDATE() as ReportDate from tb 
							--where ftb.DataType1 like (@DataType1)
							)

           -- select * from fltb order by fltb.f_Pareto

			insert into JDE_DB_Alan.FCPRO_Fcst_Pareto select t.ItemNumber,t.SellingGroup_,t.FamilyGroup_,t.Family_0,t.DataType1,t.f_Score,t.f_Pareto,t.StockingType,t.ReportDate from fltb t
			select * from JDE_DB_Alan.FCPRO_Fcst_Pareto p order by p.Pareto,p.rnk desc
			--where ftb.DataType1 like ('%price') and ftb.rnk =819
	
	


END
