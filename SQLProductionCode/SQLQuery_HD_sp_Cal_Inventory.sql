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
/****** Object:  StoredProcedure [JDE_DB_Alan].[sp_Cal_Inventory]    Script Date: 10/11/2021 7:05:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




ALTER PROCEDURE [JDE_DB_Alan].[sp_Cal_Inventory] 
	-- Add the parameters for the stored procedure here
	--<@Param1, sysname, @p1> <Datatype_For_Param1, , int> = <Default_Value_For_Param1, , 0>, 
	--<@Param2, sysname, @p2> <Datatype_For_Param2, , int> = <Default_Value_For_Param2, , 0>
	@DataType1 varchar(100) = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from interfering with SELECT statements.
	SET NOCOUNT ON;  
	   

    --- 10/11/2021 ---
	--- This code is to obtain summarized inventory value every time you run ML345 - you can opt out to only update inventory at your wish ---
	 --- it is by Category,by stock type by Pareto ; and including OPen PO ; you also hve choice of visiblity of Qty and Dollar value ---
	 --- also include SKU count ---

	--	delete from JDE_DB_Alan.xxx	
		
		----xxxxxxxxxxxxxxxxx---  Inventory Reporting 10/11/2021  ---xxxxxxxxxxxxxxxxxxxxxxxxx------

	--select * from JDE_DB_Alan.Master_ML345			-- 49,607 records
	--select * from JDE_DB_Alan.vw_Mast a				--- 49,594 records
	--select * from JDE_DB_Alan.vw_OpenPO a			--- 4,094 records
	--where a.QuantityOpen is null
	--where a.ItemNumber in ('42.210.031')


	with t as 

		( select a.ItemNumber,a.StockingType,a.Pareto,isnull(a.QtyOnHand,0) as SOH_Qty,isnull(a.StockValue,0) as SOH_Val,a.StandardCost
			   ,isnull(c.PO_Qty,0) as PO_Qty,isnull(c.PO_Qty,0)*a.StandardCost as PO_Val 
			   ,isnull(a.QtyOnHand,0) + isnull(c.PO_Qty,0) as Item_Qty_GrandTTL
			   ,isnull(a.StockValue,0) + (isnull(c.PO_Qty,0)*a.StandardCost) as Item_Val_GrandTTL
			   ,a.FamilyGroup,a.Family_0,a.Description
		   from JDE_DB_Alan.vw_Mast a left join 
				 ( select b.ItemNumber,sum(b.QuantityOpen) as PO_Qty
					from JDE_DB_Alan.vw_OpenPO b
					--where b.ItemNumber in ('42.210.031')
					group by b.ItemNumber

							) c
				  on a.ItemNumber = c.ItemNumber
		 -- where a.ItemNumber in ('42.210.031')
           
			   )
		      
	   , _t as ( select t.FamilyGroup,t.Family_0,t.Pareto,t.StockingType
				 ,count(t.ItemNumber) as SKU_Count
				  ,sum(t.SOH_Qty) as SOH_qty_,sum(t.SOH_Val) as SOH_Val_
				  ,sum(t.PO_Qty) as PO_Qty_,sum(PO_Val) as PO_Val_
				  ,sum(t.Item_Qty_GrandTTL) as Item_Qty_GrandTTL_,sum(t.Item_Val_GrandTTL) as Item_Val_GrandTTL_

				  ,GETDATE() as ReportDate
				  ,cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE()),0),126),'-',''),1,8) as integer) as Rpt_YYMMDD	      --- 1st day of each month,so actually by month
				  ,cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE()),0),126),'-',''),1,6) as integer) as Rpt_YYMM	
				  ,cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE()),0),126),'-',''),1,4) as integer) as Rpt_YY
				  ,cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE()),0),126),'-',''),4,2) as integer) as Rpt_MM
				  ,day(getdate()) as Rpt_DayofMth

			   from t
		       group by t.FamilyGroup,t.Family_0,t.Pareto,t.StockingType
			  -- order by t.FamilyGroup desc
	      )

		  select * 
		  from _t 
		  order by _t.FamilyGroup desc,_t.Pareto


        --select * from t
		--insert into JDE_DB_Alan.FCPRO_Fcst_Pareto select t.ItemNumber,t.SellingGroup_,t.FamilyGroup_,t.Family_0,t.DataType1,t.rnk,t.Pareto,t.StockingType,t.ReportDate  from fltb t
		--select * from JDE_DB_Alan.FCPRO_Fcst_Pareto p order by p.Pareto,p.rnk desc
		

	


END
