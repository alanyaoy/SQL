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

/****** Object:  StoredProcedure [JDE_DB_Alan].[sp_Mismatch_HD_RCCP]    Script Date: 18/06/2021 2:10:00 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [JDE_DB_Alan].[sp_Mismatch_HD_RCCP_test] 
 --CREATE PROCEDURE [JDE_DB_Alan].[sp_Mismatch_Textile_RCCP] 

	-- Add the parameters for the stored procedure here
	--<@Param1, sysname, @p1> <Datatype_For_Param1, , int> = <Default_Value_For_Param1, , 0>, 
	--<@Param2, sysname, @p2> <Datatype_For_Param2, , int> = <Default_Value_For_Param2, , 0>

	 --- 17/5/2018 ---


	-- ,@Supplier_id varchar(8000) = null	 
	-- ,@DataType varchar (100) = null
	--,@ItemNumber varchar(100) = null
	--,@ShortItemNumber varchar(100) = null
	--,@CenturyYearMonth int = null
	--,@OrderByClause varchar(1000) = null
	--,@dt datetime  = DATEADD(mm, DATEDIFF(m,0,GETDATE())+5,0)			-- does not work
	  
	  @WCGRP_id varchar(8000) = null	
	  ,@dt datetime = null
	    ,@Item_id varchar(8000) = null

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


			  	-------- Textile RCCP ---------			5/12/2019  -- updated 18/2/2020
		--- updated 27/2/2020 to include 'Stocking Type ' as per Nic/Lee Rose's request ---
		--- Updated 21/5/2021 to Remove/Prevent duplicate in HD (Textile) Work Center --------

				
		  ------ HD Work Center ---- 25/5/2021
		------ Note you can choose to fetch Textile/Metal RCCP items from 'vw_Master' table; or from 'HD_WorkCenter' table - just be careful when choosing from 'HD_WorkCenter' table, use proper filter because 1 SKU could point to 2 different WC --- 25/5/2021
		--- Acutally I have created a Staging table 'HD_WorkCenter_Staging'  for Raw data of HD Work Centers; then created 'HD_WorkCenter' table for 1 SKU point to 1 Work Center or 1 'Combined' Work Center if there are multiple WC involved for 1 SKU, as result there will be no issues when join table for duplications


	--select distinct f.ItemNumber from JDE_DB_Alan.vw_FC f where f.DataType1 in ('Adj_FC')
	--select * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h where h.ItemNumber in ('42.210.031')


AS
BEGIN
-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	--set @OrderByClause = 'rnk'	

-- Insert statements for procedure here
	--SELECT <@Param1, sysname, @p1>, <@Param2, sysname, @p2>	  


	 DECLARE @WCGRP_id_loc varchar(8000)
	 DECLARE @dt_loc datetime
	 declare @Item_id_loc varchar(8000)

     SET @WCGRP_id_loc = @WCGRP_id
	 SET @dt_loc = @dt
	 SET @Item_id = @Item_id_loc



	 --- if WCGRP_ID (1) is provided - Textile , SKU number is not provided, then choose certain SKUs table 	  
 	if @WCGRP_id_loc ='GRP_1' and @dt_loc is not null and @Item_id_loc is null
	    	

         ------ First Get your clean/valid Textile item -------

			--- All HD WC (Textile/Metal ) SKUs ---- From Master file
	    with  _hdwcitm as ( select m.ItemNumber,m.WCCode_fl,m.WCGroupName_fl,m.StockingType,m.Description
	                            ,'TBC' as Sls_Status	                            	
	                            ,count(m.Description )over() as Total_Count_Textile_Items_With_WC
	                     from JDE_DB_Alan.vw_Mast m
						 where m.WCGroupCode_fl <>'0' 						       
						 --order by m.WC
						 )
			
			--- Obsolete Items ----	113 item -- this is just for testing purpose,in ' _txlitm ' table it already include 'O','U' items for textile
             ,Obsl_hdwcitm  as ( select m.ItemNumber,m.Description,m.WCCode_fl,m.WCGroupName_fl,m.StockingType
	                                   ,count(m.Description)over() as Item_Count
								 from JDE_DB_Alan.vw_Mast m 
	                             where m.StockingType in ('O','U')
								       and m.WCGroupCode_fl <> '0'
								 )   

            --- Items with either 0 sales or Null sales over last 12 months ----   205 Items
            ,Null_hdwcitm as (  select nil.ItemNumber,'Nil_Sls_Y' as Nil_Status
			                   from  
									 (select a.ItemNumber from _hdwcitm a except select h.ItemNumber_ from JDE_DB_Alan.vw_Sls_History_HD h )        
								 as nil

                               ) 
			--select * from Obsl_txlitm
			--select * from Null_txlitm

			  ----- Full HD WC (Textile/Metal ) SKU list with details ----- You can use this list for SKU Analysis, FOR RCCP reporting purose, u might not need this full list, just active item list .
			,hdwcitm_ as ( select a.ItemNumber,a.WCCode_fl,a.WCGroupName_fl,a.StockingType
								 ,case 
								     when ni.Nil_Status = 'Nil_Sls_Y' then ni.Nil_Status
									 when ni.Nil_Status is null then 'Nil_Sls_N'
                                 end as Sls_Status_
                                ,a.Description
                                ,count(a.Description)over() as Itm_Count
			               from  _hdwcitm a left join Null_hdwcitm ni on a.ItemNumber = ni.ItemNumber )
			  
			  --  select * from txtitm_ t where t.ItemNumber in ('82.201.950') 		   
			  --  where t.StockingType not in ('O','U') and t.Sls_Status_ in ('Nil_Sls_Y')

			 
			 ----- Your final list of clean HD WC (Textile/Metal) Items ( Active item & with Sales ) ---------- only 533 SKUs Vs 738 SKUs
			 ,hdwcitm as ( select t.*,m.FamilyGroup,FamilyGroup_,m.Family,m.Family_0
			                from hdwcitm_ t left join JDE_DB_Alan.vw_Mast m on t.ItemNumber = m.ItemNumber
							where t.StockingType not in ('O','U') and t.Sls_Status_ in ('Nil_Sls_N')

			             )
             --  select * from txtitm
				

			---- Below is not good as you actually not group PO by month if you add supplierName or oOrder number! --- 14/5/2020
			--with po as (
						-- select tb.ItemNumber,tb.DataType1,tb.PODate_,tb.poyr,tb.pomth,tb.BuyerName,tb.BuyerNumber,tb.TransactionOriginator,tb.TransactionOrigName,tb.SupplierName
						 --select tb.ItemNumber,tb.DataType1,tb.PODate_,tb.poyr,tb.pomth,tb.SupplierName							
							--	,sum(tb.QuantityOpen) as PO_Vol				---7/12/2018
						--	from JDE_DB_Alan.vw_OpenPO tb						
						  --  where tb.ItemNumber in ('24.7002.0001')
						 -- group by tb.ItemNumber,tb.DataType1,tb.PODate_,tb.poyr,tb.pomth,tb.SupplierName
						
					 -- )					

			,po as (
						-- select tb.ItemNumber,tb.DataType1,tb.PODate_,tb.poyr,tb.pomth,tb.BuyerName,tb.BuyerNumber,tb.TransactionOriginator,tb.TransactionOrigName,tb.SupplierName
						 select tb.ItemNumber,tb.DataType1,tb.PODate_,tb.poyr,tb.pomth					--- 14/5/2020
								--,sum(tb.PO_Volume) as PO_Vol
								,sum(tb.QuantityOpen) as PO_Vol				---7/12/2018
							from JDE_DB_Alan.vw_OpenPO tb
						 -- where tb.ItemNumber in  ( select splitdata from JDE_DB_Alan.dbo.fnSplitString(@Item_id,','))	
						  --  where tb.ItemNumber in ('24.7002.0001')
						  group by tb.ItemNumber,tb.DataType1,tb.PODate_,tb.poyr,tb.pomth
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


				
				------- FC for Textile --- Need to isolate Vertical Fabric ( 981 ) And Apply % --- 5/12/2019
			
				------- This table will filter out any Obsolete item, active item but no sales over past 12 month hence no need to allocate capactity ( only forecastable item )---
				------- How to get those items mentioned above ??------

                ,fc as ( select --distinct m.ItemNumber
								t.ItemNumber,f.FCDate2_,f.DataType1,t.StockingType,f.FCDate_,f.Date
								,f.FC_Vol
								 ,t.FamilyGroup,t.Family
								 					
							from  hdwcitm t left join JDE_DB_Alan.vw_FC f on f.ItemNumber = t.ItemNumber
							where  f.DataType1 in ('ADJ_FC')
							        and  t.StockingType not in ('O','U','Z')
								    -- mm.StockingType in ('K','W','X','S','F','P','Q','Z','C','M','0','I')			   -- this could be best to avoid issue of returning empty dataSet due to Null value --- 23/7/2018									     
								  --and f.FCDate2_ in ('201912')
							)
                     
				-- select * from fc 
				-- where fc.ItemNumber in ('82.201.901','82.109.921','82.011.937')							--- '82.201.901' active WC item 'S'; '82.109.921' WC item but obsolete;'82.011.937' Active WC item 'S' but within '981' Vertical familyGP
						--and fc.FCDate2_ in ('201912')		

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
							 
					-- from JDE_DB_Alan.vw_FC f left join po p on f.ItemNumber = p.ItemNumber and f.FCDate_ = p.PODate_
					   from fc f left join po p on f.ItemNumber = p.ItemNumber and f.FCDate_ = p.PODate_
					                          left join so s on f.ItemNumber = s.Item_Number and f.FCDate_ = s.YM_Req_c					  --19/10/2019			
											  left join JDE_DB_Alan.vw_Mast m on f.ItemNumber  = m.ItemNumber and f.FCDate_ = m.SOHDate   -- SOHDate is current month name,also note 'vw_Mast' is clearn without duplicated records
					 where f.Date< @dt
					-- where f.Date < '2022-03-02'
					--where f.Date < '2021-01-02'
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
									   ,mm.PrimarySupplier,mm.Description,mm.FamilyGroup_,mm.FamilyGroup,mm.Family_0,mm.Family,mm.PlannerNumber,mm.Leadtime_Mth,mm.UOM								   
								from t_ left join JDE_DB_Alan.vw_Mast mm on t_.ItemNumber = mm.ItemNumber )				-- note that 'vw_Mast ' has clean data 
		 
					   --select * from _t
						--where _t.ItemNumber in ('45.103.000','45.200.100','42.210.031') 
						 -- where _t.ItemNumber in ('0751031003001H')
						 --order by _t.ItemNumber,_t.Date		 

				,com_1 as ( select _t.ItemNumber,_t.Date d1,_t.FCDate_ d2,'FC_Qty' as DataType,_t.FC_Vol as Value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.PlannerNumber,_t.Leadtime_Mth,_t.UOM from _t
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
							select _t.ItemNumber,_t.Date d1,_t.FCDate_ d2,'Weeks_Cover1' as DataType,coalesce(_t.SOH_End_M_/nullif(_t.CumulativeTotal_FC_Vol_Nxt3M/12,0),0) as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.PlannerNumber,_t.Leadtime_Mth,_t.UOM from _t				  
						--  union all
						--	select _t.ItemNumber,_t.Date d1,_t.FCDate_ d2,'Weeks_Cover2' as DataType,(_t.SOH_End_M_)/(_t.Avg_FC_Vol_Nxt8M/4) as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0 from _t				  							  						  	 
							)
                -- select * from com
			,c1 as ( select c.ItemNumber,c.d1,c.d2,c.DataType,c.value,c.Stk_Out_Stauts,c.Owner_,c.PrimarySupplier,c.Leadtime_Mth,c.PlannerNumber,c.Description
				    ,c.UOM    
				    ,getdate() as ThisReportDate
			    	from com_1 as c
				--where com.Stk_Out_Stauts in ('Y')
			-- where com.ItemNumber in ('46.598.000')
				-- where com.PrimarySupplier in ('20037','1102')
				-- where com.PrimarySupplier in ( select splitdata from JDE_DB_Alan.dbo.fnSplitString(@Supplier_id,','))
                --  where com.ItemNumber in ( select splitdata from JDE_DB_Alan.dbo.fnSplitString(@Item_id,','))
				--order by c.ItemNumber,c.DataType,c.d2 	
				)
              
			--select * from c1

		,com_2 as ( select _t.ItemNumber,_t.Date d1,_t.FCDate_ d2,'FC_Qty' as DataType,case when _t.FamilyGroup in ('981') then _t.FC_Vol/25 else _t.FC_Vol end as Value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.PlannerNumber,_t.Leadtime_Mth,_t.UOM from _t
							union all
							select _t.ItemNumber,_t.Date d1,_t.FCDate_ d2,'SO_Qty' as DataType,case when _t.FamilyGroup in ('981') then _t.SO_Vol/25 else _t.SO_Vol end as Value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.PlannerNumber,_t.Leadtime_Mth,_t.UOM from _t
							union all
							select _t.ItemNumber,_t.Date d1,_t.FCDate_ d2,'PO_Qty' as DataType,case when _t.FamilyGroup in ('981') then _t.PO_Vol/25 else _t.PO_Vol end as Value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.PlannerNumber,_t.Leadtime_Mth,_t.UOM from _t
							union all
							select _t.ItemNumber,_t.Date d1,_t.FCDate_ d2,'SOH_Qty' as DataType,case when _t.FamilyGroup in ('981') then _t.SOH_Vol_/25 else _t.SOH_Vol_ end as Value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.PlannerNumber,_t.Leadtime_Mth,_t.UOM from _t
							union all
							select _t.ItemNumber,_t.Date d1,_t.FCDate_ d2,'Start_Stk' as DataType,case when _t.FamilyGroup in ('981') then _t.Final_SOH_Begin_M_/25 else _t.Final_SOH_Begin_M_ end as Value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.PlannerNumber,_t.Leadtime_Mth,_t.UOM from _t
							union all
							select _t.ItemNumber,_t.Date d1,_t.FCDate_ d2,'End_Stk' as DataType,case when _t.FamilyGroup in ('981') then _t.SOH_End_M_/25 else _t.SOH_End_M_ end as Value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.PlannerNumber,_t.Leadtime_Mth,_t.UOM from _t
							union all
							select _t.ItemNumber,_t.Date d1,_t.FCDate_ d2,'FC_Amt' as DataType,_t.FC_Amt as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.PlannerNumber,_t.Leadtime_Mth,_t.UOM from _t	
							union all
							select _t.ItemNumber,_t.Date d1,_t.FCDate_ d2,'End_Stk_Amt' as DataType,_t.SOH_End_Amt as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.PlannerNumber,_t.Leadtime_Mth,_t.UOM from _t				   				   
                            union all
							select _t.ItemNumber,_t.Date d1,_t.FCDate_ d2,'Weeks_Cover1' as DataType,coalesce(_t.SOH_End_M_/nullif(_t.CumulativeTotal_FC_Vol_Nxt3M/12,0),0) as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.PlannerNumber,_t.Leadtime_Mth,_t.UOM from _t				  
						--  union all
						--	select _t.ItemNumber,_t.Date d1,_t.FCDate_ d2,'Weeks_Cover2' as DataType,(_t.SOH_End_M_)/(_t.Avg_FC_Vol_Nxt8M/4) as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0 from _t				  							  						  	 
							)
                -- select * from com
		,c2 as ( select c.ItemNumber,c.d1,c.d2,c.DataType,c.value,c.Stk_Out_Stauts,c.Owner_,c.PrimarySupplier,c.Leadtime_Mth,c.PlannerNumber,c.Description
				        ,c.UOM    				        
				  from com_2 as c
				 --where com.Stk_Out_Stauts in ('Y')
				-- where com.ItemNumber in ('46.598.000')
				 -- where com.PrimarySupplier in ('20037','1102')
				  -- where com.PrimarySupplier in ( select splitdata from JDE_DB_Alan.dbo.fnSplitString(@Supplier_id,','))
                 --  where com.ItemNumber in ( select splitdata from JDE_DB_Alan.dbo.fnSplitString(@Item_id,','))
				  --order by c.ItemNumber,c.DataType,c.d2 					 
				   )

              --  select distinct c2.ItemNumber from c2
              
		,z as (  select c2.*
					  ,m.WCCode_fl
					  ,case 
						  when m.WCCode_fl like ('%45004%') then 'Monfort'
						  when m.WCCode_fl like ('%45005%') then 'Babcock'
					   end as WCCode_fl_
                       ,m.WCGroupCode_fl,m.WCGroupName_fl
					   ,m.StockingType
					   
			          ,getdate() as ThisReportDate

					  from c2 left join JDE_DB_Alan.vw_Mast m on c2.ItemNumber = m.ItemNumber
					
					-- where fc.ItemNumber in ('82.201.901','82.109.921','82.011.937')							--- '82.201.901' active WC item 'S'; '82.109.921' WC item but obsolete;'82.011.937' Active WC item 'S' but within '981' Vertical familyGP
                  )

			select * 
			--select distinct z.ItemNumber
			from z	
			where z.WCGroupName_fl like ('%Textile%')  
			   --  and z.ItemNumber in ('82.028.901') 	  
          -- where z.ItemNumber in ( select splitdata from JDE_DB_Alan.dbo.fnSplitString(@Item_id,','))



      --- if WCGRP_ID (2) is provided --- Metal, SKU number is not provided, then choose certain SKUs table 	  
	if @WCGRP_id_loc ='GRP_2' and @dt_loc is not null and @Item_id_loc is null	 
	 
	   begin	
		  
		  --- First Get your clean/valid Textile item -------

						--- All HD WC (Textile/Metal ) SKUs ---- From Master file
				   with  _hdwcitm as ( select m.ItemNumber,m.WCCode_fl,m.WCGroupName_fl,m.StockingType,m.Description
											,'TBC' as Sls_Status	                            	
											,count(m.Description )over() as Total_Count_Textile_Items_With_WC
									 from JDE_DB_Alan.vw_Mast m
									 where m.WCGroupCode_fl <>'0' 						       
									 --order by m.WC
									 )
			
						--- Obsolete Items ----	113 item -- this is just for testing purpose,in ' _txlitm ' table it already include 'O','U' items for textile
						 ,Obsl_hdwcitm  as ( select m.ItemNumber,m.Description,m.WCCode_fl,m.WCGroupName_fl,m.StockingType
												   ,count(m.Description)over() as Item_Count
											 from JDE_DB_Alan.vw_Mast m 
											 where m.StockingType in ('O','U')
												   and m.WCGroupCode_fl <> '0'
											 )   

						--- Items with either 0 sales or Null sales over last 12 months ----   205 Items
						,Null_hdwcitm as (  select nil.ItemNumber,'Nil_Sls_Y' as Nil_Status
										   from  
												 (select a.ItemNumber from _hdwcitm a except select h.ItemNumber_ from JDE_DB_Alan.vw_Sls_History_HD h )        
											 as nil

										   ) 
						--select * from Obsl_txlitm
						--select * from Null_txlitm

						  ----- Full HD WC (Textile/Metal ) SKU list with details ----- You can use this list for SKU Analysis, FOR RCCP reporting purose, u might not need this full list, just active item list .
						,hdwcitm_ as ( select a.ItemNumber,a.WCCode_fl,a.WCGroupName_fl,a.StockingType
											 ,case 
												 when ni.Nil_Status = 'Nil_Sls_Y' then ni.Nil_Status
												 when ni.Nil_Status is null then 'Nil_Sls_N'
											 end as Sls_Status_
											,a.Description
											,count(a.Description)over() as Itm_Count
									   from  _hdwcitm a left join Null_hdwcitm ni on a.ItemNumber = ni.ItemNumber )
			  
						  --  select * from txtitm_ t where t.ItemNumber in ('82.201.950') 		   
						  --  where t.StockingType not in ('O','U') and t.Sls_Status_ in ('Nil_Sls_Y')

			 
						 ----- Your final list of clean HD WC (Textile/Metal) Items ( Active item & with Sales ) ---------- only 533 SKUs Vs 738 SKUs
						 ,hdwcitm as ( select t.*,m.FamilyGroup,FamilyGroup_,m.Family,m.Family_0
										from hdwcitm_ t left join JDE_DB_Alan.vw_Mast m on t.ItemNumber = m.ItemNumber
										where t.StockingType not in ('O','U') and t.Sls_Status_ in ('Nil_Sls_N')

									 )
						 --  select * from txtitm
				

						---- Below is not good as you actually not group PO by month if you add supplierName or oOrder number! --- 14/5/2020
						--with po as (
									-- select tb.ItemNumber,tb.DataType1,tb.PODate_,tb.poyr,tb.pomth,tb.BuyerName,tb.BuyerNumber,tb.TransactionOriginator,tb.TransactionOrigName,tb.SupplierName
									 --select tb.ItemNumber,tb.DataType1,tb.PODate_,tb.poyr,tb.pomth,tb.SupplierName							
										--	,sum(tb.QuantityOpen) as PO_Vol				---7/12/2018
									--	from JDE_DB_Alan.vw_OpenPO tb						
									  --  where tb.ItemNumber in ('24.7002.0001')
									 -- group by tb.ItemNumber,tb.DataType1,tb.PODate_,tb.poyr,tb.pomth,tb.SupplierName
						
								 -- )					

						,po as (
									-- select tb.ItemNumber,tb.DataType1,tb.PODate_,tb.poyr,tb.pomth,tb.BuyerName,tb.BuyerNumber,tb.TransactionOriginator,tb.TransactionOrigName,tb.SupplierName
									 select tb.ItemNumber,tb.DataType1,tb.PODate_,tb.poyr,tb.pomth					--- 14/5/2020
											--,sum(tb.PO_Volume) as PO_Vol
											,sum(tb.QuantityOpen) as PO_Vol				---7/12/2018
										from JDE_DB_Alan.vw_OpenPO tb
									 -- where tb.ItemNumber in  ( select splitdata from JDE_DB_Alan.dbo.fnSplitString(@Item_id,','))	
									  --  where tb.ItemNumber in ('24.7002.0001')
									  group by tb.ItemNumber,tb.DataType1,tb.PODate_,tb.poyr,tb.pomth
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


				
							------- FC for Textile --- Need to isolate Vertical Fabric ( 981 ) And Apply % --- 5/12/2019
			
							------- This table will filter out any Obsolete item, active item but no sales over past 12 month hence no need to allocate capactity ( only forecastable item )---
							------- How to get those items mentioned above ??------

							,fc as ( select --distinct m.ItemNumber
											t.ItemNumber,f.FCDate2_,f.DataType1,t.StockingType,f.FCDate_,f.Date
											,f.FC_Vol
											 ,t.FamilyGroup,t.Family
								 					
										from  hdwcitm t left join JDE_DB_Alan.vw_FC f on f.ItemNumber = t.ItemNumber
										where  f.DataType1 in ('ADJ_FC')
												and  t.StockingType not in ('O','U','Z')
												-- mm.StockingType in ('K','W','X','S','F','P','Q','Z','C','M','0','I')			   -- this could be best to avoid issue of returning empty dataSet due to Null value --- 23/7/2018									     
											  --and f.FCDate2_ in ('201912')
										)
                     
							-- select * from fc 
							-- where fc.ItemNumber in ('82.201.901','82.109.921','82.011.937')							--- '82.201.901' active WC item 'S'; '82.109.921' WC item but obsolete;'82.011.937' Active WC item 'S' but within '981' Vertical familyGP
									--and fc.FCDate2_ in ('201912')		

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
							 
								-- from JDE_DB_Alan.vw_FC f left join po p on f.ItemNumber = p.ItemNumber and f.FCDate_ = p.PODate_
								   from fc f left join po p on f.ItemNumber = p.ItemNumber and f.FCDate_ = p.PODate_
														  left join so s on f.ItemNumber = s.Item_Number and f.FCDate_ = s.YM_Req_c					  --19/10/2019			
														  left join JDE_DB_Alan.vw_Mast m on f.ItemNumber  = m.ItemNumber and f.FCDate_ = m.SOHDate   -- SOHDate is current month name,also note 'vw_Mast' is clearn without duplicated records
								 where f.Date< @dt
								-- where f.Date < '2022-03-02'
								--where f.Date < '2021-01-02'
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
												   ,mm.PrimarySupplier,mm.Description,mm.FamilyGroup_,mm.FamilyGroup,mm.Family_0,mm.Family,mm.PlannerNumber,mm.Leadtime_Mth,mm.UOM								   
											from t_ left join JDE_DB_Alan.vw_Mast mm on t_.ItemNumber = mm.ItemNumber )				-- note that 'vw_Mast ' has clean data 
		 
								   --select * from _t
									--where _t.ItemNumber in ('45.103.000','45.200.100','42.210.031') 
									 -- where _t.ItemNumber in ('0751031003001H')
									 --order by _t.ItemNumber,_t.Date		 

							,com_1 as ( select _t.ItemNumber,_t.Date d1,_t.FCDate_ d2,'FC_Qty' as DataType,_t.FC_Vol as Value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.PlannerNumber,_t.Leadtime_Mth,_t.UOM from _t
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
										select _t.ItemNumber,_t.Date d1,_t.FCDate_ d2,'Weeks_Cover1' as DataType,coalesce(_t.SOH_End_M_/nullif(_t.CumulativeTotal_FC_Vol_Nxt3M/12,0),0) as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.PlannerNumber,_t.Leadtime_Mth,_t.UOM from _t				  
									--  union all
									--	select _t.ItemNumber,_t.Date d1,_t.FCDate_ d2,'Weeks_Cover2' as DataType,(_t.SOH_End_M_)/(_t.Avg_FC_Vol_Nxt8M/4) as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0 from _t				  							  						  	 
										)
							-- select * from com
						,c1 as ( select c.ItemNumber,c.d1,c.d2,c.DataType,c.value,c.Stk_Out_Stauts,c.Owner_,c.PrimarySupplier,c.Leadtime_Mth,c.PlannerNumber,c.Description
								,c.UOM    
								,getdate() as ThisReportDate
			    				from com_1 as c
							--where com.Stk_Out_Stauts in ('Y')
						-- where com.ItemNumber in ('46.598.000')
							-- where com.PrimarySupplier in ('20037','1102')
							-- where com.PrimarySupplier in ( select splitdata from JDE_DB_Alan.dbo.fnSplitString(@Supplier_id,','))
							--  where com.ItemNumber in ( select splitdata from JDE_DB_Alan.dbo.fnSplitString(@Item_id,','))
							--order by c.ItemNumber,c.DataType,c.d2 	
							)
              
						--select * from c1

					,com_2 as ( select _t.ItemNumber,_t.Date d1,_t.FCDate_ d2,'FC_Qty' as DataType,case when _t.FamilyGroup in ('981') then _t.FC_Vol/25 else _t.FC_Vol end as Value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.PlannerNumber,_t.Leadtime_Mth,_t.UOM from _t
										union all
										select _t.ItemNumber,_t.Date d1,_t.FCDate_ d2,'SO_Qty' as DataType,case when _t.FamilyGroup in ('981') then _t.SO_Vol/25 else _t.SO_Vol end as Value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.PlannerNumber,_t.Leadtime_Mth,_t.UOM from _t
										union all
										select _t.ItemNumber,_t.Date d1,_t.FCDate_ d2,'PO_Qty' as DataType,case when _t.FamilyGroup in ('981') then _t.PO_Vol/25 else _t.PO_Vol end as Value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.PlannerNumber,_t.Leadtime_Mth,_t.UOM from _t
										union all
										select _t.ItemNumber,_t.Date d1,_t.FCDate_ d2,'SOH_Qty' as DataType,case when _t.FamilyGroup in ('981') then _t.SOH_Vol_/25 else _t.SOH_Vol_ end as Value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.PlannerNumber,_t.Leadtime_Mth,_t.UOM from _t
										union all
										select _t.ItemNumber,_t.Date d1,_t.FCDate_ d2,'Start_Stk' as DataType,case when _t.FamilyGroup in ('981') then _t.Final_SOH_Begin_M_/25 else _t.Final_SOH_Begin_M_ end as Value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.PlannerNumber,_t.Leadtime_Mth,_t.UOM from _t
										union all
										select _t.ItemNumber,_t.Date d1,_t.FCDate_ d2,'End_Stk' as DataType,case when _t.FamilyGroup in ('981') then _t.SOH_End_M_/25 else _t.SOH_End_M_ end as Value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.PlannerNumber,_t.Leadtime_Mth,_t.UOM from _t
										union all
										select _t.ItemNumber,_t.Date d1,_t.FCDate_ d2,'FC_Amt' as DataType,_t.FC_Amt as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.PlannerNumber,_t.Leadtime_Mth,_t.UOM from _t	
										union all
										select _t.ItemNumber,_t.Date d1,_t.FCDate_ d2,'End_Stk_Amt' as DataType,_t.SOH_End_Amt as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.PlannerNumber,_t.Leadtime_Mth,_t.UOM from _t				   				   
										union all
										select _t.ItemNumber,_t.Date d1,_t.FCDate_ d2,'Weeks_Cover1' as DataType,coalesce(_t.SOH_End_M_/nullif(_t.CumulativeTotal_FC_Vol_Nxt3M/12,0),0) as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.PlannerNumber,_t.Leadtime_Mth,_t.UOM from _t				  
									--  union all
									--	select _t.ItemNumber,_t.Date d1,_t.FCDate_ d2,'Weeks_Cover2' as DataType,(_t.SOH_End_M_)/(_t.Avg_FC_Vol_Nxt8M/4) as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0 from _t				  							  						  	 
										)
							-- select * from com
					,c2 as ( select c.ItemNumber,c.d1,c.d2,c.DataType,c.value,c.Stk_Out_Stauts,c.Owner_,c.PrimarySupplier,c.Leadtime_Mth,c.PlannerNumber,c.Description
									,c.UOM    				        
							  from com_2 as c
							 --where com.Stk_Out_Stauts in ('Y')
							-- where com.ItemNumber in ('46.598.000')
							 -- where com.PrimarySupplier in ('20037','1102')
							  -- where com.PrimarySupplier in ( select splitdata from JDE_DB_Alan.dbo.fnSplitString(@Supplier_id,','))
							 --  where com.ItemNumber in ( select splitdata from JDE_DB_Alan.dbo.fnSplitString(@Item_id,','))
							  --order by c.ItemNumber,c.DataType,c.d2 					 
							   )

						  --  select distinct c2.ItemNumber from c2
              
					,z as (  select c2.*
								  --,case 
									 -- when m.WCCode_fl like ('%45004%') then 'Monfort'
									 -- when m.WCCode_fl like ('%45005%') then 'Babcock'
								  -- end as WCCode_fl_								  								
								  
								   ,m.WCCode_fl													-- Metal Work Center --> ('53001','60000','60003','60007','60011','60013','60019','60027','60035','60052','68903')
								   ,m.WCGroupCode_fl,m.WCGroupName_fl
								   ,m.StockingType
					   
								  ,getdate() as ThisReportDate

								  from c2 left join JDE_DB_Alan.vw_Mast m on c2.ItemNumber = m.ItemNumber
					
								-- where fc.ItemNumber in ('82.201.901','82.109.921','82.011.937')							--- '82.201.901' active WC item 'S'; '82.109.921' WC item but obsolete;'82.011.937' Active WC item 'S' but within '981' Vertical familyGP
							  )

						select * 
						--select distinct z.ItemNumber
						from z	
						where z.WCGroupName_fl like ('%Metal%')  
					 --  and z.ItemNumber in ('82.028.901') 	  
					  -- where z.ItemNumber in ( select splitdata from JDE_DB_Alan.dbo.fnSplitString(@Item_id,','))

			 end
  
    
	--- if WCGRP_ID is not provided at all, SKU number is provided 	  
	--if @WCGRP_id is null  and @dt is not null and @Item_id is null	 
	 
	--   begin	

 --                    --	select * 					
	--				--	from z	
	--					--where z.WCGroupName_fl like ('%Metal%')  
	--				 --  and z.ItemNumber in ('82.028.901') 	  
	--				  -- where z.ItemNumber in ( select splitdata from JDE_DB_Alan.dbo.fnSplitString(@Item_id,','))

 --      end


END
GO


