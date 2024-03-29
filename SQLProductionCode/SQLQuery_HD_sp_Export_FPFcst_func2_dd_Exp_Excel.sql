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
/****** Object:  StoredProcedure [JDE_DB_Alan].[sp_Exp_FPFcst_func2Exl]    Script Date: 16/03/2018 4:23:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [JDE_DB_Alan].[sp_Exp_FPFcst_func2Exl]
		( @Supplier_id varchar(8000) = null
		  ,@Item_id varchar(8000) = null
		  ,@DataType varchar (1000) = null
		  --,@FcReportDate datetime
		  )
AS
BEGIN
   
		  IF @Supplier_id is NULL and @Item_id is null
	
				with cte as (
					select f.ItemNumber,convert(varchar(6),f.Date,112) as Period_YM,f.Value,'Adj_FC' as Typ_,f.ReportDate
					 --from JDE_DB_Alan.FCPRO_Fcst f 
					   from JDE_DB_Alan.FCPRO_Fcst_History f				--- 16/3/2018
					 --where s.ItemNumber in (select ids from @ItemIDs)
					 --where f.ItemNumber in ('40.033.131')
					   where f.DataType1 in ('Adj_FC')				--- 26/2/2018
					         --and f.ReportDate < @FcReportDate		-- 16/3/2018
					union all
					select s.ItemNumber,convert(varchar(6),convert(datetime,concat(s.CYM,'01')),112) Period_YM,s.SalesQty,'Sales' as Typ_,s.ReportDate
					from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload s --where s.ItemNumber in ('27.176.320')
					--where s.ItemNumber in (select ids from @ItemIDs)
					--where s.ItemNumber in ('40.033.131')
					 -- where s.ItemNumber in ('27.253.000')
				 ) 
			,comb_ as ( select cte.ItemNumber,cte.Typ_,cte.Period_YM,cte.Value,m.StandardCost,p.Pareto,m.UOM,m.PrimarySupplier 					
								,m.PlannerNumber
								,m.SellingGroup,m.FamilyGroup,m.Family,Description,cte.ReportDate
								,case m.PlannerNumber when '20072' then 'Salman Saeed'
													 when '20004' then 'Margaret Dost'	
													 when '20005' then 'Imelda Chan'
													 when '20071' then 'Domenic Cellucci'
													 else 'Unknown'
									end as Owner_
							from cte left join JDE_DB_Alan.Master_ML345 m on cte.ItemNumber = m.ItemNumber
								 left join JDE_DB_Alan.FCPRO_Fcst_Pareto p on cte.Itemnumber = p.ItemNumber
						 -- where m.PrimarySupplier in ( select data from JDE_DB_Alan.dbo.Split(@Supplier_id,','))
								-- and/or cte.ItemNumber in ( select data from JDE_DB_Alan.dbo.Split(@Item_id,','))
							)
			,staging as 
						(select comb_.*
								,c.LongDescription as SellingGroup_
								,d.LongDescription as FamilyGroup_
								,e.LongDescription as Family_0
								--,tbl.Family as Family_1
								--,f.StandardCost,f.WholeSalePrice
						from comb_ left join JDE_DB_Alan.MasterSellingGroup c on comb_.SellingGroup = c.Code
								 left join JDE_DB_Alan.MasterFamilyGroup d on comb_.FamilyGroup = d.Code
								 left join JDE_DB_Alan.MasterFamily e on comb_.Family = e.Code
						 )
              -- select * from staging s where s.ItemNumber in ('27.253.000')

			,comb as ( select * from staging )

				select comb.ItemNumber,'HD' as BranchPlant,comb.UOM,'BF' as ForcastType
					,comb.Period_YM
					,convert(date,dateadd(mm,0,convert(datetime,comb.Period_YM+'01',103))) as Period_YMD_0
					--,convert(date,dateadd(d,-1,dateadd(mm,1,convert(datetime,comb.Period_YM+'01',103))),103) as Period_YMD_1		-- to get 'Jde FC Date' Format ie 31/Month/Year
					--,convert(date,dateadd(d,-1,dateadd(mm,0,convert(datetime,comb.Period_YM+'01',103))),103) as Period_YMD_2 -- to get 'Jde FC Date' Format ie 31/Month/Year,however when FC loaded into Jde, Jde will automatically add 1 day and push FC to Following month, ie 31/1/2018 FC will be push into Month slot of 1/Feb/2018, so here you need to change date again
					--,convert(varchar(10),convert(date,dateadd(d,-1,dateadd(mm,0,convert(datetime,comb.Period_YM+'01',105))),103),103) Period_YMD_3
					,comb.Typ_
					,comb.Value as Qty
					,0 as Amt
					,0 as CustomerNumber,'N' as BypassForcing,comb.Pareto 			
					,comb.PlannerNumber,comb.primarysupplier,comb.Owner_
					,comb.Family_0
					,comb.Description
					,comb.ReportDate
					from comb

				--where comb.Typ_ in ('Forecast')
				 where comb.Typ_ in (select splitdata from JDE_DB_Alan.dbo.fnSplitString(@DataType,',')) 
				order by Pareto asc,comb.ItemNumber,comb.Typ_,comb.Period_YM
				option (maxrecursion 0)

		
		ELSE IF @Item_id IS NULL
		BEGIN
				with cte as (
					select f.ItemNumber,convert(varchar(6),f.Date,112) as Period_YM,f.Value,'Adj_FC' as Typ_,f.ReportDate
					--from JDE_DB_Alan.FCPRO_Fcst f 
					   from JDE_DB_Alan.FCPRO_Fcst_History f
					 --where s.ItemNumber in (select ids from @ItemIDs)
					 --where f.ItemNumber in ('40.033.131')
					   where f.DataType1 in ('Adj_FC')				--- 26/2/2018
					      --   and f.ReportDate < @FcReportDate		-- 16/3/2018
					union all
					select s.ItemNumber,convert(varchar(6),convert(datetime,concat(s.CYM,'01')),112) Period_YM,s.SalesQty,'Sales' as Typ_,s.ReportDate
					from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload s 
					--where s.ItemNumber in (select ids from @ItemIDs)
					--where s.ItemNumber in ('40.033.131')
				 ) 
			  ,comb_ as ( select cte.ItemNumber,cte.Typ_,cte.Period_YM,cte.Value,m.StandardCost,p.Pareto,m.UOM,m.PrimarySupplier 					
								,m.PlannerNumber
								,m.SellingGroup,m.FamilyGroup,m.Family,m.Description,cte.ReportDate
								,case m.PlannerNumber when '20072' then 'Salmon Saeed'
													 when '20004' then 'Margaret Dost'	
													 when '20005' then 'Imelda Chan'
													 when '20071' then 'Domenic Cellucci'
													 else 'Unknown'
									end as Owner_
							from cte left join JDE_DB_Alan.Master_ML345 m on cte.ItemNumber = m.ItemNumber
								 left join JDE_DB_Alan.FCPRO_Fcst_Pareto p on cte.Itemnumber = p.ItemNumber
						 where m.PrimarySupplier in ( select splitdata from JDE_DB_Alan.dbo.fnSplitString(@Supplier_id,','))
								-- and/or cte.ItemNumber in ( select data from JDE_DB_Alan.dbo.Split(@Item_id,','))
						)

			,staging as 
						(select comb_.*
								,c.LongDescription as SellingGroup_
								,d.LongDescription as FamilyGroup_
								,e.LongDescription as Family_0
								--,tbl.Family as Family_1
								--,f.StandardCost,f.WholeSalePrice
						from comb_ left join JDE_DB_Alan.MasterSellingGroup c on comb_.SellingGroup = c.Code
								 left join JDE_DB_Alan.MasterFamilyGroup d on comb_.FamilyGroup = d.Code
								 left join JDE_DB_Alan.MasterFamily e on comb_.Family = e.Code
						 )

			,comb as ( select * from staging )

				select comb.ItemNumber,'HD' as BranchPlant,comb.UOM,'BF' as ForcastType
					,comb.Period_YM
					,convert(date,dateadd(mm,0,convert(datetime,comb.Period_YM+'01',103))) as Period_YMD_0
					--,convert(date,dateadd(d,-1,dateadd(mm,1,convert(datetime,comb.Period_YM+'01',103))),103) as Period_YMD_1		-- to get 'Jde FC Date' Format ie 31/Month/Year
					--,convert(date,dateadd(d,-1,dateadd(mm,0,convert(datetime,comb.Period_YM+'01',103))),103) as Period_YMD_2 -- to get 'Jde FC Date' Format ie 31/Month/Year,however when FC loaded into Jde, Jde will automatically add 1 day and push FC to Following month, ie 31/1/2018 FC will be push into Month slot of 1/Feb/2018, so here you need to change date again
					--,convert(varchar(10),convert(date,dateadd(d,-1,dateadd(mm,0,convert(datetime,comb.Period_YM+'01',105))),103),103) Period_YMD_3
					,comb.Typ_
					,comb.Value as Qty
					,0 as Amt
					,0 as CustomerNumber,'N' as BypassForcing,comb.Pareto 			
					,comb.PlannerNumber,comb.primarysupplier,comb.Owner_
					,comb.Family_0
					,comb.Description
					,comb.ReportDate
					from comb

				 --where comb.Typ_ in ('Forecast')
				 where comb.Typ_ in (select splitdata from JDE_DB_Alan.dbo.fnSplitString(@DataType,',')) 
				 order by Pareto asc,comb.ItemNumber,comb.Typ_,comb.Period_YM
				 option (maxrecursion 0)
		END

		ELSE IF @Supplier_id IS NULL
		BEGIN
				with cte as (
					select f.ItemNumber,convert(varchar(6),f.Date,112) as Period_YM,f.Value,'Adj_FC' as Typ_,f.ReportDate
					 --from JDE_DB_Alan.FCPRO_Fcst f 
					   from JDE_DB_Alan.FCPRO_Fcst_History f
					 --where s.ItemNumber in (select ids from @ItemIDs)
					 --where f.ItemNumber in ('40.033.131')
					   where f.DataType1 in ('Adj_FC')				--- 26/2/2018
							-- and f.ReportDate < @FcReportDate		-- 16/3/2018
					union all
					select s.ItemNumber,convert(varchar(6),convert(datetime,concat(s.CYM,'01')),112) Period_YM,s.SalesQty,'Sales' as Typ_,s.ReportDate
					from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload s 
					--where s.ItemNumber in (select ids from @ItemIDs)
					--where s.ItemNumber in ('40.033.131')
				 ) 
			  ,comb_ as ( select cte.ItemNumber,cte.Typ_,cte.Period_YM,cte.Value,m.StandardCost,p.Pareto,m.UOM,m.PrimarySupplier 					
								,m.PlannerNumber
								,m.SellingGroup,m.FamilyGroup,m.Family,m.Description,cte.ReportDate
								,case m.PlannerNumber when '20072' then 'Salmon Saeed'
													 when '20004' then 'Margaret Dost'	
													 when '20005' then 'Imelda Chan'
													 when '20071' then 'Domenic Cellucci'
													 else 'Unknown'
									end as Owner_
							from cte left join JDE_DB_Alan.Master_ML345 m on cte.ItemNumber = m.ItemNumber
								 left join JDE_DB_Alan.FCPRO_Fcst_Pareto p on cte.Itemnumber = p.ItemNumber
						 where 
								--m.PrimarySupplier in ( select data from JDE_DB_Alan.dbo.Split(@Supplier_id,','))
								 cte.ItemNumber in ( select splitdata from JDE_DB_Alan.dbo.fnSplitString(@Item_id,','))
					)

			,staging as 
						(select comb_.*
								,c.LongDescription as SellingGroup_
								,d.LongDescription as FamilyGroup_
								,e.LongDescription as Family_0
								--,tbl.Family as Family_1
								--,f.StandardCost,f.WholeSalePrice
						from comb_ left join JDE_DB_Alan.MasterSellingGroup c on comb_.SellingGroup = c.Code
								 left join JDE_DB_Alan.MasterFamilyGroup d on comb_.FamilyGroup = d.Code
								 left join JDE_DB_Alan.MasterFamily e on comb_.Family = e.Code
						 )

			,comb as ( select * from staging )

				select comb.ItemNumber,'HD' as BranchPlant,comb.UOM,'BF' as ForcastType
					,comb.Period_YM
					,convert(date,dateadd(mm,0,convert(datetime,comb.Period_YM+'01',103))) as Period_YMD_0
					--,convert(date,dateadd(d,-1,dateadd(mm,1,convert(datetime,comb.Period_YM+'01',103))),103) as Period_YMD_1		-- to get 'Jde FC Date' Format ie 31/Month/Year
					--,convert(date,dateadd(d,-1,dateadd(mm,0,convert(datetime,comb.Period_YM+'01',103))),103) as Period_YMD_2 -- to get 'Jde FC Date' Format ie 31/Month/Year,however when FC loaded into Jde, Jde will automatically add 1 day and push FC to Following month, ie 31/1/2018 FC will be push into Month slot of 1/Feb/2018, so here you need to change date again
					--,convert(varchar(10),convert(date,dateadd(d,-1,dateadd(mm,0,convert(datetime,comb.Period_YM+'01',105))),103),103) Period_YMD_3
					,comb.Typ_
					,comb.Value as Qty
					,0 as Amt
					,0 as CustomerNumber,'N' as BypassForcing,comb.Pareto 			
					,comb.PlannerNumber,comb.primarysupplier,comb.Owner_
					,comb.Family_0
					,comb.Description
					,comb.ReportDate
					from comb

				--where comb.Typ_ in ('Forecast')
				where comb.Typ_ in (select splitdata from JDE_DB_Alan.dbo.fnSplitString(@DataType,',')) 
				order by Pareto asc,comb.ItemNumber,comb.Typ_,comb.Period_YM
				option (maxrecursion 0)
		END

		ELSE IF @Supplier_id IS not NULL and @Item_id IS not NULL and @DataType IS not NULL 
		BEGIN
				with cte as (
					select f.ItemNumber,convert(varchar(6),f.Date,112) as Period_YM,f.Value,'Adj_FC' as Typ_,f.ReportDate
					  --from JDE_DB_Alan.FCPRO_Fcst f 
					   from JDE_DB_Alan.FCPRO_Fcst_History f
					 --where s.ItemNumber in (select ids from @ItemIDs)
					 --where f.ItemNumber in ('40.033.131')
					   where f.DataType1 in ('Adj_FC')				--- 26/2/2018
							--and f.ReportDate < @FcReportDate		-- 16/3/2018
					union all
					select s.ItemNumber,convert(varchar(6),convert(datetime,concat(s.CYM,'01')),112) Period_YM,s.SalesQty,'Sales' as Typ_,s.ReportDate
					from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload s 
					--where s.ItemNumber in (select ids from @ItemIDs)
					--where s.ItemNumber in ('40.033.131')
				 ) 
			,comb_ as ( select cte.ItemNumber,cte.Typ_,cte.Period_YM,cte.Value,m.StandardCost,p.Pareto,m.UOM,m.PrimarySupplier 					
								,m.PlannerNumber
								,m.SellingGroup,m.FamilyGroup,m.Family,m.Description,cte.ReportDate
								,case m.PlannerNumber when '20072' then 'Salmon Saeed'
													 when '20004' then 'Margaret Dost'	
													 when '20005' then 'Imelda Chan'
													 when '20071' then 'Domenic Cellucci'
													 else 'Unknown'
									end as Owner_
							from cte left join JDE_DB_Alan.Master_ML345 m on cte.ItemNumber = m.ItemNumber
								 left join JDE_DB_Alan.FCPRO_Fcst_Pareto p on cte.Itemnumber = p.ItemNumber
						 where 
								m.PrimarySupplier in ( select splitdata from JDE_DB_Alan.dbo.fnSplitString(@Supplier_id,','))
								and cte.ItemNumber in ( select splitdata from JDE_DB_Alan.dbo.fnSplitString(@Item_id,','))
					)

			,staging as 
						(select comb_.*
								,c.LongDescription as SellingGroup_
								,d.LongDescription as FamilyGroup_
								,e.LongDescription as Family_0
								--,tbl.Family as Family_1
								--,f.StandardCost,f.WholeSalePrice
						from comb_ left join JDE_DB_Alan.MasterSellingGroup c on comb_.SellingGroup = c.Code
								 left join JDE_DB_Alan.MasterFamilyGroup d on comb_.FamilyGroup = d.Code
								 left join JDE_DB_Alan.MasterFamily e on comb_.Family = e.Code
						 )

		  ,comb as ( select * from staging )

				select comb.ItemNumber,'HD' as BranchPlant,comb.UOM,'BF' as ForcastType
					,comb.Period_YM
					,convert(date,dateadd(mm,0,convert(datetime,comb.Period_YM+'01',103))) as Period_YMD_0
					--,convert(date,dateadd(d,-1,dateadd(mm,1,convert(datetime,comb.Period_YM+'01',103))),103) as Period_YMD_1		-- to get 'Jde FC Date' Format ie 31/Month/Year
					--,convert(date,dateadd(d,-1,dateadd(mm,0,convert(datetime,comb.Period_YM+'01',103))),103) as Period_YMD_2 -- to get 'Jde FC Date' Format ie 31/Month/Year,however when FC loaded into Jde, Jde will automatically add 1 day and push FC to Following month, ie 31/1/2018 FC will be push into Month slot of 1/Feb/2018, so here you need to change date again
					--,convert(varchar(10),convert(date,dateadd(d,-1,dateadd(mm,0,convert(datetime,comb.Period_YM+'01',105))),103),103) Period_YMD_3
					,comb.Typ_
					,comb.Value as Qty
					,0 as Amt
					,0 as CustomerNumber,'N' as BypassForcing,comb.Pareto 			
					,comb.PlannerNumber,comb.primarysupplier,comb.Owner_
					,comb.Family_0
					,comb.Description
					,comb.ReportDate
					from comb

				--where comb.Typ_ in ('Forecast')
				where comb.Typ_ in (select splitdata from JDE_DB_Alan.dbo.fnSplitString(@DataType,',')) 
				order by Pareto asc,comb.ItemNumber,comb.Typ_,comb.Period_YM
				option (maxrecursion 0)
		END

END
