	use JDE_DB_Alan
	go
SQLQuery_HD_sp_MI_Raw_2_Combine_Mismatch_Old.sql
	
	 --- Old MI Code --> [JDE_DB_Alan].[sp_MI_2_Raw_Combine_Mismatch] --- 3/8/2018 ---
	---first sumarize PO by month --- 
		 with po as (
						 select tb.ItemNumber,tb.DataType1,tb.PODate_,tb.poyr,tb.pomth,tb.BuyerName,tb.BuyerNumber,tb.TransactionOriginator,tb.TransactionOrigName,tb.SupplierName
								,sum(tb.PO_Volume) as PO_Vol
							from JDE_DB_Alan.vw_OpenPO tb
						 -- where tb.ItemNumber in  ( select splitdata from JDE_DB_Alan.dbo.fnSplitString(@Item_id,','))	
						  group by tb.ItemNumber,tb.DataType1,tb.PODate_,tb.poyr,tb.pomth,tb.BuyerName,tb.BuyerNumber,tb.TransactionOriginator,tb.TransactionOrigName,tb.SupplierName

					  )
					--select * from po

					---  Need to aggregate FC for Single SKU ---  1/8/2018
                   ,mi2fc as ( select mi2.ItemID,mi2.Date,mi2.ValidStatus,sum(mi2.Value) as value
								from JDE_DB_Alan.FCPRO_MI_2_Raw_Data_tmp mi2
								where mi2.ValidStatus = 'Y'	
								--where mi2.ValidStatus = 'S'								-- ' S' denotes for Simulation only   --- 2/8/2018 --- only pickup S items for Simulation, when MI confirmed you need to put Y instead of S
							         and mi2.Value >0											--- Need to pick up non Zero value  --3/8/2018
								   --  and mi2.ItemID in ('18.010.035')     
								group by mi2.ItemID,mi2.date,mi2.ValidStatus
								)
                   -- select distinct mi2fc.ItemID from mi2fc
				  -- FC --- updated 12/7/2018 to include MI in table variable ( Or Temp table)
				  ,fc_mas as ( select * from JDE_DB_Alan.vw_FC f 
							--where f.ItemNumber in ('18.010.035','42.210.031')			-- deliberately choose 2 items in vw_FC, 1 is 18.010.035 which also exists in MI_orig table, 1 is 42.210.031 which does exist in Mi_orig table but exists in vw_FC master table to check what result it will yield after Join --- 25/7/2018
							  -- where f.ItemNumber in ('26.800.833')	
								-- and f.Date < '2019-03-02'								-- choose small date range to return small data set for easy manupilation
							   )
				  ,_fc as																		
					   ( --select f_.ItemID,f_.myFcDate,f_.myFcQty,f.ItemNumber,f.Date,f.FCDate_,f.FC_Vol,convert(datetime,f_.myFcDate+'-01',111) as myDate
						  --from fc_mas f full outer join @mymi f_ on f.ItemNumber = f_.ItemID and f.FCDate_ = f_.myFcDate
						  select f_.ItemID,f_.Date as myDate,f_.Value as myFcQty,f.ItemNumber,f.Date,f.FCDate_,f.FC_Vol
									,convert(varchar(7),f_.Date,120) as myFcDate								
						  --from fc_mas f full outer join @mymi f_ on f.ItemNumber = f_.ItemID and f.Date = f_.myDate
						  -- from fc_mas f full outer join JDE_DB_Alan.FCPRO_MI_orig f_ on f.ItemNumber = f_.ItemID and f.Date = f_.Date		-- use this will have all data (includes 18.013.089) but big recordsets, because you are picking up all SKUs in 'Master' file regardless if they have forecast or not ( currently you filter out items has no sales history over last 12 months and prevent them generating fc )	--- ?				 
						   -- from JDE_DB_Alan.FCPRO_MI_orig f_ left join fc_mas f on f.ItemNumber = f_.ItemID and f.Date = f_.Date	         --- not good causing big problems for SOH etc because on Mi raw table you only have 1 or 2 or 3 month, say if MI is for 2018-09 then you will not get SOH ( since SOH is always default to current month you are in ) and you need visibility for each month, YOU can use left join if you are not concerning SOH figure but in order to keep your code consistent, you should keep use full outer join and filter out on specific SKUs at end,this might best solution for this issue 25/7/2018 --- Will Use this lead to risk of lossing item has no sales history 18.013.089	--- No ???
						   --from fc_mas f full outer join JDE_DB_Alan.FCPRO_MI_2_Raw_Data_tmp f_ on f.ItemNumber = f_.ItemID and f.Date = f_.Date		-- 31/7/2018, change table name -- use this will have all data (includes 18.013.089) but big recordsets, because you are picking up all SKUs in 'Master' file regardless if they have forecast or not ( currently you filter out items has no sales history over last 12 months and prevent them generating fc )	--- ?				 
						     from fc_mas f full outer join mi2fc f_ on f.ItemNumber = f_.ItemID and f.Date = f_.Date						-- 1/8/2018, Need to combine multip entry for 1 SKU; Also change table name -- use this will have all data (includes 18.013.089) but big recordsets, because you are picking up all SKUs in 'Master' file regardless if they have forecast or not ( currently you filter out items has no sales history over last 12 months and prevent them generating fc )	--- ?				 
						 )
				  -- select * from _fc where _fc.ItemID in ('18.013.089')
				 ,fc as																		
					   ( select f.ItemID,f.myFcDate,f.myFcQty,f.ItemNumber,f.Date,f.FCDate_,f.FC_Vol
								,case when f.myFcQty is null then f.FC_Vol												-- if Item doest not exists in MI raw but exists in vw_FC master
									  when f.myFcQty is not null then													-- if Item exists in MI raw, see if it exists in vw_FC master,if do, combine two fc together			
															case when f.FC_Vol is not null then f.FC_Vol+f.myFcQty		-- if Item exists in MI raw, see if it exists in vw_FC master,if do not, then use Mi Raw ( it could be Item with no 12 mth sales history, item discontinued, or item belongs to AWF )
																 when f.FC_Vol is null then f.myFcQty
																 end
								   
								   end as  FC_Vol_f
								,case when f.ItemNumber is not null then f.ItemNumber
									  when f.ItemNumber is null then f.ItemID
								 end as ItemNumber_f
								,case when f.Date is not null then f.Date
									  when f.date is null then f.myDate
								 end as Date_f
								,case when f.FCDate_ is not null then f.FCDate_
									  when f.FCDate_ is null then f.myFcDate
								 end as FcDate_f
					  		  	        	   
						  from  _fc f 
						-- from JDE_DB_Alan.vw_FC f full outer join @mymi f_ on f.ItemNumber = f_.ItemID and f.FCDate_ = f_.FcDate  
						-- from JDE_DB_Alan.vw_FC f left join @mymi f_ on f.ItemNumber = f_.ItemID and f.FCDate_ = f_.FcDate 
						--  from  @mymi f_  left join JDE_DB_Alan.vw_FC f on f.ItemNumber = f_.ItemID and f.FCDate_ = f_.FcDate_Raw			--- not good causing big problems for SOH etc because on Mi raw table you only have 1 or 2 or 3 month, say if MI is for 2018-09 then you will not get SOH ( since SOH is always default to current month you are in ) and you need visibility for each month, YOU can use left join if you are not concerning SOH figure but in order to keep your code consistent, you should keep use full outer join and filter out on specific SKUs at end,this might best solution for this issue 25/7/2018 --- Will Use this lead to risk of lossing item has no sales history 18.013.089	--- No ???
						-- where f.ItemNumber in ( '42.210.031','24.7207.4459')
							 --  and f.Date < '2019-03-01'
						-- where f.ItemNumber in ('18.010.035')
						 --where f.ItemID in ('18.013.089')
						 )

				  -- select distinct fc.ItemNumber from fc 
				  --select  * from fc  where fc.ItemNumber_f in ('18.013.089')
				  --select  * from fc  where fc.ItemID in ('18.013.089') or fc.ItemNumber_f in ('18.013.089')			--- note 18.013.089 has no existence in 'FVPRO_Fcst' table as there is no sales history over 12 month. Therefore when join table you will have unexpected result - be careful here in where condition be careful to which ItemNumber or ItemId you need to use. Also be careful using 'Not In ( )' conditional because if there is null value SQL will return empty dataset ! --- 20/7/2018
				   --select * from fc

					,tb as 
						( select f.ItemNumber_f,f.FcDate_f,f.Date_f,f.FC_Vol_f as FC_Vol				-- will it cause issues if you rename 'f.FC_Vol_f' as 'FC_Vol' since you already have 'FC_Vol' column ?
							 -- select f.ItemNumber,f.Date,f.FCDate_,f.FC_Vol_f
								,isnull(p.PO_Vol,0) PO_Vol
								--,isnull(m.QtyOnHand,0) SOH_Vol
								,isnull(m.QtyOnHand,0) as SOH_Begin_M
								 ,0 as SOH_Vol				 
								--, isnull(m.QtyOnHand,0) as SOH_End_M
								,0 as SOH_End_M
								,m.WholeSalePrice							
							 
						-- from JDE_DB_Alan.vw_FC f left join po p on f.ItemNumber = p.ItemNumber and f.FCDate_ = p.PODate_
						  from fc f left join po p on f.ItemNumber_f = p.ItemNumber and f.FcDate_f = p.PODate_
												left join JDE_DB_Alan.vw_Mast m on f.ItemNumber_f  = m.ItemNumber and f.FCDate_f = m.SOHDate   -- SOHDate is current month name,also note 'vw_Mast' is clearn without duplicated records
												  --left join JDE_DB_Alan.vw_Mast m on f.ItemNumber_f  = m.ItemNumber
						-- where f.Date_f< @dt							--- be careful if you have null value resulting from pervious step in join -- you will miss value --- 20/7/2018
						  where f.FcDate_f < '2019-03-02'
							  -- and f.ItemNumber in ('45.103.000')
									 )
								 						
				   --select * from tb where tb.ItemNumber_f in ('18.013.089') order by tb.ItemNumber_f,tb.FCDate_f
					  ,tb_ as (
								select tb.ItemNumber_f,tb.Date_f,tb.FCDate_f,tb.FC_Vol,tb.PO_Vol,tb.SOH_Vol 
										,case 
											   when tb.Date_f >DATEADD(mm, DATEDIFF(m,0,GETDATE()),0)  then (tb.PO_Vol -tb.FC_Vol)
											   when tb.Date_f = DATEADD(mm, DATEDIFF(m,0,GETDATE()),0) then (tb.PO_Vol -tb.FC_Vol + tb.SOH_Begin_M)
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
										row_number() over ( partition by tb_.itemNumber_f order by tb_.FCDate_f ) as rnk 
									from tb_      
                
								)
								--- running total To get End period inventory ---
					 ,tbl_ as 
							(	select *
									  ,sum(tbl.SOH_Vol_) over (partition by tbl.ItemNumber_f order by tbl.rnk ) as SOH_End_M_
									from tbl
							 )
      
					  --select * from tbl_
								--- Beginning period inventory preparation ---
					  ,stk_beg as
							  ( select tbl_.ItemNumber_f as myItemNumber,tbl_.FcDate_f as myDate
										,DATEADD(mm, DATEDIFF(m,0,tbl_.Date_f)+1,0) dte
										,tbl_.SOH_End_M_ as mySOH_Begin_M_
			            
								 from tbl_)
						   --select * from stk_beg

					 ,t as ( select *
									 from tbl_ left join stk_beg on tbl_.ItemNumber_f = stk_beg.myItemNumber and tbl_.Date_f = stk_beg.dte 
								  )
						--  select * from t
								  --- Get Begining period inventory ---
					 ,t_ as ( select t.ItemNumber_f,t.Date_f,t.FCDate_f,t.FC_Vol,t.PO_Vol,t.SOH_Vol,t.SOH_Vol_
										,case 
												when t.mySOH_Begin_M_ is null then t.SOH_Begin_M
												else t.mySOH_Begin_M_
										  end as  Final_SOH_Begin_M_
										,t.SOH_End_M_,t.rnk
										,t.WholeSalePrice
										--,t.myWSP
										,replace(convert(varchar(8), DATEADD(mm, DATEDIFF(m,0,t.Date_f),0),126),'-','') as Date_f_2
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
				 
						---===========================================================================================================
						--- Filter out Item does not exist using inner join Or O/U items ( discontinued) by using stocking type filter
						---===========================================================================================================
					  ,_t as ( --select t_.ItemNumber,t_.Date,t_.FCDate_,t_.FC_Vol,t_.PO_Vol,t_.SOH_Vol,t_.SOH_Vol_,t_.Final_SOH_Begin_M_,t_.SOH_End_M_,m.WholeSalePrice     -- will spit out column by column saves the performance issue ? Not really  -- 14/5/2018
									select t_.*
											, mm.WholeSalePrice as Mywholesaleprice
											,(mm.WholeSalePrice * t_.FC_Vol) FC_Amt
										   , case when t_.Final_SOH_Begin_M_ <= 0  then 'Y 'else 'N' end as Stk_Out_Stauts
										   ,sum(t_.FC_Vol) over (partition by t_.ItemNumber_f order by t_.FCDate_f Rows between current row and 2 following ) as CumulativeTotal_FC_Vol_3M			-- only works in SQL 2012 upwards, if you using 2008 need to use below...  https://docs.microsoft.com/en-us/sql/t-sql/queries/select-over-clause-transact-sql?view=sql-server-2017
										   ,sum(t_.FC_Vol) over (partition by t_.ItemNumber_f order by t_.FCDate_f Rows between 1 following and 3 following ) as CumulativeTotal_FC_Vol_Nxt3M	
										   ,avg(t_.FC_Vol) over (partition by t_.ItemNumber_f) as Avg_FC_Vol_Nxt8M			--- SQL2008 support this 
										   ,mm.PlannerNumber
						 					,case mm.PlannerNumber 
												when '20071' then 'Domenic Cellucci'		
												--when '20071' then 'Rosie Ashpole'
												when '20072' then 'Salman Saeed'
												when '20004' then 'Margaret Dost'	
												when '20005' then 'Imelda Chan'										  
												else 'Unknown'
											end as Owner_
										   ,mm.PrimarySupplier,mm.Description,mm.FamilyGroup_,mm.Family_0,mm.Leadtime_Mth									   
									--from t_ left join JDE_DB_Alan.vw_Mast mm on t_.ItemNumber_f = mm.ItemNumber	)				-- note that 'vw_Mast ' has clean data, also best to use Inner Join ( see below for reason )  - 23/7/2018
									  from t_ inner join JDE_DB_Alan.vw_Mast mm on t_.ItemNumber_f = mm.ItemNumber					-- Use inner join to filter out SKUs not showing up in HD using ML345 (HD) like '709895', so SKUs against AWF will filter out ( like in CommonWealth Bank Proj - '7089895','709901' ) -- 23/7/2018 
									--  where mm.StockingType not in ('O','U')														-- filter out discontinued SKU like '32.501.000' - project Comwlth Bank Project. Should keep sku has no sales history over last 12 months like '18.013.089'  in Proj RAMLER -- 7/8/2018
									--  where mm.StockingType in ('O','K','W','X','S','F','P','U','Q','Z','C','M','0','I')			
									  where mm.StockingType in ('K','W','X','S','F','P','Q','Z','C','M','0','I') --or mm.StockingType is null				   -- this could be best to avoid issue of returning empty dataSet due to Null value --- 23/7/2018
												)		
		 
						-- select * from _t		
						--  where _t.ItemNumber_f in ('32.501.000','709895','82.691.909','18.013.089','42.210.031')				  
							--where _t.ItemNumber in ('45.103.000','45.200.100','42.210.031') 
							 -- where _t.ItemNumber in ('0751031003001H')
							 --order by _t.ItemNumber,_t.Date	
						 	 
						--select _t.ItemNumber_f,_t.Date_f d1,_t.FCDate_f d2,'Start_Stk' as DataType,_t.Final_SOH_Begin_M_ as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.Leadtime_Mth,_t.PlannerNumber from _t

					 ,com as ( select _t.ItemNumber_f,_t.Date_f d1,_t.Date_f_2 d3,_t.FCDate_f d2,'FC_Qty' as DataType,_t.FC_Vol as Value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.Leadtime_Mth,_t.PlannerNumber from _t
								   union all
								   select _t.ItemNumber_f,_t.Date_f d1,_t.Date_f_2 d3,_t.FCDate_f d2,'PO_Qty' as DataType,_t.PO_Vol as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.Leadtime_Mth,_t.PlannerNumber from _t
								  union all
								   select _t.ItemNumber_f,_t.Date_f d1,_t.Date_f_2 d3,_t.FCDate_f d2,'SOH_Qty' as DataType,_t.SOH_Vol_ as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.Leadtime_Mth,_t.PlannerNumber from _t
							  
								  union all
									select _t.ItemNumber_f,_t.Date_f d1,_t.Date_f_2 d3,_t.FCDate_f d2,'Start_Stk' as DataType,_t.Final_SOH_Begin_M_ as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.Leadtime_Mth,_t.PlannerNumber from _t
								  union all
									select _t.ItemNumber_f,_t.Date_f d1,_t.Date_f_2 d3,_t.FCDate_f d2,'End_Stk' as DataType,_t.SOH_End_M_ as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.Leadtime_Mth,_t.PlannerNumber from _t
								  union all
									select _t.ItemNumber_f,_t.Date_f d1,_t.Date_f_2 d3,_t.FCDate_f d2,'FC_Amt' as DataType,_t.FC_Amt as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.Leadtime_Mth,_t.PlannerNumber from _t				   
								  union all
									select _t.ItemNumber_f,_t.Date_f d1,_t.Date_f_2 d3,_t.FCDate_f d2,'Weeks_Cover1' as DataType,coalesce(_t.SOH_End_M_/nullif(_t.CumulativeTotal_FC_Vol_Nxt3M/12,0),0) as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.Leadtime_Mth,_t.PlannerNumber from _t				  
								--  union all
								--	select _t.ItemNumber,_t.Date d1,_t.FCDate_ d2,'Weeks_Cover2' as DataType,(_t.SOH_End_M_)/(_t.Avg_FC_Vol_Nxt8M/4) as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0 from _t				  							  						  	 
								   )

					-- select distinct com.ItemNumber_f from com 
				,fcst as 
						 (select * from com 
							 --where com.Stk_Out_Stauts in ('Y')
							   -- where com.ItemNumber in ('45.103.000','45.200.100')
							--where com.ItemNumber in ('4152336048B')
				 			-- where com.ItemNumber in ( select splitdata from JDE_DB_Alan.dbo.fnSplitString(@Item_id,','))	
							  --where com.PrimarySupplier in ('20037','1102')
							--where com.ItemNumber in ('32.501.000','18.010.035','18.615.007','18.010.036','2780229000','82.391.909','32.379.200','18.013.089','24.7002.0001','24.7334.4459','24.7102.1858','24.7219.4459','32.455.155','24.7121.4459','24.7122.4459','24.7124.4459','24.7127.4459','24.5349.4459','24.7120.4459','24.7250.4459','24.7251.4459','24.7253.4459','24.7146.4459A','24.7207.4459','24.7168.4459A','24.7169.4459A','24.7163.0000A')  
							--  where com.ItemNumber in ('24.7218.4465','32.501.000','43.211.004','32.379.200','32.380.855','18.607.016','24.7201.0000','24.7102.7052','24.7102.7052','32.455.465','24.7115.0952A','24.7114.0952A','24.7128.0952','709895','24.7353.0000A','24.7136.0155A','709901','24.7120.0952')
							-- where com.ItemNumber in ('32.501.000','18.010.035','18.615.007','18.010.036','2780229000','82.391.909','32.379.200','18.013.089','24.7002.0001','24.7334.4459','24.7102.1858','24.7219.4459','32.455.155','24.7121.4459','24.7122.4459','24.7124.4459','24.7127.4459','24.5349.4459','24.7120.4459','24.7250.4459','24.7251.4459','24.7253.4459','24.7146.4459A','24.7207.4459','24.7168.4459A','24.7169.4459A','24.7163.0000A')
							-- where com.ItemNumber in ('42.210.031')
							--where com.ItemNumber_f in ('18.013.089')
							where com.DataType in ('FC_Qty')
								   and com.ItemNumber_f in (select distinct o.ItemID from JDE_DB_Alan.FCPRO_MI_2_Raw_Data_tmp o)			 --- change the table name 31/7/2018	
								-- and com.ItemNumber_f in (select o.ItemID from JDE_DB_Alan.FCPRO_MI_orig o)				-- pick up item only appearing in Mi_orig table, if you omit this clause, you can pick up all items both in Mi_orig and vw_FC table   --- 25/7/2018
																														-- better to do filter here to avoid performance bottleneck in following Pivot function		--- 25/7/2018													
							
							-- and com.ItemNumber_f in  ( select splitdata from JDE_DB_Alan.dbo.fnSplitString(@Item_id,','))	--- No need in Mi_Raw since you only pick up Forecast, but if you do Generic Mismatch it is good to have alternative to choose ItemNumber --- 25/7/2018
							
							--order by com.ItemNumber_f,com.DataType,com.d2
							   ) 
					  --select * from fcst where fcst.ItemNumber_f is null
					  --where fcst.ItemNumber_f in ('18.010.035')					  

			 
				  --- Get Preparation to Pivot Data using SQL --- It is better to use Numbwe Array ([1],[2],[3] ) instead of ([201807],[201808],[201809]) as it is more versatile and flexible to avoid hard coding --- 25/7/2018
				,R(N,_T,T_,T,XX,YY,start) AS
						(
						 select 1 as N,-24 as _T,24 as T_,-23 as T,24 as XX,24 as YY,cast(DATEADD(mm, DATEDIFF(mm, 0, GETDATE())-24, 0) as datetime) as start      -- pay attention T starts -23,you need this so you can get XXX Column/Field in current month you start as 1, otherwise you can use XX field
						 UNION ALL
						 select  N+1, _T+1,T_-1,case when T+1<0 then T+1 else case when T+1 =0 then 1 else T+1 end end as T						
												,case when N >= 24  then _T+1
												   else  
													   XX-1
													end as XX
												 ,case when N >= 24  then T							     
												   else  
													   YY-1
													end as YY
								 ,dateadd(mm,1,start)
						  from R
						 where N < 49
						)
					--select * from r
					--select R.N,case when R._T < 0 then R.T_ else R._T end as T, start from R
					--select R.N,case when R._T < 0 then R.T_ else R.YY end as T, start from R
				  ,MthCal as (
									select  n as rnk
									 ,YY
									,_T
									,cast(SUBSTRING(REPLACE(CONVERT(char(10),start,126),'-',''),1,6) as integer) as [StartDt]		
									,LEFT(datename(month,start),3) AS [month_name]
									,datepart(month,start) AS [month]
									,datepart(year,start) AS [year]				
								   from R  )
				 --select * from MthCal
                
				 --- Need to Pivot data to display in Horizontal way --- Need to think it to join Calendar table ( with integer t number ) rather using [201808],[201809] instead using [1],[2] to speed up execution time,also to avoid hard coding !
				
			 ,_fcst as ( select f.ItemNumber_f,f.Description,f.d1,f.d3,f.d2,f.Value
								,c.*																				--- join cal to get YY value which is your month rank/order
				    
						from fcst f left join MthCal c on f.d3 = c.StartDt												--- no need to cross join cal table as FC tb always has data in 24 mth				
					  -- where fc.ItemNumber = ('42.210.031') order by fc.ItemNumber,fc.StartDt,fc.Date
						)
				
              --select * from fcst_  f where f.ItemNumber_f in ('18.010.035')


			  -- Need to Join back Original to get Data for only MI Month you Need --- 3/8/2018
			,mi2fc_ as ( select f.ItemID,f.Date,f.ValidStatus,f.value as Value_Orig from mi2fc f)
			,fcst_ as ( select *
					    from mi2fc_ myf left join _fcst f on myf.ItemID = f.ItemNumber_f and myf.Date = f.d1
						)
               -- select * from _fcst f where f.ItemNumber_f is null

				, mypvt as 
					( select *
						 from 
								( select f.ItemNumber_f,f.Description,f._T,f.Value  from fcst_ f  ) as sourcetb
                         pivot 
						       ( sum(value) for _T in ( [0],[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11]) 
								) as p								
					)
				
				
				select pv.ItemNumber_f
					   ,pv.Description
					   ,'Market Intelligence_2' as DataType
					   ,'TBC' as ChangeNoticeNumber
					   , 'Check_Original_Raw' as Comment
					   , 'TBC' as Creator
					   , 'TBC' as RefNum
					   , 'Y' as ValidStatus
					   , getdate() as LastUpdated
					   ,isnull(pv.[0],0) [0]
					   ,isnull(pv.[1],0) [1]
					   ,isnull(pv.[2],0) [2]
					   ,isnull(pv.[3],0) [3]
					   ,isnull(pv.[4],0) [4]
					   ,isnull(pv.[5],0) [5]
					   ,isnull(pv.[6],0) [6]
					   ,isnull(pv.[7],0) [7]
					   ,isnull(pv.[8],0) [8]
					   ,isnull(pv.[9],0) [9]
					   ,isnull(pv.[10],0) [10]
					   ,isnull(pv.[11],0) [11]
					   
				 from mypvt pv
				-- where pv.ItemNumber_f in ('18.013.089')
				--where pv.ItemNumber_f is null
				 order by pv.ItemNumber_f


				--, mypvt as 
				--	( select *
				--		 from 
				--				( select f.ItemNumber_f,f.Description,f.d3,f.Value  from fcst f  ) as sourcetb
                --        pivot 
				--		       ( sum(value) for d3 in ( [201807],[201808],[201809],[201810],[201811],[201812],[201901],[201902],[201903],[201904],[201905],[201906]) 
				--				) as p								
				--	)

		   --    	select pv.ItemNumber_f
					--   ,pv.Description
					--   ,isnull(pv.[201807],0) [201807]
					--   ,isnull(pv.[201808],0) [201808]
					--   ,isnull(pv.[201809],0) [201809]
					--   ,isnull(pv.[201810],0) [201810]
					--   ,isnull(pv.[201811],0) [201811]
					--   ,isnull(pv.[201812],0) [201812]
					--   ,isnull(pv.[201901],0) [201901]
					--   ,isnull(pv.[201902],0) [201902]	
					--   ,isnull(pv.[201903],0) [201903]	
					--   ,isnull(pv.[201904],0) [201904]	
					--   ,isnull(pv.[201905],0) [201905]			   	
					--   ,isnull(pv.[201906],0) [201906]	
				 --from mypvt pv
				 --order by pv.ItemNumber_f