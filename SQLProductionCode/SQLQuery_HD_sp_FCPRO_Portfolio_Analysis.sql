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
/****** Object:  StoredProcedure [JDE_DB_Alan].[sp_FCPro_Portfolio_Analysis]    Script Date: 5/09/2018 11:39:54 AM ******/
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
ALTER PROCEDURE [JDE_DB_Alan].[sp_FCPro_Portfolio_Analysis] 
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
	,@OrderByClause varchar(1000) = null
	


AS
BEGIN
-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	--set @OrderByClause = 'rnk'	

-- Insert statements for procedure here
	--SELECT <@Param1, sysname, @p1>, <@Param2, sysname, @p2>
	 
	if @Item_id is null and @Start is not null and @end is not null
	 
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
							,DATENAME(mm,start) MnthName,DATENAME(yyyy,start) YearName from CalendarFrame
			)
		 --select * from MonthlyCalendar
		--cldr as
		--		(select mc.t
		--			,left(mc.eom,6)  as eom_
		--		from MonthlyCalendar mc 
		--		--where left(mc.eom,4)=2015
		--		where mc.eom> replace(convert(varchar(8), DATEADD(mm, DATEDIFF(m,0,GETDATE())-13,0),126),'-','')		--last 12 months
		--	),

		 --hist_ as ( select *,					
			--					case 
			--						when h.Month >= 10 then format(h.Month,'0') 
			--						--else right('000'+cast(a.financialMonth as varchar(2)),3) 
			--						when h.Month <10 then format(h.Month,'00') 
			--					end as MM
			--			from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h
			--			),
			--hist as ( select *,concat(hist_.CY,hist_.MM) as CYM_
			--				from hist_
			--			), 
			--histy as (select x.ItemNumber,count(x.CYM_) Sls_freq,sum(isnull(x.SalesQty,0)) SlsVol_TTL_12
			--			from hist x 
			--			--where x.ItemNumber in ('26.353.000') and x.CYM >201612
			--			where x.cym_ >replace(convert(varchar(8), DATEADD(mm, DATEDIFF(m,0,GETDATE())-13,0),126),'-','')				-- last 12 months
			--			group by x.ItemNumber )	,				--- sales about 9139 records
      

		,itm as ( select distinct h.ItemNumber as ItemNumber_ from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h )
		,m as ( select * from itm cross join MonthlyCalendar cldr 
					where --StartDate						-- original name of '[StartDate]' in template 
					        StartDt2
							 between replace(convert(varchar(8), DATEADD(mm, DATEDIFF(m,0,GETDATE())-12,0),126),'-','' )			-- last 12 months		
											 and  replace(convert(varchar(8), DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-','' )		-- last 12 months
				  )	
				  
	     --  select * from m where m.ItemNumber_ in ('38.001.001')	
		 		  	     
		----------------- Padded Item with all Months --------------------		
		  
		   --- old code as of 3/9/2018	 ---
		--,hist as													
		--(  select m.ItemNumber_ 
		--		,case when h.SalesQty is null then 0 else h.SalesQty end as SalesQty_
		--		--,m.StartDate as CYM                      -- original name of '[StartDate]' in template
		--		,m.StartDt2 as CYM
		--		,m.t
		--	from m left join JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h on m.StartDt2 = h.CYM and m.ItemNumber_ = h.ItemNumber
		----where list.ItemNumber in ('18.615.024') 		
		--)

		     --- below is tb padded Item with all Months ---
		,hist as																													
		(  select m.ItemNumber_
				            
					,h.CYM,h.CY,h.Month
				    ,h.ReportDate
					,case when h.SalesQty is null then 0 else h.SalesQty end as SalesQty_
					--,case when h.ReportDate is null then getdate() else h.ReportDate end as ReportDate_
					--  ,case when h.ReportDate is null then getdate() else h.ReportDate end as ReportDate_
					,getdate() as ReportDate_												-- there is no different version of history, so do not bother to use old ReportData in History table UNLESS you need to join back to History table using ReportData as a key --- 5/9/2018
					,m.StartDt2
					--,m.YY, m.rnk,m.month as mth						  
					,case 
						when h.CYM is null	then cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-',''),1,6) as integer) 		-- why use this ?						
						else h.CYM
					end as CYM_
                    ,case 
						when h.CYM is null	then m.StartDt2					
						else h.CYM
					end as CYM_2

			from m left join JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h on m.StartDt2 = h.CYM and  m.ItemNumber_ = h.ItemNumber
			--where    list.StartDt = cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-',''),1,6) as integer)			-- Watch out use List.StartDt Not h.CYM !!!   --- 29/5/2018
					-- h.CYM = '201804' and																													-- Performance issue ?
					--c.rnk =24																												-- last month ( for last month Sales)
				where  m.StartDt2 <= cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-',''),1,6) as integer)
				)

			-- select * from hist where hist.ItemNumber_ in ('38.001.001')

		--select * from hist h where h.ItemNumber_ in ('38.001.001')
		,histy as 
			( select x.ItemNumber_
			,count(isnull(x.CYM_2,0)) TTL_SlsMths			-- Or you can use --> count(isnull(x.StartDt2,0)) TTL_SlsMths
			,sum( case when salesqty_ >0 then 1 else 0 end ) as Sls_freq
			,sum(x.SalesQty_) SlsVol_TTL_12 
			from hist x 
			group by x.ItemNumber_)
		--select * from histy where histy.ItemNumber_ in ('03.986.000','38.001.001')

		,stk as (
					select a.ItemNumber,sum(coalesce(a.QtyOnHand,0)) SOHVol 
					from JDE_DB_Alan.Master_ML345 a 
					--from m
					--where a.ItemNumber in ('24.7206.0000')
					--where a.ItemNumber in ('03.986.000')
					-- where a.ItemNumber in ('24.057.165s')   -- cannot find '24.057.165s' in ML345 file hence later table join will yield Null Value causing potential issue in coding - 29/1/18
					group by a.ItemNumber
					)					
		,fc_Vol as  
			( select fct.DataType1,fct.ItemNumber,sum(isnull(fct.value,0)) as ItemLvlFCVol_1To24,count(isnull(fct.Date,0)) Count_FC_Period   ---TTL_FCMths	
				from JDE_DB_Alan.FCPRO_Fcst fct					-- 22/1/2018 did not have  condition before --> where fct.DataType1 like ('%Adj_FC%')	
				  where fct.DataType1 like ('%Adj_FC%')			-- 26/2/2018
				        --and fct.Date between '2018-05-01' and '2018-10-01'			-- For Signature New Product Post Launch Analysis --- 5/6/2018
						  and fct.Date between @Start and @End
				group by fct.DataType1,fct.ItemNumber)	
		
		,fcVol as (	select fc_Vol.ItemNumber
						,fc_Vol.DataType1							
						,fc_Vol.ItemLvlFCVol_1To24							
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
				--select * from fcVol where fcvol.ItemNumber = '03.986.000'
				--where fcVol.ItemLvlFCVol_24 is null		-- where fc.ItemNumber = '18.615.024' --- fc about 10125 record

			   --- Item Level ----
		,comb_Vol as (select fc_Vol.ItemNumber,histy.SlsVol_TTL_12,histy.Sls_Freq								
								,fc_Vol.ItemLvlFCVol_1To24
								,fc_Vol.Count_FC_Period
								,stk.SOHVol
								--,coalesce(stk.SOHVol/(nullif(fc_Vol.ItemLvlFCVol_1To24/24,0)),0) as SOHWksCover						--if divisor is 0	
								,coalesce(stk.SOHVol/(nullif(fc_Vol.ItemLvlFCVol_1To24/fc_Vol.Count_FC_Period,0)),0) as SOHWksCover			--if divisor is 0 And FC month count varies --- 19/7/2018					 
						from fc_Vol left join histy on fc_Vol.ItemNumber = histy.ItemNumber_
									left join stk on stk.ItemNumber = histy.ItemNumber_
						)
		-- select * from comb_vol  where comb_Vol.SOHWksCover is null
		-- where comb_vol.ItemNumber = ('03.986.000')

		,combVol as ( select comb_Vol.*,px.StandardCost as Cost,px.WholeSalePrice as Price
						from comb_Vol left join JDE_DB_Alan.Px_AWF_HD_MT_FCPro_upload px on comb_Vol.ItemNumber = px.ItemNumber
						)

		,pareto as ( select p.ItemNumber,p.rnk,p.DataType1,p.Pareto from JDE_DB_Alan.FCPRO_Fcst_Pareto p where p.DataType1 like ('%Adj_FC%')			--26/2/2018
						)

		,comb_Amt as ( select combVol.*,Pareto.Pareto,pareto.rnk,ss.SS_
							,combVol.SlsVol_ttl_12*combVol.price as SlsAmt_12
							,combVol.ItemLvlFCVol_1To24*combVol.price as FCAmt_1To24
							,combVol.SOHVol*combVol.cost as SOHAmt										 
							from combVol left join pareto on combVol.ItemNumber = pareto.ItemNumber
											left join JDE_DB_Alan.FCPRO_SafetyStock ss on combVol.ItemNumber = ss.ItemNumber
					)
		 --select * from comb_Amt where comb_Amt.SlsAmt_12 is null or comb_Amt.FCAmt_24 is null or SOHAmt  is null

		,fl_ as ( select * 
							,sum(comb_Amt.SlsVol_TTL_12) over() as SlsVol_Grd
							,sum(comb_Amt.ItemLvlFCVol_1To24) over() as FCVol_Grd
							,sum(comb_Amt.SOHVol) over() as SOHVol_Grd
							,sum(comb_Amt.SlsAmt_12) over() as SlsAmt_Grd
							,sum(comb_Amt.FCAmt_1To24) over() as FCAmt_Grd
							,sum(comb_Amt.SOHAmt) over() as SOHAmt_Grd
						from comb_Amt)

        --- Get Supplier name ---
		,_mas as ( select a.ItemNumber
					,a.PrimarySupplier
					,case a.PlannerNumber when '20072' then 'Salman Saeed'
						when '20004' then 'Margaret Dost'	
						when '20005' then 'Imelda Chan'
						when '20071' then 'Domenic Cellucci'
						else 'Unknown'
					end as Owner_
					,a.Description
					,a.LeadtimeLevel as LeadTime
					,a.UOM
					,a.StockingType
					,row_number() over(partition by a.itemnumber order by a.itemnumber) as rn 
				 from JDE_DB_Alan.Master_ML345 a)
		,mas as ( select * 
				from _mas where rn =1 )

        ,_fl as ( select fl_.*,m.PrimarySupplier,m.Owner_,m.Description,m.LeadTime,m.UOM,m.StockingType from fl_ left join mas m on fl_.ItemNumber = m.ItemNumber) 

		select * from _fl
			-- where fl_.ItemNumber like ('%85053100%')	
		-- where fl_.ItemNumber in ('7495500001')	
	  -- where fl_.ItemNumber in (2974000000'	
		-- where fl_.ItemNumber in ('24.057.165s')					-- cannot find '24.057.165s' in ML345 file hence later table join will yield Null Value causing potential issue in coding - 29/1/18
		  
		-- m.PrimarySupplier in ( select data from JDE_DB_Alan.dbo.Split(@Supplier_id,','))
		--	fl_.ItemNumber in ( select data from JDE_DB_Alan.dbo.Split(@Item_id,','))
	   --order by fl_.SlsAmt_12 desc
	   --  order by fl_.rnk
	 	order by 			 
					case when @OrderByClause ='rnk' then _fl.rnk end,
					case when @OrderByClause ='SlsAmt_12' then _fl.SlsAmt_12 end desc,
					case when @OrderByClause ='SOHAmt' then _fl.SOHAmt end desc						 				 
	 
	 
	else if @Item_id is not null and @Start is not null and @end is not null
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
								,DATENAME(mm,start) MnthName,DATENAME(yyyy,start) YearName from CalendarFrame
				)
			 --select * from MonthlyCalendar
			--cldr as
			--		(select mc.t
			--			,left(mc.eom,6)  as eom_
			--		from MonthlyCalendar mc 
			--		--where left(mc.eom,4)=2015
			--		where mc.eom> replace(convert(varchar(8), DATEADD(mm, DATEDIFF(m,0,GETDATE())-13,0),126),'-','')		--last 12 months
			--	),

			 --hist_ as ( select *,					
				--					case 
				--						when h.Month >= 10 then format(h.Month,'0') 
				--						--else right('000'+cast(a.financialMonth as varchar(2)),3) 
				--						when h.Month <10 then format(h.Month,'00') 
				--					end as MM
				--			from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h
				--			),
				--hist as ( select *,concat(hist_.CY,hist_.MM) as CYM_
				--				from hist_
				--			), 
				--histy as (select x.ItemNumber,count(x.CYM_) Sls_freq,sum(isnull(x.SalesQty,0)) SlsVol_TTL_12
				--			from hist x 
				--			--where x.ItemNumber in ('26.353.000') and x.CYM >201612
				--			where x.cym_ >replace(convert(varchar(8), DATEADD(mm, DATEDIFF(m,0,GETDATE())-13,0),126),'-','')				-- last 12 months
				--			group by x.ItemNumber )	,				--- sales about 9139 records
      

			,itm as ( select distinct h.ItemNumber as ItemNumber_ from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h )
			,m as ( select * from itm cross join MonthlyCalendar cldr 
						where --StartDate						-- original name of '[StartDate]' in template 
								StartDt2
								 between replace(convert(varchar(8), DATEADD(mm, DATEDIFF(m,0,GETDATE())-12,0),126),'-','' )			-- last 12 months		
												 and  replace(convert(varchar(8), DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-','' )		-- last 12 months
					  )	
				  
			 --  select * from m where m.ItemNumber_ in ('38.001.001')	
		 		  	     
			----------------- Padded Item with all Months --------------------		
		  
			   --- old code as of 3/9/2018	 ---
			--,hist as													
			--(  select m.ItemNumber_ 
			--		,case when h.SalesQty is null then 0 else h.SalesQty end as SalesQty_
			--		--,m.StartDate as CYM                      -- original name of '[StartDate]' in template
			--		,m.StartDt2 as CYM
			--		,m.t
			--	from m left join JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h on m.StartDt2 = h.CYM and m.ItemNumber_ = h.ItemNumber
			----where list.ItemNumber in ('18.615.024') 		
			--)

				 --- below is tb padded Item with all Months ---
			,hist as																													
			(  select m.ItemNumber_
				            
						,h.CYM,h.CY,h.Month
						,h.ReportDate
						,case when h.SalesQty is null then 0 else h.SalesQty end as SalesQty_
						--,case when h.ReportDate is null then getdate() else h.ReportDate end as ReportDate_
						--  ,case when h.ReportDate is null then getdate() else h.ReportDate end as ReportDate_
						,getdate() as ReportDate_												-- there is no different version of history, so do not bother to use old ReportData in History table UNLESS you need to join back to History table using ReportData as a key --- 5/9/2018
						,m.StartDt2
						--,m.YY, m.rnk,m.month as mth						  
						,case 
							when h.CYM is null	then cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-',''),1,6) as integer) 		-- why use this ?						
							else h.CYM
						end as CYM_
						,case 
							when h.CYM is null	then m.StartDt2					
							else h.CYM
						end as CYM_2

				from m left join JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h on m.StartDt2 = h.CYM and  m.ItemNumber_ = h.ItemNumber
				--where    list.StartDt = cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-',''),1,6) as integer)			-- Watch out use List.StartDt Not h.CYM !!!   --- 29/5/2018
						-- h.CYM = '201804' and																													-- Performance issue ?
						--c.rnk =24																												-- last month ( for last month Sales)
					where  m.StartDt2 <= cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-',''),1,6) as integer)
					)

				-- select * from hist where hist.ItemNumber_ in ('38.001.001')

			--select * from hist h where h.ItemNumber_ in ('38.001.001')
			,histy as 
				( select x.ItemNumber_
				,count(isnull(x.CYM_2,0)) TTL_SlsMths			-- Or you can use --> count(isnull(x.StartDt2,0)) TTL_SlsMths
				,sum( case when salesqty_ >0 then 1 else 0 end ) as Sls_freq
				,sum(x.SalesQty_) SlsVol_TTL_12 
				from hist x 
				group by x.ItemNumber_)
			--select * from histy where histy.ItemNumber_ in ('03.986.000','38.001.001')

			,stk as (
						select a.ItemNumber,sum(coalesce(a.QtyOnHand,0)) SOHVol 
						from JDE_DB_Alan.Master_ML345 a 
						--from m
						--where a.ItemNumber in ('24.7206.0000')
						--where a.ItemNumber in ('03.986.000')
						-- where a.ItemNumber in ('24.057.165s')   -- cannot find '24.057.165s' in ML345 file hence later table join will yield Null Value causing potential issue in coding - 29/1/18
						group by a.ItemNumber
						)					
			,fc_Vol as  
				( select fct.DataType1,fct.ItemNumber,sum(isnull(fct.value,0)) as ItemLvlFCVol_1To24,count(isnull(fct.Date,0)) Count_FC_Period   ---TTL_FCMths	
					from JDE_DB_Alan.FCPRO_Fcst fct					-- 22/1/2018 did not have  condition before --> where fct.DataType1 like ('%Adj_FC%')	
					  where fct.DataType1 like ('%Adj_FC%')			-- 26/2/2018
							--and fct.Date between '2018-05-01' and '2018-10-01'			-- For Signature New Product Post Launch Analysis --- 5/6/2018
							  and fct.Date between @Start and @End
					group by fct.DataType1,fct.ItemNumber)	
		
			,fcVol as (	select fc_Vol.ItemNumber
							,fc_Vol.DataType1							
							,fc_Vol.ItemLvlFCVol_1To24							
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
					--select * from fcVol where fcvol.ItemNumber = '03.986.000'
					--where fcVol.ItemLvlFCVol_24 is null		-- where fc.ItemNumber = '18.615.024' --- fc about 10125 record

				   --- Item Level ----
			,comb_Vol as (select fc_Vol.ItemNumber,histy.SlsVol_TTL_12,histy.Sls_Freq								
									,fc_Vol.ItemLvlFCVol_1To24
									,fc_Vol.Count_FC_Period
									,stk.SOHVol
									--,coalesce(stk.SOHVol/(nullif(fc_Vol.ItemLvlFCVol_1To24/24,0)),0) as SOHWksCover						--if divisor is 0	
									,coalesce(stk.SOHVol/(nullif(fc_Vol.ItemLvlFCVol_1To24/fc_Vol.Count_FC_Period,0)),0) as SOHWksCover			--if divisor is 0 And FC month count varies --- 19/7/2018					 
							from fc_Vol left join histy on fc_Vol.ItemNumber = histy.ItemNumber_
										left join stk on stk.ItemNumber = histy.ItemNumber_
							)
			-- select * from comb_vol  where comb_Vol.SOHWksCover is null
			-- where comb_vol.ItemNumber = ('03.986.000')

			,combVol as ( select comb_Vol.*,px.StandardCost as Cost,px.WholeSalePrice as Price
							from comb_Vol left join JDE_DB_Alan.Px_AWF_HD_MT_FCPro_upload px on comb_Vol.ItemNumber = px.ItemNumber
							)

			,pareto as ( select p.ItemNumber,p.rnk,p.DataType1,p.Pareto from JDE_DB_Alan.FCPRO_Fcst_Pareto p where p.DataType1 like ('%Adj_FC%')			--26/2/2018
							)

			,comb_Amt as ( select combVol.*,Pareto.Pareto,pareto.rnk,ss.SS_
								,combVol.SlsVol_ttl_12*combVol.price as SlsAmt_12
								,combVol.ItemLvlFCVol_1To24*combVol.price as FCAmt_1To24
								,combVol.SOHVol*combVol.cost as SOHAmt										 
								from combVol left join pareto on combVol.ItemNumber = pareto.ItemNumber
												left join JDE_DB_Alan.FCPRO_SafetyStock ss on combVol.ItemNumber = ss.ItemNumber
						)
			 --select * from comb_Amt where comb_Amt.SlsAmt_12 is null or comb_Amt.FCAmt_24 is null or SOHAmt  is null

			,fl_ as ( select * 
								,sum(comb_Amt.SlsVol_TTL_12) over() as SlsVol_Grd
								,sum(comb_Amt.ItemLvlFCVol_1To24) over() as FCVol_Grd
								,sum(comb_Amt.SOHVol) over() as SOHVol_Grd
								,sum(comb_Amt.SlsAmt_12) over() as SlsAmt_Grd
								,sum(comb_Amt.FCAmt_1To24) over() as FCAmt_Grd
								,sum(comb_Amt.SOHAmt) over() as SOHAmt_Grd
							from comb_Amt)

			--- Get Supplier name ---
			,_mas as ( select a.ItemNumber
						,a.PrimarySupplier
						,case a.PlannerNumber when '20072' then 'Salman Saeed'
							when '20004' then 'Margaret Dost'	
							when '20005' then 'Imelda Chan'
							when '20071' then 'Domenic Cellucci'
							else 'Unknown'
						end as Owner_
						,a.Description
						,a.LeadtimeLevel as LeadTime
						,a.UOM
						,a.StockingType
						,row_number() over(partition by a.itemnumber order by a.itemnumber) as rn 
					 from JDE_DB_Alan.Master_ML345 a)
			,mas as ( select * 
					from _mas where rn =1 )

			,_fl as ( select fl_.*,m.PrimarySupplier,m.Owner_,m.Description,m.LeadTime,m.UOM,m.StockingType from fl_ left join mas m on fl_.ItemNumber = m.ItemNumber) 


			select * from _fl
			  where 
				--where fl_.ItemNumber like (@ItemNumber)
				-- where fl_.ItemNumber like ('%85053100%')	
				-- where fl_.ItemNumber in ('7495500001')	
			  -- where fl_.ItemNumber in (2974000000'	
				-- where fl_.ItemNumber in ('24.057.165s')					-- cannot find '24.057.165s' in ML345 file hence later table join will yield Null Value causing potential issue in coding - 29/1/18
		  
				-- m.PrimarySupplier in ( select data from JDE_DB_Alan.dbo.Split(@Supplier_id,','))
					_fl.ItemNumber in ( select splitdata from JDE_DB_Alan.dbo.fnSplitString(@Item_id,','))
			   --order by fl_.SlsAmt_12 desc
			   --  order by fl_.rnk
			    order by 			 
							case when @OrderByClause ='rnk' then _fl.rnk end,
							case when @OrderByClause ='SlsAmt_12' then _fl.SlsAmt_12 end desc,
							case when @OrderByClause ='SOHAmt' then _fl.SOHAmt end desc						 


	END


END