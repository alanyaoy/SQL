  	--- Updated 21/5/2021 to remove/prevent  duplicate in HD (Textile) Work Center --------

    --- Created on 18/8/2020 ---- Use Single Select SQL command ------ Re write code ---- Will this be more efficient in term of performance if use base Master table 
	--- this will help to create view Index becuase View Index does not support ------ 

    --- Updated 4/6/2020 to include Pareto, Safety stock details ------

--CREATE view [JDE_DB_Alan].[vw_Mast] with schemabinding as
--- please note following view for Master only includes Items which is forecastable ---


create view [JDE_DB_Alan].[vw_Mast_Classic_1] as

--select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('42.210.031')
--select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('42.210.031')

select BU,ItemNumber,ShortItemNumber,Colour,StockingType,Pareto
		,v.SS_Adj_Jde,SS_Adj,SS_Latest_upd_date,ValidStatus_Adj_Flag
		,PlannerNumber,Owner_,PrimarySupplier,SupplierName,FamilyGroup_,Family_0,SellingGroup_
		,LeadtimeLevel,UOM,ConvUOM,ConversionFactor,Leadtime_Mth
		,StandardCost,WholeSalePrice,Description,QtyOnHand
		,convert(varchar(7),GETDATE(),120) as SOHDate
		,convert(varchar(7),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),120) as SOHDate_
		,datepart(year,GETDATE()) masyr,datepart(month,GETDATE()) masmth,datepart(day,GETDATE()) masdte
		,GLCat,StockValue,rn,SellingGroup,FamilyGroup,Family
	    ,case 
			when WC_Group is not null then WC_Group								
			when WC_Group is null then '0'		
			end as WC_Grp 
         ,case 
			when WC_Code is not null then WC_Code							
			when WC_Code is null then '0'		
		end as WC_Cde  
		,LocalImport,CycleCount
		,OrigMasterDataDate

		,v.Order_Policy,v.Order_Policy_Description,v.Order_Policy_Value
				,v.Planning_Code,v.Planning_Code_Description
				,v.Planning_Fence_Rule,v.Planning_Fence_Rule_Description,v.Frz_Time_Fence,v.Msg_Time_Fence				
				,v.Reorder_Quantity,v.Reorder_Qty_Max,v.Reorder_Qty_Min
				,v.ROP														--- is this field used by JDE? - Yes ! Is this value for 'Reorder Point' value ? - Yes !
				,v.Order_Multiple

from 
    ((((((( select * from 
		( select m.BU,m.ItemNumber,m.ShortItemNumber,m.StockingType,m.PlannerNumber,m.PrimarySupplier,m.StandardCost,m.WholeSalePrice,m.Description
				,m.QtyOnHand,m.LeadtimeLevel,m.UOM,m.ConvUOM,m.ConversionFactor
				,case when isnull(round(m.LeadtimeLevel/30,0),0) <0.5 then 1
					      else isnull(cast(round(m.LeadtimeLevel/30,0) as int),0 ) end as Leadtime_Mth
				 ,m.SellingGroup,m.Family,m.FamilyGroup
				  ,m.GLCat,m.StockValue
				  ,case m.PlannerNumber when '20072' then 'Salman Saeed'
						when '20004' then 'Margaret Dost'	
						when '20005' then 'Imelda Chan'
						when '20071' then 'Rosie Ashpole'
						when '20003' then 'Lee Roise'
						when '30036' then 'Violet Glodoveza'
						when '30039' then 'Ben'
						when '29917' then 'Metals Planner'
						when '20065' then 'AWF RollForming'
						when '2519718' then 'CutLength Planner'
						--when '20071' then 'Domenic Cellucci'
						else 'Unknown'
					end as Owner_
				  ,m.Colour,m.localImport,m.CycleCount
				  ,m.ReportDate as OrigMasterDataDate					
		        ,row_number() over(partition by m.itemNumber order by itemnumber) as rn from JDE_DB_Alan.Master_ML345 m ) a
	      where a.rn <2 ) b 

		left join (select Code, LongDescription as SellingGroup_ from JDE_DB_Alan.MasterSellingGroup ) c 
					on b.SellingGroup = c.Code )
		left join (select code, LongDescription as FamilyGroup_ from JDE_DB_Alan.MasterFamilyGroup ) d  
					on b.FamilyGroup = d.Code )
		left join (select code, LongDescription as Family_0	 from JDE_DB_Alan.MasterFamily ) e 
					on b.Family = e.Code )
				
		left join ( select SupplierNumber,SupplierName from JDE_DB_Alan.MasterSupplier ) s 
					on b.PrimarySupplier = s.SupplierNumber
	---	left join ( select ShortItemNumber as ShortItemNumber_wc,WorkCenter,WorkCenterName
		         --    from JDE_DB_Alan.TextileWC ) wc 
				--	on b.ShortItemNumber = wc.ShortItemNumber_wc )

        left join ( select a.ShortItemNumber as ShortItemNumber_wc,a.WC_Code,a.WC_Group
		             from JDE_DB_Alan.vw_HD_WorkCenter a ) wc 
					on b.ShortItemNumber = wc.ShortItemNumber_wc )

        left join ( select ItemNumber as ItemNumber_p, Pareto  from  JDE_DB_Alan.FCPRO_Fcst_Pareto )  p 
					on b.ItemNumber = p.ItemNumber_p)
		left join ( select Itm,SS_Adj,SS_Latest_upd_date,ValidStatus_Adj_Flag from
					   (select ItemNumber as Itm,SS_Adj, ValidStatus_Adj_Flag,max(ReportDate) over(partition by itemNumber) as SS_Latest_upd_date,dense_rank() over ( partition by itemNumber order by reportdate desc ) rk_2_dense	
						 from JDE_DB_Alan.FCPRO_SafetyStock ) a
						 where a.rk_2_dense = 1

						)  ss 
					on b.ItemNumber = ss.Itm  )


        left join ( select  a.Business_Unit
							,a.Item_Number
							,a.Short_Item_Number
							,a.Stocking_Type,a.Planner_Number,a.Primary_Supplier								
									
							--,case when isnull(round(a.Leadtime_Level/30,0),0) <0.5 then 1
							--	  else isnull(cast(round(a.Leadtime_Level/30,0) as int),0 ) end as Leadtime_Mth

							--,c.LongDescription as SellingGroup_
							--,d.LongDescription as FamilyGroup_
							--,e.LongDescription as Family_0		
							,convert(varchar(7),GETDATE(),120) as SOHDate
							,convert(varchar(7),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),120) as SOHDate_
							,datepart(year,GETDATE()) masyr
						  ,datepart(month,GETDATE()) masmth
						  ,datepart(day,GETDATE()) masdte
						  ,row_number() over(partition by a.item_Number order by a.item_number,a.Date_Updated desc,a.Time_of_Day desc) as rwn    -- filter out duplicate records, updated 11/12/2020, sort by different day and time of day as there are duplidates,need to confirm with Stevyn if we can use 'Date_Updated/Time of the day' to remove duplicates , otherwise need to think better way to handle this )  For example --- 850520000202 has 2 records updated same day but diff time of the day; 4152336276B has 2 records updated on different day
						  ,a.Date_Updated,a.Time_of_Day	

						  --,a.Sls_Cd2 as FamilyGroup
						  --,a.Sls_Cd3 as Family
						  --,a.Sls_Cd4 as SellingGroup
						  --,a.Sls_Cd1 
				  
						 -- ,case a.Planner_Number 
							--	when '20072' then 'Salman Saeed'
							--	when '20004' then 'Margaret Dost'	
							--	when '20005' then 'Imelda Chan'
							--	when '20071' then 'Rosie Ashpole'
							--	when '20003' then 'Lee Roise'
							--	when '30036' then 'Violet Glodoveza'
							--	when '30039' then 'Ben'
							--	when '29917' then 'Metals Planner'
							--	when '20065' then 'AWF RollForming'
							--	when '2519718' then 'CutLength Planner'
							--	--when '20071' then 'Domenic Cellucci'
							--	else 'Unknown'
							--end as Owner_

						  ,a.Reorder_Quantity,a.Reorder_Qty_Max,a.Reorder_Qty_Min,a.ROP,a.Order_Multiple
						  ,a.Order_Policy
						  ,case a.Order_Policy 
								  when '0' then 'ROP'				---	Reorder point (Not planned by MPS/MRP/DRP)
								  when '1' then 'LOT4LOT_Or_AsRequied'			---  Lot-for-lot, As required			-- 1 is normally selected value ( Lot-for-lot, As required )
								  when '2' then 'Fixed_Ord_Quantity'			-- -Fixed order quantity
								  when '3' then 'EOQ'							---Economic order quantity (EOQ)
								  when '4' then 'Periods_of_Supply'				--- Periods of supply
								  when '5' then 'Rate_Scheduled_Item'		   --- Rate scheduled item
					 			else 'Unknown'
							end as Order_Policy_Description									
						  ,a.Order_Policy_Value

						  ,a.Planning_Code
						   ,case a.Planning_Code 
								  when '0' then 'NOT_MRP'			---	0 Not Planned by MPS, MRP, or DRP
								  when '1' then 'MPS_Or_DRP'					--- 1 Planned by MPS or DRP				-- 1 is normally selected value ( Planned by MPS or DRP	)
								  when '2' then 'MRP'							--- 2 Planned by MRP
								  when '3' then 'MRP_Add_Indp_FC'				--- 3 Planned by MRP with additional independent forecast
								  when '4' then 'MPS_Paret_PB'					--- 4 Planned by MPS, Parent in Planning Bill
								  when '5' then 'MPS_Comp_PB'					--- 5 Planned by MPS, Component in Planning Bill
								  when '6' then 'Indent_or_MTO'					--- 6 Indent item - PurchaseOnDemand
					 			else 'Unknown'
							end as Planning_Code_Description				  
				  
						  ,a.T_F as Planning_Fence_Rule
						  ,case a.T_F
								  when 'S' then 'CO_Then_FC'						---	 S tells the system to plan using customer demand before the time fence and forecast after the time fence
								  when 'F' then 'FC_Then_FC_Plus_CO'				--- F tells the system to plan using forecast before the time fence and forecast plus customer demand after the time fence
								  when 'C' then 'CO_Then_Greater_CO_Or_FC'			--- C tells Customer demand before, greater of forecast or customer demand after
								  when 'G' then 'Greater_CO_Or_FC_Then_FC'			-- G Greater of forecast or customer demand before, forecast after
								  when '1' then 'Zero_Then_FC'							--- 1 Zero before, forecast after
								  when '3' then 'Zero_Then_CO_Plus_FC'					--- 3 Zero before, forecast plus customer demand after						
					 			else 'Unknown'
							end as Planning_Fence_Rule_Description

						  ,a.Plan_Time_Fence
				  				   
						  ,a.Frz_Time_Fence,a.Msg_Time_Fence
						  ,a.Time_Fence												--- Not sure what is Time_Fence value stands for
						  ,a.SS_Adj_Jde												--- SS_Adj_Jde is Jde value , probalby old
						  ,a.Leadtime_Level,a.Leadtime_MFG
						  ,a.ECO_Number,a.Cyc_Cnt	
						  --,a.ReportDate as OrigMasterDataDate		
						  ,a.ReportDate	

						  from JDE_DB_Alan.Master_V4102A a

		                 ) v
                 on b.ItemNumber = v.Item_Number


    -- where b.StockingType in ('P','Q','M','S')							--- 'O' has 37018 records, 'U' has 3096 records, ML_345 table has total 48572 records, 'O' & 'U' occupy about 80% of total count.

  where ItemNumber in ('24.7111.1858A')

GO


