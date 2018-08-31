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
/****** Object:  StoredProcedure [JDE_DB_Alan].[sp_Exp_FPFcst_Jde]    Script Date: 26/02/2018 1:05:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [JDE_DB_Alan].[sp_Exp_FPFcst_Jde]  
	
	--- Note for this Store Procedure You can only pass 1 ItemNumber, or 1 SupplierNumber one time , cannot do mulitple value, if it is required, use more Versatile version of SQL Code in Master COde file  14/128/2017
      @ItemNumber varchar(3500)=null,   
	  @SupplierNumber varchar(100)=null    
	--@ShortItemNumber varchar(100) = null,
	--@CenturyYearMonth int = null
AS

BEGIN   
  
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	--set  @OrderByClause = 'rnk'	


	--- if  donot specify details, Export ALL FC from FC PRo ---
	IF @ItemNumber is NULL and @SupplierNumber is null
    BEGIN
			with cte as 
			   (
				select f.ItemNumber,convert(varchar(6),f.Date,112) as Period_YM,f.Value,'Adj_FC' as Typ_
				from JDE_DB_Alan.FCPRO_Fcst f 
				 --where s.ItemNumber in (select ids from @ItemIDs)
				 --where f.ItemNumber in ('40.033.131')
				   where f.DataType1 in ('Adj_FC')				--- 26/2/2018
				union all
				 select s.ItemNumber,convert(varchar(6),convert(datetime,concat(s.CYM,'01')),112) Period_YM,s.SalesQty,'Sales' as Typ_
				 from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload s 
				--where s.ItemNumber in (select ids from @ItemIDs)
				--where s.ItemNumber in ('40.033.131')
			  ) ,

			 comb as ( select cte.ItemNumber,cte.Typ_,cte.Period_YM,cte.Value,m.StandardCost,p.Pareto,m.UOM 
							  ,m.PrimarySupplier,m.PlannerNumber
						 	,case m.PlannerNumber 
							when '20072' then 'Salmon Saeed'
							when '20004' then 'Margaret Dost'	
							when '20005' then 'Imelda Chan'
							when '20071' then 'Domenic Cellucci'
							else 'Unknown'
							end as Owner_
						from cte left join JDE_DB_Alan.Master_ML345 m on cte.ItemNumber = m.ItemNumber
					 left join JDE_DB_Alan.FCPRO_Fcst_Pareto p on cte.Itemnumber = p.ItemNumber
					-- where m.PrimarySupplier in ('20037')
					-- where cte.ItemNumber in (@ItemNumber)
				)

			select comb.ItemNumber,'HD' as BranchPlant,comb.UOM,'BF' as ForcastType
					,comb.Period_YM
					-- Get Last day of the Previous month,and format to dd/mm/yyyy for JDE format
					,convert(varchar(10),convert(date,dateadd(d,-1,dateadd(mm,1,convert(datetime,comb.Period_YM+'01',103))),103),103) as Period_YMD
					,comb.Value as ForecastQty,0 as ForecastAmt,0 as CustomerNumber,'N' as BypassForcing,comb.Pareto 
					,comb.PlannerNumber,comb.primarysupplier,comb.Owner_
					from comb
			where comb.Typ_ in ('Adj_FC')
			order by Pareto asc,comb.ItemNumber,comb.Period_YM
    END

	-- Check if SKU number is Provided to query the data 
    ELSE IF @SupplierNumber IS NULL
    BEGIN
			with cte as 
			 (
				select f.ItemNumber,convert(varchar(6),f.Date,112) as Period_YM,f.Value,'Adj_FC' as Typ_
				from JDE_DB_Alan.FCPRO_Fcst f 
				 --where s.ItemNumber in (select ids from @ItemIDs)
				 --where f.ItemNumber in ('40.033.131')
				   where f.DataType1 in ('Adj_FC')				--- 26/2/2018
				union all
				 select s.ItemNumber,convert(varchar(6),convert(datetime,concat(s.CYM,'01')),112) Period_YM,s.SalesQty,'Sales' as Typ_
				 from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload s 
				--where s.ItemNumber in (select ids from @ItemIDs)
				--where s.ItemNumber in ('40.033.131')
			  ) ,

			 comb as 
			 ( select cte.ItemNumber,cte.Typ_,cte.Period_YM,cte.Value,m.StandardCost,p.Pareto,m.UOM 
			              ,m.PrimarySupplier,m.PlannerNumber
						 	,case m.PlannerNumber 
							when '20072' then 'Salmon Saeed'
							when '20004' then 'Margaret Dost'	
							when '20005' then 'Imelda Chan'
							when '20071' then 'Domenic Cellucci'
							else 'Unknown'
							end as Owner_
				from cte left join JDE_DB_Alan.Master_ML345 m on cte.ItemNumber = m.ItemNumber
					 left join JDE_DB_Alan.FCPRO_Fcst_Pareto p on cte.Itemnumber = p.ItemNumber
					 where cte.ItemNumber in (@ItemNumber)
				)

			select comb.ItemNumber,'HD' as BranchPlant,comb.UOM,'BF' as ForcastType
					,comb.Period_YM
					-- Get Last day of the Previous month,and format to dd/mm/yyyy for JDE format
					,convert(date,dateadd(d,-1,dateadd(mm,1,convert(datetime,comb.Period_YM+'01',103))),103) as Period_YMD
					,comb.Value as ForecastQty,0 as ForecastAmt,0 as CustomerNumber,'N' as BypassForcing,comb.Pareto 
					,comb.PlannerNumber,comb.primarysupplier,comb.Owner_
					from comb
			where comb.Typ_ in ('Adj_FC')
			order by Pareto asc,comb.ItemNumber,comb.Period_YM
    END

    -- Else check if it has a @SupplierNumber
	-- Check if you want to use Supplier to query the data 
    ELSE IF @ItemNumber IS NULL 
    BEGIN

			with cte as 
			    (
				select f.ItemNumber,convert(varchar(6),f.Date,112) as Period_YM,f.Value,'Adj_FC' as Typ_
				from JDE_DB_Alan.FCPRO_Fcst f 
				 --where s.ItemNumber in (select ids from @ItemIDs)
				 --where f.ItemNumber in ('40.033.131')
				   where f.DataType1 in ('Adj_FC')				--- 26/2/2018
				union all
				 select s.ItemNumber,convert(varchar(6),convert(datetime,concat(s.CYM,'01')),112) Period_YM,s.SalesQty,'Sales' as Typ_
				 from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload s 
				--where s.ItemNumber in (select ids from @ItemIDs)
				--where s.ItemNumber in ('40.033.131')
			  ) ,

			 comb as ( select cte.ItemNumber,cte.Typ_,cte.Period_YM,cte.Value,m.StandardCost,p.Pareto,m.UOM 
			                ,m.PrimarySupplier,m.PlannerNumber
						 	,case m.PlannerNumber 
							when '20072' then 'Salmon Saeed'
							when '20004' then 'Margaret Dost'	
							when '20005' then 'Imelda Chan'
							when '20071' then 'Domenic Cellucci'
							else 'Unknown'
							end as Owner_
						from cte left join JDE_DB_Alan.Master_ML345 m on cte.ItemNumber = m.ItemNumber
						 left join JDE_DB_Alan.FCPRO_Fcst_Pareto p on cte.Itemnumber = p.ItemNumber
						where m.PrimarySupplier in (@SupplierNumber)
				)

			select comb.ItemNumber,'HD' as BranchPlant,comb.UOM,'BF' as ForcastType
					,comb.Period_YM
					-- Get Last day of the Previous month,and format to dd/mm/yyyy for JDE format
					,convert(date,dateadd(d,-1,dateadd(mm,1,convert(datetime,comb.Period_YM+'01',103))),103) as Period_YMD
					,comb.Value as ForecastQty,0 as ForecastAmt,0 as CustomerNumber,'N' as BypassForcing,comb.Pareto 
					,comb.PlannerNumber,comb.primarysupplier,comb.Owner_
					from comb
			where comb.Typ_ in ('Adj_FC')
			order by Pareto asc,comb.ItemNumber,comb.Period_YM       
    END
    
END
