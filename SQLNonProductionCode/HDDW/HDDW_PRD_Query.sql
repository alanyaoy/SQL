
use hd-vm-bi-sql01.HDDW_PRD
go



select * from [hd-vm-bi-sql01].HDDW_PRD.star.d_region
------ DW ----------------- Guru's query ---

select  f.jde_business_unit, substring( cast(f.d_date_key as varchar) , 1, 6) Order_YYMM
		 ,d.price_group_desc, d.family_group_desc,u.primary_uom_name, 
		sum(f.primary_quantity)   primary_quantity		 

from star.f_so_detail_history  f join  star.d_product  d 	on f.d_product_key = d.d_product_key 
								join star.d_primary_uom u 	on f.d_primary_uom_key = u.d_primary_uom_key 

where    d.item_code = '31121765'
group by f.jde_business_unit, 
		substring( cast(f.d_date_key as varchar) , 1, 6) , 
		 d.price_group_desc, d.family_group_desc,   u.primary_uom_name 
		 order by 1, 2 


-----------------Alan's query --------------------------------------------------------------

select  f.jde_business_unit
        ,c.contact_name
		,d.item_code		
		 ,d.price_group_desc
		 ,d.family_group_desc
		 ,u.primary_uom_name 		 
		 ,substring( cast(f.d_date_key as varchar) , 1, 6) Order_YYMM
		,sum(f.primary_quantity)   primary_quantity		 

from star.f_so_detail_history  f left join  star.d_product  d 	on f.d_product_key = d.d_product_key 
								left join star.d_primary_uom u 	on f.d_primary_uom_key = u.d_primary_uom_key 
								left join star.d_customer c on f.d_customer_key = c.d_customer_key

where    d.item_code = '31121765'
group by f.jde_business_unit 
         ,c.contact_name  
		 ,d.item_code		 
		 ,d.price_group_desc
		 ,d.family_group_desc
		 ,u.primary_uom_name 
		 ,substring( cast(f.d_date_key as varchar) , 1, 6) 
 order by d.item_code
          ,cast(substring( cast(f.d_date_key as varchar) , 1, 6) as int)

------------------------------------------------------------------------------------------------

select count(*) from Star.f_so_detail_history
select top 10 h.*  from Star.f_so_detail_history h

select count(*) from star.d_product p 
select top 10 p.* from star.d_product p 

select count(*) from star.d_customer 
select top 10 c.* from star.d_customer c 

select *
from star.d_customer c 
where c.contact_name like ('%lovelight%')
--where c.customer_number in ('2088109')
order by c.customer_number






select * from HDDW_PRD.Star.