/*    ==Scripting Parameters==

    Source Server Version : SQL Server 2016 (13.0.4259)
    Source Database Engine Edition : Microsoft SQL Server Express Edition
    Source Database Engine Type : Standalone SQL Server

    Target Server Version : SQL Server 2016
    Target Database Engine Edition : Microsoft SQL Server Express Edition
    Target Database Engine Type : Standalone SQL Server
*/

USE [JDE_DB_Alan]
GO

/****** Object:  View [JDE_DB_Alan].[vw_Cust_Commit_TTL]    Script Date: 12/08/2022 2:29:50 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





ALTER view [JDE_DB_Alan].[vw_Cust_Commit_TTL] with schemabinding as
 

 --- 12/8/2022 ---
 --- this 'View' works on 'Item_Availablity' table ( 170,000 records ) which is really a inventory details reports from Jde
 --- however this 'Item_Availability' data from Jde contains AWF customer commitment ( under AWF Business unit - 'P' primary location - 'Qty_Soft_Commit' ); 
  --- and other Customer commitment ( under HD Business unit - 'P' primary location - 'Qty_hard_Commit' ), effectively this report includes all Customer orders but with No date required ( volume are aggregated )
   -- so I just use This month ( current month ) as customer required date because normally most customer orders are due within 30 days we are whole sale business
   -- This View also tranaform data from Vertical to Horizontal --- all customer commit volume are laid out across columns for easy manupilation 


  --- Note in this code , all Customer commitment are in 'P' under 'Primary Location' field, all data under 'S' are excluded !!
 ---  Note 'Qty hard Committed' is Qty for confirmed Customer order; 'Qty soft Committed' is qty required by AWF but do not necessarily mean it has been converted into SO yet; 'Qty on Po ' ( same as 'Qty on receipt'in Jde 'Details Availaibility' screen ) means all PO Qty in pipeline but not yet received; Qty on Future' may means future CO ( we do not really use this data )---  Since normally HD customer order qty are under 'Hard Commit' field in Jde report and AWF 'Soft Commit' filed in Jde report has covered all AWF customer order volume including both soft and hard commit - it is Grand Total for AWF
 ---  Since normally HD customer order qty are under 'Hard Commit' field in Jde report and AWF 'Soft Commit' filed in Jde report has covered all AWF customer order volume including both soft and hard commit - it is Grand Total for AWF
 ---  So really your true availalbe stock should be SOH - CO ( hard committed ) - AWF committed ( Softy committed ) + AWF SOH ( on P location ) ---
  
  -- note if you only want to use 'AWF' 'Soft_Commit' then you only include 'Qty_AWF_Soft_Commit' ; if you want to use all customer commit volume use 'Qty_HD_hard_AWF_Soft_Commit', 
  --- be cautious not to double dip if you in future want to spit out HD customer volume by month using sales order 'SO" data by month

  --- also be careful:
  --- 1. that HD hard commitment might include AWF soft commit ?
  --- 2. HD hard commitment does not necessarily inlude all future customer orders - depends on the status - it is ST or SO ?
  --- 3. Back order can be just same as HD hard commit volume if we have 0 SOH - item 1019884(1424770) -- need to understand Back Order logic

 -- select distinct a.Reportdate as Rpt_dt from JDE_DB_Alan.Jde_Item_Availability a 
 -- select distinct convert( varchar(10),a.Reportdate,120) as Rpt_dt from JDE_DB_Alan.Jde_Item_Availability a 

 with cust_committed_ttl as 		
        ( select a.Short_Item_Num,b.ItemNumber					
						,b.StockingType,b.QtyOnHand as SOH_ML345,b.Description,b.FamilyGroup_
						--,b.Family_0
						,b.UOM,b.StandardCost	
						,convert(varchar(7), DATEADD(mm, DATEDIFF(m,0,GETDATE()),0),120) as cust_commit_date	
					   -- ,convert( varchar(10),a.Reportdate,120)	as Rpt_date
					--,len(a.Business_unit) as bu_length					
					--,sum(isnull(a.qty_on_hand,0)) as hdsoh
					--,sum( case when (a.Business_Unit = 'HD' and a.Primary_Location = 'P') then a.QTY_On_Hand end ) as HD_SOH_0
					,sum( case when (a.Business_Unit = 'HD' and a.Primary_Location = 'P') then isnull(a.QTY_On_Hand,0) end) as HD_SOH_41021A	--- works, no need to  use isnull in front of sum() function as HD_SOH usually has value  -- 10/8/2022
					
					,isnull(sum(case when a.Business_Unit = 'AWF' and a.Primary_Location = 'P' then isnull(a.QTY_On_Hand,0)  end),0)   as AWF_SOH_41021A	---  need to  use isnull/coalesce in front of sum() function in case AWF_SOH does not have value	--- 10/8/2022	
				  
				    ,isnull(sum(case when a.Business_Unit = 'HD' and a.Primary_Location = 'P' then isnull(a.QTY_On_PO,0)  end),0)   as HD_PO_41021A	---  need to  use isnull/coalesce in front of sum() function in case HD_PO does not have value	--- 10/8/2022	
				    

					,coalesce(sum( case when a.Business_Unit = 'HD' and a.Primary_Location = 'P' then isnull(a.QTY_hard_Committed,0) end),0) as HD_hard_comit
					,coalesce(sum( case when a.Business_Unit = 'HD' and a.Primary_Location = 'P' then isnull(a.QTY_soft_Committed,0) end),0)  as HD_soft_comit
					,coalesce(sum( case when a.Business_Unit = 'AWF' and a.Primary_Location = 'P' then isnull(a.QTY_hard_Committed,0) end),0) as AWF_hard_comit
					,coalesce(sum( case when a.Business_Unit = 'AWF' and a.Primary_Location = 'P' then isnull(a.QTY_soft_Committed,0) end),0) as AWF_soft_comit
		
					,( coalesce(sum( case when a.Business_Unit = 'HD' and a.Primary_Location = 'P' then isnull(a.QTY_hard_Committed,0) end),0) + coalesce(sum( case when a.Business_Unit = 'AWF' and a.Primary_Location = 'P' then isnull(a.QTY_soft_Committed,0) end),0) ) as Qty_HD_hard_AWF_Soft_Commit
		             
					,isnull(sum(case when a.Business_Unit = 'HD' and a.Primary_Location = 'P' then isnull(a.QTY_Backordered,0)  end),0)   as HD_BO_41021A	---  need to  use isnull/coalesce in front of sum() function in case  does not have value	--- 12/8/2022	
					,isnull(sum(case when a.Business_Unit = 'AWF' and a.Primary_Location = 'P' then isnull(a.QTY_Backordered,0)  end),0)  as AWF_BO_41021A	---  need to  use isnull/coalesce in front of sum() function in case  does not have value	--- 12/8/2022	

					--,sum(isnull(a.Qty_hard_Committed,0)) over ( partition by a.short_item_num order by a.short_item_num)  as hard_cmit_ttl 
					--,sum(isnull(a.Qty_Soft_Committed,0)) over ( partition by a.short_item_num order by a.short_item_num)  as soft_cmit_ttl  
        
				  from JDE_DB_Alan.Jde_Item_Availability a left join JDE_DB_Alan.vw_Mast b on a.Short_Item_Num = b.ShortItemNumber		
				 --where b.FamilyGroup in ('965') and b.Family in ('THH') and b.StockingType in ('P') and b.Description like ('%tube%')  
				   where b.StockingType in ('P') and a.Primary_Location in ('P') 
						  --and a.Business_Unit in ('HD')
						 -- and b.ItemNumber in ('7456500914','42.210.031')
				   group by a.Short_Item_Num,b.ItemNumber,b.StockingType,b.QtyOnHand,b.Description,b.FamilyGroup_
							--,b.Family_0
							,b.UOM,b.StandardCost
							-- ,convert( varchar(10),a.Reportdate,120)	
				 --group by a.Short_Item_Num,b.ItemNumber  ---a.Business_Unit,a.Primary_Location			
                    
					)
									
               -- ,a as (  select a.ItemNumber as Item_Number,a.Qty_HD_hard_AWF_Soft_Commit 
			   --	                 ,a.SO_commit_date
			   --	         from so_committed_ttl  a

			   --			)

         select a.Short_Item_Num,a.ItemNumber,a.StockingType,a.SOH_ML345,a.Description,a.FamilyGroup_,a.UOM,a.StandardCost
		        ,a.cust_commit_date,a.HD_SOH_41021A,a.AWF_SOH_41021A
				,a.HD_PO_41021A
				,a.HD_hard_comit,a.HD_soft_comit,a.AWF_hard_comit,a.AWF_soft_comit
				,a.Qty_HD_hard_AWF_Soft_Commit
				,a.HD_BO_41021A,a.AWF_BO_41021A
				--,a.Reportdate
				
		 from cust_committed_ttl a


    


GO


