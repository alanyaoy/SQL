
-------------   HDDDW -- Hunter Douglas Data Warehouse Master ---------------------

 ---=================How to Skip SQL Query --- Method 3   30/7/2018= ================================================================= 
 --https://stackoverflow.com/questions/659188/sql-server-stop-or-break-execution-of-a-sql-script?noredirect=1&lq=1

print 'hi'
go

print 'Fatal error, script will not continue!'

set noexec on
print 'ho'
go

------*******************************************************------
use HDDW_PRD
go


SELECT
    @@SERVERNAME AS TargetServerName,
    SUSER_SNAME() AS ConnectedWith,
    DB_NAME() AS DefaultDB,
    client_net_address AS IPAddress
FROM
    sys.dm_exec_connections
WHERE
    session_id = @@SPID

select local_net_address,* FROM sys.dm_exec_connections


/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [d_region_key]
      ,[region_code]
      ,[region_name]
      ,[dss_record_source]
      ,[dss_load_date]
      ,[dss_batch_load_date]
      ,[dss_create_time]
      ,[dss_update_time]
  FROM [HDDW_PRD].[Star].[d_region]


---================= *** Find Server name *** ================================---
select @@SERVERNAME

--- Find Linked Server ---
select * from sys.servers where is_linked = 1

select top 3 * from [hd-vm-bi-sql01].HDDW_PRD.star.d_region

---------- remember you have admin right in 'JDE_DB_Alan ' db, so you have control and can link to '[hd-vm-bi-sql01].HDDW_PRD' , however you cannot do reverse because you do not control data warehouse and you do not have control , unless you have admin right to set access to hdd dw. ----
---------- However you do not have access and cannot query directly from 'hdd dw' database to your 'JDE_DB_ALan' database ---------

select * from HD_2016EXPAD.JDE_DB_Alan.vw_Mast						--- does not work as of 10/12/2019 as there is no linked server
select * from [RYDWS366\HD_2016EXPAD].JDE_DB_Alan.dbo.cj			--- does not work
select * from [RYDWS366\HD_2016EXPAD].JDE_DB_Alan.jde_db_alan.vw_Mast    --- does not work

select * from [hd-vm-bi-sql01].HDDW_PRD.star.d_product p where p.item_code in ('44.011.007')

select * from HDDW_PRD.star.f_so_detail_history h where h.order_number like ('5641025%')

with _pr as ( 
			select pr.item_code,pr.date_updated
			       --,row_number() over(partition by pr.item_code order by date_updated ) rn  
				   --,sum(unique_id)over(partition by pr.item_code,pr.date_updated order by pr.updated_time) rn 
				  -- ,max(unique_id)over(partition by pr.item_code,date_updated order by pr.item_code) rn 
				  -- ,max(date_updated) as latest
				  -- max(unique_id)
				  --,max(date_updated)
				  --,max(date_updated)over(partition by pr.item_code order by pr.item_code) max_ 
				  ,max(date_updated)over(partition by pr.wo_number,pr.item_code order by pr.item_code) max_			-- 27/7/2020 major update you need to partition first by wo-number ( which is unique ) otherwise yield dt will be wrong
			FROM HDDW_PRD.star.f_wo_parts_list pr 
			where pr.so_number in ('5642227') and pr.wo_number in ('4769683') and pr.item_code in ('24.7100.0199')
			--group by pr.item_code,pr.date_updated
			)
   , pr_ as ( 
				select * 
				from _pr 
				where _pr.date_updated = _pr.max_)
  select * from pr_


------------------------------ *** Using HDD - DW Database *** ------------------------------------------------- 5/3/2020
---------------------------- Some statistic about tables in HDD DW ---------------------------- ---------------------------
select count(*) from Star.f_so_detail_history
select top 3 h.*  from Star.f_so_detail_history h

select c.contact_name,h.*  from Star.f_so_detail_history h left join star.d_customer c on h.d_customer_key = c.d_customer_key
  where   h.item_code in ('32.379.200')					---3419 rows
		and cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,h.invoice_date),0),126),'-',''),1,6) as integer) >201910		--- 36 rows
		

--- SKU count by stock type ---

with a as (select p.stock_type_code,count(*) as SKU_Count from star.d_product p group by p.stock_type_code	 )
	,b as ( select a.stock_type_code,a.SKU_Count, sum(a.SKU_Count) over () as N from a group by a.stock_type_code,a.SKU_Count )
    select b.*,cast(cast(b.SKU_Count as decimal(10,2))/ cast(b.N as decimal (10,2)) as decimal(10,3)) as  Pecert from b 
	order by b.SKU_Count desc

--- SKU count by stock type by business unit ---
with a as (select p.business_unit_code,p.stock_type_code,count(*) as SKU_Count from star.d_product p group by p.business_unit_code,p.stock_type_code  )
	,b as ( select a.business_unit_code,a.stock_type_code,a.SKU_Count, sum(a.SKU_Count) over () as N from a group by a.business_unit_code,a.stock_type_code,a.SKU_Count )
    select b.*,cast(cast(b.SKU_Count as decimal(10,2))/ cast(b.N as decimal (10,2)) as decimal(10,3)) as  Pecert from b 
	where b.business_unit_code not in ('AP','BR')
	--order by b.business_unit_code,b.SKU_Count desc
	order by b.business_unit_code,b.SKU_Count desc


select top 10 p.* from star.d_product p 
select top 10 p.* from star.d_product p where p.business_unit_code in ('BM')
select  p.* from star.d_product p where p.item_code in ('44.011.007')                               -- note 'item_code' 2nd item number,'item_number' is short item number in 'Product' table in data warehouse 28/2/2020


select * from star.d_product p where p.business_unit_code in ('BM','CO')			--- 73,765 records
select * from star.d_product p where p.business_unit_code in ('BM','CO') and p.stock_type_code in ('P','S','Q','P')  --- 13,845 records
select p.business_unit_code,count(*) from star.d_product p group by p.business_unit_code


select count(*) from star.d_customer 
select top 10 c.* from star.d_customer c 

select *
from star.d_customer c 
where c.contact_name like ('%lovelight%')
--where c.customer_number in ('2088109')
order by c.customer_number


select * from HDDW_PRD.Star.d_customer


--------------05/03/2020 Work started using HDD - DW tables -------------------------------

;with wcc as 
		( select top 3 *
		  from HDDW_PRD.star.f_so_detail_history h
		  where h.jde_business_unit in ('HD')						-- important !
		  )

   select * from wcc
   
   
select count(*) from HDDW_PRD.star.f_so_detail_history    --- 8,664,477 rows 104 columns - very large table 
select count(*) from HDDW_PRD.star.f_so_detail_current    --- 16,721 row 104 columnes - small table , should be identical with _history table but 1 coloumn has different name --> column 78/79 ' BRACKET_COLOUR ' and  'BRACKET_TYPE_SIZE' are flipped


select max(invoice_date) from [hd-vm-bi-sql01.hd.local].HDDW_PRD.star.f_so_detail_history h
select min(invoice_date) from [hd-vm-bi-sql01.hd.local].HDDW_PRD.star.f_so_detail_history h
select * from [hd-vm-bi-sql01.hd.local].HDDW_PRD.star.f_so_detail_history h where h.invoice_date in ('1999-08-04 00:00:00.000')

select * from HDDW_PRD.star.f_so_detail_current c where c.order_number in ('5652689')

select count(*) from HDDW_PRD.star.f_wo_parts_list      --- 17,656,155 rows , 96 columns --- huge table --- 2017 to 2019 ( total 3 years records of WO details )
select * from HDDW_PRD.star.f_wo_parts_list				--- 17 million records, appox 1 min = 1 million records ( nearlly 100 columns )
select top 3 *  from HDDW_PRD.star.f_wo_parts_list l
select top 3 h.*  from HDDW_PRD.Star.f_so_detail_history h

select l.item_number,l.so_number,l.wo_number,l.quantity,l.date_updated from HDDW_PRD.star.f_wo_parts_list l where l.wo_number in ('4801649')		-- 21 records		27/7/2020
select *  from HDDW_PRD.star.f_wo_parts_list l where l.so_number in ('5652689')		-- 21 records		27/7/2020


select l.wo_number from HDDW_PRD.star.f_wo_parts_list l    --- search 1 column only, it takes 2 mins


---------------- Product hierarchy -------------------

select count(*) from HDDW_PRD.Star.d_product p
select top 3 * from HDDW_PRD.Star.d_product p 

select p.item_code,p.item_name,p.business_unit_code,p. from HDDW_PRD.Star.d_product p 

select * from  [hd-vm-bi-sql01.hd.local].HDDW_PRD.star.d_product			--- not working, has to use [hd-vm-bi-sql01]

select distinct business_unit_code,business_unit_name from HDDW_PRD.Star.d_product p

select top 3 * from HDDW_PRD.Star.d_product p



select distinct 
		--item_code,item_name,
		business_unit_code,business_unit_name
	   ,price_group_code,price_group_desc,family_group_code,family_desc,family_code,family_desc
	   ,HDLive_Category_code,HDLive_Category	   
	   
 from HDDW_PRD.Star.d_product p
 --where business_unit_code in ('BM')			--- blindmaker , CO for Components


---=============================================================================================================
     
 
---==========================================================================================================================================
---------------  Get WO parts number from Work orders --------------------------------------        17/2/2020 ----------------------
 -------------  Get all Sales history On components level across HD and AWF channel ---- by exploring Comp level details from AWF Sales order ( breaks/exploded down to parts level from Finished Blinds to component ) --- 19/3/2020

select count(*) from HDDW_PRD.star.f_so_detail_history    --- 8,664,477 rows 104 columns - very large table 
select count(*) from HDDW_PRD.star.f_so_detail_current    --- 16,721 row 104 columnes - small table , should be identical with _history table but 1 coloumn has different name --> column 78/79 ' BRACKET_COLOUR ' and  'BRACKET_TYPE_SIZE' are flipped


select max(invoice_date) from [hd-vm-bi-sql01.hd.local].HDDW_PRD.star.f_so_detail_history h
select min(invoice_date) from [hd-vm-bi-sql01.hd.local].HDDW_PRD.star.f_so_detail_history h
select * from [hd-vm-bi-sql01.hd.local].HDDW_PRD.star.f_so_detail_history h where h.invoice_date in ('1999-08-04 00:00:00.000')

select * from HDDW_PRD.star.f_so_detail_current c where c.order_number in ('5652689')

select count(*) from HDDW_PRD.star.f_wo_parts_list      --- 17,656,155 rows , 96 columns --- huge table --- 2017 to 2019 ( total 3 years records of WO details )
select * from HDDW_PRD.star.f_wo_parts_list				--- 17 million records, appox 1 min = 1 million records ( nearlly 100 columns )
select top 3 *  from HDDW_PRD.star.f_wo_parts_list l
select top 3 h.*  from HDDW_PRD.Star.f_so_detail_history h where h.item_code in ('52.008.104')
select top 3 d.* from HDDW_PRD.star.d_product d 
select * from HDDW_PRD.star.d_product d where d.item_code in ('52.008.104')

select l.item_number,l.so_number,l.wo_number,l.quantity,l.date_updated from HDDW_PRD.star.f_wo_parts_list l where l.wo_number in ('4801649')		-- 21 records		27/7/2020
select *  from HDDW_PRD.star.f_wo_parts_list l where l.so_number in ('5652689')		-- 21 records		27/7/2020


select * from HDDW_PRD.star.f_wo_parts_list l						--- search 1 column only, it takes 2 mins
select top 3 * from HDDW_PRD.star.f_wo_parts_list l					--- search 1 column only, it takes 2 mins
select count(l.wo_number) from HDDW_PRD.star.f_wo_parts_list l      

--- Note:
--- F3111 is JDE table on which work order fetched from...
--- F4211  is Jde table which stores 'Open sales' order - Sales order which has not been materilized yet ( anything could happen ) - 980/990 cancelled order need to be excluded;
---  F42119 is Jde table which stores 'CLosed sale' order - invoiced history - 620/980 invoiced.


--- combined sales (history + open sales order ) ---  17/2/2020
--- Not Or And Combined ... http://www.peachpit.com/articles/article.aspx?p=1276352&seqNum=6

 --------------------------------------------------------------------------------------------------------------------------
  --- New way --- You get Child_name when join 'wo_parts' table with 'd_product_key' table so that you get colour of parts --- May take a bit longer to run whole query --- 7 mins
   --- To reduce query time,maybe do not use 'select * ' , select only column you need ! ---

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
	where So.item_code in ('FAMT')
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
					--so.order_number in ('5685884','5685891','5685911','5685923')					--John Flynn Burwood  - 5685884
																									--Highton Geelong – 5685891
																									--Wheelers hill – 5685911
																									--Ocean grove – 5685923
   order by so.order_number


  -----------------------------------------------------------------------------------------------------------------------
  --- Old code to get Child_name so you get colour for parts ( note you join 'd_product_key' table at very end of entire query -- Not bad, it is clean ) --- 7 mins
   --- To reduce query time,maybe do not use 'select * ' , select only column you need ! --- 
 

  ;with so as

  (  select * from HDDW_PRD.star.f_so_detail_history h
		union all		
	 select * from HDDW_PRD.star.f_so_detail_current c where not ( c.last_line_status_code = '980' and c.next_line_status_code = '999')		--- 13022  -- use this one !!		        
		)

   ----- Get your part list --- Filter out duplicated records if WO is updated different times --- 11/6/2020
   ,_pr as ( 
			select 
			        pr.item_code as Child_code,pr.date_updated,pr.so_number,pr.wo_number,pr.d_product_key as Child_key,pr.parts_description2 as Child_descrp,pr.quantity as Child_Qty,pr.uom as Child_UOM ---,pd.item_name as Child_name
					,max(date_updated)over(partition by pr.wo_number,pr.item_code order by pr.item_code) max_		-- 27/7/2020 major update you need to partition first by wo-number ( which is unique ) otherwise yield dt will be wrong
			FROM HDDW_PRD.star.f_wo_parts_list pr  
									--left join HDDW_PRD.star.d_product pd on pr.d_product_key = pd.d_product_key 
			--where pr.so_number in ('5642227') and pr.wo_number in ('4769683') and pr.item_code in ('24.7100.0199')
			--group by pr.item_code,pr.date_updated
			)
   , pr as ( 
				select * 
				from _pr 
				where _pr.date_updated = _pr.max_)
 
   ,blinds_tb as 
			( select so.order_number as So_num,so.work_order_number as So_wo_num,pr.wo_number as Part_wo_num
					 ,so.d_product_key as Parent_pd_key,so.item_code as Parent,pr.Child_key,pr.Child_code,pr.Child_descrp
					 --,pr.Child_name
					 ,so.primary_quantity as ParentSoldQty,pr.Child_Qty,isnull(pr.Child_qty/1000, 0) as ChildQty_f,pr.Child_UOM,c.contact_name as customer,so.order_date
					 ,so.BRAND,c.sold_to_account_manager_name,c.channel_name

					 ,cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,so.order_date),0),126),'-',''),1,8) as integer) as Inv_YYMMDD	      --- 1st day of each month,so actually by month
					  ,cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,so.order_date),0),126),'-',''),1,6) as integer) as Inv_YYMM	
					   ,cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,so.order_date),0),126),'-',''),1,4) as integer) as Inv_YY
			
			   from so left join pr on so.work_order_number = pr.wo_number
					   left join  star.d_product pd on so.d_product_key = pd.d_product_key 
					   left join [hd-vm-bi-sql01].HDDW_PRD.star.d_customer c on so.d_customer_key = c.d_customer_key
			   where So.item_code in ('FAMT')
			  -- order by so.order_number
			  )
   
     select * from blinds_tb a left join HDDW_PRD.Star.d_product b on a.Child_key = b.d_product_key 

  -------------------------------------------------------------------------------------------------------------------------
  

  ------------------------------------------------------------------------------------------------------------------------
select top 3 h.*  from Star.f_so_detail_history h

select * from HDDW_PRD.Star.f_so_detail_history h
--where h.order_number in ('5623307','05641025')
where h.order_number in ('5642227')
		
select * from HDDW_PRD.Star.f_so_detail_current c 
--where c.order_number in ('05623307','375567','05641025')
where c.order_number in ('5642227')

select top 3 * from HDDW_PRD.Star.f_so_detail_current c
select * from HDDW_PRD.Star.f_so_detail_current c where c.order_number in ('5641025')
select * from HDDW_PRD.Star.f_so_detail_current c where c.order_number in ('05641025')

 --- get simple FAMT blinds level sales --- 364 
select h.d_business_unit_key,h.d_customer_key,h.d_product_key,h.d_account_manager_key,h.order_number,h.company_code,h.order_type,h.jde_business_unit,h.business_unit_code,h.sold_to_account_code,h.invoice_number,h.gl_class,h.order_date,h.ship_date,h.invoice_date,h.item_code,h.pricing_uom,h.primary_quantity,h.sales_quantity,h.sales_amount,h.cost_amount,h.unit_list_price ,h.customer_number,h.last_line_status_code,h.next_line_status_code,h.work_order_number,h.dss_record_source,c.d_customer_key,c.customer_number,c.contact_name,c.sold_to_account_code,c.sold_to_account_manager_name,c.channel_name,c.state_code  
from HDDW_PRD.star.f_so_detail_history h left  join star.d_customer c on h.d_customer_key = c.d_customer_key
        --where h.item_code in ('38.001.005')
 where h.item_code in ('FAMT')

select * from HDDW_PRD.star.f_so_detail_history h left join star.d_customer c on h.d_customer_key = c.d_customer_key
where h.item_code in ('FAMT') and h.order_number in ('05614583')

select * from HDDW_PRD.star.f_wo_parts_list p
where p.wo_number in ('04685890') 


select * from HDDW_PRD.Star.d_customer
select * from HDDW_PRD.star.d_product p where p.item_code in ('RBSC','38.001.005','24.7334.0199') and p.jde_business_unit = 'HD'

--- 28/2/2020 --- cannot find records
select * from HDDW_PRD.Star.f_so_detail_history h
--where h.item_code in ('38.001.005')
where h.order_number in ('375568')


select p.item_code,h.*
from HDDW_PRD.star.f_so_detail_history h left join  star.d_product p  on h.d_product_key = p.d_product_key 
where p.item_code in ('38.001.005')


-------------------- To Get All sales history for '44.011.007' fibre glass using Sales history table including all channels ie AWF, WCC etc -----------------------------

select h.item_code,h.d_product_key,h.d_customer_key,h.d_account_manager_key,h.order_number,h.company_code,h.order_type,h.jde_business_unit,h.business_unit_code
       ,h.sold_to_account_code,h.invoice_number,h.gl_class,h.order_date,h.ship_date,h.invoice_date,h.item_code,h.pricing_uom,h.primary_quantity,h.sales_quantity,h.sales_amount,h.cost_amount,h.unit_list_price
	   ,h.customer_number,h.last_line_status_code,h.next_line_status_code,h.work_order_number,h.dss_record_source,c.d_customer_key,c.customer_number,c.contact_name,c.sold_to_account_code,c.sold_to_account_manager_name,c.channel_name,c.state_code  
from HDDW_PRD.star.f_so_detail_history h left  join star.d_customer c on h.d_customer_key = c.d_customer_key
        --where h.item_code in ('38.001.005')
-- where h.item_code in ('44.011.007')
	where h.item_code in ('18.019.013')	
-------------------------------------------------------

--------------- DW ----------------- Guru's query ---

select  f.jde_business_unit, substring( cast(f.d_date_key as varchar) , 1, 6) Order_YYMM
		 ,d.price_group_desc, d.family_group_desc,u.primary_uom_name, 
		sum(f.primary_quantity)   primary_quantity		 

from HDDW_PRD.star.f_so_detail_history  f join  star.d_product  d 	on f.d_product_key = d.d_product_key 
								join star.d_primary_uom u 	on f.d_primary_uom_key = u.d_primary_uom_key 

where    d.item_code = '31121765'
group by f.jde_business_unit, 
		substring( cast(f.d_date_key as varchar) , 1, 6) , 
		 d.price_group_desc, d.family_group_desc,   u.primary_uom_name 
		 order by 1, 2 


-----------------Alan's query --------------------------------------------------------------

select count(*) from dv.ds_F42119
select count(*) from star.f_wo_parts_list
select top 3 * from star.f_wo_parts_list
select min(l.requested_date), max(l.requested_date) from star.f_wo_parts_list l

select count(*) from star.f_so_detail_history
select top 3 * from star.f_so_detail_history h

;with z as (
		select h.jde_business_unit, count(h.order_number) as sales_ct 
		from star.f_so_detail_history h
		group by h.jde_business_unit
		 )

	select z.*,sum(sales_ct)over() as ttl_sales_ct from z
	order by sales_ct desc


select count(*) from star.f_so_detail_history h where h.jde_business_unit in ('AWF')


----------------- AWF Blinds Sales history -----------------
-- xxxxxxxxxxx ---  Order date ---xxxxxxxxxxxx --- do not use , use Invoice date 
select  h.jde_business_unit        
		,h.item_code,p.d_product_key		
		 ,p.price_group_desc
		  ,h.d_customer_key
		  ,c.customer_number
		 ,c.contact_name

		 ,p.family_group_desc,p.family_group_code
		 ,p.family_desc,p.family_code
		 ,u.primary_uom_name 		 
		 ,substring( cast(h.d_date_key as varchar) , 1, 6) Order_YYMM
		--  ,cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,h.invoice_date)-37,0),126),'-',''),1,6) as integer) as Inv_YYMM	
		,sum(h.primary_quantity)   primary_quantity		 

from [hd-vm-bi-sql01].HDDW_PRD.star.f_so_detail_history h left join  [hd-vm-bi-sql01].HDDW_PRD.star.d_product  p 	on h.d_product_key = p.d_product_key 
								left join [hd-vm-bi-sql01].HDDW_PRD.star.d_primary_uom u 	on h.d_primary_uom_key = u.d_primary_uom_key 
								left join [hd-vm-bi-sql01].HDDW_PRD.star.d_customer c on h.d_customer_key = c.d_customer_key

--where    d.item_code = '31121765'
where  --  h.item_code = '44.011.007'
          --h.item_code = '32.379.200'
		  --h.item_code in ('PRHI1')
		  --h.item_code in ('RBSC')
  --where f.order_number in ('5456172')
group by h.jde_business_unit         
		 ,h.item_code,p.d_product_key	 
		 ,p.price_group_desc
		 ,h.d_customer_key
		 ,c.customer_number
		 ,c.contact_name

		 ,p.family_group_desc
		 ,p.family_group_code
		 ,p.family_desc
		 ,p.family_code
		 ,u.primary_uom_name 
		 ,substring( cast(h.d_date_key as varchar) , 1, 6) 
		 --,cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,h.invoice_date)-37,0),126),'-',''),1,6) as integer) 
 order by h.item_code
          ,cast(substring( cast(h.d_date_key as varchar) , 1, 6) as int)
		 -- ,cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,h.invoice_date)-37,0),126),'-',''),1,6) as integer)


	--- Invoice history --- Sales by month by customer ( original sales is by each date so has to be grouped by month otherwise too much lines )  , Invoive date ---xxxxxxxxxxxx --- Use this one , not Order date
	--- Note when you aggregate by Sales qty ( not primary qty ), if UOM is different each month for one customer ( which is rare ) then you might get sum by different UOM by month --- so it is better to use primary UOM
select  h.jde_business_unit        
		,h.item_code,p.d_product_key		
		--- ,p.price_group_desc			--use Item_name instead
		,p.item_name

		 ,h.d_customer_key
		  ,c.customer_number
		 ,c.contact_name
		
		 --,p.family_group_desc
		 ,p.family_group_code		-- use code instead of desc
		 ,p.family_code
		 ,p.business_unit_code		-- use code instead
		 ,p.business_unit_name

		 ,u.primary_uom_code	as UOM_PR	-- use code instead
		  ,h.pricing_uom   as UM_PX
		--  ,u.primary_uom_name 		 
		-- ,p.jde_business_unit		-- duplicate you already have bu in history table

		-- ,substring( cast(f.d_date_key as varchar) , 1, 6) Order_YYMM
		  ,cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,h.invoice_date),0),126),'-',''),1,8) as integer) as Inv_YYMMDD	
		  ,cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,h.invoice_date),0),126),'-',''),1,6) as integer) as Inv_YYMM	
		,sum(h.primary_quantity)   primary_quantity	
		,sum(h.sales_quantity)    sales_quantitiy
		,sum(h.sales_amount)      sales_amount	 	 

from [hd-vm-bi-sql01].HDDW_PRD.star.f_so_detail_history h left join  [hd-vm-bi-sql01].HDDW_PRD.star.d_product  p 	on h.d_product_key = p.d_product_key 
								left join [hd-vm-bi-sql01].HDDW_PRD.star.d_primary_uom u 	on h.d_primary_uom_key = u.d_primary_uom_key 
								left join [hd-vm-bi-sql01].HDDW_PRD.star.d_customer c on h.d_customer_key = c.d_customer_key

--where    d.item_code = '31121765'
where 
	--h.item_code = '38.004.000'
      h.item_code = '38.001.005'
	  --  h.item_code = '18.019.013'				--- anti bacterial wipe
	 -- h.item_code = '44.011.007'
   --where f.order_number in ('5456172')
   --  and h.invoice_date is not null				--- do you need to include SKUs with no invoice date but possible with Order date ?
        --and p.business_unit_name = 'Blindmaker'     --- do you need this one ? DOes AWF selling components ?  10/12/2019
		-- and p.business_unit_name = 'Components'      --- state expplicitly albeit h.business_unit is in 'select' clause
		 -- and cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,h.invoice_date),0),126),'-',''),1,6) as integer) >201910
		-- h.order_number in ('5456172')
group by h.jde_business_unit         
		 ,h.item_code,p.d_product_key	 
		 --,p.price_group_desc
		 ,p.item_name
		 
		  ,h.d_customer_key
		  ,c.customer_number
		 ,c.contact_name

		 --,p.family_group_desc
		 ,p.family_group_code
		 ,p.family_code
		 ,p.business_unit_code
		 ,p.business_unit_name

		 ,u.primary_uom_code
		-- ,u.primary_uom_name
		,h.pricing_uom  
		-- ,p.jde_business_unit
		 --,substring( cast(f.d_date_key as varchar) , 1, 6) Order_YYMM
		  ,cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,h.invoice_date),0),126),'-',''),1,8) as integer)
		 ,cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,h.invoice_date),0),126),'-',''),1,6) as integer) 
 order by h.item_code
         -- ,cast(substring( cast(f.d_date_key as varchar) , 1, 6) as int)
		  ,cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,h.invoice_date),0),126),'-',''),1,6) as integer)


---------------------------------- WCC history ------------------ HD Parts --------------------------------------

-------- Note that HD history includes sales history sold to AWF ( also include sales for WCC channel customer ) ---------
--------- but HD sales history does not have details of where is components history originated for which customer ) and how much is from which blinds ---- we need seconds layer of details underneath ------

	-- xxxxxxxxxxx --- Sales by month by customer ( original sales is by each date so has to be grouped by month otherwise too much lines )  , Invoive date ---xxxxxxxxxxxx --- Use this one , not Order date
	--- Note when you aggregate by Sales qty ( not primary qty ), if UOM is different each month for one customer ( which is rare ) then you might get sum by different UOM by month --- so it is better to use primary UOM
select  h.jde_business_unit        
		,h.item_code,p.d_product_key		
		--- ,p.price_group_desc			--use Item_name instead
		,p.item_name

		 ,h.d_customer_key
		  ,c.customer_number
		 ,c.contact_name
		
		 --,p.family_group_desc
		 ,p.family_group_code		-- use code instead of desc
		 ,p.family_code
		 ,p.business_unit_code		-- use code instead
		 ,p.business_unit_name

		   ,u.primary_uom_code	as UM_PM	-- use code instead
		   ,h.pricing_uom   as UM_PX
		--  ,u.primary_uom_name 		 
		-- ,p.jde_business_unit		-- duplicate you already have bu in history table

		-- ,substring( cast(f.d_date_key as varchar) , 1, 6) Order_YYMM
		  ,cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,h.invoice_date),0),126),'-',''),1,8) as integer) as Inv_YYMMDD	      --- 1st day of each month,so actually by month
		  ,cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,h.invoice_date),0),126),'-',''),1,6) as integer) as Inv_YYMM	
		,sum(h.primary_quantity)   primary_quantity	
		,sum(h.sales_quantity)    sales_quantitiy
		,sum(h.sales_amount)      sales_amount	 

from [hd-vm-bi-sql01].HDDW_PRD.star.f_so_detail_history h left join  [hd-vm-bi-sql01].HDDW_PRD.star.d_product  p 	on h.d_product_key = p.d_product_key 
								left join [hd-vm-bi-sql01].HDDW_PRD.star.d_primary_uom u 	on h.d_primary_uom_key = u.d_primary_uom_key 
								left join [hd-vm-bi-sql01].HDDW_PRD.star.d_customer c on h.d_customer_key = c.d_customer_key

--where    d.item_code = '31121765'
where  -- h.item_code = '26.119.347' 
	--  h.item_code = '44.011.007'
	--h.item_code = '24.7219.4460'
	--  h.item_code in ('40.132.131','40.129.378','40.197.850','40.129.433')
	--  h.item_code = '38.001.005'
	 --  h.item_code in ('2920436000')
	  --  h.item_code in ('82.374.904')
	  --h.item_code in ('24.7002.0000','24.7002.0000T','24.7207.0952')
	  --h.item_code in ('FT.01468.000.01')
	  --h.item_code in ('43.212.003')
	 -- h.item_code in ('2781211001','2780034000B')
	 --  h.item_code in ('24.7334.0199')
	  --h.item_code in ('38.004.000s')
	--  h.item_code in ('26.802.820','26.803.820')
	  --  h.item_code in ('46.612.700','46.522.500','46.005.850','46.005.000')
	-- h.item_code in ('27.252.000','27.253.000','27.257.000','27.258.000','27.170.135','27.170.810','27.170.661','27.170.862','27.170.879','27.170.048','27.170.785','27.171.810','27.171.661','27.171.862','27.171.879','27.171.048','27.171.785','27.175.810','27.175.661','27.175.862','27.175.879','27.175.048','27.175.785','27.176.810','27.176.661','27.176.862','27.176.879','27.176.048','27.176.785','27.174.810','27.174.661','27.174.862','27.174.879','27.174.048','27.174.785','27.160.661','27.160.862','27.160.879','27.160.882','27.160.320','27.160.785','27.161.661','27.161.862','27.161.879','27.161.882','27.161.320','27.161.785','27.162.661','27.162.862','27.162.879','27.162.882','27.162.320','27.162.785','27.163.661','27.163.862','27.163.879','27.163.882','27.163.320','27.163.785','27.164.661','27.164.862','27.164.879','27.164.882','27.164.320','27.164.785','27.165.661','27.165.862','27.165.879','27.165.882','27.165.320','27.165.785','27.166.661','27.166.862','27.166.879','27.166.882','27.166.320','27.166.785')
	--    h.item_code in ('43.207.584M')			---23/7/2020	
	 ---   h.item_code in ('44.010.007')			---23/7/2020
	 --   h.item_code in ('82.696.910')
		 -- h.item_code in ('24.7218.0199')
	   -- h.item_code in ('24.7257.0952')
	 --   h.item_code in ('82.336.901')
	    -- h.item_code in ('XUCLC100','XUCLC105','XUCLC118','XUCLC131','XUEC100','XUEC105','XUEC118','XUEC131','XUR10016','XUR10516','XUR11816','XUR13116','3116131','3116118','3116100','3116105','3024954765F','3024954587F','3024954246F','3024954125F','31122765','31122587','31122246','311202','31121765','31121587','31121246','311201','2780034000B','2780033000B','3024956000F','2770004000B','4181301661','4181301320','4181301765','4181301785','3051303661','3051303320','3051303765','3051303785')
          h.item_code in ('2780135000B','2780120000B','2920707000B')
    --where f.order_number in ('5456172')
	 --   f.order_number in ('5653693')
   --  and h.invoice_date is not null				--- do you need to include SKUs with no invoice date but possible with Order date ?
        --and p.business_unit_name = 'Blindmaker'     --- do you need this one ? DOes AWF selling components ?  10/12/2019
		-- and p.business_unit_name = 'Components'      --- state expplicitly albeit h.business_unit is in 'select' clause
		 --  and h.jde_business_unit in ('AWF')
		 -- and cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,h.invoice_date),0),126),'-',''),1,6) as integer) >201910
		 ---h.order_number in ('5456172')
		--  c.contact_name like ('%Venus%')					--- choose special customer		10/7/2020
		 --   c.customer_number in ('500370','1919459')
		 -- and p.family_group_code in ('974','982')			--- choose special category		10/7/2020
		 and c.customer_number in ('2096938')					--- choose customer named as 'Watson Blinds'
		 -- and p.family_group_code in ('966')			--- choose special category ( family group Alpha Awning) for Watson 	-- 	'Contemporary Collection'  18/2020
		--  and p.family_code in ('633')					--- choose family  -- --- Alpha awning  
		  and cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,h.invoice_date),0),126),'-',''),1,6) as integer) > 201712	-- narrow your range		10/7/2020

group by h.jde_business_unit         
		 ,h.item_code,p.d_product_key	 
		 --,p.price_group_desc
		 ,p.item_name
		 
		  ,h.d_customer_key
		  ,c.customer_number
		 ,c.contact_name

		 --,p.family_group_desc
		 ,p.family_group_code
		 ,p.family_code
		 ,p.business_unit_code
		 ,p.business_unit_name

		 ,u.primary_uom_code
		-- ,u.primary_uom_name 
		 ,h.pricing_uom

		-- ,p.jde_business_unit
		 --,substring( cast(f.d_date_key as varchar) , 1, 6) Order_YYMM
		 ,cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,h.invoice_date),0),126),'-',''),1,8) as integer) 
		 ,cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,h.invoice_date),0),126),'-',''),1,6) as integer) 
 order by h.item_code
         -- ,cast(substring( cast(f.d_date_key as varchar) , 1, 6) as int)
		  ,cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,h.invoice_date),0),126),'-',''),1,6) as integer)


select top 3 * from HDDW_PRD.star.f_so_detail_history
select distinct h.jde_business_unit,h.business_unit_code from HDDW_PRD.star.f_so_detail_history h

select * from HDDW_PRD.star.d_customer c where c.contact_name like ('%pacific%')
order by c.contact_name

select * 


----------- Check one particular order details ( Qty, Order Date, who ordered it ( Customer - contact name ) etc )  ---------------------------------------------------------------------------------------------------------------------
  --- --- 25/5/2020    --- 43.212.003 ---

 select  h.jde_business_unit        
		,h.item_code,p.d_product_key		
		--- ,p.price_group_desc			--use Item_name instead
		,p.item_name

		 ,h.order_date
		 ,h.invoice_date
		 ,h.order_number

		 ,h.d_customer_key
		  ,c.customer_number
		 ,c.contact_name
		
		 --,p.family_group_desc
		 ,p.family_group_code		-- use code instead of desc
		 ,p.family_code
		 ,p.business_unit_code		-- use code instead
		 ,p.business_unit_name

		   ,u.primary_uom_code	as UM_PM	-- use code instead
		   ,h.pricing_uom   as UM_PX
		--  ,u.primary_uom_name 		 
		-- ,p.jde_business_unit		-- duplicate you already have bu in history table

		-- ,substring( cast(f.d_date_key as varchar) , 1, 6) Order_YYMM
		  ,cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,h.invoice_date),0),126),'-',''),1,8) as integer) as Inv_YYMMDD	      --- 1st day of each month,so actually by month
		  ,cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,h.invoice_date),0),126),'-',''),1,6) as integer) as Inv_YYMM	
		  ,h.primary_quantity
		--,sum(h.primary_quantity)   primary_quantity	
		--,sum(h.sales_quantity)    sales_quantitiy
		--,sum(h.sales_amount)      sales_amount	 

from [hd-vm-bi-sql01].HDDW_PRD.star.f_so_detail_history h left join  [hd-vm-bi-sql01].HDDW_PRD.star.d_product  p 	on h.d_product_key = p.d_product_key 
								left join [hd-vm-bi-sql01].HDDW_PRD.star.d_primary_uom u 	on h.d_primary_uom_key = u.d_primary_uom_key 
								left join [hd-vm-bi-sql01].HDDW_PRD.star.d_customer c on h.d_customer_key = c.d_customer_key

--where    d.item_code = '31121765'
where  
	--  h.item_code in ('40.132.131','40.129.378','40.197.850','40.129.433')
	--  h.item_code = '38.001.005'
	  --h.item_code in ('24.7002.0000','24.7002.0000T','24.7207.0952')
	  --h.item_code in ('FT.01468.000.01')
	  h.item_code in ('43.212.003')
	   -- h.item_code in ('24.7257.0952')
	 --   h.item_code in ('82.336.901')
    --where f.order_number in ('5456172')
   --  and h.invoice_date is not null				--- do you need to include SKUs with no invoice date but possible with Order date ?
        --and p.business_unit_name = 'Blindmaker'     --- do you need this one ? DOes AWF selling components ?  10/12/2019
		-- and p.business_unit_name = 'Components'      --- state expplicitly albeit h.business_unit is in 'select' clause
		 --  and h.jde_business_unit in ('AWF')
		  and cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,h.invoice_date),0),126),'-',''),1,6) as integer) =202005
		 ---h.order_number in ('5456172')

 order by h.item_code,h.order_date

---------------------------------------------------------------------------------------------------------------------------------
select h.item_code,h.invoice_date,sum(h.primary_quantity) as Sls_Qty
from Star.f_so_detail_history h 
where h.item_code in ('FAMT')
group by h.item_code,h.invoice_date


select h.item_code as Itm,h.* from star.f_so_detail_history h 
--where h.item_code in ('26.119.347')					
--where h.item_code in ('44.011.007')			-- Fibre glass
where h.item_code in ('82.691.901')				-- Zen fabric ( RB)

order by h.item_code,h.order_date,h.customer_number

select p.item_code,h.* from star.f_so_detail_history h left join star.d_product p on h.d_product_key = p.d_product_key             --- no need, history table alreadyhas item_code
where p.item_code in ('44.011.007')


select * from star.f_so_detail_history h
where h.order_number in ('5599230')							--- SKU 44.011.007 ( product key 82235 ) - fibre glass

select * from star.f_so_detail_history h 
where h.order_number in ('5456172')		
	 and h.item_code in ('RBSC')													--- Roller blinds single chain


select distinct h.order_type from star.f_so_detail_history h 


select * from star.f_so_detail_history h 
where h.item_code in ('44.011.007')

select * from star.f_so_detail_history h 
--where h.order_number in ('381612')

--where h.order_number in ('00159110')			-- this is actually SO # 159110 ( not SO 00159110)
where h.work_order_number in ('00159110')

--where h.order_number in ('159960')			---this is actually SO #159960
  where h.work_order_number in ('00159960')			--- HD WO #00159960


  select * from star.f_so_detail_history h 
  where h.order_number in ('05614583')			--- AWD SO #


select * from star.f_so_detail_history h 
--where h.order_number in ('381612')
--where h.item_code in ('facsd2')
  where h.item_code in ('famt')
        and h.invoice_date >'2020-02-01'
        and h.work_order_number in ('04685890')



------------------------------ *** Using HDD - DW Database *** ------------------------------------------------- 5/3/2020
---------------------------- Some statistic about tables in HDD DW ---------------------------- ---------------------------
select count(*) from Star.f_so_detail_history
select top 3 h.*  from Star.f_so_detail_history h

select c.contact_name,h.*  from Star.f_so_detail_history h left join star.d_customer c on h.d_customer_key = c.d_customer_key
  where   h.item_code in ('32.379.200')					---3419 rows
		and cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,h.invoice_date),0),126),'-',''),1,6) as integer) >201910		--- 36 rows
		

select count(*) from star.d_product p 
select top 10 p.* from star.d_product p 
select  p.* from star.d_product p where p.item_code in ('44.011.007')                               -- note 'item_code' 2nd item number,'item_number' is short item number in 'Product' table in data warehouse 28/2/2020

select count(*) from star.d_customer 
select top 10 c.* from star.d_customer c 

select *
from star.d_customer c 
where c.contact_name like ('%lovelight%')
--where c.customer_number in ('2088109')
order by c.customer_number


select * from HDDW_PRD.Star.d_customer


--------------05/03/2020 Work started using HDD - DW tables -------------------------------

;with wcc as 
		( select top 3 *
		  from HDDW_PRD.star.f_so_detail_history h
		  where h.jde_business_unit in ('HD')						-- important !
		  )

   select * from wcc







----- ALWAYS ENTER YOUR CODE ABOVE THIS LINE -------- ----- ALWAYS ENTER YOUR CODE ABOVE THIS LINE -------- ----- ALWAYS ENTER YOUR CODE ABOVE THIS LINE --------
----- NEVER ENTER YOUR CODE BELOW THIS LINE --------- ----- NEVER ENTER YOUR CODE BELOW THIS LINE --------- ----- NEVER ENTER YOUR CODE BELOW THIS LINE ---------

 ---&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&------------------
-- END_EXIT:

-- last line of the script
set noexec off -- Turn execution back on; only needed in SSMS, so as to be able 
               -- to run this script again in the same session.