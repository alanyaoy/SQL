 ------*******************************************************------
use HDDW_PRD
go
 
---+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
---------------  Get WO parts number from Work orders --------------------------------------        17/2/2020 ----------------------
 -------------  Get all Sales history On components level across HD and AWF channel ---- by exploring Comp level details from AWF Sales order ( breaks/exploded down to parts level from Finished Blinds to component ) --- 19/3/2020

--select count(*) from HDDW_PRD.star.f_so_detail_history    --- 8,664,477 rows 104 columns - very large table 
--select count(*) from HDDW_PRD.star.f_so_detail_current    --- 16,721 row 104 columnes - small table , should be identical with _history table but 1 coloumn has different name --> column 78/79 ' BRACKET_COLOUR ' and  'BRACKET_TYPE_SIZE' are flipped


--select max(invoice_date) from [hd-vm-bi-sql01.hd.local].HDDW_PRD.star.f_so_detail_history h
--select min(invoice_date) from [hd-vm-bi-sql01.hd.local].HDDW_PRD.star.f_so_detail_history h
--select * from [hd-vm-bi-sql01.hd.local].HDDW_PRD.star.f_so_detail_history h where h.invoice_date in ('1999-08-04 00:00:00.000')

--select * from HDDW_PRD.star.f_so_detail_current c where c.order_number in ('5652689')

--select count(*) from HDDW_PRD.star.f_wo_parts_list      --- 17,656,155 rows , 96 columns --- huge table --- 2017 to 2019 ( total 3 years records of WO details )
--select * from HDDW_PRD.star.f_wo_parts_list				--- 17 million records, appox 1 min = 1 million records ( nearlly 100 columns )
--select top 3 *  from HDDW_PRD.star.f_wo_parts_list l
--select top 3 h.*  from HDDW_PRD.Star.f_so_detail_history h where h.item_code in ('52.008.104')
--select top 3 d.* from HDDW_PRD.star.d_product d 
--select * from HDDW_PRD.star.d_product d where d.item_code in ('52.008.104')

--select l.item_number,l.so_number,l.wo_number,l.quantity,l.date_updated from HDDW_PRD.star.f_wo_parts_list l where l.wo_number in ('4801649')		-- 21 records		27/7/2020
--select *  from HDDW_PRD.star.f_wo_parts_list l where l.so_number in ('5652689')		-- 21 records		27/7/2020

--select * from HDDW_PRD.star.f_wo_parts_list l						--- search 1 column only, it takes 2 mins
--select top 3 * from HDDW_PRD.star.f_wo_parts_list l					--- search 1 column only, it takes 2 mins
--select count(l.wo_number) from HDDW_PRD.star.f_wo_parts_list l  
 

 --- Where Used --- 4/11/2021  -- Find out which Finished Blind Cutomer order use Child Item then Find Out Finished Item Code and SO number

  --select * from HDDW_PRD.Star.f_wo_parts_list a inner join HDDW_PRD.star.d_product b on a.d_product_key = b.d_product_key 
  --where cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,a.order_date),0),126),'-',''),1,6) as integer)  >201701
  --     -- and  b.item_code in ('46.614.500')				--- 78MM ROLLER TUBE 5M BULK used for 'FMAT' Magnatrack Blinds
	 --  and  b.item_code in ('26.800.820')	
  --order by a.order_date
 
  --select * from HDDW_PRD.star.f_so_detail_history a where a.order_number in ('5452063')				--- '5744128','5739637'


  -----**************************************************************************************************************
  --- New way --- You get Child_name when join 'wo_parts' table with 'd_product_key' table so that you get colour of parts --- May take a bit longer to run whole query --- 7 mins
   --- To reduce query time,maybe do not use 'select * ' , select only column you need ! ---

     --- 980 ( cancelled in order entry ) , 999 ( completed ), 902 ( back order in commitment ), 620 ( ready for sales update)

  ;with so as

  (  	
		--select d_date_key,d_business_unit_key,d_customer_key,d_product_key,d_primary_uom_key,d_account_manager_key,d_product_width_key,d_product_drop_key,order_number,company_code,order_type,order_suffix,jde_business_unit,business_unit_code,sold_to_account_code,invoice_number,gl_class,order_date,ship_date,invoice_date,item_code,line_type,primary_uom,primary_quantity,sales_quantity,sales_amount,cost_amount,unit_list_price,customer_number,last_line_status_code,next_line_status_code,work_order_number,BLIND_SQUARE_MT,BRAND,COLOUR,COMPONENT_COLOUR,DROP_MM,FABRIC_TYPE,WIDTH,Drop_Band_Code,Width_Band_Code,dss_record_source,dss_load_date,dss_batch_load_date,dss_create_time,dss_update_time,ship_to,shipped_quantity,backordered_quantity from HDDW_PRD.star.f_so_detail_history h
		  select * from HDDW_PRD.star.f_so_detail_history h
		union all
		 --select * from HDDW_PRD.star.f_so_detail_current c where c.last_line_status_code + c.next_line_status_code <> '980999' and c.item_code in ('FAMT')  --- 12196
		-- select * from HDDW_PRD.star.f_so_detail_current c where c.last_line_status_code <> '980' and c.next_line_status_code <> '999' and c.item_code in ('FAMT')  --- 11810
		
		 --select d_date_key,d_business_unit_key,d_customer_key,d_product_key,d_primary_uom_key,d_account_manager_key,d_product_width_key,d_product_drop_key,order_number,company_code,order_type,order_suffix,jde_business_unit,business_unit_code,sold_to_account_code,invoice_number,gl_class,order_date,ship_date,invoice_date,item_code,line_type,primary_uom,primary_quantity,sales_quantity,sales_amount,cost_amount,unit_list_price,customer_number,last_line_status_code,next_line_status_code,work_order_number,BLIND_SQUARE_MT,BRAND,COLOUR,COMPONENT_COLOUR,DROP_MM,FABRIC_TYPE,WIDTH,Drop_Band_Code,Width_Band_Code,dss_record_source,dss_load_date,dss_batch_load_date,dss_create_time,dss_update_time,ship_to,shipped_quantity,backordered_quantity from HDDW_PRD.star.f_so_detail_current c where not ( c.last_line_status_code = '980' and c.next_line_status_code = '999')		--- 13022  -- use this one !!
		 select * from HDDW_PRD.star.f_so_detail_current c where not ( c.last_line_status_code = '980' and c.next_line_status_code = '999')		--- 13022  -- use this one !!
		
		-- select * from HDDW_PRD.star.f_so_detail_current c where (not c.last_line_status_code = '980')  or ( not c.next_line_status_code = '999')  --- 13022
		-- select * from HDDW_PRD.star.f_so_detail_current c where ( c.last_line_status_code <> '980')  or (  c.next_line_status_code <> '999')  --- 13022
		        
		)
  --select * from  so

   ----- Get your part list --- Filter out duplicated records if WO is updated different times --- 11/6/2020
   ,_pr as ( 
			select  -- pr.*
			        pr.item_code as Child_code,pr.date_updated,pr.so_number,pr.wo_number,pr.d_product_key as Child_key,pr.parts_description2 as Child_descrp,pr.quantity as Child_Qty,pr.uom as Child_UOM ,pd.item_name as Child_name
			       --,row_number() over(partition by pr.item_code order by date_updated ) rn  
				   --,sum(unique_id)over(partition by pr.item_code,pr.date_updated order by pr.updated_time) rn 
				  -- ,max(unique_id)over(partition by pr.item_code,date_updated order by pr.item_code) rn 
				  -- ,max(date_updated) as latest
				  -- max(unique_id)
				  --,max(date_updated)
				 -- ,max(date_updated)over(partition by pr.item_code order by pr.item_code) max_ 
					,max(date_updated)over(partition by pr.wo_number,pr.item_code order by pr.item_code) max_		-- 27/7/2020 major update you need to partition first by wo-number ( which is unique ) otherwise yield dt will be wrong
			FROM HDDW_PRD.star.f_wo_parts_list pr 
												left join HDDW_PRD.star.d_product pd on pr.d_product_key = pd.d_product_key 
			--where pr.so_number in ('5642227') and pr.wo_number in ('4769683') and pr.item_code in ('24.7100.0199')
			--group by pr.item_code,pr.date_updated
			)
   , pr as ( 
				select * 
				from _pr 
				where _pr.date_updated = _pr.max_)
     -- select * from pr

   select so.order_number as So_num,so.work_order_number as So_wo_num,pr.wo_number as Part_wo_num
					 ,so.d_product_key as Parent_pd_key,so.item_code as Parent,pr.Child_key,pr.Child_code,pr.Child_descrp
					 ,pr.Child_name
					 ,so.primary_quantity as ParentSoldQty,pr.Child_Qty,isnull(pr.Child_qty/1000, 0) as ChildQty_f,pr.Child_UOM,c.contact_name as customer,so.order_date
					 ,so.BRAND,c.sold_to_account_manager_name,c.channel_name

					 ,cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,so.order_date),0),126),'-',''),1,8) as integer) as Inv_YYMMDD	      --- 1st day of each month,so actually by month
					  ,cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,so.order_date),0),126),'-',''),1,6) as integer) as Inv_YYMM	
					   ,cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,so.order_date),0),126),'-',''),1,4) as integer) as Inv_YY
			
	from so left join pr on so.work_order_number = pr.wo_number
	     			   left join  star.d_product pd on so.d_product_key = pd.d_product_key 
					   left join [hd-vm-bi-sql01].HDDW_PRD.star.d_customer c on so.d_customer_key = c.d_customer_key
	where 
					--So.item_code in ('FAMT')
				  --  and so.jde_business_unit = 'AWF'    
					--and so.work_order_number = '04685890'   
					--and pr.item_code in ('42.421.855','52.018.000','44.011.007')
					  --so.order_number in ('5623307')					   ---  Sun Solution WA Dummy order
					 --  so.order_number in ('5626957')				        -- Sun Solution WA
					  --  so.order_number in ('5641025')						--  DUMMY ORDER FOR FABRIQUE FOR LARGE COMMERCIAL ORDER 5641025 -- 1/6/2020
					 --  so.order_number in ('5642227')							--  NELLIE MELBA RETIREMENT Vic            11/6/2020
					 --   so.order_number in ('5652197')							-- Wilkins Construction ESMO Project		22/7/2020
					--   so.order_number in ('5652689')							-- query take 2 minutes 38 sec to run... GEELONG APARTMENTS Project / WO - 4801649				24/7/2020
					-- so.order_number in ('5653693')	
					--and so.order_number in ('5707259')
					 -- so.order_number in ('5452063')
					  so.order_number in ('5788601')				--- 'VBWE'  -- Timber VB - Wood essence
					--so.order_number in ('5685884','5685891','5685911','5685923')					--John Flynn Burwood  - 5685884
																									--Highton Geelong – 5685891
																									--Wheelers hill – 5685911
																									--Ocean grove – 5685923
			and cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,so.order_date),0),126),'-',''),1,6) as integer)  >201701																						 
   order by so.order_number



 --  select * from star.d_product pd
