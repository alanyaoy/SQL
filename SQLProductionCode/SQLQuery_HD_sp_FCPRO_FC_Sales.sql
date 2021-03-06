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
/****** Object:  StoredProcedure [JDE_DB_Alan].[sp_FCPro_FC_Sales_Analysis]    Script Date: 14/01/2020 11:23:34 AM ******/
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
ALTER PROCEDURE [JDE_DB_Alan].[sp_FCPro_FC_Sales_Analysis] 
	-- Add the parameters for the stored procedure here
	--<@Param1, sysname, @p1> <Datatype_For_Param1, , int> = <Default_Value_For_Param1, , 0>, 
	--<@Param2, sysname, @p2> <Datatype_For_Param2, , int> = <Default_Value_For_Param2, , 0>


	-- @FC_ID varchar(100) = null
	-- @Supplier_id varchar(8000) = null
	 @Item_id varchar(8000) = null
	-- ,@DataType varchar (100) = null
	--,@ItemNumber varchar(100) = null
	--,@ShortItemNumber varchar(100) = null
	--,@CenturyYearMonth int = null	
	,@Start_Fc_SaveDate datetime = null
	,@End_Fc_SaveDate datetime = null
	--,@OrderByClause varchar(1000) = null
	  
	


AS
BEGIN
-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	--set @OrderByClause = 'rnk'	

-- Insert statements for procedure here
	--SELECT <@Param1, sysname, @p1>, <@Param2, sysname, @p2>

	     

		 --- Note below code of Sales history & Forecast --> combines use of using  current FC table or FC History table depends on what you need --- 17/9/2018
		 --- When using FC History table, you are using Aug Save FC - 1 Month Offsetting ---
		 --- When using FC table, you are using Current lastest most updated FC ---

	 	---*******************************************************************************************************************---
	--- Note this query analysis Sales/FC trend/Pattern ---
	--- Difference between 'sp_FC_Accy_Data' & 'sp_FC_Sales_Analysis' is that latter only fetch 1 month FC data hence much more concise and no need to pay attention to FC history,
	--- Latter Qry is more about Sales & Forecast trend / Pattern, Former Qry is more about FC accuracy  -- 5/10/2018
	---*******************************************************************************************************************---


	 --- Note this FC Sales Analysis Are using Data from FC table not FC history table Hence more efficient ( if you do not need see FC History this is best choice ) --- 4/9/2018
   
   
   	-- if there is no 'Start_Fc_SaveDate' and 'End_Fc_SaveDate is provided'	then default is to use current month FC
	if @Item_id is not null and @Start_Fc_SaveDate is null and @End_Fc_SaveDate is null	   -- under this option will use 'vw_FC' or 'FC' tbl --> myfc, although you have myfct as part of your code			--5/10/2018
																								   -- you will select lastest FC 			
		   
	      			 ------- Alan's New code ------------------ 1/6/2018 ------
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
                     
				    --- myfc is current lastest updated FC ---
				  ,myfc as ( select * 
									,cast(SUBSTRING(REPLACE(CONVERT(char(10),f.Date,126),'-',''),1,6) as integer) as [StartDate]
									,cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,f.date),0),126),'-',''),1,6) as integer) as FC_date		-- FC date in YYYY-mm format--- 5/9/2018								
								  from JDE_DB_Alan.FCPRO_Fcst f		
								  -- from JDE_DB_Alan.vw_FC f						
								where f.DataType1 in ('Adj_FC')  
								    --  and f.ItemNumber in ('42.210.031')   
									--and f.ItemNumber in ('38.001.001')    
								 ) 
                   --  select * from myfc
                   
				   --- myfct is one month old 1 month offset last month saved FC ---  
                ,myfct as ( select fh.ItemNumber,fh.DataType1,fh.Date
									,fh.myDate2 as FC_date
									,fh.FC_Vol as Value
									,fh.ReportDate
									,fh.myReportDate1
									,fh.myReportDate2
									,fh.myReportDate3						---19/3/2019
							--,cast(SUBSTRING(REPLACE(CONVERT(char(10),f.Date,126),'-',''),1,6) as integer) as [StartDate]
							--,cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,f.date),0),126),'-',''),1,6) as integer) as FC_date		-- FC date in YYYY-mm format--- 5/9/2018								
							--from JDE_DB_Alan.FCPRO_Fcst f 
							 from JDE_DB_Alan.vw_FC_Hist fh
							where fh.DataType1 in ('Adj_FC')  
								--and f.ItemNumber in ('42.210.031')   
							  -- and fh.myReportDate2 = cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-',''),1,6) as integer)	   --3/10/2018 ( Last Month FC saved data )
							 -- and fh.myReportDate2 = cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE()),0),126),'-',''),1,6) as integer)	   --3/10/2018 ( This Month FC saved data )
								-- and fh.myReportDate3 between @Start_Fc_SaveDate and @End_Fc_SaveDate																  --5/10/2018	(Pick up a Version - in terms of FC saved date	)
						       --and fh.myReportDate3 between '2018-10-15' and '2018-10-21'
						)  
	              
				   --select DATEADD(mm, DATEDIFF(m,0,getdate()),0)
				  --select * from myfc f where f.ItemNumber in ('42.210.031') 

				 ----------------------------********** BELOW CODE FOR myfctt is Optional ******-----------------------------------------------------------------
               	 ---if you perfer to use latest FC from 'FC_Hist' tbl rather than from 'FC' tbl, use 'rank' or 'max' funtion -- it is not recommendated as this is complicated -- just use 'FC' tbl for Latest FC --- 23/10/2018
				 ,myfctt as ( select *
									,ROW_NUMBER() over ( partition by fh.Itemnumber order by ReportDate asc) as rn1				--- use ReportDate in over clause here will not garantee result will be ordering by rn1  -- rank vs dense_rank --> https://stackoverflow.com/questions/11183572/whats-the-difference-between-rank-and-dense-rank-functions-in-oracle
									,ROW_NUMBER() over ( partition by fh.Itemnumber order by ReportDate desc) as rn2			--- use ReportDate in over clause here will not garantee result will be ordering by rn2	 -- rank vs dense_rank --> https://stackoverflow.com/questions/11183572/whats-the-difference-between-rank-and-dense-rank-functions-in-oracle
									,rank() over ( partition by fh.Itemnumber order by myReportDate4 desc) as R1
                                    ,rank() over ( partition by fh.Itemnumber order by myReportDate4 asc) as R2  
									,dense_rank() over ( partition by fh.Itemnumber order by myReportDate4 asc) as DR1
									,dense_rank() over ( partition by fh.Itemnumber order by myReportDate4 desc) as DR2
									--,max(ReportDate) as maxdt
				             from JDE_DB_Alan.vw_FC_Hist fh
							  where fh.DataType1 in ('Adj_FC') 
									--and fh.ItemNumber in ('38.001.001') and fh.myReportDate2 = '201810'
                              --group by fh.ItemNumber
							  --order by rn1                 -- this might not be good condition here

							 )	
                  ---------------------------********** ABOVE CODE FOR myfctt is Optional ******----------------------------------------------------------------  


					----- below is tb NOT padded with 0 sales history --- straight from SlsHist tb
					,SlsItm as ( select distinct h.ItemNumber as ItemNumber_ from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h )
					
					,m as ( select * from SlsItm cross join MthCal c 
								 -- where   c.StartDt between replace(convert(varchar(8), DATEADD(mm, DATEDIFF(m,0,GETDATE())-12,0),126),'-','' )			-- last 12 months		
								  --				 and  replace(convert(varchar(8), DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-','' )		   -- last 12 months
										)	
																			     
			      -- select * from SlsList s where s.ItemNumber_ in ('43.205.532M')

				 -------- below is tb padded Item with all Months -------------------

					     ----- old code -----
					--,hist as																													
					--(  select list.ItemNumber_,h.CYM,h.CY,h.Month
					--			,case when h.SalesQty is null then 0 else h.SalesQty end as SalesQty,h.ReportDate
					--		   ,list.YY,list.rnk,list.StartDt,list.month as mth
					--		  ,case 
					--				when h.CYM is null	then cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-',''),1,6) as integer) 
					--				else h.CYM
					--			end as CYM_
					--	from SlsList list left join JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h on list.StartDt = h.CYM and  list.ItemNumber_ = h.ItemNumber
					--	where 					
					--			--c.rnk =24	
					--			rnk <25									-- only history from this month backwards
					  																											
					--		)
					--  --select * from hist where hist.ItemNumber_ in ('43.205.532M')


					   ----- below is tb padded Item with all Months -----
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
					 where   -- list.StartDt = cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-',''),1,6) as integer)			-- Watch out use List.StartDt Not h.CYM !!!   --- 29/5/2018
							-- h.CYM = '201804' and																													-- Performance issue ?
							rnk <25									-- only history from this month backwards																											-- last month ( for last month Sales)
					   --where  m.StartDt <= cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-',''),1,6) as integer)
						)
				 --  select * from hist where hist.ItemNumber_ in ('38.001.001')


				,myhist as 
					( select h.ItemNumber_,h.CYM_2,'Sales' as DataType1,h.SalesQty as Value,h.StartDt				--- CYM_2/ h.StartDt is Sales_date         --- 5/9/2018
						from hist h
					)

				 --select * from myhist h where h.ItemNumber_ in ('43.205.532M')
				,_comb as 
					( select  f.ItemNumber,f.DataType1,f.FC_date as dt,f.Value						
						 from myfc f
						 --  from myfct f
						union all
						select h.ItemNumber_,h.DataType1,h.StartDt as dt,h.Value
						from myhist  h
					)

				,comb as 
				(
					 select b.*
					  ,(b.Value * m.WholeSalePrice) as Amount								-- 19/3/2019 this is dollar amount
					 ,m.Description
					 ,m.FamilyGroup_
					 ,m.Family_0
					 ,m.UOM					
					 ,getdate() as ThisReportDate 
					 from _comb b left join JDE_DB_Alan.vw_Mast m on b.ItemNumber = m.ItemNumber
					 --where b.ItemNumber in ('42.210.031')
					-- where b.ItemNumber in ('82.600.908','82.600.903')
				    --where b.ItemNumber in ('38.001.001') 
				      where b.ItemNumber in  ( select splitdata from JDE_DB_Alan.dbo.fnSplitString(@Item_id,','))			 
					)

                 select * from comb b
				order by b.ItemNumber, b.DataType1 desc,b.dt

		

   -- if @FC_ID = 'This_Mth_FC' and @Item_id is null 	   
    else if @Item_id is not null and @Start_Fc_SaveDate is not null and @End_Fc_SaveDate is not null		--Under this option, will use 'vw_FC_Hist' tbl --> myfct, although you have myfc as part of your code	--5/10/2018	
	  								
		begin
			 ------- Alan's New code ------------------ 1/6/2018 ------
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
                     
				    --- myfc is current lastest updated FC ---
				  ,myfc as ( select * 
									,cast(SUBSTRING(REPLACE(CONVERT(char(10),f.Date,126),'-',''),1,6) as integer) as [StartDate]
									,cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,f.date),0),126),'-',''),1,6) as integer) as FC_date		-- FC date in YYYY-mm format--- 5/9/2018								
								 from JDE_DB_Alan.FCPRO_Fcst f	
								--from JDE_DB_Alan.vw_FC f						
								where f.DataType1 in ('Adj_FC')  
								     -- and f.ItemNumber in ('42.210.031')     
									 --   and f.ItemNumber in ('38.001.001')   
								 ) 
                    -- select * from myfc   
                   
				   --- myfct is one month old 1 month offset last month saved FC ---  
                ,myfct as ( select fh.ItemNumber,fh.DataType1,fh.Date
									,fh.myDate2 as FC_date
									,fh.FC_Vol as Value
									,fh.ReportDate
									,fh.myReportDate1
									,fh.myReportDate2
									,fh.myReportDate3							--19/3/2019
							--,cast(SUBSTRING(REPLACE(CONVERT(char(10),f.Date,126),'-',''),1,6) as integer) as [StartDate]
							--,cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,f.date),0),126),'-',''),1,6) as integer) as FC_date		-- FC date in YYYY-mm format--- 5/9/2018								
							--from JDE_DB_Alan.FCPRO_Fcst f 
							 from JDE_DB_Alan.vw_FC_Hist fh
							where fh.DataType1 in ('Adj_FC')  
								--and f.ItemNumber in ('42.210.031')   
							  -- and fh.myReportDate2 = cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-',''),1,6) as integer)	   --3/10/2018 ( Last Month FC saved data )
							  --and fh.myReportDate2 = cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE()),0),126),'-',''),1,6) as integer)	   --3/10/2018 ( This Month FC saved data )
								 and fh.myReportDate3 between @Start_Fc_SaveDate and @End_Fc_SaveDate																  --5/10/2018	(Pick up a Version - in terms of FC saved date	)
						        --and fh.myReportDate3 between '2018-10-15' and '2018-10-21'
						)  
	              
				   --select DATEADD(mm, DATEDIFF(m,0,getdate()),0)
				  --select * from myfc f where f.ItemNumber in ('42.210.031') 

					----- below is tb NOT padded with 0 sales history --- straight from SlsHist tb
					,SlsItm as ( select distinct h.ItemNumber as ItemNumber_ from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h )
					
					,m as ( select * from SlsItm cross join MthCal c 
								 -- where   c.StartDt between replace(convert(varchar(8), DATEADD(mm, DATEDIFF(m,0,GETDATE())-12,0),126),'-','' )			-- last 12 months		
								  --				 and  replace(convert(varchar(8), DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-','' )		   -- last 12 months
										)	
																			     
			      -- select * from SlsList s where s.ItemNumber_ in ('43.205.532M')

				 -------- below is tb padded Item with all Months -------------------

					     ----- old code -----
					--,hist as																													
					--(  select list.ItemNumber_,h.CYM,h.CY,h.Month
					--			,case when h.SalesQty is null then 0 else h.SalesQty end as SalesQty,h.ReportDate
					--		   ,list.YY,list.rnk,list.StartDt,list.month as mth
					--		  ,case 
					--				when h.CYM is null	then cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-',''),1,6) as integer) 
					--				else h.CYM
					--			end as CYM_
					--	from SlsList list left join JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h on list.StartDt = h.CYM and  list.ItemNumber_ = h.ItemNumber
					--	where 					
					--			--c.rnk =24	
					--			rnk <25									-- only history from this month backwards
					  																											
					--		)
					--  --select * from hist where hist.ItemNumber_ in ('43.205.532M')


					   ----- below is tb padded Item with all Months -----
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
					 where   -- list.StartDt = cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-',''),1,6) as integer)			-- Watch out use List.StartDt Not h.CYM !!!   --- 29/5/2018
							-- h.CYM = '201804' and																													-- Performance issue ?
							rnk <25									-- only history from this month backwards																											-- last month ( for last month Sales)
					   --where  m.StartDt <= cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-',''),1,6) as integer)
						)
				 --  select * from hist where hist.ItemNumber_ in ('38.001.001')


				,myhist as 
					( select h.ItemNumber_,h.CYM_2,'Sales' as DataType1,h.SalesQty as Value,h.StartDt				--- CYM_2/ h.StartDt is Sales_date         --- 5/9/2018
						from hist h
					)

				 --select * from myhist h where h.ItemNumber_ in ('43.205.532M')
				,_comb as 
					( select  f.ItemNumber,f.DataType1,f.FC_date as dt,f.Value						
						-- from myfc f
						   from myfct f
						union all
						select h.ItemNumber_,h.DataType1,h.StartDt as dt,h.Value
						from myhist  h
					)

				,comb as 
				(
					 select b.*
					 ,(b.Value * m.WholeSalePrice) as Amount								-- 19/3/2019 this is dollar amount
					 ,m.Description
					 ,m.FamilyGroup_
					 ,m.Family_0
					 ,m.UOM					 
					 ,getdate() as ThisReportDate 
					 from _comb b left join JDE_DB_Alan.vw_Mast m on b.ItemNumber = m.ItemNumber
					 --where b.ItemNumber in ('42.210.031')
					-- where b.ItemNumber in ('82.600.908','82.600.903')
				    --where b.ItemNumber in ('38.001.001') 
				      where b.ItemNumber in  ( select splitdata from JDE_DB_Alan.dbo.fnSplitString(@Item_id,','))			 
					)

                select * from comb b
				order by b.ItemNumber, b.DataType1 desc,b.dt	
       end

    else if @Item_id is null  and @Start_Fc_SaveDate is not null and @End_Fc_SaveDate is not null	  --under this option, will use 'vw_FC_Hist' tbl --> myfct, although you have myfc as part of your code				--5/10/2018
	begin 	   
	      			 ------- Alan's New code ------------------ 1/6/2018 ------
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
                     
				    --- myfc is current lastest updated FC ---
				  ,myfc as ( select * 				                      
									,cast(SUBSTRING(REPLACE(CONVERT(char(10),f.Date,126),'-',''),1,6) as integer) as [StartDate]
									,cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,f.date),0),126),'-',''),1,6) as integer) as FC_date		-- FC date in YYYY-mm format--- 5/9/2018								
								 from JDE_DB_Alan.FCPRO_Fcst f		
								-- from JDE_DB_Alan.vw_FC f						
								where f.DataType1 in ('Adj_FC')  
								     -- and f.ItemNumber in ('42.210.031')     
									 -- and f.ItemNumber in ('38.001.001')  
								 ) 
                    --select * from myfc
                   
                 --- myfct is one month old 1 month offset last month saved FC ---  
                ,myfct as ( select fh.ItemNumber,fh.DataType1,fh.Date
									,fh.myDate2 as FC_date
									,fh.FC_Vol as Value
									,fh.ReportDate
									,fh.myReportDate1
									,fh.myReportDate2
									,fh.myReportDate3						---19/3/2019
							--,cast(SUBSTRING(REPLACE(CONVERT(char(10),f.Date,126),'-',''),1,6) as integer) as [StartDate]
							--,cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,f.date),0),126),'-',''),1,6) as integer) as FC_date		-- FC date in YYYY-mm format--- 5/9/2018								
							--from JDE_DB_Alan.FCPRO_Fcst f 
							 from JDE_DB_Alan.vw_FC_Hist fh
							where fh.DataType1 in ('Adj_FC')  
								--and f.ItemNumber in ('42.210.031')   
							  -- and fh.myReportDate2 = cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-',''),1,6) as integer)	   --3/10/2018 ( Last Month FC saved data )
							  --and fh.myReportDate2 = cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE()),0),126),'-',''),1,6) as integer)	   --3/10/2018 ( This Month FC saved data )
								 and fh.myReportDate3 between @Start_Fc_SaveDate and @End_Fc_SaveDate																  --5/10/2018	(Pick up a Version - in terms of FC saved date	)
					           --  and fh.myReportDate3 between '2019-03-02' and '2019-12-21'
						)				 

	              
				   --select DATEADD(mm, DATEDIFF(m,0,getdate()),0)
				  --select * from myfc f where f.ItemNumber in ('42.210.031') 

					----- below is tb NOT padded with 0 sales history --- straight from SlsHist tb
					,SlsItm as ( select distinct h.ItemNumber as ItemNumber_ from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h )
					
					,m as ( select * from SlsItm cross join MthCal c 
								 -- where   c.StartDt between replace(convert(varchar(8), DATEADD(mm, DATEDIFF(m,0,GETDATE())-12,0),126),'-','' )			-- last 12 months		
								  --				 and  replace(convert(varchar(8), DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-','' )		   -- last 12 months
										)	
																			     
			      -- select * from SlsList s where s.ItemNumber_ in ('43.205.532M')

				 -------- below is tb padded Item with all Months -------------------

					     ----- old code -----
					--,hist as																													
					--(  select list.ItemNumber_,h.CYM,h.CY,h.Month
					--			,case when h.SalesQty is null then 0 else h.SalesQty end as SalesQty,h.ReportDate
					--		   ,list.YY,list.rnk,list.StartDt,list.month as mth
					--		  ,case 
					--				when h.CYM is null	then cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-',''),1,6) as integer) 
					--				else h.CYM
					--			end as CYM_
					--	from SlsList list left join JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h on list.StartDt = h.CYM and  list.ItemNumber_ = h.ItemNumber
					--	where 					
					--			--c.rnk =24	
					--			rnk <25									-- only history from this month backwards
					  																											
					--		)
					--  --select * from hist where hist.ItemNumber_ in ('43.205.532M')


					   ----- below is tb padded Item with all Months -----
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
					 where   -- list.StartDt = cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-',''),1,6) as integer)			-- Watch out use List.StartDt Not h.CYM !!!   --- 29/5/2018
							-- h.CYM = '201804' and																													-- Performance issue ?
							rnk <25									-- only history from this month backwards																											-- last month ( for last month Sales)
					   --where  m.StartDt <= cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-',''),1,6) as integer)
						)
				 --  select * from hist where hist.ItemNumber_ in ('38.001.001')


				,myhist as 
					( select h.ItemNumber_,h.CYM_2,'Sales' as DataType1,h.SalesQty as Value,h.StartDt				--- CYM_2/ h.StartDt is Sales_date         --- 5/9/2018
						from hist h
					)

				 --select * from myhist h where h.ItemNumber_ in ('43.205.532M')
				,_comb as 
					( select  f.ItemNumber,f.DataType1,f.FC_date as dt,f.Value						
						 --from myfc f
						   from myfct f
						union all
						select h.ItemNumber_,h.DataType1,h.StartDt as dt,h.Value
						from myhist  h
					)

				,comb as 
				(
					 select b.*
					 ,(b.Value * m.WholeSalePrice) as Amount			-- 19/3/2019 this is dollar amount
					 ,m.Description
					 ,m.FamilyGroup_
					 ,m.Family_0
					 ,m.UOM	
					-- ,1 as skucnt				 
					 ,getdate() as ThisReportDate 
					 from _comb b left join JDE_DB_Alan.vw_Mast m on b.ItemNumber = m.ItemNumber
					--where b.ItemNumber in ('42.210.031')
					-- where b.ItemNumber in ('82.600.908','82.600.903')
				   -- where b.ItemNumber in ('38.001.001') 
				   --   where b.ItemNumber in  ( select splitdata from JDE_DB_Alan.dbo.fnSplitString(@Item_id,','))			 
					)

                 select * 
				     --   ,avg(skucnt)over(partition by b.FamilyGroup_) as Family_Cnt
					 --  ,count(Family_0)over(partition by b.FamilyGroup_)/48 as Family_Cnt 
				 from comb b
		      -- where b.FamilyGroup_ like('%982%')			--- Roller fabric  ( 982 )
				 order by b.ItemNumber, b.DataType1 desc,b.dt


		END

       --- pick up everything --- 14/1/2020
    else if @Item_id is null  and @Start_Fc_SaveDate is null and @End_Fc_SaveDate is null	  --under this option, will use 'vw_FC_Hist' tbl --> myfct, although you have myfc as part of your code				--5/10/2018
	  begin 	   
	      			 ------- Alan's New code ------------------ 1/6/2018 ------
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
                     
				    --- myfc is current lastest updated FC ---
				  ,myfc as ( select * 				                      
									,cast(SUBSTRING(REPLACE(CONVERT(char(10),f.Date,126),'-',''),1,6) as integer) as [StartDate]
									,cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,f.date),0),126),'-',''),1,6) as integer) as FC_date		-- FC date in YYYY-mm format--- 5/9/2018								
								 from JDE_DB_Alan.FCPRO_Fcst f		
								-- from JDE_DB_Alan.vw_FC f						
								where f.DataType1 in ('Adj_FC')  
								     -- and f.ItemNumber in ('42.210.031')     
									 -- and f.ItemNumber in ('38.001.001')  
								 ) 
                    --select * from myfc
                   
                 --- myfct is one month old 1 month offset last month saved FC ---  
                ,myfct as ( select fh.ItemNumber,fh.DataType1,fh.Date
									,fh.myDate2 as FC_date
									,fh.FC_Vol as Value
									,fh.ReportDate
									,fh.myReportDate1
									,fh.myReportDate2
									,fh.myReportDate3						---19/3/2019
							--,cast(SUBSTRING(REPLACE(CONVERT(char(10),f.Date,126),'-',''),1,6) as integer) as [StartDate]
							--,cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,f.date),0),126),'-',''),1,6) as integer) as FC_date		-- FC date in YYYY-mm format--- 5/9/2018								
							--from JDE_DB_Alan.FCPRO_Fcst f 
							 from JDE_DB_Alan.vw_FC_Hist fh
							where fh.DataType1 in ('Adj_FC')  
								--and f.ItemNumber in ('42.210.031')   
							  -- and fh.myReportDate2 = select cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-',''),1,6) as integer)	   --3/10/2018 ( Last Month FC saved data )
							  --and fh.myReportDate2 = select cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE()),0),126),'-',''),1,6) as integer)	   --3/10/2018 ( This Month FC saved data )
								-- and fh.myReportDate3 between @Start_Fc_SaveDate and @End_Fc_SaveDate																  --5/10/2018	(Pick up a Version - in terms of FC saved date	)
					           --  and fh.myReportDate3 between '2019-03-02' and '2019-12-21'
						)				 

	              
				   --select DATEADD(mm, DATEDIFF(m,0,getdate()),0)
				  --select * from myfc f where f.ItemNumber in ('42.210.031') 

					----- below is tb NOT padded with 0 sales history --- straight from SlsHist tb
					,SlsItm as ( select distinct h.ItemNumber as ItemNumber_ from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h )
					
					,m as ( select * from SlsItm cross join MthCal c 
								 -- where   c.StartDt between replace(convert(varchar(8), DATEADD(mm, DATEDIFF(m,0,GETDATE())-12,0),126),'-','' )			-- last 12 months		
								  --				 and  replace(convert(varchar(8), DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-','' )		   -- last 12 months
										)	
																			     
			      -- select * from SlsList s where s.ItemNumber_ in ('43.205.532M')

				 -------- below is tb padded Item with all Months -------------------

					     ----- old code -----
					--,hist as																													
					--(  select list.ItemNumber_,h.CYM,h.CY,h.Month
					--			,case when h.SalesQty is null then 0 else h.SalesQty end as SalesQty,h.ReportDate
					--		   ,list.YY,list.rnk,list.StartDt,list.month as mth
					--		  ,case 
					--				when h.CYM is null	then cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-',''),1,6) as integer) 
					--				else h.CYM
					--			end as CYM_
					--	from SlsList list left join JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h on list.StartDt = h.CYM and  list.ItemNumber_ = h.ItemNumber
					--	where 					
					--			--c.rnk =24	
					--			rnk <25									-- only history from this month backwards
					  																											
					--		)
					--  --select * from hist where hist.ItemNumber_ in ('43.205.532M')


					   ----- below is tb padded Item with all Months -----
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
					 where   -- list.StartDt = cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-',''),1,6) as integer)			-- Watch out use List.StartDt Not h.CYM !!!   --- 29/5/2018
							-- h.CYM = '201804' and																													-- Performance issue ?
							rnk <25									-- only history from this month backwards																											-- last month ( for last month Sales)
					   --where  m.StartDt <= cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-',''),1,6) as integer)
						)
				 --  select * from hist where hist.ItemNumber_ in ('38.001.001')


				,myhist as 
					( select h.ItemNumber_,h.CYM_2,'Sales' as DataType1,h.SalesQty as Value,h.StartDt				--- CYM_2/ h.StartDt is Sales_date         --- 5/9/2018
						from hist h
					)

				 --select * from myhist h where h.ItemNumber_ in ('43.205.532M')
				,_comb as 
					( select  f.ItemNumber,f.DataType1,f.FC_date as dt,f.Value						
						  from myfc f
						  -- from myfct f
						union all
						select h.ItemNumber_,h.DataType1,h.StartDt as dt,h.Value
						from myhist  h
					)

				,comb as 
				(
					 select b.*
					 ,(b.Value * m.WholeSalePrice) as Amount			-- 19/3/2019 this is dollar amount
					 ,m.Description
					 ,m.FamilyGroup_
					 ,m.Family_0
					 ,m.UOM	
					-- ,1 as skucnt				 
					 ,getdate() as ThisReportDate 
					 from _comb b left join JDE_DB_Alan.vw_Mast m on b.ItemNumber = m.ItemNumber
					--where b.ItemNumber in ('42.210.031')
					-- where b.ItemNumber in ('82.600.908','82.600.903')
				   -- where b.ItemNumber in ('38.001.001') 
				   --   where b.ItemNumber in  ( select splitdata from JDE_DB_Alan.dbo.fnSplitString(@Item_id,','))			 
					)

                 select * 
				     --   ,avg(skucnt)over(partition by b.FamilyGroup_) as Family_Cnt
					 --  ,count(Family_0)over(partition by b.FamilyGroup_)/48 as Family_Cnt 
				 from comb b
		      -- where b.FamilyGroup_ like('%982%')			--- Roller fabric  ( 982 )
				 order by b.ItemNumber, b.DataType1 desc,b.dt


		END



END
