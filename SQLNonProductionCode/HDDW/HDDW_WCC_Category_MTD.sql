

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
		 ,p.family_code,p.family_desc		 
		 ,p.business_unit_code		-- use code instead
		 ,p.business_unit_name
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
		 --   c.customer_number in ('500370','1919459')
		 -- and p.family_group_code in ('974','982')			--- choose special category		10/7/2020
		  -- c.customer_number in ('2096938')					--- choose customer named as 'Watson Blinds'
		 --  p.family_group_code in ('964')			--- choose special category ( family group )	-- 	'Contemporary Collection'  18/2020
		  --and p.family_code in ('633')					--- choose family  -- --- Alpha awning  
		 -- p.family_group_code in ('982')			--- choose special category ( family group )	-- 	'Roller fabric'  18/2020
		-- p.family_group_code in ('964')			--- choose special category ( family group )	-- 	'Metal Awning'		QLD Hail storm damage  9/11/2020		
		 -- p.family_group_code in ('982')			--- choose special category ( family group )	-- 	'Roller fabric'  18/2020
		    p.family_group_code in ('965')			--- choose special category ( family group )	-- 	'Awning' - FA series  12/2/2021
		-- and cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,h.invoice_date),0),126),'-',''),1,6) as integer) > 201907	-- narrow your range		10/7/2020
		and cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,h.invoice_date),0),126),'-',''),1,6) as integer) > 201409	-- narrow your range		10/7/2020


group by h.jde_business_unit         
		-- ,h.item_code,p.d_product_key,p.item_name		 
		  ,h.d_customer_key,c.customer_number,c.contact_name
	     ,p.family_group_code,family_group_desc
		 ,p.family_code,family_desc
		 ,p.business_unit_code
		 ,p.business_unit_name
		-- ,u.primary_uom_code,h.pricing_uom	
	    --,substring( cast(f.d_date_key as varchar) , 1, 6) Order_YYMM
		 
		 ,cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,h.invoice_date),0),126),'-',''),1,8) as integer) 
		 ,cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,h.invoice_date),0),126),'-',''),1,6) as integer) 
		   ,cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,h.invoice_date),0),126),'-',''),1,4) as integer)
 order by --h.item_code
         -- ,cast(substring( cast(f.d_date_key as varchar) , 1, 6) as int)
		  h.jde_business_unit,p.family_group_code,p.family_code,c.contact_name
		  ,cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,h.invoice_date),0),126),'-',''),1,6) as integer)


