

 --- Sun Solution WA --- dummy order SO ( 5623307 ) and WO ( 4709432 ) cancelled but cannot see in DW table --- see email sent to Guru 5/3/2020

;with so as

  (  select * from HDDW_PRD.star.f_so_detail_history h        
	union all		
	 select * from HDDW_PRD.star.f_so_detail_current c where not ( c.last_line_status_code = '980' and c.next_line_status_code = '999')		--- 13022  -- use this one !!		        
		)
  --select top 3 * from  so   
   select so.order_number as So_num,so.work_order_number as So_wo_num,pr.wo_number as part_wo_num,so.item_code,pr.item_code as part_code,pr.parts_description2,pr.quantity as part_SoldQty,pr.uom as part_uom,c.contact_name as customer,so.order_date           
   from so left join HDDW_PRD.star.f_wo_parts_list pr on so.work_order_number = pr.wo_number
           left join  star.d_product p on so.d_product_key = p.d_product_key 
		   left join [hd-vm-bi-sql01].HDDW_PRD.star.d_customer c on so.d_customer_key = c.d_customer_key
	where  
		---so.work_order_number = '04685890'     -- works !
		 so.order_number in ('5623307')          -- do not yield details --- order has been cancelled though in JDE