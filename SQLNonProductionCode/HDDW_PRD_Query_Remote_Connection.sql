

--- connecting remotely --- hd-vm-bi-sql01.hd.local 

  --- it is successful ---- Yeah 19/3/2020

use HDDW_PRD
go

;with so as

  (  	select * from HDDW_PRD.star.f_so_detail_history
		union all
		 --select * from HDDW_PRD.star.f_so_detail_current c where c.last_line_status_code + c.next_line_status_code <> '980999' and c.item_code in ('FAMT')  --- 12196
		-- select * from HDDW_PRD.star.f_so_detail_current c where c.last_line_status_code <> '980' and c.next_line_status_code <> '999' and c.item_code in ('FAMT')  --- 11810
		 select * from HDDW_PRD.star.f_so_detail_current c where not ( c.last_line_status_code = '980' and c.next_line_status_code = '999')		--- 13022  -- use this one !!
		-- select * from HDDW_PRD.star.f_so_detail_current c where (not c.last_line_status_code = '980')  or ( not c.next_line_status_code = '999')  --- 13022
		-- select * from HDDW_PRD.star.f_so_detail_current c where ( c.last_line_status_code <> '980')  or (  c.next_line_status_code <> '999')  --- 13022
		        
		)
  --select * from  so
   ,comb as (
		   select so.order_number as So_num,so.work_order_number as So_wo_num,pr.wo_number as Part_wo_num
				 ,so.d_product_key as Parent_pd_key,so.item_code as Parent,pr.d_product_key Child_pd_key,pr.item_code as Child,pr.parts_description2,so.primary_quantity as ParentSoldQty,pr.quantity as ChildSoldQty,pr.uom Child_uom
				  ,cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,so.order_date),0),126),'-',''),1,8) as integer) as Ord_YYMMDD	
				  ,cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,so.order_date),0),126),'-',''),1,6) as integer) as Ord_YYMM
  				 ,c.contact_name as customer
				 ,so.order_date
		
		   from so left join HDDW_PRD.star.f_wo_parts_list pr on so.work_order_number = pr.wo_number
				   left join  star.d_product pd on so.d_product_key = pd.d_product_key 
				   left join star.d_customer c on so.d_customer_key = c.d_customer_key
		   where 
		          so.item_code in ('FACSD2')				-- EVO - Alpha SRS (1118 )/ Alpha Cable (145) / Alpha Drop (349) (To Get component )
		        --  so.item_code in ('FAAU')					-- Folding Arm - Auto lock arm (981)/  Fixed guide (181) / Fixed guide Motorised (134 ) (To Get component )
				--so.item_code in ('FAMT')						--- Alpha M / Magnatrack (To Get component )
				 --  so.item_code in ('PRHI1')					--- Poly Resin Shutter ( To get component )
			  --  and so.jde_business_unit = 'AWF'    
				--and so.work_order_number = '04685890'   
				--and pr.item_code in ('42.421.855','52.018.000','44.011.007')
				   --  so.order_number in ('5623307')                  -- Sun solution dummy order
				 --  so.order_number in ('5626957')                  -- Sun solution real order
		 
		   --  order by so.order_number                       
		 )

     select * from comb z
	  where z.Ord_YYMM >201812

	 select distinct z.Ord_YYMM from comb z
	 where z.Ord_YYMM >201812
	 order by z.So_num

 select top 3 * from star.d_product


  select count(*) from HDDW_PRD.Star.d_customer

  select * from HDDW_PRD.star.d_product p where p.item_code in ('RBSC','38.001.005')