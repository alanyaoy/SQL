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
/****** Object:  StoredProcedure [JDE_DB_Alan].[sp_Mismatch_Textile_RCCP_old]    Script Date: 18/03/2020 12:34:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/****** Object:  StoredProcedure [JDE_DB_Alan].[sp_FCPro_Portfolio_Analysis]    Script Date: 29/01/2018 9:17:10 AM ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [JDE_DB_Alan].[sp_Mismatch_Textile_RCCP_old] 
	-- Add the parameters for the stored procedure here
	--<@Param1, sysname, @p1> <Datatype_For_Param1, , int> = <Default_Value_For_Param1, , 0>, 
	--<@Param2, sysname, @p2> <Datatype_For_Param2, , int> = <Default_Value_For_Param2, , 0>

	 --- 17/5/2018 ---
	  @Item_id varchar(8000) = null
	 ,@Supplier_id varchar(8000) = null	 
	-- ,@DataType varchar (100) = null
	--,@ItemNumber varchar(100) = null
	--,@ShortItemNumber varchar(100) = null
	--,@CenturyYearMonth int = null
	--,@OrderByClause varchar(1000) = null
	--,@dt datetime  = DATEADD(mm, DATEDIFF(m,0,GETDATE())+5,0)			-- does not work
	  ,@dt datetime = null
	

	---******************************************************************************************************************---
	--- 1. Note that I did not switch this 'sp_Mismatch_Multi' to 'sp_Mismatch_Multi_V9' in my Application ( VBA or C# or Python ), because 
	--- 1) there are likely performance issue since in that sp, you are query against 'FC_Hist' table, you are looking at double qery time for a already complex query ( there are a lot of calculation involved already )
	--- 2) there are less chance to spot FC diffenece because result dataset in sp has a lot of data ie SOH,END SOH, FC Amt,WeekCover etc
	--- 3) you can use 'sp_Sales_FC' procedure to do Sales_FC Analysis if you want , 'sp_Mismatch_Multi' is mainly for simulation of supply
	--- 4) finally you need to set up 'Start_Saved_FC_Date'  and 'End_Saved_FC_Date' in your VBA becasue you already have @dt in your 'sp_Mismatch_Multi_V9' sp.
	---******************************************************************************************************************---
		
		 --- This Code use Mismatch report to calculate RCCP for Textile --- 5/12/2019
	       --- code is exact same as 'Mismatch ' Report --- It could cause some work for maintenance of code if you need to change code for 'Mismatch ' code report for SQL
		   --- But Reason to create this SP & give a different name to 'Mismatch' Report is it is used for 'RCCP' capacity planning not necessarily to identify Mismatch but capacity planning includes & use the Logic from 'Mismatch' code.   -- 22-01-2020 
		   --- So code is clean, not messy up with 'Mismatch ' report code

		 -----------  Add Open Sales Order Super Sales Inquiry ------------------ 21/10/2019
		 ------ Compare FC and Open SO and select which ever is greater in demand ----
		----- Need to change nonSim_Mismatch and Sim_Mismatch Code ----- For MI input code

AS
BEGIN
-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	--set @OrderByClause = 'rnk'	

-- Insert statements for procedure here
	--SELECT <@Param1, sysname, @p1>, <@Param2, sysname, @p2>	  




	  --- If SKU no is provided, dt is provided  ---
	 if @Item_id is not null and @Supplier_id is null and @dt is not null	
	 
	 	  
		  with  po as (    --select tb.ItemNumber,tb.DataType1,tb.PODate_,tb.poyr,tb.pomth,tb.BuyerName,tb.BuyerNumber,tb.TransactionOriginator,tb.TransactionOrigName,tb.SupplierName
						 select tb.ItemNumber,tb.DataType1,tb.PODate_,tb.poyr,tb.pomth,tb.SupplierName
							--,sum(tb.PO_Volume) as PO_Vol
							,sum(tb.QuantityOpen) as PO_Vol		--- 7/12/2018
					    from JDE_DB_Alan.vw_OpenPO tb
					 -- where tb.ItemNumber in  ( select splitdata from JDE_DB_Alan.dbo.fnSplitString(@Item_id,','))	
					  group by tb.ItemNumber,tb.DataType1,tb.PODate_,tb.poyr,tb.pomth,tb.SupplierName
					   --- 6/12/2018, cater for change Planner leaving business
					  )
				--select * from po

				----- Open SO from Super Sales Inquiry ------ 21/10/2019
				,_so as ( select s.Item_Number,s.Order_Number,s.LastStatus,s.NextStatus,s.Qty_Ordered_LowestLvl,s.YM_Req_c,s.Address_Number
				           from JDE_DB_Alan.vw_SO_Inquiry_Super s
						  -- where s.Item_Number in ('46.598.000')
						   )
                ,so as ( select s.Item_Number,s.YM_Req_c,sum(s.Qty_Ordered_LowestLvl) as OpenSO_Qty
				          from _so s
						  group by s.Item_Number,s.YM_Req_c
						  )  
                  --select * from so where so.OpenSO_Qty is null

				,tb as 
					(  select f.ItemNumber,f.Date,f.FCDate_,f.FC_Vol
					        ,isnull(s.OpenSO_Qty,0) as SO_Vol											--19/10/2019
							,isnull(f.FC_Vol,0) - ISNULL(s.OpenSO_Qty,0) as Diff_FC_SO					--19/10/2019
							,isnull(p.PO_Vol,0) PO_Vol
							--,isnull(m.QtyOnHand,0) SOH_Vol
							,isnull(m.QtyOnHand,0) as SOH_Begin_M
							 ,0 as SOH_Vol				 
							--, isnull(m.QtyOnHand,0) as SOH_End_M
							,0 as SOH_End_M
							,m.WholeSalePrice
							 
					 from JDE_DB_Alan.vw_FC f left join po p on f.ItemNumber = p.ItemNumber and f.FCDate_ = p.PODate_
					                          left join so s on f.ItemNumber = s.Item_Number and f.FCDate_ = s.YM_Req_c					  --19/10/2019			
											  left join JDE_DB_Alan.vw_Mast m on f.ItemNumber  = m.ItemNumber and f.FCDate_ = m.SOHDate   -- SOHDate is current month name,also note 'vw_Mast' is clearn without duplicated records
					 where f.Date< @dt
					-- where f.Date < '2020-03-02'
						  --and f.ItemNumber in ('46.598.000')
								 )
						
			  -- select * from tb  
			         
				  ,tb_ as (
							select tb.ItemNumber,tb.Date,tb.FCDate_,tb.FC_Vol,tb.PO_Vol,tb.SOH_Vol,tb.SO_Vol
									,case 
										   when tb.Date >DATEADD(mm, DATEDIFF(m,0,GETDATE()),0)  then
												case 
								                     when tb.Diff_FC_SO >=0 then (tb.PO_Vol -tb.FC_Vol)							-- if FC > SO        -- 21/10/2019
													 when tb.Diff_FC_SO <0 then  (tb.PO_Vol -tb.SO_Vol)							-- if FC < SO       -- need to validate if Fc already include SO  --- 21/10/2019
													 
													 end 
										   when tb.date = DATEADD(mm, DATEDIFF(m,0,GETDATE()),0) then
										         case
												     when tb.Diff_FC_SO >=0 then (tb.PO_Vol -tb.FC_Vol + tb.SOH_Begin_M)			-- if FC > SO      -- 21/10/2019
													 when tb.Diff_FC_SO <0 then  (tb.PO_Vol -tb.SO_Vol + tb.SOH_Begin_M)			-- if FC < SO       -- need to validate if Fc already include SO  --- 21/10/2019
													 end  

										   else tb.SOH_Vol
										end as  SOH_Vol_
								  -- ,(tb.PO_Vol -tb.FC_Vol) as SOH_Vol_
								   ,tb.SOH_Begin_M,tb.SOH_End_M
								   ,tb.WholeSalePrice					  
							from tb				
							)  
				 --select * from tb_				
				
						   --- running total preparation ---      
				  ,tbl as ( select *,
									row_number() over ( partition by tb_.ItemNumber order by tb_.FCDate_ ) as rnk 
								from tb_      
                
							)
							--- running total To get End period inventory ---
				 ,tbl_ as 
						(	select *
								  ,sum(tbl.SOH_Vol_) over (partition by tbl.ItemNumber order by tbl.rnk ) as SOH_End_M_
								from tbl
						 )
      
				 -- select * from tbl_
							--- Beginning period inventory preparation ---
				  ,stk_beg as
						  ( select tbl_.ItemNumber as myItemNumber,tbl_.Date as myDate
									,DATEADD(mm, DATEDIFF(m,0,tbl_.Date)+1,0) dte
									,tbl_.SOH_End_M_ as mySOH_Begin_M_
			            
							 from tbl_)
					   --select * from stk_beg

				 ,t as ( select *
								 from tbl_ left join stk_beg on tbl_.ItemNumber = stk_beg.myItemNumber and tbl_.Date = stk_beg.dte 
							  )
					--  select * from t
							  --- Get Begining period inventory ---
				 ,t_ as ( select t.ItemNumber,t.Date,t.FCDate_,t.FC_Vol,t.SO_Vol,t.PO_Vol,t.SOH_Vol,t.SOH_Vol_								--21/10/2019 add t.SO_Vol
									,case 
											when t.mySOH_Begin_M_ is null then t.SOH_Begin_M
											else t.mySOH_Begin_M_
									  end as  Final_SOH_Begin_M_
									,t.SOH_End_M_,t.rnk
									,t.WholeSalePrice
									--,t.myWSP
								 from t
								 )

					 -- select * from t_
					  -- ,pri as ( select t_.ItemNumber,t_.WholeSalePrice from t_ where t_.WholeSalePrice is not null)

					 --  select * from pri
					--   ,_t as ( select t_.*,																			-- cost too long time to run
								   --       case when t_.WholeSalePrice is null then pri.WholeSalePrice
											 --   else t_.WholeSalePrice
										  --  end as mywholesaleprice
									--from t_ left join pri on t_.ItemNumber = pri.ItemNumber )
          
				  ,_t as ( --select t_.ItemNumber,t_.Date,t_.FCDate_,t_.FC_Vol,t_.PO_Vol,t_.SOH_Vol,t_.SOH_Vol_,t_.Final_SOH_Begin_M_,t_.SOH_End_M_,m.WholeSalePrice     -- will spit out column by column saves the performance issue ? Not really  -- 14/5/2018
								select t_.*, mm.WholeSalePrice as Mywholesaleprice
										,(mm.WholeSalePrice * t_.FC_Vol) FC_Amt
										,(mm.StandardCost * t_.SOH_End_M_ ) as SOH_End_Amt
									   --, case when t_.Final_SOH_Begin_M_ <= 0  then 'Y 'else 'N' end as Stk_Out_Stauts
									   , case when t_.SOH_End_M_ <= 0  then 'Y 'else 'N' end as Stk_Out_Stauts				-- 6/9/2018
									   ,sum(t_.FC_Vol) over (partition by t_.ItemNumber order by t_.FCDate_ Rows between current row and 2 following ) as CumulativeTotal_FC_Vol_3M			-- only works in SQL 2012 upwards, if you using 2008 need to use below...  https://docs.microsoft.com/en-us/sql/t-sql/queries/select-over-clause-transact-sql?view=sql-server-2017
									   ,sum(t_.FC_Vol) over (partition by t_.ItemNumber order by t_.FCDate_ Rows between 1 following and 3 following ) as CumulativeTotal_FC_Vol_Nxt3M	
									   ,avg(t_.FC_Vol) over (partition by t_.ItemNumber) as Avg_FC_Vol_Nxt8M			--- SQL2008 support this 
									 --  ,mm.PlannerNumber
						 				,case mm.PlannerNumber 
											--when '20071' then 'Domenic Cellucci'		
												when '20072' then 'Salman Saeed'
												when '20004' then 'Margaret Dost'	
												when '20005' then 'Imelda Chan'
												when '20071' then 'Rosie Ashpole'
												when '20003' then 'Lee Rose'
												when '30036' then 'Violet Glodoveza'
												when '30039' then 'Ben'
												when '29917' then 'Metals Planner'
												when '20065' then 'AWF RollForming'
												when '2519718' then 'CutLength Planner'																					  
												else 'Unknown'
										end as Owner_
									   ,mm.PrimarySupplier,mm.Description,mm.FamilyGroup_,mm.Family_0,mm.PlannerNumber,mm.Leadtime_Mth,mm.UOM								   
								from t_ left join JDE_DB_Alan.vw_Mast mm on t_.ItemNumber = mm.ItemNumber )				-- note that 'vw_Mast ' has clean data 
		 
					   --select * from _t
						--where _t.ItemNumber in ('45.103.000','45.200.100','42.210.031') 
						 -- where _t.ItemNumber in ('0751031003001H')
						 --order by _t.ItemNumber,_t.Date		 

				 ,com as ( select _t.ItemNumber,_t.Date d1,_t.FCDate_ d2,'FC_Qty' as DataType,_t.FC_Vol as Value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.PlannerNumber,_t.Leadtime_Mth,_t.UOM from _t
							  union all
							    select _t.ItemNumber,_t.Date d1,_t.FCDate_ d2,'SO_Qty' as DataType,_t.SO_Vol as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.PlannerNumber,_t.Leadtime_Mth,_t.UOM from _t
							   union all
							   select _t.ItemNumber,_t.Date d1,_t.FCDate_ d2,'PO_Qty' as DataType,_t.PO_Vol as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.PlannerNumber,_t.Leadtime_Mth,_t.UOM from _t
							  union all
							   select _t.ItemNumber,_t.Date d1,_t.FCDate_ d2,'SOH_Qty' as DataType,_t.SOH_Vol_ as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.PlannerNumber,_t.Leadtime_Mth,_t.UOM from _t
							  union all
								select _t.ItemNumber,_t.Date d1,_t.FCDate_ d2,'Start_Stk' as DataType,_t.Final_SOH_Begin_M_ as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.PlannerNumber,_t.Leadtime_Mth,_t.UOM from _t
							  union all
								select _t.ItemNumber,_t.Date d1,_t.FCDate_ d2,'End_Stk' as DataType,_t.SOH_End_M_ as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.PlannerNumber,_t.Leadtime_Mth,_t.UOM from _t
							  union all
								select _t.ItemNumber,_t.Date d1,_t.FCDate_ d2,'FC_Amt' as DataType,_t.FC_Amt as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.PlannerNumber,_t.Leadtime_Mth,_t.UOM from _t	
							  union all
								select _t.ItemNumber,_t.Date d1,_t.FCDate_ d2,'End_Stk_Amt' as DataType,_t.SOH_End_Amt as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.PlannerNumber,_t.Leadtime_Mth,_t.UOM from _t				   				   
                              union all
								select _t.ItemNumber,_t.Date d1,_t.FCDate_ d2,'Weeks_Cover1' as DataType,coalesce(_t.SOH_End_M_/nullif(_t.CumulativeTotal_FC_Vol_Nxt3M/12*4.33,0),0) as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.PlannerNumber,_t.Leadtime_Mth,_t.UOM from _t				  
							--  union all
							--	select _t.ItemNumber,_t.Date d1,_t.FCDate_ d2,'Weeks_Cover2' as DataType,(_t.SOH_End_M_)/(_t.Avg_FC_Vol_Nxt8M/4) as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0 from _t				  							  						  	 
							   )
                  -- select * from com
				 select com.ItemNumber,com.d1,com.d2,com.DataType,com.value,com.Stk_Out_Stauts,com.Owner_,com.PrimarySupplier,com.Leadtime_Mth,com.PlannerNumber,com.Description
				        ,com.UOM,t.WorkCenter,right(t.WorkCenterName,7) as WC_Name
				        ,getdate() as ThisReportDate
				  from com inner join JDE_DB_Alan.TextileWC t on com.ItemNumber = t.ItemNumber
				 --where com.Stk_Out_Stauts in ('Y')
				 --where com.ItemNumber in ('46.598.000')
				 -- where com.PrimarySupplier in ('20037','1102')
				  -- where com.PrimarySupplier in ( select splitdata from JDE_DB_Alan.dbo.fnSplitString(@Supplier_id,','))
                  -- where com.ItemNumber in ( select splitdata from JDE_DB_Alan.dbo.fnSplitString(@Item_id,','))
					 where com.ItemNumber in ( select * from string_split(@Item_id,','))									----- 17/1/2020
				    --  where com.ItemNumber in ( select data from dbo.udf_SplitByXml(@Item_id,','))									----- 17/1/2020
				    --  where com.ItemNumber in ( select distinct t.ItemNumber from JDE_DB_Alan.TextileWC t )				---22/1/2020
				  order by com.ItemNumber,com.DataType,com.d2 	

   
    --- if not SKU number is provided, then choose all SKUs from 'JDE_DB_Alan.TextileWC  ' table 
   else if @Item_id is null and @Supplier_id is null and @dt is not null	
	 
	  begin	
		  
		  with  po as (    --select tb.ItemNumber,tb.DataType1,tb.PODate_,tb.poyr,tb.pomth,tb.BuyerName,tb.BuyerNumber,tb.TransactionOriginator,tb.TransactionOrigName,tb.SupplierName
						 select tb.ItemNumber,tb.DataType1,tb.PODate_,tb.poyr,tb.pomth,tb.SupplierName
							--,sum(tb.PO_Volume) as PO_Vol
							,sum(tb.QuantityOpen) as PO_Vol		--- 7/12/2018
					    from JDE_DB_Alan.vw_OpenPO tb
					 -- where tb.ItemNumber in  ( select splitdata from JDE_DB_Alan.dbo.fnSplitString(@Item_id,','))	
					  group by tb.ItemNumber,tb.DataType1,tb.PODate_,tb.poyr,tb.pomth,tb.SupplierName
					   --- 6/12/2018, cater for change Planner leaving business
					  )
				--select * from po

				----- Open SO from Super Sales Inquiry ------ 21/10/2019
				,_so as ( select s.Item_Number,s.Order_Number,s.LastStatus,s.NextStatus,s.Qty_Ordered_LowestLvl,s.YM_Req_c,s.Address_Number
				           from JDE_DB_Alan.vw_SO_Inquiry_Super s
						  -- where s.Item_Number in ('46.598.000')
						   )
                ,so as ( select s.Item_Number,s.YM_Req_c,sum(s.Qty_Ordered_LowestLvl) as OpenSO_Qty
				          from _so s
						  group by s.Item_Number,s.YM_Req_c
						  )  
                  --select * from so where so.OpenSO_Qty is null

				,tb as 
					(  select f.ItemNumber,f.Date,f.FCDate_,f.FC_Vol
					        ,isnull(s.OpenSO_Qty,0) as SO_Vol											--19/10/2019
							,isnull(f.FC_Vol,0) - ISNULL(s.OpenSO_Qty,0) as Diff_FC_SO					--19/10/2019
							,isnull(p.PO_Vol,0) PO_Vol
							--,isnull(m.QtyOnHand,0) SOH_Vol
							,isnull(m.QtyOnHand,0) as SOH_Begin_M
							 ,0 as SOH_Vol				 
							--, isnull(m.QtyOnHand,0) as SOH_End_M
							,0 as SOH_End_M
							,m.WholeSalePrice
							 
					 from JDE_DB_Alan.vw_FC f left join po p on f.ItemNumber = p.ItemNumber and f.FCDate_ = p.PODate_
					                          left join so s on f.ItemNumber = s.Item_Number and f.FCDate_ = s.YM_Req_c					  --19/10/2019			
											  left join JDE_DB_Alan.vw_Mast m on f.ItemNumber  = m.ItemNumber and f.FCDate_ = m.SOHDate   -- SOHDate is current month name,also note 'vw_Mast' is clearn without duplicated records
					 where f.Date< @dt
					-- where f.Date < '2020-03-02'
						  --and f.ItemNumber in ('46.598.000')
								 )
						
			  -- select * from tb  
			         
				  ,tb_ as (
							select tb.ItemNumber,tb.Date,tb.FCDate_,tb.FC_Vol,tb.PO_Vol,tb.SOH_Vol,tb.SO_Vol
									,case 
										   when tb.Date >DATEADD(mm, DATEDIFF(m,0,GETDATE()),0)  then
												case 
								                     when tb.Diff_FC_SO >=0 then (tb.PO_Vol -tb.FC_Vol)							-- if FC > SO        -- 21/10/2019
													 when tb.Diff_FC_SO <0 then  (tb.PO_Vol -tb.SO_Vol)							-- if FC < SO       -- need to validate if Fc already include SO  --- 21/10/2019
													 
													 end 
										   when tb.date = DATEADD(mm, DATEDIFF(m,0,GETDATE()),0) then
										         case
												     when tb.Diff_FC_SO >=0 then (tb.PO_Vol -tb.FC_Vol + tb.SOH_Begin_M)			-- if FC > SO      -- 21/10/2019
													 when tb.Diff_FC_SO <0 then  (tb.PO_Vol -tb.SO_Vol + tb.SOH_Begin_M)			-- if FC < SO       -- need to validate if Fc already include SO  --- 21/10/2019
													 end  

										   else tb.SOH_Vol
										end as  SOH_Vol_
								  -- ,(tb.PO_Vol -tb.FC_Vol) as SOH_Vol_
								   ,tb.SOH_Begin_M,tb.SOH_End_M
								   ,tb.WholeSalePrice					  
							from tb				
							)  
				 --select * from tb_				
				
						   --- running total preparation ---      
				  ,tbl as ( select *,
									row_number() over ( partition by tb_.ItemNumber order by tb_.FCDate_ ) as rnk 
								from tb_      
                
							)
							--- running total To get End period inventory ---
				 ,tbl_ as 
						(	select *
								  ,sum(tbl.SOH_Vol_) over (partition by tbl.ItemNumber order by tbl.rnk ) as SOH_End_M_
								from tbl
						 )
      
				 -- select * from tbl_
							--- Beginning period inventory preparation ---
				  ,stk_beg as
						  ( select tbl_.ItemNumber as myItemNumber,tbl_.Date as myDate
									,DATEADD(mm, DATEDIFF(m,0,tbl_.Date)+1,0) dte
									,tbl_.SOH_End_M_ as mySOH_Begin_M_
			            
							 from tbl_)
					   --select * from stk_beg

				 ,t as ( select *
								 from tbl_ left join stk_beg on tbl_.ItemNumber = stk_beg.myItemNumber and tbl_.Date = stk_beg.dte 
							  )
					--  select * from t
							  --- Get Begining period inventory ---
				 ,t_ as ( select t.ItemNumber,t.Date,t.FCDate_,t.FC_Vol,t.SO_Vol,t.PO_Vol,t.SOH_Vol,t.SOH_Vol_								--21/10/2019 add t.SO_Vol
									,case 
											when t.mySOH_Begin_M_ is null then t.SOH_Begin_M
											else t.mySOH_Begin_M_
									  end as  Final_SOH_Begin_M_
									,t.SOH_End_M_,t.rnk
									,t.WholeSalePrice
									--,t.myWSP
								 from t
								 )

					 -- select * from t_
					  -- ,pri as ( select t_.ItemNumber,t_.WholeSalePrice from t_ where t_.WholeSalePrice is not null)

					 --  select * from pri
					--   ,_t as ( select t_.*,																			-- cost too long time to run
								   --       case when t_.WholeSalePrice is null then pri.WholeSalePrice
											 --   else t_.WholeSalePrice
										  --  end as mywholesaleprice
									--from t_ left join pri on t_.ItemNumber = pri.ItemNumber )
          
				  ,_t as ( --select t_.ItemNumber,t_.Date,t_.FCDate_,t_.FC_Vol,t_.PO_Vol,t_.SOH_Vol,t_.SOH_Vol_,t_.Final_SOH_Begin_M_,t_.SOH_End_M_,m.WholeSalePrice     -- will spit out column by column saves the performance issue ? Not really  -- 14/5/2018
								select t_.*, mm.WholeSalePrice as Mywholesaleprice
										,(mm.WholeSalePrice * t_.FC_Vol) FC_Amt
										,(mm.StandardCost * t_.SOH_End_M_ ) as SOH_End_Amt
									   --, case when t_.Final_SOH_Begin_M_ <= 0  then 'Y 'else 'N' end as Stk_Out_Stauts
									   , case when t_.SOH_End_M_ <= 0  then 'Y 'else 'N' end as Stk_Out_Stauts				-- 6/9/2018
									   ,sum(t_.FC_Vol) over (partition by t_.ItemNumber order by t_.FCDate_ Rows between current row and 2 following ) as CumulativeTotal_FC_Vol_3M			-- only works in SQL 2012 upwards, if you using 2008 need to use below...  https://docs.microsoft.com/en-us/sql/t-sql/queries/select-over-clause-transact-sql?view=sql-server-2017
									   ,sum(t_.FC_Vol) over (partition by t_.ItemNumber order by t_.FCDate_ Rows between 1 following and 3 following ) as CumulativeTotal_FC_Vol_Nxt3M	
									   ,avg(t_.FC_Vol) over (partition by t_.ItemNumber) as Avg_FC_Vol_Nxt8M			--- SQL2008 support this 
									 --  ,mm.PlannerNumber
						 				,case mm.PlannerNumber 
											--when '20071' then 'Domenic Cellucci'		
												when '20072' then 'Salman Saeed'
												when '20004' then 'Margaret Dost'	
												when '20005' then 'Imelda Chan'
												when '20071' then 'Rosie Ashpole'
												when '20003' then 'Lee Rose'
												when '30036' then 'Violet Glodoveza'
												when '30039' then 'Ben'
												when '29917' then 'Metals Planner'
												when '20065' then 'AWF RollForming'
												when '2519718' then 'CutLength Planner'																					  
												else 'Unknown'
										end as Owner_
									   ,mm.PrimarySupplier,mm.Description,mm.FamilyGroup_,mm.Family_0,mm.PlannerNumber,mm.Leadtime_Mth,mm.UOM								   
								from t_ left join JDE_DB_Alan.vw_Mast mm on t_.ItemNumber = mm.ItemNumber )				-- note that 'vw_Mast ' has clean data 
		 
					   --select * from _t
						--where _t.ItemNumber in ('45.103.000','45.200.100','42.210.031') 
						 -- where _t.ItemNumber in ('0751031003001H')
						 --order by _t.ItemNumber,_t.Date		 

				 ,com as ( select _t.ItemNumber,_t.Date d1,_t.FCDate_ d2,'FC_Qty' as DataType,_t.FC_Vol as Value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.PlannerNumber,_t.Leadtime_Mth,_t.UOM from _t
							  union all
							    select _t.ItemNumber,_t.Date d1,_t.FCDate_ d2,'SO_Qty' as DataType,_t.SO_Vol as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.PlannerNumber,_t.Leadtime_Mth,_t.UOM from _t
							   union all
							   select _t.ItemNumber,_t.Date d1,_t.FCDate_ d2,'PO_Qty' as DataType,_t.PO_Vol as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.PlannerNumber,_t.Leadtime_Mth,_t.UOM from _t
							  union all
							   select _t.ItemNumber,_t.Date d1,_t.FCDate_ d2,'SOH_Qty' as DataType,_t.SOH_Vol_ as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.PlannerNumber,_t.Leadtime_Mth,_t.UOM from _t
							  union all
								select _t.ItemNumber,_t.Date d1,_t.FCDate_ d2,'Start_Stk' as DataType,_t.Final_SOH_Begin_M_ as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.PlannerNumber,_t.Leadtime_Mth,_t.UOM from _t
							  union all
								select _t.ItemNumber,_t.Date d1,_t.FCDate_ d2,'End_Stk' as DataType,_t.SOH_End_M_ as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.PlannerNumber,_t.Leadtime_Mth,_t.UOM from _t
							  union all
								select _t.ItemNumber,_t.Date d1,_t.FCDate_ d2,'FC_Amt' as DataType,_t.FC_Amt as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.PlannerNumber,_t.Leadtime_Mth,_t.UOM from _t	
							  union all
								select _t.ItemNumber,_t.Date d1,_t.FCDate_ d2,'End_Stk_Amt' as DataType,_t.SOH_End_Amt as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.PlannerNumber,_t.Leadtime_Mth,_t.UOM from _t				   				   
                              union all
								select _t.ItemNumber,_t.Date d1,_t.FCDate_ d2,'Weeks_Cover1' as DataType,coalesce(_t.SOH_End_M_/nullif(_t.CumulativeTotal_FC_Vol_Nxt3M/12*4.33,0),0) as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.PlannerNumber,_t.Leadtime_Mth,_t.UOM from _t				  
							--  union all
							--	select _t.ItemNumber,_t.Date d1,_t.FCDate_ d2,'Weeks_Cover2' as DataType,(_t.SOH_End_M_)/(_t.Avg_FC_Vol_Nxt8M/4) as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0 from _t				  							  						  	 
							   )
                  -- select * from com
				 select com.ItemNumber,com.d1,com.d2,com.DataType,com.value,com.Stk_Out_Stauts,com.Owner_,com.PrimarySupplier,com.Leadtime_Mth,com.PlannerNumber,com.Description
				        ,com.UOM,t.WorkCenter,right(t.WorkCenterName,7) as WC_Name  
				        ,getdate() as ThisReportDate
				  from com inner join JDE_DB_Alan.TextileWC t on com.ItemNumber = t.ItemNumber
				 --where com.Stk_Out_Stauts in ('Y')
				 --where com.ItemNumber in ('46.598.000')
				 -- where com.PrimarySupplier in ('20037','1102')
				  -- where com.PrimarySupplier in ( select splitdata from JDE_DB_Alan.dbo.fnSplitString(@Supplier_id,','))
                  -- where com.ItemNumber in ( select splitdata from JDE_DB_Alan.dbo.fnSplitString(@Item_id,','))
				  -- where com.ItemNumber in ( select * from string_split(@Item_id,','))									----- 17/1/2020
				    --  where com.ItemNumber in ( select data from dbo.udf_SplitByXml(@Item_id,','))									----- 17/1/2020
				    --  where com.ItemNumber in ( select distinct t.ItemNumber from JDE_DB_Alan.TextileWC t )				---22/1/2020
				  order by com.ItemNumber,com.DataType,com.d2 	

         end
  

END
