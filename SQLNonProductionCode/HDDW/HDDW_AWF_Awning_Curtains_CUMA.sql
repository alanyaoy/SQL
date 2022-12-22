
use HDDW_PRD
go

      -------- Query for HDDW_AWF_Curtains_CUMA ------
	  --- note Inv quantities should be very close to Qlikview App invoice number,if there is a slight diff,it could be the way how Qlikview Cube calculate day/time 23:59:00 Vs in SQL Server Alan's code use 24:00:00 , it could end up with some variance when day pass mid night --- 2/5/2022 
	  --- 'd_date_key' is Converted date for Request date - funny 'd_date_key' is not meaningful it should say 'd_request_date_key' 

select  h.jde_business_unit 
        ,p.business_unit_code,p.business_unit_name       
		,h.item_code,p.item_name,p.item_code
		,p.d_product_key		
		 ,p.price_group_desc
		  ,h.d_customer_key
		  ,c.customer_number
		 ,c.contact_name
		  ,c.sold_to_account_manager_name				--- 2/6/2021 , sho who is looking after this account ( will it duplicate ?? like sales employee left and new sales rep join ? )
		 

		 ,p.family_group_code,p.family_group_desc
		 ,p.family_code,p.family_desc
		 ,u.primary_uom_name 		 
		 ,substring( cast(h.d_date_key as varchar) , 1, 6) Order_YYMM						--- 'd_date_key column' is converted
		-- ,substring( cast(h.invoice_date as varchar) , 1, 6) Inv_YYMM						--- 'invoice_date' column is not converted		 
		  ,cast(SUBSTRING(REPLACE(CONVERT(char(10),h.invoice_date,126),'-',''),1,6) as integer) as Inv_YYMM
		 -- ,cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,h.invoice_date)-37,0),126),'-',''),1,6) as integer) as Inv_YYMM	
		,sum(h.primary_quantity)   primary_quantity		
		,sum(h.sales_amount)    primary_Amount		
		
--select distinct h.business_unit_code,p.family_group_desc,p.family_group_code,p.family_desc,p.family_code 

from [hd-vm-bi-sql01].HDDW_PRD.star.f_so_detail_history h left join  [hd-vm-bi-sql01].HDDW_PRD.star.d_product  p  on h.d_product_key = p.d_product_key 
								left join [hd-vm-bi-sql01].HDDW_PRD.star.d_primary_uom u 	on h.d_primary_uom_key = u.d_primary_uom_key 
								left join [hd-vm-bi-sql01].HDDW_PRD.star.d_customer c on h.d_customer_key = c.d_customer_key

--order by h.business_unit_code,p.family_group_code
--where    d.item_code = '31121765'
where  --  h.item_code = '44.011.007'
		--   h.item_code = '43.212.004'
         -- h.item_code = '24.7201.0000T'
		  --h.item_code in ('PRHI1')
		 --  h.item_code in ('VESH')										--- Lumi shade/Veri shade
		   h.item_code in ('VBWE')										--- Timber VB - Country wood
	    -- h.item_code in ('RBSC','RBMS','MOTRB','RBMM','RBSM')				--- roller blinds
		 --  h.item_code in ('RBTSC','RBTSCS')								--- roller blinds ( Blinds On line Roller code )
		 -- h.item_code in ('CUMA','CUMOT','CUTR')				-- Curtain
		 -- h.item_code in ('RBSC','RBMS','MOTRB','RBMM','RBSM','RBTSC','RBTSCS')			--- roller blinds
		 -- h.item_code in ('FACSD2')			--- Evo /Alpha awning but HDDW use 'SUNSCR' and 'AWF SUNSCReen', 'Fabric awning' and '32F' ( should it be 32E instead ? ) as family group nmae NOT 'Contemprary Collection' as family name 
		 --  h.item_code in ('FAAU')			--- fabric roll up awning - fabric awning automatic 
		--   h.item_code in ('FAMT')			--- Magnatrack - 32F again ?! should it be '32E " as in Kamiliata's report ??
		--	 h.item_code in ('TUFA20')			--- Tunil/Bricos - Nordic ( Lux ) / Kona ; has to use 'TU' in front of 'FA20' or 'FA58' etc !! otherwise search result is null - how good is name convenetion in Hunter Duglas - everyone is use different name !
		--   p.family_code in ('33C')
		--   p.family_code in ('32E')
		 --  p.family_code in ('32B')				--- VB timber
 --where f.order_number in ('5456172')
    
    --  and c.sold_to_account_manager_name in ('BRANT TOOMEY')
	--  and h.customer_number in ('2993498')
group by h.jde_business_unit 
		,p.business_unit_code,p.business_unit_name           
		 ,h.item_code,p.item_name,p.item_code
		 ,p.d_product_key	 
		 ,p.price_group_desc
		 ,h.d_customer_key
		 ,c.customer_number
		 ,c.contact_name
		  ,c.sold_to_account_manager_name				

		 ,p.family_group_desc
		 ,p.family_group_code
		 ,p.family_desc
		 ,p.family_code
		 ,u.primary_uom_name 
		 ,substring( cast(h.d_date_key as varchar) , 1, 6)			
		 --,substring( cast(h.invoice_date as varchar) , 1, 6)
		 ,cast(SUBSTRING(REPLACE(CONVERT(char(10),h.invoice_date,126),'-',''),1,6) as integer)
		-- ,cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,h.invoice_date)-37,0),126),'-',''),1,6) as integer) 

 order by h.item_code
          ,cast(substring( cast(h.d_date_key as varchar) , 1, 6) as int)




----------------- Check 1 order by 1 Sales manager 2/5/2022 -----------------------

select  h.jde_business_unit 
        ,p.business_unit_code,p.business_unit_name       
		,h.item_code,p.item_name,p.item_code
		,p.d_product_key		
		 ,p.price_group_desc
		  ,h.d_customer_key
		  ,c.customer_number
		 ,c.contact_name
		  ,c.sold_to_account_manager_name				--- 2/6/2021 , sho who is looking after this account ( will it duplicate ?? like sales employee left and new sales rep join ? )
		 

		 ,p.family_group_code,p.family_group_desc
		 ,p.family_code,p.family_desc
		 ,u.primary_uom_name 		 
		 ,substring( cast(h.d_date_key as varchar) , 1, 6) Order_YYMM
		 ,substring( cast(h.invoice_date as varchar) , 1, 6) Inv_YYMM
		 -- ,cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,h.invoice_date)-37,0),126),'-',''),1,6) as integer) as Inv_YYMM	
		,h.primary_quantity		
		,h.sales_amount	
		
--select distinct h.business_unit_code,p.family_group_desc,p.family_group_code,p.family_desc,p.family_code 

from [hd-vm-bi-sql01].HDDW_PRD.star.f_so_detail_history h left join  [hd-vm-bi-sql01].HDDW_PRD.star.d_product  p  on h.d_product_key = p.d_product_key 
								left join [hd-vm-bi-sql01].HDDW_PRD.star.d_primary_uom u 	on h.d_primary_uom_key = u.d_primary_uom_key 
								left join [hd-vm-bi-sql01].HDDW_PRD.star.d_customer c on h.d_customer_key = c.d_customer_key

--order by h.business_unit_code,p.family_group_code
--where    d.item_code = '31121765'
where  --  h.item_code = '44.011.007'
		--   h.item_code = '43.212.004'
          --h.item_code = '32.379.200'
		  --h.item_code in ('PRHI1')
	    -- h.item_code in ('RBSC','RBMS','MOTRB','RBMM','RBSM')				--- roller blinds
		 --  h.item_code in ('RBTSC','RBTSCS')								--- roller blinds ( Blinds On line Roller code )
		 -- h.item_code in ('CUMA','CUMOT','CUTR')				-- Curtain
		 -- h.item_code in ('RBSC','RBMS','MOTRB','RBMM','RBSM','RBTSC','RBTSCS')			--- roller blinds
		 -- h.item_code in ('FACSD2')			--- Evo /Alpha awning but HDDW use 'SUNSCR' and 'AWF SUNSCReen', 'Fabric awning' and '32F' ( should it be 32E instead ? ) as family group nmae NOT 'Contemprary Collection' as family name 
		 --  h.item_code in ('FAAU')			--- fabric roll up awning - fabric awning automatic 
		--   h.item_code in ('FAMT')			--- Magnatrack - 32F again ?! should it be '32E " as in Kamiliata's report ??
		--	 h.item_code in ('TUFA20')			--- Tunil/Bricos - Nordic ( Lux ) / Kona ; has to use 'TU' in front of 'FA20' or 'FA58' etc !! otherwise search result is null - how good is name convenetion in Hunter Duglas - everyone is use different name !
		   p.family_code in ('33C')
		--   p.family_code in ('32E')
		 --  p.family_code in ('32B')				--- VB timber
  --where f.order_number in ('5456172')
    
      and c.sold_to_account_manager_name in ('BRANT TOOMEY')
	  and h.customer_number in ('2993498')



------------------------------------

select h.*
from [hd-vm-bi-sql01].HDDW_PRD.star.f_so_detail_history h left join  [hd-vm-bi-sql01].HDDW_PRD.star.d_product  p  on h.d_product_key = p.d_product_key 
								left join [hd-vm-bi-sql01].HDDW_PRD.star.d_primary_uom u 	on h.d_primary_uom_key = u.d_primary_uom_key 
								left join [hd-vm-bi-sql01].HDDW_PRD.star.d_customer c on h.d_customer_key = c.d_customer_key

--order by h.business_unit_code,p.family_group_code
--where    d.item_code = '31121765'
where  --  h.item_code = '44.011.007'
		--   h.item_code = '43.212.004'
          --h.item_code = '32.379.200'
		  --h.item_code in ('PRHI1')
		  h.item_code in ('VBWE')
	    -- h.item_code in ('RBSC','RBMS','MOTRB','RBMM','RBSM')				--- roller blinds
		 --  h.item_code in ('RBTSC','RBTSCS')								--- roller blinds ( Blinds On line Roller code )
		 --h.item_code in ('CUMA','CUMOT','CUTR')				-- Curtain
		 -- h.item_code in ('RBSC','RBMS','MOTRB','RBMM','RBSM','RBTSC','RBTSCS')			--- roller blinds
		 -- h.item_code in ('FACSD2')			--- Evo /Alpha awning but HDDW use 'SUNSCR' and 'AWF SUNSCReen', 'Fabric awning' and '32F' ( should it be 32E instead ? ) as family group nmae NOT 'Contemprary Collection' as family name 
		 --  h.item_code in ('FAAU')			--- fabric roll up awning - fabric awning automatic 
		--   h.item_code in ('FAMT')			--- Magnatrack - 32F again ?! should it be '32E " as in Kamiliata's report ??
		--	 h.item_code in ('TUFA20')			--- Tunil/Bricos - Nordic ( Lux ) / Kona ; has to use 'TU' in front of 'FA20' or 'FA58' etc !! otherwise search result is null - how good is name convenetion in Hunter Duglas - everyone is use different name !
		--   p.family_code in ('33C')
		--   p.family_code in ('32E')
		 --  p.family_code in ('32B')				--- VB timber
  --where f.order_number in ('5456172')
    
     -- and c.sold_to_account_manager_name in ('BRANT TOOMEY')
	 and c.sold_to_account_manager_name in  ('TREVOR REYNOLDS')
	  and h.customer_number in ('2137684')