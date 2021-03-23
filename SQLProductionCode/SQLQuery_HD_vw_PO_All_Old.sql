/*    ==Scripting Parameters==

    Source Server Version : SQL Server 2016 (13.0.4001)
    Source Database Engine Edition : Microsoft SQL Server Express Edition
    Source Database Engine Type : Standalone SQL Server

    Target Server Version : SQL Server 2016
    Target Database Engine Edition : Microsoft SQL Server Express Edition
    Target Database Engine Type : Standalone SQL Server
*/

USE [JDE_DB_Alan]
GO

/****** Object:  View [JDE_DB_Alan].[vw_PO_All]    Script Date: 26/02/2021 10:18:05 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO








	--- created 25/2/2021 --- 


ALTER view [JDE_DB_Alan].[vw_PO_All] with schemabinding as
 

 with a as ( 
		   select  a.Business_Unit,a.Short_Item_No,a.Item_Number,a.Descrip,a.Or_Ty,a.Order_Number
					  ,a.Order_Date,a.Actual_Ship_Date,a.Shipment_Number
					  ,case 
						  when a.Actual_Ship_Date is null then 'N'
						  else 'Y'
					   end as Actual_Ship_Status
					   ,convert(varchar(7),a.Actual_Ship_Date,120) as ActualShipMth_

					  ,case 
						  when a.Actual_Ship_Date is null then GETDATE()
						  else a.Actual_Ship_Date
					   end as Actual_Ship_Date_2

					   
                      ,case 
						  when a.Actual_Ship_Date is null then datediff(day,a.Order_Date,getdate()) 
						  else datediff(day,a.Order_Date,a.Actual_Ship_Date)
					   end as Actual_Ship_LT_Days

				      ,m.LeadtimeLevel as Jde_LT_Days

					  ,a.Quantity_Ordered,a.Quantity_Open
					  ,a.Address_Number as Vendor_,a.Buyer_Number,a.Unit_Cost,a.Extended_Price,a.Next_Stat,a.Last_Stat,a.Line_Number,a.Ship_To_Number,a.Account_ID,a.UM
					  ,a.Amount_Open_1,a.Amount_Open_2,a.Currency_Code,a.Ln_Ty,a.Foreign_Unit_Cost,a.Foreign_Extended_Price,a.Request_Date,a.Original_Promised_Date,a.G_L_Date,a.Cancel_Date
				      ,m.Family,m.FamilyGroup,m.Family_0,m.FamilyGroup_,m.SupplierName,m.Owner_,m.WholeSalePrice,m.Pareto
					 
			

		   from JDE_DB_Alan.PO_All a left join JDE_DB_Alan.vw_Mast m on a.Item_Number = m.ItemNumber
          )

	,b as (select
				 a.Business_Unit,a.Short_Item_No,a.Item_Number,a.Descrip,a.Or_Ty,a.Order_Number
				 ,a.Order_Date,a.Actual_Ship_Date,a.Shipment_Number
				 ,a.Actual_Ship_Status
				 ,a.ActualShipMth_
				 ,a.Actual_Ship_Date_2
				 ,a.Actual_Ship_LT_Days
				 ,a.Jde_LT_Days
				  ,(a.Actual_Ship_LT_Days - a.Jde_LT_Days ) as LT_Diff
				  ,(a.Actual_Ship_LT_Days - a.Jde_LT_Days )/a.Jde_LT_Days as LT_Diff_Pcnt

				,a.Quantity_Ordered,a.Quantity_Open
				,a.Vendor_,a.Buyer_Number,a.Unit_Cost,a.Extended_Price,a.Next_Stat,a.Last_Stat,a.Line_Number,a.Ship_To_Number,a.Account_ID,a.UM
				,a.Amount_Open_1,a.Amount_Open_2,a.Currency_Code,a.Ln_Ty,a.Foreign_Unit_Cost,a.Foreign_Extended_Price,a.Request_Date,a.Original_Promised_Date,a.G_L_Date,a.Cancel_Date
				,a.Family,a.FamilyGroup,a.Family_0,a.FamilyGroup_,a.SupplierName,a.Owner_,a.WholeSalePrice,a.Pareto	
								 
	from a    

   --where a.Item_Number in ('7390060182','24.7219.0952')

     )

	,c as( select 	  b.Business_Unit,b.Short_Item_No,b.Item_Number,b.Descrip,b.Or_Ty,b.Order_Number
				 ,b.Order_Date,b.Actual_Ship_Date,b.Shipment_Number
				 ,b.Actual_Ship_Status
				 ,b.ActualShipMth_
				 ,b.Actual_Ship_Date_2
				 ,b.Actual_Ship_LT_Days
				 ,b.Jde_LT_Days
				  ,b.LT_Diff
				  ,b. LT_Diff_Pcnt
			  
			  ,max(LT_Diff) over(partition by b.item_number) as Max_Gap_day	
			  ,min(LT_Diff) over(partition by b.item_number) as Min_Gap_day	
			  ,rank() over ( partition by b.item_number order by order_number) rk_1
			  ,dense_rank() over ( partition by b.item_number order by order_number) rk_2
			  ,count(Order_Number) over( partition by b.item_number) as Orde_Count
			  ,avg(Actual_Ship_LT_Days) over( partition by b.item_number) as Avg_Ship_Days
			   ,STDEVP(Actual_Ship_LT_Days) over( partition by b.item_number) as Stdev_Itm	

				,b.Quantity_Ordered,b.Quantity_Open
				,b.Vendor_,b.Buyer_Number,b.Unit_Cost,b.Extended_Price,b.Next_Stat,b.Last_Stat,b.Line_Number,b.Ship_To_Number,b.Account_ID,b.UM
				,b.Amount_Open_1,b.Amount_Open_2,b.Currency_Code,b.Ln_Ty,b.Foreign_Unit_Cost,b.Foreign_Extended_Price,b.Request_Date,b.Original_Promised_Date,b.G_L_Date,b.Cancel_Date
				,b.Family,b.FamilyGroup,b.Family_0,b.FamilyGroup_,b.SupplierName,b.Owner_,b.WholeSalePrice,b.Pareto	
				
   			from b
		       )

 
 	 select 	 c.business_Unit,c.Short_Item_No,c.Item_Number,c.Descrip,c.Or_Ty,c.Order_Number
				 ,c.Order_Date,c.Actual_Ship_Date,c.Shipment_Number
				 ,c.Actual_Ship_Status
				 ,c.ActualShipMth_
				 ,c.Actual_Ship_Date_2
				 ,c.Actual_Ship_LT_Days
				 ,c.Jde_LT_Days
				  ,c.LT_Diff
				  ,c. LT_Diff_Pcnt
				  ,c.Avg_Ship_Days
				  ,c.Stdev_Itm

				  ,c.Max_Gap_day
				  ,c.Min_Gap_day
				  ,c.rk_1
				  ,c.rk_2
				  ,c.Orde_Count

				,c.Quantity_Ordered,c.Quantity_Open
				,c.Vendor_,c.Buyer_Number,c.Unit_Cost,c.Extended_Price,c.Next_Stat,c.Last_Stat,c.Line_Number,c.Ship_To_Number,c.Account_ID,c.UM
				,c.Amount_Open_1,c.Amount_Open_2,c.Currency_Code,c.Ln_Ty,c.Foreign_Unit_Cost,c.Foreign_Extended_Price,c.Request_Date,c.Original_Promised_Date,c.G_L_Date,c.Cancel_Date
				,c.Family,c.FamilyGroup,c.Family_0,c.FamilyGroup_,c.SupplierName,c.Owner_,c.WholeSalePrice,c.Pareto	

			 from c
	         

   
    --where c.Item_Number in ('7390060182','24.7219.0952')
	--order by c.Item_Number,c.rk_1

   
   --where  a.Order_Date > DATEADD(mm, DATEDIFF(m,0,GETDATE())-11,0)					--- order raised in recent 12 month 
     
    

GO


