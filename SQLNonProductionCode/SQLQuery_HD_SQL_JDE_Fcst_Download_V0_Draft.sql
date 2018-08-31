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
	 ),
-- select * from cte_  

itm_mthLvl	 as (
select fc.ShortItemNunber,fc.ItemNumber,m.Description
		--,fc.Date
		,dateadd(mm,-1,dateadd(d,1,fc.Date)) as FC_Date				-- Get first day of month since Jde FC date is end of each month
		,isnull(fc.Qty,0) as FC_Qty
		,isnull(m.QtyOnHand,0) as SOH
		,cte_.Customer_Supplier_ItemNumber,cte_.Address_Number,p.Pareto,m.UOM			-- Need to get UOM and Pareto		
		,isnull(m.StandardCost,0) Cost,isnull(m.WholeSalePrice,0) SlsPx
		,isnull(m.WholeSalePrice * fc.Qty,0) as FC_Amt
		,isnull(m.StandardCost * m.QtyOnHand,0) as SOH_Amt
		,isnull(avg(fc.qty) over( partition by fc.itemnumber),0) as AvgMthFC
		,coalesce(isnull(m.QtyOnHand,0)/nullif(isnull(avg(fc.qty) over( partition by fc.itemnumber),0),0),0)  as MthCover
		,fc.ReportDate

from JDE_DB_Alan.JDE_Fcst_DL fc left join cte_ on fc.ItemNumber = cte_.ItemNumber
     left join JDE_DB_Alan.FCPRO_Fcst_Pareto p on fc.ItemNumber = p.ItemNumber
	 left join JDE_DB_Alan.Master_ML345 m on fc.ShortItemNunber = m.ShortItemNumber
where  cte_.Address_Number in ('20037')
		and m.StockingType in ('P','S')
      -- and fc.ItemNumber in ('2950100000') 
	   and fc.ItemNumber not in ('27.173.135','27.175.135')			--excluding some discontinued item, People need to update stock types for these items in JDe to prevent it sneak through
--order by fc.ItemNumber,fc.Date
--order by cte_.Address_Number,p.Pareto,fc.ItemNumber,fc.Date
         )
		 
select * from itm_mthLvl  
where itm_mthLvl.ItemNumber in ('24.7185.0000')
 -- order by MthCover desc
 --order by Address_Number,Pareto,ItemNumber,itm_Lvl.FC_Date 


   --select l.ItemNumber,l.Description,l.Customer_Supplier_ItemNumber,l.Address_Number
   --      ,sum(FC_Qty) as FC_Qty_24mth
		 --,avg(AvgMthFC) as AvgMthFC

   --from itm_mthLvl l
   --group by l.ItemNumber,l.Description,l.Customer_Supplier_ItemNumber,l.Address_Number
    