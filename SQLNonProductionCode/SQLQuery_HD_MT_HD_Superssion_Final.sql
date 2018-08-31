use JDE_DB_Alan
go

-----------------------------  MT History     25/10/2017 ------------------------------------------------------

with t as ( select * 
		from JDE_DB_Alan.SalesHistoryAWFHDMT a )

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

tb1 as ( select m.bu,m.ShortItemNumber,m.fItemNumber
   --    case 
	  --     when m.myItemNumber is null then m.ItemNumber
		 --   else  m.myItemNumber		    
			--end as fItemNumber,
		,m.Century,m.FinancialYear,m.FinancialMonth,m.DocumentType,m.Quantity,m.UOM,m.StockingType					
		 from m
     ),
--select * from tb

  	--- Superssion for Bricos Item ---
  tbl1 as (
	select tb1.*,b.NewItemNumberHD,b.NewShortItemNumberHD
	from tb1 
	     left join JDE_DB_Alan.MasterMTSuperssionItemList b on tb1.fItemNumber = b.CurrentItemNumberMT   
    where tb1.StockingType in ('P','S') 
	   --   and a.ItemNumber in ('28.380.108')
	),

  mt as (select case 
	       when tbl1.BU ='MT' then 'HD'
		    else  'HD'		    
			end as BU
		,case  
		  when tbl1.NewShortItemNumberHD is null then tbl1.ShortItemNumber
		    else tbl1.NewShortItemNumberHD 
			end as FinalShortItemNumber
	   , case 
	       when tbl1.NewItemNumberHD is null then tbl1.fItemNumber
		    else tbl1.NewItemNumberHD 
			end as FinalItemNumber
		,tbl1.Century,tbl1.FinancialYear,tbl1.FinancialMonth,tbl1.DocumentType,tbl1.Quantity,tbl1.UOM
		
 from tbl1 ),

 --select * from mt
 --select * from JDE_DB_Alan.SalesHistoryHD a
---------------------------  HD History  -----------------------------------------------------------------

 dd as ( 
        select h.*,l.myItemNumber from JDE_DB_Alan.SalesHistoryHD h left join l on h.ShortItemNumber = l.ShortItemNo 
		),
	  
hd as ( select dd.bu,dd.ShortItemNumber,
       case 
	       when dd.myItemNumber is null then dd.ItemNumber
		    else  dd.myItemNumber		    
			end as fItemNumber
        ,
		dd.Century,dd.FinancialYear,dd.FinancialMonth,dd.DocumentType,dd.Quantity,dd.UOM					
		 from dd ),

cb as (		
		select * from mt
		union all
		select * from hd 
     ),

-- select * from cb

 ---========================================================
 --- Need to delete History first before Insert data into 'SalesHistoryAWFHDMT' Table  ---
  ---========================================================
--delete from JDE_DB_Alan.SalesHistoryAWFHDMT

--INSERT INTO JDE_DB_Alan.SalesHistoryAWFHDMT
--SELECT * FROM cb
  

------------------------------------------------------------
--select * from JDE_DB_Alan.SalesHistoryAWFHDMT

--select * from JDE_DB_Alan.SalesHistoryHDAWF
--delete from JDE_DB_Alan.SalesHistoryHDAWF


---=================== CTE for Hunter Douglas Sales History =====================================================================

------ Very First First to Need to consolidate HD & MT Data --- on ItemNum , ShortItemNum level 

 tb as (
select BU,FinalItemNumber,cb.FinalShortItemNumber,cb.Century,cb.FinancialYear,cb.FinancialMonth,cb.UOM,sum(cb.Quantity) as Quantity
 --from JDE_DB_Alan.SalesHistoryAWFHDMT a 
 from cb
 group by BU,FinalItemNumber,cb.FinalShortItemNumber,cb.Century,cb.FinancialYear,cb.FinancialMonth,cb.UOM
 --order by BU,a.ItemNumber,a.ShortItemNum,a.Century asc,a.FinancialYear asc,a.FinancialMonth desc
    ),

 ------ First to get rough selling group/family group/family info from R55ML345 Table ---------

 tbl as (
select x.BU,tb.FinalItemNumber
		,tb.FinalShortItemNumber		
     --   , case a.FinancialMonth 
		   --   when > 10  then a.FinancialMonth
			  --else right('00'+a.financialMonth,2)  end

		,tb.Century,tb.FinancialYear,tb.FinancialMonth
		,tb.Quantity,tb.Quantity * (-1) as SalesQty,x.Description,x.SellingGroup,x.FamilyGroup,x.Family,tb.UOM,x.StandardCost,x.WholeSalePrice
 from	--JDE_DB_Alan.SalesHistoryHDAWF a 
        tb
		left join JDE_DB_Alan.Master_R55ML345_Description_Hierarchy_SKU_Level x			--R55ML345 Table
	 --  on a.ItemNumber = b.ItemNumber
	   on tb.finalShortItemNumber = x.ShortItemNumber
--where a.ItemNumber in ('27.161.135') 
       ),

--select * from tbl	  
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
		staging.FinalItemNumber,staging.Description
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

    ),

--select * from z
--where staging.ItemNumber in ('27.161.135')
--where StandardCost > WholeSalePrice
--order by SalesVal desc
   
  ----- Need to consolidate Sales History if there are one ItemNum but mulitple ShortItemNum ?--- After this operation you will lost your descriiption since for  one  item you might have 2 different description, to get ItemNum level data, you NEED aggregate and remove description level,your data set will only have this info--> Hierarchy/ItemNum/Year/Month/Qty
 zz as (
	select z.RowLabel,z.SellingGroup,z.FamilyGroup,z.Family,z.FinalItemNumber,concat(z.CY,z.MM) as CYM,z.CY,z.Century,z.Year,z.Month,z.PPY,z.PPC,sum(SalesQty) as SalesQty_,sum(z.InventoryVal) as InventoryVal_,sum(z.SalesVal) as SalesVal_
	from z 
--where z.ItemNumber in ('8.51E+11') 
      -- and z.Year in ('15') and z.month in ('1')
		-- and (z.Year + z.Month like '%20151')
group by  z.RowLabel,z.SellingGroup,z.FamilyGroup,z.Family,z.FinalItemNumber,concat(z.CY,z.MM),z.CY,z.Century,z.Year,z.Month,z.PPY,z.PPC
  ),

  ---==== To get your description from ML345 to join back your data set but First need to fix the ItemNumber with leading zero for ML345  ---
 --l as ( select y.*,
 --       case 
	--       when y.ItemWithLeadingZero ='Y' then '0'+ y.ItemNumber
	--	    else  y.ItemNumber		    
	--		end as myItemNumber
 --        from JDE_DB_Alan.MasterMTLeadingZeroItemList y
      
	--  ),

 q as ( 
        select x.*,l.myItemNumber from JDE_DB_Alan.Master_R55ML345_Description_Hierarchy_SKU_Level x 
		left join l on x.ShortItemNumber = l.ShortItemNo 
		),
--select * from m
	  
ml as ( select q.BU,
       case 
	       when q.myItemNumber is null then q.ItemNumber
		    else  q.myItemNumber		    
			end as fItemNumber
        ,q.ShortItemNumber,q.description,q.SellingGroup,q.FamilyGroup,q.Family,q.Standardcost,q.WholeSalePrice					
		 from q ),

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
 select zz.RowLabel,zz.SellingGroup,zz.FamilyGroup,zz.Family,rtrim(ltrim(zz.FinalItemNumber)) as ItemNumber_,cte.Description,cte.standardcost,cte.wholesaleprice,zz.CYM,zz.CY,zz.Month,zz.PPY,zz.PPC,zz.SalesQty_
 from zz left join cte on zz.FinalItemNumber = cte.fItemNumber
 --  from zz inner join cte on zz.ItemNumber = cte.ItemNumber
   ),

-- select* from fl 
--where fl.ItemNumber_ in ('44.132.000')
--order by fl.SellingGroup,fl.FamilyGroup,fl.Family,fl.ItemNumber_,fl.CYM

myfl as (
		select fl.RowLabel,fl.SellingGroup,fl.FamilyGroup,fl.Family,fl.ItemNumber_,fl.Description,fl.CY,fl.Month,fl.PPY,fl.PPC,fl.SalesQty_,getdate() as ReportDate from fl
		where fl.ItemNumber_ in ('18.607.016') 
		)

select * from myfl


--delete from JDE_DB_Alan.SalesHistoryAWFHDMTuploadToFCPRO
insert into JDE_DB_Alan.SalesHistoryAWFHDMT  select * from myfl 
select * from JDE_DB_Alan.SalesHistoryAWFHDMTuploadToFCPRO a


insert into JDE_DB_Alan.SalesHistoryAWF select * from JDE_DB_Alan.SalesHistoryAWFHDMT


------------------------ To Get Your Price Conversion table -----------------------
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

exec JDE_DB_Alan.sp_GetMTquery
exec JDE_DB_Alan.sp_GetMTquery @ItemNumber = '26.740.060'

exec JDE_DB_Alan.sp_GetMTquery @ItemNumber = '26.740.060', @CenturyYearMonth =201505
exec JDE_DB_Alan.sp_GetMTquery @ShortItemNumber = '543515', @CenturyYearMonth =201505

select * from JDE_DB_Alan.SlsHistoryMT a  where a.ItemNumber in ('26.740.060')

exec [JDE_DB_Alan].sp_FCPRO_SlsHistory_upload
select * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload

---------------------------------- end of CTE ---------------------------------------

----- Store procedure ------------- 7/11/2017

-- check if sp exist ---
IF exists (select 1 FROM sys.procedures where object_id = OBJECT_ID(N'dbo.GetCustomers'))
BEGIN
    PRINT 'Stored Procedure Exists'
END

if exists (select * from sys.procedures where name = 'procedure_to_drop')

select * from sys.procedures a order by a.schema_id


