

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
		 ,c.sold_to_account_manager_name									--- 7/6/2021
		 ,c.channel_name

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

from [hd-vm-bi-sql01].HDDW_PRD.star.f_so_detail_history h left join  [hd-vm-bi-sql01].HDDW_PRD.star.d_product  p 	on h.d_product_key = p.d_product_key 
								left join [hd-vm-bi-sql01].HDDW_PRD.star.d_primary_uom u 	on h.d_primary_uom_key = u.d_primary_uom_key 
								left join [hd-vm-bi-sql01].HDDW_PRD.star.d_customer c on h.d_customer_key = c.d_customer_key

where  	--  h.item_code in ('46.005.000','46.005.100','46.005.134','46.005.104','46.005.734','46.005.737','46.005.810','46.005.850','46.011.000','46.011.100','46.011.134','46.011.104','46.011.734','46.011.737','46.011.810','46.011.850','46.012.000','46.012.100','46.012.134','46.012.104','46.012.734','46.012.737','46.012.810','46.012.850','46.013.000','46.013.100','46.013.134','46.013.104','46.013.734','46.013.737','46.013.810','46.013.850','46.004.000','46.004.100','46.004.134','46.004.810','46.602.000','46.602.100','46.602.134','46.602.810','46.603.000','46.603.100','46.603.134','46.603.810','46.606.000','46.606.100','46.606.134','46.606.104','46.606.734','46.606.737','46.606.810','46.606.850','46.607.000','46.607.100','46.607.134','46.607.104','46.607.734','46.607.737','46.607.810','46.607.850','46.608.000','46.608.100','46.608.134','46.608.104','46.608.734','46.608.737','46.608.810','46.608.850','42.064.000','42.065.000','42.066.000','42.067.000','42.068.000','46.002.000','46.002.063','46.019.000','46.019.063','46.021.000','46.025.000','46.108.063','46.203.000','46.306.000','46.410.063','46.414.000','46.419.000','46.419.100','46.420.000','46.421.000','46.422.030','46.423.100','46.500.000','46.502.100','46.502.837','46.504.000','46.505.000','46.506.000','46.507.000','46.517.000','46.518.063','46.524.000','46.530.063','46.599.000','46.609.000','46.610.000','46.611.000','42.421.855')
		 --  h.item_code in ('40.260.131')
		 -- h.item_code in ('24.7218.0199')
	   -- h.item_code in ('24.7257.0952')
		h.item_code in ('46.612.500')
	 --   h.item_code in ('82.336.901')
    --where f.order_number in ('5456172')
	 --   f.order_number in ('5653693')
   --  and h.invoice_date is not null					--- do you need to include SKUs with no invoice date but possible with Order date ?
        --and p.business_unit_name = 'Blindmaker'		--- do you need this one ? DOes AWF selling components ?  10/12/2019
		-- and p.business_unit_name = 'Components'      --- state expplicitly albeit h.business_unit is in 'select' clause
		 --  and h.jde_business_unit in ('AWF')
		 -- and cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,h.invoice_date),0),126),'-',''),1,6) as integer) >201910
		 ---h.order_number in ('5456172')
		--  c.contact_name like ('%Venus%')					   --- choose special customer		10/7/2020
		 --   c.customer_number in ('500370','1919459')		
		 -- and p.family_group_code in ('974','982')			--- choose special category		10/7/2020
		 --  c.customer_number in ('2867256')					---  Blue Pacific shades & Awnings 6/6/2022
		  -- c.customer_number in ('2096938','2019984')			--- choose customer named as 'Watson Blinds' or 'ABC Blinds & Awnings' / ABC - INDEPENDANT WHOLESALE - AWF ('2122010','2120499')
		  --and p.family_group_code in ('966')					--- choose special category ( family group )	-- 	'Contemporary Collection'  18/2020
		-- p.family_group_code in ('964')
		  --and p.family_code in ('633')						--- choose family  -- --- Alpha awning  
		 ---  and p.family_group_code in ('973','966')			--- Duette
		 -- and p.family_group_code in ('966','965')			--- Duette
		  and cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,h.invoice_date),0),126),'-',''),1,6) as integer) > 2020	-- narrow your range		10/7/2020

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
       	 ,c.sold_to_account_manager_name									--- 7/6/2021
		 ,c.channel_name

		 ,h.order_type,h.last_line_status_code,h.next_line_status_code
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