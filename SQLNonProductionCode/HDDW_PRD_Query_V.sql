
-------------    Hunter Douglas Data Warehouse ---------------------

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


use HDDW_PRD
go

--- Find Server name ---
select @@SERVERNAME

--- Find Linked Server ---
select * from sys.servers where is_linked = 1

select * from [hd-vm-bi-sql01].HDDW_PRD.star.d_region

select * from HD_2016EXPAD.JDE_DB_Alan.vw_Mast						--- does not work as of 10/12/2019 as there is no linked server
select * from [RYDWS366\HD_2016EXPAD].JDE_DB_Alan.dbo.cj			--- does not work
select * from [RYDWS366\HD_2016EXPAD].JDE_DB_Alan.jde_db_alan.vw_Mast    --- does not work

------ DW ----------------- Guru's query ---

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

----------------- AWF Blinds Sales history -----------------
-- xxxxxxxxxxx ---  Order date ---xxxxxxxxxxxx --- do not use , use Invoice date 
select  h.jde_business_unit        
		,h.item_code,p.d_product_key		
		 ,p.price_group_desc
		  ,h.d_customer_key
		  ,c.customer_number
		 ,c.contact_name

		 ,p.family_group_desc
		 ,u.primary_uom_name 		 
		 ,substring( cast(h.d_date_key as varchar) , 1, 6) Order_YYMM
		--  ,cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,h.invoice_date)-37,0),126),'-',''),1,6) as integer) as Inv_YYMM	
		,sum(h.primary_quantity)   primary_quantity		 

from [hd-vm-bi-sql01].HDDW_PRD.star.f_so_detail_history h left join  [hd-vm-bi-sql01].HDDW_PRD.star.d_product  p 	on h.d_product_key = p.d_product_key 
								left join [hd-vm-bi-sql01].HDDW_PRD.star.d_primary_uom u 	on h.d_primary_uom_key = u.d_primary_uom_key 
								left join [hd-vm-bi-sql01].HDDW_PRD.star.d_customer c on h.d_customer_key = c.d_customer_key

--where    d.item_code = '31121765'
where  --  h.item_code = '44.011.007'
          h.item_code = '32.379.200'
  --where f.order_number in ('5456172')
group by h.jde_business_unit         
		 ,h.item_code,p.d_product_key	 
		 ,p.price_group_desc
		 ,h.d_customer_key
		 ,c.customer_number
		 ,c.contact_name

		 ,p.family_group_desc
		 ,u.primary_uom_name 
		 ,substring( cast(h.d_date_key as varchar) , 1, 6) 
		 --,cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,h.invoice_date)-37,0),126),'-',''),1,6) as integer) 
 order by h.item_code
          ,cast(substring( cast(h.d_date_key as varchar) , 1, 6) as int)
		 -- ,cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,h.invoice_date)-37,0),126),'-',''),1,6) as integer)


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
where h.item_code = '38.004.000'
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


---------------------------------- HD Parts --------------------------------------
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
		  ,cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,h.invoice_date),0),126),'-',''),1,8) as integer) as Inv_YYMMDD	
		  ,cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,h.invoice_date),0),126),'-',''),1,6) as integer) as Inv_YYMM	
		,sum(h.primary_quantity)   primary_quantity	
		,sum(h.sales_quantity)    sales_quantitiy
		,sum(h.sales_amount)      sales_amount	 

from [hd-vm-bi-sql01].HDDW_PRD.star.f_so_detail_history h left join  [hd-vm-bi-sql01].HDDW_PRD.star.d_product  p 	on h.d_product_key = p.d_product_key 
								left join [hd-vm-bi-sql01].HDDW_PRD.star.d_primary_uom u 	on h.d_primary_uom_key = u.d_primary_uom_key 
								left join [hd-vm-bi-sql01].HDDW_PRD.star.d_customer c on h.d_customer_key = c.d_customer_key

--where    d.item_code = '31121765'
where   h.item_code = '26.119.347' 
	 -- h.item_code = '44.011.007'
    --where f.order_number in ('5456172')
   --  and h.invoice_date is not null				--- do you need to include SKUs with no invoice date but possible with Order date ?
        --and p.business_unit_name = 'Blindmaker'     --- do you need this one ? DOes AWF selling components ?  10/12/2019
		 and p.business_unit_name = 'Components'      --- state expplicitly albeit h.business_unit is in 'select' clause
		 -- and cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,h.invoice_date),0),126),'-',''),1,6) as integer) >201910
		 ---h.order_number in ('5456172')
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

---------------------------------------------------------------------------------------------------------------------------------
select * 
from Star.f_so_detail_history h 


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

--------------------------------------------------------------- ---------------------------
select count(*) from Star.f_so_detail_history
select top 10 h.*  from Star.f_so_detail_history h

select c.contact_name,h.*  from Star.f_so_detail_history h left join star.d_customer c on h.d_customer_key = c.d_customer_key
  where   h.item_code in ('32.379.200')					---3419 rows
		and cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,h.invoice_date),0),126),'-',''),1,6) as integer) >201910		--- 36 rows
		

select count(*) from star.d_product p 
select top 10 p.* from star.d_product p
select  p.* from star.d_product p where p.item_code in ('44.011.007')

select count(*) from star.d_customer 
select top 10 c.* from star.d_customer c 

select *
from star.d_customer c 
where c.contact_name like ('%lovelight%')
--where c.customer_number in ('2088109')
order by c.customer_number






select * from HDDW_PRD.Star.