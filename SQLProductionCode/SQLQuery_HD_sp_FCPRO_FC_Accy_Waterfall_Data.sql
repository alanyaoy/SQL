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
/****** Object:  StoredProcedure [JDE_DB_Alan].[sp_FCPro_FC_Accy_Data]    Script Date: 26/02/2020 10:52:21 AM ******/
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
ALTER PROCEDURE [JDE_DB_Alan].[sp_FCPro_FC_Accy_Data] 
	-- Add the parameters for the stored procedure here
	--<@Param1, sysname, @p1> <Datatype_For_Param1, , int> = <Default_Value_For_Param1, , 0>, 
	--<@Param2, sysname, @p2> <Datatype_For_Param2, , int> = <Default_Value_For_Param2, , 0>

	-- @Measurement_id varchar(100) = null
	-- @Supplier_id varchar(8000) = null
	 @Item_id varchar(8000) = null
	-- ,@DataType varchar (100) = null
	--,@ItemNumber varchar(100) = null
	--,@ShortItemNumber varchar(100) = null
	--,@CenturyYearMonth int = null
	--,@OrderByClause varchar(1000) = null
	

	        ------- This report product waterfall feature using forecast history and sales ----------------
AS
BEGIN
-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	--set @OrderByClause = 'rnk'	

-- Insert statements for procedure here
	--SELECT <@Param1, sysname, @p1>, <@Param2, sysname, @p2>

	--- Note this FC Analysis Are using Data from FC History table not FC table Hence more visibility ( if you need see FC History this is best choice ) --- 4/9/2018
	--- Also note that Below code exact 24 months Sales History + Whatever FC history you Saved before in your FC history table ---
	
	---*******************************************************************************************************************---
	--- Note this query Only generate Forecast history data ( with Sales ) in 'Waterfall' format when Pivot in Excel ---
	--- Difference between 'sp_FC_Accy_Data' & 'sp_FC_Sales_Analysis' is that latter only fetch 1 month FC data hence much more concise and no need to pay attention to FC history,
	--- Latter Qry is more about Sales & Forecast trend / Pattern, Former Qry is more about FC accuracy  -- 5/10/2018
	---*******************************************************************************************************************---


	--delete from JDE_DB_Alan.FCPRO_Fcst_Accuracy			--- do you want to delete Fcst_Accuracy data every time, is there any such need - maybe you need in test environment ?  --- 8/6/2018
	 
	if @Item_id is not null	



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
			  -- select * from MthCal
			 ,f as ( select fch.*
							,cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,fch.date),0),126),'-',''),1,6) as integer) as FC_date		-- FC_date is FC period in FC table but in Integer format -- FC date in YYYY-mm format--- 5/9/2018	, changed position on 11/1/2019							
							,cast(SUBSTRING(REPLACE(CONVERT(char(10),fch.ReportDate,126),'-',''),1,6) as integer) as [StartDate]	--this [StartDate] is ReportDate in FC table but in Integer format					
					  from JDE_DB_Alan.FCPRO_Fcst_History fch
							-- where h.ItemNumber in ('42.210.031')
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
			   -- select * from fc where fc.Itm in ('42.210.031')
			   -- select * from JDE_DB_Alan.vw_Mast m where m.ItemNumber in ('42.210.031')
			   -----------------------------------------------------------------      
				--- LT offset FC ---
			  --,fct as ( -- select *
					--	--select fc.Itm,fc.DataType1,fc.Date,fc.StartDt,fc.Value,fc.ReportDate,fc.YY,fc.rnk,fc.month			 -- inner join --- so remove all records which does not meet condition - In another words I am only interested and only want SKU that has 3 month lead time. Of course you can use Left join to achiece same result, if you use inner join it is important to include all records of Master data in vw_Mast table though, otherwise you will lose some data --- 30/5/2018  -- Use YY
					--	select fc.Itm,fc.DataType1,fc.Date,fc.StartDt,fc.Value,fc.ReportDate,fc.XX,fc.rnk,fc.month				 -- inner join --- so remove all records which does not meet condition - In another words I am only interested and only want SKU that has 3 month lead time. Of course you can use Left join to achiece same result, if you use inner join it is important to include all records of Master data in vw_Mast table though, otherwise you will lose some data --- 11/1/2019  -- Use XX
					--	from fc inner join JDE_DB_Alan.vw_Mast m on fc.Itm = m.ItemNumber and fc.XX= m.Leadtime_Mth+1			-- LT calculation: LT plus 1 month since FC was saved last day of month - if 2 month then need to consider 60 days, 3 month need to consider 90 days; it will also depend how what value you are using for benchmarking -->  XX or YY  ? 11/1/2019
					--	where fc.Date =  DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0)											-- Get monthly fc in this case --> FC of '2018-04-01' this is FC you want to measure			   -- fc.Date is Forecast Period
					--		   --and fc.Date =  '2018-04-01 00:00:00.000'	
					--	)	
							
				 -- --- Non LT offset FC ---
			  --,fctt as ( -- select *
					--	--select fc.Itm,fc.DataType1,fc.Date,fc.StartDt,fc.Value,fc.ReportDate,fc.YY,fc.rnk,fc.month				 -- inner join -- Use YY
					--	select fc.Itm,fc.DataType1,fc.Date,fc.StartDt,fc.Value,fc.ReportDate,fc.XX,fc.rnk,fc.month					 -- inner join -- Use XX 
					--	from fc 																							  --- No Need to use Join you simply fetch last month FC
					--	where     fc.StartDt	 = cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-2,0),126),'-',''),1,6) as integer)  	-- Get FC saved 30 days ago. LT calculation: Get data captured 1 mth ago, since last month you will have FC only for next month, do get fooled that you are only retriveing forecast 30 days ago ( it looks like 2 month ago ) but this is most recent fc you can get for fc you want to measure !   --- '201803'   -- Performance issue ? --- fc.StartDt is ReportDate ( Date when fc was saved )   --- 10/1/19
					--			 -- fc.StartDt	 = cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-',''),1,6) as integer)   -- Use so called 'last mth' FC ( use minus 1 in formula ),use fc saved 1 day ago ?  You cannot do this, since last month you only saved next month forecast--- 11/1/19 
					--			  --and fc.StartDt = '201803'																									-- hard coded LT			
					--			  --and fc.YY = 2 and fc.rnk = 23																		-- 	Capped to 2 mth ago	
					--			  and fc.Date = DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0)											-- get monthly fc in this case --> FC of '2018-04-01' this is FC you want to measure		-- fc.Date is Forecast Period
					--				--and fc.Date =  '2018-04-01 00:00:00.000'	
					--		)			
										
				--select * from fct  where fct.Itm in ('42.210.031','32.379.200')
			   -- select * from fctt  where fctt.Itm in ('42.210.031')			
              ---------------------------------------------------------------------		

			  ------- Last Month Histry --- If you are in May, Need April History ( compared with April FC though) ,Not May History !  --------------


				,SlsItm as ( select distinct h.ItemNumber as ItemNumber_ from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h )
				,m    as ( select * from SlsItm cross join MthCal c 
							 -- where   c.StartDt between replace(convert(varchar(8), DATEADD(mm, DATEDIFF(m,0,GETDATE())-12,0),126),'-','' )			-- last 12 months		
							  --				 and  replace(convert(varchar(8), DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-','' )		   -- last 12 months
									)		     
		
				--select * from SlsList s where s.ItemNumber_ in ('42.210.031')	
											-- and  s.StartDt = cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-',''),1,6) as integer)	

					-------- below is tb padded Item with all Months ---------
				,hist as																													
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
					 where  m.StartDt <= cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-',''),1,6) as integer)
						)
				  --select * from hist where hist.ItemNumber_ in ('82.501.904')
				  -- select * from hist where hist.ItemNumber_ in ('42.210.031')
				 --  select * from hist where hist.ItemNumber_ in ('38.001.001')

				 ,_comb as (  select fc.Itm as Item_f, fc.DataType1,fc.FC_date as dt,fc.Value,fc.ReportDate
							  from fc
							 Union all
							 select h.ItemNumber_ as Item_f,'Sales' as DataType1,h.CYM_2 as dt,h.SalesQty,h.ReportDate_
							  from hist h
									  )

                 ,comb as ( select c.*,m.Description,m.StockingType
									--,m.SellingGroup_
									,m.FamilyGroup_,m.Family_0								--4/12/2019
									,m.FamilyGroup,m.Family									--4/12/2019
									,p.Pareto
									,m.UOM
									,m.Leadtime_Mth											-- 20/8/2019
								from _comb c left join JDE_DB_Alan.vw_Mast m on c.Item_f = m.ItemNumber 
								             left join JDE_DB_Alan.FCPRO_Fcst_Pareto p on c.Item_f = p.ItemNumber								           
								)

                 select c.*, getdate() as ThisReportDate from comb c
                 where  c.Item_f in  ( select splitdata from JDE_DB_Alan.dbo.fnSplitString(@Item_id,','))			 
				 --where c.Item_f in ('38.001.001')
	                 order by c.Item_f,c.DataType1,c.ReportDate,c.dt 
				 --select * from comb c
				-- where c.Item_f in ('42.210.031')
				-- order by c.Item_f,c.DataType1,c.ReportDate,c.dt
				       --comb.Description is null
				 -- select * from comb
       			--	insert into JDE_DB_Alan.FCPRO_Fcst_Accuracy  select * from comb
					--select * from JDE_DB_Alan.FCPRO_Fcst_Accuracy
	  	 
	 
	 
	else if @Item_id is null
	--else if @Measurement_id is not null
	begin
	   		
		 
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
			  -- select * from MthCal
			 ,f as ( select fch.*
							,cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,fch.date),0),126),'-',''),1,6) as integer) as FC_date		-- FC_date is FC period in FC table but in Integer format -- FC date in YYYY-mm format--- 5/9/2018	, changed position on 11/1/2019							
							,cast(SUBSTRING(REPLACE(CONVERT(char(10),fch.ReportDate,126),'-',''),1,6) as integer) as [StartDate]	--this [StartDate] is ReportDate in FC table but in Integer format					
					  from JDE_DB_Alan.FCPRO_Fcst_History fch
							-- where h.ItemNumber in ('42.210.031')
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
			   -- select * from fc where fc.Itm in ('42.210.031')
			   -- select * from JDE_DB_Alan.vw_Mast m where m.ItemNumber in ('42.210.031')
			   -----------------------------------------------------------------      
				--- LT offset FC ---
			  --,fct as ( -- select *
					--	--select fc.Itm,fc.DataType1,fc.Date,fc.StartDt,fc.Value,fc.ReportDate,fc.YY,fc.rnk,fc.month			 -- inner join --- so remove all records which does not meet condition - In another words I am only interested and only want SKU that has 3 month lead time. Of course you can use Left join to achiece same result, if you use inner join it is important to include all records of Master data in vw_Mast table though, otherwise you will lose some data --- 30/5/2018  -- Use YY
					--	select fc.Itm,fc.DataType1,fc.Date,fc.StartDt,fc.Value,fc.ReportDate,fc.XX,fc.rnk,fc.month				 -- inner join --- so remove all records which does not meet condition - In another words I am only interested and only want SKU that has 3 month lead time. Of course you can use Left join to achiece same result, if you use inner join it is important to include all records of Master data in vw_Mast table though, otherwise you will lose some data --- 11/1/2019  -- Use XX
					--	from fc inner join JDE_DB_Alan.vw_Mast m on fc.Itm = m.ItemNumber and fc.XX= m.Leadtime_Mth+1			-- LT calculation: LT plus 1 month since FC was saved last day of month - if 2 month then need to consider 60 days, 3 month need to consider 90 days; it will also depend how what value you are using for benchmarking -->  XX or YY  ? 11/1/2019
					--	where fc.Date =  DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0)											-- Get monthly fc in this case --> FC of '2018-04-01' this is FC you want to measure			   -- fc.Date is Forecast Period
					--		   --and fc.Date =  '2018-04-01 00:00:00.000'	
					--	)	
							
				 -- --- Non LT offset FC ---
			  --,fctt as ( -- select *
					--	--select fc.Itm,fc.DataType1,fc.Date,fc.StartDt,fc.Value,fc.ReportDate,fc.YY,fc.rnk,fc.month				 -- inner join -- Use YY
					--	select fc.Itm,fc.DataType1,fc.Date,fc.StartDt,fc.Value,fc.ReportDate,fc.XX,fc.rnk,fc.month					 -- inner join -- Use XX 
					--	from fc 																							  --- No Need to use Join you simply fetch last month FC
					--	where     fc.StartDt	 = cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-2,0),126),'-',''),1,6) as integer)  	-- Get FC saved 30 days ago. LT calculation: Get data captured 1 mth ago, since last month you will have FC only for next month, do get fooled that you are only retriveing forecast 30 days ago ( it looks like 2 month ago ) but this is most recent fc you can get for fc you want to measure !   --- '201803'   -- Performance issue ? --- fc.StartDt is ReportDate ( Date when fc was saved )   --- 10/1/19
					--			 -- fc.StartDt	 = cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-',''),1,6) as integer)   -- Use so called 'last mth' FC ( use minus 1 in formula ),use fc saved 1 day ago ?  You cannot do this, since last month you only saved next month forecast--- 11/1/19 
					--			  --and fc.StartDt = '201803'																									-- hard coded LT			
					--			  --and fc.YY = 2 and fc.rnk = 23																		-- 	Capped to 2 mth ago	
					--			  and fc.Date = DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0)											-- get monthly fc in this case --> FC of '2018-04-01' this is FC you want to measure		-- fc.Date is Forecast Period
					--				--and fc.Date =  '2018-04-01 00:00:00.000'	
					--		)			
										
				--select * from fct  where fct.Itm in ('42.210.031','32.379.200')
			   -- select * from fctt  where fctt.Itm in ('42.210.031')			
              ---------------------------------------------------------------------		

			  ------- Last Month Histry --- If you are in May, Need April History ( compared with April FC though) ,Not May History !  --------------


				,SlsItm as ( select distinct h.ItemNumber as ItemNumber_ from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h )
				,m    as ( select * from SlsItm cross join MthCal c 
							 -- where   c.StartDt between replace(convert(varchar(8), DATEADD(mm, DATEDIFF(m,0,GETDATE())-12,0),126),'-','' )			-- last 12 months		
							  --				 and  replace(convert(varchar(8), DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-','' )		   -- last 12 months
									)		     
		
				--select * from SlsList s where s.ItemNumber_ in ('42.210.031')	
											-- and  s.StartDt = cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-',''),1,6) as integer)	

					-------- below is tb padded Item with all Months ---------
				,hist as																													
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
					 where  m.StartDt <= cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-',''),1,6) as integer)
						)
				  --select * from hist where hist.ItemNumber_ in ('82.501.904')
				  -- select * from hist where hist.ItemNumber_ in ('42.210.031')
				 --  select * from hist where hist.ItemNumber_ in ('38.001.001')

				 ,_comb as (  select fc.Itm as Item_f, fc.DataType1,fc.FC_date as dt,fc.Value,fc.ReportDate
							  from fc
							 Union all
							 select h.ItemNumber_ as Item_f,'Sales' as DataType1,h.CYM_2 as dt,h.SalesQty,h.ReportDate_
							  from hist h
									  )

                 ,comb as ( select c.*,m.Description,m.StockingType
									,m.SellingGroup_
									,m.FamilyGroup_,m.Family_0					--4/12/2019
									,m.FamilyGroup,m.Family					--4/12/2019
									,p.Pareto
									,m.UOM
									,m.Leadtime_Mth										-- 20/8/2019
								from _comb c left join JDE_DB_Alan.vw_Mast m on c.Item_f = m.ItemNumber 
								             left join JDE_DB_Alan.FCPRO_Fcst_Pareto p on c.Item_f = p.ItemNumber								           
								)

                select c.*, getdate() as ThisReportDate from comb c
                -- where  c.Item_f in  ( select splitdata from JDE_DB_Alan.dbo.fnSplitString(@Item_id,','))			 
				 -- where c.Item_f in ('38.001.001')
	                 order by c.Item_f,c.DataType1,c.ReportDate,c.dt 
				       --comb.Description is null
				 -- select * from comb
       			--	insert into JDE_DB_Alan.FCPRO_Fcst_Accuracy  select * from comb
					--select * from JDE_DB_Alan.FCPRO_Fcst_Accuracy
	  	 
	  
	END

	     --select * from JDE_DB_Alan.FCPRO_Fcst_Accuracy_
						 

END
