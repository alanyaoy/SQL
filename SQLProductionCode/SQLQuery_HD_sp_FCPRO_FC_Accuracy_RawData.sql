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

/****** Object:  StoredProcedure [JDE_DB_Alan].[sp_FCPro_FC_Accuracy]    Script Date: 3/09/2018 3:45:30 PM ******/
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
CREATE PROCEDURE [JDE_DB_Alan].[sp_FCPro_FC_Accuracy_RawDt] 
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
	


AS
BEGIN
-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	--set @OrderByClause = 'rnk'	

-- Insert statements for procedure here
	--SELECT <@Param1, sysname, @p1>, <@Param2, sysname, @p2>


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
								 ,YY 
								,cast(SUBSTRING(REPLACE(CONVERT(char(10),start,126),'-',''),1,6) as integer) as [StartDt]		
								,LEFT(datename(month,start),3) AS [month_name]
								,datepart(month,start) AS [month]
								,datepart(year,start) AS [year]				
							   from R  )
			 -- select * from MthCal
			  -------------------------------------------
			 ,f as ( select fch.*
							,cast(SUBSTRING(REPLACE(CONVERT(char(10),fch.ReportDate,126),'-',''),1,6) as integer) as [StartDate]						
					  from JDE_DB_Alan.FCPRO_Fcst_History fch
							-- where h.ItemNumber in ('42.210.031')
							)
			  ,fc as ( select f.ItemNumber as Itm,f.DataType1,f.Date,f.StartDate,f.Value,f.ReportDate,c.*							--- join cal to get YY value which is your month rank/order
				    
						from f left join MthCal c on f.StartDate = c.StartDt												--- no need to cross join cal table as FC tb always has data in 24 mth				
					  -- where fc.ItemNumber = ('42.210.031') order by fc.ItemNumber,fc.StartDt,fc.Date
						)     
		
				--select * from fc where fc.Itm in ('42.210.031','32.379.200')	order by fc.Itm,fc.ReportDate,fc.Date 
	  
			   ----------------------------------------------------------------------      
				--- LT offset FC ---
			--  ,fct as ( -- select *
			   --         select fc.Itm,fc.DataType1,fc.Date,fc.StartDt,fc.Value,fc.ReportDate,fc.YY,fc.rnk,fc.month				 -- inner join --- so remove all records which does not meet condition - In another words I am only interested and only want SKU that has 3 month lead time. Of course you can use Left join to achiece same result, if you use inner join it is important to include all records of Master data in vw_Mast table though, otherwise you will lose some data --- 30/5/2018
			   --         from fc inner join JDE_DB_Alan.vw_Mast m on fc.Itm = m.ItemNumber and fc.YY= m.Leadtime_Mth+1			-- LT calculation: LT plus 1 month since FC was saved last day of month - if 2 month then need to consider 60 days, 3 month need to consider 90 days
						--where fc.Date =  DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0)											-- get monthly fc in this case --> FC of '2018-04-01' this is FC you want to measure
						--       and fc.Date =  '2018-04-01 00:00:00.000'	
						--)	
							
				--- Non LT offset FC ---
			--  ,fctt as ( -- select *
			   --         select fc.Itm,fc.DataType1,fc.Date,fc.StartDt,fc.Value,fc.ReportDate,fc.YY,fc.rnk,fc.month				 -- inner join
			   --         from fc 																							  --- No Need to use Join you simply fetch last month FC
						--where    fc.StartDt	 = cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-2,0),126),'-',''),1,6) as integer)  	--LT calculation: Capped to 2 mth ago, since last month you will have FC only for next month   --- '201803'   -- Performance issue ?
						--		  and fc.StartDt = '201803'																									-- hard coded LT			
						--		  and fc.YY = 2 and fc.rnk = 23																		-- 	Capped to 2 mth ago	
						--		  and fc.Date = DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0)											-- get monthly fc in this case --> FC of '2018-04-01' this is FC you want to measure
						--			and fc.Date =  '2018-04-01 00:00:00.000'	
						--	)			
										
				--select * from fctt  where fct.Itm in ('82.501.904','42.210.031')
				--select * from fctt  where fctt.Itm in ('42.210.031')			
			 -----------------------------------------------------------------------------     

			  ------- Last Month Histry --- If you are in May, Need April History ( compared with April FC though) ,Not May History !  --------------


				,SlsItm as ( select distinct h.ItemNumber as ItemNumber_ from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h )
				,SlsList as ( select * from SlsItm cross join MthCal c 
							 -- where   c.StartDt between replace(convert(varchar(8), DATEADD(mm, DATEDIFF(m,0,GETDATE())-12,0),126),'-','' )			-- last 12 months		
							  --				 and  replace(convert(varchar(8), DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-','' )		   -- last 12 months
									)		     
		
				--select * from SlsList s where s.ItemNumber_ in ('42.210.031')	
											-- and  s.StartDt = cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-',''),1,6) as integer)	

					-------- below is tb padded Item with all Months ---------
				,hist as																													
				(  select list.ItemNumber_,h.CYM,h.CY,h.Month
							,case when h.SalesQty is null then 0 else h.SalesQty end as SalesQty,h.ReportDate
						   ,list.YY,list.rnk,list.StartDt,list.month as mth
						  ,case 
								when h.CYM is null	then cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-',''),1,6) as integer) 
								else h.CYM
							end as CYM_
					from SlsList list left join JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h on list.StartDt = h.CYM and  list.ItemNumber_ = h.ItemNumber
					--where    list.StartDt = cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-',''),1,6) as integer)			-- Watch out use List.StartDt Not h.CYM !!!   --- 29/5/2018
							-- h.CYM = '201804' and																													-- Performance issue ?
							--c.rnk =24																												-- last month ( for last month Sales)
					 where  list.StartDt <= cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-',''),1,6) as integer)
						)
				   --select * from hist where hist.ItemNumber_ in ('82.501.904')
				   --select * from hist where hist.ItemNumber_ in ('42.210.031')
				 ,comb as (  select fc.Itm as Item_f, fc.DataType1,fc.StartDt as dt,fc.Value
							  from fc
							 Union all
							 select h.ItemNumber_ as Item_f,'Sales' as DataType1,h.CYM_ as dt,h.SalesQty
							  from hist h

									  )

                 select * from comb c
                 where  c.Item_f in  ( select splitdata from JDE_DB_Alan.dbo.fnSplitString(@Item_id,','))			 
	                 order by c.Item_f,c.DataType1,c.dt
				 --select * from comb where comb.Itm in ('42.210.031')
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
								 ,YY 
								,cast(SUBSTRING(REPLACE(CONVERT(char(10),start,126),'-',''),1,6) as integer) as [StartDt]		
								,LEFT(datename(month,start),3) AS [month_name]
								,datepart(month,start) AS [month]
								,datepart(year,start) AS [year]				
							   from R  )
			 -- select * from MthCal
			  -------------------------------------------
			 ,f as ( select fch.*
							,cast(SUBSTRING(REPLACE(CONVERT(char(10),fch.ReportDate,126),'-',''),1,6) as integer) as [StartDate]						
					  from JDE_DB_Alan.FCPRO_Fcst_History fch
							-- where h.ItemNumber in ('42.210.031')
							)
			  ,fc as ( select f.ItemNumber as Itm,f.DataType1,f.Date,f.StartDate,f.Value,f.ReportDate,c.*							--- join cal to get YY value which is your month rank/order
				    
						from f left join MthCal c on f.StartDate = c.StartDt												--- no need to cross join cal table as FC tb always has data in 24 mth				
					  -- where fc.ItemNumber = ('42.210.031') order by fc.ItemNumber,fc.StartDt,fc.Date
						)     
		
				--select * from fc where fc.Itm in ('42.210.031','32.379.200')	order by fc.Itm,fc.ReportDate,fc.Date 
	  
			   ----------------------------------------------------------------------      
				--- LT offset FC ---
			--  ,fct as ( -- select *
			   --         select fc.Itm,fc.DataType1,fc.Date,fc.StartDt,fc.Value,fc.ReportDate,fc.YY,fc.rnk,fc.month				 -- inner join --- so remove all records which does not meet condition - In another words I am only interested and only want SKU that has 3 month lead time. Of course you can use Left join to achiece same result, if you use inner join it is important to include all records of Master data in vw_Mast table though, otherwise you will lose some data --- 30/5/2018
			   --         from fc inner join JDE_DB_Alan.vw_Mast m on fc.Itm = m.ItemNumber and fc.YY= m.Leadtime_Mth+1			-- LT calculation: LT plus 1 month since FC was saved last day of month - if 2 month then need to consider 60 days, 3 month need to consider 90 days
						--where fc.Date =  DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0)											-- get monthly fc in this case --> FC of '2018-04-01' this is FC you want to measure
						--       and fc.Date =  '2018-04-01 00:00:00.000'	
						--)	
							
				--- Non LT offset FC ---
			--  ,fctt as ( -- select *
			   --         select fc.Itm,fc.DataType1,fc.Date,fc.StartDt,fc.Value,fc.ReportDate,fc.YY,fc.rnk,fc.month				 -- inner join
			   --         from fc 																							  --- No Need to use Join you simply fetch last month FC
						--where    fc.StartDt	 = cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-2,0),126),'-',''),1,6) as integer)  	--LT calculation: Capped to 2 mth ago, since last month you will have FC only for next month   --- '201803'   -- Performance issue ?
						--		  and fc.StartDt = '201803'																									-- hard coded LT			
						--		  and fc.YY = 2 and fc.rnk = 23																		-- 	Capped to 2 mth ago	
						--		  and fc.Date = DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0)											-- get monthly fc in this case --> FC of '2018-04-01' this is FC you want to measure
						--			and fc.Date =  '2018-04-01 00:00:00.000'	
						--	)			
										
				--select * from fctt  where fct.Itm in ('82.501.904','42.210.031')
				--select * from fctt  where fctt.Itm in ('42.210.031')			
			 -----------------------------------------------------------------------------     

			  ------- Last Month Histry --- If you are in May, Need April History ( compared with April FC though) ,Not May History !  --------------


				,SlsItm as ( select distinct h.ItemNumber as ItemNumber_ from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h )
				,SlsList as ( select * from SlsItm cross join MthCal c 
							 -- where   c.StartDt between replace(convert(varchar(8), DATEADD(mm, DATEDIFF(m,0,GETDATE())-12,0),126),'-','' )			-- last 12 months		
							  --				 and  replace(convert(varchar(8), DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-','' )		   -- last 12 months
									)		     
		
				--select * from SlsList s where s.ItemNumber_ in ('42.210.031')	
											-- and  s.StartDt = cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-',''),1,6) as integer)	

					-------- below is tb padded Item with all Months ---------
				,hist as																													
				(  select list.ItemNumber_,h.CYM,h.CY,h.Month
							,case when h.SalesQty is null then 0 else h.SalesQty end as SalesQty,h.ReportDate
						   ,list.YY,list.rnk,list.StartDt,list.month as mth
						  ,case 
								when h.CYM is null	then cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-',''),1,6) as integer) 
								else h.CYM
							end as CYM_
					from SlsList list left join JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h on list.StartDt = h.CYM and  list.ItemNumber_ = h.ItemNumber
					--where    list.StartDt = cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-',''),1,6) as integer)			-- Watch out use List.StartDt Not h.CYM !!!   --- 29/5/2018
							-- h.CYM = '201804' and																													-- Performance issue ?
							--c.rnk =24																												-- last month ( for last month Sales)
					 where  list.StartDt <= cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-',''),1,6) as integer)
						)
				   --select * from hist where hist.ItemNumber_ in ('82.501.904')
				   --select * from hist where hist.ItemNumber_ in ('42.210.031')
				 ,comb as (  select fc.Itm as Item_f, fc.DataType1,fc.StartDt as dt,fc.Value
							  from fc
							 Union all
							 select h.ItemNumber_ as Item_f,'Sales' as DataType1,h.CYM_ as dt,h.SalesQty
							  from hist h

									  )

                 select * from comb c
                -- where  c.Item_f in  ( select splitdata from JDE_DB_Alan.dbo.fnSplitString(@Item_id,','))			 
	                 order by c.Item_f,c.DataType1,c.dt
				 --select * from comb where comb.Itm in ('42.210.031')
				 -- select * from comb
       			--	insert into JDE_DB_Alan.FCPRO_Fcst_Accuracy  select * from comb
					--select * from JDE_DB_Alan.FCPRO_Fcst_Accuracy
	  
	END

	     --select * from JDE_DB_Alan.FCPRO_Fcst_Accuracy_
						 

END
GO


