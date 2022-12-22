


use HDDW_PRD
go

--select *
--from HDDW_PRD.Star.f_so_detail_history h left join	HDDW_PRD.star.d_product p on h.d_product_key = p.d_product_key
--								left join HDDW_PRD.star.d_primary_uom u 	on h.d_primary_uom_key = u.d_primary_uom_key 
--								left join HDDW_PRD.star.d_customer c on h.d_customer_key = c.d_customer_key




---------------- WCC history ------------ Summary of 12 months - HD Parts in Details by family by Customer --------------------------------------


-------- Note that HD history includes sales history sold to AWF ( also include sales for WCC channel customer ) ---------
--------- but HD sales history does not have details of where is components history originated for which customer ) and how much is from which blinds ---- we need seconds layer of details underneath ------

	-- xxxxxxxxxxx --- Sales by month by customer ( original sales is by each date so has to be grouped by month otherwise too much lines )  , Invoive date ---xxxxxxxxxxxx --- Use this one , not Order date
	--- Note when you aggregate by Sales qty ( not primary qty ), if UOM is different each month for one customer ( which is rare ) then you might get sum by different UOM by month --- so it is better to use primary UOM
select  h.jde_business_unit        
		--,h.item_code,p.d_product_key,p.item_name
		 ,h.d_customer_key,c.customer_number,c.contact_name		
		 ,p.family_group_code,family_group_desc		-- use code instead of desc		
		 ,p.family_code
		 --,p.family_desc		 
		  ,replace( family_desc, ',', '-') as family_desc_2	
		 ,p.business_unit_code		-- use code instead
		 ,p.business_unit_name
	     ,c.sold_to_account_manager_name				--- 2/6/2021 , sho who is looking after this account ( will it duplicate ?? like sales employee left and new sales rep join ? )
		 ,c.channel_name

		 --  ,u.primary_uom_code	as UM_PM	-- use code instead
		  -- ,h.pricing_uom   as UM_PX		
		-- ,substring( cast(f.d_date_key as varchar) , 1, 6) Order_YYMM
		  ,cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,h.invoice_date),0),126),'-',''),1,8) as integer) as Inv_YYMMDD	      --- 1st day of each month,so actually by month
		  ,cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,h.invoice_date),0),126),'-',''),1,6) as integer) as Inv_YYMM	
		   ,cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,h.invoice_date),0),126),'-',''),1,4) as integer) as Inv_YY
		,sum(h.primary_quantity)   primary_quantity	
		,sum(h.sales_quantity)    sales_quantitiy
		,sum(h.sales_amount)      sales_amount	
		,getdate() as Reportdate 

from [hd-vm-bi-sql01].HDDW_PRD.star.f_so_detail_history h left join  [hd-vm-bi-sql01].HDDW_PRD.star.d_product  p 	on h.d_product_key = p.d_product_key 
								left join [hd-vm-bi-sql01].HDDW_PRD.star.d_primary_uom u 	on h.d_primary_uom_key = u.d_primary_uom_key 
								left join [hd-vm-bi-sql01].HDDW_PRD.star.d_customer c on h.d_customer_key = c.d_customer_key

where  	
		--	  h.item_code in ('40.174.131','40.041.131')		--- Metal Awning parts -- 964
    	 --   f.order_number in ('5653693')
     --  and h.invoice_date is not null				--- do you need to include SKUs with no invoice date but possible with Order date ?
        --and p.business_unit_name = 'Blindmaker'     --- do you need this one ? DOes AWF selling components ?  10/12/2019
		-- and p.business_unit_name = 'Components'      --- state expplicitly albeit h.business_unit is in 'select' clause
		 --  and h.jde_business_unit in ('AWF')
		 -- and cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,h.invoice_date),0),126),'-',''),1,6) as integer) >201910
		 ---h.order_number in ('5456172')
		--  c.contact_name like ('%Venus%')					--- choose special customer		10/7/2020
		--   c.contact_name like ('%ABC%')					--- choose special customer		10/7/2020
		 --   c.customer_number in ('500370','1919459')
		 -- and p.family_group_code in ('974','982')			--- choose special category		10/7/2020
		--  c.customer_number in ('2867256')					---  Blue Pacific shades & Awnings 6/6/2022
		  -- c.customer_number in ('2096938','2019984')			--- choose customer named as 'Watson Blinds' or 'ABC Blinds & Awnings' / ABC - INDEPENDANT WHOLESALE - AWF ('2122010','2120499')
		  --  c.customer_number in ('500518')					--- choose customer named as 'Dollar Curtain'

		--   p.family_group_code in ('966')			--- choose special category ( family group )	-- 	'Metal Awning'  18/2020
		 --  p.family_group_code in ('966','965','964')			--- choose special category ( family group )	-- 	'Contemporary Collection'  18/2020
		  --and p.family_code in ('633')					--- choose family  -- --- Alpha awning  
		--  p.family_code in ('635')							--- choose family  -- --- Magnatrack awning 
		 -- p.family_group_code in ('982')			--- choose special category ( family group )	-- 	'Roller fabric'  18/2020
		-- p.family_group_code in ('964')			--- choose special category ( family group )	-- 	'Metal Awning'		QLD Hail storm damage  9/11/2020		
		--  p.family_group_code in ('910')			--- choose special category ( family group )	-- 	'Veri shade'  18/2020
		  -- p.family_group_code in ('983')			--- choose special category ( family group )	-- 	'Canvas'  12/2/2021
		  --  p.family_group_code in ('977')			--- choose special category ( family group )	-- 	'Timber Venetian - Woodnature'  16/4/2021
		  --   p.family_group_code in ('972')			--- choose special category ( family group )	-- 	' Vertical'  6/5/2021
		  --   p.family_group_code in ('971')			--- choose special category ( family group )	-- 	' Venetian'  6/5/2021
		   --    p.family_group_code in ('986','989')			--- choose special category ( family group )	
		   p.family_group_code in ('974','982','973','979','964','965','966','971','977','972','910','981','986','989','992','900','913')			--- choose special category ( family group )	
             --  and p.family_code in ('892')
		-- and cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,h.invoice_date),0),126),'-',''),1,6) as integer) > 201907	-- narrow your range		10/7/2020
		and cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,h.invoice_date),0),126),'-',''),1,6) as integer) > 201812	-- narrow your range		10/7/2020


group by h.jde_business_unit         
		-- ,h.item_code,p.d_product_key,p.item_name		 
		  ,h.d_customer_key,c.customer_number,c.contact_name
	     ,p.family_group_code,family_group_desc
		 ,p.family_code,family_desc
		 ,p.business_unit_code
		 ,p.business_unit_name
		 ,c.sold_to_account_manager_name
		 ,c.channel_name
		-- ,u.primary_uom_code,h.pricing_uom	
	    --,substring( cast(f.d_date_key as varchar) , 1, 6) Order_YYMM
		 
		 ,cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,h.invoice_date),0),126),'-',''),1,8) as integer) 
		 ,cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,h.invoice_date),0),126),'-',''),1,6) as integer) 
		   ,cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,h.invoice_date),0),126),'-',''),1,4) as integer)
 order by --h.item_code
         -- ,cast(substring( cast(f.d_date_key as varchar) , 1, 6) as int)
		  h.jde_business_unit,p.family_group_code,p.family_code,c.contact_name
		  ,cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,h.invoice_date),0),126),'-',''),1,6) as integer)


  --- Testing for VBA connection --- 6/5/2021
 --select top 3 h.*,getdate() as ReportTime  from [hd-vm-bi-sql01].HDDW_PRD.Star.f_so_detail_history h 