	

use JDE_DB_Alan
go	
	
	-------- Textile RCCP ---------			5/12/2019

	--select distinct f.ItemNumber from JDE_DB_Alan.vw_FC f where f.DataType1 in ('Adj_FC')
	--select * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h where h.ItemNumber in ('42.210.031')

	  ------ First Get your clean/valid Textile item -------

			 --- All Textile SKUs ---- From Master file
	with   _txlitm as ( select m.ItemNumber,m.WC,m.StockingType,m.Description
	                            ,'TBC' as Sls_Status	                            	
	                            ,count(m.Description )over() as Total_Count_Textile_Items_With_WC
	                     from JDE_DB_Alan.vw_Mast m
						 where m.WC <>'0' 						       
						 --order by m.WC
						 )
			
			--- Obsolete Items ----	113 item -- this is just for testing purpose,in ' _txlitm ' table it already include 'O','U' items for textile
             ,Obsl_txlitm  as ( select m.ItemNumber,m.Description,m.wc,m.StockingType
	                                   ,count(m.Description)over() as Item_Count
								 from JDE_DB_Alan.vw_Mast m 
	                             where m.StockingType in ('O','U')
								       and m.wc <> '0'
								 )   

            --- Items with either 0 sales or Null sales over last 12 months ----   205 Items
            ,Null_txlitm as (  select nil.ItemNumber,'Nil_Sls_Y' as Nil_Status
			                   from  
									 (select a.ItemNumber from _txlitm a except select h.ItemNumber_ from JDE_DB_Alan.vw_Sls_History_HD h )        
								 as nil

                               ) 
			--select * from Obsl_txlitm
			--select * from Null_txlitm

			  ----- Full Textile SKU list with details ----- You can use this list for SKU Analysis, FOR RCCP reporting purose, u might not need this full list, just active item list .
			,txtitm_ as ( select a.ItemNumber,a.WC,a.StockingType
								 ,case 
								     when ni.Nil_Status = 'Nil_Sls_Y' then ni.Nil_Status
									 when ni.Nil_Status is null then 'Nil_Sls_N'
                                 end as Sls_Status_
                                ,a.Description
                                ,count(a.Description)over() as Itm_Count
			               from  _txlitm a left join Null_txlitm ni on a.ItemNumber = ni.ItemNumber )
			  
			  --  select * from txtitm_ t where t.ItemNumber in ('82.201.950') 		   
			  --  where t.StockingType not in ('O','U') and t.Sls_Status_ in ('Nil_Sls_Y')

			 
			 ----- Your final list of clean Textile Items ( Active item & with Sales ) ---------- only 533 SKUs Vs 738 SKUs
			 ,txtitm as ( select t.*,m.FamilyGroup,FamilyGroup_,m.Family,m.Family_0
			                from txtitm_ t left join JDE_DB_Alan.vw_Mast m on t.ItemNumber = m.ItemNumber
							where t.StockingType not in ('O','U') and t.Sls_Status_ in ('Nil_Sls_N')

			             )
             --  select * from txtitm
				
			,po as (    --select tb.ItemNumber,tb.DataType1,tb.PODate_,tb.poyr,tb.pomth,tb.BuyerName,tb.BuyerNumber,tb.TransactionOriginator,tb.TransactionOrigName,tb.SupplierName
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
				
				------- FC for Textile --- Need to isolate Vertical Fabric ( 981 ) And Apply % --- 5/12/2019
				------- This table will filter out any Obsolete item, active item but no sales over past 12 month hence no need to allocate capactity ( only forecastable item )---
				------- How to get those items mentioned above ??------

                ,fc as ( select --distinct m.ItemNumber
								t.ItemNumber,f.FCDate2_,f.DataType1,t.StockingType,f.FCDate_,f.Date
								,f.FC_Vol
								 ,t.FamilyGroup,t.Family
								 					
							from  txtitm t left join JDE_DB_Alan.vw_FC f on f.ItemNumber = t.ItemNumber
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
					-- where f.Date< @dt
					-- where f.Date < '2020-12-02'
					where f.Date < '2021-01-02'
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
												when '20003' then 'Lee Roise'
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
              
			 , z as (  select c2.*
					  ,m.WC
					  ,case 
						  when m.wc = '45004' then 'Monfort'
						  when m.wc ='45005' then 'Babcock'
					   end as WC_Description 
			          ,getdate() as ThisReportDate
					  from c2 left join JDE_DB_Alan.vw_Mast m on c2.ItemNumber = m.ItemNumber
					-- where fc.ItemNumber in ('82.201.901','82.109.921','82.011.937')							--- '82.201.901' active WC item 'S'; '82.109.921' WC item but obsolete;'82.011.937' Active WC item 'S' but within '981' Vertical familyGP
                  )

			--select distinct z.ItemNumber 
			select *
			from z	   