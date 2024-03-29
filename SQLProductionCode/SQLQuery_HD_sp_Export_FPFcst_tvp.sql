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
/****** Object:  StoredProcedure [JDE_DB_Alan].[sp_Exp_FPFcst_tvp]    Script Date: 26/02/2018 1:09:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [JDE_DB_Alan].[sp_Exp_FPFcst_tvp]
		( @tvpItem tvpItemList  READONLY, 
		  @tvpSupplier tvpSupplierList readonly)
AS
BEGIN

	;with cte as (
		select f.ItemNumber,convert(varchar(6),f.Date,112) as Period_YM,f.Value,'Adj_FC' as Typ_
		 from JDE_DB_Alan.FCPRO_Fcst f 
		   where f.DataType1 in ('Adj_FC')				--- 26/2/2018
		 --where s.ItemNumber in (select ids from @ItemIDs)
		 --where f.ItemNumber in ('40.033.131')
		union all
		select s.ItemNumber,convert(varchar(6),convert(datetime,concat(s.CYM,'01')),112) Period_YM,s.SalesQty,'Sales' as Typ_
		from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload s 
		--where s.ItemNumber in (select ids from @ItemIDs)
		--where s.ItemNumber in ('40.033.131')
	  ) ,
	   comb as ( select cte.ItemNumber,cte.Typ_,cte.Period_YM,cte.Value,m.StandardCost,p.Pareto,m.UOM,m.PrimarySupplier 
				from cte left join JDE_DB_Alan.Master_ML345 m on cte.ItemNumber = m.ItemNumber
					 left join JDE_DB_Alan.FCPRO_Fcst_Pareto p on cte.Itemnumber = p.ItemNumber
			   where cte.ItemNumber in ( select SKU from @tvpItem)
			      and m.PrimarySupplier in ( select SupplierNum from @tvpSupplier)
			       
		)

	select comb.ItemNumber,'HD' as BranchPlant,comb.UOM,'BF' as ForcastType
			,comb.Period_YM,convert(date,dateadd(d,-1,dateadd(mm,1,convert(datetime,comb.Period_YM+'01',103))),103) as Period_YMD,comb.Value as ForecastQty,0 as ForecastAmt,0 as CustomerNumber,'N' as BypassForcing,comb.Pareto from comb
	--where comb.Typ_ in ('Forecast')
	  where comb.Typ_ in ('Adj_FC')				--- 26/2/2018
	order by Pareto asc,comb.ItemNumber,comb.Period_YM

END