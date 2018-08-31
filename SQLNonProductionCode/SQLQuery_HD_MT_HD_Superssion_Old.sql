-----------------------------------------------------------------------------------------------------------------------------------

use JDE_DB_Alan
go

---------------------- Superssion for MT Items 19/10/17---------------------------------
   --- Raw data should have Stock type column and you need to swap ItemNumber and ShortItemNum position to load data ---
   --- the format of MT file before consolidated with HD Raw Data should kept in same Format b4 loaded in DB for further Manupilations ie X1(-1), Get Hierarchy long description, 
select * from JDE_DB_Alan.HistoryMTB4Superssion a
select * from JDE_DB_Alan.MasterMTItemList a where a.CurrentItemNumberMT in ('28.164.000')
select * from JDE_DB_Alan.MasterMTItemList a where a.CurrentItemNumberMT in ('26.350.831')


-----------------------------  MT History     ------------------------------------------------------

---- First fix issue for Item with leading zero --------
 with l as ( select y.*,
        case 
	       when y.ItemWithLeadingZero ='Y' then '0'+ y.ItemNumber
		    else  y.ItemNumber		    
			end as myItemNumber
         from JDE_DB_Alan.MasterMTLeadingZeroItemList y
      
	  ),

--- get stocking type ---
 t as (
          select a.*,x.StockingType 
		  from JDE_DB_Alan.SalesHistoryMT a left join JDE_DB_Alan.Master_R55ML345_Temp x
			   on a.ShortItemNum = x.ShortItemNumber 
		  ),

m as ( 
        select t.*,l.myItemNumber from t left join l on t.ShortItemNum = l.ShortItemNo 
		),

tb as ( select m.bu,m.ShortItemNum,
       case 
	       when m.myItemNumber is null then m.ItemNumber
		    else  m.myItemNumber		    
			end as fItemNumber
        ,
		m.Century,m.FinancialYear,m.FinancialMonth,m.DocumentType,m.Quantity,m.UOM,m.StockingType					
		 from m
     ),
--select * from tb

  tbl as (
	select tb.*,b.NewItemNumberHD,b.NewShortItemNumberHD
	from tb 
	     left join JDE_DB_Alan.MasterMTSuperssionItemList b on tb.fItemNumber = b.CurrentItemNumberMT   
    where tb.StockingType in ('P','S') 
	   --   and a.ItemNumber in ('28.380.108')
	),

	--- Superssion for Bricos Item ---
  mt as (select case 
	       when tbl.BU ='MT' then 'HD'
		    else  'HD'		    
			end as BU
		,case  
		  when tbl.NewShortItemNumberHD is null then tbl.ShortItemNum
		    else tbl.NewShortItemNumberHD 
			end as FinalShortItemNumber
	   , case 
	       when tbl.NewItemNumberHD is null then tbl.fItemNumber
		    else tbl.NewItemNumberHD 
			end as FinalItemNumber
		,tbl.Century,tbl.FinancialYear,tbl.FinancialMonth,tbl.DocumentType,tbl.Quantity,tbl.UOM
		
 from tbl )

 select * from mt
-- where tbl.fItemNumber in ('26.350.831','28.164.000')

		--- load into HDAWF Table ---
INSERT INTO JDE_DB_Alan.SalesHistoryHDAWF
SELECT * FROM mt

select * from JDE_DB_Alan.SalesHistoryHDAWF
delete from JDE_DB_Alan.SalesHistoryHDAWF


--- Use Select into does not work=============================================================

-- please note SELECT INTO is used to create a table based on the data you have.
--- As you have already created the table, you want to use INSERT INTO. E.g.
INSERT INTO table2 (co1, col2, col3)
SELECT col1, col2, col3
FROM table1
----------------------------------------------------

select * from JDE_DB_Alan.JDE_DB_Alan.Master_R55ML345_Description_Hierarchy_SKU_Level
SELECT * INTO JDE_DB_Alan.Master_R55ML345_Description_Hierarchy_SKU_Level_T 
from JDE_DB_Alan.Master_R55ML345_Description_Hierarchy_SKU_Level

SELECT * INTO CustomersGermany FROM Customers WHERE Country = 'Germany';

SELECT Customers.CustomerName, Orders.OrderID
INTO CustomersOrderBackup2017
FROM Customers
LEFT JOIN Orders ON Customers.CustomerID = Orders.CustomerID  WHERE Country = 'Germany';


---===  Tip: SELECT INTO can also be used to create a new, empty table using the schema of another. Just add a WHERE clause that causes the query to return no data:

SELECT * INTO newtable
FROM oldtable
WHERE 1 = 0;
--- End of  Use Select into  ==============================================================

---------------------------  HD History  -----------------------------------------------------------------

----  fix issue for Item with leading zero --------
 with l as ( select y.*,
        case 
	       when y.ItemWithLeadingZero ='Y' then '0'+ y.ItemNumber
		    else  y.ItemNumber		    
			end as myItemNumber
         from JDE_DB_Alan.MasterMTLeadingZeroItemList y
      
	  ),

 m as ( 
        select t.*,l.myItemNumber from JDE_DB_Alan.SalesHistoryHD t left join l on t.ShortItemNum = l.ShortItemNo 
		),
	  
hd as ( select m.bu,m.ShortItemNum,
       case 
	       when m.myItemNumber is null then m.ItemNumber
		    else  m.myItemNumber		    
			end as fItemNumber
        ,
		m.Century,m.FinancialYear,m.FinancialMonth,m.DocumentType,m.Quantity,m.UOM					
		 from m )

--select * from hd
INSERT INTO JDE_DB_Alan.SalesHistoryHDAWF
SELECT * FROM hd
  

select * from JDE_DB_Alan.SalesHistoryHDAWF
delete from JDE_DB_Alan.SalesHistoryHDAWF


-------------------------- ML345  ------------------------------------------------------------

----  fix issue for Item with leading zero --------
 with l as ( select y.*,
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
        ,
		m.ShortItemNumber,m.description,m.SellingGroup,m.FamilyGroup,m.Family,m.Standardcost,m.WholeSalePrice					
		 from m )

select * from ml



INSERT INTO 
SELECT * FROM 
  

select * from JDE_DB_Alan.Master_R55ML345_Description_Hierarchy_SKU_Level


--delete from JDE_DB_Alan.Master_R55ML345_Description_Hierarchy_SKU_Level