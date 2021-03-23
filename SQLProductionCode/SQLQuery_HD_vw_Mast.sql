
    --- Updated 4/6/2020 to include Pareto, Safety stock details ---------
	--- Updated 8/3/2021 to include Pareto, Safety stock details ---------

 --- below is comments for 'vw_Safetystock' table but it is also appropriate to 'view_Mast' table, need to try to aovid crosss referencing, try to use raw SQL table as much as you can...
	
	--- please do NOT reference 'vw_Mast' for this view to avoid cross referenceing... if you really really want it, use 'ML345' raw SQL table but not recommended --- 
    --- stick to SQL rule one table data stick to one table, for 'view' you might need to join different table but better to join raw SQL table not 'view' table to avoid dependency and 
    --- problem of later updating ( you could run into problem to updating multiple view, and need to delete them first which is not ideal ---

CREATE view [JDE_DB_Alan].[vw_Mast] with schemabinding as

--- please note following view for Master only includes Items which is forecastable ---


with fc as (
		select f.ItemNumber,f.DataType1,f.Date
				,convert(varchar(7),f.Date,120) as FCDate_
				,datepart(year,f.date) fcyr
				,datepart(month,f.date) fcmth
				,f.Value as FC_Vol
		from JDE_DB_Alan.FCPRO_Fcst f 
		where f.Date < DATEADD(mm, DATEDIFF(m,0,GETDATE())+5,0)	and f.DataType1 in ('Adj_FC')
				--and f.ItemNumber in ('45.103.000','45.200.100') 
          )
    
	,po as (																				-- do you need to use po table in this query ? Maybe not   --- 6/68/2018
		select p.ItemNumber,'WIP' as DataType1,p.DueDate
				,convert(varchar(7),p.DueDate,120) as PODate_
				,datepart(year,p.DueDate) poyr
				,datepart(month,p.DueDate ) pomth
				,p.QuantityOrdered as PO_Vol
		 from JDE_DB_Alan.OpenPO p 
		where  p.DueDate < DATEADD(mm, DATEDIFF(m,0,GETDATE())+8,0)
			--	and p.ItemNumber in ('45.103.000','45.200.100')    
		 )


		 --- Safety stock table --- 8/3/2021---  Not Using 'View' table of 'Safety stock ' table here - why not use 'vw_Safetystock' directly - try to avoid cross referecing( on one hard when creating vw_Mast you are referencing vw_Safetystock; on the other hand, when creating vw_Safetystock, you are referencing vw_Mast table , which is not good )
     ,_ss as (  select a.ItemNumber,a.SS_Adj,a.Stdevp_,a.ValidStatus_Adj_Flag	
					,max(a.ReportDate) over(partition by a.itemNumber) as SS_Latest_upd_date	
					,min(a.ReportDate) over(partition by a.itemNumber) as SS_Oldest_upd_date
					,rank() over ( partition by a.itemNumber order by a.reportdate Desc) rk_0
					,rank() over ( partition by a.itemNumber order by a.reportdate desc) rk_1
					,dense_rank() over ( partition by a.itemNumber order by a.reportdate desc ) rk_2_dense	
					,a.ReportDate
				from JDE_DB_Alan.FCPRO_SafetyStock a
				 )
     

	 ,ss as (   select a.ItemNumber,a.SS_Adj,a.Stdevp_,a.ValidStatus_Adj_Flag
						  ,a.SS_Latest_upd_date,a.SS_Oldest_upd_date	
						 ,a.rk_0,a.rk_1,a.rk_2_dense   									
						,a.ReportDate						
				from _ss as a 		
				where a.rk_2_dense = 1									--- Important !!!   Pick up the latest updated Safetly stock records !!  8/3/2021
	             ) 



		 --- get your master ---
	 ,_mas as (
            select   m.BU
					,m.ItemNumber
				   ,m.ShortItemNumber
				    ,m.StockingType,m.PlannerNumber,m.PrimarySupplier
					,m.StandardCost,m.WholeSalePrice,m.Description,m.QtyOnHand 	
					,m.LeadtimeLevel
					,m.UOM,m.ConvUOM,m.ConversionFactor						
					,case when isnull(round(m.LeadtimeLevel/30,0),0) <0.5 then 1
					      else isnull(cast(round(m.LeadtimeLevel/30,0) as int),0 ) end as Leadtime_Mth
					,c.LongDescription as SellingGroup_
					,d.LongDescription as FamilyGroup_
					,e.LongDescription as Family_0		
			        ,convert(varchar(7),GETDATE(),120) as SOHDate
					,convert(varchar(7),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),120) as SOHDate_
					,datepart(year,GETDATE()) masyr
				  ,datepart(month,GETDATE()) masmth
				  ,datepart(day,GETDATE()) masdte
				  ,row_number() over(partition by m.itemNumber order by itemnumber ) as rn     -- filter out duplicate records
				  ,m.SellingGroup,m.Family,m.FamilyGroup
				  ,m.GLCat,m.StockValue
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
						--when '20071' then 'Domenic Cellucci'
						else 'Unknown'
					end as Owner_
				  ,m.Colour	
				  ,m.localImport
				  ,m.CycleCount
				  ,m.ReportDate as OrigMasterDataDate			

			from  JDE_DB_Alan.Master_ML345 m 
			         left join JDE_DB_Alan.MasterSellingGroup c  on m.SellingGroup = c.Code
					 left join JDE_DB_Alan.MasterFamilyGroup d  on m.FamilyGroup = d.Code
					 left join JDE_DB_Alan.MasterFamily e  on m.Family = e.Code							 	   
			 --where exists ( select fc.ItemNumber from fc where fc.ItemNumber = m.ItemNumber )   --- Probably need to remove this condition as it has significant impact on performance and any code using this view table --- 30/5/2018

			  )  
			  
		--select * from  _mas
			  			   
     ,mas_ as (
				select m.BU,m.ItemNumber,m.ShortItemNumber,m.StockingType,m.PlannerNumber,m.PrimarySupplier
				     ,m.SellingGroup_,m.FamilyGroup_,m.Family_0
					,m.StandardCost,m.WholeSalePrice,m.Description,m.QtyOnHand,m.SOHDate,m.SOHDate_
					,m.masyr,m.masmth,m.masdte
					,m.LeadtimeLevel
					,m.UOM
					,m.ConvUOM
					,m.ConversionFactor
					,m.Leadtime_Mth
					,m.rn 
					,m.SellingGroup,m.FamilyGroup,m.Family
					,m.GLCat,m.StockValue
					,m.Owner_
					,m.Colour
					,m.localImport
				   ,m.CycleCount
					,m.OrigMasterDataDate
					
				from _mas as m where rn =1  )

			
      ,mas as (select a.BU,a.ItemNumber,a.ShortItemNumber,a.StockingType,a.PlannerNumber,a.PrimarySupplier
	             ,a.SellingGroup_,a.FamilyGroup_,a.Family_0
				,a.StandardCost,a.WholeSalePrice,a.Description,a.Colour,a.QtyOnHand,a.SOHDate,a.SOHDate_
				,a.masyr,a.masmth,a.masdte
				,a.LeadtimeLevel
				,a.UOM,a.ConvUOM,a.ConversionFactor	
				,a.Leadtime_Mth
				,a.rn
				,a.SellingGroup,a.FamilyGroup,a.Family 	
				,a.GLCat,a.StockValue	
				,a.Owner_
				,s.SupplierName		
				,p.Pareto
				,ss.SS_Adj
				,ss.Stdevp_,ss.SS_Latest_upd_date,ss.ValidStatus_Adj_Flag	
				,case 
					when wc.WorkCenter is not null then wc.WorkCenter
					--when wc.WorkCenter is null then 'No_WC_Assigned'		
					  when wc.WorkCenter is null then '0'		
					end as WC	
			   	 ,a.localImport
			     ,a.CycleCount		
				,a.OrigMasterDataDate

                from mas_ a left join JDE_DB_Alan.MasterSupplier s on a.PrimarySupplier = s.SupplierNumber
				            left join JDE_DB_Alan.TextileWC wc on a.ShortItemNumber = wc.ShortItemNumber
							left join JDE_DB_Alan.FCPRO_Fcst_Pareto p on a.ItemNumber = p.ItemNumber
							--left join JDE_DB_Alan.FCPRO_SafetyStock ss on a.ItemNumber = ss.ItemNumber
							left join ss on a.ItemNumber = ss.ItemNumber

			 -- where a.ItemNumber in ('42.210.031')
	 	          )

       
	   
	    -------- Get some Planning Parameters from Planning Master raw table ( not vw_Master_Planning) - V4102A ----------    9/3/2021
		
		 --- get your Planning master ---
	 ,_ms as (
            select   m.Business_Unit
					,m.Item_Number
				    ,m.Short_Item_Number
				    ,m.Stocking_Type,m.Planner_Number,m.Primary_Supplier								
									
					,case when isnull(round(m.Leadtime_Level/30,0),0) <0.5 then 1
					      else isnull(cast(round(m.Leadtime_Level/30,0) as int),0 ) end as Leadtime_Mth
					,c.LongDescription as SellingGroup_
					,d.LongDescription as FamilyGroup_
					,e.LongDescription as Family_0		
			        ,convert(varchar(7),GETDATE(),120) as SOHDate
					,convert(varchar(7),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),120) as SOHDate_
					,datepart(year,GETDATE()) masyr
				  ,datepart(month,GETDATE()) masmth
				  ,datepart(day,GETDATE()) masdte
				  ,row_number() over(partition by m.item_Number order by item_number,m.Date_Updated desc,m.Time_of_Day desc) as rn    -- filter out duplicate records, updated 11/12/2020, sort by different day and time of day as there are duplidates,need to confirm with Stevyn if we can use 'Date_Updated/Time of the day' to remove duplicates , otherwise need to think better way to handle this )  For example --- 850520000202 has 2 records updated same day but diff time of the day; 4152336276B has 2 records updated on different day
				  ,m.Date_Updated,m.Time_of_Day	

				  ,m.Sls_Cd2 as FamilyGroup
				  ,m.Sls_Cd3 as Family
				  ,m.Sls_Cd4 as SellingGroup
				  ,m.Sls_Cd1 
				  
				  ,case m.Planner_Number 
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
						--when '20071' then 'Domenic Cellucci'
						else 'Unknown'
					end as Owner_
				  ,m.Reorder_Quantity,m.Reorder_Qty_Max,m.Reorder_Qty_Min,m.ROP,m.Order_Multiple
				  ,m.Order_Policy
				  ,case m.Order_Policy 
						  when '0' then 'ROP'				---	Reorder point (Not planned by MPS/MRP/DRP)
				          when '1' then 'LOT4LOT_Or_AsRequied'			---  Lot-for-lot, As required			-- 1 is normally selected value ( Lot-for-lot, As required )
						  when '2' then 'Fixed_Ord_Quantity'			-- -Fixed order quantity
						  when '3' then 'EOQ'							---Economic order quantity (EOQ)
						  when '4' then 'Periods_of_Supply'				--- Periods of supply
						  when '5' then 'Rate_Scheduled_Item'		   --- Rate scheduled item
					 	else 'Unknown'
					end as Order_Policy_Description									
				  ,m.Order_Policy_Value

				  ,m.Planning_Code
				   ,case m.Planning_Code 
						  when '0' then 'NOT_MRP'			---	0 Not Planned by MPS, MRP, or DRP
				          when '1' then 'MPS_Or_DRP'					--- 1 Planned by MPS or DRP				-- 1 is normally selected value ( Planned by MPS or DRP	)
						  when '2' then 'MRP'							--- 2 Planned by MRP
						  when '3' then 'MRP_Add_Indp_FC'				--- 3 Planned by MRP with additional independent forecast
						  when '4' then 'MPS_Paret_PB'					--- 4 Planned by MPS, Parent in Planning Bill
						  when '5' then 'MPS_Comp_PB'					--- 5 Planned by MPS, Component in Planning Bill
						  when '6' then 'Indent_or_MTO'					--- 6 Indent item - PurchaseOnDemand
					 	else 'Unknown'
					end as Planning_Code_Description				  
				  
				  ,m.T_F as Planning_Fence_Rule
				  ,case m.T_F
						  when 'S' then 'CO_Then_FC'						---	 S tells the system to plan using customer demand before the time fence and forecast after the time fence
				          when 'F' then 'FC_Then_FC_Plus_CO'				--- F tells the system to plan using forecast before the time fence and forecast plus customer demand after the time fence
						  when 'C' then 'CO_Then_Greater_CO_Or_FC'			--- C tells Customer demand before, greater of forecast or customer demand after
						  when 'G' then 'Greater_CO_Or_FC_Then_FC'			-- G Greater of forecast or customer demand before, forecast after
						  when '1' then 'Zero_Then_FC'							--- 1 Zero before, forecast after
						  when '3' then 'Zero_Then_CO_Plus_FC'					--- 3 Zero before, forecast plus customer demand after						
					 	else 'Unknown'
					end as Planning_Fence_Rule_Description

                  ,m.Plan_Time_Fence
				  				   
				  ,m.Frz_Time_Fence,m.Msg_Time_Fence
				  ,m.Time_Fence												--- Not sure what is Time_Fence value stands for
				  ,m.SS_Adj_Jde												--- SS_Adj_Jde is Jde value , probalby old
				  ,m.Leadtime_Level,m.Leadtime_MFG
				  ,m.ECO_Number,m.Cyc_Cnt	
				  --,m.ReportDate as OrigMasterDataDate		
				  ,m.ReportDate	

			from  JDE_DB_Alan.Master_V4102A m 
			         left join JDE_DB_Alan.MasterSellingGroup c  on m.Sls_Cd4 = c.Code
					 left join JDE_DB_Alan.MasterFamilyGroup d  on m.Sls_Cd2 = d.Code
					 left join JDE_DB_Alan.MasterFamily e  on m.Sls_Cd3 = e.Code							 	   
			 --where exists ( select fc.ItemNumber from fc where fc.ItemNumber = m.ItemNumber )   --- Probably need to remove this condition as it has significant impact on performance and any code using this view table --- 30/5/2018

			  )  
			  
		--select * from  _mas m where m.Item_Number in ('4152336276B','850520000202')			-- 850520000202 has 2 records updated same day but diff time of the day; 4152336276B has 2 records updated on different day
			  			   
     ,ms_ as (
				select 
					 m.Business_Unit,m.Item_Number,m.Short_Item_Number,m.Stocking_Type,m.Planner_Number,m.Primary_Supplier
					 ,m.Sls_Cd1
				     ,m.SellingGroup_
					 ,m.FamilyGroup_,m.Family_0	
					 ,m.Reorder_Quantity,m.Reorder_Qty_Max,m.Reorder_Qty_Min,m.ROP,m.Order_Multiple
					 ,m.Order_Policy,m.Order_Policy_Description,m.Order_Policy_Value
					 ,m.Planning_Code,m.Planning_Code_Description	
					 ,m.Planning_Fence_Rule
					 ,m.Planning_Fence_Rule_Description
					 ,m.Frz_Time_Fence,m.Msg_Time_Fence
					 ,m.Time_Fence
					 ,m.SS_Adj_Jde								--- SS_Adj_Jde is Jde value , probalby old
					 ,m.ECO_Number	
					 	
					,m.Leadtime_Level					
					,m.Leadtime_Mth
					,m.rn 
					,m.SellingGroup,m.FamilyGroup,m.Family					
					,m.Owner_					
				   ,m.Cyc_Cnt
					,m.ReportDate
					
				from _ms as m where rn =1  )

	
	--------End of getting some Planning Parameters from Planning Master raw table ( not vw_Master_Planning) - V4102A ----------    9/3/2021
             

		
      select a.BU,a.ItemNumber,a.ShortItemNumber,a.StockingType,a.Pareto,a.PlannerNumber,a.PrimarySupplier
	             ,a.SellingGroup_,a.FamilyGroup_,a.Family_0
				,a.StandardCost,a.WholeSalePrice,a.Description,a.Colour,a.QtyOnHand,a.SOHDate,a.SOHDate_
				,a.masyr,a.masmth,a.masdte
				,a.LeadtimeLevel
				,a.UOM,a.ConvUOM,a.ConversionFactor	
				,a.Leadtime_Mth
				,b.SS_Adj_Jde										--- SS_Adj_Jde is safety stock Jde value , probalby old
				,a.SS_Adj											--- SS_Adj is alway new safety stock value from '.Fcst_SafetyStock' table using 'Cal_Safety_Stock 'store procedure	
				,a.SS_Latest_upd_date,a.ValidStatus_Adj_Flag
				,a.rn
				,a.SellingGroup,a.FamilyGroup,a.Family 	
				,a.GLCat,a.StockValue	
				,a.Owner_
				,a.SupplierName				
				,WC	
				,a.localImport
				,a.CycleCount
				,a.OrigMasterDataDate
				
				,b.Order_Policy,b.Order_Policy_Description,b.Order_Policy_Value
				,b.Planning_Code,b.Planning_Code_Description
				,b.Planning_Fence_Rule,b.Planning_Fence_Rule_Description,b.Frz_Time_Fence,b.Msg_Time_Fence				
				,b.Reorder_Quantity,b.Reorder_Qty_Max,b.Reorder_Qty_Min
				,b.ROP														--- is this field used by JDE? - Yes ! Is this value for 'Reorder Point' value ? - Yes !
				,b.Order_Multiple


                from mas a  left join ms_ b on a.ShortItemNumber = b.Short_Item_Number

       --where a.ItemNumber in ('34.481.000')

	   --select * from mas 
	   --where z.wc <> '0'
GO
