use JDE_DB_Alan
go

-----------------------------  MT History     25/10/2017 ------------------------------------------------------


--==============================================================================
--- First need to delete old data for HD,MT,AWF table, important !!! ----
--==============================================================================

select * from JDE_DB_Alan.SalesHistoryAWFHDMT
select * from JDE_DB_Alan.SalesHistoryHD
select * from JDE_DB_Alan.SalesHistoryMT
delete from JDE_DB_Alan.SalesHistoryAWFHDMT
delete from JDE_DB_Alan.SalesHistoryHD
delete from JDE_DB_Alan.SalesHistoryMT


---- Start to fix issue for Item with leading zero --------


 ;with l as ( select y.*,
				case 
				   when y.ItemWithLeadingZero ='Y' then '0'+ y.ItemNumber
					else  y.ItemNumber		    
				   end as myItemNumber
			 from JDE_DB_Alan.MasterMTLeadingZeroItemList y
      
	  ),

--- get stocking type ---
 t as (
          select a.*,x.StockingType 
		  from JDE_DB_Alan.SalesHistoryMT a left join JDE_DB_Alan.Master_R55ML345_Description_Hierarchy_SKU_Level x
			   on a.ShortItemNumber = x.ShortItemNumber 
		  ),

m as ( 
        select t.*,l.myItemNumber
		       ,case when l.myItemNumber is null then t.ItemNumber
			       else t.ItemNumber 
		        end as fItemNumber
		from t left join l on t.ShortItemNumber = l.ShortItemNo 
		--where  t.ShortItemNumber in ('1218124','159804') 
				--and concat(t.Century,t.FinancialYear,t.FinancialMonth) = '201512'
		),

--select * from m where m.myItemNumber is null
--select * from m 
--where m.ShortItemNumber in ('1218124','159804') and concat(m.Century,m.FinancialYear,m.FinancialMonth) = '201512'
--order by m.Century,m.FinancialYear,m.FinancialMonth

tb as ( select m.bu,m.ShortItemNumber,m.fItemNumber
   --    case 
	  --     when m.myItemNumber is null then m.ItemNumber
		 --   else  m.myItemNumber		    
			--end as fItemNumber,
		,m.Century,m.FinancialYear,m.FinancialMonth,m.DocumentType,m.Quantity,m.UOM,m.StockingType					
		 from m
     ),
--select * from tb

  	--- Superssion for Bricos Item ---
  tbl as (
	select tb.*,b.NewItemNumberHD,b.NewShortItemNumberHD
	from tb 
	     left join JDE_DB_Alan.MasterMTSuperssionItemList b on tb.fItemNumber = b.CurrentItemNumberMT   
    where tb.StockingType in ('P','S') 
	   --   and a.ItemNumber in ('28.380.108')
	),

  mt as (select case 
	       when tbl.BU ='MT' then 'HD'
		    else  'HD'		    
			end as BU
		,case  
		  when tbl.NewShortItemNumberHD is null then tbl.ShortItemNumber
		    else tbl.NewShortItemNumberHD 
			end as FinalShortItemNumber
	   , case 
	       when tbl.NewItemNumberHD is null then tbl.fItemNumber
		    else tbl.NewItemNumberHD 
			end as FinalItemNumber
		,tbl.Century,tbl.FinancialYear,tbl.FinancialMonth,tbl.DocumentType,tbl.Quantity,tbl.UOM
		
 from tbl ),

 --select * from mt
 --select * from JDE_DB_Alan.SalesHistoryHD a
---------------------------  HD History  -----------------------------------------------------------------

 d as ( 
        select h.*,l.myItemNumber from JDE_DB_Alan.SalesHistoryHD h left join l on h.ShortItemNumber = l.ShortItemNo 
		),
	  
hd as ( select d.bu,d.ShortItemNumber,
       case 
	       when d.myItemNumber is null then d.ItemNumber
		    else  d.myItemNumber		    
			end as fItemNumber
        ,
		d.Century,d.FinancialYear,d.FinancialMonth,d.DocumentType,d.Quantity,d.UOM					
		 from d ),

cb as (		
		select * from mt
		union all
		select * from hd 
     )

 select * from cb
 where cb.FinalItemNumber in ('44.132.000')

 ---========================================================
 --- Need to delete History first before Insert data into 'SalesHistoryAWFHDMT' Table  ---
  ---========================================================
delete from JDE_DB_Alan.SalesHistoryAWFHDMT

INSERT INTO JDE_DB_Alan.SalesHistoryAWFHDMT
SELECT * FROM cb
  

----------------------------------------------------------
use JDE_DB_Alan
go

select * from JDE_DB_Alan.SalesHistoryAWFHDMT a where a.ItemNumber in ('44.132.000')
select * from JDE_DB_Alan.Master_R55ML345_Description_Hierarchy_SKU_Level a where a.ItemNumber in ('44.132.000')

select * from JDE_DB_Alan.SalesHistoryHDAWF
delete from JDE_DB_Alan.SalesHistoryHDAWF


-------------------------- ML345  ------------------------------------------------------------

----  fix issue for Item with leading zero --------
 ;with l as ( select y.*,
        case 
	       when y.ItemWithLeadingZero ='Y' then '0'+ y.ItemNumber
		    else  y.ItemNumber		    
			end as myItemNumber
         from JDE_DB_Alan.MasterMTLeadingZeroItemList y
      
	  ),

 m as ( 
        select t.*,l.myItemNumber from JDE_DB_Alan.Master_R55ML345_Description_Hierarchy_SKU_Level t 
		left join l on t.ShortItemNumber = l.ShortItemNo 
		),
--select * from m
	  
ml as ( select m.BU,
       case 
	       when m.myItemNumber is null then m.ItemNumber
		    else  m.myItemNumber		    
			end as fItemNumber
        ,m.ShortItemNumber,m.description,m.SellingGroup,m.FamilyGroup,m.Family,m.Standardcost,m.WholeSalePrice					
		 from m )

select * from ml



INSERT INTO 
SELECT * FROM 
  

select * from JDE_DB_Alan.Master_R55ML345_Description_Hierarchy_SKU_Level

--delete from JDE_DB_Alan.Master_R55ML345_Description_Hierarchy_SKU_Level


---=================== CTE for Hunter Douglas Sales History =====================================================================

select * from JDE_DB_Alan.SalesHistoryAWFHDMT a where a.ShortItemNumber in ('1074571')
select * from JDE_DB_Alan.SalesHistoryAWFHDMT a where a.ItemNumber in ('44.132.000')
select * from JDE_DB_Alan.MasterFamily a where contains(a.Description,'B')
select * from JDE_DB_Alan.MasterFamily a where substring(a.Code,1,1) ='2'
select * from JDE_DB_Alan.MasterFamily a where a.code not like ('%[^0-9]%') and substring(a.Code,1,1) ='2'   -- works
select * from JDE_DB_Alan.MasterFamily a where a.code not like ('%[^0-9]%') and convert(int,substring(a.Code,1,1)) =2   -- does not work
select * from JDE_DB_Alan.MasterFamily a where a.code not like ('%[^0-9]%') and convert(float,substring(a.Code,1,1)) =2   -- does not work
select * from JDE_DB_Alan.MasterFamily a where a.code not like ('%[^0-9]%') and cast( substring(a.Code,1,1) as int) =2 



select substring(a.Code,1,1) from JDE_DB_Alan.MasterFamily a
select convert(int,substring(a.Code,1,1)) from JDE_DB_Alan.MasterFamily a
select cast(substring(a.Code,1,1) as int) from JDE_DB_Alan.MasterFamily a


select * from JDE_DB_Alan.MasterFamily a where a.code like '8%'
select * from JDE_DB_Alan.MasterFamily a where a.code not like ('%[^0-9]%')  --- wrong need to put carat inside box
select * from JDE_DB_Alan.MasterFamily a where a.code not like ('%[^0-9]%')  --- show all items only with numbers
select * from JDE_DB_Alan.MasterFamily a where substring(a.Code,1,1) not like ('%[^0-9]%')  --- show all items starts with numbers 
select * from JDE_DB_Alan.MasterFamily a where a.code not like ('%[^a-z]%')  --- show all items only with letters



select * from JDE_DB_Alan.MasterFamilyGroup a 
order by a.code
select * from JDE_DB_Alan.MasterFamilyGroup a where a.Code like ('[2-9]%')
select * from JDE_DB_Alan.MasterSellingGroup

select SERVERPROPERTY('isfulltextinstalled')

------ Very First First to Need to consolidate HD & MT Data --- on ItemNum , ShortItemNum level 

;with tb as (
select BU,ItemNumber,a.ShortItemNumber,a.Century,a.FinancialYear,a.FinancialMonth,a.UOM,sum(a.Quantity) as Quantity
 from JDE_DB_Alan.SalesHistoryAWFHDMT a
 group by BU,ItemNumber,a.ShortItemNumber,a.Century,a.FinancialYear,a.FinancialMonth,a.UOM
 --order by BU,a.ItemNumber,a.ShortItemNum,a.Century asc,a.FinancialYear asc,a.FinancialMonth desc
    ),

 ------ First to get rough selling group/family group/family info from R55ML345 Table ---------

 tbl as (
select b.BU,tb.ItemNumber
		,tb.ShortItemNumber		
     --   , case a.FinancialMonth 
		   --   when > 10  then a.FinancialMonth
			  --else right('00'+a.financialMonth,2)  end

		,tb.Century,tb.FinancialYear,tb.FinancialMonth
		,tb.Quantity,tb.Quantity * (-1) as SalesQty,b.Description,b.SellingGroup,b.FamilyGroup,b.Family,tb.UOM,b.StandardCost,b.WholeSalePrice
 from	--JDE_DB_Alan.SalesHistoryHDAWF a 
        tb
		left join JDE_DB_Alan.Master_R55ML345_Description_Hierarchy_SKU_Level b			--R55ML345 Table
	 --  on a.ItemNumber = b.ItemNumber
	   on tb.ShortItemNumber = b.ShortItemNumber
--where a.ItemNumber in ('27.161.135') 
       ),

--select * from tbl where tbl.ItemNumber in ('44.132.000')
--- Then get your long description of selling group/family group/family which Nic wants ---
staging as 
(select  tbl.*
		,c.LongDescription as SellingGroup_
		,d.LongDescription as FamilyGroup_
		,e.LongDescription as Family_0
		--,tbl.Family as Family_1
		--,f.StandardCost,f.WholeSalePrice
from tbl left join JDE_DB_Alan.MasterSellingGroup c  on tbl.SellingGroup = c.Code
         left join JDE_DB_Alan.MasterFamilyGroup d  on tbl.FamilyGroup = d.Code
		 left join JDE_DB_Alan.MasterFamily e  on tbl.Family = e.Code
   ),

----- Then get your final Customerised Output ------
--  select * from staging where staging.ItemNumber in ('27.161.135')

z as  (
select 'Total' as RowLabel,staging.SellingGroup_ as SellingGroup,staging.FamilyGroup_ as FamilyGroup,staging.Family_0 as Family,
		--staging.Family_1,
		staging.ItemNumber,staging.Description
		--,cast(staging.Century as varchar(10))+ cast(staging.FinancialYear as varchar(10))+cast(staging.FinancialMonth as varchar(10)) as CYM
		,cast(staging.Century as varchar(10))+ cast(staging.FinancialYear as varchar(10)) as CY
		,staging.Century,staging.FinancialYear as Year,staging.FinancialMonth as Month
		,case  
		     when staging.FinancialMonth  >= 10  then format(staging.FinancialMonth,'0') 
			 --else right('000'+cast(a.financialMonth as varchar(2)),3)  
			 when staging.FinancialMonth  <10  then format(staging.FinancialMonth,'00') 
		end as MM
		,'12' as PPY, '12' as PPC
		,staging.SalesQty,staging.StandardCost,staging.WholeSalePrice,SalesQty*StandardCost as InventoryVal, SalesQty*WholeSalePrice as SalesVal
from staging

    )

select * from z
where z.ItemNumber in ('44.132.000')
--where StandardCost > WholeSalePrice
--order by SalesVal desc
   
  ----- Need to consolidate Sales History if there are one ItemNum but mulitple ShortItemNum ?--- After this operation you will lost your descriiption since for  one  item you might have 2 different description, to get ItemNum level data, you NEED aggregate and remove description level,your data set will only have this info--> Hierarchy/ItemNum/Year/Month/Qty
 zz as (
	select z.RowLabel,z.SellingGroup,z.FamilyGroup,z.Family,z.ItemNumber,concat(z.CY,z.MM) as CYM,z.CY,z.Century,z.Year,z.Month,z.PPY,z.PPC,sum(SalesQty) as SalesQty_,sum(z.InventoryVal) as InventoryVal_,sum(z.SalesVal) as SalesVal_
	from z 
--where z.ItemNumber in ('8.51E+11') 
      -- and z.Year in ('15') and z.month in ('1')
		-- and (z.Year + z.Month like '%20151')
group by  z.RowLabel,z.SellingGroup,z.FamilyGroup,z.Family,z.ItemNumber,concat(z.CY,z.MM),z.CY,z.Century,z.Year,z.Month,z.PPY,z.PPC
  ),

   ---==== To get your description from ML345 to join back your data set but First need to fix the ItemNumber with leading zero for ML345  ---
 l as ( select y.*,
        case 
	       when y.ItemWithLeadingZero ='Y' then '0'+ y.ItemNumber
		    else  y.ItemNumber		    
			end as myItemNumber
         from JDE_DB_Alan.MasterMTLeadingZeroItemList y
      
	  ),

 m as ( 
        select t.*,l.myItemNumber from JDE_DB_Alan.Master_R55ML345_Description_Hierarchy_SKU_Level t 
		left join l on t.ShortItemNumber = l.ShortItemNo 
		),
--select * from m
	  
ml as ( select m.BU,
       case 
	       when m.myItemNumber is null then m.ItemNumber
		    else  m.myItemNumber		    
			end as fItemNumber
        ,m.ShortItemNumber,m.description,m.SellingGroup,m.FamilyGroup,m.Family,m.Standardcost,m.WholeSalePrice					
		 from m ),

cte1 as (
select ml.fItemNumber,ml.Description,ml.StandardCost,ml.WholeSalePrice
		,row_number() over(partition by ml.fitemnumber order by fitemnumber ) rn  
 from ml
 ),

 cte as (
 select * from cte1 
 where rn = 1 ),


 --- Below will yield result for Combined MT + HD History Ready for Upload to Forecast Pro ---
 fl as (
 select zz.RowLabel,zz.SellingGroup,zz.FamilyGroup,zz.Family,rtrim(ltrim(zz.ItemNumber)) as ItemNumber_,cte.Description,cte.standardcost,cte.wholesaleprice,zz.CYM,zz.CY,zz.Month,zz.PPY,zz.PPC,zz.SalesQty_
 from zz left join cte on zz.ItemNumber = cte.fItemNumber
 --  from zz inner join cte on zz.ItemNumber = cte.ItemNumber
   )

select* from fl 
where fl.ItemNumber_ in ('44.132.000')
order by fl.SellingGroup,fl.FamilyGroup,fl.Family,fl.ItemNumber_,fl.CYM


------- To Get Your Price Conversion table ----
flpri as ( select fl.RowLabel,fl.SellingGroup,fl.FamilyGroup,fl.Family,fl.ItemNumber_,fl.StandardCost,fl.WholeSalePrice
			      ,row_number() over(partition by fl.itemnumber_ order by itemnumber_) as rn
			from fl
			)


select * from flpri where flpri.rn =1

-- To get your distinct ItemNumber (give you 9932 records ) --- no need to get another join you can just tweet cte query to include cost & wholesaleprice ---
-- just remember need to manual change either cost or  retail price is 0 or both are 0 then upload into Master price table in SQL DB ---

--select distinct fl.ItemNumber_ from fl


--where fl.ItemNumber like ('%7840001000') or fl.ItemNumber like ('%Item.32000')
--where fl.ItemNumber like ('%18.217.010')
 where fl.ItemNumber_ in ('28.552.000')
order by fl.RowLabel,fl.SellingGroup,fl.FamilyGroup,fl.Family,fl.ItemNumber_,fl.CY,fl.Month

exec JDE_DB_Alan.sp_GetHDHist
exec JDE_DB_Alan.sp_GetHDHist @ItemNumber = '28.552.000'
---------------------------------- end of CTE ---------------------------------------