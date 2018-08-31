
use JDE_DB_Alan
go

--select * from JDE_DB_Alan.FCPRO_Fcst fc
--where fc.ItemNumber in ('2950100000')

select * from JDE_DB_Alan.JDE_Fcst_DL fc where fc.ItemNumber in ('2950100000')
select * from JDE_DB_Alan.Master_ItemCrossRef c where c.ItemNumber in ('2950100000')


select *
    ,rank() over (partition by ItemNumber,Address_Number order by c.expireddate desc ) as myrnk
	,row_number() over(partition by ItemNumber,Address_Number order by Address_Number desc ) as rnk
	,max(c.ExpiredDate) over(partition by ItemNumber,Address_Number order by Address_Number desc ) as max_expir_date
from JDE_DB_Alan.Master_ItemCrossRef c 
where c.ItemNumber in ('2950100000') 
--and c.Address_Number in ('20037')

---===================================================================================================================================================================
-------- Get FC from JDE for Particular Supplier -- works Yeah !!! 17/1/2018 ------------ Need First create Table for JDE FC & Item Cross Ref --------------------

--- need to pick up the latest record in ItemCrossRef Table---- 
with cte as (
	select *
    ,rank() over (partition by ItemNumber,Address_Number order by c.expireddate desc ) as myrnk
	,row_number() over(partition by ItemNumber,Address_Number order by Address_Number desc ) as rnk
	,max(c.ExpiredDate) over(partition by ItemNumber,Address_Number order by Address_Number desc ) as max_expir_date
	from JDE_DB_Alan.Master_ItemCrossRef c 
	--where c.ItemNumber in ('2950100000') 
	),
 cte_ as 
	( select * from cte where cte.rnk = 1 
	 )
-- select * from cte_  
	
select fc.ShortItemNunber,fc.ItemNumber
		--,fc.Date
		,dateadd(mm,-1,dateadd(d,1,fc.Date)) as FC_Date				-- Get first day of month since Jde FC date is end of each month
		,fc.Qty,cte_.Customer_Supplier_ItemNumber,cte_.Address_Number,fc.ReportDate,p.Pareto,m.UOM			-- Need to get UOM and Pareto
from JDE_DB_Alan.JDE_Fcst_DL fc left join cte_ on fc.ItemNumber = cte_.ItemNumber
     left join JDE_DB_Alan.FCPRO_Fcst_Pareto p on fc.ItemNumber = p.ItemNumber
	 left join JDE_DB_Alan.Master_ML345 m on fc.ShortItemNunber = m.ShortItemNumber
where  cte_.Address_Number in ('20037')
		and m.StockingType in ('P','S')
      -- and fc.ItemNumber in ('2950100000') 
	   and fc.ItemNumber not in ('27.173.135','27.175.135')
--order by fc.ItemNumber,fc.Date
order by cte_.Address_Number,p.Pareto,fc.ItemNumber,fc.Date



--==========================================================================================================================================================
------ Jde Downloaded Fcst ----- 18/1/2018 -- Need to Updated Item Cross Ref for Record with '*' sign - I can update thousands records in one seconds !

	;update m
	set m.Customer_Supplier_ItemNumber = ( case 
										when m.Customer_Supplier_ItemNumber = ('*') then m.ItemNumber	
										when m.Customer_Supplier_ItemNumber = '' then m.ItemNumber		 
										else m.Customer_Supplier_ItemNumber
										end )
						
	from JDE_DB_Alan.Master_ItemCrossRef m
	--where m.ItemNumber in ('7612208013')
	--where m.ItemNumber in ('2930564000')
	 where  m.Address_Number in ('20037')


	
	select *
	--from JDE_DB_Alan.Master_ItemCrossRef m where m.Address_Number in ('20037')
	from JDE_DB_Alan.Master_ItemCrossRef m where m.ItemNumber in ('2930564000','7612208013') and m.Address_Number in ('20037')
	--from JDE_DB_Alan.Master_ItemCrossRef m where m.Customer_Supplier_ItemNumber like ('%*')
	 from JDE_DB_Alan.Master_ItemCrossRef m where m.Customer_Supplier_ItemNumber = ('*') and m.Address_Number in ('20037')