
CREATE view [JDE_DB_Alan].[vw_PO_All] with schemabinding as
 


 --- do not remove air freight order ( if shipment days is too short hence stdevp will be larger ) --- it is good
 --- Use 'a.Actual_Ship_Date is not null ' condition 							-- 16,144 - 10,661 = 5483 ( OPen order lines ) 
 
	--select * from JDE_DB_Alan.PO_All


with a as ( 
		   select  a.Business_Unit,a.Short_Item_No,a.Item_Number,a.Descrip,a.Or_Ty,a.Order_Number
					  ,a.Shipment_Number
					  ,case 
						  when a.Actual_Ship_Date is null then 'N'
						  else 'Y'
					   end as Actual_Ship_Status
					  
					  --- Shipm month
					   ,case 
						  when a.Actual_Ship_Date is null then convert(varchar(7),GETDATE(),120)
						  else convert(varchar(7),a.Actual_Ship_Date,120)
					   end as ActualShipMth_2					   
					  
					   ,case 
						  when a.Actual_Ship_Date is null then '0'
						  else convert(varchar(7),a.Actual_Ship_Date,120)
					   end as ActualShipMth_	

					  ,a.Order_Date
					  
					  --- Actual ship date
					  ,a.Actual_Ship_Date					  
					  ,case 
						  when a.Actual_Ship_Date is null then GETDATE()
						  else a.Actual_Ship_Date
					   end as Actual_Ship_Date_2


					     
                     -- ,case 
						--  when a.Actual_Ship_Date is null then datediff(day,a.Order_Date,getdate()) 
						--  else datediff(day,a.Order_Date,a.Actual_Ship_Date)
					   --end as Actual_Ship_LT_Days

					  ,case 
						  when a.Actual_Ship_Date is null then datediff(day,a.Order_Date,getdate())					--- this formula yields unrealistic days in some cases especially if it is new order ( just raised ) -- not good
						  else datediff(day,a.Order_Date,a.Actual_Ship_Date)
					   end as Actual_Ship_LT_Days_2

					  ,case 
						  when a.Actual_Ship_Date is null then 
															  (
																case																									--- for order just raised, we assume it will be delivered within standard LT				
																	when datediff(day,a.Order_Date,getdate()) < m.LeadtimeLevel then m.LeadtimeLevel					--- intentionally remove air freight order, or if order is just raised ( say 3 days ago or 1 week ago, ship date is far away if it is not local ).  
																	when datediff(day,a.Order_Date,getdate()) > m.LeadtimeLevel then datediff(day,a.Order_Date,getdate())
																end 
																) 
						  else datediff(day,a.Order_Date,a.Actual_Ship_Date)
					   end as Actual_Ship_LT_Days
					     

				      ,m.LeadtimeLevel as Jde_LT_Days

					  ,a.Quantity_Ordered,a.Quantity_Open
					  ,a.Address_Number as Vendor_,a.Buyer_Number,a.Unit_Cost,a.Extended_Price,a.Next_Stat,a.Last_Stat,a.Line_Number,a.Ship_To_Number,a.Account_ID,a.UM
					  ,a.Amount_Open_1,a.Amount_Open_2,a.Currency_Code,a.Ln_Ty,a.Foreign_Unit_Cost,a.Foreign_Extended_Price,a.Request_Date,a.Original_Promised_Date,a.G_L_Date,a.Cancel_Date
				      ,m.Family,m.FamilyGroup,m.Family_0,m.FamilyGroup_,m.SupplierName,m.Owner_,m.WholeSalePrice,m.Pareto,m.StockingType			

		   from JDE_DB_Alan.PO_All a left join JDE_DB_Alan.vw_Mast m on a.Item_Number = m.ItemNumber
		     where a.Actual_Ship_Date is not null											--important ! To filter out Open PO.   16,144 - 10,661 = 5483 ( OPen order lines ) filter out PO has already shipped, some PO might be raised by never maintained properly so to fill ship date with today's date for outstanding PO might created unexpected result --- 26/2/2021
          )

	--select * from a	   

	,b as (select
				 a.Business_Unit,a.Short_Item_No,a.Item_Number,a.Descrip,a.Or_Ty,a.Order_Number
				 ,a.Shipment_Number,a.Actual_Ship_Status,a.ActualShipMth_
				 ,a.Order_Date
				 ,a.Actual_Ship_Date				 
				 ,a.Actual_Ship_Date_2
				 ,a.Actual_Ship_LT_Days	
				  ,a.Actual_Ship_LT_Days_2															--- leave air freight days as is, do not remove them
				 ,avg(Actual_Ship_LT_Days) over( partition by a.item_number) as Avg_Ship_Days
				 ,a.Jde_LT_Days
				  ,(a.Actual_Ship_LT_Days - a.Jde_LT_Days ) as LT_Diff
				  ,(a.Actual_Ship_LT_Days - a.Jde_LT_Days )/a.Jde_LT_Days as LT_Diff_Pcnt
				  ,count(Order_Number) over( partition by a.item_number) as Orde_Count

				,a.Quantity_Ordered,a.Quantity_Open
				,a.Vendor_,a.Buyer_Number,a.Unit_Cost,a.Extended_Price,a.Next_Stat,a.Last_Stat,a.Line_Number,a.Ship_To_Number,a.Account_ID,a.UM
				,a.Amount_Open_1,a.Amount_Open_2,a.Currency_Code,a.Ln_Ty,a.Foreign_Unit_Cost,a.Foreign_Extended_Price,a.Request_Date,a.Original_Promised_Date,a.G_L_Date,a.Cancel_Date
				,a.Family,a.FamilyGroup,a.Family_0,a.FamilyGroup_,a.SupplierName,a.Owner_,a.WholeSalePrice,a.Pareto,a.StockingType
								 
	from a    

   --where a.Item_Number in ('7390060182','24.7219.0952')

     )

	,c as( select 	  b.Business_Unit,b.Short_Item_No,b.Item_Number,b.Descrip,b.Or_Ty,b.Order_Number
				 ,b.Order_Date,b.Actual_Ship_Date,b.Shipment_Number
				 ,b.Actual_Ship_Status
				 ,b.ActualShipMth_
				 ,b.Actual_Ship_Date_2
				 ,b.Actual_Ship_LT_Days
				 ,b.Avg_Ship_Days
				 ,b.Jde_LT_Days
				 ,power((b.Actual_Ship_LT_Days - b.Avg_Ship_Days ),2) as Variance_
				  ,b.LT_Diff
				  ,b. LT_Diff_Pcnt
			  
			  ,max(LT_Diff) over(partition by b.item_number) as Max_Gap_day	
			  ,min(LT_Diff) over(partition by b.item_number) as Min_Gap_day	

			  ,rank() over ( partition by b.item_number order by Actual_Ship_Date_2,order_number,Line_Number) rk_0
			  ,rank() over ( partition by b.item_number order by order_number) rk_1
			  ,dense_rank() over ( partition by b.item_number order by order_number) rk_2			  
			  
			   ,STDEVP(Actual_Ship_LT_Days) over( partition by b.item_number) as Stdev_Itm	
			   ,b.Orde_Count

				,b.Quantity_Ordered,b.Quantity_Open
				,b.Vendor_,b.Buyer_Number,b.Unit_Cost,b.Extended_Price,b.Next_Stat,b.Last_Stat,b.Line_Number,b.Ship_To_Number,b.Account_ID,b.UM
				,b.Amount_Open_1,b.Amount_Open_2,b.Currency_Code,b.Ln_Ty,b.Foreign_Unit_Cost,b.Foreign_Extended_Price,b.Request_Date,b.Original_Promised_Date,b.G_L_Date,b.Cancel_Date
				,b.Family,b.FamilyGroup,b.Family_0,b.FamilyGroup_,b.SupplierName,b.Owner_,b.WholeSalePrice,b.Pareto,b.StockingType
				
   			from b
		       )

 
 	 ,d as (select 	 c.business_Unit,c.Short_Item_No,c.Item_Number,c.Descrip,c.Or_Ty,c.Order_Number
				 ,c.Order_Date,c.Actual_Ship_Date,c.Shipment_Number
				 ,c.Actual_Ship_Status
				 ,c.ActualShipMth_
				 ,c.Actual_Ship_Date_2
				 ,c.Actual_Ship_LT_Days
				 
				 ,c.Jde_LT_Days
				  ,c.LT_Diff
				  ,c. LT_Diff_Pcnt
				  ,c.Avg_Ship_Days
				  ,c.Variance_
				  ,SQRT(sum(c.Variance_) over( partition by c.item_number)/c.Orde_Count ) as Root_ 				  			  
				  ,c.Stdev_Itm as Sig_Itm
				  ,(c.Avg_Ship_Days + c.Stdev_Itm *1.5) as Actual_Ship_LT_Days_Final			-- 1 std 68%, 1.3 80%, 1.5 std 85-86%, 2 std 95%, 3 std 99%

				  ,c.Max_Gap_day
				  ,c.Min_Gap_day
				  ,c.rk_0
				  ,c.rk_1
				  ,c.rk_2
				  ,c.Orde_Count

				,c.Quantity_Ordered,c.Quantity_Open
				,c.Vendor_,c.Buyer_Number,c.Unit_Cost,c.Extended_Price,c.Next_Stat,c.Last_Stat,c.Line_Number,c.Ship_To_Number,c.Account_ID,c.UM
				,c.Amount_Open_1,c.Amount_Open_2,c.Currency_Code,c.Ln_Ty,c.Foreign_Unit_Cost,c.Foreign_Extended_Price,c.Request_Date,c.Original_Promised_Date,c.G_L_Date,c.Cancel_Date
				,c.Family,c.FamilyGroup,c.Family_0,c.FamilyGroup_,c.SupplierName,c.Owner_,c.WholeSalePrice,c.Pareto,c.StockingType

			 from c )


    select  d.business_Unit,d.Short_Item_No,d.Item_Number,d.Descrip,d.Or_Ty,d.Order_Number
				 ,d.Order_Date,d.Actual_Ship_Date,d.Shipment_Number
				 ,d.Actual_Ship_Status
				 ,d.ActualShipMth_
				 ,d.Actual_Ship_Date_2
				 ,d.Actual_Ship_LT_Days
				 
				,d.Jde_LT_Days
				,d.LT_Diff
				,d. LT_Diff_Pcnt
				,d.Avg_Ship_Days
				,d.Variance_
				,SQRT(sum(d.Variance_) over( partition by d.item_number)/d.Orde_Count ) as Root_ 				  			  
				,d.Sig_Itm
				,(d.Avg_Ship_Days + d.Sig_Itm *1.5) as Actual_Ship_LT_Days_Final			-- 1 std 68%, 1.3 80%, 1.5 std 85-86%, 2 std 95%, 3 std 99%

				,d.Max_Gap_day
				,d.Min_Gap_day
				,d.rk_0
				,d.rk_1
				,d.rk_2
				,d.Orde_Count
				 
				,d.Quantity_Ordered,d.Quantity_Open
				,d.Vendor_,d.Buyer_Number,d.Unit_Cost,d.Extended_Price,d.Next_Stat,d.Last_Stat,d.Line_Number,d.Ship_To_Number,d.Account_ID,d.UM
				,d.Amount_Open_1,d.Amount_Open_2,d.Currency_Code,d.Ln_Ty,d.Foreign_Unit_Cost,d.Foreign_Extended_Price,d.Request_Date,d.Original_Promised_Date,d.G_L_Date,d.Cancel_Date
				,d.Family,d.FamilyGroup,d.Family_0,d.FamilyGroup_,d.SupplierName,d.Owner_,d.WholeSalePrice,d.Pareto,d.StockingType	
	from d	      
	  
    -- where 
	      -- d.Item_Number in ('1014716')				--- order where has same order number ( not shiped yet )
		 -- d.Item_Number in ('46.508.700')				--- item where has same order number 
		--	d.Item_Number in ('7390060182','24.7219.0952','1014716','46.508.700') 
	      -- d.LT_Diff = d.Max_Gap_day
		--   d.rk_0 = 1													--- this condition will help to pick only 1st line for 1 SKU
		 -- d.Item_Number is null or d.Item_Number =''					--- good to pick up all Item with empty or null value
		  
	--order by d.Item_Number,d.rk_1
   
   --where  a.Order_Date > DATEADD(mm, DATEDIFF(m,0,GETDATE())-11,0)					--- order raised in recent 12 month 
     
    

GO