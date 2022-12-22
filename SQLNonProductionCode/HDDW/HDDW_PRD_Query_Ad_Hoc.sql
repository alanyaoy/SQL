


-------------    Hunter Douglas Data Warehouse Ad Hoc query ---------------------
use HDDW_PRD
go


select * from HDDW_PRD.Star.f_so_detail_current c 
where c.order_number in ('5623307')


select * from HDDW_PRD.Star.f_so_detail_history c 
where c.order_number in ('5623307')


--- 980 ( cancelled in order entry ) , 999 ( completed ), 902 ( back order in commitment ), 620 ( ready for sales update)


;with so as

  (  select * from HDDW_PRD.star.f_so_detail_history h
       -- where h.item_code in ('38.001.005')
        
	union all
		 --select * from HDDW_PRD.star.f_so_detail_current c where c.last_line_status_code + c.next_line_status_code <> '980999' and c.item_code in ('FAMT')  --- 12196
		-- select * from HDDW_PRD.star.f_so_detail_current c where c.last_line_status_code <> '980' and c.next_line_status_code <> '999' and c.item_code in ('FAMT')  --- 11810
	 select * from HDDW_PRD.star.f_so_detail_current c where not ( c.last_line_status_code = '980' and c.next_line_status_code = '999')		--- 13022  -- use this one !!		-- 980 cancelled in order entry, 999 completed - ready to Purge 
		-- select * from HDDW_PRD.star.f_so_detail_current c where (not c.last_line_status_code = '980')  or ( not c.next_line_status_code = '999')  --- 13022
		-- select * from HDDW_PRD.star.f_so_detail_current c where ( c.last_line_status_code <> '980')  or (  c.next_line_status_code <> '999')  --- 13022
		        
		)
  --select top 3 * from  so
   
   select so.order_number as So_num,so.work_order_number as So_wo_num,pr.wo_number as part_wo_num,so.item_code,pr.item_code as part_code,pr.parts_description2,pr.quantity as part_SoldQty,pr.uom as part_uom,c.contact_name as customer,so.order_date           
   from so left join HDDW_PRD.star.f_wo_parts_list pr on so.work_order_number = pr.wo_number
           left join  star.d_product p on so.d_product_key = p.d_product_key 
		   left join [hd-vm-bi-sql01].HDDW_PRD.star.d_customer c on so.d_customer_key = c.d_customer_key
	where 
       -- so.work_order_number = '04685890'
	   -- so.order_number in ('5623307')
		--and so.jde_business_unit = 'AWF'    	    
		so.item_code in ('FAMT')	
		--and so.order_number in ('05614583')   
	   -- p.item_code in ('42.421.855','52.018.000','44.011.007')
	      pr.item_code in ('38.001.005')


select top 3 * from HDDW_PRD.star.f_so_detail_history
select distinct h.jde_business_unit,h.business_unit_code from HDDW_PRD.star.f_so_detail_history h
select distinct c.jde_business_unit,c.business_unit_code from HDDW_PRD.star.f_so_detail_current c


-------------------- To Get All sales history for '44.011.007' fibre glass using Sales history table including all channels ie AWF, WCC etc -----------------------------

select h.item_code,h.d_product_key,h.d_customer_key,h.d_account_manager_key,h.order_number,h.company_code,h.order_type,h.jde_business_unit,h.business_unit_code
       ,h.sold_to_account_code,h.invoice_number,h.gl_class,h.order_date,h.ship_date,h.invoice_date,h.pricing_uom,h.primary_quantity,h.sales_quantity,h.sales_amount,h.cost_amount,h.unit_list_price
	   ,h.customer_number,h.last_line_status_code,h.next_line_status_code,h.work_order_number,h.dss_record_source,c.d_customer_key,c.customer_number,c.contact_name,c.sold_to_account_code,c.sold_to_account_manager_name,c.channel_name,c.state_code  		  
		 ,cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,h.invoice_date),0),126),'-',''),1,8) as integer) as Inv_YYMMDD	
		   ,cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,h.invoice_date),0),126),'-',''),1,6) as integer) as Inv_YYMM	
from HDDW_PRD.star.f_so_detail_history h left  join star.d_customer c on h.d_customer_key = c.d_customer_key
        where h.item_code in ('38.001.005')
		-- where h.item_code in ('44.011.007')
order by h.invoice_date desc

------------- Blue Pacific , account no. #2867256 Sales history for Metal Awning ---------- 2/3/2020 ----------



