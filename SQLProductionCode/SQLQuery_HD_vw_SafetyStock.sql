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

/****** Object:  View [JDE_DB_Alan].[vw_SafetyStock]    Script Date: 30/03/2021 12:27:26 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





-- 8/3/2021 ---
--- this code for View is simpler it just pick up the latest SS updated data rather than pick up all Safety stock historial value ---
--- it also filter out MTO items ---> leave this task to Normal SQL query ... here code for 'View' table with pick up everything ---
--- please do NOT reference 'vw_Mast' for this view to avoid cross referenceing... if you really really want it, use 'ML345' raw SQL table but not recommended --- 
--- stick to SQL rule one table data stick to one table, for 'view' you might need to join different table but better to join raw SQL table not 'view' table to avoid dependency and 
--- problem of later updating ( you could run into problem to updating multiple view, and need to delete them first which is not ideal ---

--- Need to reorganize the column to align with .SafetyStock table  --- 22/3/2021


ALTER view [JDE_DB_Alan].[vw_SafetyStock] with schemabinding as


 ----- Query the SS --------

	--with cte as
	--		( select *
	--				,row_number() over(partition by m.itemnumber order by itemnumber ) rn 
	--		from JDE_DB_Alan.Master_ML345 m               
	--		)
	--		,cte_ as
	--		( select * from cte where cte.rn =1
	--		)

	--with cte_ as ( select m.ItemNumber,m.PrimarySupplier,m.LeadtimeLevel,m.StandardCost,m.PlannerNumber
	--					  ,m.StockingType,m.SellingGroup,m.FamilyGroup,m.Family
	--				from JDE_DB_Alan.vw_Mast m )
        
	--- select * from JDE_DB_Alan.FCPRO_SafetyStock a where a.ItemNumber in ('42.210.031','604023820')
	
	 with 	 	
	 
		 _tb as (  select a.ItemNumber,a.Sales_12Mth,a.SS_,a.SS_Adj,a.Stdevp_,a.ValidStatus_Adj_Flag,a.Pareto,a.LeadtimeLevel,a.StockingType
						,a.StandardCost,a.SS_Adj * a.StandardCost as SS_Adj_Dollars
	                    ,a.Order_Policy,a.Order_Policy_Description
						,a.Planning_Code,a.Planning_Code_Description
						,a.Planning_Fence_Rule,a.Planning_Fence_Rule_Description

						
						,max(a.ReportDate) over(partition by a.itemNumber) as Itm_SS_Latest_upd_date	
						,min(a.ReportDate) over(partition by a.itemNumber) as Itm_SS_Oldest_upd_date
						,rank() over ( partition by a.itemNumber order by a.reportdate Desc) rk_0
						,rank() over ( partition by a.itemNumber order by a.reportdate desc) rk_1
						,dense_rank() over ( partition by a.itemNumber order by a.reportdate desc ) rk_2_dense	
						,a.ReportDate
						,max(a.reportdate)over() as Latest_SS_Analysis_Run_date
						
				  from JDE_DB_Alan.FCPRO_SafetyStock a
				-- where a.ItemNumber in ('42.210.031','604023820')

					)

		 ,tb_ as (  	
				  select a.ItemNumber,a.Sales_12Mth,a.SS_
						,a.SS_Adj,a.Stdevp_
						 ,a.rk_0,a.rk_1,a.rk_2_dense   
						 ,a.Itm_SS_Latest_upd_date,a.Itm_SS_Oldest_upd_date,a.ValidStatus_Adj_Flag
						,a.LeadtimeLevel					
						,a.Pareto					
						,a.ReportDate
						,a.StockingType
						,a.StandardCost,a.SS_Adj_Dollars
						,a.Order_Policy,a.Order_Policy_Description
						,a.Planning_Code,a.Planning_Code_Description
						,a.Planning_Fence_Rule,a.Planning_Fence_Rule_Description
						,convert(varchar(19), dateadd(d, datediff(d,0, a.Latest_SS_Analysis_Run_date), 0), 120) as latest_Analyis_Dt_2
						,convert(varchar(10), a.Latest_SS_Analysis_Run_date,120) as latest_Analysis_Dt_3
						,cast(SUBSTRING(REPLACE(CONVERT(char(10),a.Latest_SS_Analysis_Run_date,120),'-',''),1,6) as integer) latest_Analysis_Dt_4

					from _tb as a 
					where a.rk_2_dense = 1									--- Important !!!   Pick up the latest updated Safetly stock records !!  8/3/2021

				  )  

		,tb as ( 		    
				   select a.ItemNumber,a.Sales_12Mth,a.SS_,a.SS_Adj,a.Stdevp_,a.LeadtimeLevel,a.StockingType
				          ,a.StandardCost,a.SS_Adj_Dollars 
				        ,a.Order_Policy,a.Order_Policy_Description
						,a.Planning_Code,a.Planning_Code_Description
						,a.Planning_Fence_Rule,a.Planning_Fence_Rule_Description
						  ,a.Pareto,a.Itm_SS_Latest_upd_date,a.Itm_SS_Oldest_upd_date,a.ValidStatus_Adj_Flag
						  ,a.rk_0,a.rk_1,a.rk_2_dense,a.ReportDate
				   from tb_ a
				   where a.Itm_SS_Latest_upd_date > a.latest_Analyis_Dt_2						-- pick latest record, another layer if 1 SKU was not updated in latest Analysis run ( so you do not want to pick up SS result from previous/last Analysis ) 	30/3/2021
				   )

       --  select * from tb a where a.ItemNumber in ('42.210.031','604023820')

		
		 --- Re arrange the sequence of the columns ---
		-- select a.ItemNumber,a.SS_Adj,a.Stdevp_,a.LeadtimeLevel,a.StockingType,a.StandardCost,a.SS_Adj_Dollars,a.Order_Policy,a.Order_Policy_Description,a.Planning_Code,a.Planning_Code_Description,a.Planning_Fence_Rule,a.Planning_Fence_Rule_Description,a.Pareto,a.SS_Latest_upd_date,a.SS_Oldest_upd_date,a.ValidStatus_Adj_Flag,a.rk_0,a.rk_1,a.rk_2_dense,a.ReportDate			'--- Old Column sequence    18/3/2021
		 select a.ItemNumber,a.Sales_12Mth,a.Pareto,a.StockingType,a.SS_,a.SS_Adj,a.SS_Adj_Dollars,a.ValidStatus_Adj_Flag,a.Stdevp_,a.LeadtimeLevel
				,a.rk_0,a.rk_1,a.rk_2_dense,a.StandardCost
				,a.Order_Policy,a.Order_Policy_Description
				,a.Planning_Code,a.Planning_Code_Description
				,a.Planning_Fence_Rule,a.Planning_Fence_Rule_Description
				,a.Itm_SS_Latest_upd_date,a.Itm_SS_Oldest_upd_date
				,a.ReportDate
				   
		 from tb a


	  -- where 		 
			--  a.ItemNumber in ('34.481.000') and
			--   a.rk_2_dense = 1												
	 -- order by  tb.PrimarySupplier,tb.Pareto
 
	 -- select * from JDE_DB_Alan.FCPRO_SafetyStock ss where ss.ReportDate >'2021-03-02'
	 --  select distinct ss.ReportDate  from JDE_DB_Alan.FCPRO_SafetyStock ss 

	 	   
		     ------------------------------------
	         --- Some Debug tools ---
			 ------------------------------------
	        -- select count(*) from JDE_DB_Alan.FCPRO_SafetyStock ss
	        -- select distinct ss.ReportDate from JDE_DB_Alan.FCPRO_SafetyStock ss
			--  select * from JDE_DB_Alan.FCPRO_SafetyStock ss  where dateadd(d, datediff(d,0, ss.ReportDate), 0) = dateadd(d, datediff(d,0, getdate()), 0)		-- today's record
			--   select * from JDE_DB_Alan.FCPRO_SafetyStock ss  where ss.ItemNumber in ('34.481.000')
			--    select * from JDE_DB_Alan.FCPRO_SafetyStock ss  where ss.ReportDate > dateadd(s,-1, dateadd(d, datediff(d,0, getdate()), 0))		-- any new record sinc middle night yesterday

			--   delete from JDE_DB_Alan.FCPRO_SafetyStock  where ReportDate > dateadd(s,-1, dateadd(d, datediff(d,0, getdate()), 0))				--- delete test data

			----------------------------------------------


GO


