use JDE_DB_Alan
go

declare @mymi as table
( ItemID varchar(100) not null 
  ,FcDate varchar(100) not null
  ,FcQty  decimal(18,2) not null 
  --,constraint primary key PK_myID (ItemID,FcDate)
  )
  
 Insert into @mymi ( ItemId,FcDate,FcQty)
 values 
('24.7218.4465','2018-09',1157.25),
('32.501.000','2018-09',1120.5),
('43.211.004','2018-09',4636.5),
('32.379.200','2018-09',1208.25),
('32.380.855','2018-09',1208.25),
('18.607.016','2018-09',765),
('24.7201.0000','2018-09',1155.75),
('24.7102.7052','2018-09',765),
('24.7102.7052','2018-09',765),
('32.455.465','2018-09',765),
('24.7115.0952A','2018-09',765),
('24.7114.0952A','2018-09',765),
('24.7128.0952','2018-09',1530.75),
('709895','2018-09',750),
('24.7353.0000A','2018-09',750),
('24.7136.0155A','2018-09',750),
('709901','2018-09',750),
('24.7120.0952','2018-09',765),
('24.7218.4465','2018-10',1774.45),
('32.501.000','2018-10',1718.1),
('43.211.004','2018-10',7109.3),
('32.379.200','2018-10',1852.65),
('32.380.855','2018-10',1852.65),
('18.607.016','2018-10',1173),
('24.7201.0000','2018-10',1772.15),
('24.7102.7052','2018-10',1173),
('24.7102.7052','2018-10',1173),
('32.455.465','2018-10',1173),
('24.7115.0952A','2018-10',1173),
('24.7114.0952A','2018-10',1173),
('24.7128.0952','2018-10',2347.15),
('709895','2018-10',1150),
('24.7353.0000A','2018-10',1150),
('24.7136.0155A','2018-10',1150),
('709901','2018-10',1150),
('24.7120.0952','2018-10',1173);

   
--select * from @mymi

DECLARE @dt datetime
SET @dt = DATEADD(mm, DATEDIFF(m,0,GETDATE())+10,0)

--Declare @Item_id varchar(8000)
--SET @Item_id = '45.103.000,27.252.713'

			 --first sumarize PO by month ---     
;with         
		   po as (
					 select tb.ItemNumber,tb.DataType1,tb.PODate_,tb.poyr,tb.pomth,tb.BuyerName,tb.BuyerNumber,tb.TransactionOriginator,tb.TransactionOrigName,tb.SupplierName
							,sum(tb.PO_Volume) as PO_Vol
					    from JDE_DB_Alan.vw_OpenPO tb
					 -- where tb.ItemNumber in  ( select splitdata from JDE_DB_Alan.dbo.fnSplitString(@Item_id,','))	
					  group by tb.ItemNumber,tb.DataType1,tb.PODate_,tb.poyr,tb.pomth,tb.BuyerName,tb.BuyerNumber,tb.TransactionOriginator,tb.TransactionOrigName,tb.SupplierName

					  )
				--select * from po
			
			  -- FC --- updated 12/7/2018 to include MI in table variable ( Or Temp table)
			 ,fc as																		
				   ( select f.ItemNumber,f.Date,f.FCDate_,f.FC_Vol,f_.FcQty
				            ,case when FcQty is null then f.FC_Vol
							      when FcQty is not null then f.FC_Vol + f_.FcQty 
								   --   else f.FC_Vol + f_.FcQty
							   end as  FC_Vol_f	   
				     from JDE_DB_Alan.vw_FC f left join @mymi f_ on f.ItemNumber = f_.ItemID and f.FCDate_ = f_.FcDate 
					-- where f.ItemNumber in ( '42.210.031','24.7207.4459')
					     --  and f.Date < '2019-03-01'
					 )
              -- select distinct fc.ItemNumber from fc 

				,tb as 
					( select f.ItemNumber,f.Date,f.FCDate_,f.FC_Vol_f as FC_Vol				-- will it cause issues if you rename 'f.FC_Vol_f' as 'FC_Vol' since you already have 'FC_Vol' column ?
						 -- select f.ItemNumber,f.Date,f.FCDate_,f.FC_Vol_f
							,isnull(p.PO_Vol,0) PO_Vol
							--,isnull(m.QtyOnHand,0) SOH_Vol
							,isnull(m.QtyOnHand,0) as SOH_Begin_M
							 ,0 as SOH_Vol				 
							--, isnull(m.QtyOnHand,0) as SOH_End_M
							,0 as SOH_End_M
							,m.WholeSalePrice
							 
					-- from JDE_DB_Alan.vw_FC f left join po p on f.ItemNumber = p.ItemNumber and f.FCDate_ = p.PODate_
					  from fc f left join po p on f.ItemNumber = p.ItemNumber and f.FCDate_ = p.PODate_
											left join JDE_DB_Alan.vw_Mast m on f.ItemNumber  = m.ItemNumber and f.FCDate_ = m.SOHDate   -- SOHDate is current month name,also note 'vw_Mast' is clearn without duplicated records
					 where f.Date< @dt
					 -- where f.Date < '2018-10-01'
						  -- and f.ItemNumber in ('45.103.000')
								 )
						
			   --select * from tb        
				  ,tb_ as (
							select tb.ItemNumber,tb.Date,tb.FCDate_,tb.FC_Vol,tb.PO_Vol,tb.SOH_Vol 
									,case 
										   when tb.Date >DATEADD(mm, DATEDIFF(m,0,GETDATE()),0)  then (tb.PO_Vol -tb.FC_Vol)
										   when tb.date = DATEADD(mm, DATEDIFF(m,0,GETDATE()),0) then (tb.PO_Vol -tb.FC_Vol + tb.SOH_Begin_M)
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
				 ,t_ as ( select t.ItemNumber,t.Date,t.FCDate_,t.FC_Vol,t.PO_Vol,t.SOH_Vol,t.SOH_Vol_
									,case 
											when t.mySOH_Begin_M_ is null then t.SOH_Begin_M
											else t.mySOH_Begin_M_
									  end as  Final_SOH_Begin_M_
									,t.SOH_End_M_,t.rnk
									,t.WholeSalePrice
									--,t.myWSP
								 from t
								 )

					  --select * from t_
					  -- ,pri as ( select t_.ItemNumber,t_.WholeSalePrice from t_ where t_.WholeSalePrice is not null)

					 --  select * from pri
					--   ,_t as ( select t_.*,																			-- cost too long time to run
								   --       case when t_.WholeSalePrice is null then pri.WholeSalePrice
											 --   else t_.WholeSalePrice
										  --  end as mywholesaleprice
									--from t_ left join pri on t_.ItemNumber = pri.ItemNumber )
          
				  ,_t as ( --select t_.ItemNumber,t_.Date,t_.FCDate_,t_.FC_Vol,t_.PO_Vol,t_.SOH_Vol,t_.SOH_Vol_,t_.Final_SOH_Begin_M_,t_.SOH_End_M_,m.WholeSalePrice     -- will spit out column by column saves the performance issue ? Not really  -- 14/5/2018
								select t_.*, mm.WholeSalePrice as Mywholesaleprice,(mm.WholeSalePrice * t_.FC_Vol) FC_Amt
									   , case when t_.Final_SOH_Begin_M_ <= 0  then 'Y 'else 'N' end as Stk_Out_Stauts
									   ,sum(t_.FC_Vol) over (partition by t_.ItemNumber order by t_.FCDate_ Rows between current row and 2 following ) as CumulativeTotal_FC_Vol_3M			-- only works in SQL 2012 upwards, if you using 2008 need to use below...  https://docs.microsoft.com/en-us/sql/t-sql/queries/select-over-clause-transact-sql?view=sql-server-2017
									   ,sum(t_.FC_Vol) over (partition by t_.ItemNumber order by t_.FCDate_ Rows between 1 following and 3 following ) as CumulativeTotal_FC_Vol_Nxt3M	
									   ,avg(t_.FC_Vol) over (partition by t_.ItemNumber) as Avg_FC_Vol_Nxt8M			--- SQL2008 support this 
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
								from t_ left join JDE_DB_Alan.vw_Mast mm on t_.ItemNumber = mm.ItemNumber )				-- note that 'vw_Mast ' has clean data 
		 
					   --select * from _t
						--where _t.ItemNumber in ('45.103.000','45.200.100','42.210.031') 
						 -- where _t.ItemNumber in ('0751031003001H')
						 --order by _t.ItemNumber,_t.Date		 

				 ,com as ( select _t.ItemNumber,_t.Date d1,_t.FCDate_ d2,'FC_Qty' as DataType,_t.FC_Vol as Value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.Leadtime_Mth,_t.PlannerNumber from _t
							   union all
							   select _t.ItemNumber,_t.Date d1,_t.FCDate_ d2,'PO_Qty' as DataType,_t.PO_Vol as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.Leadtime_Mth,_t.PlannerNumber from _t
							  union all
							   select _t.ItemNumber,_t.Date d1,_t.FCDate_ d2,'SOH_Qty' as DataType,_t.SOH_Vol_ as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.Leadtime_Mth,_t.PlannerNumber from _t
							  union all
								select _t.ItemNumber,_t.Date d1,_t.FCDate_ d2,'Start_Stk' as DataType,_t.Final_SOH_Begin_M_ as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.Leadtime_Mth,_t.PlannerNumber from _t
							  union all
								select _t.ItemNumber,_t.Date d1,_t.FCDate_ d2,'End_Stk' as DataType,_t.SOH_End_M_ as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.Leadtime_Mth,_t.PlannerNumber from _t
							  union all
								select _t.ItemNumber,_t.Date d1,_t.FCDate_ d2,'FC_Amt' as DataType,_t.FC_Amt as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.Leadtime_Mth,_t.PlannerNumber from _t				   
                              union all
								select _t.ItemNumber,_t.Date d1,_t.FCDate_ d2,'Weeks_Cover1' as DataType,coalesce(_t.SOH_End_M_/nullif(_t.CumulativeTotal_FC_Vol_Nxt3M/12,0),0) as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.Leadtime_Mth,_t.PlannerNumber from _t				  
							--  union all
							--	select _t.ItemNumber,_t.Date d1,_t.FCDate_ d2,'Weeks_Cover2' as DataType,(_t.SOH_End_M_)/(_t.Avg_FC_Vol_Nxt8M/4) as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0 from _t				  							  						  	 
							   )
             
				 select * from com 
					 --where com.Stk_Out_Stauts in ('Y')
					   -- where com.ItemNumber in ('45.103.000','45.200.100')
					--where com.ItemNumber in ('4152336048B')
				 	-- where com.ItemNumber in ( select splitdata from JDE_DB_Alan.dbo.fnSplitString(@Item_id,','))	
					  --where com.PrimarySupplier in ('20037','1102')
                    --where com.ItemNumber in ('32.501.000','18.010.035','18.615.007','18.010.036','2780229000','82.391.909','32.379.200','18.013.089','24.7002.0001','24.7334.4459','24.7102.1858','24.7219.4459','32.455.155','24.7121.4459','24.7122.4459','24.7124.4459','24.7127.4459','24.5349.4459','24.7120.4459','24.7250.4459','24.7251.4459','24.7253.4459','24.7146.4459A','24.7207.4459','24.7168.4459A','24.7169.4459A','24.7163.0000A')  
					  where com.ItemNumber in ('24.7218.4465','32.501.000','43.211.004','32.379.200','32.380.855','18.607.016','24.7201.0000','24.7102.7052','24.7102.7052','32.455.465','24.7115.0952A','24.7114.0952A','24.7128.0952','709895','24.7353.0000A','24.7136.0155A','709901','24.7120.0952')
					order by com.ItemNumber,com.DataType,com.d2