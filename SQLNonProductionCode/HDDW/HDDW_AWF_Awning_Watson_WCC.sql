

use HDDW_PRD
go

---================================================================================================
--- Evo / Alpha awning sales history for WCC channel -- for Watson Blinds customer  --- 11/8/2020
---================================================================================================


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

where  	 --   h.item_code in ('82.696.910')
		 -- h.item_code in ('24.7218.0199')
	   -- h.item_code in ('24.7257.0952')
	 --   h.item_code in ('82.336.901')
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
		   c.customer_number in ('2096938')					--- choose customer named as 'Watson Blinds'
		  --and p.family_group_code in ('966')			--- choose special category ( family group )	-- 	'Contemporary Collection'  18/2020
		  --and p.family_code in ('633')					--- choose family  -- --- Alpha awning  
		   and p.family_group_code in ('973')				--- Duette
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
		 ,h.pricing_uom

		-- ,p.jde_business_unit
		 --,substring( cast(f.d_date_key as varchar) , 1, 6) Order_YYMM
		 ,cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,h.invoice_date),0),126),'-',''),1,8) as integer) 
		 ,cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,h.invoice_date),0),126),'-',''),1,6) as integer) 
 order by h.item_code
         -- ,cast(substring( cast(f.d_date_key as varchar) , 1, 6) as int)
		  ,cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,h.invoice_date),0),126),'-',''),1,6) as integer)