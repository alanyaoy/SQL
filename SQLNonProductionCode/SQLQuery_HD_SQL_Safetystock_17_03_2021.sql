
use JDE_DB_Alan
go


/****** Script for SelectTopNRows command from SSMS  ******/


SELECT *
  FROM [JDE_DB_Alan].[JDE_DB_Alan].[FCPRO_SafetyStock] s
--  where s.ItemNumber in ('42.210.031','34.406.000')

  
 ;with c as 
  (select a.ItemNumber,a.SS_Adj,a.SS_Adj_Dollars from JDE_DB_Alan.vw_SafetyStock a
		--a.*,a.SS_Adj * m.StandardCost as SS_Dollars from JDE_DB_Alan.vw_SafetyStock a left join JDE_DB_Alan.vw_Mast m on a.ItemNumber = m.ItemNumber
		where a.Pareto in ('C')

     )
	-- select * from c

  select coalesce(ItemNumber,'Total') as Itm
         ,sum(SS_Adj_Dollars) as Amt
  from c
  Group by grouping sets((ItemNumber),());


  --select * from JDE_DB_Alan.FCPRO_SafetyStock_Oldcopy

  --inst into JDE_DB_Alan.FCPRO_SafetyStock (ItemNumber,Sales_12Mth,Pareto,StockingType,Stdevp_,LeadtimeLevel,rn,SS_,SS_Adj,ValidStatus_Adj_Flag,ReportDate) select * from JDE_DB_Alan.FCPRO_SafetyStock_Oldcopy c where c.ItemNumber in ('42.210.031')
  --del from JDE_DB_Alan.FCPRO_SafetyStock where ReportDate < '2021-02-28'

  -- select * from JDE_DB_Alan.FCPRO_SafetyStock where ReportDate < '2021-02-28'


  --select m.Item_Number,m.Short_Item_Number,m.StandardCost,m.SS_Adj_Jde,m.SS_Adj,m.Leadtime_Level,m.Stocking_Type,m.Pareto
  select m.Item_Number,m.Pareto,m.Stocking_Type,m.SS_Adj_Jde,m.Leadtime_Level,m.StandardCost,m.Order_Policy,m.Order_Policy_Description,m.Planning_Code,m.Planning_Code_Description
         ,m.Planning_Fence_Rule,m.Planning_Fence_Rule_Description,GETDATE() as rpdt
  from JDE_DB_Alan.vw_Mast_Planning m
  where m.Item_Number in ('42.210.031','24.7219.0952')

    select * from JDE_DB_Alan.FCPRO_SafetyStock a where a.ItemNumber in ('26.805.000','42.210.031','24.7219.0952','34.249.000')

insert into JDE_DB_Alan.FCPRO_SafetyStock (ItemNumber,Pareto,StockingType,SS_Adj,ValidStatus_Adj_Flag,LeadtimeLevel,StandardCost,Order_Policy,Order_Policy_Description,Planning_Code,Planning_Code_Description
											,Planning_Fence_Rule,Planning_Fence_Rule_Description,ReportDate)
 select m.Item_Number,m.Pareto,m.Stocking_Type,m.SS_Adj_Jde,'N',m.Leadtime_Level,m.StandardCost,m.Order_Policy,m.Order_Policy_Description,m.Planning_Code,m.Planning_Code_Description
         ,m.Planning_Fence_Rule,m.Planning_Fence_Rule_Description,GETDATE() as rpdt 
 from JDE_DB_Alan.vw_Mast_Planning m 
 where m.Item_Number in ( select distinct f.ItemNumber from JDE_DB_Alan.FCPRO_Fcst f )


--- update SS table --- 
 ;update a
set a.rn = 1
from JDE_DB_Alan.FCPRO_SafetyStock a
where  ReportDate <'2021-03-13'


;update a
set a.ReportDate = '2021-03-12 15:00:00'
from JDE_DB_Alan.FCPRO_SafetyStock a
      inner join JDE_DB_Alan.FCPRO_SafetyStock b on a.ItemNumber = b.ItemNumber  
where a.ReportDate between '2021-03-17 12:47:00' and '2021-03-17 13:00:00'
--where a.ReportDate between '2018-04-20' and '2018-05-03 13:00:00'


;update a
set a.SS_ = b.SS_Adj
from JDE_DB_Alan.FCPRO_SafetyStock a
      inner join JDE_DB_Alan.FCPRO_SafetyStock b on a.ItemNumber = b.ItemNumber 
where a.ReportDate <'2021-03-13'



 --- check column name ---
SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = N'FCPRO_SafetyStock'

delete from JDE_DB_Alan.FCPRO_SafetyStock where ReportDate >'2021-03-17'
select * from JDE_DB_Alan.FCPRO_SafetyStock where ReportDate >'2021-03-17'


  select top 3 * from JDE_DB_Alan.Master_V4102A m where m.Item_Number in ('26.805.000')
  select top 3 * from JDE_DB_Alan.vw_Mast_Planning m where m.Item_Number in ('26.805.000')


  --- leave sequence this way,because in V4102A you first get Jde SS, then new calculation of SS_Adj, when uploading SS into JDE, you might need to change 
 select m.Item_Number,m.Short_Item_Number,m.StandardCost,m.SS_Adj_Jde,m.SS_Adj,m.Leadtime_Level,m.Stocking_Type,m.Pareto,m.Leadtime_Level
  from JDE_DB_Alan.vw_Mast_Planning m
  where m.Item_Number in ('42.210.031','24.7219.0952')

    select * from JDE_DB_Alan.FCPRO_SafetyStock a where a.ItemNumber in ('26.805.000','42.210.031','24.7219.0952','82.520.901','7196010001','PR61075905','12.171.033')
	order by a.Pareto,a.ItemNumber


    select distinct (a.ReportDate) from JDE_DB_Alan.FCPRO_SafetyStock a 



	---- check summary of safety stock table ---

	;with  t as (	select count(a.ItemNumber) as Rows_,convert(varchar,a.ReportDate,120) as ReportDate_ from JDE_DB_Alan.FCPRO_SafetyStock a group by convert(varchar,a.ReportDate,120) )

		SELECT ReportDate_ = COALESCE(ReportDate_, 'Total'), 
			   Rows_ = SUM(Rows_)
		FROM t
		GROUP BY GROUPING SETS((ReportDate_),());