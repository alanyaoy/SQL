

use HDDW_PRD
go



---------------- WCC history ------------ 12 months - rougly 116,521 records  HD Parts in Details by SKU by Customer --------------------------------------

-------- Note that HD history includes sales history sold to AWF ( also include sales for WCC channel customer ) ---------
--------- but HD sales history does not have details of where is components history originated for which customer ) and how much is from which blinds ---- we need seconds layer of details underneath ------
--- 980 ( cancelled  ) , 999 ( completed - ready to Purge ), 902 ( back order in commitment ), 620 ( ready for sales update)


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
		 ,p.family_group_code,p.family_group_desc		-- use code instead of desc
		 ,p.family_code,p.family_desc
		 ,p.business_unit_code		-- use code instead
		 ,p.business_unit_name
		 		 
		   ,h.order_type,h.last_line_status_code,h.next_line_status_code
		   ,u.primary_uom_code	as UM_PM	-- use code instead
		   ,h.pricing_uom   as UM_PX
		--  ,u.primary_uom_name 		 
		-- ,p.jde_business_unit		-- duplicate you already have bu in history table

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

where  	   -- h.item_code in ('2770004000B','43.212.001','43.211.001','43.205.637M','43.207.637M')
          -- h.item_code in ('43.207.637m')
		 --  h.item_code in ('34.073.000','FT.01391.000.00')
		-- h.item_code in ('43.205.532m')
		--h.item_code in ('38.001.001','38.001.002','38.001.003','38.001.004','38.001.005','38.001.006','38.004.000S','38.005.001','38.005.002','38.005.003','38.005.004','38.005.005','38.005.006','38.005.007','38.005.008','38.005.009','38.005.010','38.005.011','38.010.001','38.010.002','38.010.003','38.010.004','38.010.005','38.010.006','38.010.007','38.013.001','38.013.002','38.013.003','38.013.004','38.013.005','38.013.006','38.013.007','38.013.008')
		-- h.item_code in ('82.401.012')
		--h.item_code in ('52.013.000','34.252.000','34.254.000')
		--h.item_code in ('82.336.903')
		--h.item_code in ('26.801.820')
		--h.item_code in ('82.696.901')
		--  h.item_code in ('26.800.820'	)
		--  h.item_code in ('82336.3000.00.01')
		--  h.item_code in ('82.336.903')
		 -- h.item_code in ('27.277.951')
		 -- h.item_code in ('26.144.0192')
		   h.item_code in ('34.255.000','34.256.000','34.257.000')
		--h.item_code in ('82.435.901')
		--h.item_code in ('38.005.001','38.005.002','38.005.003','38.005.004','38.005.005','34.005.006')
		--h.item_code in ('38.010.006')
		--h.item_code in ('40.499.000','40.023.000','40.152.131','40.129.131','40.129.378','40.129.433')
		--h.item_code in ('40.048.131','26.478.000','40.499.000','40.023.000','40.152.131')
		 -- h.item_code in ('24.7218.0199')
	   -- h.item_code in ('24.7257.0952')
		--	  h.item_code in ('40.174.131','40.041.131')		--- Metal Awning parts -- 964
    --where f.order_number in ('5456172')
	 --   f.order_number in ('5653693')
   --  and h.invoice_date is not null				--- do you need to include SKUs with no invoice date but possible with Order date ?
        --and p.business_unit_name = 'Blindmaker'     --- do you need this one ? DOes AWF selling components ?  10/12/2019
		-- and p.business_unit_name = 'Components'      --- state expplicitly albeit h.business_unit is in 'select' clause
		 --  and h.jde_business_unit in ('AWF')
		 -- and cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,h.invoice_date),0),126),'-',''),1,6) as integer) >201910
		 ---h.order_number in ('5456172')
		 -- c.contact_name like ('%Venus%')					--- choose special customer		10/7/2020
		  --  c.contact_name like ('%dollar%')				--- 500518
		-- and p.family_group_code in ('982')			--- choose special category ( family group )	-- 	'Roller fabric - Zen'  18/2020
		 --   c.customer_number in ('500370','1919459')
		 -- and p.family_group_code in ('974','982')			--- choose special category		10/7/2020
		  -- c.customer_number in ('2096938')					--- choose customer named as 'Watson Blinds'
		 --and  c.customer_number in ('2096850')					-- customer Viewscape
		  --p.family_group_code in ('910')			--- choose special category ( family group )	-- 	'Contemporary Collection'  18/2020
		 -- c.customer_number in ('2126621')					-- US Mermet
		--  and p.family_group_code in ('982')			--- choose special category ( family group )	-- 	'Contemporary Collection'  18/2020
		 -- p.family_group_code in ('910')			--- choose special category ( family group )	-- 	'Veri Shades' for Victory Blinds   1/3/2021

		 -- and p.family_code in ('633')					--- choose family  -- --- Alpha awning  
		 --  p.family_code in ('89J','89K')					--- choose family  -- --- Alpha awning  
		  and cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,h.invoice_date),0),126),'-',''),1,6) as integer) > 201912-- narrow your range		10/7/2020

group by h.jde_business_unit         
		 ,h.item_code,p.d_product_key	 
		 --,p.price_group_desc
		 ,p.item_name
		 
		  ,h.d_customer_key
		  ,c.customer_number
		 ,c.contact_name

		 --,p.family_group_desc
		 ,h.order_type,h.last_line_status_code,h.next_line_status_code

		 ,p.family_group_code,p.family_group_desc
		 ,p.family_code,p.family_desc
		 ,p.business_unit_code
		 ,p.business_unit_name
		 ,u.primary_uom_code		
		 ,h.pricing_uom
		 

		-- ,p.jde_business_unit
		 --,substring( cast(f.d_date_key as varchar) , 1, 6) Order_YYMM
		 ,cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,h.invoice_date),0),126),'-',''),1,8) as integer) 
		 ,cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,h.invoice_date),0),126),'-',''),1,6) as integer) 
		  ,cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,h.invoice_date),0),126),'-',''),1,4) as integer)
 order by h.item_code
         -- ,cast(substring( cast(f.d_date_key as varchar) , 1, 6) as int)
		  ,cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,h.invoice_date),0),126),'-',''),1,6) as integer)


