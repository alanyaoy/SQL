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
/****** Object:  StoredProcedure [JDE_DB_Alan].[sp_FCPro_FC_Sales_Analysis]    Script Date: 23/08/2018 3:56:18 PM ******/
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

	-- @Supplier_id varchar(8000) = null
	 @Item_id varchar(8000) = null
	-- ,@DataType varchar (100) = null
	--,@ItemNumber varchar(100) = null
	--,@ShortItemNumber varchar(100) = null
	--,@CenturyYearMonth int = null	
	--,@Start datetime = null
	--,@End datetime = null
	--,@OrderByClause varchar(1000) = null
	


AS
BEGIN
-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	--set @OrderByClause = 'rnk'	

-- Insert statements for procedure here
	--SELECT <@Param1, sysname, @p1>, <@Param2, sysname, @p2>
	 
	if @Item_id is not null 
	 
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

				  ,myfc as ( select * 
									,cast(SUBSTRING(REPLACE(CONVERT(char(10),f.Date,126),'-',''),1,6) as integer) as [StartDate]
								from JDE_DB_Alan.FCPRO_Fcst f 
								where f.DataType1 in ('Adj_FC')       
								 ) 
	  
				  --select * from myfc f where f.ItemNumber in ('42.210.031') 

					----- below is tb NOT padded with 0 sales history --- straight from SlsHist tb
					,SlsItm as ( select distinct h.ItemNumber as ItemNumber_ from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h )
					,SlsList as ( select * from SlsItm cross join MthCal c 
								 -- where   c.StartDt between replace(convert(varchar(8), DATEADD(mm, DATEDIFF(m,0,GETDATE())-12,0),126),'-','' )			-- last 12 months		
								  --				 and  replace(convert(varchar(8), DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-','' )		   -- last 12 months
										)		
										     
			      -- select * from SlsList s where s.ItemNumber_ in ('43.205.532M')

						 ----- below is tb padded Item with all Months ---
					,hist as																													
					(  select list.ItemNumber_,h.CYM,h.CY,h.Month
								,case when h.SalesQty is null then 0 else h.SalesQty end as SalesQty,h.ReportDate
							   ,list.YY,list.rnk,list.StartDt,list.month as mth
							  ,case 
									when h.CYM is null	then cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-',''),1,6) as integer) 
									else h.CYM
								end as CYM_
						from SlsList list left join JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h on list.StartDt = h.CYM and  list.ItemNumber_ = h.ItemNumber
						where 					
								--c.rnk =24	
								rnk <25									-- only history from this month backwards
					  																											
							)
					  --select * from hist where hist.ItemNumber_ in ('43.205.532M')


					 ,myhist as 
							( select h.ItemNumber_,CYM_,'Sales' as DataType1,h.SalesQty as Value,h.StartDt
								from hist h
							)

					 -- select * from myhist h where h.ItemNumber_ in ('43.205.532M')
					 ,comb as 
							( select  f.ItemNumber,f.DataType1,f.StartDate,f.Value
							   from myfc f
							  union all
							 select h.ItemNumber_,h.DataType1,h.StartDt,h.Value
							 from myhist  h
							)

					 select * from comb b 
					--where b.ItemNumber in ('42.210.031') 
					where b.ItemNumber in  ( select splitdata from JDE_DB_Alan.dbo.fnSplitString(@Item_id,','))			 
	                 order by b.ItemNumber, b.DataType1 desc,b.StartDate
	 
	else if @Item_id is null
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

				  ,myfc as ( select * 
									,cast(SUBSTRING(REPLACE(CONVERT(char(10),f.Date,126),'-',''),1,6) as integer) as [StartDate]
								from JDE_DB_Alan.FCPRO_Fcst f 
								where f.DataType1 in ('Adj_FC')       
								 ) 
	  
				  --select * from myfc f where f.ItemNumber in ('42.210.031') 

					----- below is tb NOT padded with 0 sales history --- straight from SlsHist tb
					,SlsItm as ( select distinct h.ItemNumber as ItemNumber_ from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h )
					,SlsList as ( select * from SlsItm cross join MthCal c 
								 -- where   c.StartDt between replace(convert(varchar(8), DATEADD(mm, DATEDIFF(m,0,GETDATE())-12,0),126),'-','' )			-- last 12 months		
								  --				 and  replace(convert(varchar(8), DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-','' )		   -- last 12 months
										)		
										     
			      -- select * from SlsList s where s.ItemNumber_ in ('43.205.532M')

						 ----- below is tb padded Item with all Months ---
					,hist as																													
					(  select list.ItemNumber_,h.CYM,h.CY,h.Month
								,case when h.SalesQty is null then 0 else h.SalesQty end as SalesQty,h.ReportDate
							   ,list.YY,list.rnk,list.StartDt,list.month as mth
							  ,case 
									when h.CYM is null	then cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-',''),1,6) as integer) 
									else h.CYM
								end as CYM_
						from SlsList list left join JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h on list.StartDt = h.CYM and  list.ItemNumber_ = h.ItemNumber
						where 					
								--c.rnk =24	
								rnk <25									-- only history from this month backwards
					  																											
							)
					  --select * from hist where hist.ItemNumber_ in ('43.205.532M')


					 ,myhist as 
							( select h.ItemNumber_,CYM_,'Sales' as DataType1,h.SalesQty as Value,h.StartDt
								from hist h
							)

					 -- select * from myhist h where h.ItemNumber_ in ('43.205.532M')
					 ,comb as 
							( select  f.ItemNumber,f.DataType1,f.StartDate,f.Value
							   from myfc f
							  union all
							 select h.ItemNumber_,h.DataType1,h.StartDt,h.Value
							 from myhist  h
							)

					 select * from comb b 
					 --where b.ItemNumber in ('42.210.031') 
					 --where b.ItemNumber in  ( select splitdata from JDE_DB_Alan.dbo.fnSplitString(@Item_id,','))
					 order by b.ItemNumber, b.DataType1 desc,b.StartDate
		  


	END


END
