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
/****** Object:  StoredProcedure [JDE_DB_Alan].[sp_Exp_FPFcst_func2Jde]    Script Date: 17/05/2021 9:44:33 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [JDE_DB_Alan].[sp_Exp_FPFcst_func2Jde]
		( @Supplier_id varchar(8000) = null
		  ,@Item_id varchar(8000) = null
		  ,@DataType varchar (100) = null
		  ,@IncludeRowNum varchar(1) = null

		  )
AS
BEGIN
        
		
		IF @Supplier_id is NULL and @Item_id is null and @DataType is not null and @IncludeRowNum = 'Y'			--- Yes please include row number for data dump into Excel 17/5/2021
		 -- Add 14/5/2021, for loadng data into Excel and debug purpose ---

		   	with cte as (
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
				 ) 
				 ,comb_ as ( select cte.ItemNumber,cte.Typ_,cte.Period_YM,cte.Value,m.StandardCost,m.WholeSalePrice,p.Pareto,m.UOM,m.PrimarySupplier 					
								,m.PlannerNumber
								,m.SellingGroup,m.FamilyGroup,m.Family
								,case m.PlannerNumber 
											when '20072' then 'Salman Saeed'
											when '20004' then 'Margaret Dost'	
											when '20005' then 'Imelda Chan'
											when '20071' then 'Rosie Ashpole'
											when '20003' then 'Lee Roise'
											when '30036' then 'Violet Glodoveza'
											when '30039' then 'Ben'
											when '29917' then 'Metals Planner'
											when '20065' then 'AWF RollForming'
											when '2519718' then 'CutLength Planner'																					  
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

			  ,comb as ( select * from staging )
			  --select * from comb			 

		    ,fl as ( select comb.ItemNumber,'HD' as BranchPlant,comb.UOM,'BF' as ForcastType
					,comb.Period_YM
					,convert(date,dateadd(d,-1,dateadd(mm,0,convert(datetime,comb.Period_YM+'01',103))),103) as Period_YMD_1		-- to get 'Jde FC Date' Format ie 31/Month/Year,however when FC loaded into Jde, Jde will automatically add 1 day and push FC to Following month, ie 31/1/2018 FC will be push into Month slot of 1/Feb/2018, so here you need to change date again
					,convert(date,dateadd(d,-1,dateadd(mm,1,convert(datetime,comb.Period_YM+'01',103))),103) as Period_YMD_2        -- Current month + 1 month minus 1 day to get last day of same month , to get 'Jde FC Date' Format ie 31/Month/Year, get last day of last month 
					,convert(varchar(10),convert(date,dateadd(d,-1,dateadd(mm,1,convert(datetime,comb.Period_YM+'01',105))),103),103) Period_YMD_3 
					,comb.Typ_
					,comb.Value as Qty
					,comb.Value * comb.WholeSalePrice as Amt_Actual
					,0 as Amt
					,0 as CustomerNumber,'N' as BypassForcing,comb.Pareto 			
					,comb.PlannerNumber,comb.primarysupplier,comb.Owner_
					,comb.Family_0
					from comb

				where comb.Typ_ in ('Adj_FC')
				-- where comb.Typ_ in (select splitdata from JDE_DB_Alan.dbo.fnSplitString(@DataType,',')) 
			 --	order by Pareto asc,comb.ItemNumber,comb.Typ_,comb.Period_YM
			      )

              select row_number() over(order by ForcastType) as RecordNumer,					--- add 14/5/2021, for loadng data into Excel and debug purpose 
			         fl.ItemNumber,fl.BranchPlant,fl.UOM,fl.ForcastType
			        -- ,fl.Period_YM,fl.Period_YMD_1,fl.Period_YMD_2
					,fl.Period_YMD_3,fl.Qty,fl.Amt,fl.CustomerNumber,fl.BypassForcing
					--,fl.Amt_Actual,fl.Pareto
			  from fl
			  where fl.Typ_ in ('Adj_FC') and fl.ItemNumber not in ('misc.item.32000')	
			  order by Pareto asc,fl.ItemNumber,fl.Typ_,fl.Period_YM
			  option (maxrecursion 0)
		
	 Else  IF @Supplier_id is NULL and @Item_id is null and @DataType is not null and ( @IncludeRowNum = 'N' or @IncludeRowNum is null )	--- No, no Rownunmber just data dump into Text file then straight into Jde 17/5/2021
		   
		   begin

		   	with cte as (
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
				 ) 
				 ,comb_ as ( select cte.ItemNumber,cte.Typ_,cte.Period_YM,cte.Value,m.StandardCost,m.WholeSalePrice,p.Pareto,m.UOM,m.PrimarySupplier 					
								,m.PlannerNumber
								,m.SellingGroup,m.FamilyGroup,m.Family
								,case m.PlannerNumber 
											when '20072' then 'Salman Saeed'
											when '20004' then 'Margaret Dost'	
											when '20005' then 'Imelda Chan'
											when '20071' then 'Rosie Ashpole'
											when '20003' then 'Lee Roise'
											when '30036' then 'Violet Glodoveza'
											when '30039' then 'Ben'
											when '29917' then 'Metals Planner'
											when '20065' then 'AWF RollForming'
											when '2519718' then 'CutLength Planner'																					  
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

			  ,comb as ( select * from staging )
			  --select * from comb			 

		    ,fl as ( select comb.ItemNumber,'HD' as BranchPlant,comb.UOM,'BF' as ForcastType
					,comb.Period_YM
					,convert(date,dateadd(d,-1,dateadd(mm,0,convert(datetime,comb.Period_YM+'01',103))),103) as Period_YMD_1		-- to get 'Jde FC Date' Format ie 31/Month/Year,however when FC loaded into Jde, Jde will automatically add 1 day and push FC to Following month, ie 31/1/2018 FC will be push into Month slot of 1/Feb/2018, so here you need to change date again
					,convert(date,dateadd(d,-1,dateadd(mm,1,convert(datetime,comb.Period_YM+'01',103))),103) as Period_YMD_2        -- Current month + 1 month minus 1 day to get last day of same month , to get 'Jde FC Date' Format ie 31/Month/Year, get last day of last month 
					,convert(varchar(10),convert(date,dateadd(d,-1,dateadd(mm,1,convert(datetime,comb.Period_YM+'01',105))),103),103) Period_YMD_3 
					,comb.Typ_
					,comb.Value as Qty
					,comb.Value * comb.WholeSalePrice as Amt_Actual
					,0 as Amt
					,0 as CustomerNumber,'N' as BypassForcing,comb.Pareto 			
					,comb.PlannerNumber,comb.primarysupplier,comb.Owner_
					,comb.Family_0
					from comb

				where comb.Typ_ in ('Adj_FC')
				-- where comb.Typ_ in (select splitdata from JDE_DB_Alan.dbo.fnSplitString(@DataType,',')) 
			 --	order by Pareto asc,comb.ItemNumber,comb.Typ_,comb.Period_YM
			      )

              select fl.ItemNumber,fl.BranchPlant,fl.UOM,fl.ForcastType
			        -- ,fl.Period_YM,fl.Period_YMD_1,fl.Period_YMD_2
					,fl.Period_YMD_3,fl.Qty,fl.Amt,fl.CustomerNumber,fl.BypassForcing
					--,fl.Amt_Actual,fl.Pareto
			  from fl
			  where fl.Typ_ in ('Adj_FC') and fl.ItemNumber not in ('misc.item.32000')	
			  order by Pareto asc,fl.ItemNumber,fl.Typ_,fl.Period_YM
			  option (maxrecursion 0)  

         end
					--- if want to Use Item_id --- 
	  ELSE IF @Item_id is not null and @Supplier_id IS NULL and @DataType is not null and ( @IncludeRowNum = 'N'  or  @IncludeRowNum is null )   ---  No, no Rownunmber just data dump into Text file then straight into Jde 17/5/2021, but you provided Item id when query      
				BEGIN
					
					with cte as (
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
						 ) 
						 ,comb_ as ( select cte.ItemNumber,cte.Typ_,cte.Period_YM,cte.Value,m.StandardCost,m.WholeSalePrice,p.Pareto,m.UOM,m.PrimarySupplier 					
										,m.PlannerNumber
										,m.SellingGroup,m.FamilyGroup,m.Family
										,case m.PlannerNumber 
												when '20072' then 'Salman Saeed'
												when '20004' then 'Margaret Dost'	
												when '20005' then 'Imelda Chan'
												when '20071' then 'Rosie Ashpole'
												when '20003' then 'Lee Roise'
												when '30036' then 'Violet Glodoveza'
												when '30039' then 'Ben'
												when '29917' then 'Metals Planner'
												when '20065' then 'AWF RollForming'
												when '2519718' then 'CutLength Planner'																					  
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

					 ,fl as (	select comb.ItemNumber,'HD' as BranchPlant,comb.UOM,'BF' as ForcastType
							,comb.Period_YM
							,convert(date,dateadd(d,-1,dateadd(mm,0,convert(datetime,comb.Period_YM+'01',103))),103) as Period_YMD_1		-- to get 'Jde FC Date' Format ie 31/Month/Year,however when FC loaded into Jde, Jde will automatically add 1 day and push FC to Following month, ie 31/1/2018 FC will be push into Month slot of 1/Feb/2018, so here you need to change date again
							,convert(date,dateadd(d,-1,dateadd(mm,1,convert(datetime,comb.Period_YM+'01',103))),103) as Period_YMD_2        -- Current month + 1 month minus 1 day to get last day of same month , to get 'Jde FC Date' Format ie 31/Month/Year, get last day of last month 
							,convert(varchar(10),convert(date,dateadd(d,-1,dateadd(mm,1,convert(datetime,comb.Period_YM+'01',105))),103),103) Period_YMD_3 
							,comb.Typ_
							,comb.Value as Qty
							,comb.Value * comb.WholeSalePrice as Amt_Actual
							,0 as Amt
							,0 as CustomerNumber,'N' as BypassForcing,comb.Pareto 			
							,comb.PlannerNumber,comb.primarysupplier,comb.Owner_
							,comb.Family_0
							from comb

						--where comb.Typ_ in ('Forecast')
						where comb.Typ_ in (select splitdata from JDE_DB_Alan.dbo.fnSplitString(@DataType,',')) 
						--order by Pareto asc,comb.ItemNumber,comb.Typ_,comb.Period_YM

						)
				
					  select fl.ItemNumber,fl.BranchPlant,fl.UOM,fl.ForcastType
						--	,fl.Period_YM,fl.Period_YMD_1,fl.Period_YMD_2
							,fl.Period_YMD_3,fl.Qty,fl.Amt,fl.CustomerNumber,fl.BypassForcing
							--,fl.Amt_Actual,fl.Pareto
					  from fl
					  where fl.Typ_ in ('Adj_FC')
					  order by Pareto asc,fl.ItemNumber,fl.Typ_,fl.Period_YM
					  option (maxrecursion 0)

				END  
		
				--- if want to Use Supplier_id --- 
		ELSE IF @Supplier_id is not null and @Item_id IS NULL and @DataType is not null and ( @IncludeRowNum = 'N' or  @IncludeRowNum  is null )    ---  No, no Rownunmber just data dump into Text file then straight into Jde 17/5/2021, but you provided Vendor id when query      
		BEGIN
				with cte as (
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
				 ) 
				 ,comb_ as ( select cte.ItemNumber,cte.Typ_,cte.Period_YM,cte.Value,m.StandardCost,m.WholeSalePrice,p.Pareto,m.UOM,m.PrimarySupplier 					
								,m.PlannerNumber
								,m.SellingGroup,m.FamilyGroup,m.Family
								,case m.PlannerNumber 
												when '20072' then 'Salman Saeed'
												when '20004' then 'Margaret Dost'	
												when '20005' then 'Imelda Chan'
												when '20071' then 'Rosie Ashpole'
												when '20003' then 'Lee Roise'
												when '30036' then 'Violet Glodoveza'
												when '30039' then 'Ben'
												when '29917' then 'Metals Planner'
												when '20065' then 'AWF RollForming'
												when '2519718' then 'CutLength Planner'																					  
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

			,fl as (	select comb.ItemNumber,'HD' as BranchPlant,comb.UOM,'BF' as ForcastType
					,comb.Period_YM
					,convert(date,dateadd(d,-1,dateadd(mm,0,convert(datetime,comb.Period_YM+'01',103))),103) as Period_YMD_1		-- to get 'Jde FC Date' Format ie 31/Month/Year,however when FC loaded into Jde, Jde will automatically add 1 day and push FC to Following month, ie 31/1/2018 FC will be push into Month slot of 1/Feb/2018, so here you need to change date again
					,convert(date,dateadd(d,-1,dateadd(mm,1,convert(datetime,comb.Period_YM+'01',103))),103) as Period_YMD_2        -- Current month + 1 month minus 1 day to get last day of same month , to get 'Jde FC Date' Format ie 31/Month/Year, get last day of last month 
					,convert(varchar(10),convert(date,dateadd(d,-1,dateadd(mm,1,convert(datetime,comb.Period_YM+'01',105))),103),103) Period_YMD_3 
					,comb.Typ_
					,comb.Value as Qty
					,comb.Value * comb.WholeSalePrice as Amt_Actual
					,0 as Amt
					,0 as CustomerNumber,'N' as BypassForcing,comb.Pareto 			
					,comb.PlannerNumber,comb.primarysupplier,comb.Owner_
					,comb.Family_0
					from comb

				 --where comb.Typ_ in ('Forecast')
				 where comb.Typ_ in (select splitdata from JDE_DB_Alan.dbo.fnSplitString(@DataType,',')) 
				-- order by Pareto asc,comb.ItemNumber,comb.Typ_,comb.Period_YM
               )

			   
              select fl.ItemNumber,fl.BranchPlant,fl.UOM,fl.ForcastType
					--  ,fl.Period_YM,fl.Period_YMD_1,fl.Period_YMD_2
					 ,fl.Period_YMD_3,fl.Qty,fl.Amt,fl.CustomerNumber,fl.BypassForcing
					 --,fl.Amt_Actual,fl.Pareto
			  from fl
			  where fl.Typ_ in ('Adj_FC')
			  order by Pareto asc,fl.ItemNumber,fl.Typ_,fl.Period_YM
			  option (maxrecursion 0)

		END

		   --- if want to Use both Item_id & Supplier_id --- 
		ELSE IF @Supplier_id IS not NULL and @Item_id IS not NULL and @DataType IS not NULL and ( @IncludeRowNum = 'N' or @IncludeRowNum is null )           ---  No, no Rownunmber just data dump into Text file then straight into Jde 17/5/2021, but you provided Vendor id and Item id when query      
		BEGIN
				with cte as (
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
				 ) 
				,comb_ as ( select cte.ItemNumber,cte.Typ_,cte.Period_YM,cte.Value,m.StandardCost,m.WholeSalePrice,p.Pareto,m.UOM,m.PrimarySupplier 					
								,m.PlannerNumber
								,m.SellingGroup,m.FamilyGroup,m.Family
								,case m.PlannerNumber
												when '20072' then 'Salman Saeed'
												when '20004' then 'Margaret Dost'	
												when '20005' then 'Imelda Chan'
												when '20071' then 'Rosie Ashpole'
												when '20003' then 'Lee Roise'
												when '30036' then 'Violet Glodoveza'
												when '30039' then 'Ben'
												when '29917' then 'Metals Planner'
												when '20065' then 'AWF RollForming'
												when '2519718' then 'CutLength Planner'																					  
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

			 ,fl as (	select comb.ItemNumber,'HD' as BranchPlant,comb.UOM,'BF' as ForcastType
					,comb.Period_YM
					,convert(date,dateadd(d,-1,dateadd(mm,0,convert(datetime,comb.Period_YM+'01',103))),103) as Period_YMD_1		-- to get 'Jde FC Date' Format ie 31/Month/Year,however when FC loaded into Jde, Jde will automatically add 1 day and push FC to Following month, ie 31/1/2018 FC will be push into Month slot of 1/Feb/2018, so here you need to change date again
					,convert(date,dateadd(d,-1,dateadd(mm,1,convert(datetime,comb.Period_YM+'01',103))),103) as Period_YMD_2        -- Current month + 1 month minus 1 day to get last day of same month , to get 'Jde FC Date' Format ie 31/Month/Year, get last day of last month 
					,convert(varchar(10),convert(date,dateadd(d,-1,dateadd(mm,1,convert(datetime,comb.Period_YM+'01',105))),103),103) Period_YMD_3 
					,comb.Typ_
					,comb.Value as Qty
					,comb.Value * comb.WholeSalePrice as Amt_Actual
					,0 as Amt
					,0 as CustomerNumber,'N' as BypassForcing,comb.Pareto 			
					,comb.PlannerNumber,comb.primarysupplier,comb.Owner_
					,comb.Family_0
					from comb

				--where comb.Typ_ in ('Forecast')
				where comb.Typ_ in (select splitdata from JDE_DB_Alan.dbo.fnSplitString(@DataType,',')) 
				--order by Pareto asc,comb.ItemNumber,comb.Typ_,comb.Period_YM
				)
				 
				 
              select fl.ItemNumber,fl.BranchPlant,fl.UOM,fl.ForcastType
				--    ,fl.Period_YM,fl.Period_YMD_1,fl.Period_YMD_2
					,fl.Period_YMD_3,fl.Qty,fl.Amt,fl.CustomerNumber,fl.BypassForcing
					--,fl.Amt_Actual,fl.Pareto
			  from fl
			  where fl.Typ_ in ('Adj_FC')
			  order by Pareto asc,fl.ItemNumber,fl.Typ_,fl.Period_YM
			  option (maxrecursion 0)
		END

END
