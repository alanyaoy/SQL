//
 ---------------------------------  SQL Query Master -------------------------------------

 ---=================How to Skip SQL Query --- Method 3   30/7/2018= ================================================================= 
 --https://stackoverflow.com/questions/659188/sql-server-stop-or-break-execution-of-a-sql-script?noredirect=1&lq=1
 
print 'hi'
go

print 'Fatal error, script will not continue!'

set noexec on
print 'ho'
go

--To Reconnect Use --- 2/11/2017
--> CTRL-F5 
--use DemandPlanning
--go

use JDE_DB_Alan
go

  ---=================How to Skip SQL Query --- Method 2  30/7/2018= ========================

  --- Hot KEy

  -- Fn + end , Fn + home to begining / end of line
  -- Ctrl + KU , to select whole line, then F5 to execute
  -- Alt + break to stop run
 -- CTRL+HOME - Top of the current query window
 -- CTRL+END - End of the query window

 -- Shift + Fn+home to select whole line if you are @ end of line
  -- Shift + Fn+ end to select whole line if you are @ begining of line

--select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('42.210.031')
--select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('18.013.089')

--GOTO SKIP_3;

--select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('18.010.035')

--SKIP_3:
--select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('28.617.002')


--GOTO END_EXIT; 

--select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('82.391.912')
--select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('24.7250.4459')

---END_EXIT:
--======================================================================================


---========================================================================================---

----- List Table name / data type / primary key etc Meta data --------  20/1/2021

SELECT COUNT(*) 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE 
   TABLE_NAME = 'table_name'


SELECT COUNT(*) 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE 
   TABLE_NAME = 'Master_V4102A'

   --- To get all the metadata you require except for the Pk information ---
 select COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, 
       NUMERIC_PRECISION, DATETIME_PRECISION, 
       IS_NULLABLE 
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME='Master_V4102A'


SELECT 
    c.name 'Column Name',
    t.Name 'Data type',
    c.max_length 'Max Length',
    c.precision ,
    c.scale ,
    c.is_nullable,
    ISNULL(i.is_primary_key, 0) 'Primary Key'
FROM    
    sys.columns c
INNER JOIN 
    sys.types t ON c.user_type_id = t.user_type_id
LEFT OUTER JOIN 
    sys.index_columns ic ON ic.object_id = c.object_id AND ic.column_id = c.column_id
LEFT OUTER JOIN 
    sys.indexes i ON ic.object_id = i.object_id AND ic.index_id = i.index_id
WHERE
    c.object_id = OBJECT_ID('JDE_DB_Alan.Master_V4102A')

	
--- Need to design a code to track inventory month by month & for Inventory projection -- by category - each month has view of next 12 months together with PO / SO / SOH on high level ! Include AWF stock as well ! --- 3/9/2020
--- this will also help to predict if you have any inventory problems as well ---- 

select m.ItemNumber,m.PlannerNumber,m.Owner_ from JDE_DB_Alan.vw_Mast m
where m.ItemNumber in ('18.010.035','18.010.036','18.013.089','18.615.007','24.5353.0204','24.7100.0199','24.7110.0155','24.7111.0155A','24.7120.0155','24.7121.0155','24.7122.0155','24.7123.0155A','24.7124.0155','24.7127.0155','24.7129.0155','24.7133.0155A','24.7200.0001','24.7220.0199','24.7333.0199','32.379.200','32.380.002','32.455.155','32.501.000','43.212.001','43.212.003')

select sum(m.StockValue) from JDE_DB_Alan.vw_Mast m

select max(h.SlsMth_latest) as LatestMonth from JDE_DB_Alan.vw_Sls_History_HD h

select * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload s where s.ItemNumber in ('34.216.000')
select * from JDE_DB_Alan.px_AWFHDMT_FCPro_upload s where s.ItemNumber in ('34.216.000')

select * from JDE_DB_Alan.vw_Mast m where m.ItemNumber in ('850520000202.002')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('850520000202.002')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('850520000202')

select * from JDE_DB_Alan.FCPRO_SafetyStock s where s.ItemNumber in ('34.226.000')



select * from JDE_DB_Alan.FCPRO_SafetyStock s where s.ItemNumber in ('82.058.928')
select * from JDE_DB_Alan.vw_FC f where f.ItemNumber in ('82.058.928')
select * from JDE_DB_Alan.vw_Mast m where m.ItemNumber in ('27.163.785','27.166.785','27.276.502')
select * from JDE_DB_Alan.MasterFamily f where f.Code like ('14%')
select * from [hd-vm-bi-sql01.hd.local].HDDW_PRD.star.d_product p where p.item_code in ('44.011.007')      --- works ! 3/6/2020  -- need to created new linked server : hd-vm-bi-sql01.hd.local
select * from [hd-vm-bi-sql01].HDDW_PRD.star.d_product p where p.item_code in ('44.011.007')              --- not working, if your linked server is : hd-vm-bi-sql01   3/6/2020

select * from JDE_DB_Alan.SlsHistoryHD h where h.ItemNumber in ('42.210.031')

select max(h.SlsMth_latest)+1  as LatestMth from JDE_DB_Alan.vw_Sls_History_HD h where h.ItemNumber_ in ('42.210.031')
select convert(int,convert(varchar(6),getdate(),112))+11 -- yield 201712 - ISO



---============================*** HD DW data warehouse query *** =================================---
---------------------------------- HD Data Warehouse Query ------------------------------------------- works !
---------- remember you have admin right in 'JDE_DB_Alan ' db, so you have control and can link to '[hd-vm-bi-sql01].HDDW_PRD' , however you cannot do reverse because you do not control data warehouse and you do not have control , unless you have admin right to set access to hdd dw. ----


select * from HDDW_PRD.star.d_region		-- does not work , need full qualification 

select * from [hd-vm-bi-sql01].HDDW_PRD.star.d_region  --- works !

drop table dbo.test_hddw_prd

-- be careful to use this query as you are writing data to db ----
select * into test_hddw_prd from [hd-vm-bi-sql01].HDDW_PRD.star.d_region		--- table will be created under 'dbo' schema

drop table JDE_DB_Alan.test_hddw_prd_
select * into JDE_DB_Alan.test_hddw_prd_ from [hd-vm-bi-sql01].HDDW_PRD.star.d_region     --- --- table will be created under 'JDE_DB_Alan' schema


-------------------------------------------------------------------------------------------------------------------------------------------------------------------
 --- works ! Yeah ---- by sending query to linked Server ! ----
 --- Sun Solution WA --- dummy order SO ( 5623307 ) and WO ( 4709432 ) cancelled but cannot see in DW table --- see email sent to Guru 5/3/2020
;with so as

  (  select * from [hd-vm-bi-sql01].HDDW_PRD.star.f_so_detail_history h        
	union all		
	 select * from [hd-vm-bi-sql01].HDDW_PRD.star.f_so_detail_current c where not ( c.last_line_status_code = '980' and c.next_line_status_code = '999')		--- 13022  -- use this one !!		        
		)
  --select top 3 * from  so   
   select so.order_number as So_num,so.work_order_number as So_wo_num,pr.wo_number as part_wo_num,so.item_code,pr.item_code as part_code,pr.parts_description2,pr.quantity as part_SoldQty,pr.uom as part_uom,c.contact_name as customer,so.order_date           
   from so left join [hd-vm-bi-sql01].HDDW_PRD.star.f_wo_parts_list pr on so.work_order_number = pr.wo_number
           left join [hd-vm-bi-sql01].HDDW_PRD.star.d_product p on so.d_product_key = p.d_product_key 
		   left join [hd-vm-bi-sql01].HDDW_PRD.star.d_customer c on so.d_customer_key = c.d_customer_key
	where  
		so.work_order_number = '04685890'     -- works !
		-- so.order_number in ('5623307')          -- do not yield details --- order has been cancelled though in JDE



--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

---------*********************************************************************************************************************---------
---=========== Use linked server hd-vm-bi-sql01.hd.local to created a query to query data in HDDDW ! 3/6/2020 ==========------



---------------  Get WO parts number from Work orders --------------------------------------        17/2/2020 ----------------------
 -------------  Get all Sales history On components level across HD and AWF channel ---- by exploring Comp level details from AWF Sales order ( breaks/exploded down to parts level from Finished Blinds to component ) --- 19/3/2020

select count(*) from [hd-vm-bi-sql01.hd.local].HDDW_PRD.star.f_so_detail_history h   --- 8,664,477 rows 104 columns - very large table 
select count(*) from [hd-vm-bi-sql01.hd.local].HDDW_PRD.star.f_so_detail_current c   --- 16,721 row 104 columnes - small table , should be identical with _history table but 1 coloumn has different name --> column 78/79 ' BRACKET_COLOUR ' and  'BRACKET_TYPE_SIZE' are flipped


select max(invoice_date) from [hd-vm-bi-sql01.hd.local].HDDW_PRD.star.f_so_detail_history h
select min(invoice_date) from [hd-vm-bi-sql01.hd.local].HDDW_PRD.star.f_so_detail_history h
select * from [hd-vm-bi-sql01.hd.local].HDDW_PRD.star.f_so_detail_history h where h.invoice_date in ('1999-08-04 00:00:00.000')


select count(*) from [hd-vm-bi-sql01.hd.local].HDDW_PRD.star.f_wo_parts_list      --- 17,656,155 rows , 96 columns --- huge table --- 2017 to 2019 ( total 3 years records of WO details )
select * from [hd-vm-bi-sql01.hd.local].HDDW_PRD.star.f_wo_parts_list				--- 17 million records, appox 1 min = 1 million records ( nearlly 100 columns )
select top 3 *  from [hd-vm-bi-sql01.hd.local].HDDW_PRD.star.f_wo_parts_list	


select l.wo_number from [hd-vm-bi-sql01.hd.local].HDDW_PRD.star.f_wo_parts_list l    --- search 1 column only, it takes 2 mins

--- Note:
--- F3111 is JDE table on which work order fetched from...
--- F4211  is Jde table which stores 'Open sales' order - Sales order which has not been materilized yet ( anything could happen ) - 980/990 cancelled order need to be excluded;
---  F42119 is Jde table which stores 'CLosed sale' order - invoiced history - 620/980 invoiced.


--- combined sales (history + open sales order ) ---  17/2/2020
--- Not Or And Combined ... http://www.peachpit.com/articles/article.aspx?p=1276352&seqNum=6


;with so as

  (  	select * from [hd-vm-bi-sql01.hd.local].HDDW_PRD.star.f_so_detail_history
		union all
		 --select * from HDDW_PRD.star.f_so_detail_current c where c.last_line_status_code + c.next_line_status_code <> '980999' and c.item_code in ('FAMT')  --- 12196
		-- select * from HDDW_PRD.star.f_so_detail_current c where c.last_line_status_code <> '980' and c.next_line_status_code <> '999' and c.item_code in ('FAMT')  --- 11810
		 select * from [hd-vm-bi-sql01.hd.local].HDDW_PRD.star.f_so_detail_current c where not ( c.last_line_status_code = '980' and c.next_line_status_code = '999')		--- 13022  -- use this one !!
		-- select * from HDDW_PRD.star.f_so_detail_current c where (not c.last_line_status_code = '980')  or ( not c.next_line_status_code = '999')  --- 13022
		-- select * from HDDW_PRD.star.f_so_detail_current c where ( c.last_line_status_code <> '980')  or (  c.next_line_status_code <> '999')  --- 13022
		        
		)
  --select * from  so

        ----- Get your part list --- Filter out duplicated records if WO is updated different times --- 11/6/2020
   ,_pr as ( 
			select  -- pr.*
			       pr.item_code,pr.date_updated,pr.so_number,pr.wo_number,pr.d_product_key,pr.parts_description2,pr.quantity,pr.uom
			       --,row_number() over(partition by pr.item_code order by date_updated ) rn  
				   --,sum(unique_id)over(partition by pr.item_code,pr.date_updated order by pr.updated_time) rn 
				  -- ,max(unique_id)over(partition by pr.item_code,date_updated order by pr.item_code) rn 
				  -- ,max(date_updated) as latest
				  -- max(unique_id)
				  --,max(date_updated)
				 -- ,max(date_updated)over(partition by pr.item_code order by pr.item_code) max_ 
				 ,max(date_updated)over(partition by pr.wo_number,pr.item_code order by pr.item_code) max_		-- 27/7/2020 major update you need to partition first by wo-number ( which is unique ) otherwise yield dt will be wrong
			FROM [hd-vm-bi-sql01.hd.local].HDDW_PRD.star.f_wo_parts_list pr 
			  --where pr.wo_number in ('4801649')            
			--where pr.so_numbwo_number in ('4801649')  er in ('5642227') 
			       --and pr.wo_number in ('4769683') and pr.item_code in ('24.7100.0199')
			--group by pr.item_code,pr.date_updated
			)
   ,pr_ as ( 
				select * 
				from _pr 
				where _pr.date_updated = _pr.max_)
    --select * from pr_  where pr_.wo_number in ('4801649')			-- OK no speed issue

   ,part_list as 
   
	   (select so.order_number as So_num,so.work_order_number as So_wo_num,pr.wo_number as Part_wo_num
			 ,so.d_product_key as Parent_pd_key,so.item_code as Parent,pr.d_product_key Child_pd_key,pr.item_code as Child,pr.parts_description2,so.primary_quantity as ParentSoldQty,pr.quantity as ChildSoldQty,pr.uom Child_uom,c.contact_name as customer,so.order_date
		 from 
		       so left join  pr_ as pr on so.work_order_number = pr.wo_number
			  -- so left join [hd-vm-bi-sql01.hd.local].HDDW_PRD.star.f_wo_parts_list pr on so.work_order_number = pr.wo_number
			   left join  [hd-vm-bi-sql01.hd.local].HDDW_PRD.star.d_product pd on so.d_product_key = pd.d_product_key 
			   left join [hd-vm-bi-sql01.hd.local].HDDW_PRD.star.d_customer c on so.d_customer_key = c.d_customer_key
		  
		  where --so.item_code in ('FAMT')
		  --  and so.jde_business_unit = 'AWF'    
			--and so.work_order_number = '04685890'   
			--and pr.item_code in ('42.421.855','52.018.000','44.011.007')
			-- so.order_number in ('5641025')						--  Fabrique store Project - DUMMY ORDER FOR FABRIQUE FOR LARGE COMMERCIAL ORDER 5641025 -- 1/6/2020
		    --so.order_number in ('5642227')							--  NELLIE MELBA RETIREMENT Vic            11/6/2020
		      so.order_number in ('5652689')							-- GEELONG APARTMENTS Project / WO - 4801649				24/7/2020
		  --order by so.order_number      
		  )
	  --select * from part_list

	  select p.*,m.PlannerNumber from  part_list p left join JDE_DB_Alan.vw_Mast m 
				-- on p.Child COLLATE Latin1_General_CS_AS = m.ItemNumber COLLATE Latin1_General_CS_AS			--- works 3/6/2020    'The root cause is that the sql server database you took the schema from has a collation that differs from your local installation. If you don't want to worry about collation re install SQL Server locally using the same collation as the SQL Server 2008 database.
				 on p.Child	COLLATE DATABASE_DEFAULT = m.ItemNumber COLLATE DATABASE_DEFAULT			 --- works 3/6/2020			'This is extremely useful. I'm using a local database and querying against a linked server and they have two different collations. Obviously I can't change the collation on the linked server, and I didn't want to change mine locally, so this is absolutely the best answer. 


---===============================================================================================================================------

  ---*************** Stress Test using linked Server if you use Partition Function for Parts list 11/6/2020 ************************************
;with so as

  (  	select * from [hd-vm-bi-sql01.hd.local].HDDW_PRD.star.f_so_detail_history
		union all
		 --select * from HDDW_PRD.star.f_so_detail_current c where c.last_line_status_code + c.next_line_status_code <> '980999' and c.item_code in ('FAMT')  --- 12196
		-- select * from HDDW_PRD.star.f_so_detail_current c where c.last_line_status_code <> '980' and c.next_line_status_code <> '999' and c.item_code in ('FAMT')  --- 11810
		 select * from [hd-vm-bi-sql01.hd.local].HDDW_PRD.star.f_so_detail_current c where not ( c.last_line_status_code = '980' and c.next_line_status_code = '999')		--- 13022  -- use this one !!
		-- select * from HDDW_PRD.star.f_so_detail_current c where (not c.last_line_status_code = '980')  or ( not c.next_line_status_code = '999')  --- 13022
		-- select * from HDDW_PRD.star.f_so_detail_current c where ( c.last_line_status_code <> '980')  or (  c.next_line_status_code <> '999')  --- 13022
		        
		)
  --select * from  so

   ----- Get your part list --- Filter out duplicated records if WO is updated different times --- 11/6/2020
   ,_pr as ( 
			select  -- pr.*
			        pr.item_code,pr.date_updated,pr.so_number,pr.wo_number,pr.d_product_key,pr.parts_description2,pr.quantity,pr.uom
			       --,row_number() over(partition by pr.item_code order by date_updated ) rn  
				   --,sum(unique_id)over(partition by pr.item_code,pr.date_updated order by pr.updated_time) rn 
				  -- ,max(unique_id)over(partition by pr.item_code,date_updated order by pr.item_code) rn 
				  -- ,max(date_updated) as latest
				  -- max(unique_id)
				  --,max(date_updated)
				  ,max(date_updated)over(partition by pr.item_code order by pr.item_code) max_ 
			FROM [hd-vm-bi-sql01.hd.local].HDDW_PRD.star.f_wo_parts_list pr 
			--where pr.so_number in ('5642227') and pr.wo_number in ('4769683') and pr.item_code in ('24.7100.0199')
			--group by pr.item_code,pr.date_updated
			)
   , pr as ( 
				select * 
				from _pr 
				where _pr.date_updated = _pr.max_)
     -- select * from pr
   
   select so.order_number as So_num,so.work_order_number as So_wo_num,pr.wo_number as Part_wo_num
		 ,so.d_product_key as Parent_pd_key,so.item_code as Parent,pr.d_product_key Child_pd_key,pr.item_code as Child,pr.parts_description2,so.primary_quantity as ParentSoldQty,pr.quantity as ChildSoldQty,pr.uom Child_uom,c.contact_name as customer,so.order_date
   from so left join pr on so.work_order_number = pr.wo_number
           left join  [hd-vm-bi-sql01.hd.local].HDDW_PRD.star.d_product pd on so.d_product_key = pd.d_product_key 
		   left join [hd-vm-bi-sql01.hd.local].HDDW_PRD.star.d_customer c on so.d_customer_key = c.d_customer_key
   where --so.item_code in ('FAMT')
      --  and so.jde_business_unit = 'AWF'    
		--and so.work_order_number = '04685890'   
		--and pr.item_code in ('42.421.855','52.018.000','44.011.007')
		  --so.order_number in ('5623307')					   ---  Sun Solution WA Dummy order
		 --  so.order_number in ('5626957')				        -- Sun Solution WA
		  --  so.order_number in ('5641025')						--  DUMMY ORDER FOR FABRIQUE FOR LARGE COMMERCIAL ORDER 5641025 -- 1/6/2020
           so.order_number in ('5642227')							--  NELLIE MELBA RETIREMENT Vic            11/6/2020
  order by so.order_number 

  ---*********************************************************************




--- from one table --
CREATE TABLE suppliers
  AS (SELECT id, address, city, state, zip
      FROM companies
      WHERE id > 1000);

--- from 2 tables ---
CREATE TABLE suppliers
  AS (SELECT companies.id, companies.address, categories.cat_type
      FROM companies, categories
      WHERE companies.id = categories.id
      AND companies.id > 1000);


 --- This would create a new table called suppliers that included all columns from the companies table, but no data from the companies table --- retain table structure but no data is copied over
CREATE TABLE suppliers
  AS (SELECT *
      FROM companies WHERE 1=2);


--------- Create table and insert data multiple rows-----------

CREATE TABLE recipes (
  recipe_id INT NOT NULL,
  recipe_name VARCHAR(30) NOT NULL,
  PRIMARY KEY (recipe_id),
  UNIQUE (recipe_name)
);

INSERT INTO recipes (recipe_id, recipe_name) 
VALUES 
    (1,"Tacos"),
    (2,"Tomato Soup"),
    (3,"Grilled Cheese");

---------- create temp table # ( if need > 1000 records )-----------------

Local Temporary Tables (#temp)  
Global Temporary Tables (##temp)  
  
CREATE TABLE #StudentTemp  
(  
    StudentID int,  
    Name varchar(50),   
    Address varchar(150)  
)  
GO  
INSERT INTO #StudentTemp VALUES ( 1, 'Dipendra','Pune');  
GO  
SELECT * FROM #StudentTemp  

------------Create table variable @ -----------------------------------

 DECLARE @TStudent TABLE  
 (  
    RollNo INT IDENTITY(1,1),  
    StudentID INT,  
    Name INT  
 )   
 --Insert data to Table variable @TStudent   
 INSERT INTO @TStudent(StudentID,Name)  
 SELECT DISTINCT StudentID, Name FROM StudentMaster ORDER BY StudentID ASC 

 ----------------------------------------------


drop table da.test
create table da.test (mycol char(20) ,constraint ck_illegal_char check(charindex(',',mycol)=0 ))					  -- do not allow comma	
create table da.test (mycol char(20) ,constraint ck_illegal_char check (len(mycol) - len(replace(mycol,',',''))>0))   -- allow comma

insert into da.test select 'test'
union all select 'test,'
union all select 'tes,t'
union all select ',test'
union all select 'ab'

select * from JDE_DB_Alan.Master_ML345

select * from da.test_
select charindex(',','test')
select len('test') - len(replace('test',',',''))

select * from da.test_


sp_helpdb JDE_DB_Alan
sp_spaceused

SELECT DB_NAME() AS DbName, 
name AS FileName, 
size/128.0 AS CurrentSizeMB, 
size/128.0 - CAST(FILEPROPERTY(name, 'SpaceUsed') AS INT)/128.0 AS FreeSpaceMB 
FROM sys.database_files; 
-------------------------------17/1/2020-------------------

SELECT compatibility_level
FROM sys.databases
WHERE name = 'jde_db_alan';


alter database [jde_db_alan]
set compatibility_level = 130
go

SELECT name, compatibility_level
FROM sys.databases;

-----------------------------------------------------

CREATE TABLE JDE_DB_Alan.Products  
   (ProductID int PRIMARY KEY NOT NULL,  
    ProductName varchar(25) NOT NULL,  
    Price money NULL,  
    ProductDescription text NULL)  
--GO

select * from dbo.Products 


create schema JDE_DB_Alan

CREATE TABLE JDE_DB_Alan.Products  
   (ProductID int PRIMARY KEY NOT NULL,  
    ProductName varchar(25) NOT NULL,  
    Price money NULL,  
    ProductDescription text NULL)  
--GO


select * from JDE_DB_Alan.Products


SELECT * FROM sys.schemas;

drop table JDE_DB_Alan.SalesHistory 

CREATE TABLE JDE_DB_Alan.SalesHistory  
   ( Comb varchar(100) not null primary key,		-- 2nd ItemNum + Yr + Month
     SellingGroup	varchar(100), 
     FamilyGroup	varchar(100), 
	 Family			varchar(100), 	
	 ItemNumber		varchar(50) not null,  			--2nd ItemNumber 	
	 ItemDesciption varchar(100), 
	 CalendarYear	int NOT NULL, 	
	 CalendarMonth	int NOT NULL, 
	 Quantity		decimal, 
	 StandardCost	decimal, 
	 WholeSalePrice	decimal	
	    
   --ProductID int PRIMARY KEY NOT NULL,  
   -- ProductName varchar(25) NOT NULL,  
   -- Price money NULL,  
   -- ProductDescription text NULL
   )  
--GO	

GRANT CREATE ANY DATABASE to [HD\yaoa]
--GO


EXEC sp_configure 'show advanced options', 1
RECONFIGURE
--GO
EXEC sp_configure 'ad hoc distributed queries', 1
RECONFIGURE
--GO


select * from JDE_DB_Alan.SalesHistory

SELECT * INTO JDE_DB_Alan.Salesh
History FROM OPENDATASOURCE('Microsoft.Jet.OLEDB.4.0',
'Data Source=C:\Users\yaoa\Alan_HD\Alan_Work\Tranning\Report_HD_Sales_History4_Alan.xlsx;Extended Properties=Excel 8.0')...[Data$]


BULK INSERT JDE_DB_Alan.SalesHistory
    --  from 'C:\Alan_GWA_C\Work\ImportData.csv'
    -- from 'E:\ImportDataa.txt'
   -- from 'E:\T-SQL\Alans_Folder\DSX_FC_Error_Data_Temp_Old_Final.txt'
   -- from 'E:\T-SQL\Alans_Folder\FcUpload.csv'
   -- from 'E:\T-SQL\Alans_Folder\FcErrorMth_Offset_Master.csv'
      from 'C:\Users\yaoa\Alan_HD\Alan_Work\Tranning\Report_HD_Sales_History4_Alan.csv'
   with  (
        --   Fieldteminator='',
        --   Rowteminator ='\n',
            
        FIELDTERMINATOR =',',
        ROWTERMINATOR = '\n',
        FIRSTROW =2     			
			) 


select * from JDE_DB_Alan.saleshistory
select count(*) from JDE_DB_Alan.saleshistory a

alter table JDE_DB_Alan.saleshistory
add UniqueItemNum varchar(100)


-- drop column or alter column data type
alter table JDE_DB_Alan.saleshistory
drop column UniqueItemNum
--alter column UniqueItemNum int




-----------------------------------------------------------------------------------------------------------

--26/09/2017

select * from JDE_DB_Alan.MasterFamilyGroup
select * from JDE_DB_Alan.SalesHistoryAWFHDMTupload

--drop table JDE_DB_Alan.SalesHistoryHDAWF
--drop table JDE_DB_Alan.SalesHistoryHD
--drop table JDE_DB_Alan.SalesHistoryAWF
--drop table JDE_DB_Alan.SalesHistoryMT
--drop table JDE_DB_Alan.HistoryMTB4Superssion
--drop table JDE_DB_Alan.SalesHistoryAWFHDMTupload

--drop table JDE_DB_Alan.Master_ML345_T
--drop table JDE_DB_Alan.Master_R55ML345_TempSKU_Level
--drop table JDE_DB_Alan.MasterSellingGroup
--drop table JDE_DB_Alan.MasterFamilyGroup
--drop table JDE_DB_Alan.MasterFamily
--drop table JDE_DB_Alan.MasterPrice2
--drop table JDE_DB_Alan.MasterMTItemList

--truncate table JDE_DB_Alan.MasterPrice
--truncate table JDE_DB_Alan.Master_ML345
--truncate table JDE_DB_Alan.MasterFamilyGroup
--delete from JDE_DB_Alan.MasterFamilyGroup
--delete from JDE_DB_Alan.MasterFamily
--delete from JDE_DB_Alan.MasterPrice
--delete from JDE_DB_Alan.Master_ML345_T
--delete from JDE_DB_Alan.Master_R55ML345_Temp
--delete from JDE_DB_Alan.SalesHistoryHDAWF

--delete from FinalFcstShot where DownLoadDate = '2014-08-01' and date > '2014-08-01'
--                                                                and DataType in ('Adjusted History','Revenue History')


--=============================== Table --==============================================================

----------------- Master Data Table Below -----------------

drop table JDE_DB_Alan.MasterSellingGroup
CREATE TABLE JDE_DB_Alan.MasterSellingGroup  
   ( 
     Code			varchar(100) NOT NULL primary key, 
     Description	varchar(100), 
	 LongDescription varchar(100)    
  )  
--GO

drop table JDE_DB_Alan.MasterFamilyGroup
CREATE TABLE JDE_DB_Alan.MasterFamilyGroup
   ( 
     Code			varchar(100) NOT NULL primary key, 
     Description	varchar(100), 
	 LongDescription varchar(100)    
  )  
--GO	

drop table JDE_DB_Alan.MasterFamily
CREATE TABLE JDE_DB_Alan.MasterFamily
   ( 
     Code				varchar(100) NOT NULL primary key
     ,Description		varchar(100) 
	 ,Description2		varchar(100)
	 ,LongDescription	varchar(100)
	 ,ReportDate		datetime default(getdate())										   -- added 23/5/2018						 	    
  )  
 ALTER TABLE JDE_DB_Alan.MasterFamily ADD ReportDate datetime default(getdate());	 -- added 23/5/2018	

--GO		

--CREATE TABLE JDE_DB_Alan.Master_Description_Hierarchy_SKU_Level
select * from JDE_DB_Alan.Master_R55ML345

CREATE TABLE JDE_DB_Alan.Master_ML345_Jde
   ( 
    BusinessUnit		 varchar(100),
	X					varchar(100),
	ItemNumber			  varchar(100),       
	Description			   varchar(100),       
	ShortItem			 varchar(100),       
	Blank				 varchar(100),   
	StockingType		  varchar(100),   
	GLCat				 varchar(100),   
	LineType			    varchar(100),   
	--PackQty				   varchar(100),   
	PackQty				   decimal(18,6),  
	xx					   varchar(100),
	MfgUnit				      varchar(100),
	PrimUM				     varchar(100),
	PurchUM				      varchar(100),
	PricingUM			        varchar(100),
	ProdUM				     varchar(100),
	CompUM				     varchar(100),
	Colour				     varchar(100),
	PlannerNumber		     varchar(100),       
	PrimarySupplier		       varchar(100),       
	OriginCountry		     varchar(100),       
	PriceList			        varchar(100),
	MaxDisc				      varchar(100),
	ManFC				    varchar(100),
	PriceGrp			       varchar(100),
	MktGrp				     varchar(100),
	FamilyGrp			        varchar(100),
	Family				     varchar(100),
	SellGrp				      varchar(100),
	LocImp				     varchar(100),
	PlnnrCde			       varchar(100),
	PlanFmly			       varchar(100),
	DRP					  varchar(100),
	InvCat				     varchar(100),
	ReportGrp			        varchar(100),
	NonStk				     varchar(100),
	CurCod				     varchar(100),
	ForeignPrice		    decimal(18,2),
	AUDPrice			    decimal(18,2),
	ListPrice			    decimal(18,2),
	UOM					  varchar(100),
	ConvUOM				   varchar(100),
	ConversionFactor	   decimal(18,3),
	RelUM				    varchar(100),
	OrderMultiples		     decimal(18,2),        
	LeadtimeLevel		    decimal(18,2),        
	DutyC				    varchar(100),
	DutyR				    decimal(18,2),
	DistC				    varchar(100),
	DistR				    decimal(18,2),
	FreightC			     varchar(100),
	FreightR			     decimal(18,2),
	WfageC				     varchar(100),
	WfageR				     decimal(18,2),
	PurchC				     varchar(100),
	PurchR				     decimal(18,2),
	UnmappedCostType	    varchar(100),
	IsCd				   varchar(100),
	ToolC				    varchar(100),
	ToolR				    decimal(18,2),
	ToolDepC			     varchar(100),
	ToolDepR			     decimal(18,2),
	ReallC				     varchar(100),
	ReallR				     decimal(18,2),
	CoreC				    varchar(100),
	CoreR				    decimal(18,2),
	CommC				    varchar(100),
	CommR				    decimal(18,2),
	MargC				    varchar(100),
	MargR				    decimal(18,2),
	StdCost				   decimal(18,2),   
	Location			    varchar(100),   
	QtyOnHand			     decimal(18,2),   
	UOM1				   varchar(100),
	StockValue			   decimal(18,2),
	OBSST				    varchar(100),
	BOMRIG				     varchar(100),
	STKDIS				     varchar(100),
	ROP					  decimal(18,2),
	SS					 decimal(18,2),
	MOQ					  decimal(18,2),
	OP					 decimal(18,2),
	EndDate				    int,
	ECONumber			   varchar(100),
	CycleCount			  varchar(100)

  )  
--GO	



drop table JDE_DB_Alan.Master_ML345
drop index PK_ShortItem_master on JDE_DB_Alan.Master_ML345

select * from JDE_DB_Alan.Master_ML345

----- This is the one ------
CREATE TABLE JDE_DB_Alan.Master_ML345				-- you probably need to allow cost,salesprice to be null since people might not enter these values in JDE in its first place -- 1/3/2018
   ( 
	 BU					 	varchar(100)
	,ItemNumber				 varchar(100) not null
	,Description			 varchar(100)
	,ShortItemNumber		 varchar(100) not null -- primary key
	,StockingType			 varchar(100)
	,GLCat					varchar(100)
	,LineType				varchar(100)
	,PackQty				decimal(18,6)						-- added 29/3/2019	
	,MfgUnit				varchar(100)						-- added 29/3/2019
	,PrimUM				    varchar(100)						-- added 29/3/2019
	,PurchUM				varchar(100)						-- added 29/3/2019
	,PricingUM			    varchar(100)						-- added 29/3/2019
	,ProdUM				    varchar(100)						-- added 29/3/2019	
	,CompUM				    varchar(100)						-- added 29/3/2019		
	,Colour					varchar(100)						-- added 29/3/2019
	,PlannerNumber		   varchar(100)
	,PrimarySupplier	   varchar(100)
	--,MaxDisc				decimal(18,6)							-- deleted this field 30/11/2019 by Dan Ross
	,ManFC					varchar(100)
	,FamilyGroup			varchar(100)
	,Family					varchar(100)
	,SellingGroup			varchar(100)
	,LocalImport			varchar(100)						-- added 03/8/2020	
	,InvCat					varchar(100)
	,NonStk					varchar(100)
	,WholeSalePrice			decimal(18,6)
	,UOM					varchar(100)
	,ConvUOM				  varchar(100)						-- added 29/3/2019
	,ConversionFactor		  decimal(18,6)						-- added 29/3/2019
	,LeadtimeLevel			 decimal(18,6)
	,StandardCost			decimal(18,6)
	,QtyOnHand				decimal(18,6)
	,StockValue				 decimal(18,6)
	--,SS					decimal(18,6)					    -- deleted this field 30/11/2019 by Dan Ross
	--,MOQ					decimal(18,6)						-- deleted this field 30/11/2019 by Dan Ross
	,ECONumber				varchar(100)
	,CycleCount				varchar(100)						-- added 03/8/2020			
	
	,ItemCreateDate			varchar(100)						-- added 3/12/2019
	,WMSItem				varchar(100)						-- added 3/12/2019
	,ReportDate				datetime default(getdate())			-- added 23/5/2018
	
	,constraint PK_ShortItem_master	primary key (ShortItemNumber)
	,constraint ck_illegal_char check(charindex(',',Description)=0 )
	)
go

create clustered index idx_ShortItem on JDE_DB_Alan.Master_ML345 (ShortItemNumber asc)
Create nonclustered index idx_ml345_plannernumber  ON JDE_DB_Alan.Master_ML345 (PlannerNumber);  
Create nonclustered index idx_ml345_ItemNumber  ON JDE_DB_Alan.Master_ML345 (ItemNumber);  
drop index idx_ml345_ItemNumber on JDE_DB_Alan.Master_ML345

Create unique clustered index idx_v_ml345_ItemNumber  ON  JDE_DB_Alan.vw_Mast (ItemNumber);  

select * from JDE_DB_Alan.vw_Mast
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('42.210.031')


ALTER TABLE employees ADD CONSTRAINT employees_pk PRIMARY KEY (last_name, first_name);		-- Syntax to add Primary Key
ALTER TABLE employees DROP CONSTRAINT employees_pk;											-- Syntax to drop Primary Key

create clustered index i1 on JDE_DB_Alanbulk
.Master_ML345 (ShortItemNumber asc)
ALTER INDEX i1 ON JDE_DB_Alan.Master_ML345  DISABLE;
ALTER INDEX i1 ON JDE_DB_Alan.Master_ML345  REBUILD;

CREATE TABLE JDE_DB_Alan.Master_ML345_temp
   ( 
	 BU				varchar(100),
	ItemNumber      varchar(100) not null,
	Description      varchar(100),
	ShortItemNumber	 varchar(100) not null,
	StockingType      varchar(100),
	GLCat			varchar(100),
	LineType		varchar(100),
	PlannerNumber      varchar(100),
	PrimarySupplier    varchar(100),
	MaxDisc			decimal(18,6),
	ManFC			varchar(100),
	FamilyGroup		varchar(100),
	Family			varchar(100),
	SellingGroup	varchar(100),
	InvCat			varchar(100),
	NonStk			varchar(100),
	WholeSalePrice	decimal(18,6),
	UOM				varchar(100),
	LeadtimeLevel   decimal(18,6),
	StandardCost	decimal(18,6),
	QtyOnHand      decimal(18,6),
	StockValue      decimal(18,6),
	SS				decimal(18,6),
	MOQ				decimal(18,6),
	ECONumber      varchar(100)

	,constraint ck_illegal_char_ check(charindex(',',Description)=0 )
	)
--go

CREATE TABLE JDE_DB_Alan.Master_ML345_old
   ( 
     BU					varchar(100) NOT NULL, 
	 ItemNumber			varchar(1000) NOT NULL, 
	 ShortItemNumber	varchar(100), 
     Description		varchar(100), 	 
	 SellingGroup		varchar(100),
	 FamilyGroup		varchar(100),
	 Family				varchar(100),
	 StandardCost	decimal(18,6),	
	 WholeSalePrice	decimal(18,6)	
  )  
--GO	

CREATE TABLE JDE_DB_Alan.Master_ML345_test
   ( 
     BU					varchar(100) NOT NULL, 
	 ItemNumber			varchar(1000) NOT NULL, 
	 ShortItemNumber	varchar(100), 
     Description		varchar(100), 	 
	 SellingGroup		varchar(100),
	 FamilyGroup		varchar(100),
	 Family				varchar(100),
	 StandardCost	decimal(18,6),	
	 WholeSalePrice	decimal(18,6)	
  )  
--GO	


INSERT INTO JDE_DB_Alan.Master_ML345
SELECT top 1 * FROM JDE_DB_Alan.Master_ML345


--- left join does not workk --- Need to use inner join !!! --- 24/7/17
UPDATE t
  SET t.ItemNumber =  '0'+ y.ItemNumber
  FROM JDE_DB_Alan.Master_ML345_temp AS t
        inner JOIN JDE_DB_Alan.MasterMTLeadingZeroItemList AS y
  ON t.ShortItemNumber = y.ShortItemNo
  --WHERE t.ShortItemNumber = '1044988';
--------------------------------------------------

--- JDE Planning Parameter Master --- 3/12/2020

----- This is the one ------

select * from JDE_DB_Alan.Master_ML345 m					--- 48,783
select * from JDE_DB_Alan.Master_V4102A m					--- 48,784
select * from JDE_DB_Alan.vw_Mast							--- 48,770
select * from JDE_DB_Alan.vw_Mast_Planning					--- 48,782


select distinct m.PrimarySupplier,m.SupplierName from JDE_DB_Alan.vw_Mast m where m.Owner_ like ('rosie%')
select * from JDE_DB_Alan.vw_Mast m where m.PrimarySupplier in ('2829284')
select * from JDE_DB_Alan.vw_Mast_Planning p where p.Item_Number in ('52.008.104','42.210.031')

select * from JDE_DB_Alan.Master_V4102A p where p.Item_Number in ('42.210.031')



delete from JDE_DB_Alan.Master_V4102A	
drop table JDE_DB_Alan.Master_V4102A
	
select * from JDE_DB_Alan.Master_V4102A p
--where p.Item_Number in ('24.722.481S','27.160.320','26.740.060','26.741.820')      --- 7/12/2020, pay attention to ROP_Qty_Max,ROP_Qty_Min,Change_Date,Updated_Date
 where p.Item_Number in ('42.210.031')

CREATE TABLE JDE_DB_Alan.Master_V4102A					--- planning Master			
   ( 
	
	 Business_Unit             varchar(100)
	,Short_Item_Number        varchar(100)				 --- primary key
	,Item_Number              varchar(100)				not null

	,Sls_Cd1                   varchar(100)				--- Family Group name ? or sub family ? ---  ie 'FA' for 42.210.031 -- Fabric Awning ?
	,Sls_Cd2                   varchar(100)				--- Family Group code ie 965 
	,Sls_Cd3                   varchar(100)				--- Family code ie 653
	,Sls_Cd4                   varchar(100)				--- channel name ? WC 

	,Sls_Cd5                   varchar(100)				--- no value populated in JDE
	,Cat_Cd6                   varchar(100)				--- no value populated in JDE
	,Cat_Cd7                   varchar(100)				--- no value populated in JDE

	,Cat_Cd8                   varchar(100)				--- not sure what is value stand for 
	,Cat_Cd9                   varchar(100)				--- N, not sure what is value stand for 
	,Cat_Cd10                  varchar(100)				--- N, not sure what is value stand for 

	,Plan_Fmly                 varchar(100)				--- Item plan family
	,Item_Pool                 varchar(100)
	,Primary_Supplier          varchar(100)
	,Planner_Number             varchar(100)
	,Buyer_Number              varchar(100)
	,G_L_Cat                   varchar(100)
	,Origin_Country            varchar(100)

	,ROP                       decimal(18,6)			-- ROP value ? Yes !
	,Reorder_Quantity           decimal(18,6)			-- EOQ
	,Reorder_Qty_Max           decimal(30,6)
	,Reorder_Qty_Min           decimal(30,6)
	,Order_Multiples           decimal(18,6)
	,Srvc_Lvl                  varchar(100)
	--,Safety_Stock              decimal(18,6)			--- is this field ( SS ) populated field ? Yes ! , this is safety stock in Jde ( updated last time ), waiting for updated next time, but is current value in Jde -- 17/3/2021
	,SS_Adj_Jde              decimal(18,6)				--- name changed 17/3/2021
	,Shelf_Days               decimal(18,6)
	,C_A                      varchar(100)
	,LC_Src                    varchar(100)
	,Lot_Stat_Code            varchar(100)
	,P_C                      varchar(100)
	,G_C                       varchar(100)
	,Item_Group               varchar(100)			    --- Item price group 
	,Back_Y_N                varchar(100)
	,It_Mg                    varchar(100)

	,ABC_1_Sls               varchar(100)
	,ABC_2_Mrg               varchar(100)
	,ABC_3_Inv               varchar(100)
	,ABC_Ovrride              varchar(100)
	,Carrier_Number           varchar(100)
	,Stocking_Type            varchar(100)   not null
	,Ln_Ty                    varchar(100)
	,FIFO_Pricessing          varchar(100)
	,Cyc_Cnt                   varchar(100)

	--,Planning_Code             varchar(100)				--- planning code
	,Planning_Code             decimal(18,6)				--- planning code

	,Dsp_Cod                   decimal(18,6)
	,Net_Chg                   decimal(18,6)
	,Units_Per_Container       decimal(18,6)
	,R_N                       varchar(100)
	,Itm_Rev                   varchar(100)
	,Leadtime_Level            decimal(18,6)
	,Leadtime_MFG              decimal(18,6)
	,InTransit_Days            decimal(18,6)			--- in transit days ( related to lead time )

	,Order_Policy              decimal(18,6)
	,Order_Policy_Value         decimal(18,6)
	,MFG_Leadtime_Quantity      decimal(18,6)
	,Leadtime_Per_Unit          decimal(18,6)

	,T_F                       varchar(100)				--- Planning Fence rule
	,FV_Lt                     varchar(100)			--- Lead time fixed or variable

	,IsCd                     varchar(100)
	,ECO_Number               varchar(100)
	,Change_Date			   datetime			--- date time

	--,Plan_Time_Fence             varchar(100)			--- Planning Time Fence value			

	,Plan_Time_Fence             decimal(18,6)			--- Planning Time Fence value			---9/3/2021
	,Frz_Time_Fence              decimal(18,6)			--- Freeze Fence
	,Msg_Time_Fence              decimal(18,6)			--- Message Display Fence 
	,Time_Fence                  decimal(18,6)			--- Not sure what this value for 

	,Order_Multiple              decimal(18,6)
	,Safety_Leadtime             decimal(18,6)
	,UserID                      varchar(100)
	,Program_ID                  varchar(100)  
	,Work_Stn_ID                 varchar(100)
   --,Date_Updated				  -- varchar(100)		
	,Date_Updated                 datetime				--- date time
	,Time_of_Day                 varchar(100)
	,St_UM                       varchar(100)
	,Best_Before_Days             decimal(18,6)
	,Commitment_Date_Method       decimal(18,6)
	,Exp_Date_Calc_Method         decimal(18,6)
	,Lot_Effective_Days           decimal(18,6)
	,Mix_DL                       varchar(100)
	,Sell_By_Days                  decimal(18,6)
	,Purch_Eff_Days                decimal(18,6)
	,Sellable_Item                 varchar(100)
		
	,ReportDate			    datetime default(getdate())			-- 
	
	,constraint PK_ShortItem_Planning_master	primary key (Short_Item_Number)
	--,constraint ck_illegal_char check(charindex(',',Description)=0 )
	)
go

exec sp_RENAME 'JDE_DB_Alan.Master_V4102A.Safety_Stock', 'Safety_Stock_Jde', 'COLUMN'


CREATE TABLE JDE_DB_Alan.PO_All_Staging					--- PO All with data type set as varchar			
   ( 
	
	 Order_Co                      varchar(100)
	,Business_Unit                 varchar(100)
	,Order_Number                  varchar(100)
	,Item_Number                   varchar(100)
	,Descrip						 varchar(100)
	,Short_Item_No                  varchar(100)
	,Or_Ty                         varchar(100)
	,Line_Number                    varchar(100)
	,Address_Number                varchar(100)
	,Ship_To_Number                varchar(100)
	,Buyer_Number                  varchar(100)
	,Account_ID                     varchar(100)
	,UM                            varchar(100)
	,Quantity_Open                 varchar(100)
	,Amount_Open_1                 varchar(100)
	,Amount_Open_2                 varchar(100)
	,Currency_Code                 varchar(100)
	
	,Order_Date                    varchar(100)
	,Request_Date                   varchar(100)
	,Original_Promised_Date        varchar(100)
	,G_L_Date                      varchar(100)
	,Cancel_Date                    varchar(100)
	
	,Last_Stat                     varchar(100)
	,Next_Stat                      varchar(100)
	,Transaction_Originator         varchar(100)
	,Third_Item_Number             varchar(100)
	,Ln_Ty                         varchar(100)
	,Quantity_Ordered              varchar(100)
	,Related_PO_SO_No              varchar(100)
	,Rel_Ord_Type                 varchar(100)
	,Related_PO_SO_Line_No        varchar(100)


	
	,Extended_Price              varchar(100)
	,Foreign_Extended_Price      varchar(100)
	,Unit_Cost                    varchar(100)
	,Foreign_Unit_Cost           varchar(100)

	,Actual_Ship_Date              varchar(100)	
	
	,Related_Item_No              varchar(100)
	,Shipment_Number              varchar(100)
	
	,Sched_Pick                   varchar(100)
	,User_Reference               varchar(100)

	--,ReportDate			    datetime default(getdate())			
	
	,constraint PK_ShortItem_PO_All_Staging	primary key (Short_Item_No,Order_Number,Line_Number)


	)
go

select * from JDE_DB_Alan.PO_All_Staging p where p.Item_Number in ('34.223.000*OP100')

select p.Item_Number,p.Order_Number,p.Quantity_Ordered,p.Order_Date,p.Actual_Ship_Date,p.Descrip,p.UM from JDE_DB_Alan.PO_All_Staging p where p.Item_Number in ('34.223.000*OP100')


select * from JDE_DB_Alan.PO_All_Staging p where p.Order_Number in ('515133')
select * from JDE_DB_Alan.PO_All_Staging p where p.Order_Number in ('511999')

delete from JDE_DB_Alan.PO_All_Staging 
drop table JDE_DB_Alan.PO_All_Staging


select * from JDE_DB_Alan.PO_All_Testing p where p.Item_Number in ('34.223.000*OP100')
select * from JDE_DB_Alan.PO_All_Testing p where p.Order_Number in ('511999')
select * from JDE_DB_Alan.PO_All_Testing p where p.Order_Number in ('515133')
drop table JDE_DB_Alan.PO_All_Testing


select * from JDE_DB_Alan.PO_All p where p.Item_Number in ('34.223.000*OP100')
select * from JDE_DB_Alan.PO_All p where p.Order_Number in ('511999')
select * from JDE_DB_Alan.PO_All p where p.Order_Number in ('515133')

select * into JDE_DB_Alan.JDE_DB_Alan.PO_All_Testing from JDE_DB_Alan.PO_All  


drop table JDE_DB_Alan.PO_All

CREATE TABLE JDE_DB_Alan.PO_All					--- PO All - field with different data type		
   ( 
	
	 Order_Co                      varchar(100)
	,Business_Unit                 varchar(100)
	,Order_Number                  varchar(100)
	,Item_Number                   varchar(100)
	,Descrip						 varchar(100)
	,Short_Item_No                  varchar(100)
	,Or_Ty                         varchar(100)
	,Line_Number                    varchar(100)
	,Address_Number                varchar(100)
	,Ship_To_Number                varchar(100)
	,Buyer_Number                  varchar(100)
	,Account_ID                     varchar(100)
	,UM                            varchar(100)
	,Quantity_Open                 decimal(18,6)
	,Amount_Open_1                   decimal(18,6)
	,Amount_Open_2                  decimal(18,6)
	,Currency_Code                 varchar(100)
	
	--,Order_Date                    varchar(100)
	--,Request_Date                   varchar(100)
	--,Original_Promised_Date        varchar(100)
	--,G_L_Date                      varchar(100)
	--,Cancel_Date                    varchar(100)

	,Order_Date                     datetime	
	,Request_Date                   datetime	
	,Original_Promised_Date         datetime	
	,G_L_Date                       datetime	
	,Cancel_Date                    datetime	

	
	,Last_Stat                     varchar(100)
	,Next_Stat                      varchar(100)
	,Transaction_Originator         varchar(100)
	,Third_Item_Number             varchar(100)
	,Ln_Ty                         varchar(100)
	,Quantity_Ordered             decimal(18,6)
	,Related_PO_SO_No              varchar(100)
	,Rel_Ord_Type                 varchar(100)
	,Related_PO_SO_Line_No        varchar(100)

	,Extended_Price               decimal(18,6)
	,Foreign_Extended_Price       decimal(18,6)
	,Unit_Cost                    decimal(18,6)
	,Foreign_Unit_Cost            decimal(18,6)
	
	--,Extended_Price              varchar(100)
	--,Foreign_Extended_Price      varchar(100)
	--,Unit_Cost                    varchar(100)
	--,Foreign_Unit_Cost           varchar(100)


	--,Actual_Ship_Date              varchar(100)
	,Actual_Ship_Date				datetime	
	
	,Related_Item_No              varchar(100)
	,Shipment_Number              varchar(100)
	
	--,Sched_Pick                   varchar(100)
	,Sched_Pick                   datetime	

	,User_Reference               varchar(100)
	,ReportDate			    datetime default(getdate())			
	
	,constraint PK_ShortItem_PO_All	primary key (Short_Item_No,Order_Number,Line_Number)


	)
go


 
drop table JDE_DB_Alan.PO_All



select * from JDE_DB_Alan.vw_Mast_Planning
select * from JDE_DB_Alan.Master_V4102A m where m.Item_Number like ('%850525000202%')
select * from JDE_DB_Alan.Master_V4102A_stage
select * into JDE_DB_Alan.Master_V4102A_stage  from JDE_DB_Alan.Master_V4102A
delete from JDE_DB_Alan.Master_V4102A

insert into JDE_DB_Alan.Master_V4102A select * from JDE_DB_Alan.Master_V4102A_test

select * from JDE_DB_Alan.Master_V4102A_test

delete from JDE_DB_Alan.Master_V4102A_test	
drop table JDE_DB_Alan.Master_V4102A_test
	
select * from JDE_DB_Alan.Master_V4102A_test p
where p.Item_Number in ('24.722.481S','27.160.320','26.740.060','26.741.820')      --- 7/12/2020, pay attention to ROP_Qty_Max,ROP_Qty_Min,Change_Date,Updated_Date

CREATE TABLE JDE_DB_Alan.Master_V4102A_test					--- planning Master			
   ( 
	
	Business_Unit             varchar(100)
	,Short_Item_Number        varchar(100)		--- primary key
	,Item_Number              varchar(100)			 not null
	,Sls_Cd1                   varchar(100)
	,Sls_Cd2                   varchar(100)
	,Sls_Cd3                   varchar(100)
	,Sls_Cd4                   varchar(100)
	,Sls_Cd5                   varchar(100)
	,Cat_Cd6                   varchar(100)
	,Cat_Cd7                   varchar(100)
	,Cat_Cd8                   varchar(100)
	,Cat_Cd9                   varchar(100)
	,Cat_Cd10                  varchar(100)
	,Plan_Fmly                 varchar(100)
	,Item_Pool                 varchar(100)
	,Primary_Supplier          varchar(100)
	,Planner_Number             varchar(100)
	,Buyer_Number              varchar(100)
	,G_L_Cat                   varchar(100)
	,Origin_Country            varchar(100)

	,ROP                       decimal(18,6)
	,Reorder_Quantity           decimal(18,6)
	,Reorder_Qty_Max           decimal(30,6)
	,Reorder_Qty_Min           decimal(30,6)
	,Order_Multiples           decimal(18,6)
	,Srvc_Lvl                  varchar(100)
	,Safety_Stock              decimal(18,6)
	,Shelf_Days               decimal(18,6)

	,C_A                      varchar(100)
	,LC_Src                    varchar(100)
	,Lot_Stat_Code            varchar(100)
	,P_C                      varchar(100)
	,G_C                       varchar(100)
	,Item_Group               varchar(100)
	,Back_Y_N                varchar(100)
	,It_Mg                    varchar(100)
	,ABC_1_Sls               varchar(100)
	,ABC_2_Mrg               varchar(100)
	,ABC_3_Inv               varchar(100)
	,ABC_Ovrride              varchar(100)
	,Carrier_Number           varchar(100)
	,Stocking_Type            varchar(100)   not null
	,Ln_Ty                    varchar(100)
	,FIFO_Pricessing          varchar(100)
	,Cyc_Cnt                    varchar(100)
	,Planning_Code            varchar(100)						--- decimal(18,6)

	,Dsp_Cod                   decimal(18,6)
	,Net_Chg                   decimal(18,6)
	,Units_Per_Container         decimal(18,6)
	,R_N                         varchar(100)
	,Itm_Rev                    varchar(100)
	,Leadtime_Level              decimal(18,6)
	,Leadtime_MFG              decimal(18,6)
	,InTransit_Days            decimal(18,6)
	,Order_Policy              decimal(18,6)
	,Order_Policy_Value         decimal(18,6)
	,MFG_Leadtime_Quantity      decimal(18,6)
	,Leadtime_Per_Unit          decimal(18,6)

	,T_F                       varchar(100)
	,FV_Lt                      varchar(100)
	,IsCd                       varchar(100)
	,ECO_Number                 varchar(100)
	,Change_Date					datetime			--- date time
	,Plan_Time_Fence             varchar(100)				--- decimal(18,6)
	,Frz_Time_Fence              decimal(18,6)
	,Msg_Time_Fence              decimal(18,6)
	,Time_Fence                  decimal(18,6)
	,Order_Multiple              decimal(18,6)
	,Safety_Leadtime             decimal(18,6)

	,UserID                      varchar(100)
	,Program_ID                  varchar(100)  
	,Work_Stn_ID                 varchar(100)
   --,Date_Updated				  -- varchar(100)		
	,Date_Updated                 datetime				--- date time

	,Time_of_Day                 varchar(100)
	,St_UM                       varchar(100)
	,Best_Before_Days             decimal(18,6)
	,Commitment_Date_Method       decimal(18,6)
	,Exp_Date_Calc_Method         decimal(18,6)
	,Lot_Effective_Days           decimal(18,6)
	,Mix_DL                       varchar(100)
	,Sell_By_Days                  decimal(18,6)
	,Purch_Eff_Days                decimal(18,6)
	,Sellable_Item                 varchar(100)
		
	,ReportDate			    datetime default(getdate())			-- 
	
	,constraint PK_ShortItem_Planning_master_test	primary key (Short_Item_Number)
	--,constraint ck_illegal_char check(charindex(',',Description)=0 )
	)
go


---------------------------------------------------


select * from JDE_DB_Alan.Master_ML345_temp a where a.ShortItemNumber in ('1074571')
--delete from JDE_DB_Alan.Master_ML345

CREATE TABLE JDE_DB_Alan.MasterPrice
   ( 
     RawLabel		varchar(100) NOT NULL, 
     SellingGroup	varchar(100) not null, 
	 FamilyGroup	varchar(100) not null, 				-- 2nd ItemNumber
	 Family			varchar(100) not null,  		 		 
	 ItemNumber		varchar(100) not null,	
	 ShortItemNumber varchar(100) not null primary key, 
	 StandardCost	decimal(18,6),	
	 WholeSalePrice	decimal(18,6)	    
  )  
--GO	

drop table JDE_DB_Alan.MasterSuperssionItemList
CREATE TABLE JDE_DB_Alan.MasterSuperssionItemList
   ( 
     CurrentItemNumber		varchar(100) NOT NULL, 
	 CurrentShortItemNumber	varchar(100) not null, 
     --ItemDescription		varchar(100) not null, 
	 --FamilyGroup			varchar(100) not null, 				
	 --ItemPriceGroup		varchar(100) not null,  		 		 
	 --IPGDescription		varchar(100) not null,
	 --UOM					varchar(100) not null, 	
	 --StockingType			varchar(100) not null,	
	-- MTListPrice			decimal(18,6),	
	 NewItemNumber			varchar(100) NOT NULL,
	 NewShortItemNumber		varchar(100) not null,
	 ConversionRate_UOM		decimal(18,6),
	 Comment				varchar(1000) ,
	 ValidStatus			varchar(100),						-- if valid then active , for record keeping purpose		-- 8/6/2018
	 UpdateDate				datetime,
	 ReportDate				datetime default(getdate()),
	 constraint PK_ShtItem_Sups primary key (CurrentShortItemNumber,ValidStatus)
  )  
--GO	
select * from JDE_DB_Alan.MasterSuperssionItemList



CREATE TABLE JDE_DB_Alan.MasterMTSuperssionItemList
   ( 
     CurrentItemNumberMT	varchar(100) NOT NULL, 
     ItemDescription		varchar(100) not null, 
	 FamilyGroup			varchar(100) not null, 				
	 ItemPriceGroup			varchar(100) not null,  		 		 
	 IPGDescription			varchar(100) not null,
	 UOM				varchar(100) not null, 	
	 StockingType		varchar(100) not null,	
	 MTListPrice			decimal(18,6),	
	 NewItemNumberHD		varchar(100) NOT NULL,
	 NewShortItemNumberHD   varchar(100) NOT NULL
  )  
--GO	

drop table JDE_DB_Alan.MasterMTLeadingZeroItemList
CREATE TABLE JDE_DB_Alan.MasterMTLeadingZeroItemList
   ( 
    BranchPlant			varchar (100 )  not null,
	ItemNumber			varchar (100 )  not null,
	ItemWithLeadingZero	varchar (100 )  not null,
	Description			varchar (100 )  not null,
	Description2		varchar (100 )  not null,
	StockingType		varchar (100 )  not null,
	FamilyGroup			varchar (100 )  not null,
	Family				varchar (100 )  not null,
	ShortItemNo			varchar (100 )  not null,
	SellingGroup		varchar (100 )  not null,
	NewItemNumber		varchar (100 )  not null

  )  
--GO	

alter table JDE_DB_Alan.MasterMTLeadingZeroItemList add NewItemNumber varchar(100)

;update m 
		set m.NewItemNumber = case m.ItemWithLeadingZero
									 when 'Y' then '0'+ m.ItemNumber
					                 else  m.ItemNumber		    
							  end 
from JDE_DB_Alan.MasterMTLeadingZeroItemList m 

select * from JDE_DB_Alan.MasterMTLeadingZeroItemList

exec JDE_DB_Alan.sp_FCPro_upd_withleadingzero
SELECT * FROM [JDE_DB_Alan].FCPRO_Fcst f where f.ItemNumber like ('%850531003021%')  and f.DataType1 in ('Adj_FC')
order by f.ItemNumber asc 


select * from JDE_DB_Alan.vw_Mast_Vendor_Item_CrossRef
select * from JDE_DB_Alan.Master_Vendor_Item_CrossRef
delete from JDE_DB_Alan.Master_Vendor_Item_CrossRef
drop table JDE_DB_Alan.Master_Vendor_Item_CrossRef

CREATE TABLE JDE_DB_Alan.Master_Vendor_Item_CrossRef
   ( 
    ItemNumber						varchar (100 ),
	ShortItemNumber					varchar (100 ),
	Xref_Type						varchar (100 ),
    Address_Number					varchar (100 ),
	Customer_Supplier_ItemNumber	varchar (100 ),
	ExpiredDate						datetime,
	EffectiveDate					datetime,
	BusinessUnit					varchar (100 ),
	Description						varchar (100 ),
	DescriptionLine2				varchar (100 ),	
	--ItemNumber						varchar (100 ),
	UserID							varchar (100 ),
	ReportDate						datetime default(getdate())
  )  
--GO	

select * from JDE_DB_Alan.MasterSupplier
delete from JDE_DB_Alan.MasterSupplier
drop table JDE_DB_Alan.MasterSupplier												--13/11/2018
CREATE TABLE JDE_DB_Alan.MasterSupplier				--- old
   ( 		
		 PlannerNumber				varchar(100)
		,SupplierNumber				varchar(100) not null primary key
		,SupplierName				varchar(100)		
		,Reportdate			  datetime default(getdate())
		--,CONSTRAINT PK_Item_PO PRIMARY KEY (ItemNumber,OrderNumber,QuantityOrdered,DueDate)

   )
ALTER TABLE JDE_DB_Alan.MasterSupplier ADD CONSTRAINT PK_Item_PO PRIMARY KEY (ItemNumber,OrderNumber,QuantityOrdered,DueDate);
ALTER TABLE JDE_DB_Alan.MasterSupplier ADD OpenPOID int NOT NULL IDENTITY (1,1) PRIMARY KEY	


CREATE TABLE JDE_DB_Alan.MasterSupplier			--- new 3/8/2020
   ( 		
		 SupplierNumber				varchar(100) not null primary key			-- AddressNumber
		,SupplierName_2				varchar(1000)								--  Alpha Name
		,SupplierName				varchar(1000)								--   Description Compressed
		,Sch_Typ					varchar(100)	
		,Continent_					varchar(100)
		,UserID_					varchar(100)
		,Program_ID					varchar(100)
		,DateUpdated				datetime
		,Work_Stn_ID				varchar(100)
		,TimeUpdated				decimal(18,6)
		,ReportDate					datetime default(getdate())
		
		--,constraint PK_SupplierNumber  primary key (SupplierNumber)
		--,CONSTRAINT PK_Item_PO PRIMARY KEY (ItemNumber,OrderNumber,QuantityOrdered,DueDate)
   )



CREATE TABLE JDE_DB_Alan.Master_UOMConversion					--- 27/3/2019
   ( 
     BU							varchar(100) NOT NULL, 
	-- ItemNumber				varchar(1000) NOT NULL, 
	 ShortItemNumber			varchar(100),     
	 UOM_From					varchar(100),
	 UOM_To						varchar(100),
	 Conv_Factor				decimal(18,6),
	 Conv_Factor_2ndToPmy		decimal(18,6),
	-- ReportDate					datetime default(getdate())
  )  

drop table JDE_DB_Alan.TextileWC
CREATE TABLE JDE_DB_Alan.TextileWC
   ( 
     BU					varchar(100) NOT NULL, 
	 ShortItemNumber	varchar(100) NOT NULL, 
	 ItemNumber			varchar(100) NOT NULL,
	 EffectiveFrom		datetime,		
	 EffectiveThru		datetime,
	 WorkCenter			varchar(1000) ,
	 WorkCenterName		varchar(100),						
	 ReportDate			datetime default(getdate()),
	 constraint PK_WCItem primary key (BU,ShortItemNumber,WorkCenterName)
  )  
--GO	
select * from JDE_DB_Alan.TextileWC wc where wc.WorkCenterName is null or wc.WorkCenterName =''
select * from JDE_DB_Alan.TextileWC wc where wc.ItemNumber in ('83.529.901')

----------------- Transaction Data Tabel Below   --------------------------

--drop table JDE_DB_Alan.JDE_Fcst_DL
----drop table JDE_DB_Alan.Master_ItemCrossRef
--drop table JDE_DB_Alan.SalesHistoryAWFHDMT
--drop table JDE_DB_Alan.SlsHistoryMT
--drop table JDE_DB_Alan.SlsHistoryHD
--drop table JDE_DB_Alan.HistoryMTB4Superssion 
--drop table JDE_DB_Alan.SalesHistoryAWFHDMTuploadToFCPRO_Px
--drop table JDE_DB_Alan.FCPRO_Fcst

--drop table JDE_DB_Alan.FCPRO_Fcst_Pareto
--drop table JDE_DB_Alan.FCPRO_SafetyStock
--drop table JDE_DB_Alan.FCPRO_MI
--drop table JDE_DB_Alan.FCPRO_MI_tmp
--drop table JDE_DB_Alan.FCPRO_NP
--drop table JDE_DB_Alan.FCPRO_NP_tmp
------------------------------------------------------------

--drop table JDE_DB_Alan.FCPRO_MI_2_Raw_Data_tmp
CREATE TABLE JDE_DB_Alan.FCPRO_MI_2_Raw_Data_tmp
(       

		ItemID				varchar(100)      not null,
		Date				datetime,		
		Value					decimal(18,12),	
		--Description			varchar(1000),					-- remember 'Normalization' rule when designing data base, so remove this column and get description info from Master table,but you can has 'Description' column in your Excel raw data file to make end user life bit easier.
		DataType				varchar(100),
		CN_Number				varchar(100),
		Comment				varchar(1000),						-- Enter 'NP' or 'MI' word to start follow by dash then Change Notice number, then brief description of change.can include Range information ( like 'Signature) which is userful
		Creator				varchar(100),		
		LastUpdated			datetime,
		ValidStatus			varchar(100),						-- if valid then active , for record keeping purpose
		RefNum				varchar(100),						--- Normally it is Old ItemNumber, if you need to add ShortItemNumber you need to add another column - 31/5/2018
		ReportDate			datetime default(getdate())
		--constraint PK_MI_2_Raw_Data primary key (ItemID,Date)
)

CREATE TABLE JDE_DB_Alan.FCPRO_MI_2_tmp
(       

		ItemNumber			varchar(100)      not null,
		Date				datetime,		
		Value					decimal(18,12),	
		--Description			varchar(1000),					-- remember 'Normalization' rule when designing data base, so remove this column and get description info from Master table,but you can has 'Description' column in your Excel raw data file to make end user life bit easier.
		DataType				varchar(100),
		CN_Number				varchar(100),
		Comment				varchar(1000),						-- Enter 'NP' or 'MI' word to start follow by dash then Change Notice number, then brief description of change.can include Range information ( like 'Signature) which is userful
		Creator				varchar(100),		
		LastUpdated			datetime,
		ValidStatus			varchar(100),						-- if valid then active , for record keeping purpose
		RefNum				varchar(100),						--- Normally it is Old ItemNumber, if you need to add ShortItemNumber you need to add another column - 31/5/2018
		ReportDate			datetime default(getdate())
)
--drop table JDE_DB_Alan.FCPRO_MI_orig
CREATE TABLE JDE_DB_Alan.FCPRO_MI_orig
(       
		ItemID			varchar(100)    not null,
		Description			varchar (100 ),  
		WO_Order_Number		decimal(18,0),	
		SO_Order_Number		decimal(18,0),		
		--Project_Name		varchar(100),
		Comment				varchar(100),				
		UOM					varchar(100) not null, 	
		Order_Quantity		decimal(18,12),	
		Date				datetime,		
		Value				decimal(18,12),			
		ReportDate			datetime default(getdate())
		constraint PK_MI_Orig primary key (ItemID,Date)
)


CREATE TABLE JDE_DB_Alan.FCPRO_MI
(       
		RowLabel			varchar(100),		
		SellingGroup		varchar(100)	  ,
		FamilyGroup			varchar(100)      ,
		Family				varchar(100)      ,
		ItemNumber			varchar(100)      not null,
		Date				datetime,
		Row					varchar(100),
		Baseline_Qty		decimal(18,12),		
		Formula				varchar(100),
		Overide_Qty			decimal(18,12),	
		Comment				varchar(1000),		
		LastUpdated			datetime,
		ReportDate			datetime default(getdate())
)

drop table JDE_DB_Alan.FCPRO_MI_tmp
CREATE TABLE JDE_DB_Alan.FCPRO_MI_tmp
(       

		ItemNumber			varchar(100)      not null,
		Date				datetime,		
		Value					decimal(18,12),	
		--Description			varchar(1000),					-- remember 'Normalization' rule when designing data base, so remove this column and get description info from Master table,but you can has 'Description' column in your Excel raw data file to make end user life bit easier.
		DataType				varchar(100),
		CN_Number				varchar(100),
		Comment				varchar(1000),						-- Enter 'NP' or 'MI' word to start follow by dash then Change Notice number, then brief description of change.can include Range information ( like 'Signature) which is userful
		Creator				varchar(100),		
		LastUpdated			datetime,
		ValidStatus			varchar(100),						-- if valid then active , for record keeping purpose
		RefNum				varchar(100),						--- Normally it is Old ItemNumber, if you need to add ShortItemNumber you need to add another column - 31/5/2018
		ReportDate			datetime default(getdate())
)
select * from JDE_DB_Alan.FCPRO_MI_tmp



CREATE TABLE JDE_DB_Alan.JDE_Fcst_DL								-- JDE forecast download table			1/5/2018
(       
		ShortItemNunber		varchar(100),
		BU					varchar(100),
		DataType_1			varchar(100),
		Date				datetime,
		Qty					decimal(18,12),		
		ItemNumber			varchar(100),	
		DataType_2			varchar(100),
		Bypass_Forcing		varchar(100),				
		ReportDate			datetime default(getdate())
)


drop table JDE_DB_Alan.FCPRO_SafetyStock_Excp										---3/7/2020
select * from JDE_DB_Alan.FCPRO_SafetyStock_Excp
CREATE TABLE JDE_DB_Alan.FCPRO_SafetyStock_Excp
(       
		ItemNumber			varchar(100)      not null,
        SS_Old				decimal(18,12),
		SS_New				decimal(18,12),
		ValidStatus			varchar(100),	
		Date_Updated		datetime,		
		ReportDate			datetime default(getdate()),

		Index_Row_Number	bigint,
		Comments			varchar(3500) 

		constraint PK_SafetyStock_Excp primary key (ItemNumber,Date_Updated,ValidStatus)	
)

select * from JDE_DB_Alan.FCPRO_SafetyStock_Excp e


--- find key then you can drop it if you want ---
SELECT *
FROM   sys.key_constraints
WHERE  [type] = 'PK'
       AND [parent_object_id] = Object_id('JDE_DB_Alan.FCPRO_SafetyStock');


alter table JDE_DB_Alan.FCPRO_Fcst drop constraint [DF__FCPRO_Fcs__Repor__3FD07829]

ALTER TABLE employees ADD CONSTRAINT employees_pk PRIMARY KEY (last_name, first_name);		-- Syntax to add Primary Key
ALTER TABLE employees DROP CONSTRAINT employees_pk;											-- Syntax to drop Primary Key
ALTER TABLE JDE_DB_Alan.MasterSupplier ADD CONSTRAINT PK_Item_PO PRIMARY KEY (ItemNumber,OrderNumber,QuantityOrdered,DueDate);
ALTER TABLE JDE_DB_Alan.MasterSupplier ADD OpenPOID int NOT NULL IDENTITY (1,1) PRIMARY KEY	


drop table JDE_DB_Alan.FCPRO_SafetyStock_test
delete from JDE_DB_Alan.FCPRO_SafetyStock
drop table JDE_DB_Alan.FCPRO_SafetyStock

select * from JDE_DB_Alan.FCPRO_SafetyStock

CREATE TABLE JDE_DB_Alan.FCPRO_SafetyStock
(       
		ItemNumber						varchar(100)      not null,
		Sales_12Mth						decimal(18,2),		
		Pareto							varchar(2),	
		StockingType					varchar(100),

		SS_								decimal(18,12),
		SS_Adj							decimal(18,12),						
		ValidStatus_Adj_Flag			varchar(100),				

		Stdevp_							decimal(18,2),			
		LeadtimeLevel					decimal(18,12),
		rn								int,
		StandardCost					decimal(18,6),

		Order_Policy					 decimal(18,6),
		Order_Policy_Description		varchar(100),	
		Planning_Code					decimal(18,6),
		Planning_Code_Description		varchar(100),	
		Planning_Fence_Rule				varchar(100),	
		Planning_Fence_Rule_Description		varchar(100),	


		--Date_Updated	    datetime,		
		ReportDate			datetime default(getdate()),
		--Index_Row_Number	bigint	

		constraint PK_SafetyStock primary key (ItemNumber,ValidStatus_Adj_Flag,ReportDate)	

)


ALTER TABLE JDE_DB_Alan.FCPRO_SafetyStock drop column Index_Row_Number;
select * from JDE_DB_Alan.FCPRO_SafetyStock
EXEC sp_rename 'JDE_DB_Alan.JDE_DB_Alan.FCPRO_SafetyStock.ValidStatus', 'ValidStatus_Adj_Flag', 'COLUMN';

   --- Add 'Total' at bottom --- Method 1
with  t as (	select count(a.ItemNumber) as Rows_,a.ReportDate from JDE_DB_Alan.FCPRO_SafetyStock a group by a.ReportDate )
     ,_t as  (
				SELECT convert(varchar,t.ReportDate,120) as ReportDate_,t.Rows_
				From  t
				union all 
				SELECT 'Total', Sum(t.Rows_)
				From  t
				)
      select * from _t

		 --- Use below if you have problem with ordering ---https://stackoverflow.com/questions/17934318/add-a-summary-row-with-totals --- 16/3/2021
--with  t as (	select count(a.ItemNumber) as Rows_,convert(varchar,a.ReportDate,120) as ReportDate_ from JDE_DB_Alan.FCPRO_SafetyStock a group by convert(varchar,a.ReportDate,120) )
	--select aa.ReportDate_,aa.Rows_
	--from (SELECT t.ReportDate_,t.Rows_, 0 mykey From t 
	--	  union all 
	--	  SELECT 'Total', Sum(t.Rows_),1 From t
	--	  ) aa 
	--order by aa.ReportDate_


	 --- Add 'Total' at bottom --- Method 2
;with  t as (	select count(a.ItemNumber) as Rows_,convert(varchar,a.ReportDate,120) as ReportDate_ from JDE_DB_Alan.FCPRO_SafetyStock a group by convert(varchar,a.ReportDate,120) )

		SELECT ReportDate_ = COALESCE(ReportDate_, 'Total'), 
			   Rows_ = SUM(Rows_)
		FROM t
		GROUP BY GROUPING SETS((ReportDate_),());

;update a
set a.rn = 1
from JDE_DB_Alan.FCPRO_SafetyStock a
where a.ReportDate between '2021-03-01' and '2021-03-15 13:00:00'


;update a
set a.ReportDate = '2021-03-12 15:00:00'
from JDE_DB_Alan.FCPRO_SafetyStock a
where  ReportDate >'2021-03-17'

where a.ReportDate between '2021-03-01' and '2021-03-02 13:00:00'
--where a.ReportDate between '2018-04-20' and '2018-05-03 13:00:00'


select * from JDE_DB_Alan.FCPRO_SafetyStock_test
select * from JDE_DB_Alan.FCPRO_SafetyStock a where a.ReportDate between '2021-03-08' and '2021-03-09'
select * from JDE_DB_Alan.FCPRO_SafetyStock a where a.ItemNumber in ('42.210.031','34.506.000')

select * into JDE_DB_Alan.FCPRO_SafetyStock_test from JDE_DB_Alan.FCPRO_SafetyStock
insert into JDE_DB_Alan.FCPRO_SafetyStock select * from JDE_DB_Alan.FCPRO_SafetyStock_test

select * from JDE_DB_Alan.JDE_DB_Alan.FCPRO_SafetyStock_test
select * from 


CREATE TABLE JDE_DB_Alan.FCPRO_SafetyStock_RM
(       
		ItemNumber			varchar(100)      not null,
		Sales_12Mth			decimal(18,2),		
		Pareto				varchar(2),	
		Stdevp_				decimal(18,2),	
		LeadtimeLevel		decimal(18,12),
		rk					int,
		SS_					decimal(18,12),
		ReportDate			datetime default(getdate())

)


drop table JDE_DB_Alan.FCPRO_Fcst_Pareto
CREATE TABLE JDE_DB_Alan.FCPRO_Fcst_Pareto
   ( 
     
		ItemNumber			varchar(100)      not null,
		SellingGroup		varchar(100)	  ,
		FamilyGroup			varchar(100)      ,
		Family				varchar(100)      ,
		DataType1			varchar(100)      ,
		--ItemLvlFC_24_Amt	decimal(18,2),
		--RunningTTL			decimal(18,2),
		--GrandTTL			decimal(18,2),
		--Pct					decimal(18,12),
		--RunningTTLPct		decimal(18,12),
		rnk					int,
		Pareto				varchar(2),	
		StockingType		 varchar(100),
		--PlannerNumber		 varchar(100),			
		ReportDate			datetime default(getdate())
  )  
--GO	
				
CREATE TABLE JDE_DB_Alan.FCPRO_NP					-- Use Override Format to load NP FC ?   --- -- cannot upload into FC Pro DB Straight, has to use Override Format?
   ( 
		RowLabel			varchar(100),		
		SellingGroup		varchar(100)	  ,
		FamilyGroup			varchar(100)      ,
		Family				varchar(100)      ,
		ItemNumber			varchar(100)      not null,
		Date				datetime,
		Row					varchar(100),
		Baseline_Qty		decimal(18,12),		
		Formula				varchar(100),
		Overide_Qty			decimal(18,12),	
		Comment				varchar(1000),		
		LastUpdated			datetime,
		ReportDate			datetime default(getdate())
   )

drop view [vw_NP_FC_Analysis_Old]
drop view [vw_NP_FC_Analysis]
drop table JDE_DB_Alan.FCPRO_NP_tmp
drop view JDE_DB_Alan.vw_Mast
drop view JDE_DB_Alan.vw_FC
drop view JDE_DB_Alan.vw_NP_FC_Analysis


CREATE TABLE JDE_DB_Alan.FCPRO_NP_tmp
   (     	
		ItemNumber				varchar(100)      not null,		
		Date					datetime,
		Value					decimal(18,2),
		--Decription			varchar(1000),				-- remember 'Normalization' rule when designing data base, so remove this column and get description info from Master table,but you can has 'Description' column in your Excel raw data file to make end user life bit easier.
		DataType				varchar(100),
		CN_Number				varchar(100),
		Comment					varchar(1000),					-- normally put range info there ---- Enter 'NP' or 'MI' word to start follow by dash then Change Notice number, then brief description of change.can include Range information ( like 'Signature) which is userful
		Creator					varchar(100),
		LastUpdated				datetime,
		ValidStatus			varchar(100),						-- if valid then active
		RefNum				varchar(100),
		ReportDate				datetime
  )  
--GO	
select * from JDE_DB_Alan.FCPRO_NP_tmp


CREATE TABLE JDE_DB_Alan.FCPRO_NP_tmp_vw
   (     	
		ItemNumber				varchar(100)      not null,		
		Date					datetime,
		Value					decimal(18,2),
		--Decription			varchar(1000),				-- remember 'Normalization' rule when designing data base, so remove this column and get description info from Master table,but you can has 'Description' column in your Excel raw data file to make end user life bit easier.
		Comment					varchar(1000),					-- normally put range info there
		Creator					varchar(100),
		HasSalesActual			varchar(10),
		SlsMthCount				int,
		CreateSKUIn_FCPRO		varchar(10),
		OverrideIn_FCPRO		varchar(10),
		LastUpdated				datetime,
		ReportDate				datetime
  )  
--GO	

drop table JDE_DB_Alan.FCPRO_Modifiers
drop table JDE_DB_Alan.FCPRO_Modifiers_tmp	
							
CREATE TABLE JDE_DB_Alan.FCPRO_Modifiers_cmt				-- this is table with comments, works this way: first upload into Sql server using original Modifiers ds from downloaded Modifiers file from FC Pro, upload this table, compare the two tables, then dump item with no commments into Excel, Alan to add some comments and insert back into 'tmp' table with comments. This process cycles some you will alway have comments /log againt each change for Modifiers. 
   (     													
		ItemNumber				varchar(100)      not null,		
		Modifier				varchar(1000),
		Comment					varchar(1000),					-- normally put range info there ---- Enter 'NP' or 'MI' word to start follow by dash then Change Notice number, then brief description of change.can include Range information ( like 'Signature) which is userful	
		LastUpdated				datetime,
		ReportDate				datetime	
  )  
--GO	

CREATE TABLE JDE_DB_Alan.FCPRO_Modifiers_tmp				
   (     													-- this is table ready to upload into FC Pro (You actually do not need to do any extra work ),unlike NP/MI you need to add Hierarchy info, this one you do not need. Becasue NP and MI are input from Product or Sales team.
     	RowLabel			varchar(100),					 -- it is almost like NP or MI table with no '_tmp' at end.
		SellingGroup		varchar(100),
		FamilyGroup			varchar(100),
		Family				varchar(100),
		ItemNumber			varchar(100)      not null,		
		Modifier			varchar(1000)		
  )  
--GO	
					
								


ALTER TABLE JDE_DB_Alan.FCPRO_Fcst_NP_upload ADD ReportDate	datetime default(getdate());
ALTER TABLE JDE_DB_Alan.FCPRO_Fcst_NP_upload drop column ReportDate;

drop table JDE_DB_Alan.FCPRO_Fcst_downloaded
CREATE TABLE JDE_DB_Alan.FCPRO_Fcst_downloaded
   (      
		ItemNumber     varchar(100)      not null,
		DataType1		varchar(100)      ,		
		[1]				decimal(18,2),
		[2]				decimal(18,2),
		[3]				decimal(18,2),
		[4]				decimal(18,2),
		[5]				decimal(18,2),
		[6]				decimal(18,2),
		[7]				decimal(18,2),
		[8]				decimal(18,2),
		[9]				decimal(18,2),
		[10]				decimal(18,2),
		[11]				decimal(18,2),
		[12]				decimal(18,2),
		[13]				decimal(18,2),
		[14]				decimal(18,2),
		[15]				decimal(18,2),
		[16]				decimal(18,2),		
		[17]				decimal(18,2),
		[18]				decimal(18,2),
		[19]				decimal(18,2),
		[20]				decimal(18,2),
		[21]				decimal(18,2),
		[22]				decimal(18,2),
		[23]				decimal(18,2),
		[24]				decimal(18,2)		

  )  
--GO	

drop table JDE_DB_Alan.FCPRO_Fcst_Accuracy_SKU

drop table JDE_DB_Alan.FCPRO_FC_Accy_SKU
CREATE TABLE JDE_DB_Alan.FCPRO_FC_Accy_SKU
   ( 
         DataType				varchar(100)    not null
		,Item					varchar(100)     not null			
		,Sales					decimal(18,2)					
		,Fcst					decimal(18,2)		
		,Date_				    datetime		not  null	
		,StartDt			    int				 
		,Bias				    decimal(18,2)
		,ABS_				   decimal(18,2)
		,ErrPct				   decimal(18,6)
		,AccuracyPct		   decimal(18,6)
		,Description		   varchar(100) 
		,Family_0			   varchar(100)
		,FamilyGroup_			varchar(100)
		,PrimarySupplier		varchar(100)
		,PlannerNumber			varchar(100)
        ,StockingType		  varchar(100)
		,FamilyGroup            varchar(100)
		,Family	            varchar(100)	
		,Leadtime_Mth			int			
		,LT_Type			  varchar(100)	
		,ReportDate		datetime default(getdate())
		--constraint PK_Item_FC primary key (ItemNumber,date)							--- Need to make your primary key unique,not null,also remember you can hv only one Primary key as well
		constraint PK_Item_FC_Accy_SKU primary key (Item,Date_,DataType,ReportDate)			  --- if there is violation of constraint yenforced & you are using RecordSet rather using CSV ( to bulk insert ) you will receive error message which is a very good thing -- 2/3/2018
																					-- Date_ is forecast period 
  )  
--GO	
alter table JDE_DB_Alan.FCPRO_Fcst_Accuracy drop constraint DF__FCPRO_Fcs__Repor__4D6A6A69



drop table JDE_DB_Alan.FCPRO_FC_Accy_Group
CREATE TABLE JDE_DB_Alan.FCPRO_FC_Accy_Group
   ( 
		DataType			varchar(100)    not null	
		,Hierarchy_0		varchar(100)    not null	
		,Hierarchy_abb		varchar(100)    not null	
		,Sls_				decimal(18,2)	
		,FC_				decimal(18,2)	
		,Bias_				decimal(18,2)	
		,Abs_				decimal(18,2)	
		,Bias_ttl			decimal(18,2)	
		,Abs_ttl			decimal(18,2)	
		,Sls_Gnd			decimal(18,2)	
		,FC_Gnd				decimal(18,2)	
		,Hierarchy_Cat		varchar	(100) 
		,Version_Lv			varchar	(100) 
		,LT_Type			varchar	(100) 
		,err1				decimal(18,4)	
		,err2				decimal(18,4)	
		,err3				decimal(18,4)	
		,acc1				decimal(18,4)	
		,acc2				decimal(18,4)	
		,acc3				decimal(18,4)	
		,Reportdate			datetime default(getdate())	
		constraint PK_Item_FC_Accy_Group primary key (DataType,Hierarchy_0,Hierarchy_Cat,ReportDate)	
   )
-- Go

exec JDE_DB_Alan.sp_FCPro_FC_Accy_Group
select * from JDE_DB_Alan.FCPRO_FC_Accy_Group
delete from JDE_DB_Alan.FCPRO_FC_Accy_Group



select * from JDE_DB_Alan.FCPRO_Fcst
select * from JDE_DB_Alan.FCPRO_Fcst_History
select * from JDE_DB_Alan.FCPRO_Fcst_History_

drop table JDE_DB_Alan.FCPRO_Fcst_History_

insert into JDE_DB_Alan.FCPRO_Fcst_History  select * from JDE_DB_Alan.FCPRO_Fcst_History_

CREATE TABLE JDE_DB_Alan.FCPRO_Fcst_History
   ( 
		FC_ID		  int not null identity (1,1) primary key,			--- seed is 1 by increment1		-- 5/3/2018
   		ItemNumber     varchar(100)  not null,
		DataType1		varchar(100),
		Date			datetime,
		Value			decimal(18,0),
		ReportDate		datetime default(getdate()),	
  )  
--GO	
ALTER TABLE MyTable ADD mytableID int NOT NULL IDENTITY (1,1) PRIMARY KEY				-- add Auto Increment
DBCC CHECKIDENT('databasename.dbo.tablename', RESEED, number)							-- Reset Auto Increment -- if number=0 then in the next insert the auto increment field will contain value 1,if number=101 then in the next insert the auto increment field will contain value 102;Actually, in order to start IDs at 1, you need to use 0: DBCC CHECKIDENT (mytable, RESEED, 0)


drop table JDE_DB_Alan.FCPRO_Fcst
CREATE TABLE JDE_DB_Alan.FCPRO_Fcst
   ( 
     
		--RowLabel		 varchar(100)    not null,
		--SellingGroup     varchar(100)	  ,
		--FamilyGroup     varchar(100)      ,
		--Family			varchar(100)      ,
		ItemNumber     varchar(100)      not null,
		--Name			varchar(255)      ,
		--Description     varchar(100)      ,
		DataType1		varchar(100)      ,
		--DataType2		varchar(100)      ,
		Date			datetime,
		Value			decimal(18,0),
		ReportDate		datetime default(getdate()),
		--constraint PK_Item_FC primary key (ItemNumber,date)							--- Need to make your primary key unique,not null,also remember you can hv only one Primary key as well
		constraint PK_Item_FC primary key (ItemNumber,date,DataType1)			--- if there is violation of constraint you enforced & you are using RecordSet rather using CSV ( to bulk insert ) you will receive error message which is a very good thing -- 2/3/2018
  )  

--GO	

create index idx_Item on JDE_DB_Alan.FCPRO_Fcst (ItemNumber,date)
drop index idx_Item on JDE_DB_Alan.FCPRO_Fcst

create index idx_fc on JDE_DB_Alan.FCPRO_Fcst (ItemNumber,date)
drop index idx_fc on JDE_DB_Alan.FCPRO_Fcst

--create index i_fc on JDE_DB_Alan.FCPRO_Fcst (SellingGroup,FamilyGroup,Family,ItemNumber,date)
ALTER TABLE JDE_DB_Alan.FCPRO_Fcst ADD ReportDate datetime ;
ALTER TABLE JDE_DB_Alan.FCPRO_Fcst ADD constraint DF_Date default getdate() for ReportDate


ALTER TABLE JDE_DB_Alan.FCPRO_Fcst drop column ReportDate;
alter table JDE_DB_Alan.FCPRO_Fcst drop constraint [DF__FCPRO_Fcs__Repor__3FD07829]
select GETDATE()



drop table JDE_DB_Alan.SlsHist_Excp_FCPro_upload
CREATE TABLE JDE_DB_Alan.SlsHist_Excp_FCPro_upload
(       

		ItemNumber			varchar(100)      not null,
		Description			varchar(100) , 
		Date				int not null,		
		Value_Sls_Old		decimal(18,12),	
		Value_Sls_Adj		decimal(18,12),
		ValidStatus			varchar(100),						-- if valid then active , for record keeping purpose	
		Date_Updated		datetime,		
		ReportDate			datetime default(getdate()),
		Index_Row_Number    bigint

		constraint PK_Item_Sls_Excp primary key (ItemNumber,Date,Date_Updated,ValidStatus)						-- deliberatly remove Reportdate as constrain, so do not allow same day data 
		-- constraint PK_Item_Sls_Excp primary key (ItemNumber,Date,Date_Updated,ReportDate,ValidStatus)     	
)


----- Recover Accidently deleted View or Store procedure ------ 15/6/2020
SELECT  Convert(varchar(Max),Substring([RowLog Contents 0],33,LEN([RowLog Contents 0]))) as [Script] 
FROM fn_dblog(DEFAULT, DEFAULT) 
Where [Operation]='LOP_DELETE_ROWS' And [Context]='LCX_MARK_AS_GHOST' And [AllocUnitName]='sys.sysobjvalues.clst'


select * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload l where l.ItemNumber in ('26.132.0204')
select count(*) from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload
drop table JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload
CREATE TABLE JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload				-- updated 1/3/2018 -- force almost all field not accepting null value, add primary key and index
   ( 
     RowLabel			varchar(100) NOT NULL,	 
	 SellingGroup		varchar(100) not null,  
	 FamilyGroup		varchar(100) not null,  
	 Family				varchar(100) not null, 
	 ItemNumber		    varchar(100) NOT NULL, 	
	 Description		varchar(100) , 
	 CY					int ,
	 Month				int ,
	 PPY				int ,
	 PPC				int ,
	 CYM				int not null,
	 SalesQty			decimal,
	 SalesQty_Adj		decimal,
	 ValidStatus		varchar(100),	 
	 ReportDate			datetime,

	 constraint PK_Item_Sls primary key (ItemNumber,CYM,ValidStatus)					----- if there is violation of constraint you enforced & you are using RecordSet rather using CSV ( to bulk insert ) you will receive error message which is a very good thing -- 2/3/2018
  )  
--GO	
create clustered index idx_Item on JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload (ItemNumber,CYM)        -- No need to As per Default setting in SQL Server Clustered Index already created using Primary Key. If you go ahead with this command you will receive error message --> Cannot create more than one clustered index on table 'JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload'. Drop the existing clustered index 'PK_Item' before creating another. -- 1/3/2018
--https://stackoverflow.com/questions/2878272/when-should-i-use-primary-key-or-index
--1. Column(s) that make the Primary Key of a table cannot be NULL since by definition, the Primary Key cannot be NULL since it helps uniquely identify the record in the table. The column(s) that make up the unique index can be nullable. A note worth mentioning over here is that different RDBMS treat this differently –> while SQL Server and DB2 do not allow more than one NULL value in a unique index column, Oracle allows multiple NULL values. That is one of the things to look out for when designing/developing/porting applications across RDBMS.
--2. There can be only one Primary Key defined on the table where as you can have many unique indexes defined on the table (if needed).
--3. Also, in the case of SQL Server, if you go with the default options then a Primary Key is created as a clustered index while the unique index (constraint) is created as a non-clustered index. This is just the default behavior though and can be changed at creation time, if needed.


drop table JDE_DB_Alan.Px_AWF_HD_MT_FCPro_upload
CREATE TABLE JDE_DB_Alan.Px_AWF_HD_MT_FCPro_upload				-- updated 1/3/2018 -- force almost all field not accepting null value, add primary key and index
   ( 
      RowLabel			varchar(100) NOT NULL	 
	 ,SellingGroup		varchar(100) not null  
	 ,FamilyGroup		varchar(100) not null  
	 ,Family			varchar(100) not null 
	 ,ItemNumber		varchar(100) NOT NULL 		
	 ,StandardCost		decimal(18,6)	
	 ,WholeSalePrice	decimal(18,6)
	 ,rnk				int	    
	 ,ReportDate		datetime											--- Need to make your primary key unique,not null,also remember you can hv only one Primary key as well
	 constraint PK_Item_Sls_Px primary key (ItemNumber)					--- if there is violation of constraint you enforced & you are using RecordSet rather using CSV ( to bulk insert ) you will receive error message which is a very good thing -- 2/3/2018
  )  
--GO	

create clustered index idx_Item on JDE_DB_Alan.Px_AWF_HD_MT_FCPro_upload (ItemNumber)


CREATE TABLE JDE_DB_Alan.SlsHistoryAWF_HD_MT
   ( 
     BU					varchar(100) NOT NULL,	 
	 ShortItemNumber	varchar(100) NOT NULL,  
	 ItemNumber			varchar(100) NOT NULL, 				-- 2nd ItemNumber	
	 Century			int NOT NULL,  		 		 
	 FinancialYear		int NOT NULL, 	
	 FinancialMonth		int NOT NULL, 	
	 DocumentType		varchar(100) NOT NULL,
	 Quantity			decimal ,	
	 UOM				varchar(100) NOT NULL 	    
  )  
--GO	

CREATE TABLE JDE_DB_Alan.SlsHistoryAWF  
   ( 
     BU					varchar(100) NOT NULL, 
     ShortItemNumber	varchar(100) NOT NULL, 
	 ItemNumber			varchar(100) NOT NULL, 				-- 2nd ItemNumber
	 Century			int NOT NULL,  		 		 
	 FinancialYear		int NOT NULL, 	
	 FinancialMonth		int NOT NULL, 	
	 DocumentType		varchar(100) NOT NULL,
	 Quantity			decimal ,	
	 UOM				varchar(100) NOT NULL 	    
  )  
--GO	

CREATE TABLE JDE_DB_Alan.SlsHistoryHD  
   ( 
     BU				varchar(100) NOT NULL, 
     ShortItemNumber	varchar(100) NOT NULL, 
	 ItemNumber		varchar(100) NOT NULL, 				-- 2nd ItemNumber
	 Century		int NOT NULL,  		 		 
	 FinancialYear	int NOT NULL, 	
	 FinancialMonth	int NOT NULL, 	
	 DocumentType	varchar(100) NOT NULL, 
	 Quantity		decimal,	
	 UOM			varchar(100) NOT NULL 	    
  )  
--GO	

CREATE TABLE JDE_DB_Alan.SlsHistoryMT
   ( 
     BU				varchar(100) NOT NULL, 
	 
	 ShortItemNumber	varchar(100) NOT NULL, 
	 ItemNumber		varchar(100) NOT NULL, 				-- 2nd ItemNumber
	-- StockType		varchar(100) NOT NULL, 
	 Century		int NOT NULL,  		 		 
	 FinancialYear	int NOT NULL, 	
	 FinancialMonth	int NOT NULL, 	
	 DocumentType	varchar(100) NOT NULL,
	 Quantity		decimal ,	
	 UOM			varchar(100) NOT NULL 	    
  )  
--GO	

CREATE TABLE JDE_DB_Alan.SlsHistoryRM
   ( 
     BU				varchar(100) NOT NULL, 	 
	 ShortItemNumber	varchar(100) NOT NULL, 
	 ItemNumber		varchar(100) NOT NULL, 				-- 2nd ItemNumber
	-- StockType		varchar(100) NOT NULL, 
	 Hierarchy			varchar(100), 
	 GLCategory			varchar(100),		
	 SalesChannel		varchar(100),
	 Century		int NOT NULL,  		 		 
	 FinancialYear	int NOT NULL, 	
	 FinancialMonth	int NOT NULL, 	
	 DocumentType	varchar(100) NOT NULL,
	 Quantity		decimal ,	
	 UOM			varchar(100) NOT NULL 	    
  )  
--GO



drop table JDE_DB_Alan.StkAvailability
CREATE TABLE JDE_DB_Alan.StkAvailability
   ( 
    Short_Item_No                    char(100),
	Business_Unit                    char(100),
	Location_                        char(100),
	Lot_Serial_Number                int,
	Primary_Location                 char(100),
	Lot_Stat_Code                    char(100),
	QTY_On_Hand                      decimal(18,2),
	QTY_Backordered                  decimal(18,2),
	QTY_On_PO                      decimal(18,2),
	QTY_On_WO_RC                     decimal(18,2),
	QTY_On_other_1                   decimal(18,2),
	QTY_On_Other_2                   decimal(18,2),
	QTY_on_Other_PO                  decimal(18,2),
	QTY_Hard_Committed               decimal(18,2),
	Qty_Soft_Committed               decimal(18,2),
	QTY_On_Future                    decimal(18,2),
	WO_Soft_Commit                   decimal(18,2),
	Qty_Hard_Committed_WO            decimal(18,2),
	QTY_In_Transit                   decimal(18,2),
	QTY_In_Inspection                decimal(18,2),
	QTY_In_Operation_1               decimal(18,2),
	QTY_In_Operation_2               decimal(18,2),
	Last_Rcpt_Date                   datetime,
	--_2nddry_QTY_Hard_Committed        decimal(18,2),
	--_2nddry_QTY_Soft_Committed        decimal(18,2),
	--_2nddry_QTY_On_Hand               decimal(18,2),
	--_2nddry_QTY_On_WO_RC              decimal(18,2),
	--_2nddry_QTY_On_Purchase_Order     decimal(18,2),
	--_2nddry_WO_Hard_Committed         decimal(18,2),
	--_2nddry_WO_Soft_Commit            decimal(18,2),
	--QTY_on_Project_Hard_Commit1       decimal(18,2),
	--QTY_on_Project_Hard_Commit2       decimal(18,2),
	--Unique_Configuration_ID           int
	Reportdate						  datetime default(getdate())

  )  
--GO	

ALTER TABLE JDE_DB_Alan.StkAvailability
ADD Reportdate datetime;

drop table JDE_DB_Alan.OpenPO
CREATE TABLE JDE_DB_Alan.OpenPO
   ( 
		 ItemNumber					varchar(100)				
		,OrderNumber				varchar(100) 		
		,QuantityOrdered			decimal(18,2)
		,QuantityReceived			decimal(18,2)
		,QuantityOpen				decimal(18,2)
		,OrderDate					datetime		
		,ExSupplierShipDate			datetime
		,DueDate					datetime  
		,InTransitDays				decimal(18,2)		
		,BuyerNumber				varchar(100)		
		,BuyerName					varchar(100)
		,TransactionOriginator		varchar(100)
		,TransactionOrigName		varchar(100)
		,SupplierNumber				varchar(100)
		,SupplierName				varchar(100)
		,ShipmentNumber			varchar(100)
		,ShpSts					varchar(100)
		,ShipStatus				varchar(100)	
		,Reportdate			  datetime default(getdate())
		--,CONSTRAINT PK_Item_PO PRIMARY KEY (ItemNumber,OrderNumber,QuantityOrdered,DueDate)

   )
ALTER TABLE JDE_DB_Alan.OpenPO ADD CONSTRAINT PK_Item_PO PRIMARY KEY (ItemNumber,OrderNumber,QuantityOrdered,DueDate);
ALTER TABLE JDE_DB_Alan.OpenPO ADD OpenPOID int NOT NULL IDENTITY (1,1) PRIMARY KEY	



drop table JDE_DB_Alan.TestWO
CREATE TABLE JDE_DB_Alan.TestWO
   ( 
		 TestWO_ID		  int not null identity (1,1) primary key			--- seed is 1 by increment1		-- 22/10/2018
		,ItemNumber					varchar(100)				
		,OrderQuantity				decimal(18,2)			
		,UM							varchar(100)
		,Customer					varchar(100)		
		,RequestDate				datetime
		,ComponentBranch			varchar(100)
		,WONumber					varchar(100) 		
		,Reportdate			  datetime default(getdate())
   )



delete from JDE_DB_Alan.TestCO
drop table JDE_DB_Alan.TestCO
CREATE TABLE JDE_DB_Alan.TestCO
   ( 
		 TestCO_ID					 int not null identity (1,1) primary key			--- seed is 1 by increment1		-- 22/10/2018
		,OrderNumber				varchar(100)
		,LineNumber					int			
		,BranchPlant			   varchar(100)	
		,RelatedWONum              varchar(100)	
		,RelatedWOType             varchar(100) 
		,Customer					varchar(100)		
		,CustomerName				 varchar(100)
		,CustomerSub				 varchar(100)
		,EnterDate					datetime		
		,SchdPickDate				datetime
		,OrigPromiseDate			datetime
		,PromiseDelDate				datetime
		,CO_Name						varchar(100)		
		,ItemNumber					varchar(100)	
		,ItemDescription			varchar(100)		
		,SlsCd1						varchar(100)	
		,SlsCd2						varchar(100)		
		,SlsCd3						varchar(100)	
		,SlsCd4						varchar(100)	
		,OrderQty					decimal(18,2)
		,PrimaryUOM				    varchar(100)
		,ListPrice				    decimal(18,2)	
		,ExtPrice					decimal(18,2)
		,Buyer						varchar(100)	
		,WOStartDate				datetime
		,WOFinishDate				datetime
		,Brand						varchar(100)
		,StateCode1					varchar(100)
		,StateCode2					varchar(100)
		,OrderTakenBy				varchar(5000)
		,Reportdate					datetime default(getdate())
   )


--- 29/3/2019 ---		

drop table JDE_DB_Alan.TesTSO											
CREATE TABLE [JDE_DB_Alan].[SO_Inquiry]
(
	[Order_Number]				[varchar](100) NULL,
	[Order_Type]				[varchar](100) NULL,
	[Order_Co]					[varchar](100) NULL,
	[Line_Number]				[int] NULL,
	[Hold_Code]					[varchar](100) NULL,
	[Sold_To]					[varchar](100) NULL,
	[Sold_To_Name]				[varchar](100) NULL,
	[Second_Item_Number]		[varchar](100) NULL,
	[Description_1]				[varchar](100) NULL,
	[Quantity]					[decimal](18, 2) NULL,
	[UOM]						[varchar](100) NULL,
	[Secondary_Quantity]		[decimal](18, 2) NULL,
	[Secondary_UOM]				[varchar](100) NULL,
	[Requested_Date]			[datetime] NULL,
	[Last_Status]				[decimal](18, 2) NULL,
	[Last_Status_Desc]			[varchar](100) NULL,
	[Next_Status]				[decimal](18, 2) NULL,
	[Next_Status_Desc]			[varchar](100) NULL,
	[Customer_PO]				[varchar](100) NULL,
	[Ship_To]					[varchar](100) NULL,
	[Ship_To_Description]		[varchar](100) NULL,
	[Third_Item_Number]			[varchar](100) NULL,
	[Parent_Number]				[varchar](100) NULL,
	[Agreement_Number]			[varchar](100) NULL,
	[Shipment_Number]			[varchar](100) NULL,
	[Pick_Number]				[varchar](100) NULL,
	[Delivery_Number]			[varchar](100) NULL,
	[Unit_Price]				[decimal](18, 2) NULL,
	[Extended_Amount]			[decimal](18, 2) NULL,
	[Pricing_UOM]				[decimal](18, 2) NULL,
	[Foreign_Unit_Price]		[decimal](18, 2) NULL,
	[Foreign_Extended_Amount]	[decimal](18, 2) NULL,
	[Trans_Currency]			[varchar](100) NULL,
	[Order_Date]				[datetime] NULL,
	[Short_Item_No]				[varchar](100) NULL,
	[Ord_Suf]					[varchar](100) NULL,
	[Document_Number]			[varchar](100) NULL,
	[Doument_Type]				[varchar](100) NULL,
	[Document_Company]			[varchar](100) NULL,
	[Scheduled_Pick_Date]		[datetime] NULL,
	[Scheduled_Pick_Time]		[datetime] NULL,
	[Original_Promised_Date]	[datetime] NULL,
	[Original_Promised_Time]	[datetime] NULL,
	[Actual_Ship_Date]			[datetime] NULL,
	[Actual_Ship_Time]			[datetime] NULL,
	[Invoice_Date]				[datetime] NULL,
	[Cancel_Date]				[datetime] NULL,
	[GL_Date]					[datetime] NULL,
	[Promised_Delivery_Date]	 [datetime] NULL,
	[Promised_Delivery_Time]	 [datetime] NULL,
	[Business_Unit]				[varchar](100) NULL,
	[Line_Type]					[varchar](100) NULL,
	[Sls_Cd1]					[varchar](100) NULL,
	[Sls_Cd2]					[varchar](100) NULL,
	[Sls_Cd3]					[varchar](100) NULL,
	[Sls_Cd4]					[varchar](100) NULL,
	[Sls_Cd5]					[varchar](100) NULL,
	[Exchange_Rate]				[decimal](18, 2) NULL,
	[Base_Currency]				[varchar](100) NULL,
	[Quantity_Ordered]			[decimal](18, 2) NULL,
	[Quantity_Shipped]			[decimal](18, 2) NULL,
	[Quantity_Backordered]		[decimal](18, 2) NULL,
	[Quantity_Canceled]			[decimal](18, 2) NULL,
	[Price_Effective_Date]		[datetime] NULL,
	[Unit_Cost]					[decimal](18, 2) NULL,
	[Foreign_Unit_Cost]			[decimal](18, 2) NULL,
	[Adjustment_Schedule]		[varchar](100) NULL,
	[Transaction_Originator]	 [varchar](100) NULL,
	[ReportDate]				[datetime] NULL
) ON [PRIMARY]
GO


drop table JDE_DB_Alan.SO_Inquiry_Super											
CREATE TABLE [JDE_DB_Alan].[SO_Inquiry_Super]
(
	 Order_Number               varchar(100) null
	,Or_Ty						varchar(100) null
	,Do_Ty						varchar(100) null
	,Business_Unit				varchar(100) null
	,Item_Number				varchar(100) null
	,Ship_To_Number				varchar(100) null
	,Address_Number				varchar(100) null
	,UM_UM						varchar(100) null
	,PR_UM						varchar(100) null
	,Qty_Ordered				decimal(18,2) null
	,Request_Date				datetime null
	,Order_Date					datetime null
	,Invoice_Date				datetime null
	,Qty_Ordered_LowestLvl		decimal(18,2) null
	,GL_Date					datetime null
	,Reference					varchar(500) null
	
	,LastStatus					decimal(18,2) null
	,NextStatus					decimal(18,2) null
	,Cd2_FamilyGroup			varchar(100) null	
	,Cd3_Family					varchar(100) null

	,Unit_Cost					decimal(18,2) null
	,Unit_Price					decimal(18,2) null
	,Extended_Cost				decimal(18,2) null
	,Extended_Price				decimal(18,2) null
	,Document_Number			varchar(100) null
	,Primary_Supplier			varchar(100) null
	,Buyer_Number				varchar(100) null
	,Transaction_Originator		varchar(100) null
	,Unit_List_Price			decimal(18,2) null
	,ReportDate					[datetime] NULL

) ON [PRIMARY]
GO



drop table JDE_DB_Alan.TextileFC
CREATE TABLE JDE_DB_Alan.TextileFC
(
    -- TextileFC_ID		 int not null identity (1,1) primary key			--- seed is 1 by increment1		-- 21/06/2019
	-- [TextileFC_ID]	[int] IDENTITY(1,1) NOT NULL,
	ArticleNumber				varchar(100) ,
	ArticleDescription			varchar(100) ,
	Vendor						varchar(100) ,
	Date						int ,
	Quantity					decimal(18, 0) NULL,
	ArticleUOM					varchar(100) nuLL,
	Reportdate					datetime ,

	constraint PK_Textile_FC primary key (ArticleNumber,date,Reportdate)	
   )



select * from JDE_DB_Alan.Textile_ItemCrossRef
drop table JDE_DB_Alan.Textile_ItemCrossRef
CREATE TABLE JDE_DB_Alan.Textile_ItemCrossRef
   ( 
		--TextileItemCrossRef_ID		  int not null identity (1,1) primary key			--- seed is 1 by increment1		-- 22/10/2018
		SupplierItemNumber			  varchar(100)	
		,HDItemNumber			     varchar(100)				
		,UpdateDate					 datetime default(getdate())
		,comments                    varchar(2000)
		constraint PK_Textile_ItemCrossRef primary key (SupplierItemNumber,UpdateDate)	
   )



--=============================== Data --==============================================================
-------------------------- bulk insert for Master Data ---------------------------------------------
select count(a.StandardCost) from JDE_DB_Alan.Master_ML345 a where a.WholeSalePrice is null
select a.ItemNumber,count(a.Description) 
from JDE_DB_Alan.Master_ML345 a 
group by a.ItemNumber
order by count(a.Description)  desc

select * from JDE_DB_Alan.Master_ML345 a
--where a.WholeSalePrice=0 and a.StandardCost =0
where  a.StandardCost =0
order by a.WholeSalePrice

select * from JDE_DB_Alan.Master_ML345 a
--where a.WholeSalePrice=0 and a.StandardCost =0
where a.StandardCost =0
order by a.WholeSalePrice

update JDE_DB_Alan.Master_ML345 
set WholeSalePrice = StandardCost
where WholeSalePrice = 0 


;update p
set p.WholeSalePrice =0.01,p.StandardCost =0.01
from JDE_DB_Alan.Master_ML345 p
where WholeSalePrice = 0 and p.StandardCost =0
----------------------------------------------------------------------------
--- some check delibertly change cost value to Null see if code works ---
;update p
set p.StandardCost = null
from JDE_DB_Alan.Master_ML345 p
where p.ShortItemNumber = '100722'

;update p
set p.WholeSalePrice = null
from JDE_DB_Alan.Master_ML345 p
where p.ShortItemNumber = '100714'
---------------------------------------------------------------------
--- some check delibertly change description value to have comma see if code works ---
;update p
set p.Description = 'Cold Rolled,Steel, 0.50-0.59'
from JDE_DB_Alan.Master_ML345 p
where p.ShortItemNumber = '852764'

;update p
set p.WholeSalePrice= ( case 
								when p.WholeSalePrice = 0 or p.WholeSalePrice is null then
									(case 
											when p.StandardCost=0 or p.StandardCost is null then 0.01
											else p.StandardCost 
											end)							 
								else p.WholeSalePrice
								end )
	,p.StandardCost= ( case 
								when p.StandardCost = 0 or p.StandardCost is null then
									(case 
											when p.WholeSalePrice=0 or p.WholeSalePrice is null then 0.01
											else p.WholeSalePrice 
											end)							 
								else p.StandardCost
								end )
	,p.Description =( case 
							 when CHARINDEX(',',p.Description) >0 then REPLACE(p.Description,',','/')
								 else p.Description
								 end )
								 										
from JDE_DB_Alan.Master_ML345 p 
--where p.ShortItemNumber in ('806215')
where p.ShortItemNumber in( '806215','703689','703654','1129640','852764','1351435','825328','102226','533704')
--where a.StandardCost =0 and a.WholeSalePrice =0
--where a.WholeSalePrice =0
--where a.WholeSalePrice is null
order by p.WholeSalePrice



--------- Update Mastter Price table,this works !!! ---------------------------- The process take price info from R55ML345 Table -- 17/10/2017
--------- And Get Price for Unique Item from this Table -------------------------
--- this DataSet however does not have Hierarchy info though !---------

 select * from JDE_DB_Alan.MasterPrice a where a.ShortItemNumber in ('1374362')
  select * from JDE_DB_Alan.MasterPrice a where a.WholeSalePrice =0

  --- First Need to delete old price first !!! -----
 delete from JDE_DB_Alan.MasterPrice   

 select * from JDE_DB_Alan.Master_ML345 a where a.ItemNumber like ('%28.164.000')
  select * from JDE_DB_Alan.Master_ML345 a where a.ShortItemNumber like ('959676')
select * from JDE_DB_Alan.SalesHistoryHDAWF a where a.ItemNumber in ('28.164.000B')

 --- First Get Price for all Items include duplicate Items ( but with unique ShortItems ) ---

with temp as (

	select 'Total' as RowLabels,SellingGroup,FamilyGroup,Family,ItemNumber,ShortItemNumber,StandardCost,WholeSalePrice 
	from (
	      (select distinct ShortItemNum from JDE_DB_Alan.SalesHistoryHDAWF)  a 
		    left join (  
				select b.ShortItemNumber,b.ItemNumber,b.SellingGroup,b.FamilyGroup,b.Family,b.StandardCost,b.WholeSalePrice
				from JDE_DB_Alan.Master_ML345 b   )  c
				on a.ShortItemNum =c.ShortItemNumber 
   ) 
      
 )

 select * from temp where temp.ShortItemnumber in ('1239574')

 --- then Get Price for Unique Item from this Table ---
 cte as  (
	select *, row_number() over(partition by temp.itemnumber order by itemnumber ) rownumber
	 from temp
 --where a.ItemNumber in ('24.023.165S','7.51E+11')
  ), 

 flprice as (
 select 'Total' as RowLabels,cte.SellingGroup,cte.FamilyGroup,cte.Family
		,ltrim(rtrim(cte.Itemnumber)) as Itemnumber_,cte.StandardCost,cte.WholeSalePrice
   from cte        
 -- where rownumber > 1
    where rownumber =1
 -- order by cte.itemnumber,rownumber desc 
    )

select flprice.RowLabels
		,d.LongDescription as SellingGroup_
		,e.LongDescription as FamilyGroup_
		,f.LongDescription as Family_0
		,flprice.Itemnumber_
		,flprice.StandardCost
		,flprice.WholeSalePrice
			
from flprice left join JDE_DB_Alan.MasterSellingGroup d  on flprice.SellingGroup = d.Code
         left join JDE_DB_Alan.MasterFamilyGroup e  on flprice.FamilyGroup = e.Code
		 left join JDE_DB_Alan.MasterFamily f  on flprice.Family = f.Code
where flprice.Itemnumber_ in ('28.164.000B')


insert into JDE_DB_Alan.MasterPrice  select * from flprice 
drop table flprice

select * from JDE_DB_Alan.MasterPrice
----------- END OF Update Master Price Table -----------------------

 ----- Some snippet code to check price ---
 --- Get duplicate row for Master price table  ---
 select a.ItemNumber, count(a.RawLabel) cnt
 from JDE_DB_Alan.MasterPrice a
 group by a.ItemNumber
 order by cnt desc


 --- olap function for Price Table---
 with cte as (
 select *, row_number() over(partition by a.itemnumber order by itemnumber ) rownumber
 from JDE_DB_Alan.MasterPrice a 
 --where a.ItemNumber in ('24.023.165S','7.51E+11')
  )

 select cte.RawLabel,cte.SellingGroup,cte.FamilyGroup,cte.Family,ltrim(rtrim(cte.Itemnumber)),cte.StandardCost,cte.WholeSalePrice
   from cte 
  where rownumber =1
  where rownumber >1

--------- Endof Update Mastter Price table,this works !!! ---------------------------- 
--------- End of And Get Price for Unique Item from this Table -------------------------
----------- END OF Get Price for Unique Items in Price Table -----------------------

select * from JDE_DB_Alan.MasterFamilyGroup
select * from JDE_DB_Alan.Textile_ItemCrossRef
select * from JDE_DB_Alan.Master_V4102A m where m.Item_Number in ('52.008.104')

delete from JDE_DB_Alan.StkAvailability
select * from JDE_DB_Alan.MasterMTLeadingZeroItemList a
select * from JDE_DB_Alan.Master_ML345 a where a.ShortItemNumber in ('1074571')
delete from JDE_DB_Alan.Master_ML345
delete from JDE_DB_Alan.MasterFamily
delete from JDE_DB_Alan.MasterFamilyGroup
delete fJDE_DB_Alan.Master_V4102Arom JDE_DB_Alan.MasterMTLeadingZeroItemList 
delete from JDE_DB_Alan.MasterSupplier
delete from JDE_DB_Alan.Textile_ItemCrossRef
delete from 

--bulk insert JDE_DB_Alan.JDE_Fcst
--bulk insert JDE_DB_Alan.Master_ItemCrossRef
--BULK INSERT JDE_DB_Alan.MasterSellingGroup
 --BULK INSERT JDE_DB_Alan.MasterFamilyGroup
 --BULK INSERT JDE_DB_Alan.MasterFamily
 --BULK INSERT JDE_DB_Alan.Master_ML345
 -- BULK INSERT JDE_DB_Alan.Textile_ItemCrossRef
 --BULK INSERT JDE_DB_Alan.MasterSupplier
--BULK INSERT JDE_DB_Alan.Master_UOMConversion
-- BULK INSERT JDE_DB_Alan.Master_ML345
-- BULK INSERT JDE_DB_Alan.MasterPrices
--  BULK INSERT JDE_DB_Alan.MasterMTSuperssionItemList
 --BULK INSERT JDE_DB_Alan.MasterMTLeadingZeroItemList
  BULK INSERT JDE_DB_Alan.Master_V4102A
    --  from 'C:\Alan_GWA_C\Work\ImportData.csv'
    -- from 'E:\ImportDataa.txt'

  -- from 'C:\Users\yaoa\Alan_HD\Alan_Work\HD_IT_DB\FC_Input\HD_Branch\JDE_Master_Data_Download\Master_V4102A\Master_JDE_Item_Branch_V4102A_Template.csv'
     from  'C:\Users\yaoa\Alan_HD\Alan_Work\HD_IT_DB\FC_Input\HD_Branch\JDE_Master_Data_Download\Master_V4102A\test.txt'

-- from 'C:\Users\yaoa\Alan_HD\Alan_Work\HD_IT_DB\FC_Input\HD_Branch\JDE_Master_Data_Download\Master_R55ML345.csv'
 --  from 'T:\Forecast Pro\Forecast Pro TRAC\Input\HD Branch Plant\archive\Master_Hierarchy_ETC\Master_R55ML345_HD_2017_11_CSV.csv'			-- use this one
    -- from 'C:\Users\yaoa\Alan_HD\Alan_Work\HD_IT_DB\FC_Input\HD_Branch\JDE_Master_Data_Download\Master_R55ML345_z.csv'
	-- from 'C:\Users\yaoa\Alan_HD\Alan_Work\HD_DemandPlanning\FC_Change\HD_Market_Intelligence\Market_Intelligence_Raw_Data\Raw_Data\Textile_Export_Forecast\Textile_FC_ProductCode_Cross_Reference_Master.csv'
   -- from 'C:\Users\yaoa\Alan_HD\Alan_Work\HD_IT_DB\FC_Input\HD_Branch\JDE_Master_Data_Download\Textile_FC_ProductCode_Cross_Reference_Master.csv'
   -- from 'C:\Users\yaoa\Alan_HD\Alan_Work\HD_IT_DB\FC_Input\HD_Branch\JDE_Master_Data_Download\Master_Item_Cross_Ref.csv'
 -- from 'T:\Forecast Pro\Forecast Pro TRAC\Input\HD Branch Plant\archive\Master_Hierarchy_ETC\Master_Description_Hierarchy_SKU_Level_CSV.csv'   
  -- from 'T:\Forecast Pro\Forecast Pro TRAC\Input\HD Branch Plant\archive\Master_Hierarchy_ETC\HierarchyMaster_SellingGroup_CSV.csv'
   -- from 'T:\Forecast Pro\Forecast Pro TRAC\Input\HD Branch Plant\archive\Master_Hierarchy_ETC\HierarchyMaster_FamilyGroup_CSV.csv'
  --   from 'C:\Users\yaoa\Alan_HD\Alan_Work\HD_IT_DB\FC_Input\HD_Branch\Master_Hierarchy_ETC\HierarchyMaster_FamilyGroup_CSV_new.csv'
  --  from 'T:\Forecast Pro\Forecast Pro TRAC\Input\HD Branch Plant\archive\Master_Hierarchy_ETC\HierarchyMaster_Family_CSV.csv'
  --  from 'C:\Users\yaoa\Alan_HD\Alan_Work\HD_IT_DB\FC_Input\HD_Branch\Master_Hierarchy_ETC\HierarchyMaster_Family_CSV.csv'
  --  from 'C:\Users\yaoa\Alan_HD\Alan_Work\HD_IT_DB\FC_Input\HD_Branch\JDE_Master_Data_Download\Supplier_Summary.csv'

  --    from 'C:\Users\yaoa\Alan_HD\Alan_Work\HD_IT_DB\FC_Input\HD_Branch\JDE_Master_Data_Download\Master_Vendor.csv'
	  -- from 'C:\Users\yaoa\Alan_HD\Alan_Work\HD_IT_DB\FC_Input\HD_Branch\JDE_Master_Data_Download\UOM_Conversion.csv'
--	 from 'T:\Forecast Pro\Forecast Pro TRAC\Input\HD Branch Plant\archive\Master_Hierarchy_ETC\Report_HD_Conversions_CSV.csv'
 -- from 'T:\Forecast Pro\Forecast Pro TRAC\Input\HD Branch Plant\archive\Master_Hierarchy_ETC\Master_Bricos_MT_SuperssionItems_CSV.csv'
  --from 'T:\Forecast Pro\Forecast Pro TRAC\Input\HD Branch Plant\archive\Master_Hierarchy_ETC\Master_Bricos_MT_LeadingZeroItems_CSV_.csv'
   -- from 'T:\Forecast Pro\Forecast Pro TRAC\Input\HD Branch Plant\archive\JDE_Master_Data_Download\Master_Item_Cross_Ref_16_01_2018.csv'
	--from 'T:\Forecast Pro\Forecast Pro TRAC\Input\HD Branch Plant\archive\JDE_Transaction_Data_Download\Jde_FC_Downloaded_Template_CSV.csv'
	with  (
        --   Fieldteminator='',
        --   Rowteminator ='\n',
      --  DATAFILETYPE = 'widechar',    
        FIELDTERMINATOR =',',
		--FIELDTERMINATOR ='~',
        ROWTERMINATOR = '\n',
        FIRSTROW =2     			
			) 


-------------------- bulk insert for Transaction Data ------------------------
truncate table JDE_DB_Alan.SalesHistoryHDAWF
delete from JDE_DB_Alan.HistoryMTB4Superssion
delete from JDE_DB_Alan.SalesHistoryHDAWF
delete from JDE_DB_Alan.SalesHistoryHD
delete from JDE_DB_Alan.SalesHistoryMT
delete from JDE_DB_Alan.FCPRO_Fcst

select * from JDE_DB_Alan.SalesHistoryHDAWF
select distinct a.DocumentType from JDE_DB_Alan.SalesHistoryHDAWF a

select a.ShortItemNum,a.Century,a.FinancialYear,a.FinancialMonth,count(a.ItemNumber) SKUCount
 from JDE_DB_Alan.SalesHistoryHDAWF a
 group by a.ShortItemNum,a.Century,a.FinancialYear,a.FinancialMonth
 order by SKUCount desc

 select a.ItemNumber,a.Century,a.FinancialYear,a.FinancialMonth,count(a.ItemNumber) SKUCount
 from JDE_DB_Alan.SalesHistoryHDAWF a
 group by a.ItemNumber, a.ShortItemNum,a.Century,a.FinancialYear,a.FinancialMonth
 order by SKUCount desc

 select * from JDE_DB_Alan.SalesHistoryMT a where a.ShortItemNum in ('1074571')
 select * from JDE_DB_Alan.SalesHistoryHD a where a.Century in ('20') and a.FinancialYear in ('17') and a.FinancialMonth in ('10')

select count(*) TTL_Record, count(distinct x.ItemNumber) TTL_UniqueItem from JDE_DB_Alan.FCPRO_Fcst x where x.DataType1 in ('Point forecasts')
 select * from JDE_DB_Alan.FCPRO_Fcst x where x.DataType1 in ('Point forecasts') and  x.ItemNumber in ('2851218661') 
 select 247320*2

 select * from JDE_DB_Alan.SlsHist_Excp_FCPro_upload
 delete from JDE_DB_Alan.FCPRO_Fcst
 delete from JDE_DB_Alan.FCPRO_NP_tmp
 delete from JDE_DB_Alan.FCPRO_MI_tmp
 delete from JDE_DB_Alan.SlsHist_Excp_FCPro_upload

 --Bulk insert JDE_DB_Alan.FCPRO_Fcst_downloaded
 --bulk insert JDE_DB_Alan.StkAvailability
 -- BULK INSERT JDE_DB_Alan.SalesHistoryHDAWF
--BULK INSERT JDE_DB_Alan.SalesHistoryAWFtop
 -- BULK INSERT JDE_DB_Alan.HistoryMTB4Superssion 
  -- BULK INSERT JDE_DB_Alan.SlsHistoryMT
  --BULK INSERT JDE_DB_Alan.SlsHistoryHD
   -- Bulk insert JDE_DB_Alan.FCPRO_Fcst
  --  Bulk insert JDE_DB_Alan.SlsHistoryRM
	--Bulk insert JDE_DB_Alan.SlsHist_Excp_FCPro_upload
	--Bulk insert JDE_DB_Alan.FCPRO_SafetyStock_Excp
	Bulk insert JDE_DB_Alan.PO_All_Staging

 -- bulk insert JDE_DB_Alan.FCPRO_NP_tmp
 -- bulk insert JDE_DB_Alan.FCPRO_MI_tmp
    --  from 'C:\Alan_GWA_C\Work\ImportData.csv'
    -- from 'E:\ImportDataa.txt'       
     -- from 'T:\Forecast Pro\Forecast Pro TRAC\Input\HD Branch Plant\archive\FC_Raw_Data\HD_Sales_MT_History6_Excel_SuperssioRawData_CSV.csv'
   --from 'T:\Forecast Pro\Forecast Pro TRAC\Input\HD Branch Plant\archive\FC_Raw_Data\RI transactions MT since Jan15_CSV.csv'
  --from 'T:\Forecast Pro\Forecast Pro TRAC\Input\HD Branch Plant\archive\FC_Raw_Data\RI transactions HD since Jan15_CSV.csv'
  --from 'C:\Users\yaoa\Alan_HD\Alan_Work\HD_IT_DB\FC_Input\HD_Branch\JDE_Transaction_Data_Download\JDE_Transaction_IM_2\RawMaterial_SS_Nic_CSV.csv'
 -- from 'C:\Users\yaoa\Alan_HD\Alan_Work\HD_IT_DB\FC_Input\HD_Branch\JDE_Transaction_Data_Upload_To_SQL\HD_Sales_History_Temp_Exception_Data.csv'
 --   from 'C:\Users\yaoa\Alan_HD\Alan_Work\HD_IT_DB\FC_Input\HD_Branch\JDE_Transaction_Data_Upload_To_SQL\HD_Sales_History_Temp_Exception_Data.xlsx'

  --from  'C:\Users\yaoa\Alan_HD\Alan_Work\HD_DemandPlanning\HD_Pareto_Safety_Stock_And_Inventory\SafetyStock_Exception_Temp.csv'
    from 'C:\Users\yaoa\Alan_HD\Alan_Work\HD_DemandPlanning\HD_Pareto_Analysis\Supplier_Leadtime_Raw_Data_24_02_2021_Txt.txt'
   
  --from 'T:\s _ Supply Chain\archive\Inventory_By_Location_Template_CSV.csv'
  --from  'T:\Forecast Pro\Forecast Pro TRAC\Output\Hunter Douglas\FC_Pro_Fcst_upload_To_SQLSVR_CSV_Download_Template.csv'
   -- from  'T:\Forecast Pro\Forecast Pro TRAC\Output\Hunter Douglas\FC_Download_CSV_test.csv'
   --   from 'C:\Users\yaoa\Alan_HD\Alan_Work\HD_DemandPlanning\FC_Change\HD_New_Product_Induction\Signature_Series_20037_CSV.csv'
	--  from 'C:\Users\yaoa\Alan_HD\Alan_Work\HD_DemandPlanning\FC_Change\HD_Market_Intelligence\Jde_FC_Downloaded_20037_BroomField_DA Review_CSV_.csv'
	 --   from 'C:\Users\yaoa\Alan_HD\Alan_Work\HD_DemandPlanning\FC_Change\HD_Market_Intelligence\Market_Intelligence_Upload_Template_CSV.csv'
	  --  from 'C:\Users\yaoa\Alan_HD\Alan_Work\HD_DemandPlanning\FC_Change\HD_New_Product_Induction\New_Product_Upload_Template_CSV.csv'
	   
   with  (
        --   Fieldteminator='',
        --   Rowteminator ='\n',
            
        FIELDTERMINATOR =',',
        ROWTERMINATOR = '\n',
        FIRSTROW =2     			
			) 


exec JDE_DB_Alan.sp_FCPro_Create_Pareto
exec JDE_DB_Alan.sp_ML345_Px_update
exec JDE_DB_Alan.sp_FCPRO_SlsHistory_upload
exec JDE_DB_Alan.sp_FCPRO_Px_upload
-----------------------------------------------------------------------------------------------------------------------------------



select * from JDE_DB_Alan.MasterFamilyGroup a 
--where a.Code = ''
where a.Description like ('%/S2')
 order by a.Code

select a.ItemNumber,a.WholeSalePrice from JDE_DB_Alan.MasterPrice a
where a.WholeSalePrice> 1000 
group by a.ItemNumber,a.WholeSalePrice
order by a.WholeSalePrice asc

select * from JDE_DB_Alan.MasterFamilyGroup
select * from JDE_DB_Alan.MasterSellingGroup a where a.Code like ('A%')
select * from JDE_DB_Alan.Master_Description_Hierarchy_SKU_Level a where a.ItemNumber like ('%3004')


select * from JDE_DB_Alan.Master_Description_Hierarchy_SKU_Level a 
where a.ItemNumber in (
select a.ItemNumber,count(*) as Cnt
--from JDE_DB_Alan.SalesHistoryHDAWF a
from JDE_DB_Alan.Master_Description_Hierarchy_SKU_Level a 
--where a.ItemNumber like('75%')
 group by a.ItemNumber
 having count(*) >1 )
 order by Cnt asc

 select convert(varchar(20),a.Itemnumber),a.ShortItemNumber
 from JDE_DB_Alan.Master_Description_Hierarchy_SKU_Level a  
 where a.ItemNumber in ('7.51E+11')
 where a.ItemNumber in ('7520000013')



select * from JDE_DB_Alan.SalesHistoryHDAWF a where a.ItemNumber like ('%161.135')


--- Query to get Upload data for Forecasst Pro) ---

ALTER TABLE JDE_DB_Alan.MasterPrice
ALTER COLUMN   WholeSalePrice decimal(18,6);
ALTER COLUMN  StandardCost decimal(18,6);

ALTER TABLE table_name
ADD column_name datatype;

-------------------- CTE for Hunter Douglas Sales History ---------------------------------------

--- Below is just Draft --- Need to consolidate HD & MT Data --- on ItemNum , ShortItemNum level, CYM level ---

with z as (
select ItemNumber,a.ShortItemNum,a.Century,a.FinancialYear,a.FinancialMonth,sum(a.Quantity) as Qty
 from JDE_DB_Alan.SalesHistoryHDAWF a
 group by ItemNumber,a.ShortItemNum,a.Century,a.FinancialYear,a.FinancialMonth
 order by a.ItemNumber,a.ShortItemNum,a.Century asc,a.FinancialYear asc,a.FinancialMonth desc
    )

	--- audit ---
select z.ShortItemNum,ItemNumber,z.Century,z.FinancialYear,z.FinancialMonth,count(z.ItemNumber) Cnt
 from z
 group by z.ShortItemNum,ItemNumber,z.Century,z.FinancialYear,z.FinancialMonth
 Having count(z.ItemNumber) >1


 --- Need to pay attention to Syntax with olap funciton !!! order clause !!! --- 19/10/17 ---
 with cte as (
 --select z.ShortItemNum,z.ItemNumber,z.Century,z.FinancialYear,z.FinancialMonth,row_number() over(partition by z.itemnumber,z.Century,z.FinancialYear,z.FinancialMonth order by itemnumber ) rn  
 --select *,row_number() over(partition by z.itemnumber,z.Century,z.FinancialYear,z.FinancialMonth order by itemnumber ) rownumber 
   select z.ItemNumber,z.ShortItemNum,z.Century,z.FinancialYear,z.FinancialMonth,row_number() over(partition by z.itemnumber,z.Century,z.FinancialYear,z.FinancialMonth order by shortitemnum ) rownumber 
 from JDE_DB_Alan.SalesHistoryHDAWF z
 --where z.ShortItemNum in ('1193545') --order by z.ItemNumber,z.Century,z.FinancialYear,z.FinancialMonth
     )

select * from cte
where  cte.ShortItemNum in ('1193545')
--where cte.ItemNumber in ('6004130000000')
--order by rn desc
order by ItemNumber,Century,financialYear,financialMonth,rownumber desc

select * from JDE_DB_Alan.SalesHistoryHDAWF z where z.ShortItemNum in ('1193545')


select * from JDE_DB_Alan.SalesHistoryAWFHDMT a where a.ShortItemNumber in ('1074571')






---=====================================================================================================================================================================================
---=================== Create SQL table:  CTE for Hunter Douglas Sales History ======================================
--- At the moment, First need to download data from JDE into CSV, delete certain Columns and upload into SQL Server Table SalesHistoryHD/SalesHistoryMT using Bulk Insert

------ Very First First to Need to consolidate HD & MT Data --- on ItemNum , ShortItemNum level 

-----------------------------  MT History     25/10/2017 ------------------------------------------------------

with t as ( select * 
		from JDE_DB_Alan.SalesHistoryAWFHDMT a )

--==============================================================================
--- First need to delete old data for HD,MT,AWF table, important !!! ----
--==============================================================================

select * from JDE_DB_Alan.SalesHistoryAWFHDMTuploadToFCPRO
select * from JDE_DB_Alan.SalesHistoryAWFHDMT
select * from JDE_DB_Alan.SalesHistoryHD
select * from JDE_DB_Alan.SalesHistoryMT

delete from JDE_DB_Alan.SalesHistoryAWFHDMTuploadToFCPRO
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
      
				  )

			--- get stocking type ---
			 ,t as (
					  select a.*,x.StockingType 
					  from JDE_DB_Alan.SlsHistoryMT a left join JDE_DB_Alan.Master_ML345 x
						   on a.ShortItemNumber = x.ShortItemNumber 
					  )
             -- select * from t where t.ItemNumber in ('26.802.659T')

			,m as ( 
					select t.*,l.myItemNumber
						   ,case when l.myItemNumber is null then t.ItemNumber
							   --else t.ItemNumber			-- Mistake 6/11/2017
							     else l.myItemNumber
							end as fItemNumber
					from t left join l on t.ShortItemNumber = l.ShortItemNo 
					--where  t.ShortItemNumber in ('1218124','159804') 
							--and concat(t.Century,t.FinancialYear,t.FinancialMonth) = '201512'
					)            
			
			--select * from m where m.myItemNumber is null
			--select * from m 
			--where m.ShortItemNumber in ('1218124','159804') and concat(m.Century,m.FinancialYear,m.FinancialMonth) = '201512'
			--order by m.Century,m.FinancialYear,m.FinancialMonth

			,_tb as ( select m.bu,m.ShortItemNumber,m.fItemNumber
			   --    case 
				  --     when m.myItemNumber is null then m.ItemNumber
					 --   else  m.myItemNumber		    
						--end as fItemNumber,
					,m.Century,m.FinancialYear,m.FinancialMonth,m.DocumentType,m.Quantity,m.UOM,m.StockingType					
					 from m
				 )
			--select * from _tb 

  			--- Superssion for Bricos Item --- do superssion first, then if there is any U items ( which need to be superseded, can leave filter U later ) otherwise if you not have history for superseded items -- 6/3/2018
			  ,tb_ as (
				select _tb.*,b.NewItemNumberHD,b.NewShortItemNumberHD
				from _tb 
					 left join JDE_DB_Alan.MasterMTSuperssionItemList b on _tb.fItemNumber = b.CurrentItemNumberMT   
				--where _tb.StockingType in ('P','S')					-- leave the task of pick up StockingType to later stage   -- 7/3/2018
				   --   and a.ItemNumber in ('28.380.108')
				)

				
			  ,mt as (select case 
					   when tb_.BU ='MT' then 'HD'
						else  'HD'		    
						end as BU
					,case  
					  when tb_.NewShortItemNumberHD is null then tb_.ShortItemNumber
						else tb_.NewShortItemNumberHD 
						end as FinalShortItemNumber
				   , case 
					   when tb_.NewItemNumberHD is null then tb_.fItemNumber
						else tb_.NewItemNumberHD 
						end as FinalItemNumber
					,tb_.Century,tb_.FinancialYear,tb_.FinancialMonth,tb_.DocumentType,tb_.Quantity,tb_.UOM
		
			 from tb_ )

			 --select * from mt  where mt.FinalItemNumber in ('26.802.659T')
			 --select * from JDE_DB_Alan.SalesHistoryHD a
			---------------------------  HD History  -----------------------------------------------------------------

			--- fix leading zero For HD ---
			 ,dd as ( 
					select h.*,l.myItemNumber from JDE_DB_Alan.SlsHistoryHD h left join l on h.ShortItemNumber = l.ShortItemNo 
					)
	  
			,_hd as ( select dd.bu,dd.ShortItemNumber,
						case 
							 when dd.myItemNumber is null then dd.ItemNumber
							 else  dd.myItemNumber		    
							end as fItemNumber
							,
						dd.Century,dd.FinancialYear,dd.FinancialMonth,dd.DocumentType,dd.Quantity,dd.UOM					
					 from dd )

				--- get stocking type --- 20/2/2018
			 ,hd_ as (
					  select _hd.*,x.StockingType
					  from _hd left join JDE_DB_Alan.Master_ML345 x
						   on _hd.ShortItemNumber = x.ShortItemNumber 
                     -- where x.StockingType not in ('O','U')			'You cannot filter like this for superssion purpose if people already put O or U against a SKU, do it after superssioin - 22/2/2018
					  )
               
			 ,hd as ( select rtrim(ltrim(hd_.BU)) as BU,hd_.ShortItemNumber,hd_.fItemNumber,hd_.Century,hd_.FinancialYear,hd_.FinancialMonth,hd_.DocumentType,hd_.Quantity,hd_.UOM 
						from hd_)

			---------------- Combine MT and HD History together ---------------
			,cb as (		
					select * from mt
					union all
					select * from hd 
				 )

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
			
				------ Consolidate/Merge Very First HD & MT Data for Single Item --- on ItemNum , ShortItemNum level 

			 ,con as (
					select BU,FinalItemNumber as ItemNum,cb.FinalShortItemNumber as ShortItemNum,cb.Century,cb.FinancialYear,cb.FinancialMonth,cb.UOM,sum(cb.Quantity) as Quantity
					 --from JDE_DB_Alan.SalesHistoryAWFHDMT a 
					 from cb
					 group by BU,FinalItemNumber,cb.FinalShortItemNumber,cb.Century,cb.FinancialYear,cb.FinancialMonth,cb.UOM
					 --order by BU,a.ItemNumber,a.ShortItemNum,a.Century asc,a.FinancialYear asc,a.FinancialMonth desc
				)              
				--select * from con where con.ItemNum in ('26.802.659','26.802.659T','27.253.000')

              --------- Superssion --------- 21/2/2018 ---
			 ,_sp as ( select con.ItemNum,con.ShortItemNum
						,sup.NewItemNumber,sup.NewShortItemNumber
							  , case
									when sup.NewItemNumber is null then con.ItemNum
									else sup.NewItemNumber
									end as fItemNum                            
                               , case
									when sup.NewShortItemNumber is null then con.ShortItemNum
									else sup.NewShortItemNumber
									end as fShortItemNum
							  ,con.Century,con.FinancialYear as Year,con.FinancialMonth as Month,con.UOM,con.Quantity
							  ,sup.ConversionRate_UOM					-- use this field as it is good  for debugging purpose  -- 7/3/2018
							  ,case  
							        when sup.ConversionRate_UOM is null then con.Quantity
									when sup.ConversionRate_UOM = 1 then con.Quantity							        
									when sup.ConversionRate_UOM <> 1 then con.Quantity/sup.ConversionRate_UOM
									 end as fQuantity	

						from con left join JDE_DB_Alan.MasterSuperssionItemList sup on con.ShortItemNum = sup.CurrentShortItemNumber		-- join by ShortItemNumber
						)					
             -- select * from _sp where _sp.ItemNum in ('26.802.659','26.802.659T','27.253.000')
			  --select * from _sp where _sp.ItemNum in ('6000130009001H','6000130009001','27.253.000')

			  ------ Group data together by ItemNumber/Month after superssion ------
			  ,sp as (select _sp.fItemNum,_sp.fShortItemNum,_sp.Century,_sp.Year,_sp.Month,_sp.UOM,sum(isnull(_sp.fQuantity,0)) as Qty
						 from _sp
						 group by _sp.fItemNum,_sp.fShortItemNum,_sp.Century,_sp.Year,_sp.Month,_sp.UOM
						)
					-- select * from sp_ where sp_.fItemNum in ('26.802.659','26.802.659T','27.253.000') 
					-- order by sp_.fItemNum,sp_.Century,sp_.Year,sp_.Month
               
         
			 ------ First to get rough selling group/family group/family info from R55ML345 Table,also Select ALL SKUs with right Stocking type so that Obsolete /phase out Product does not generate FC - Can ERP do this job ??  22/2/2018 ---------
			   --- the reason to do join of Hierarchy is it can take advantage of ShortItemNumber since it is unique ---

			,tbl as (
			   select x.BU,sp.fItemNum
					,sp.fShortItemNum		
				 --   , case a.FinancialMonth 
					   --   when > 10  then a.FinancialMonth
						  --else right('00'+a.financialMonth,2)  end

					,sp.Century,sp.Year,sp.Month
					,sp.Qty,sp.Qty * (-1) as SalesQty,x.Description,x.SellingGroup,x.FamilyGroup,x.Family,sp.UOM,x.StandardCost,x.WholeSalePrice
			    from	--JDE_DB_Alan.SalesHistoryHDAWF a 
					 sp
					left join JDE_DB_Alan.Master_ML345 x			--R55ML345 Table
				 --  on a.ItemNumber = b.ItemNumber
				   on sp.fShortItemNum = x.ShortItemNumber
               where x.StockingType not in ('O','U')				--- Filter out U / O stocking type -- Important so No FC generated for these SKUs - 22/2/2018
			--where a.ItemNumber in ('27.161.135') 
				   )
			--select * from tbl	  

			------ Then get your long description of selling group/family group/family which Nic wants ------
			,staging as 
			  (select  tbl.*
					,c.LongDescription as SellingGroup_
					,d.LongDescription as FamilyGroup_
					,e.LongDescription as Family_0
					--,tbl.Family as Family_1
					--,f.StandardCost,f.WholeSalePrice
			  from tbl left join JDE_DB_Alan.MasterSellingGroup c  on tbl.SellingGroup = c.Code
					 left join JDE_DB_Alan.MasterFamilyGroup d  on tbl.FamilyGroup = d.Code
					 left join JDE_DB_Alan.MasterFamily e  on tbl.Family = e.Code
			   )

			----- Then get your final Customerised Output ------
			--  select * from staging where staging.ItemNumber in ('27.161.135')

			,z as  (
				select 'Total' as RowLabel,staging.SellingGroup_ as SellingGroup,staging.FamilyGroup_ as FamilyGroup,staging.Family_0 as Family,
					--staging.Family_1,
					staging.fItemNum as ItemNum,staging.fShortItemNum as ShortItemNum,staging.Description
					--,cast(staging.Century as varchar(10))+ cast(staging.FinancialYear as varchar(10))+cast(staging.FinancialMonth as varchar(10)) as CYM
					,cast(staging.Century as varchar(10))+ cast(staging.Year as varchar(10)) as CY
					,staging.Century,staging.Year,staging.Month
					,case  
						 when staging.Month  >= 10  then format(staging.Month,'0') 
						 --else right('000'+cast(a.financialMonth as varchar(2)),3)  
						 when staging.Month  <10  then format(staging.Month,'00') 
					end as MM
					,'12' as PPY, '12' as PPC
					,staging.SalesQty,staging.StandardCost,staging.WholeSalePrice,SalesQty*StandardCost as InventoryVal, SalesQty*WholeSalePrice as SalesVal
				from staging

				)

			--select * from z
			--where z.FinalItemNumber in ('26.802.659','26.802.659T')
			--where StandardCost > WholeSalePrice
			--order by SalesVal desc
          

			  ----- Need to consolidate Sales History if there are one ItemNum but mulitple ShortItemNum ?--- After this operation you will lost your descriiption since for  one  item you might have 2 different description, to get ItemNum level data, you NEED aggregate and remove description level,your data set will only have this info--> Hierarchy/ItemNum/Year/Month/Qty
			,zz as (
				select z.RowLabel,z.SellingGroup,z.FamilyGroup,z.Family,z.ItemNum,concat(z.CY,z.MM) as CYM,z.CY,z.Century,z.Year,z.Month,z.PPY,z.PPC,sum(SalesQty) as SalesQty_,sum(z.InventoryVal) as InventoryVal_,sum(z.SalesVal) as SalesVal_
				from z 
			--where z.ItemNumber in ('8.51E+11') 
				  -- and z.Year in ('15') and z.month in ('1')
					-- and (z.Year + z.Month like '%20151')
				group by  z.RowLabel,z.SellingGroup,z.FamilyGroup,z.Family,z.ItemNum,concat(z.CY,z.MM),z.CY,z.Century,z.Year,z.Month,z.PPY,z.PPC
			  )

        --  select * from zz where zz.FinalItemNumber in ('26.802.659')

		 --------- To get your description from ML345 to join back your data set but First need to fix the ItemNumber with leading zero for ML345  ------

			 --- First fix Leading Zero for ML345 table --- This can be obsolete since this process has already been done ---
			 ,q as ( 
					select x.*,l.myItemNumber from JDE_DB_Alan.Master_ML345 x 
					left join l on x.ShortItemNumber = l.ShortItemNo 
					)			  
			,ml as ( select q.BU,
				   case 
					   when q.myItemNumber is null then q.ItemNumber
						else  q.myItemNumber		    
						end as fItemNumber
					,q.ShortItemNumber,q.description,q.SellingGroup,q.FamilyGroup,q.Family,q.Standardcost,q.WholeSalePrice					
					 from q )
               ---------------------------------------------------------
			,cte1 as (
					select ml.fItemNumber,ml.Description,ml.StandardCost,ml.WholeSalePrice
							,row_number() over(partition by ml.fitemnumber order by fitemnumber ) rn  
					from ml
			 )
			 ,cte as (
					 select * from cte1 
					 where rn = 1 )


			 --- Below will yield result for Combined MT + HD History Ready for Upload to Forecast Pro ---
		  , fl as (
			 select zz.RowLabel,zz.SellingGroup,zz.FamilyGroup,zz.Family,rtrim(ltrim(zz.ItemNum)) as ItemNumber_,cte.Description,cte.standardcost,cte.wholesaleprice,zz.CYM,zz.CY,zz.Month,zz.PPY,zz.PPC,zz.SalesQty_
			 from zz left join cte on zz.ItemNum = cte.fItemNumber
			 --  from zz inner join cte on zz.ItemNumber = cte.ItemNumber
			 where zz.CYM < cast(convert(varchar(6),getdate(),112) as int)				--- to exclude current month Sales --- 5/3/2018
			   )				

			--select top 3 fl.* from fl 
			--where fl.ItemNumber_ in ('44.132.000')
			--order by fl.SellingGroup,fl.FamilyGroup,fl.Family,fl.ItemNumber_,fl.CYM		

			,myfl as (
					select fl.RowLabel,fl.SellingGroup,fl.FamilyGroup,fl.Family,fl.ItemNumber_,fl.Description,fl.CY,fl.Month,fl.PPY,fl.PPC,fl.SalesQty_,fl.CYM,getdate() as ReportDate from fl
					--where fl.ItemNumber_ in ('18.615.024')
					--  where fl.CYM < cast(convert(varchar(6),getdate(),112) as int)				--- to exclude current month Sales --- Move this filter up one step so all records extracted from this SP will be consistent with Px table -- 5/3/2018
					)
			

			--select * from myfl 
			--where myfl.FamilyGroup is null					--- This is very good code to see & identify any field you have null value, since you put constraint in table definition and if you go to insert into table when you have null value you will be thrown with error like --> Cannot insert the value NULL into column 'SellingGroup', table 'JDE_DB_Alan.JDE_DB_Alan.Px_AWF_HD_MT_FCPro_upload'; column does not allow nulls. INSERT fails. --- 1/3/2018  --- The most important things here is how to identify which records cause insert fail and where is the null value as error message does not give enough clue like which row which line. So it begs the question is it worthvile to implement null value or not in table definition ?
			--select * from myfl where myfl.Family is null
			--where myfl.ItemNumber_ in ('26.802.659','27.253.000') order by myfl.ItemNumber_,myfl.CYM
			 --select top 3 myfl.* from myfl 
			--select distinct myfl.CYM  from myfl order by myfl.CYM desc
			--delete from JDE_DB_Alan.SalesHistoryAWFHDMTuploadToFCPRO
			--insert into JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload  select * from myfl 
			--select * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload
			

		------------------------ To Get Your Price Conversion table -----------------------
		,flpri as ( select fl.RowLabel,fl.SellingGroup,fl.FamilyGroup,fl.Family,fl.ItemNumber_,fl.StandardCost,fl.WholeSalePrice
						  ,row_number() over(partition by fl.itemnumber_ order by itemnumber_) as rn,GETDATE() as ReportDate
					from fl
					)

         --select * from flpri 
		-- where flpri.ItemNumber_ in ('2801382551')
		-- where flpri.SellingGroup is null					--- This is very good code to see & identify any field you have null value, since you put constraint in table definition and if you go to insert into table when you have null value you will be thrown with error like --> Cannot insert the value NULL into column 'SellingGroup', table 'JDE_DB_Alan.JDE_DB_Alan.Px_AWF_HD_MT_FCPro_upload'; column does not allow nulls. INSERT fails. --- 1/3/2018  --- The most important things here is how to identify which records cause insert fail and where is the null value as error message does not give enough clue like which row which line. So it begs the question is it worthvile to implement null value or not in table definition ?
		
		insert into JDE_DB_Alan.Px_AWF_HD_MT_FCPro_upload select * from flpri where flpri.rn =1

   -----------------------------------------------------------------------------------------------------		
		update px
		set px.WholeSalePrice = ( case 
		                                when px.WholeSalePrice >9998 then 1
										when px.WholeSalePrice = 0 or px.WholeSalePrice is null then
											(case 
													when px.StandardCost=0 or px.StandardCost is null then 0.01
													else px.StandardCost 
													end)							 
										else px.WholeSalePrice
										end )
			,px.StandardCost= ( case 
										when px.StandardCost = 0 or px.StandardCost is null then
											(case 
													when px.WholeSalePrice=0 or px.WholeSalePrice is null then 0.01
													else px.WholeSalePrice 
													end)							 
										else px.StandardCost
										end )
			--,p.Description =( case 
			--						 when CHARINDEX(',',p.Description) >0 then REPLACE(p.Description,',','/')
			--							 else p.Description
			--							 end )
								 										
		from JDE_DB_Alan.Px_AWF_HD_MT_FCPro_upload px

		select * from JDE_DB_Alan.Px_AWF_HD_MT_FCPro_upload


-- To get your distinct ItemNumber (give you 9932 records ) --- no need to get another join you can just tweet cte query to include cost & wholesaleprice ---
-- just remember need to manual change either cost or  retail price is 0 or both are 0 then upload into Master price table in SQL DB ---

--select distinct fl.ItemNumber_ from fl


--where fl.ItemNumber like ('%7840001000') or fl.ItemNumber like ('%Item.32000')
--where fl.ItemNumber like ('%18.217.010')
 where fl.ItemNumber_ in ('28.552.000')
order by fl.RowLabel,fl.SellingGroup,fl.FamilyGroup,fl.Family,fl.ItemNumber_,fl.CY,fl.Month

-----------------------------------------------------------------------------------------------------------------------

exec JDE_DB_Alan.sp_GetMTquery
exec JDE_DB_Alan.sp_GetMTquery @ItemNumber = '26.740.060'

exec JDE_DB_Alan.sp_GetMTquery @ItemNumber = '26.740.060', @CenturyYearMonth =201505
exec JDE_DB_Alan.sp_GetMTquery @ShortItemNumber = '543515', @CenturyYearMonth =201505

select * from JDE_DB_Alan.SlsHistoryMT a  where a.ItemNumber in ('26.740.060')

exec [JDE_DB_Alan].sp_FCPRO_SlsHistory_upload
select * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload o where (o.ItemNumber not like ('82.601.90%')) and (o.ItemNumber not in ('24.057.165S'))

exec [JDE_DB_Alan].sp_FCPRO_Px_upload
select * from JDE_DB_Alan.Px_AWF_HD_MT_FCPro_upload x where x.StandardCost is null
select * from JDE_DB_Alan.Px_AWF_HD_MT_FCPro_upload x where (x.ItemNumber not like ('82.601.90%')) and (x.ItemNumber not in ('24.057.165S'))
select * from JDE_DB_Alan.Px_AWF_HD_MT_FCPro_upload x where x.ItemNumber like ('18.317.002%')



select * from JDE_DB_Alan.Master_ML345 y where y.ItemNumber in ('24.057.165S')    -- '24.057.165S' same ShortItemNumber (1351582) as Item '24.023.165S'
select * from JDE_DB_Alan.Master_ML345 y where y.ShortItemNumber in ('1351582')
select 1

select * from ( 
select * from JDE_DB_Alan.Px_AWF_HD_MT_FCPro_upload a where a.ItemNumber like ('%850520000202%')) as b where b.ItemNumber not like ('[^0-9]')

-- show item only with number
select * from ( 
select * from JDE_DB_Alan.Px_AWF_HD_MT_FCPro_upload a where a.ItemNumber like ('%850520000202%')) as b where b.ItemNumber not like ('%[^0-9]%') 

--- show item only with number
select * from (
select * from JDE_DB_Alan.Px_AWF_HD_MT_FCPro_upload a where a.ItemNumber like ('%850520000202%')) as b where b.ItemNumber not like ('%[a-z]%') 

select * from (
select * from JDE_DB_Alan.Px_AWF_HD_MT_FCPro_upload a where a.ItemNumber like ('%850520000202%')) as b where b.ItemNumber like ('%[^0-9]%') --- show item only with letters

select a.ItemNumber,ROW_NUMBER() over(partition by a.itemnumber order by a.itemnumber) as rnk 
from JDE_DB_Alan.Px_AWF_HD_MT_FCPro_upload a
order by rnk asc

---------------------------------- end of CTE of Ceating SQL table : Sales History ---------------------------------------
--==================================================================================================================================================================================



---============================================================================================================================================================================================
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
------------------- Create Pareto : Pareto Analysis step 1 :  Create Pareto 1/11/2017 ------------------------------
---===========================================================================================================================================

--use JDE_DB_Alan
--go

select top 1 * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload a
select top 10 percent * from JDE_DB_Alan.Master_ML345 a

select * from JDE_DB_Alan.Master_ML345 a where a.ItemNumber in ('18.217.002')

select top 1000 * from JDE_DB_Alan.FCPRO_Fcst		and f.DataType1 in ('Adj_FC')			--26/2/2018
select * from JDE_DB_Alan.FCPRO_Fcst a where a.ItemNumber like ('%850520000202%')		and f.DataType1 in ('Adj_FC')			--26/2/2018
select * from JDE_DB_Alan.JDE_DB_Alan.FCPRO_Fcst a where a.ItemNumber in ('2851218661') and a.DataType1 like('%price')
---

---------------------Method 1. use Order by works this is fastest takes 2 sec awesome !  ---  14/11/2014------------------------------------------
--- Get ItemLvl FC --- Please note you Have change Data input in .FCPRO_Fcst table so below Query will be Wrong, since you need to Join Px table to get Price then calculate Pareto, but SQL logic is correct - that is to use OLAP  over() clause to quicly get result ! 1/12/2017
with sm as
 ( select t.ItemNumber,t.SellingGroup,t.FamilyGroup,t.Family,t.DataType1,sum(t.Value) as ItemLvlFC_24 
			from JDE_DB_Alan.FCPRO_Fcst as t 
			where t.DataType1 in ('Adj_FC')		--26/2/2018
			-- where t.DataType1 in ('WholeSalePrice') and 
			   where t.ItemNumber in ('2851218661','18.615.024','26.803.676','4250084126','4150951785','2851236862')
			group by t.ItemNumber,t.SellingGroup,t.FamilyGroup,t.Family,t.DataType1 
			--order by t.DataType1, sum(t.Value) desc
		 ),		
		  
x as (
	select *
		 ,sum(sm.ItemLvlFC_24) over(partition by sm.DataType1) as GrandTTL
		 ,cast(sm.ItemLvlFC_24/sum(sm.ItemLvlFC_24) over(partition by sm.DataType1) as decimal(18,12)) as Pct
		--,(select sum(value) from FCPRO_Fcst where id<=t.id)/(select sum(value) from FCPRO_Fcst ) as Running_Percent	 
	from sm
	--order by FCPRO_Fcst.value
		),

--select * from x order by x.DataType1,x.ItemLvlFC_24 desc
--- Sort the records First Very important !---
y as ( select x.*,row_number() over ( partition by x.DataType1 order by x.Pct desc) as rnk
		from x ),

tbl as (
		select y.*,sum(y.ItemLvlFC_24) over (partition by y.DataType1 order by y.rnk ) as RunningTTL from y ),

--- Calculate Percentage ( And if there is an% sign in number remove it first )
ftb as ( select tbl.ItemNumber,tbl.SellingGroup,tbl.FamilyGroup,tbl.Family,tbl.DataType1
			,tbl.ItemLvlFC_24,tbl.RunningTTL,tbl.GrandTTL,tbl.Pct,(tbl.RunningTTL/tbl.GrandTTL) as RunningTTLPct,tbl.rnk
			 , (case 
						when convert(decimal(18,2),replace((tbl.RunningTTL/tbl.GrandTTL),'%','')) < 0.80 then 'A'		---20
						when convert(decimal(18,5),replace((tbl.RunningTTL/tbl.GrandTTL),'%','')) < 0.95 then 'B'		---30
						else 'C' end ) as Pareto																		---50             
			from tbl
			),

fltb as (select *,GETDATE() as ReportDate from ftb 
			--where ftb.DataType1 like ('%price') and ftb.rnk =819
			)
select * from fltb

exec JDE_DB_Alan.sp_FCPro_Create_Pareto @DataType1 ='%price'
insert into JDE_DB_Alan.FCPRO_Fcst_Pareto  select * from fltb
select * from JDE_DB_Alan.FCPRO_Fcst_Pareto p where rnk between 800 and 850 order by p.DataType1,rnk
select p.ItemNumber,p.DataType1,p.ItemLvlFC_24,p.ItemLvlFC_24/24 FC_1MthAvg,p.Pareto from JDE_DB_Alan.FCPRO_Fcst_Pareto p where p.ItemNumber like ('%24.7206.0000')


--------------------Method 2. use CTE works but very slow 800 items takes 30 min!! Do not use it !-----------------------------------------------------------------
--- Get ItemLvl FC --- Please note you Have change Data input in .FCPRO_Fcst table so below Query will be Wrong, since you need to Join Px table to get Price then calculate Pareto, but SQL logic is correct - that is to use OLAP  over() clause to quicly get result ! 1/12/2017
--- Get ItemLvl FC ---
with sm as 
	( select t.ItemNumber,t.SellingGroup,t.FamilyGroup,t.Family,t.DataType1,sum(t.Value) as ItemLvlFC_24
	   from JDE_DB_Alan.FCPRO_Fcst as t where t.DataType1 in ('WholeSalePrice') 
				  and t.ItemNumber in ('2851218661','18.615.024','26.803.676','4250084126','4150951785','2851236862')
	  group by t.ItemNumber,t.SellingGroup,t.FamilyGroup,t.Family,t.DataType1 
	),		 
x as 
(	select *
		 ,(select sum(ItemLvlFC_24) from sm) as GrandTTL
		 ,cast(sm.ItemLvlFC_24/(select sum(sm.ItemLvlFC_24) from sm ) as decimal(18,12)) as Pct		 
	from sm
	--order by FCPRO_Fcst.value
   ),

--- Sort the records First Very important !---
y as ( select x.*,row_number() over ( order by x.Pct desc) as rnk
		from x ),

--select * from y
--- Get the Running total ---
CummulativeSum as ( select y.ItemNumber,y.SellingGroup,y.FamilyGroup,y.Family,y.DataType1
					,y.rnk,y.GrandTTL,y.ItemLvlFC_24,y.Pct,y.ItemLvlFC_24 as RunningSum from y where y.rnk =1
					--order by y.ItemLvlFC_24
				 union all
				 select This.ItemNumber,This.SellingGroup,This.FamilyGroup,This.Family,This.DataType1
					,This.rnk,this.GrandTTL,this.ItemLvlFC_24,this.Pct,(This.ItemLvlFC_24 + CS.RunningSum) as runningSum from y as This 
													inner join CummulativeSum CS on This.rnk = CS.rnk+1
				 where this.rnk >1	),

--select * from CummulativeSum
--OPTION (maxrecursion 100000)

--- Calculate Percentage ( And if there is an% sign in number remove it first )
ftb as ( select tbl.ItemNumber,tbl.SellingGroup,tbl.FamilyGroup,tbl.Family,tbl.DataType1
			,tbl.ItemLvlFC_24,tbl.RunningSum,tbl.GrandTTL,tbl.Pct,(tbl.RunningSum/tbl.GrandTTL) as RunningTTLPct
			 , (case 
						when convert(decimal(18,2),replace((tbl.RunningSum/tbl.GrandTTL),'%','')) < 0.80 then 'A'		---20
						when convert(decimal(18,5),replace((tbl.RunningSum/tbl.GrandTTL),'%','')) < 0.95 then 'B'		---30
						else 'C' end ) as Pareto																		---50
			from CummulativeSum as tbl
			--OPTION (maxrecursion 100000)
			)

select * from ftb
OPTION (maxrecursion 32760)


--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-------------------- Create Pareto: Pareto Analysis step 2:  Pareto Summary ------------------------------------
select * from JDE_DB_Alan.FCPRO_Fcst_Pareto p 
select p.ItemNumber,p.Pareto from JDE_DB_Alan.FCPRO_Fcst_Pareto p 

with cte as (
SELECT p.Pareto,sum(p.ItemLvlFC_24_Amt) FC_TTL24,count(p.ItemNumber) as SkuCount
  FROM [JDE_DB_Alan].FCPRO_Fcst_Pareto p where p.DataType1 like ('%Adj%')
  group by p.Pareto
  --order by p.Pareto
  ),

tb as (
select cte.Pareto,cte.SkuCount,cte.FC_TTL24, sum(cte.SkuCount) over () as GrandTTL_Skus,sum(cte.FC_TTL24) over () as GrandTTL_Amt from cte 
group by cte.Pareto,cte.FC_TTL24,cte.SkuCount
--order by cte.Pareto
)

select tb.*
		,convert( decimal(18,12),cast(tb.SkuCount as decimal(18,6))/cast(tb.GrandTTL_Skus as decimal(18,6))) as Pct_Sku
		,tb.FC_TTL24/tb.GrandTTL_Amt as Pct_Amt 
from tb
order by tb.Pareto
---============================== End of Creating Pareto ================================================================================================================================





---=========================== Creating Safety Stock  ===================================================================================================================================
---======================================================================================================
--- Safety stock --- Using demand history ! - 9/1/2018
--- how about items which has sales hist that is 0 qty ? --- is padding needed to calculate STDEV?
---======================================================================================================
select *
from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h
where h.ItemNumber like ('26.803.676')
order by h.CYM



exec JDE_DB_Alan.sp_Cal_SafetyStock
 ---=========================================================================================================
 --- Safety Stock Calculation --- This is Final Version  --- 11/1/2018 - Works Yeah !
 ---=========================================================================================================

 --- Get Your Calendar --- it will calculate Safety stock using Demand History of past rolling 12 ( or whatever months you want ) months ---
--- it will padded with each item in case if they do not have sales in a particular months so that you wont miss sales and division is correct ( 12 ) ---
--- SS = stdevp x sqrt of leadtime x Z-score ---

;;with  CalendarFrame as 
		(
			select 1 as t,cast(DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,GETDATE())-35,0)) as datetime) as eom
			union all
			select t+1,dateadd(mm, 1, eom)
			from CalendarFrame
		)
		,MonthlyCalendar as
			(
			select top 36 t,cast(replace(convert(varchar(8),[eom],126),'-','') as integer) [eom] 
			from CalendarFrame
			)

		,cldr as
		(select mc.t
				,left(mc.eom,6)  as eom_
		from MonthlyCalendar mc 
			--where left(mc.eom,4)=2015
				where mc.eom> replace(convert(varchar(8), DATEADD(mm, DATEDIFF(m,0,GETDATE())-13,0),126),'-','')		--last 12 months
		)
		--select * from cldr
		,itm as ( select distinct h.ItemNumber as ItemNumber_ from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h )
		,list as ( select * from itm cross join cldr)
		--select * from list where list.ItemNumber in ('18.615.024')  order by list.ItemNumber,list.eom_ 

			-- Padded Item with all Months ---
		,hist as 
		(  select list.ItemNumber_,case when h.SalesQty is null then 0 else h.SalesQty end as SalesQty_,list.eom_,list.t
		from list left join JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h on list.eom_ = h.CYM and list.ItemNumber_ = h.ItemNumber
		--where list.ItemNumber in ('18.615.024') 		
		)
		-- select * from hist 
		-- where hist.ItemNumber in ('18.615.024')
		-- order by hist.eom_

		,stdv_ as ( 
				select hist.ItemNumber_ 
				,sum(hist.salesqty_)/count(hist.eom_) as Avg_Itm					-- Be careful , some month doesnot have sales, so affect avg
				,sum(hist.salesqty_) as TTL_Itm
				,sum( case when salesqty_ >0 then 1 else 0 end ) as Num_ItmSls		-- count numb of month that has positive sales
				,count(hist.eom_) as TTL_ItmSlsMth			
				,STDEVP(salesqty_) as Stdevp_Item
				from hist
				group by hist.ItemNumber_ )
        --    select * from stdv_ where stdv_.ItemNumber_ in ('45.124.000') 
		--  select * from stdv_ where stdv_.ItemNumber_ in ('45.648.100')   
		--select * from stdv_ where stdv_.ItemNumber_ in ('18.615.024')
		--select * from stdv_ where stdv_.ItemNumber_ in ('2974000000','24.7206.0000')

		--- Get Your Pareto & Z-Score (Service Level )--
		,parto as ( select * 
				from JDE_DB_Alan.FCPRO_Fcst_Pareto p left join stdv_ on p.ItemNumber = stdv_.ItemNumber_
						     
				)
  
		,parto_ as ( select parto.ItemNumber,parto.Stdevp_Item,parto.TTL_Itm,parto.Pareto
				,case parto.Pareto 
						when 'A'  then 2.33			-- 99%		
						when 'B'  then 1.65			-- 95%		-- 2.05 98%
						when 'C'  then 1.65           --95%
					end as Z        
				from parto 
				--where comb.ItemNumber in ('18.615.024')
				)
		--select *, parto_.Stdevp_Item * parto_.Z as SS from parto_
		--where parto_.ItemNumber in ('18.615.024')

		--- Get your Leadtime ---
		,ldtm as (
			select m.ItemNumber as Item_Number,m.LeadtimeLevel
				,row_number() over(partition by m.itemNumber order by m.itemNumber ) rn  
				from JDE_DB_Alan.Master_ML345 m
			)
		,ldtm_ as (
			select * from ldtm
			where rn = 1 )

		,comb as 
		( select *,parto_.Stdevp_Item* SQRT(ldtm_.leadtimeLevel/30)*parto_.Z as SS
			from parto_ left join ldtm_ on parto_.ItemNumber = ldtm_.Item_Number
				--where parto_.ItemNumber in ('18.615.024')
		)

		,fltb as 
		( select comb.ItemNumber,comb.TTL_Itm,comb.Pareto,comb.Stdevp_Item,comb.LeadtimeLevel,comb.rn,comb.ss as SS_,GETDATE() as RdportDate
			from comb 
		--   where comb.ItemNumber in ('18.615.024','26.803.676','34.307.000','52.417.905','24.043.165S')
			)

              
        insert into JDE_DB_Alan.FCPRO_SafetyStock select * from fltb
		select * from JDE_DB_Alan.FCPRO_SafetyStock
     
	-- below code will be result with calculation on each line/month level ---
	--tb as (
	--select *
	--    ,count(hist.salesqty) over(partition by hist.itemnumber) as count_
	--	,avg(hist.salesqty) over(partition by hist.itemnumber) as avg_	
	--	,SalesQty - avg(hist.salesqty) over(partition by hist.itemnumber)  as diff_
	--	,POWER((SalesQty - avg(hist.salesqty) over(partition by hist.itemnumber)),2) diff_powwer2
	--	,POWER((SalesQty - avg(hist.salesqty) over(partition by hist.itemnumber)),2) /count(hist.salesqty) over(partition by hist.itemnumber) as  var_
	--	,POWER((SalesQty - avg(hist.salesqty) over(partition by hist.itemnumber)),2) /12 as  var_12m
	--	,STDEVP(hist.salesqty) over(partition by hist.itemnumber) as stdev_
	--from hist
	--   )

	--select *
	--	  ,sum(tb.var_) over() as varsum_	   
	--from tb
	--order by tb.ItemNumber,tb.CYM
  

   insert into JDE_DB_Alan.FCPRO_SafetyStock select * from fltb

   exec JDE_DB_Alan.sp_Cal_SafetyStock
   select * from JDE_DB_Alan.FCPRO_SafetyStock
     
-- below code will be result with calculation on each line/month level ---
--tb as (
--select *
--    ,count(hist.salesqty) over(partition by hist.itemnumber) as count_
--	,avg(hist.salesqty) over(partition by hist.itemnumber) as avg_	
--	,SalesQty - avg(hist.salesqty) over(partition by hist.itemnumber)  as diff_
--	,POWER((SalesQty - avg(hist.salesqty) over(partition by hist.itemnumber)),2) diff_powwer2
--	,POWER((SalesQty - avg(hist.salesqty) over(partition by hist.itemnumber)),2) /count(hist.salesqty) over(partition by hist.itemnumber) as  var_
--	,POWER((SalesQty - avg(hist.salesqty) over(partition by hist.itemnumber)),2) /12 as  var_12m
--	,STDEVP(hist.salesqty) over(partition by hist.itemnumber) as stdev_
--from hist
--   )

--select *
--	  ,sum(tb.var_) over() as varsum_	   
--from tb
--order by tb.ItemNumber,tb.CYM

------------------- Safety Stock Query SS by Supplier --------------
   ---- Check the lead time ------
select m.ItemNumber,m.Description,m.LeadtimeLevel,m.PrimarySupplier,m.PlannerNumber 
from JDE_DB_Alan.Master_ML345 m 
--where m.ItemNumber in ('34.302.000')
where m.PrimarySupplier in ('1281')
     -- and m.LeadtimeLevel <>90
order by LeadtimeLevel asc


select distinct m.LeadtimeLevel from JDE_DB_Alan.Master_ML345 m 
where m.PrimarySupplier in ('1454')


         ---22/03/2021 ---

   ----- Query the SS ... --- will be carried out in Seperate SQL Query -- See code in 'Master_Code' .... Below is snippet from 'Master_Code' -- appox line 3600

     --- New --- 1. Impersonate existing SS while using latest SS - lift 10% for A & B Item - this can be wind back when Covid period is concluded ( started in June/July 2020 )
	 --- Considerations:
	 --1) excluding MTO items; excluding some Selling group
	 --2) apply certain % to A,B,C paretos - this need to be reveiwed and wind back periodically
	 --3) raw calculations for safety stock in done in Store Procedure -- 'Cal_Safety_Stock'
	 --4) in Query, has to use 'vw_SafetyStock' table to fetch only 1 records per item/SKU to avoid duplicate because 'SafetyStock' table contains all history for SS each item/SKU
	 --5) Note 'Safety stock' table is appeneded/updated each month, so this table 'Safety sto;ck' has history of SS, be careful when query or update ( select/delete/update - DML command or create/drop/alter - DDL )


         
 use JDE_DB_Alan
 go
 
 with tb as ( 
		
				select ss.ItemNumber,ss.SS_Adj,m.StandardCost,isnull(ss.SS_Adj*m.StandardCost,0) as SS_Adj_Dollar,m.LeadtimeLevel
				,m.PrimarySupplier,m.PlannerNumber,m.StockingType
				,m.SellingGroup
			    ,m.Owner_
				,ss.Pareto
				,sum(isnull(ss.SS_Adj*m.StandardCost,0)) over ( partition by m.PrimarySupplier) as SS_TTL_By_Vendor
				,sum(isnull(ss.SS_Adj*m.StandardCost,0)) over ( partition by m.FamilyGroup) as SS_TTL_By_FGrp
				,ss.ReportDate

				from JDE_DB_Alan.vw_SafetyStock ss left join JDE_DB_Alan.vw_Mast m							--- has to use 'vw_SafetyStock' to fetch only 1 records per item/SKU to avoid duplicate because 'SafetyStock' table contains all history for SS each item/SKU.
					  on ss.ItemNumber = m.ItemNumber 
				-- where  cte_.PrimarySupplier in ('1454','1281') --and ss.ItemNumber in ('34.486.000')
				-- where ss.ItemNumber in ('42.210.031')
				-- where cte_.StockingType not in ('O','U') --and cte_.ItemNumber in ('36.241.855')  -- Q is BTO and M is MTO
				 where m.StockingType not in ('O','U','Q','M') --and cte_.ItemNumber in ('36.241.855')  -- Q is BTO and M is MTO
					  and m.SellingGroup in ('AD','TM','WC','FI')
		 
		    )

 select 'HD' as BU,a.ItemNumber,a.SS_Adj as SS_Qty,a.SS_Adj as SS_Qty_ImpersonatedOld,a.standardcost as Cost,a.SS_Adj_Dollar as SS_Dollars,a.LeadtimeLevel,a.PrimarySupplier,a.PlannerNumber,a.StockingType,a.SellingGroup,a.Owner_,a.Pareto
		,case
		     when a.Pareto in ('A','B') then a.SS_Adj * 1.1
			 when a.Pareto in ('C') then a.SS_Adj
        end as SS_Final
		,case
		     when a.Pareto in ('A','B') then a.SS_Adj_Dollar * 1.1
			 when a.Pareto in ('C') then a.SS_Adj_Dollar
        end as SS_Final_$
 from tb a

 --where a.ItemNumber in ('42.210.031','34.506.000')
 order by a.PrimarySupplier,a.Pareto




   --- New --- 2. Use vw_Master_Planning where it download JDE SS ( old & existing SS ) and combines latest SS from 'SafetyStock' table ( SS_Adj )
   select * from JDE_DB_Alan.vw_Mast_Planning m where m.Item_Number in ('42.210.031','34.506.000')



   --- New --- 3. Use 'SafetyStock ' table and extract 2 latest records each item, then using 'Union' to combine same structure table 
   
   with a
       ( select * 
	      from JDE_DB_Alan.FCPRO_SafetyStock 
		
		)


   

select * from  [JDE_DB_Alan].[vw_SafetyStock] s  where s.ItemNumber in ('42.210.031','34.506.000')
select * from  [JDE_DB_Alan].FCPRO_SafetyStock_Oldcopy s  where s.ItemNumber in ('42.210.031')
select * from JDE_DB_Alan.vw_Mast_Planning m where m.Item_Number in ('42.210.031')

         --- old code ---
;with cte as
      ( select *
	          ,row_number() over(partition by m.itemnumber order by itemnumber ) rn 
		from JDE_DB_Alan.Master_ML345 m               
		)
     ,cte_ as
	    ( select * from cte where cte.rn =1
		)

     , tb as ( 
		
		select ss.ItemNumber,ss.SS_Adj,isnull(ss.SS_Adj*cte_.StandardCost,0) as SS_Adj_Dollar,cte_.LeadtimeLevel
		,cte_.PrimarySupplier,cte_.PlannerNumber,cte_.StockingType
		,cte_.SellingGroup
		,case cte_.PlannerNumber 
								--when '20071' then 'Domenic Cellucci'
								when '20071' then 'Rosie Ashpole'
								when '20072' then 'Salman Saeed'
								when '20004' then 'Margaret Dost'	
								when '20005' then 'Imelda Chan'										  
								else 'Unknown'
		end as Owner_
		,ss.Pareto
		,sum(isnull(ss.SS_*cte_.StandardCost,0)) over ( partition by cte_.PrimarySupplier) as SS_TTL_By_Vendor
		,sum(isnull(ss.SS_*cte_.StandardCost,0)) over ( partition by cte_.FamilyGroup) as SS_TTL_By_FGrp
		--,cte_.StandardCost,cte_.WholeSalePrice
		--,cte_.StandardCost * ss.SS_Adj as SS_Dollars	
		
		,max(ss.ReportDate) over(partition by ss.itemNumber) as Latest_upd_date	
		,min(ss.ReportDate) over(partition by ss.itemNumber) as Oldest_upd_date

		,rank() over ( partition by ss.itemNumber order by ss.reportdate Desc) rk_0
		,rank() over ( partition by ss.itemNumber order by ss.reportdate desc) rk_1
		,dense_rank() over ( partition by ss.itemNumber order by ss.reportdate desc ) rk_2_de	
		,ss.ReportDate

	from JDE_DB_Alan.FCPRO_SafetyStock ss left join cte_
	      on ss.ItemNumber = cte_.ItemNumber 
	-- where  cte_.PrimarySupplier in ('1454','1281') --and ss.ItemNumber in ('34.486.000')
	-- where ss.ItemNumber in ('42.210.031')
    -- where cte_.StockingType not in ('O','U') --and cte_.ItemNumber in ('36.241.855')  -- Q is BTO and M is MTO
	 where cte_.StockingType not in ('O','U','Q','M') --and cte_.ItemNumber in ('36.241.855')  -- Q is BTO and M is MTO
	      and cte_.SellingGroup in ('AD','TM','WC','FI')
		 
		    )

  select * 
   from tb
   where 
		  --and cte_.ItemNumber in ('FT.01468.000.01')
		  tb.ItemNumber in ('34.481.000') 
		 --  tb.rk_2_de = 1												--- Important ! pick up the latest updated records !!  8/3/2021
 order by  tb.PrimarySupplier,tb.Pareto


 select * from JDE_DB_Alan.vw_SafetyStock s
 
  select * from JDE_DB_Alan.FCPRO_SafetyStock ss where ss.ReportDate >'2021-03-02'
   select distinct ss.ReportDate  from JDE_DB_Alan.FCPRO_SafetyStock ss 


select * from JDE_DB_Alan.FCPRO_SafetyStock ss 
select m.ItemNumber,m.LeadtimeLevel,m.PrimarySupplier from JDE_DB_Alan.Master_ML345 m 
where m.PlannerNumber in ('20072')

select distinct f.ItemNumber from JDE_DB_Alan.FCPRO_Fcst f
---============================== End of Creating Safety Stock ===========================================================================================================================================================



---============================ Start of Forecast Accuracy ==========================================================================================================================================

--======================================
--- FC Accuracy Final --- 25/5/2018
---======================================

	 --- Peter's Old Code ---
	--;with CalendarFrame as (
	--				select -24 as t,1 as n,cast(DATEADD(mm, DATEDIFF(mm, 0, GETDATE())-24, 0) as datetime) as start
	--					select 1 as t,1 as n,cast(DATEADD(mm, DATEDIFF(mm, 0, GETDATE())-24, 0) as datetime) as start
	--				union all
	--				select case when t +1 >24 then 1 else t+1 end ,case when n=12 then 1 else n+1 end,dateadd(mm, 1, start)
	--				 select t+1 ,case when n=12 then 1 else n+1 end,dateadd(mm, 1, start)
	--				from CalendarFrame
	--				where t<50
				
	--			)
	--			select  top 50 * from CalendarFrame
	--		 ,MonthlyCalendar as
	--				(
	--				select top 48 t, RIGHT('00'+CAST(n AS VARCHAR(3)),2) nmb,cast(SUBSTRING(REPLACE(CONVERT(char(10),start,126),'-',''),1,6) as integer) as [StartDate],
	--				DATENAME(mm,start) MnthName,DATENAME(yyyy,start) YearName from CalendarFrame
	--			)
		
		--select top 50 * from MonthlyCalendar


----=========================== Start of Recursive CTE Try ==============================================================================================
  ---------------  CTE Try 1 ------------------------------------------------------------------------------------------
 ----- Last 12 month-----

 ------ Get past 12 month and future 12 month -- below is my work draft - 28/5/2018
;WITH R(N,_T,T_,T,X,X2,XX,YY,start) AS
	(
	 select 1 as N,-24 as _T,24 as T_,-23 as T,24 as X,24 as X2
			,24 as XX,24 as YY,cast(DATEADD(mm, DATEDIFF(mm, 0, GETDATE())-24, 0) as datetime) as start
	 UNION ALL
	 select  N+1, _T+1,T_-1,case when T+1<0 then T+1 else case when T+1 =0 then 1 else T+1 end end as T	
							,case when X-1 >= 0  then X-1			-- this algorithm is complicated
							   else  					   
								      case when X > 1 then X+1
										 else X+ 1  
                                      end
								end as X
                             
                            ,case when N >= 24  then _T+1			-- this is simple algorithm because use N 
							   else  					   
								     X
								end as X2

                            ,case when N >= 24  then _T+1
							   else  					   
								     X-1
								end as XX
                           ,case when N >= 24  then T							     
							   else  
							       YY-1
								end as YY
			 ,dateadd(mm,1,start)
	  from R
	 where N < 49
	)
select * from r
select R.N,case when R._T < 0 then R.T_ else R._T end as T, start  
----------------- Below is production code----------------------------------------------------

;WITH R(N,_T,T_,T,XX,YY,start) AS
	(
	 select 1 as N,-24 as _T,24 as T_,-23 as T,24 as XX,24 as YY,cast(DATEADD(mm, DATEDIFF(mm, 0, GETDATE())-24, 0) as datetime) as start      -- pay attention T starts -23,you need this so you can get XXX Column/Field in current month you start as 1, otherwise you can use XX field
	 UNION ALL
	 select  N+1, _T+1,T_-1,case when T+1<0 then T+1 else case when T+1 =0 then 1 else T+1 end end as T						
                            ,case when N >= 24  then _T+1
							   else  
							       XX-1
								end as XX
                             ,case when N >= 24  then T							     
							   else  
							       YY-1
								end as YY
			 ,dateadd(mm,1,start)
	  from R
	 where N < 49
	)
select * from r
--select R.N,case when R._T < 0 then R.T_ else R._T end as T, start  
--from R

------------------------------
;WITH R(N) AS
(
SELECT 0
UNION ALL
SELECT N+1 
FROM R
WHERE N < 12
)
SELECT  n as rnk
		,LEFT(datename(month,dateadd(month,N,GETDATE())),3) AS [month_name]
        ,datepart(month,dateadd(month,-N,GETDATE())) AS [month]
        ,datepart(year,dateadd(month,-N,GETDATE())) AS [year]		
FROM R
order by rnk desc


 ---------------  CTE Try 2 ---------------------------------------------------------------------------------------------------------
  ------------- Alan's New code ------------------ 29/5/2018 -------------------------------------------------------------------
	 ;WITH R(N,_T,T_,T,XX,YY,start) AS
			(
			 select 1 as N,-24 as _T,24 as T_,-23 as T,24 as XX,24 as YY,cast(DATEADD(mm, DATEDIFF(mm, 0, GETDATE())-24, 0) as datetime) as start      -- pay attention T starts -23,you need this so you can get XXX Column/Field in current month you start as 1, otherwise you can use XX field
			 UNION ALL
			 select  N+1, _T+1,T_-1,case when T+1<0 then T+1 else case when T+1 =0 then 1 else T+1 end end as T						
									,case when N >= 24  then _T+1
									   else  
										   XX-1
										end as XX
									 ,case when N >= 24  then T							     
									   else  
										   YY-1
										end as YY
					 ,dateadd(mm,1,start)
			  from R
			 where N < 49
			)
		--select * from r
		--select R.N,case when R._T < 0 then R.T_ else R._T end as T, start from R
		--select R.N,case when R._T < 0 then R.T_ else R.YY end as T, start from R
	  ,MthCal as (
						select  n as rnk
						 ,YY 
						,cast(SUBSTRING(REPLACE(CONVERT(char(10),start,126),'-',''),1,6) as integer) as [StartDt]		
						,LEFT(datename(month,start),3) AS [month_name]
						,datepart(month,start) AS [month]
						,datepart(year,start) AS [year]				
				       from R  )
     -- select * from MthCal

------------------ CTE Try 3 ----------------------------------------------------------------
------------- Alan's New code ------------------ 29/5/2018 -------------------------------------------------------------------
	 ;WITH R(N,_T,T_,T,XX,YY,start) AS
			(
			 select 1 as N,-24 as _T,24 as T_,-23 as T,24 as XX,24 as YY,cast(DATEADD(mm, DATEDIFF(mm, 0, GETDATE())-24, 0) as datetime) as start      -- pay attention T starts -23,you need this so you can get XXX Column/Field in current month you start as 1, otherwise you can use XX field
			 UNION ALL
			 select  N+1, _T+1,T_-1,case when T+1<0 then T+1 else case when T+1 =0 then 1 else T+1 end end as T						
									,case when N >= 24  then _T+1
									   else  
										   XX-1
										end as XX
									 ,case when N >= 24  then T							     
									   else  
										   YY-1
										end as YY
					 ,dateadd(mm,1,start)
			  from R
			 where N < 49
			)
		--select * from r
		--select R.N,case when R._T < 0 then R.T_ else R._T end as T, start from R
		--select R.N,case when R._T < 0 then R.T_ else R.YY end as T, start from R
	  ,MthCal as (
						select  n as rnk
						 ,YY 
						,cast(SUBSTRING(REPLACE(CONVERT(char(10),start,126),'-',''),1,6) as integer) as [StartDt]		
						,LEFT(datename(month,start),3) AS [month_name]
						,datepart(month,start) AS [month]
						,datepart(year,start) AS [year]				
				       from R  )
     -- select * from MthCal

----------------------- CTE Try 4 ---------------------------------------------------------------
	 ------------- Alan's New code ------------------ 29/5/2018 -------------------------------------------------------------------
	 ;WITH R(N,_T,T_,T,XX,YY,start) AS
			(
			 select 1 as N,-24 as _T,24 as T_,-23 as T,24 as XX,24 as YY,cast(DATEADD(mm, DATEDIFF(mm, 0, GETDATE())-24, 0) as datetime) as start      -- pay attention T starts -23,you need this so you can get XXX Column/Field in current month you start as 1, otherwise you can use XX field
			 UNION ALL
			 select  N+1, _T+1,T_-1,case when T+1<0 then T+1 else case when T+1 =0 then 1 else T+1 end end as T						
									,case when N >= 24  then _T+1
									   else  
										   XX-1
										end as XX
									 ,case when N >= 24  then T							     
									   else  
										   YY-1
										end as YY
					 ,dateadd(mm,1,start)
			  from R
			 where N < 49
			)
		--select * from r
		--select R.N,case when R._T < 0 then R.T_ else R._T end as T, start from R
		--select R.N,case when R._T < 0 then R.T_ else R.YY end as T, start from R
	  ,MthCal as (
						select  n as rnk
						 ,YY 
						,cast(SUBSTRING(REPLACE(CONVERT(char(10),start,126),'-',''),1,6) as integer) as [StartDt]		
						,LEFT(datename(month,start),3) AS [month_name]
						,datepart(month,start) AS [month]
						,datepart(year,start) AS [year]				
				       from R  )
     -- select * from MthCal
----=========================== End of Recursive CTE Try ==========================================================================


select distinct fch.ItemNumber from JDE_DB_Alan.FCPRO_Fcst_History fch  where fch.ReportDate = '2018-02-28 15:00:00.000' and fch.Date = '2018-04-01 00:00:00.000'
	--where --fch.ReportDate = select dateadd(d,-1,DATEADD(mm, DATEDIFF(m,0,GETDATE())-2,0)) and	    --2018-02-28 00:00:00.000
		--fch.ItemNumber in ('42.210.031') and fch.ReportDate = '2018-02-28 15:00:00.000'
select * from JDE_DB_Alan.vw_Mast m where m.ItemNumber in ('42.210.031')
select * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h where h.ItemNumber in ('42.210.031')


 ---------------- Alan's New code ------------------ 1/6/2018 -------------------------------------------------------------------
  ;WITH R(N,_T,T_,T,XX,YY,start) AS
			(
			 select 1 as N,-24 as _T,24 as T_,-23 as T,24 as XX,24 as YY,cast(DATEADD(mm, DATEDIFF(mm, 0, GETDATE())-24, 0) as datetime) as start      -- pay attention T starts -23,you need this so you can get XXX Column/Field in current month you start as 1, otherwise you can use XX field
			 UNION ALL
			 select  N+1, _T+1,T_-1,case when T+1<0 then T+1 else case when T+1 =0 then 1 else T+1 end end as T						
									,case when N >= 24  then _T+1
									   else  
										   XX-1
										end as XX
									 ,case when N >= 24  then T							     
									   else  
										   YY-1
										end as YY
					 ,dateadd(mm,1,start)
			  from R
			 where N < 49
			)
		--select * from r
		--select R.N,case when R._T < 0 then R.T_ else R._T end as T, start from R
		--select R.N,case when R._T < 0 then R.T_ else R.YY end as T, start from R
	  ,MthCal as (
						select  n as rnk
						 ,YY 
						,cast(SUBSTRING(REPLACE(CONVERT(char(10),start,126),'-',''),1,6) as integer) as [StartDt]		
						,LEFT(datename(month,start),3) AS [month_name]
						,datepart(month,start) AS [month]
						,datepart(year,start) AS [year]				
				       from R  )
     -- select * from MthCal
	 ,f as ( select fch.*
					,cast(SUBSTRING(REPLACE(CONVERT(char(10),fch.ReportDate,126),'-',''),1,6) as integer) as [StartDate]						
			  from JDE_DB_Alan.FCPRO_Fcst_History fch
					-- where h.ItemNumber in ('42.210.031')
					)
	  ,fc as ( select f.ItemNumber as Itm,f.DataType1,f.Date,f.StartDate,f.Value,f.ReportDate,c.*							--- join cal to get YY value which is your month rank/order
				    
				from f left join MthCal c on f.StartDate = c.StartDt												--- no need to cross join cal table as FC tb always has data in 24 mth				
			  -- where fc.ItemNumber = ('42.210.031') order by fc.ItemNumber,fc.StartDt,fc.Date
	            )
       
	   ------------------------------------      
		--- LT offset FC ---
      ,fct as ( -- select *
	            select fc.Itm,fc.DataType1,fc.Date,fc.StartDt,fc.Value,fc.ReportDate,fc.YY,fc.rnk,fc.month				 -- inner join --- so remove all records which does not meet condition - In another words I am only interested and only want SKU that has 3 month lead time. Of course you can use Left join to achiece same result, if you use inner join it is important to include all records of Master data in vw_Mast table though, otherwise you will lose some data --- 30/5/2018
	            from fc inner join JDE_DB_Alan.vw_Mast m on fc.Itm = m.ItemNumber and fc.YY= m.Leadtime_Mth+1			-- LT calculation: LT plus 1 month since FC was saved last day of month - if 2 month then need to consider 60 days, 3 month need to consider 90 days
				where fc.Date =  DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0)											-- get monthly fc in this case --> FC of '2018-04-01' this is FC you want to measure
				       --and fc.Date =  '2018-04-01 00:00:00.000'	
				)	
							
		  --- Non LT offset FC ---
      ,fctt as ( -- select *
	            select fc.Itm,fc.DataType1,fc.Date,fc.StartDt,fc.Value,fc.ReportDate,fc.YY,fc.rnk,fc.month				 -- inner join
	            from fc 																							  --- No Need to use Join you simply fetch last month FC
				where    fc.StartDt	 = cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-2,0),126),'-',''),1,6) as integer)  	--LT calculation: Capped to 2 mth ago, since last month you will have FC only for next month   --- '201803'   -- Performance issue ?
						  --and fc.StartDt = '201803'																									-- hard coded LT			
						  --and fc.YY = 2 and fc.rnk = 23																		-- 	Capped to 2 mth ago	
						  and fc.Date = DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0)											-- get monthly fc in this case --> FC of '2018-04-01' this is FC you want to measure
							--and fc.Date =  '2018-04-01 00:00:00.000'	
					)			
										
	    --select * from fctt  where fct.Itm in ('82.501.904','42.210.031')
		--select * from fctt  where fctt.Itm in ('42.210.031')			

	  ------- Last Month Histry --- If you are in May, Need April History ( compared with April FC though) ,Not May History !  --------------

		  		----- below is tb NOT padded with 0 sales history --- straight from SlsHist tb
		,histt as ( select h.ItemNumber,h.CYM,h.CY,h.Month,h.SalesQty,h.ReportDate
							,c.YY,c.rnk,c.StartDt,c.month as mth
	               from  JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h left join MthCal c on h.CYM = c.StartDt	
				   where     h.CYM = cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-',''),1,6) as integer)			-- Performance issue ?
				           -- h.CYM = '201804' and
				           --c.rnk =24						--- last month ( for last month Sales)
				   )

		,SlsItm as ( select distinct h.ItemNumber as ItemNumber_ from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h )
		,SlsList as ( select * from SlsItm cross join MthCal c 
					 -- where   c.StartDt between replace(convert(varchar(8), DATEADD(mm, DATEDIFF(m,0,GETDATE())-12,0),126),'-','' )			-- last 12 months		
					  --				 and  replace(convert(varchar(8), DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-','' )		   -- last 12 months
							)		     
			
		     ----- below is tb padded Item with all Months ---
		,hist as																													
		(  select list.ItemNumber_,h.CYM,h.CY,h.Month
					,case when h.SalesQty is null then 0 else h.SalesQty end as SalesQty,h.ReportDate
			       ,list.YY,list.rnk,list.StartDt,list.month as mth
				  ,case 
						when h.CYM is null	then cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-',''),1,6) as integer) 
						else h.CYM
					end as CYM_
			from SlsList list left join JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h on list.StartDt = h.CYM and  list.ItemNumber_ = h.ItemNumber
			where    list.StartDt = cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-',''),1,6) as integer)			-- Watch out use List.StartDt Not h.CYM !!!   --- 29/5/2018
					-- h.CYM = '201804' and																													-- Performance issue ?
					--c.rnk =24																												-- last month ( for last month Sales)
				)
          -- select * from hist where hist.ItemNumber_ in ('82.501.904')

		   --- **************************************
		   --- Accuracy use Non-Lead Time offset
		   --- **************************************
		  ,comVoll_ as 
		   ( select 'Units' as DataType,fctt.Itm,hist.ItemNumber_,hist.SalesQty as Sales,fctt.Value as Fcst,fctt.StartDt
		            ,SalesQty - fctt.Value as Bias,ABS(SalesQty -  fctt.Value) as ABS
		       from fctt full outer join hist on fctt.Itm = hist.ItemNumber_)		
			   
			 -- select * from comVol_ c where c.ItemNumber_ in ('TUFA20') 				   				           
	     ,_comVoll as 
		   ( select 'Units' as DataType
					,case when fctt.Itm is null then hist.ItemNumber_ else fctt.Itm end as Item					
					,isnull(hist.SalesQty,0) as Sales,isnull(fctt.Value,0) as Fcst
					,fctt.Date
					,case when fctt.Date is null then DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0) else fctt.Date end as Date_				--- 
					,fctt.StartDt
		            ,isnull((SalesQty - fctt.Value),0)as BiasVol,isnull(ABS(SalesQty -  fctt.Value),0) as ABSVol
					,coalesce(isnull(abs(SalesQty - fctt.Value),0)/nullif(hist.SalesQty,0),0) as ErrPct
					,1-(coalesce(isnull(abs(SalesQty - fctt.Value),0)/nullif(hist.SalesQty,0),0)) as AccuracyPct
		       from fctt full outer join hist on fctt.Itm = hist.ItemNumber_
			   )
            
         ,zeroo as ( select * from _comVoll where _comVoll.Fcst =0 and _comVoll.Sales=0)
		--select * from zero		
		,comVoll as (   select * from _comVoll 
						-- where _comVoll.Item not in ( select zeroo.Item from zeroo )					  --- works but not ideal usijng 'Not in'   -1/6/2018
						 where not exists ( select zeroo.Item from zeroo where zeroo.Item = _comVoll.Item)   -- better using 'Not exists' --- https://stackoverflow.com/questions/1662902/when-to-use-except-as-opposed-to-not-exists-in-transact-sql --  Also note ,if any row of that subquery returns NULL, the entire NOT IN operator will evaluate to either FALSE or UNKNOWN and no records will be returned
		             --  where comVol.Item in ('82.501.904')

			          )
         ,f_comVoll as ( select c.*,m.Description,m.Family_0,m.FamilyGroup_
								,m.WholeSalePrice
								,c.Sales*m.WholeSalePrice as SlsAmt
								,c.Fcst*m.WholeSalePrice  as FcstAmt
								,BiasVol * m.WholeSalePrice as Bias_Amt
								,ABSVol * m.WholeSalePrice as ABS_Amt
								,coalesce((ABSVol * m.WholeSalePrice)/nullif(c.Sales*m.WholeSalePrice,0),0) as ErrPct_Amt
								,1-(coalesce((ABSVol * m.WholeSalePrice)/nullif(c.Sales*m.WholeSalePrice,0),0)) as AccuracyPct_Amt
								,m.PrimarySupplier,m.PlannerNumber
		                 from _comVoll c left join JDE_DB_Alan.vw_Mast m on c.Item = m.ItemNumber )
           -- select * from f_comVoll

         ,combb as ( select fl.DataType,fl.Item,fl.Sales,fl.Fcst,fl.Date_,fl.StartDt,fl.BiasVol as Bias,fl.ABSVol as ABS_,fl.ErrPct,fl.AccuracyPct,fl.Description,fl.Family_0,fl.FamilyGroup_,fl.PrimarySupplier,fl.PlannerNumber,GETDATE() as ReportDate
						from f_comVoll fl
                    union all
					select 'Dollars' as DataType,fl.Item,fl.SlsAmt,fl.FcstAmt,fl.Date_,fl.StartDt,fl.Bias_Amt as Bias,fl.ABS_Amt as ABS_,fl.ErrPct_Amt,fl.AccuracyPct_Amt,fl.Description,fl.Family_0,fl.FamilyGroup_,fl.PrimarySupplier,fl.PlannerNumber,GETDATE() as ReportDate  
					   from f_comVoll fl
		           )

         --select * from combb
		   --- **************************************
		   --- Accuracy use Lead Time offset
		   --- **************************************

		  	,comVol_ as 
		   ( select 'Units' as DataType,fct.Itm,hist.ItemNumber_,hist.SalesQty as Sales,fct.Value as Fcst,fct.StartDt
		            ,SalesQty - fct.Value as Bias,ABS(SalesQty -  fct.Value) as ABS
		       from fct full outer join hist on fct.Itm = hist.ItemNumber_)		
			   
			-- select * from comVol_ c where c.ItemNumber_ in ('18.317.005') 				   				           
	      ,_comVol as 
		   ( select 'Units' as DataType
					,case when fct.Itm is null then hist.ItemNumber_ else fct.Itm end as Item					
					,isnull(hist.SalesQty,0) as Sales,isnull(fct.Value,0) as Fcst
					,fct.Date,case when fct.Date is null then DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0) else fct.Date end as Date_
					,fct.StartDt
		            ,isnull((SalesQty - fct.Value),0)as BiasVol,isnull(ABS(SalesQty -  fct.Value),0) as ABSVol
					,coalesce(isnull(abs(SalesQty - fct.Value),0)/nullif(hist.SalesQty,0),0) as ErrPct
					,1-(coalesce(isnull(abs(SalesQty - fct.Value),0)/nullif(hist.SalesQty,0),0)) as AccuracyPct
		       from fct full outer join hist on fct.Itm = hist.ItemNumber_
			   )
			   	
		,zero as ( select * from _comVol where _comVol.Fcst =0 and _comVol.Sales=0)
		--select * from zero		
		,comVol as ( select * from _comVol 
						-- where _comVol.Item not in ( select zero.Item from zero )					  --- works but not ideal usijng 'Not in'   -1/6/2018
						 where not exists ( select zero.Item from zero where zero.Item = _comVol.Item)   -- better using 'Not exists' --- https://stackoverflow.com/questions/1662902/when-to-use-except-as-opposed-to-not-exists-in-transact-sql -- Also note ,if any row of that subquery returns NULL, the entire NOT IN operator will evaluate to either FALSE or UNKNOWN and no records will be returned
		             --  where comVol.Item in ('82.501.904')
				
			          )
         ,f_comVol as ( select c.*,m.Description,m.Family_0,m.FamilyGroup_
								,m.WholeSalePrice
								,c.Sales*m.WholeSalePrice as SlsAmt
								,c.Fcst*m.WholeSalePrice  as FcstAmt
								,BiasVol * m.WholeSalePrice as Bias_Amt
								,ABSVol * m.WholeSalePrice as ABS_Amt
								,coalesce((ABSVol * m.WholeSalePrice)/nullif(c.Sales*m.WholeSalePrice,0),0) as ErrPct_Amt
								,1-(coalesce((ABSVol * m.WholeSalePrice)/nullif(c.Sales*m.WholeSalePrice,0),0)) as AccuracyPct_Amt
								,m.PrimarySupplier,m.PlannerNumber
		                 from _comVol c left join JDE_DB_Alan.vw_Mast m on c.Item = m.ItemNumber )
          --select * from f_comVol

         ,comb as ( select fl.DataType,fl.Item,fl.Sales,fl.Fcst,fl.Date_,fl.StartDt,fl.BiasVol as Bias,fl.ABSVol as ABS_,fl.ErrPct,fl.AccuracyPct,fl.Description,fl.Family_0,fl.FamilyGroup_,fl.PrimarySupplier,fl.PlannerNumber,getdate() as ReportDate
						from f_comVol fl
                    union all
					select 'Dollars' as DataType,fl.Item,fl.SlsAmt,fl.FcstAmt,fl.Date_,fl.StartDt,fl.Bias_Amt as Bias,fl.ABS_Amt as ABS_,fl.ErrPct_Amt,fl.AccuracyPct_Amt,fl.Description,fl.Family_0,fl.FamilyGroup_,fl.PrimarySupplier,fl.PlannerNumber,getdate() as ReportDate  
					   from f_comVol fl
		           )
          
		  select * from combb
       		insert into JDE_DB_Alan.FCPRO_Fcst_Accuracy  select * from comb
			select * from JDE_DB_Alan.FCPRO_Fcst_Accuracy


exec JDE_DB_Alan.sp_FCPro_FC_Accy_Rpt_New 'LT'					--old, changed sp name
exec JDE_DB_Alan.sp_FCPro_FC_Accy_Rpt_New 'Non_LT'


select * from JDE_DB_Alan.FCPRO_Fcst_Accuracy y
where datepart(year,y.ReportDate) = 2018 and datepart(MONTH,y.ReportDate) = 8
      and  y.Item in ('42.210.031')  


----------------------------------------------------------------------------------------
exec JDE_DB_Alan.sp_FCPro_FC_Accy_SKU 'LT'
select * from JDE_DB_Alan.FCPRO_FC_Accy_SKU


-------------------------------------------------------------------------------------------
exec JDE_DB_Alan.sp_FCPro_FC_Accy_Group
select * from JDE_DB_Alan.FCPRO_FC_Accy_Group



-- Nice way to get records in Accuracy table ---
 ;with cte as 
  (
	  select convert(varchar(13),y.ReportDate,120) as Date_Uploaded
				,count(*)  as Records_Uploaded
	  from JDE_DB_Alan.FCPRO_Fcst_Accuracy y
	  group by  convert(varchar(13),y.ReportDate,120) )
  
  select *, sum(cte.Records_Uploaded) over (order by Date_Uploaded) TTL_Records_AccuTbl from cte 
 -- where cte.Date_Uploaded between '2018-05-01' and '2018-05-25'
  order by cte.Date_Uploaded asc



---============================ End of Forecast Accuracy =======================================================================================================================================


---=========================== Override FC Pro FC , Generate Override File ( dataSet)  works ! pay attention to Order by clause  1/2/2018 ===========================================================

--------------- FC Overrides in FC Pro 25/1/2018-------------------------
with cte as (
            select m.*
					,row_number() over(partition by m.itemNumber order by itemnumber ) as rn  
			from  JDE_DB_Alan.Master_ML345 m )
     ,cte_ as (
				select * from cte where rn =1  
			--order by m.ItemNumber
			 )

select f.ItemNumber
	   ,f.Date
	   ,f.Value
from JDE_DB_Alan.FCPRO_Fcst f left join cte_ on f.ItemNumber = cte_.ItemNumber
where f.ItemNumber  in ('27.164.882') and f.DataType1 in ('Adj_FC')



--------------- Create FC Overrides File for FC Pro Uploading Using MI File ( Comptible with FC PRo Format with Date/Hierarchy ) --- 25/1/2018, 2/2/2018-------------------------
--use JDE_DB_Alan
--go

with cte as (
            select m.*
					,row_number() over(partition by m.itemNumber order by itemnumber ) as rn  
			from  JDE_DB_Alan.Master_ML345 m )
     ,cte_ as (
				select * from cte where rn =1  
			--order by m.ItemNumber
			 )
    -- ,ref_ as ( select *
	--				 ,row_number() over(partition by rf.itemNumber order by rf.Xref_Type) as rn 
	--			from JDE_DB_Alan.Master_ItemCrossRef rf where rf.Address_Number in ('20037'))		--please note there might be same item Number under multi suppliers!So need to filter here !
    --  ,ref as ( select * from ref_ where rn=1)
	
		ref_ as (
				select *
				,rank() over (partition by ItemNumber,Address_Number order by c.expireddate desc ) as myrnk					-- cannot use Expireddate as it is not maintained properly 1/5/2018
				,row_number() over(partition by ItemNumber,Address_Number order by Address_Number desc ) as rnk_							--- Since A Sku can be produced by multiple supplie 	
				,max(c.ExpiredDate) over(partition by ItemNumber order by Address_Number desc ) as max_expir_date		-- please note address_number for 02.060.000 are 1543934,20015,30482,503666 which are all pointed to supplier 155235 which is primary supplier for SKU 02.060.000, this SKU might have multiple (5) supplier against it. however, JDE 'Supplier_Cross_Ref' table as default choose the primary supplier (155235) and put its relevant supplier ref product code in this table. YOu can see for supplier 155235 we changed reference 4 times. 1/5/2018
				,max(c.EffectiveDate) over(partition by ItemNumber order by ItemNumber desc ) as max_effec_date
				,rank() over (partition by ItemNumber  order by c.effectivedate desc ) as rnk							-- use effective  datea as bench mark
				from JDE_DB_Alan.Master_ItemCrossRef c 
				--where c.ItemNumber in ('2950100000') 
				--where c.ItemNumber in ('28.536.850','02.060.000')  
			)
		 ,ref as 
			( select * from cte where cte.rnk = 1 
			 )
		 --select * from cte_ where cte_.ItemNumber in ('28.536.850','02.060.000') 
		 --  select cte_.ItemNumber,count(cte_.Xref_Type) myct from cte_  group by cte_.ItemNumber order by myct desc



     ,fc as ( select f.*
	                  --,f.Date as Date_
				      ,convert(varchar(21),f.Date,103) as SimpDate
					  ,convert(varchar(4),f.date, 111) +'-'+ left (datename(mm,DATEADD(dd, DATEDIFF(d,0,f.Date)+1,0)),3) as WrongDate			-- wrong date as it will not advance year digit
					  ,convert(varchar(10),DATEADD(dd, DATEDIFF(d,0,f.Date)+1,0),120) as Right_Date
					  ,left(datename(mm,DATEADD(dd, DATEDIFF(d,0,f.Date)+1,0)),3) as Right_MthName
					  ,left(convert(varchar(10),DATEADD(dd, DATEDIFF(d,0,f.Date)+1,0),120),4) +'-'+ left(datename(mm,DATEADD(dd, DATEDIFF(d,0,f.Date)+1,0)),3) as Date_pro
					  ,convert(varchar(10),DATEADD(dd, DATEDIFF(d,0,f.Date)+1,0),120) as Date_
					-- ,cast(DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,GETDATE())+5,0)) as datetime) as startdate			-- Set the StartDate for changing from Jun/2018 onwards
					,'2018-02-01' as startdate1			-- Set the StartDate for changing from Jun/2018 onwards
					,'2018-06-01' as startdate2
			  from JDE_DB_Alan.JDE_Fcst_DL f
				 )
      -- select * from fc where fc.ItemNumber in ('27.161.320')
    
      ,_fc as (																										-- this is Monthly SKU level data
				select 'Total' as RowLabel
				        ,cte_.SellingGroup
						,cte_.FamilyGroup
						,cte_.Family
					    ,fc.ItemNumber
					   ,fc.Date_ 
					   ,fc.Date_pro
					   ,'Override 1' as Row
					   ,isnull(fc.Qty,0) as Baseline
					   ,case 
							when fc.Date_ >= fc.startdate1 and CHARINDEX('70%',mi.Comment) >0 and CHARINDEX('now',lower(mi.Comment)) >0 then isnull(fc.Qty,0) *0.3			-- when comments has '70%' string
							when fc.Date_ >= fc.startdate2 and CHARINDEX('70%',mi.Comment) >0 and CHARINDEX('jun',lower(mi.Comment)) >0 then isnull(fc.Qty,0) *0.3
							when fc.Date_ >= fc.startdate1 and CHARINDEX('50%',mi.Comment) >0 and CHARINDEX('now',lower(mi.Comment)) >0 then isnull(fc.Qty,0) *0.5			-- when comments has '50%' string
							when fc.Date_ > fc.startdate2 and CHARINDEX('50%',mi.Comment) >0 and CHARINDEX('jun',lower(mi.Comment)) >0 then isnull(fc.Qty,0) *0.5
							when  CHARINDEX('obsolete',lower(mi.Comment)) >0 then isnull(fc.Qty,0) *0
							else isnull(fc.Qty,0)
						 end as Formula
                       ,case 
							when fc.Date_ >= fc.startdate1 and CHARINDEX('70%',mi.Comment) >0 and CHARINDEX('now',lower(mi.Comment)) >0 then isnull(fc.Qty,0) *0.3			-- when comments has '70%' string
							when fc.Date_ >= fc.startdate2 and CHARINDEX('70%',mi.Comment) >0 and CHARINDEX('jun',lower(mi.Comment)) >0 then isnull(fc.Qty,0) *0.3
							when fc.Date_ >= fc.startdate1 and CHARINDEX('50%',mi.Comment) >0 and CHARINDEX('now',lower(mi.Comment)) >0 then isnull(fc.Qty,0) *0.5			-- when comments has '50%' string
							when fc.Date_ > fc.startdate2 and CHARINDEX('50%',mi.Comment) >0 and CHARINDEX('jun',lower(mi.Comment)) >0 then isnull(fc.Qty,0) *0.5
							when  CHARINDEX('obsolete',lower(mi.Comment)) >0 then isnull(fc.Qty,0) *0
							else isnull(fc.Qty,0)
						 end as Override
                       ,mi.Comment
					   ,mi.LastUpdated
					   ,cte_.Description
					   ,ref.Customer_Supplier_ItemNumber
					   ,ref.Address_Number
					   ,sum(isnull(fc.Qty,0)) over( partition by fc.itemnumber) as FC_OrigQty_24m
				from fc	 left join  ref on fc.ShortItemNunber = ref.ShortItemNumber		--please note there might be same item Number under multi suppliers !
						 left join cte_ on fc.ItemNumber = cte_.ItemNumber
				         left join JDE_DB_Alan.FCPRO_MI_tmp mi on fc.ItemNumber = mi.ItemNumber
						
				where  ref.Address_Number in ('20037')
						--and fc.ItemNumber  in ('27.176.320')
						
				)
             -- select * from _fc
	  ,stg as 
			(select  _fc.*
					,c.LongDescription as SellingGroup_
					,d.LongDescription as FamilyGroup_
					,e.LongDescription as Family_0
					--,tbl.Family as Family_1
					--,f.StandardCost,f.WholeSalePrice
					,p.Pareto
			from _fc left join JDE_DB_Alan.MasterSellingGroup c  on _fc.SellingGroup = c.Code
					 left join JDE_DB_Alan.MasterFamilyGroup d  on _fc.FamilyGroup = d.Code
					 left join JDE_DB_Alan.MasterFamily e  on _fc.Family = e.Code
					 left join JDE_DB_Alan.FCPRO_Fcst_Pareto p on _fc.ItemNumber = p.ItemNumber
			   )

      ,fc_ as ( select stg.RowLabel,SellingGroup_ as SellingGroup,stg.FamilyGroup_ as FamilyGroup,stg.Family_0 as Family,stg.ItemNumber
                      ,stg.Date_ as date_
					  ,stg.Date_pro as date											--- for FC Pro  Date Format  		 
						,stg.Row			
					  ,stg.Baseline,stg.Formula,stg.Override,stg.Comment
					  --,stg.LastUpdated	
					  ,convert(varchar(21),stg.LastUpdated,103) as LastUpdated_					--- for FC Pro  Date Format
					  ,stg.Pareto
				from stg )
   
   --------- Execute elow to Output Format for Overrideing for Uploading into FC Pro  ---------
   select * 																					
   from fc_ 
   where fc_.Comment is not null 
			--and fc_.ItemNumber in ('27.160.320','2770002534')
			--  and fc_.ItemNumber in ('27.160.785')
			--and fc_.ItemNumber in ('2770011785')
   order by fc_.ItemNumber
            ,left(fc_.date,4) 
            ,case  right(fc_.Date,3) when 'Jan' then 1
									 when 'Feb' then 2
									 when 'Mar' then 3
									 when 'Apr' then 4
									 when 'May' then 5
									 when 'Jun' then 6
									 when 'Jul' then 7
									 when 'Aug' then 8
									 when 'Sep' then 9
									 when 'Oct' then 10
									 when 'Nov' then 11
									 when 'Dec' then 12
			  end 
   			 
  --   select * from fc_  where  fc_.Comment is not null and fc_.ItemNumber in ('27.164.882')			---- Sanity check one Item, works 1/2/2018
	 -- select fc_.ItemNumber,fc_.Comment,sum(isnull(fc_.Baseline,0)) as FC_TTL							--- Sanity check to make sure total SKU count is correct, works 1/2/2018				
		--from fc_ where fc_.Comment is not null
		--group by fc_.ItemNumber,fc_.Comment 


--select * from JDE_DB_Alan.JDE_Fcst_DL dl where dl.ItemNumber in ('27.264.850')

  -------- Execute Below to Output Format for Product Team (b Diana A)  -----------
 --  select _fc.ItemNumber,_fc.Description,_fc.Customer_Supplier_ItemNumber,_fc.Address_Number,_fc.Comment		--- Output Format for Diana A,Note dataSet is from '_fc',it is same source of dataset for'fc',but include more fields, since format for Uploading and format for Diana A ( product team ) are required differently 1/2/2018
	--		,avg(_fc.FC_OrigQty_24m) as FC_OrigQty_24m_				
	--from _fc
	----'where fc_.ItemNumber in ('27.164.882')
	----'where fc_.ItemNumber in ('2974000000','F8174A977')					-- ML345 - primarysupplier no is nil --need to update 25/1/2018
	--where  _fc.Comment is not null --and _fc.ItemNumber in ('27.164.882')
	--group by _fc.ItemNumber,_fc.Description,_fc.Customer_Supplier_ItemNumber,_fc.Address_Number,_fc.Comment
 --  order by 
 --           case when upper(substring(Comment,1,1))= 'W' then 1									-- Custom Order by Clause , Yeah !
	--			 when upper(substring(Comment,1,6))= 'MOVING' then 2
	--			 when upper(substring(Comment,1,1))= 'T' then 3
	--			 when upper(substring(Comment,1,1))= 'R' then 4
	--			 when upper(substring(Comment,1,1))= 'S' then 5
	--             when upper(substring(Comment,1,1))= 'D' then 6
	--			 when upper(substring(Comment,1,1))= 'M' then 7
 --             end desc
	--		  ,FC_OrigQty_24m_ desc

--select * 
--from JDE_DB_Alan.FCPRO_MI_tmp
--   order by 
--            case when upper(substring(Comment,1,1))= 'W' then 1									-- Custom Order by Clause , Yeah !
--				 when upper(substring(Comment,1,6))= 'MOVING' then 2
--				 when upper(substring(Comment,1,1))= 'T' then 3
--				 when upper(substring(Comment,1,1))= 'R' then 4
--				 when upper(substring(Comment,1,1))= 'S' then 5
--	             when upper(substring(Comment,1,1))= 'D' then 6
--				 when upper(substring(Comment,1,1))= 'M' then 7
--              end desc
----------------------------------------------------------------------------------------------------------

--select cast(DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,GETDATE())+6,0)) as datetime)
 --select cast(DATEADD(mm, DATEDIFF(mm, 0, '2018-04-01 00:00:00')+6, 0) as datetime) 
--select cast(DATEADD(mm, DATEDIFF(mm, 0, GETDATE())-24, 0) as datetime) 

--select cast(DATEADD(mm, DATEDIFF(mm, 0, GETDATE())+1, 0)) as datetime
--select convert(varchar(10),cast(DATEADD(mm, DATEDIFF(mm, 0, GETDATE())+1, 0) as datetime),103)
--select DATEDIFF(mm, 0, GETDATE())


------------------ Create FC Overrides File for FC Pro Uploading Using NP File ( Comptible with FC PRo Format with Date/Hierarchy ) --- 7/2/2018 , 15/2/2018-------------------------
--use JDE_DB_Alan
--go

;with cte as (
				select m.*
						,row_number() over(partition by m.itemNumber order by itemnumber ) as rn 
				from JDE_DB_Alan.Master_ML345 m )
	,cte_ as (
					select * from cte where rn =1 
					--order by m.ItemNumber
				 )
	--,ref_ as ( select *
	--					 ,row_number() over(partition by rf.itemNumber order by rf.Xref_Type) as rn 
	--			from JDE_DB_Alan.Master_ItemCrossRef rf where rf.Address_Number in ('20037'))		--please note there might be same item Number under multi suppliers!So need to filter here !
	--,ref as ( select * from ref_ where rn=1)

		
	ref_ as (
				select *
				,rank() over (partition by ItemNumber,Address_Number order by c.expireddate desc ) as myrnk					-- cannot use Expireddate as it is not maintained properly 1/5/2018
				,row_number() over(partition by ItemNumber,Address_Number order by Address_Number desc ) as rnk_							--- Since A Sku can be produced by multiple supplie 	
				,max(c.ExpiredDate) over(partition by ItemNumber order by Address_Number desc ) as max_expir_date		-- please note address_number for 02.060.000 are 1543934,20015,30482,503666 which are all pointed to supplier 155235 which is primary supplier for SKU 02.060.000, this SKU might have multiple (5) supplier against it. however, JDE 'Supplier_Cross_Ref' table as default choose the primary supplier (155235) and put its relevant supplier ref product code in this table. YOu can see for supplier 155235 we changed reference 4 times. 1/5/2018
				,max(c.EffectiveDate) over(partition by ItemNumber order by ItemNumber desc ) as max_effec_date
				,rank() over (partition by ItemNumber  order by c.effectivedate desc ) as rnk							-- use effective  datea as bench mark
				from JDE_DB_Alan.Master_ItemCrossRef c 
				--where c.ItemNumber in ('2950100000') 
				--where c.ItemNumber in ('28.536.850','02.060.000')  
			)
		 ,ref as 
			( select * from cte where cte.rnk = 1 
			 )
		 --select * from cte_ where cte_.ItemNumber in ('28.536.850','02.060.000') 
		 --  select cte_.ItemNumber,count(cte_.Xref_Type) myct from cte_  group by cte_.ItemNumber order by myct desc



	,npfc as ( select f.*
		 --,f.Date as Date_
					 ,convert(varchar(21),f.Date,103) as SimpDate
						 ,convert(varchar(4),f.date, 111) +'-'+ left (datename(mm,DATEADD(dd, DATEDIFF(d,0,f.Date)+1,0)),3) as WrongDate			-- wrong date as it will not advance year digit
						 ,convert(varchar(10),DATEADD(dd, DATEDIFF(d,0,f.Date)+1,0),120) as Right_Date
						 ,left(datename(mm,DATEADD(dd, DATEDIFF(d,0,f.Date)+1,0)),3) as Right_MthName
						 ,left(convert(varchar(10),DATEADD(dd, DATEDIFF(d,0,f.Date)+1,0),120),4) +'-'+ left(datename(mm,DATEADD(dd, DATEDIFF(d,0,f.Date)+1,0)),3) as Date_pro
						 ,convert(varchar(10),DATEADD(dd, DATEDIFF(d,0,f.Date)+1,0),120) as Date_
						-- ,cast(DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,GETDATE())+5,0)) as datetime) as startdate			-- Set the StartDate for changing from Jun/2018 onwards
						,'2018-02-01' as startdate1			-- Set the StartDate for changing from Jun/2018 onwards
						,'2018-06-01' as startdate2
				 from JDE_DB_Alan.FCPRO_NP_tmp f
				 where f.Value >0			--- Need to pick up FC Value from launch date -- 14/2/2018
					 )
	--select * from fc where fc.ItemNumber in ('2801381661','34.523.000,')
	,_npfc as (																										-- this is Monthly SKU level data
					select 'Total' as RowLabel
					 ,cte_.SellingGroup
							,cte_.FamilyGroup
							,cte_.Family
						 ,npfc.ItemNumber
						 ,npfc.Date_ 
						 ,npfc.Date_pro
						 --,'Override 1' as Row
						 ,'NP' as Row
						 ,isnull(npfc.Value,0) as Baseline
						 ,isnull(npfc.Value,0)as Formula
						,isnull(npfc.Value,0) as Override
						,npfc.Comment
						 ,npfc.LastUpdated
						 ,cte_.Description					 
					from npfc	 -- left join ref on fc.ItemNumber = ref.ItemNumber		--please note there might be same item Number under multi suppliers !
							 left join cte_ on npfc.ItemNumber = cte_.ItemNumber				 
						
					 --where ref.Address_Number in ('20037')
							--and fc.ItemNumber in ('27.176.320')						
					) 
		 ,stg as 
				(select _npfc.*
						,c.LongDescription as SellingGroup_
						,d.LongDescription as FamilyGroup_
						,e.LongDescription as Family_0
						--,tbl.Family as Family_1
						--,f.StandardCost,f.WholeSalePrice
						,p.Pareto
				from _npfc left join JDE_DB_Alan.MasterSellingGroup c on _npfc.SellingGroup = c.Code
						 left join JDE_DB_Alan.MasterFamilyGroup d on _npfc.FamilyGroup = d.Code
						 left join JDE_DB_Alan.MasterFamily e on _npfc.Family = e.Code
						 left join JDE_DB_Alan.FCPRO_Fcst_Pareto p on _npfc.ItemNumber = p.ItemNumber
				 )

	 ,npfc_ as ( select stg.RowLabel,SellingGroup_ as SellingGroup,stg.FamilyGroup_ as FamilyGroup,stg.Family_0 as Family,stg.ItemNumber
					 ,stg.Date_pro as date											--- for FC Pro Date Format 		 
						 ,stg.Row			
						 ,stg.Baseline,stg.Formula,stg.Override,stg.Comment
						 --,stg.LastUpdated	
						 ,convert(varchar(21),stg.LastUpdated,103) as LastUpdated_					--- for FC Pro Date Format
						 ,stg.Pareto
					from stg )

	--------- Execute elow to Output Format for Overrideing for Uploading into FC Pro ---------
	select * 																					
	from npfc_ 
	where 
				--fc_.date is not null 
				--and fc_.ItemNumber in ('27.160.320','2770002534')
				-- and fc_.ItemNumber in ('27.160.785')
				npfc_.ItemNumber in ('2801381661','2801381810')
	order by npfc_.ItemNumber
			 ,left(npfc_.date,4) 
			 --,substring('',1,2)
			 ,case right(npfc_.Date,3)	 when 'Jan' then 1
										 when 'Feb' then 2
										 when 'Mar' then 3
										 when 'Apr' then 4
										 when 'May' then 5
										 when 'Jun' then 6
										 when 'Jul' then 7
										 when 'Aug' then 8
										 when 'Sep' then 9
										 when 'Oct' then 10
										 when 'Nov' then 11
										 when 'Dec' then 12
				 end 


exec JDE_DB_Alan.sp_NP_FC_Override_upload

--- Nice little check for NP_tmp table ---
 ;with tb as ( select n.ItemNumber,count(n.date) MthCnt
  from JDE_DB_Alan.FCPRO_NP_tmp n
  group by n.ItemNumber )

  select * from tb where tb.MthCnt <24

---===========================  End of Override FC Pro FC , Generate Override File ( dataSet) =======================================================



---=========================== Modify FC Algorithm of Pro FC , Generate Modifiers File ( dataSet)  2/2/2018 ========================================================
--use JDE_DB_Alan
--go

with cte as (
            select m.*
					,row_number() over(partition by m.itemNumber order by itemnumber ) as rn  
			from  JDE_DB_Alan.Master_ML345 m )
     ,cte_ as (
				select * from cte where rn =1  
			--order by m.ItemNumber
			 )
    -- ,ref as ( select * from JDE_DB_Alan.Master_ItemCrossRef rf where rf.Address_Number in ('20037'))		--please note there might be same item Number under multi suppliers!So need to filter here !
     ,fc as ( select f.*
					-- ,cast(DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,GETDATE())+5,0)) as datetime) as startdate			-- Set the StartDate for changing from Jun/2018 onwards
					,'2018-06-01' as startdate			-- Set the StartDate for changing from Jun/2018 onwards
			 -- from JDE_DB_Alan.JDE_Fcst_DL f
			    from JDE_DB_Alan.FCPRO_Fcst f
				where f.DataType1 in ('Adj_FC')					--26/2/2018
				 )    
     -- this is Monthly SKU level data
     ,_fc as (																										
				select 'Total' as RowLabel
				        ,cte_.SellingGroup
						,cte_.FamilyGroup
						,cte_.Family
					    ,fc.ItemNumber
					   ,fc.Date					  
                      -- ,mi.Comment
					  -- ,mi.LastUpdated
					   ,cte_.Description				
					   ,sum(isnull(fc.Value,0)) over( partition by fc.itemnumber) as FC_OrigQty_24m
				from fc	 left join cte_ on fc.ItemNumber = cte_.ItemNumber
				       --  left join JDE_DB_Alan.FCPRO_MI_tmp mi on fc.ItemNumber = mi.ItemNumber
						
				where  
					   fc.ItemNumber  in ('42.603.855')
					  and fc.DataType1 in ('Default')	
						--ref.Address_Number in ('20037')				
				)
              --select * from _fc
	  ,stg as 
			(select  _fc.*
					,c.LongDescription as SellingGroup_
					,d.LongDescription as FamilyGroup_
					,e.LongDescription as Family_0
					--,tbl.Family as Family_1
					--,f.StandardCost,f.WholeSalePrice
			from _fc left join JDE_DB_Alan.MasterSellingGroup c  on _fc.SellingGroup = c.Code
					 left join JDE_DB_Alan.MasterFamilyGroup d  on _fc.FamilyGroup = d.Code
					 left join JDE_DB_Alan.MasterFamily e  on _fc.Family = e.Code
			   )   
      ,fc_ as ( select stg.RowLabel,SellingGroup_ as SellingGroup,stg.FamilyGroup_ as FamilyGroup,stg.Family_0 as Family,stg.ItemNumber
                      --,stg.Date as Date_
				      --,convert(varchar(21),_fc.Date,103) as date1
					  --  ,convert(varchar(4),stg.date, 111) +'-'+ left (datename(mm,DATEADD(dd, DATEDIFF(d,0,stg.Date)+1,0)),3) as Date
						--,stg.Row			
					  --,stg.Baseline,stg.Formula,stg.Override,stg.Comment
					  --,stg.LastUpdated	
					  --,convert(varchar(21),stg.LastUpdated,103) as LastUpdated_
				from stg )
      
	    --------- Execute Below to Output Format for Modifiers for Uploading into FC Pro  ---------
   select * 																					
   from fc_ 
   where fc_.ItemNumber in ('42.603.855')
		 -- and fc_.Comment is not null 
			--and fc_.ItemNumber in ('27.160.320','2770002534')
			  

---===========================  Modify FC Algorithm of Pro FC , Generate Modifiers File ( dataSet)  ==============================================================================




---============================= Transfer/Export to JDE =====================================================================================================================
   --======================================================================================================================================================
	------ Below Code Use Table Variables to Create a Template with 0 Forecast and Can then Export to Jde to Override Jde existing FC--- 16/3/2018 Works Yeah !!! --------
    --- Use ShortItemNumber and you can joined back to ML345 to get unique UOM description etc ---
--======================================================================================================================================================

--declare @ItemIDs table ( Ids varchar(8000) ) 
declare @ShortItemIDs table ( Ids varchar(8000) ) 
--insert into @ItemIDs values ('40.033.131')
--insert into @ItemIDs values ('085552500D212'),('40.033.131')
--insert into @ItemIDs values ('26.802.659T'),('26.802.676T'),('26.802.830T'),('26.802.833T'),('26.802.971T'),('26.802.820T'),('26.802.962T'),('26.802.963T'),('26.810.971T'),('26.810.962T'),('26.810.830T'),('26.810.659T'),('26.810.833T'),('26.810.676T'),('26.800.820T'),('26.800.962T'),('26.800.963T'),('26.810.963T'),('26.800.659T'),('26.800.676T'),('26.800.830T'),('26.800.833T'),('26.800.971T'),('26.811.820T'),('26.811.962T'),('26.811.676T'),('26.801.820T'),('26.801.962T'),('26.801.963T'),('26.801.676T'),('26.803.659T'),('26.803.676T'),('26.803.830T'),('26.803.833T'),('26.803.971T'),('26.803.820T'),('26.803.962T'),('26.803.963T'),('6000130009001'),('6000030009001'),('6000130009004'),('6000130009008'),('6000030009005'),('6000130009003'),('6000030009011'),('6000030009012'),('6000130009002'),('6000130009011'),('6000130009010'),('6000130009012'),('6000030009004'),('6000130009006'),('6000130009009'),('6000030009007'),('6000130009005'),('6000030009003'),('6000030009009'),('6000030009002'),('6000030009010'),('6000030009006'),('6000130009007'),('6000030009008'),('6000030009001CL'),('6000030009002CL'),('6000030009003CL'),('6000030009004CL'),('6000030009005CL'),('6000030009006CL'),('6000030009007CL'),('6000030009008CL'),('6000030009009CL'),('6000030009010CL'),('6000030009011CL'),('6000030009012CL'),('6000130009001CL'),('6000130009002CL'),('6000130009003CL'),('6000130009004CL'),('6000130009005CL'),('6000130009006CL'),('6000130009007CL'),('6000130009008CL'),('6000130009009CL'),('6000130009010CL'),('6000130009011CL'),('6000130009012CL'),('8SCA3300PR'),('8SCA3300SB'),('8SCA3300BI'),('8SCA3300SU'),('8SCA3300CO'),('8SCA3300LQ'),('8SCA3300OY'),('8SCA300LQ'),('8SCA300BI'),('8SCA300SU'),('8SCA3300TRE'),('8SCA300CO'),('8SCA300SB'),('8SCA300PR'),('8SCA300TRE'),('8SCA300OY'),('8SCA3300BICL'),('8SCA3300COCL'),('8SCA3300LQCL'),('8SCA3300OYCL'),('8SCA3300PRCL'),('8SCA3300SBCL'),('8SCA3300SUCL'),('8SCA3300TRECL'),('8SCA300BICL'),('8SCA300COCL'),('8SCA300LQCL'),('8SCA300OYCL'),('8SCA300PRCL'),('8SCA300SBCL'),('8SCA300SUCL'),('8SCA300TRECL'),('6001030009007'),('6001030009009'),('6001030009010'),('6001030009011'),('6001030009019'),('6001030009020'),('6001030009021'),('6001030009022'),('6001030009023'),('6001130009007'),('6001130009009'),('6001130009010'),('6001130009011'),('6001130009019'),('6001130009020'),('6001130009021'),('6001130009022'),('6001130009023'),('6001030009007CL'),('6001030009009CL'),('6001030009010CL'),('6001030009011CL'),('6001030009019CL'),('6001030009020CL'),('6001030009021CL'),('6001030009022CL'),('6001030009023CL'),('6001130009007CL'),('6001130009009CL'),('6001130009010CL'),('6001130009011CL'),('6001130009019CL'),('6001130009020CL'),('6001130009021CL'),('6001130009022CL'),('6001130009023CL'),('6004030009038'),('6004030009041'),('6004030009049'),('6004030009050'),('6004129009038'),('6004129009041'),('6004129009049'),('6004129009050'),('6004030009038CL'),('6004030009041CL'),('6004030009049CL'),('6004030009050CL'),('6004129009038CL'),('6004129009041CL'),('6004129009049CL'),('6004129009050CL'),('8200124000910'),('8200124000907'),('8200124000908'),('8200124000906'),('8200124000903'),('8200124000927'),('8200124000932'),('8200124000901'),('8200124000904'),('8200124000912'),('8200124000929'),('8200124000911'),('8200124000928'),('8200124000902'),('8200124000933'),('8200124000905'),('8200124000909'),('8200124000930'),('8200124000931'),('8200124000926'),('8200128000910'),('8200128000907'),('8200128000908'),('8200128000906'),('8200128000903'),('8200128000927'),('8200128000932'),('8200128000901'),('8200128000904'),('8200128000912'),('8200128000929'),('8200128000911'),('8200128000928'),('8200128000902'),('8200128000933'),('8200128000905'),('8200128000909'),('8200128000930'),('8200128000931'),('8200128000926') 
 insert into @ShortItemIDs values ('1318213'),('1318221'),('1318256'),('1318192'),('1318205'),('1318248'),('1318264'),('1318230'),('1365693'),('1365677'),('1365651'),('1365626'),('1365669'),('1365634'),('1318117'),('1318141'),('1318109'),('1365685'),('1318088'),('1318096'),('1318133'),('1318061'),('1318070'),('1365714'),('1365722'),('1365706'),('1318168'),('1318176'),('1318150'),('1318184'),('1318301'),('1318310'),('1318344'),('1318281'),('1318299'),('1318336'),('1318352'),('1318328'),('1194901'),('1194847'),('1194935'),('1228277'),('1194880'),('1194927'),('1228242'),('1228251'),('1194919'),('1228306'),('1228293'),('1228314'),('1194871'),('1194951'),('1228285'),('1228200'),('1194943'),('1194863'),('1228226'),('1194855'),('1228234'),('1194898'),('1228269'),('1228218'),('1374047'),('1374135'),('1374768'),('1374784'),('1374792'),('1374805'),('1374813'),('1374821'),('1374830'),('1374848'),('1374856'),('1374864'),('1374143'),('1374872'),('1374881'),('1374899'),('1374901'),('1374910'),('1374928'),('1374936'),('1374944'),('1374952'),('1374961'),('1374979'),('1241391'),('1241404'),('1348674'),('1348666'),('1241359'),('1241375'),('1348682'),('1241455'),('1348771'),('1348762'),('1348754'),('1241439'),('1241480'),('1241471'),('1348797'),('1348789'),('1374303'),('1376149'),('1376157'),('1376165'),('1376173'),('1376181'),('1376190'),('1376202'),('1374291'),('1376085'),('1376093'),('1384763'),('1376106'),('1376114'),('1376122'),('1376131'),('1194960'),('1194986'),('1194994'),('1195006'),('1348615'),('1348623'),('1348631'),('1348640'),('1348658'),('1195049'),('1195065'),('1195073'),('1195081'),('1348560'),('1348578'),('1348586'),('1348594'),('1348607'),('1374055'),('1374151'),('1374987'),('1374995'),('1375007'),('1375015'),('1375023'),('1375040'),('1375058'),('1374160'),('1375074'),('1375091'),('1375103'),('1375120'),('1375146'),('1375154'),('1375171'),('1375189'),('1195284'),('1195313'),('1195399'),('1195401'),('1193545'),('1193570'),('1193625'),('1193633'),('1374063'),('1374178'),('1375197'),('1375200'),('1374186'),('1375218'),('1375226'),('1375234'),('1344606'),('1352614'),('1352622'),('1344518'),('1344526'),('1352657'),('1344577'),('1344500'),('1344534'),('1344585'),('1352665'),('1352649'),('1344542'),('1352593'),('1344593'),('1352606'),('1352631'),('1344551'),('1344569'),('1344497'),('1344489'),('1352534'),('1352542'),('1344391'),('1344403'),('1352577'),('1344454'),('1344382'),('1344411'),('1344462'),('1352585'),('1352569'),('1344420'),('1352518'),('1344471'),('1352526'),('1352551'),('1344438'),('1344446'),('1344374')
--select * from @ItemIDs

 ;with CalendarFrame as (
				select -24 as t
						,1 as n
						,cast(DATEADD(mm, DATEDIFF(mm, 0, GETDATE())-24, 0) as datetime) as start
				--	select 1 as t,1 as n,cast(DATEADD(mm, DATEDIFF(mm, 0, GETDATE())-24, 0) as datetime) as start
				union all
				select 
					 case when t +1 >24 then 1 else t+1 end 
					,case when n=12 then 1 else n+1 end
					,dateadd(mm, 1, start)
				-- select t+1 ,case when n=12 then 1 else n+1 end,dateadd(mm, 1, start)
				from CalendarFrame
			)
			  --select top 50 * from CalendarFrame
		 ,MonthlyCalendar as
				(
				select top 48 t, RIGHT('00'+CAST(n AS VARCHAR(3)),2) nmb
				,cast(SUBSTRING(REPLACE(CONVERT(char(10),start,126),'-',''),1,6) as integer) as [StartDate]
				,CONVERT(char(10),start,126) as startdt
				,DATENAME(mm,start) MnthName,DATENAME(yyyy,start) YearName from CalendarFrame
			)
        
		--select * from MonthlyCalendar
       ,cal as ( 
	            select cl.t,cl.nmb,cl.YearName,cl.MnthName
				,cl.StartDate
				,convert(date,dateadd(d,-1,dateadd(mm,1,startdt)),103) as Period_YMD_1		-- to get 'Jde FC Date' Format ie 31/Month/Year
				,convert(date,dateadd(d,-1,dateadd(mm,0,startdt)),103) as Period_YMD_2 -- to get 'Jde FC Date' Format ie 31/Month/Year,however when FC loaded into Jde, Jde will automatically add 1 day and push FC to Following month, ie 31/1/2018 FC will be push into Month slot of 1/Feb/2018, so here you need to change date again
				,convert(varchar(10),convert(date,dateadd(d,-1,dateadd(mm,0,startdt)),103),103) Period_YMD_3
				,0 as Qty
				 from MonthlyCalendar as cl
				 where cl.t>-1
				 )
			-- select * from cal

        ,_fc as ( select * from @ShortItemIDs t cross join cal
					--order by t.Ids,cal.StartDate
					 )
        
        ,fc_ as ( select _fc.Ids
		                ,m.ItemNumber
					    ,'HD' as BranchPlant
						--,'EA' as UOM
						,m.UOM as UOM
						,'BF' as ForecastType
						,_fc.Period_YMD_3
						,_fc.Qty
						,0 as Amt
						,0 as CustomerNumber,'N' as BypassForcing
					from _fc left join JDE_DB_Alan.Master_ML345 m on _fc.Ids = m.ShortItemNumber
					)

         select * from fc_
		 order by fc_.Ids,fc_.Period_YMD_3


exec JDE_DB_Alan.sp_Exp_FPFcst_func2Jde_ZeroOut '1383681'			-- Has to use ShortItemNumber !
exec JDE_DB_Alan.sp_Exp_FPFcst_func2Jde_ZeroOut '1245309,1245368,1245392,1245350,1245421,1245317,1245384,1245341,1245448,1287007,1287031,1287023,1287040,1287015,1287058,1286987,1286936,1286979,1286961,1287138,1287162,1287154,1287171,1287146,1287189,1287111,1287066,1287082,1287103,1287091'			
exec JDE_DB_Alan.sp_Exp_FPFcst_func2Jde_ZeroOut '746005,1371276'
exec JDE_DB_Alan.sp_Exp_FPFcst_func2Jde_ZeroOut '1383681,1383699'
exec JDE_DB_Alan.sp_Exp_FPFcst_func2Jde_ZeroOut '1169879,1322052'
exec JDE_DB_Alan.sp_Exp_FPFcst_func2Jde_ZeroOut '1149940,1150529'
exec JDE_DB_Alan.sp_Exp_FPFcst_func2Jde_ZeroOut '1150545,1150553'
exec JDE_DB_Alan.sp_Exp_FPFcst_func2Jde_ZeroOut '1150553'
exec JDE_DB_Alan.sp_Exp_FPFcst_func2Jde_ZeroOut '1420103'
exec JDE_DB_Alan.sp_Exp_FPFcst_func2Jde_ZeroOut '1418273'
exec JDE_DB_Alan.sp_Exp_FPFcst_func2Jde_ZeroOut '1390881'
exec JDE_DB_Alan.sp_Exp_FPFcst_func2Jde_ZeroOut '1067194'
exec JDE_DB_Alan.sp_Exp_FPFcst_func2Jde_ZeroOut '1398461,1398479,1398487'
exec JDE_DB_Alan.sp_Exp_FPFcst_func2Jde_ZeroOut '1380543,1401156,1401164'
exec JDE_DB_Alan.sp_Exp_FPFcst_func2Jde_ZeroOut '1413552'
exec JDE_DB_Alan.sp_Exp_FPFcst_func2Jde_ZeroOut '1344059,1344067,1344041,1344104,1344121,1344112'
exec JDE_DB_Alan.sp_Exp_FPFcst_func2Jde_ZeroOut '1354345,1354353,1354361,1354370,1354388,1354396,1354409,1354417,1354425,1401800,1354257,1412103,1354265,1354273,1354281,1354290,1412111,1354302,1412120,1401826,1354311,1391621,1412138,1412171,1412162,1412146,1412189,1412154,1354329,1412200,1412488,1354337,1391648,1401906,1413982,1401931,1401949,1401957'


select m.ItemNumber,m.ShortItemNumber,m.description from JDE_DB_Alan.vw_Mast m where m.ItemNumber in 
('34.215.000','34.216.000','34.230.000','34.232.000','34.233.000','34.234.000')
--('38.002.001','38.002.002','38.002.003','38.002.004','38.002.005','38.002.006','26.353.0000')


select * from JDE_DB_Alan.vw_Mast m
where m


--- &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
------------------------------------- SQL Output will include : FC/History/SOH/Cost/Pareto -----------------------------------------

--- Although this Method Method 3-2.  is 3-1 but Because it is Final and most efficient Method, therefore I put this Code Upfront as #1 - 25/1/20185

---=============================================================================================================================
--- Transfer/Export to JDE Method 3-2.(Use SQL Function)  ---Very Versatile it include Hist/Hierarchy etc -- ALan's method -- Priod in format as 'YYYYMM' - needto further convert text to Int for easy handling ? - on Monthly Bases By SKU - 11/1/2018
--- Works !!! Yeah !! - 11/1/2018  -- use this one
--- Below Works in both SSMS &  in 'Programmability' Using SQL Function, you can pass Multiple parameters
---=============================================================================================================================

------ First Create Your Function ----------------------------------
https://www.codeproject.com/Questions/800672/how-to-execute-stored-procedure-in-sql-with-multip

create FUNCTION [dbo].[Split]
(
    @String VARCHAR(8000),
    @Delimiter varCHAR(1)
)
RETURNS TABLE 
AS
RETURN 
(
    WITH Split(stpos,endpos) 
    AS(
        SELECT 0 AS stpos, CHARINDEX(@Delimiter,@String) AS endpos
        UNION ALL
        SELECT endpos+1, CHARINDEX(@Delimiter,@String,endpos+1)
            FROM Split
            WHERE endpos > 0
    )
  
	SELECT 'Id' = ROW_NUMBER() OVER (ORDER BY (SELECT 1)),
        'Data' = SUBSTRING(@String,stpos,COALESCE(NULLIF(endpos,0),LEN(@String)+1)-stpos)
    FROM Split 
	
)

--- does not work for long Strings , say if HD SKU list exceed 500 SKUS
select * from JDE_DB_Alan.[dbo].[Split] ('27.255.943,2991221862,27.251.682,27.252.951,27.251.996,27.252.955,27.239.664,27.239.470,27.237.575,2780034000,27.708.454,F17174A951,27.393.785,27.589.140,27.702.977,27.704.950,27.707.454,2780471000,Z43088A547,4170681885,7300111000,7300159000,4151068300,2671000000,27.200.647,27.222.502,27.222.634,27.231.644,27.231.916,27.232.700,27.239.502,27.240.470,27.251.624,27.251.744,27.251.750,27.251.955,27.252.457,27.252.686,27.252.688,27.252.713,27.252.986,27.589.137,27.589.141,27.589.195,27.254.944,27.255.940,27.585.126,7502000000,7502001000,7504001000,2780115000,2780128000,2780136000,2801386048,2801386785,2801386879,2801463000,4600291661,27.704.964,27.708.400,2801382669,2920033000,2991228000,FZ42088A547,F9174A951,FZ45088A599,KIT2759,PR101075951,PR101075989,PR161075604,27.232.707,27.232.977,27.237.572,27.240.502,27.240.664,27.251.457,27.251.688,27.251.749,27.251.951,27.251.953,27.251.985,27.251.986,27.252.682,27.252.985,27.254.938,27.255.938,2801386669,27.200.634,27.200.664,27.231.545,27.231.634,27.231.975,2801382785,2801382862,2801404000,2801462000,27.200.502,2801462000,27.200.502,2801462000,27.200.502',',')

--use JDE_DB_Alan
--go

drop function [dbo].[Split]
-----------------------------------------------------

http://www.sqlservercentral.com/blogs/querying-microsoft-sql-server/2013/09/19/how-to-split-a-string-by-delimited-char-in-sql-server/

--- 27/2/2018 --- works for long string even for 500 HD SKUs --- no issues either for 100 Recursions
CREATE FUNCTION [dbo].[fnSplitString] 
( 
    @string VARCHAR(MAX), 
    @delimiter CHAR(1) 
) 
RETURNS @output TABLE(splitdata VARCHAR(MAX) 
) 
BEGIN 
    DECLARE @start INT, @end INT 
    SELECT @start = 1, @end = CHARINDEX(@delimiter, @string) 
    WHILE @start < LEN(@string) + 1 BEGIN 
        IF @end = 0  
            SET @end = LEN(@string) + 1
       
        INSERT INTO @output (splitdata)  
        VALUES(SUBSTRING(@string, @start, @end - @start)) 
        SET @start = @end + 1 
        SET @end = CHARINDEX(@delimiter, @string, @start)
        
    END 
    RETURN 
END

drop function [dbo].fnSplitString

select * from JDE_DB_Alan.dbo.fnSplitString ('27.255.943,2991221862,27.251.682,27.252.951,27.251.996,27.252.955,27.239.664,27.239.470,27.237.575,2780034000,27.708.454,F17174A951,27.393.785,27.589.140,27.702.977,27.704.950,27.707.454,2780471000,Z43088A547,4170681885,7300111000,7300159000,4151068300,2671000000,27.200.647,27.222.502,27.222.634,27.231.644,27.231.916,27.232.700,27.239.502,27.240.470,27.251.624,27.251.744,27.251.750,27.251.955,27.252.457,27.252.686,27.252.688,27.252.713,27.252.986,27.589.137,27.589.141,27.589.195,27.254.944,27.255.940,27.585.126,7502000000,7502001000,7504001000,2780115000,2780128000,2780136000,2801386048,2801386785,2801386879,2801463000,4600291661,27.704.964,27.708.400,2801382669,2920033000,2991228000,FZ42088A547,F9174A951,FZ45088A599,KIT2759,PR101075951,PR101075989,PR161075604,27.232.707,27.232.977,27.237.572,27.240.502,27.240.664,27.251.457,27.251.688,27.251.749,27.251.951,27.251.953,27.251.985,27.251.986,27.252.682,27.252.985,27.254.938,27.255.938,2801386669,27.200.634,27.200.664,27.231.545,27.231.634,27.231.975,2801382785,2801382862,2801404000,2801462000,27.200.502,27.252.749,2982128000,7520000008,27.231.738,2920441200,7300110000,27.237.916,27.200.738,2801386609,F37174A400,2801382048,2801386180,7612208007,2991219785,27.251.737,27.252.624,27.252.916,27.171.661,2801382320,2781315000,2801382609,2801386320,4600189661,27.171.785,2801386862,27.240.467,2801382180,27.589.196,F17174A955,4600276661,4600289661,7501001000,7501005000,7511000000,7541000000,7542000000,KIT2758,PR241050501,PR241050502,7520064000,27.251.713,27.251.916,27.251.994,27.252.953,27.254.940,27.255.944,27.222.643,27.232.702,27.237.576,27.237.653,27.237.738,27.251.681,27.292.000,27.585.110,27.585.140,27.585.141,27.701.599,27.701.635,27.702.955,27.589.133,27.703.605,27.703.951,27.704.951,27.710.957,2770004000,2770011785,2780470000,2801386276,2801386661,2801382276,2801382661,2801382879,27.708.445,27.708.458,2921273000,4150054785,4151070300,2920443000,4152336885,2991333661,2991333862,3400112300,2851284354,2851284609,2851284669,4170681133,4170681651,4160144125,4155352000,2801385661,27.710.952,2801436276,2801436048,2801350000,2801436862,2851230661,2851230689,2851230785,2851224785,2851230072,2851236785,2851284167,2780050000,2780120000,2780229000,27.704.965,27.703.977,27.703.908,27.700.635,27.700.689,27.703.568,27.588.201,27.588.226,2780143000,27.251.686,27.243.785,27.258.000,7530000005,7530000013,4611200661,27.200.916,27.160.135,2770002534,4600260000,F36174A458,F16174A568,F16174A951,27.161.785,27.171.180,27.171.862,2851284785,2801381661,F8174A949,F8174A955,2991221661,27.171.048,27.702.710,4600228000,2780145000,34.043.000,2991221785,2801386324,2801382324,2920076000,2920905000,2851230862,2851284661,27.170.785,27.588.238,J6108A146,7503000000,4150459000,27.171.320,4170681785,2789000951,27.240.487,4600277917,2991380000,7520000016,27.171.879,FP3108A544,2920750000,H7174N952,2801382810,PR141075604,2991319180,2991227000,2801386689,2801386810,2801436072,2851224862,2851230167,2851230354,27.251.928,27.171.810,PR221050502,PR81075200,PR81075951,2801382580,KIT2729,PR111075N951,PR131075600,PR141075605,FM45108A599,FQ1096A401,FZ40088A501,PR161075601,PR161075605,PR61075200,F17174A952,F9174A952,FM45108A594,PR111075N953,PR121075411,PR121075949,PR121075953,PR91075N951,2991333785,2801436354,2801436661,2920435200,2991221180,2991221276,2851284862,2920830000,2801382689,2789000682,2851284048,2851284072,2851284324,27.710.576,2770000785,2789000953,2789000955,2780144000,4600197000,7840001000,4600277532,4150288785,4155349000,4155350000,4155351000,4170417000,4170418000,7590002000,7602209013,27.587.201,27.264.850,4600208001,4600230000,4150951885,27.395.785,4150082180,27.700.599,27.702.908,3400369320,27.254.943,27.252.000,4170681320,4600195000,4150249102,4150951180,4150951785,4170440000,27.161.661,7602209005,4170729000,4170730000,7503001000,7504000000,F16174A948,F16174A949,F16174A977,F8174A951,F9174A568,F9174A576,7300109000,7300158000,2789000457,27.710.951,2770002535,27.587.238,27.707.445,27.704.952,27.704.955,27.700.660,27.701.660,27.702.948,27.702.949,27.585.127,27.585.125,4600198000,27.257.000,4150249103,D8174A700,F16174A565,F16174A955,27.703.948,27.710.955,2801386580,2801436785,2920247000,27.703.955,F9174A955,FZ5088A221,2851224661,F8174A948,2789000713,27.271.120,27.588.213,7804000000,27.254.946,27.704.784,27.239.467,4150951426,27.171.580,27.170.661,4600186661,PRHRV3L949,PRHRV3S924,4600172550,4199040300,4199070000,5007312000,4600220486,4600220661,27.162.661,27.174.882,2801499245,2911532245,2911530276,3400669661,2991307000,2991263785,2991279000,2991280000,2991573000,2991906785,34.033.000,3400382000,3400669048,342J6108221,342M4501,342M4511,342M45594,342Q296401,342Q296402,342Q296403,342Q296410,342J6108141,7300444000,4199050820,4199060000,4199040820,3200156862,2801433276,2990932000,2801436324,2911529862,KIT8105,2991290000,34.028.000,2801491661,4600279000,4150082320,4150155137,4140126000,4150082785,5007311000,4150084133,4152336685,4152336849,4152336450,4153085000,4150144128,4199080000,4199120000,4199030300,4199030331,4250085528,4600172133,4600173486,4600172810,4600173133,2801499609,27.587.208,27.587.213,27.394.785,27.308.036,27.309.036,27.311.037,27.392.000,27.707.400,27.707.458,2780033000,2781094000,2780043000,2780114000,2780143355,2780143370,2780143379,2780144150,2780144280,2780144360,2780144571,2780144636,2780144820,2780144890,2780145330,2780145360,2780145840,2780148320,2780148810,2780148879,2780149048,2780149580,2780149689,2780149810,2780155000,2780163000,2780167000,2780228000',',')
-------------------------------------------------------------------------
-- ('2780143000'),('2780047000'),('2851236354')     -- Item Number
-- ('979516'),('1262'),('35610'),('20025')			--Imelda_Chan
-- ('503978'),('20037')								--Margaret_Dost
-- ('1459')											--Salman_Saeed			--


declare @Supplier_id varchar(8000)
declare @Item_id varchar(8000)
declare @DataType as varchar(100)
--set @Supplier_id= '503978,1459'
--set @Item_id = '42.522.000,46.502.000,42.603.855,46.505.000'
--set @Item_id = '27.253.000'

--set @Supplier_id = '503978,1459,20615'
set @Item_id = '34.523.000,34.522.000,34.521.000,34.523.000,34.519.000,34.514.000,34.515.000,34.516.000,34.520.000,34.513.000,34.517.000,34.518.000'
--set @DataType = 'Forecast'
set @DataType = 'Adj_FC,Sales'
--set @DataType = 'Forecast'

					
  ;with cte as (
		select f.ItemNumber,convert(varchar(6),f.Date,112) as Period_YM,f.Value,'Adj_FC' as Typ_
		 from JDE_DB_Alan.FCPRO_Fcst f 
		 --where s.ItemNumber in (select ids from @ItemIDs)
		 --where f.ItemNumber in ('40.033.131')
		 where f.DataType1 in ('Adj_FC')
		union all
		select s.ItemNumber,convert(varchar(6),convert(datetime,concat(s.CYM,'01')),112) Period_YM,s.SalesQty,'Sales' as Typ_
		from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload s 
		--where s.ItemNumber in (select ids from @ItemIDs)
		--where s.ItemNumber in ('40.033.131')
	  ) 

	 ,comb_ as ( select cte.ItemNumber,cte.Typ_,cte.Period_YM,cte.Value,m.StandardCost,p.Pareto,m.UOM,m.PrimarySupplier 					
					,m.PlannerNumber
					,m.SellingGroup,m.FamilyGroup,m.Family,m.Description
					,case m.PlannerNumber when '20071' then 'Rosie Ashpole'             --- Domenic Cellucci										  	
										  when '20072' then 'Salmon Saeed'
										  when '20004' then 'Margaret Dost'	
										  when '20005' then 'Imelda Chan'										  
										  else 'Unknown'
						end as Owner_
				from cte left join JDE_DB_Alan.Master_ML345 m on cte.ItemNumber = m.ItemNumber
					 left join JDE_DB_Alan.FCPRO_Fcst_Pareto p on cte.Itemnumber = p.ItemNumber

			   where cte.ItemNumber in ( select data from JDE_DB_Alan.dbo.Split(@Item_id,','))
			      --  or m.PrimarySupplier in ( select data from JDE_DB_Alan.dbo.Split(@Supplier_id,','))
			     --   or m.PrimarySupplier in ( select data from JDE_DB_Alan.dbo.Split(@Supplier_id,','))
		)
	,staging as 
			(select  comb_.*
					,c.LongDescription as SellingGroup_
					,d.LongDescription as FamilyGroup_
					,e.LongDescription as Family_0
					--,tbl.Family as Family_1
					--,f.StandardCost,f.WholeSalePrice
			from comb_ left join JDE_DB_Alan.MasterSellingGroup c  on comb_.SellingGroup = c.Code
					 left join JDE_DB_Alan.MasterFamilyGroup d  on comb_.FamilyGroup = d.Code
					 left join JDE_DB_Alan.MasterFamily e  on comb_.Family = e.Code
			   )   
      
     ,comb as ( select * from staging )
     
	 ,np as ( select * from JDE_DB_Alan.FCPRO_NP_tmp )

	select comb.ItemNumber,'HD' as BranchPlant,comb.UOM,'BF' as ForcastType
			,comb.Period_YM
			,convert(date,dateadd(mm,0,convert(datetime,comb.Period_YM+'01',103))) as Period_YMD_0
			,convert(date,dateadd(d,-1,dateadd(mm,0,convert(datetime,comb.Period_YM+'01',103))),103) as Period_YMD_1		-- to get 'Jde FC Date' Format ie 31/Month/Year,however when FC loaded into Jde, Jde will automatically add 1 day and push FC to Following month, ie 31/1/2018 FC will be push into Month slot of 1/Feb/2018, so here you need to change date again
			,convert(date,dateadd(d,-1,dateadd(mm,1,convert(datetime,comb.Period_YM+'01',103))),103) as Period_YMD_2        -- Current month + 1 month minus 1 day to get last day of same month , to get 'Jde FC Date' Format ie 31/Month/Year, get last day of last month 
			,convert(varchar(10),convert(date,dateadd(d,-1,dateadd(mm,1,convert(datetime,comb.Period_YM+'01',105))),103),103) Period_YMD_3
			,comb.Typ_
			,comb.Value as Qty
			,0 as Amt
			,0 as CustomerNumber,'N' as BypassForcing,comb.Pareto 			
			,comb.PlannerNumber,comb.primarysupplier,comb.Owner_
			,comb.Family_0
			,comb.Description
			from comb
	--where comb.Typ_ in ('Forecast')
	  where comb.Typ_ in (select data from JDE_DB_Alan.dbo.Split(@DataType,','))
	      --  and  and not exists ( select np.ItemNumber from JDE_DB_Alan.FCPRO_NP_tmp np where np.ItemNumber = staging.ItemNumber)				--- exclude New Product Forecast  ---
	order by Pareto asc,comb.PlannerNumber,comb.ItemNumber,comb.Typ_,comb.Period_YM

select * from JDE_DB_Alan.FCPRO_Fcst  f where f.ItemNumber in ('24.5354.0204')

 exec JDE_DB_Alan.sp_Z_FC_Supplier 
  
 exec JDE_DB_Alan.sp_Exp_FPFcst_func  null,null,'Adj_FC'						--works
 exec JDE_DB_Alan.sp_Exp_FPFcst_func '503978,20037',null,'Adj_FC'				--works
 exec JDE_DB_Alan.sp_Exp_FPFcst_func '503978,1459',null					-- works
 exec JDE_DB_Alan.sp_Exp_FPFcst_func  null,'27.171.320,27.171.661,27.171.785'		-- works
 exec JDE_DB_Alan.sp_Exp_FPFcst_func  '503978,1459','27.171.320,27.171.661,27.171.785'		-- works
 
  exec JDE_DB_Alan.sp_Exp_FPFcst_func  null,'s3000NET5300N901','Adj_FC,Sales'		-- works
  exec JDE_DB_Alan.sp_Exp_FPFcst_func  '503978,1459',null,'Adj_FC'			-- works

  exec JDE_DB_Alan.sp_Exp_FPFcst_func  '20615',null,'Adj_FC'			-- works
  exec JDE_DB_Alan.sp_Exp_FPFcst_func  null,'27.253.000','Adj_FC'			-- works
  exec JDE_DB_Alan.sp_Exp_FPFcst_func  null,'45.668.063','Adj_FC'			-- works
  exec JDE_DB_Alan.sp_Exp_FPFcst_func  null,'27.253.000','Adj_FC'			-- works
   exec JDE_DB_Alan.sp_Exp_FPFcst_func  '20037','27.253.000','Adj_FC'			-- works   --- 29/1/2018
   exec JDE_DB_Alan.sp_Exp_FPFcst_func  null,'27.253.000,2974000000','Adj_FC,sales'		--- works --- Forecast & Sales 

   exec JDE_DB_Alan.sp_Exp_FPFcst_func  null,'2974000000,2780047000','Adj_FC'
   exec JDE_DB_Alan.sp_Exp_FPFcst_func  null,'40.033.131,2780047000','forecst'		-- does not work,misspelling -- 30/1/2018
   exec JDE_DB_Alan.sp_Exp_FPFcst_func  null,'40.033.131,2780047000','AdjFC'		-- does not work,misspelling -- 30/1/2018
  
  exec JDE_DB_Alan.sp_Exp_FPFcst_func  null,'34.345.000,34.346.000,34.347.000,34.348.000,34.349.000,34.350.000,34.351.000,34.359.000,34.360.000,34.361.000,34.370.000,34.449.000,34.451.000,34.452.000','Forecast,Sales'
  exec JDE_DB_Alan.sp_Exp_FPFcst_func2Jde  null,'40.033.131,2780047000','Adj_FC'
   exec JDE_DB_Alan.sp_Exp_FPFcst_func2Jde  null,'2780136000','Adj_FC'
 exec JDE_DB_Alan.sp_Exp_FPFcst_func2Jde  null,null,'Adj_FC'
  exec JDE_DB_Alan.sp_Exp_FPFcst_func2Exl  null,'27.253.000','Adj_FC,Sales'
   exec JDE_DB_Alan.sp_Exp_FPFcst_func2Jde '2140857',null,'Adj_FC'
  exec JDE_DB_Alan.sp_Exp_FPFcst_func2Jde  null,'34.523.000,34.522.000,34.521.000,34.519.000,34.514.000,34.515.000,34.516.000,34.520.000,34.513.000,34.517.000,34.518.000,18.618.042,18.618.043,18.618.044,18.618.046,18.618.041,4171291133,4171292133,4171291320,4171292320,4171291785,4171292785,4171291862,4171292862,4171291885,4171292885,4171291765,4171292765,4171291180,4171292180,4171291651,4171292651,4171324050,4171324060,4171324070,4171324080,4171324090,4171325050,4171325060,4171325070,4171325080,4171325090,34.530.000,34.531.000,34.528.000,34.529.000,34.532.000,34.533.000,34.534.000,34.527.000','Adj_FC'
  exec JDE_DB_Alan.sp_Exp_FPFcst_func2Jde  null,'52.029.010,52.030.000,52.017.850,52.017.810,52.017.100,52.017.735,52.017.737,52.017.000,52.017.134','Adj_FC'
    exec JDE_DB_Alan.sp_Exp_FPFcst_func2Jde  null,'34.531.000','Adj_FC'
	exec JDE_DB_Alan.sp_Exp_FPFcst_func2Jde_ZeroOut '1394654'
	exec JDE_DB_Alan.sp_Exp_FPFcst_func2Jde null,'18.010.035,18.010.036,18.013.089,18.615.007,24.5349.4459,24.7002.0001,24.7102.1858,24.7120.4459,24.7121.4459,24.7122.4459,24.7124.4459,24.7127.4459,24.7146.4459A,24.7163.0000A,24.7168.4459A,24.7169.4459A,24.7207.4459,24.7219.4459,24.7250.4459,24.7251.4459,24.7253.4459,24.7334.4459,2780229000,32.379.200,32.455.155','Adj_FC'
	exec JDE_DB_Alan.sp_Exp_FPFcst_func2Jde  null,'24.7218.4462,32.501.000,43.211.004,32.379.200,32.380.855,18.607.016,24.7201.0000,24.7102.7052,24.7102.7052,32.455.465,24.7115.0952A,24.7114.0952A,24.7128.0952,709895,24.7353.0000A,24.7136.0155A,709901,24.7120.0952','Adj_FC'
  exec JDE_DB_Alan.sp_Exp_FPFcst_func2Jde null,'S3000NET5300N001','Adj_FC'
  exec JDE_DB_Alan.sp_Exp_FPFcst_func2Jde null,'44.003.102,44.003.104,44.003.113,44.003.114,44.004.102,44.004.104,44.004.113,44.004.114,44.005.102,44.005.104','Adj_FC'	
   exec JDE_DB_Alan.sp_Exp_FPFcst_func2Jde null, '44.003.102,44.003.104,44.003.113,44.003.114,44.004.102,44.004.104,44.004.113,44.004.114,44.005.102,44.005.104,44.003.102K,44.003.104K,44.003.113K,44.003.114K,44.004.102K,44.004.104K,44.004.113K,44.004.114K,44.005.102K,44.005.104K','Adj_FC'	
   exec JDE_DB_Alan.sp_Exp_FPFcst_func2Jde  null,'18.010.035,18.010.036,18.615.007,24.7102.0199,24.7127.0155,24.7128.0155,24.7129.0155A,24.7201.0000,24.7206.0000,32.379.200,18.013.089,32.380.002,32.455.155,24.5358.0000,24.7124.0155,24.7203.0000,24.7220.0199,S3000NET5300N001,82.696.901,82.696.930','Adj_FC'
     exec JDE_DB_Alan.sp_Exp_FPFcst_func2Jde null,'52.000.000,52.001.000,52.004.000,52.005.000,52.006.000,52.007.000,52.008.850,52.008.134,52.008.810,52.008.100,52.008.734,52.008.737,52.008.000,52.009.000,52-WH-0025,52.012.000,44.132.000,52.028.134,709845,52.013.000,52.014.850,52.014.850,52.014.134,52.014.810,52.014.100,52.014.734,52.014.737,52.014.000,52.015.850,52.015.850,52.015.134,52.015.810,52.015.100,52.015.734,52.015.737,52.015.000,52.016.850,52.016.850,52.016.134,52.016.810,52.016.100,52.016.734,52.016.737,52.016.000,52.017.000,52.018.000,52.003.000,52.020.850,52.020.850,52.020.134,52.020.810,52.020.100,52.020.734,52.020.737,52.020.000,52.021.850,52.021.850,52.021.134,52.021.810,52.021.100,52.021.734,52.021.737,52.021.000,52.002.000,52.022.850,52.022.134,52.022.810,52.022.100,52.022.734,52.022.737,52.022.000','Adj_FC'
  exec JDE_DB_Alan.sp_Exp_FPFcst_func2Jde null,'44.010.003,44.010.004,44.010.005,44.010.001,44.010.002,44.010.006,44.010.007,44.011.003,44.011.004,44.011.005,44.011.001,44.011.002,44.011.006,44.011.007,44.012.003,44.012.004,44.012.008,44.012.007','Adj_FC'
   exec JDE_DB_Alan.sp_Exp_FPFcst_func2Jde null,'44.015.404,44.015.405,44.016.404,44.016.408,44.016.505,44.016.405,44.016.107,44.016.808,44.017.405','Adj_FC'	
    exec JDE_DB_Alan.sp_Exp_FPFcst_func2Jde  null,'40.041.131,40.042.131,40.041.378,40.042.433,40.041.433,40.042.804,40.042.228,40.042.378,40.041.804,40.042.430,40.041.430,40.041.228,40.042.805,40.041.805,40.041.280,40.042.280,40.024.131,40.263.131,40.262.131,40.025.131,40.026.131,40.046.850,40.026.378,40.030.131,40.029.131,40.031.131,40.032.131,40.033.131,40.153.131,40.153.378,40.132.378,40.132.430,40.153.433,40.132.433,40.153.804,40.153.430,40.132.804,40.153.228,40.153.805,40.132.280,40.158.131,40.132.805,40.132.228,40.174.131,40.176.850,40.175.002,40.415.173,40.129.131,40.129.433,40.129.378,40.129.804,40.129.430,40.132.131,40.129.805,40.129.280,40.129.228,40.131.131,40.131.378,40.199.850,40.196.850,40.197.850,40.191.000,40.152.131,40.169.173,40.173.850,40.200.850,40.189.002,40.198.850,40.170.173,40.163.131,40.162.131,40.187.850,40.171.173,40.188.850,40.260.131,40.260.378,40.260.804,40.260.430,40.260.433,40.260.805,40.260.228,40.280.120,40.467.850,40.264.131,40.001.850,40.345.131,40.346.131,40.051.048,40.368.173,40.367.173,40.270.131,40.023.000,40.381.000,40.034.000,40.271.850,40.340.173,40.172.850,40.371.173,40.379.000,40.035.120,40.048.131,40.047.856,40.380.002,40.377.000','Adj_FC'
 exec JDE_DB_Alan.sp_Exp_FPFcst_func2Jde  null,'18.010.035,18.010.036,18.013.089,18.615.007,24.5353.0204,24.5354.0204,24.7100.0199,24.7110.0155,24.7120.0155,24.7121.0155,24.7122.0155,24.7124.0155,24.7127.0155,24.7129.0155,24.7200.0001,24.7202.0001,24.7206.0000,24.7220.0199,24.7333.0199,32.379.200,32.380.002,32.455.155,32.501.000,43.212.001,43.212.003','Adj_FC'
 exec JDE_DB_Alan.sp_Exp_FPFcst_func2Jde  null,'46.005.104,46.011.104,46.012.104,46.013.104,46.606.104,46.607.104,46.608.104,52.008.104,52.014.104,52.016.104,52.017.104,52.020.104,52.021.104,52.022.104','Adj_FC'
   	
  exec JDE_DB_Alan.sp_Exp_FPFcst_func2Exl null,'27.255.943,2991221862,27.251.682,27.252.951,27.251.996,27.252.955,27.239.664,27.239.470,27.237.575,2780034000,27.708.454,F17174A951,27.393.785,27.589.140,27.702.977,27.704.950,27.707.454,2780471000,Z43088A547,4170681885,7300111000,7300159000,4151068300,2671000000,27.200.647,27.222.502,27.222.634,27.231.644,27.231.916,27.232.700,27.239.502,27.240.470,27.251.624,27.251.744,27.251.750,27.251.955,27.252.457,27.252.686,27.252.688,27.252.713,27.252.986,27.589.137,27.589.141,27.589.195,27.254.944,27.255.940,27.585.126,7502000000,7502001000,7504001000,2780115000,2780128000,2780136000,2801386048,2801386785,2801386879,2801463000,4600291661,27.704.964,27.708.400,2801382669,2920033000,2991228000,FZ42088A547,F9174A951,FZ45088A599,KIT2759,PR101075951,PR101075989,PR161075604,27.232.707,27.232.977,27.237.572,27.240.502,27.240.664,27.251.457,27.251.688,27.251.749,27.251.951,27.251.953,27.251.985,27.251.986,27.252.682,27.252.985,27.254.938,27.255.938,2801386669,27.200.634,27.200.664,27.231.545,27.231.634,27.231.975,2801382785,2801382862,2801404000,2801462000,27.200.502,27.252.749,2982128000,7520000008,27.231.738,2920441200,7300110000,27.237.916,27.200.738,2801386609,F37174A400,2801382048,2801386180,7612208007,2991219785,27.251.737,27.252.624,27.252.916,27.171.661,2801382320,2781315000,2801382609,2801386320,4600189661,27.171.785,2801386862,27.240.467,2801382180,27.589.196,F17174A955,4600276661,4600289661,7501001000,7501005000,7511000000,7541000000,7542000000,KIT2758,PR241050501,PR241050502,7520064000,27.251.713,27.251.916,27.251.994,27.252.953,27.254.940,27.255.944,27.222.643,27.232.702,27.237.576,27.237.653,27.237.738,27.251.681,27.292.000,27.585.110,27.585.140,27.585.141,27.701.599,27.701.635,27.702.955,27.589.133,27.703.605,27.703.951,27.704.951,27.710.957,2770004000,2770011785,2780470000,2801386276,2801386661,2801382276,2801382661,2801382879,27.708.445,27.708.458,2921273000,4150054785,4151070300,2920443000,4152336885,2991333661,2991333862,3400112300,2851284354,2851284609,2851284669,4170681133,4170681651,4160144125,4155352000,2801385661,27.710.952,2801436276,2801436048,2801350000,2801436862,2851230661,2851230689,2851230785,2851224785,2851230072,2851236785,2851284167,2780050000,2780120000,2780229000,27.704.965,27.703.977,27.703.908,27.700.635,27.700.689,27.703.568,27.588.201,27.588.226,2780143000,27.251.686,27.243.785,27.258.000,7530000005,7530000013,4611200661,27.200.916,27.160.135,2770002534,4600260000,F36174A458,F16174A568,F16174A951,27.161.785,27.171.180,27.171.862,2851284785,2801381661,F8174A949,F8174A955,2991221661,27.171.048,27.702.710,4600228000,2780145000,34.043.000,2991221785,2801386324,2801382324,2920076000,2920905000,2851230862,2851284661,27.170.785,27.588.238,J6108A146,7503000000,4150459000,27.171.320,4170681785,2789000951,27.240.487,4600277917,2991380000,7520000016,27.171.879,FP3108A544,2920750000,H7174N952,2801382810,PR141075604,2991319180,2991227000,2801386689,2801386810,2801436072,2851224862,2851230167,2851230354,27.251.928,27.171.810,PR221050502,PR81075200,PR81075951,2801382580,KIT2729,PR111075N951,PR131075600,PR141075605,FM45108A599,FQ1096A401,FZ40088A501,PR161075601,PR161075605,PR61075200,F17174A952,F9174A952,FM45108A594,PR111075N953,PR121075411,PR121075949,PR121075953,PR91075N951,2991333785,2801436354,2801436661,2920435200,2991221180,2991221276,2851284862,2920830000,2801382689,2789000682,2851284048,2851284072,2851284324,27.710.576,2770000785,2789000953,2789000955,2780144000,4600197000,7840001000,4600277532,4150288785,4155349000,4155350000,4155351000,4170417000,4170418000,7590002000,7602209013,27.587.201,27.264.850,4600208001,4600230000,4150951885,27.395.785,4150082180,27.700.599,27.702.908,3400369320,27.254.943,27.252.000,4170681320,4600195000,4150249102,4150951180,4150951785,4170440000,27.161.661,7602209005,4170729000,4170730000,7503001000,7504000000,F16174A948,F16174A949,F16174A977,F8174A951,F9174A568,F9174A576,7300109000,7300158000,2789000457,27.710.951,2770002535,27.587.238,27.707.445,27.704.952,27.704.955,27.700.660,27.701.660,27.702.948,27.702.949,27.585.127,27.585.125,4600198000,27.257.000,4150249103,D8174A700,F16174A565,F16174A955,27.703.948,27.710.955,2801386580,2801436785,2920247000,27.703.955,F9174A955,FZ5088A221,2851224661,F8174A948,2789000713,27.271.120,27.588.213,7804000000,27.254.946,27.704.784,27.239.467,4150951426,27.171.580,27.170.661,4600186661,PRHRV3L949,PRHRV3S924,4600172550,4199040300,4199070000,5007312000,4600220486,4600220661,27.162.661,27.174.882,2801499245,2911532245,2911530276,3400669661,2991307000,2991263785,2991279000,2991280000,2991573000,2991906785,34.033.000,3400382000,3400669048,342J6108221,342M4501,342M4511,342M45594,342Q296401,342Q296402,342Q296403,342Q296410,342J6108141,7300444000,4199050820,4199060000,4199040820,3200156862,2801433276,2990932000,2801436324,2911529862,KIT8105,2991290000,34.028.000,2801491661,4600279000,4150082320,4150155137,4140126000,4150082785,5007311000,4150084133,4152336685,4152336849,4152336450,4153085000,4150144128,4199080000,4199120000,4199030300,4199030331,4250085528,4600172133,4600173486,4600172810,4600173133,2801499609,27.587.208,27.587.213,27.394.785,27.308.036,27.309.036,27.311.037,27.392.000,27.707.400,27.707.458,2780033000,2781094000,2780043000,2780114000,2780143355,2780143370,2780143379,2780144150,2780144280,2780144360,2780144571,2780144636,2780144820,2780144890,2780145330,2780145360,2780145840,2780148320,2780148810,2780148879,2780149048,2780149580,2780149689,2780149810,2780155000,2780163000,2780167000,2780228000', 'Adj_FC' 
   exec JDE_DB_Alan.sp_Exp_FPFcst_func2Exl null,'UR13112,UR12412,UR84912,UR66212,UR11812,UR10012,UR14712,UR10512,XUR19916,XUR13116,XUR12416,XUR84916,XUR66216,XUR11816,XUR10016,XUR14716,XUR10516,UEC131,UEC124,UEC849,UEC662,UEC118,UEC100,UEC147,UEC105,XUEC199,XUEC131,XUEC124,XUEC849,XUEC662,XUEC118,XUEC100,XUEC147,XUEC105,UCLC849,UCLC118,UCLC100,UCLC105,XUCLC131,XUCLC124,XUCLC849,XUCLC118,XUCLC100,XUCLC147,XUCLC105,UCS801,XUCS801,CS100,6800125000,CS707,XCS707,2930424885,2932623048,2932623609,2932623785,2932623885,2974000000,50-0150-000,2974000111,CS12007,30-CS606,310200,3200156000C,3116199,3116131,3116124,3116849,3116662,3116118,3116100,3116147,3116105,5007311000,5007312000,3024954983F,3024954765F,3024954133F,3024954849F,3024954387F,3024954587F,3024954246F,3024954135F,3024954125F,3024956000F,08-30-06-01,11417,31122765,31122849,31122587,31122246,31122135,311202,31121983,31121765,31121849,31121587,31121246,31121135,311201,311620,311621,31017021,500199000,KIT2350,CS4023,XCS4023,4181301661,4181301048,4181301320,4181301765,4181301862,4181301176,3051303661,3051303048,3051303320,3051303765,3051303862,3051303176,4231301661,4231301048,4231301320,4231301765,4231301862,4231301176,6121302,2151308,2151307,6281301,6281303,5241301,2131301,4231303,4231302,1081401,7231303,2920673100,PA3701,2920700100,2984495100,2780093125,2780093246,2780093587,2780094125,2780094133,2780094246,2780094587,2920639100,2920637100','Adj_FC' 
  exec JDE_DB_Alan.sp_Exp_FPFcst_func2Exl null,'UR13112','Sales,Adj_FC'
    exec JDE_DB_Alan.sp_Exp_FPFcst_func2Exl null,'UR13112','Adj_FC'

 exec JDE_DB_Alan.sp_Exp_FPFcst_func2Jde null,'26.812.410,26.812.901,26.812.604,26.812.820,26.812.902,26.812.962,26.815.410,26.815.901,26.815.604,26.815.820,26.815.902,26.815.962,26.814.410,26.814.901,26.814.604,26.814.820,26.814.902,26.814.962','Adj_FC'
  exec JDE_DB_Alan.sp_Exp_FPFcst_func2Exl null,'38.001.001,38.003.001,38.004.000,38.001.002,38.001.003,38.001.004,38.001.005,38.001.006,38.002.001,38.002.002,38.002.003,38.002.004,38.002.005,38.002.006,38.003.002,38.003.003,38.003.004,38.003.005,38.003.006','Adj_FC'
  exec JDE_DB_Alan.sp_Exp_FPFcst_func2Exl null,'38.002.001','Adj_FC'

   exec JDE_DB_Alan.sp_Exp_FPFcst_func2Jde  null,'22.748.091,22.749.091,24.5110.7178,24.5349.0204,24.5349.0952,24.5349.1858,24.5349.4459,24.5353.0204,24.5353.0952,24.5353.1858,24.5353.4459,24.5354.0204,24.5354.0952,24.5354.1858,24.5354.4459,24.5358.0000,24.5360.0204,24.5360.1858,24.5361.0204,24.5361.1858,24.5362.0204,24.5362.1858,24.5363.0204,24.5363.1858,24.5396.0000,24.5397.0000,24.5398.0000,24.5399.0000,24.5403.0000,24.5404.0000,24.5405.0000,24.5411.0000,24.5412.0000,24.5413.0000,24.5414.0000,24.5415.0000,24.5416.0000,24.5417.0000,24.5418.0000,24.5424.0204,24.5424.0952,24.5424.1858,24.5424.4459,24.5425.0204,24.5425.0952,24.5425.1858,24.5425.4459,24.5426.0204,24.5426.0952,24.5426.1858,24.5426.4459,24.5427.0204,24.5427.0952,24.5427.1858,24.5427.4459,24.7002.0000,24.7002.0000T,24.7002.0001,24.7002.0001T,24.7100.0199,24.7100.1858,24.7100.4459A,24.7100.7052A,24.7102.0199,24.7102.1858,24.7102.4459A,24.7102.7052,24.7102.7052A,24.7110.0155,24.7110.0952,24.7110.0952A,24.7110.1858,24.7110.4459,24.7110.4459A,24.7114.0155,24.7114.0952A,24.7114.1858,24.7114.4459A,24.7116.0155,24.7120.0155,24.7120.0952,24.7120.0952A,24.7120.1858,24.7120.4459,24.7120.4459A,24.7121.0155,24.7121.0952,24.7121.0952A,24.7121.1858,24.7121.4459,24.7121.4459A,24.7122.0155,24.7122.0952,24.7122.0952A,24.7122.1858,24.7122.4459,24.7122.4459A,24.7124.0155,24.7124.0952,24.7124.0952A,24.7124.1858,24.7124.4459,24.7124.4459A,24.7125.0155,24.7125.0952,24.7125.0952A,24.7125.1858,24.7125.4459,24.7125.4459A,24.7127.0155,24.7127.0952,24.7127.1858,24.7127.4459,24.7128.0155,24.7128.0155A,24.7128.0952,24.7128.0952A,24.7128.1858,24.7128.1858A,24.7128.4459,24.7128.4459A,24.7192.7060A,24.7193.0199A,24.7195.0199A,24.7195.1858A,24.7196.7060A,24.7200.0000,24.7200.0000T,24.7200.0001,24.7200.0001T,24.7201.0000,24.7201.0000T,24.7201.0002,24.7202.0000,24.7202.0001,24.7219.0199,24.7219.0952,24.7219.1858,24.7219.4459,24.7219.4460,24.7219.4462,24.7219.4464,24.7219.4465,24.7300.7060,24.7307.1858,24.7333.0199,24.7333.0952,24.7333.1858,24.7333.4459,24.7334.0199,24.7334.0952,24.7334.1858,24.7334.4459,24.7363.0199,24.7363.0952,24.7363.1858,24.7363.4459,24.7364.0199,24.7364.0952,24.7364.1858,24.7364.4459,32.340.000,32.341.155,32.341.176,32.341.855,32.379.200,32.455.155,32.455.460,32.455.461,32.455.462,32.455.465,32.455.855,43.525.101,43.525.102,43.525.103,43.525.105,43.525.107,43.525.403,43.525.404,43.525.405,43.530.101,43.530.102,43.530.103,43.530.105,43.530.107,43.530.403,43.530.404,43.530.405,82.691.901,82.691.902,82.691.903,82.691.904,82.691.905,82.691.906,82.691.907,82.691.908,82.691.909,82.691.910,82.691.911,82.691.912,82.691.919,82.691.926,82.691.927,82.691.928,82.691.929,82.691.930,82.691.931,82.691.932,82.691.933,82.696.901,82.696.902,82.696.903,82.696.904,82.696.905,82.696.906,82.696.907,82.696.908,82.696.909,82.696.910,82.696.911,82.696.912,82.696.913,82.696.914,82.696.915,82.696.918,82.696.919,82.696.920,82.696.921,82.696.922,82.696.923,82.696.924,82.696.925,82.696.926,82.696.927,82.696.928,82.696.929,82.696.930,82.696.931,82.696.932,82.696.933,82.696.934,82.696.941,34.274.0155,34.263.0155,34.264.0155,34.265.0155,34.266.0000,34.267.0155,34.268.0000,34.269.0155,34.270.0155,34.271.0155,34.272.0155,34.273.0155,34.276.0000','Adj_FC'

    exec JDE_DB_Alan.sp_Exp_FPFcst_func2Jde  null,'34.274.0155,34.263.0155,34.264.0155,34.265.0155,34.266.0000,34.267.0155,34.268.0000,34.269.0155,34.270.0155,34.271.0155,34.272.0155,34.273.0155,34.276.0000','Adj_FC'

 exec JDE_DB_Alan.sp_Exp_FPFcst_func2Jde  null,'24.7121.0155,24.7100.0199,24.7002.0001T,32.380.002,32.379.200,24.7120.0155,24.7127.0155,24.7124.0155,24.7220.0952,32.455.155,24.7122.0155,24.7218.0199,24.7201.0000T,24.7121.1858,24.5417.0000,24.7100.1858,24.7120.1858,24.7128.0155A,24.7218.1858,24.7002.0001,24.7110.0155,24.7127.1858,24.7220.0199,24.5415.0000,24.7102.0199,24.7122.1858,24.7200.0000T,32.455.855,24.5416.0000,24.5414.0000,24.5427.0204,32.380.855,24.7206.0000,24.5349.0204,24.5413.0000,24.5353.0204,82.633.902,82.633.901','Adj_FC'


 select len('27.255.943,2991221862,27.251.682,27.252.951,27.251.996,27.252.955,27.239.664,27.239.470,27.237.575,2780034000,27.708.454,F17174A951,27.393.785,27.589.140,27.702.977,27.704.950,27.707.454,2780471000,Z43088A547,4170681885,7300111000,7300159000,4151068300,2671000000,27.200.647,27.222.502,27.222.634,27.231.644,27.231.916,27.232.700,27.239.502,27.240.470,27.251.624,27.251.744,27.251.750,27.251.955,27.252.457,27.252.686,27.252.688,27.252.713,27.252.986,27.589.137,27.589.141,27.589.195,27.254.944,27.255.940,27.585.126,7502000000,7502001000,7504001000,2780115000,2780128000,2780136000,2801386048,2801386785,2801386879,2801463000,4600291661,27.704.964,27.708.400,2801382669,2920033000,2991228000,FZ42088A547,F9174A951,FZ45088A599,KIT2759,PR101075951,PR101075989,PR161075604,27.232.707,27.232.977,27.237.572,27.240.502,27.240.664,27.251.457,27.251.688,27.251.749,27.251.951,27.251.953,27.251.985,27.251.986,27.252.682,27.252.985,27.254.938,27.255.938,2801386669,27.200.634,27.200.664,27.231.545,27.231.634,27.231.975,2801382785,2801382862,2801404000,2801462000,27.200.502,27.252.749,2982128000,7520000008,27.231.738,2920441200,7300110000,27.237.916,27.200.738,2801386609,F37174A400,2801382048,2801386180,7612208007,2991219785,27.251.737,27.252.624,27.252.916,27.171.661,2801382320,2781315000,2801382609,2801386320,4600189661,27.171.785,2801386862,27.240.467,2801382180,27.589.196,F17174A955,4600276661,4600289661,7501001000,7501005000,7511000000,7541000000,7542000000,KIT2758,PR241050501,PR241050502,7520064000,27.251.713,27.251.916,27.251.994,27.252.953,27.254.940,27.255.944,27.222.643,27.232.702,27.237.576,27.237.653,27.237.738,27.251.681,27.292.000,27.585.110,27.585.140,27.585.141,27.701.599,27.701.635,27.702.955,27.589.133,27.703.605,27.703.951,27.704.951,27.710.957,2770004000,2770011785,2780470000,2801386276,2801386661,2801382276,2801382661,2801382879,27.708.445,27.708.458,2921273000,4150054785,4151070300,2920443000,4152336885,2991333661,2991333862,3400112300,2851284354,2851284609,2851284669,4170681133,4170681651,4160144125,4155352000,2801385661,27.710.952,2801436276,2801436048,2801350000,2801436862,2851230661,2851230689,2851230785,2851224785,2851230072,2851236785,2851284167,2780050000,2780120000,2780229000,27.704.965,27.703.977,27.703.908,27.700.635,27.700.689,27.703.568,27.588.201,27.588.226,2780143000,27.251.686,27.243.785,27.258.000,7530000005,7530000013,4611200661,27.200.916,27.160.135,2770002534,4600260000,F36174A458,F16174A568,F16174A951,27.161.785,27.171.180,27.171.862,2851284785,2801381661,F8174A949,F8174A955,2991221661,27.171.048,27.702.710,4600228000,2780145000,34.043.000,2991221785,2801386324,2801382324,2920076000,2920905000,2851230862,2851284661,27.170.785,27.588.238,J6108A146,7503000000,4150459000,27.171.320,4170681785,2789000951,27.240.487,4600277917,2991380000,7520000016,27.171.879,FP3108A544,2920750000,H7174N952,2801382810,PR141075604,2991319180,2991227000,2801386689,2801386810,2801436072,2851224862,2851230167,2851230354,27.251.928,27.171.810,PR221050502,PR81075200,PR81075951,2801382580,KIT2729,PR111075N951,PR131075600,PR141075605,FM45108A599,FQ1096A401,FZ40088A501,PR161075601,PR161075605,PR61075200,F17174A952,F9174A952,FM45108A594,PR111075N953,PR121075411,PR121075949,PR121075953,PR91075N951,2991333785,2801436354,2801436661,2920435200,2991221180,2991221276,2851284862,2920830000,2801382689,2789000682,2851284048,2851284072,2851284324,27.710.576,2770000785,2789000953,2789000955,2780144000,4600197000,7840001000,4600277532,4150288785,4155349000,4155350000,4155351000,4170417000,4170418000,7590002000,7602209013,27.587.201,27.264.850,4600208001,4600230000,4150951885,27.395.785,4150082180,27.700.599,27.702.908,3400369320,27.254.943,27.252.000,4170681320,4600195000,4150249102,4150951180,4150951785,4170440000,27.161.661,7602209005,4170729000,4170730000,7503001000,7504000000,F16174A948,F16174A949,F16174A977,F8174A951,F9174A568,F9174A576,7300109000,7300158000,2789000457,27.710.951,2770002535,27.587.238,27.707.445,27.704.952,27.704.955,27.700.660,27.701.660,27.702.948,27.702.949,27.585.127,27.585.125,4600198000,27.257.000,4150249103,D8174A700,F16174A565,F16174A955,27.703.948,27.710.955,2801386580,2801436785,2920247000,27.703.955,F9174A955,FZ5088A221,2851224661,F8174A948,2789000713,27.271.120,27.588.213,7804000000,27.254.946,27.704.784,27.239.467,4150951426,27.171.580,27.170.661,4600186661,PRHRV3L949,PRHRV3S924,4600172550,4199040300,4199070000,5007312000,4600220486,4600220661,27.162.661,27.174.882,2801499245,2911532245,2911530276,3400669661,2991307000,2991263785,2991279000,2991280000,2991573000,2991906785,34.033.000,3400382000,3400669048,342J6108221,342M4501,342M4511,342M45594,342Q296401,342Q296402,342Q296403,342Q296410,342J6108141,7300444000,4199050820,4199060000,4199040820,3200156862,2801433276,2990932000,2801436324,2911529862,KIT8105,2991290000,34.028.000,2801491661,4600279000,4150082320,4150155137,4140126000,4150082785,5007311000,4150084133,4152336685,4152336849,4152336450,4153085000,4150144128,4199080000,4199120000,4199030300,4199030331,4250085528,4600172133,4600173486,4600172810,4600173133,2801499609,27.587.208,27.587.213,27.394.785,27.308.036,27.309.036,27.311.037,27.392.000,27.707.400,27.707.458,2780033000,2781094000,2780043000,2780114000,2780143355,2780143370,2780143379,2780144150,2780144280,2780144360,2780144571,2780144636,2780144820,2780144890,2780145330,2780145360,2780145840,2780148320,2780148810,2780148879,2780149048,2780149580,2780149689,2780149810,2780155000,2780163000,2780167000,2780228000')

 exec JDE_DB_Alan.sp_ML345_upd_LeadingZero

select convert(varchar(10),getdate(),103)



    --- Use this Query to Get Summmary On SKU level ---
--select comb.ItemNumber,comb.Pareto,sum(comb.value) FC_24 from comb
--where comb.Typ_ in ('Forecast')
--group by comb.ItemNumber,comb.Pareto
--order by Pareto asc,FC_24 desc
---=========================================================================================================================================================================
--- Pleasse note below SP can only pass 1 Item or 1 Supplier one at a time, to use more Versatile code use Code in Master Code file, this SP is primarily used to Output ALL FC Pro FC  ----- 14/12/2017
--- To have ability to pass 1 Item or 1 Supplier is just a bonus for this particular SP ....
---===========================================================================================================================================================================

exec JDE_DB_Alan.sp_Exp_FPFcst_Jde

exec JDE_DB_Alan.sp_Exp_FPFcst_Jde @ItemNumber = '4600343000'
exec JDE_DB_Alan.sp_Exp_FPFcst_Jde @SupplierNumber = '20037'
exec JDE_DB_Alan.sp_Exp_FPFcst_Jde @SupplierNumber = '979516','1262','35610','20025','503978','20037'   -- does not work 

select * from JDE_DB_Alan.FCPRO_Fcst_NP_upload_tmp np

--- BCP output -- it works in DOS environment !! --- 14/12/2017
bcp " with cte as ( select f.ItemNumber,convert(varchar(6),f.Date,112) as Period_YM,f.Value,'Adj_FC' as Typ_  from JDE_DB_Alan.JDE_DB_Alan.FCPRO_Fcst f union all select s.ItemNumber,convert(varchar(6),convert(datetime,concat(s.CYM,'01')),112) Period_YM,s.SalesQty,'Sales' as Typ_ from JDE_DB_Alan.JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload s  ) ,  comb as ( select cte.ItemNumber,cte.Typ_,cte.Period_YM,cte.Value,m.StandardCost,p.Pareto,m.UOM  from cte left join JDE_DB_Alan.JDE_DB_Alan.Master_ML345 m on cte.ItemNumber = m.ItemNumber  left join JDE_DB_Alan.JDE_DB_Alan.FCPRO_Fcst_Pareto p on cte.Itemnumber = p.ItemNumber  where  m.PrimarySupplier in ('20037')), np as ( select * from JDE_DB_Alan.JDE_DB_Alan.FCPRO_Fcst_NP_upload_tmp ) select comb.ItemNumber,'HD' as BranchPlant,comb.UOM,'BF' as ForcastType ,comb.Period_YM ,convert(date,dateadd(d,-1,dateadd(mm,1,convert(datetime,comb.Period_YM+'01',103))),103) as Period_YMD 	,comb.Value as ForecastQty,0 as ForecastAmt,0 as CustomerNumber,'N' as BypassForcing,comb.Pareto ,np.Range from comb left join np on comb.ItemNumber = np.ItemNumber where  comb.Typ_ in ('Forecast')  and not exists ( select np.ItemNumber from JDE_DB_Alan.JDE_DB_Alan.FCPRO_Fcst_NP_upload_tmp np where np.ItemNumber = comb.ItemNumber) order by Pareto asc,comb.ItemNumber,comb.Period_YM " queryout C:\Users\yaoa\Alan_HD\Alan_Work\coutt.txt -S RYDWS366\SQLEXPRESS -c -T -t,
bcp " with cte as ( select f.ItemNumber,convert(varchar(6),f.Date,112) as Period_YM,f.Value,'Adj_FC' as Typ_  from JDE_DB_Alan.JDE_DB_Alan.FCPRO_Fcst f union all select s.ItemNumber,convert(varchar(6),convert(datetime,concat(s.CYM,'01')),112) Period_YM,s.SalesQty,'Sales' as Typ_ from JDE_DB_Alan.JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload s  ) ,  comb as ( select cte.ItemNumber,cte.Typ_,cte.Period_YM,cte.Value,m.StandardCost,p.Pareto,m.UOM  from cte left join JDE_DB_Alan.JDE_DB_Alan.Master_ML345 m on cte.ItemNumber = m.ItemNumber  left join JDE_DB_Alan.JDE_DB_Alan.FCPRO_Fcst_Pareto p on cte.Itemnumber = p.ItemNumber  where  m.PrimarySupplier in ('20037')), np as ( select * from JDE_DB_Alan.JDE_DB_Alan.FCPRO_Fcst_NP_upload_tmp ) select comb.ItemNumber,'HD' as BranchPlant,comb.UOM,'BF' as ForcastType ,comb.Period_YM ,convert(date,dateadd(d,-1,dateadd(mm,1,convert(datetime,comb.Period_YM+'01',103))),103) as Period_YMD 	,comb.Value as ForecastQty,0 as ForecastAmt,0 as CustomerNumber,'N' as BypassForcing,comb.Pareto ,np.Range from comb left join np on comb.ItemNumber = np.ItemNumber where  comb.Typ_ in ('Forecast')  and not exists ( select np.ItemNumber from JDE_DB_Alan.JDE_DB_Alan.FCPRO_Fcst_NP_upload_tmp np where np.ItemNumber = comb.ItemNumber)  and comb.itemNumber in ('2780143000') order by Pareto asc,comb.ItemNumber,comb.Period_YM " queryout C:\Users\yaoa\Alan_HD\Alan_Work\coutt.txt -S RYDWS366\SQLEXPRESS -c t, -T
																							 
bcp " with cte as ( select f.ItemNumber,convert(varchar(6),f.Date,112) as Period_YM,f.Value,'Adj_FC' as Typ_  from JDE_DB_Alan.JDE_DB_Alan.FCPRO_Fcst f union all select s.ItemNumber,convert(varchar(6),convert(datetime,concat(s.CYM,'01')),112) Period_YM,s.SalesQty,'Sales' as Typ_ from JDE_DB_Alan.JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload s  ) ,  comb as ( select cte.ItemNumber,cte.Typ_,cte.Period_YM,cte.Value,m.StandardCost,p.Pareto,m.UOM  from cte left join JDE_DB_Alan.JDE_DB_Alan.Master_ML345 m on cte.ItemNumber = m.ItemNumber  left join JDE_DB_Alan.JDE_DB_Alan.FCPRO_Fcst_Pareto p on cte.Itemnumber = p.ItemNumber  where  m.PrimarySupplier in ('979516','1262','35610','20025')	or cte.ItemNumber in ('27.266.000','27.310.036','27.232.700','29.115.000B','D7174Q748','2780143000','2780047000','2851236354')), np as ( select * from JDE_DB_Alan.JDE_DB_Alan.FCPRO_Fcst_NP_upload_tmp ) select comb.ItemNumber,'HD' as BranchPlant,comb.UOM,'BF' as ForcastType ,comb.Period_YM ,convert(varchar(10),convert(date,dateadd(d,-1,dateadd(mm,1,convert(datetime,comb.Period_YM+'01',105))),103),103) as Period_YMD ,comb.Value as ForecastQty,0 as ForecastAmt,0 as CustomerNumber,'N' as BypassForcing,comb.Pareto ,np.Range from comb left join np on comb.ItemNumber = np.ItemNumber where  comb.Typ_ in ('Forecast')  and not exists ( select np.ItemNumber from JDE_DB_Alan.JDE_DB_Alan.FCPRO_Fcst_NP_upload_tmp np where np.ItemNumber = comb.ItemNumber)  order by Pareto asc,comb.ItemNumber,comb.Period_YM " queryout C:\Users\yaoa\Alan_HD\Alan_Work\coutt.txt -S RYDWS366\SQLEXPRESS -c -t, -T
																							 
																							 
bcp " with cte as ( select f.ItemNumber,convert(varchar(6),f.Date,112) as Period_YM,f.Value,'Adj_FC' as Typ_  from JDE_DB_Alan.JDE_DB_Alan.FCPRO_Fcst f union all select s.ItemNumber,convert(varchar(6),convert(datetime,concat(s.CYM,'01')),112) Period_YM,s.SalesQty,'Sales' as Typ_ from JDE_DB_Alan.JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload s  ) ,  comb as ( select cte.ItemNumber,cte.Typ_,cte.Period_YM,cte.Value,m.StandardCost,p.Pareto,m.UOM  from cte left join JDE_DB_Alan.JDE_DB_Alan.Master_ML345 m on cte.ItemNumber = m.ItemNumber  left join JDE_DB_Alan.JDE_DB_Alan.FCPRO_Fcst_Pareto p on cte.Itemnumber = p.ItemNumber  where  m.PrimarySupplier in ('979516','1262','35610','20025')	or cte.ItemNumber in ('27.266.000','27.310.036','27.232.700','D7174Q748','2780143000','2780047000','2851236354')), np as ( select * from JDE_DB_Alan.JDE_DB_Alan.FCPRO_Fcst_NP_upload_tmp ) select comb.ItemNumber,'HD' as BranchPlant,comb.UOM,'BF' as ForcastType ,comb.Period_YM ,convert(varchar(10),convert(date,dateadd(d,-1,dateadd(mm,1,convert(datetime,comb.Period_YM+'01',105))),103),103) as Period_YMD ,comb.Value as ForecastQty,0 as ForecastAmt,0 as CustomerNumber,'N' as BypassForcing,comb.Pareto from comb left join np on comb.ItemNumber = np.ItemNumber where  comb.Typ_ in ('Forecast')  and not exists ( select np.ItemNumber from JDE_DB_Alan.JDE_DB_Alan.FCPRO_Fcst_NP_upload_tmp np where np.ItemNumber = comb.ItemNumber)  order by Pareto asc,comb.ItemNumber,comb.Period_YM " queryout C:\Users\yaoa\Alan_HD\Alan_Work\coutt.txt -S RYDWS366\SQLEXPRESS -c -t, -T

-- Use below to do Bcp --- ready to load no more excessive columns ---						
bcp " with cte as ( select f.ItemNumber,convert(varchar(6),f.Date,112) as Period_YM,f.Value,'Adj_FC' as Typ_  from JDE_DB_Alan.JDE_DB_Alan.FCPRO_Fcst f union all select s.ItemNumber,convert(varchar(6),convert(datetime,concat(s.CYM,'01')),112) Period_YM,s.SalesQty,'Sales' as Typ_ from JDE_DB_Alan.JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload s  ) ,  comb as ( select cte.ItemNumber,cte.Typ_,cte.Period_YM,cte.Value,m.StandardCost,p.Pareto,m.UOM  from cte left join JDE_DB_Alan.JDE_DB_Alan.Master_ML345 m on cte.ItemNumber = m.ItemNumber  left join JDE_DB_Alan.JDE_DB_Alan.FCPRO_Fcst_Pareto p on cte.Itemnumber = p.ItemNumber  where  m.PrimarySupplier in ('979516','1262','35610','20025')	or cte.ItemNumber in ('27.266.000','27.310.036','27.232.700','27.241.785','27.247.785','27.264.850B','27.316.000B','2930230000B','82.432.901B','82.434.901B','29.115.000B','D7174Q748','2780143000','2780047000','2851236354')), np as ( select * from JDE_DB_Alan.JDE_DB_Alan.FCPRO_Fcst_NP_upload_tmp ) select comb.ItemNumber,'HD' as BranchPlant,comb.UOM,'BF' as ForcastType ,convert(varchar(10),convert(date,dateadd(d,-1,dateadd(mm,1,convert(datetime,comb.Period_YM+'01',105))),103),103) as Period_YMD ,comb.Value as ForecastQty,0 as ForecastAmt,0 as CustomerNumber,'N' as BypassForcing from comb left join np on comb.ItemNumber = np.ItemNumber where  comb.Typ_ in ('Forecast')  and not exists ( select np.ItemNumber from JDE_DB_Alan.JDE_DB_Alan.FCPRO_Fcst_NP_upload_tmp np where np.ItemNumber = comb.ItemNumber)  order by Pareto asc,comb.ItemNumber,comb.Period_YM " queryout C:\Users\yaoa\Alan_HD\Alan_Work\coutt.txt -S RYDWS366\SQLEXPRESS -c -t, -T

----------------------------------------------------------------------


--------------------------------------- FC History -----
select *,cast(convert(varchar(6),f.Date,112) as int) CYM 
from JDE_DB_Alan.FCPRO_Fcst f where f.ItemNumber in ('40.033.131') 
		and f.date > cast(DATEADD(mm, DATEDIFF(mm, 0, GETDATE()), 0) as datetime)
		and f.DataType1 in ('Adj_FC')			--26/2/2018

select cast(DATEADD(mm, DATEDIFF(mm, 0, GETDATE()), 0) as datetime)

select * from JDE_DB_Alan.FCPRO_Fcst f where f.ItemNumber in ('40.033.131')		and f.DataType1 in ('Adj_FC')			--26/2/2018
select * from JDE_DB_Alan.FCPRO_Fcst_History h where h.ItemNumber in ('40.033.131')

select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('31.166.131')
select * from JDE_DB_Alan.Master_ML345 m where m.PrimarySupplier in ('20037')
select * from JDE_DB_Alan.FCPRO_Fcst f where f.ItemNumber in ('2780047000')	and f.DataType1 in ('Adj_FC')			--26/2/2018
--------------End of Transfer/Export to JDE Method 3-2 Using SQL Function --------------------------------------------------------------------------------------------------
       

---============================================================================================
--- Transfer/Export to JDE Method 1. -- Use variable and You can Passing Multi Values --- working  -- 11/12/2017
---============================================================================================

declare @ItemIDs table ( Ids varchar(1000) ) 
--insert into @ItemIDs values ('40.033.131')
--insert into @ItemIDs values ('085552500D212'),('40.033.131')
insert into @ItemIDs values ('085552500D064'),('085552500D088'),('085552500D137'),('085552500D212'),('085552500D249'),('085552500D337'),('770531003532'),('770531003535'),('770531003531')

;with cte as 
	( 
		 ( select s.ItemNumber
		 ,case 
			 when s.Month >= 10 then concat(s.CY,format(s.Month,'0') ) 
			 when s.Month <10 then concat(s.CY,format(s.Month,'00') )
			end as CYM
		 ,s.SalesQty as Value,'Sales' as Typ
		 from JDE_DB_Alan.JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload s where s.ItemNumber in (select ids from @ItemIDs) )

		union all

		 ( select fc.ItemNumber,cast(CONVERT(VARCHAR(6),fc.Date, 112) as int) as CYM,fc.Value ,'FC' as Typ from JDE_DB_Alan.FCPRO_Fcst fc where fc.ItemNumber in (select ids from @ItemIDs) ) and fc.DataType1 in ('Adj_FC')			--26/2/2018
		 
--order by t.ItemNumber,t.CYM 
	),
--select * from cte 
comb as ( select cte.ItemNumber,cte.Typ,cte.CYM,cte.Value,m.StandardCost,p.Pareto from cte left join JDE_DB_Alan.Master_ML345 m on cte.ItemNumber = m.ItemNumber
		 left join JDE_DB_Alan.FCPRO_Fcst_Pareto p on cte.Itemnumber = p.ItemNumber
	     where m.PrimarySupplier in ('20037')
	)

select * from comb

---===============================================================================================================================================================
--- Transfer/Export to JDE Method 2. --- Simplified Version -- ALan's method Priod in format as 'YYYY-MM-DD hh:mm:ss'  - No need to Use CTE to transform DateTime as Method 1,Modified tbl 'FCPRO_Fcst' to Add new Col 'YMD'
---================================================================================================================================================================
select f.ItemNumber,f.Date as Date_,f.Value,'Adj_FC' as Type_
 from JDE_DB_Alan.FCPRO_Fcst f 
 where f.ItemNumber in ('40.033.131') and f.DataType1 in ('Adj_FC') 
union all
select s.ItemNumber,convert(datetime,concat(s.CYM,'01')) as Date_,s.SalesQty,'Sales' as Typ_
from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload s where s.ItemNumber in ('40.033.131')


----------------------------------------------------------------------------------------------------------------------
---------------- Passing multiple/dynamic values to Stored Procedures & Functions | Part 3 – by using #table  using TMP -----works Yes !! 14/12/2017------------------
https://sqlwithmanoj.com/2012/09/09/passing-multipledynamic-values-to-stored-procedures-functions-part3-by-using-table/
-- Create Stored Procedure with no parameter, it will use the temp table created outside the SP:
---==============================================================================================================================================================

CREATE PROCEDURE JDE_DB_Alan.sp_Exp_FPFcst_tmp
AS
BEGIN
     
	;with cte as (
		select f.ItemNumber,convert(varchar(6),f.Date,112) as Period_YM,f.Value,'Adj_FC' as Typ_
		 from JDE_DB_Alan.FCPRO_Fcst f 	
		  f.DataType1 in ('Adj_FC') 
		union all
		select s.ItemNumber,convert(varchar(6),convert(datetime,concat(s.CYM,'01')),112) Period_YM,s.SalesQty,'Sales' as Typ_
		from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload s 		
	  ) ,
	   comb as ( select cte.ItemNumber,cte.Typ_,cte.Period_YM,cte.Value,m.StandardCost,p.Pareto,m.UOM,m.PrimarySupplier from cte left join JDE_DB_Alan.Master_ML345 m on cte.ItemNumber = m.ItemNumber
			 left join JDE_DB_Alan.FCPRO_Fcst_Pareto p on cte.Itemnumber = p.ItemNumber
			 where cte.ItemNumber in ( select SKU from  #tblItemList)			       
		)

	select comb.ItemNumber,'HD' as BranchPlant,comb.UOM,'BF' as ForcastType
			,comb.Period_YM,convert(date,dateadd(d,-1,dateadd(mm,1,convert(datetime,comb.Period_YM+'01',103))),103) as Period_YMD,comb.Value as ForecastQty,0 as ForecastAmt,0 as CustomerNumber,'N' as BypassForcing,comb.Pareto from comb
	where comb.Typ_ in ('Adj_FC')  
	order by Pareto asc,comb.ItemNumber,comb.Period_YM
 
END
--GO
 
-- Now, create a temp table, insert records with same set of values we used in previous 2 posts:
CREATE TABLE #tblItemList (SKU NVARCHAR(100)) 
INSERT INTO #tblItemList
SELECT SKU FROM (VALUES ( '2671000000'),('27.171.180') ) AS T(SKU)
 
-- Now execute the SP, it will use the above records as input and give you required results:


EXEC JDE_DB_Alan.sp_Exp_FPFcst_tmp
 
---- Final Cleanup ---
DROP TABLE #tblItemList 
DROP PROCEDURE JDE_DB_Alan.sp_Exp_FPFcst_tmp



---======================================================================================================================================
-------------- Passing multiple/dynamic values to Stored Procedures & Functions | Part 4 – by using TVP 14/12/2017 works Yeah !------------------
--- or TVP- TableValuedParameters ---
https://sqlwithmanoj.com/2012/09/10/passing-multipledynamic-values-to-stored-procedures-functions-part4-by-using-tvp/
---=====================================================================================================================================

CREATE TYPE dbo.tvpItemList AS TABLE( SKU nvarchar(max) NULL)
CREATE TYPE dbo.tvpSupplierList AS TABLE( SupplierNum nvarchar(max) NULL)

CREATE PROCEDURE JDE_DB_Alan.sp_Exp_FPFcst_tvp
		( @tvpItem tvpItemList  READONLY, 
		  @tvpSupplier tvpSupplierList readonly)
AS
BEGIN

	;with cte as (
		select f.ItemNumber,convert(varchar(6),f.Date,112) as Period_YM,f.Value,'Adj_FC' as Typ_
		 from JDE_DB_Alan.FCPRO_Fcst f 
		 --where s.ItemNumber in (select ids from @ItemIDs)
		 --where f.ItemNumber in ('40.033.131')
		  f.DataType1 in ('Adj_FC') 
		union all
		select s.ItemNumber,convert(varchar(6),convert(datetime,concat(s.CYM,'01')),112) Period_YM,s.SalesQty,'Sales' as Typ_
		from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload s 
		--where s.ItemNumber in (select ids from @ItemIDs)
		--where s.ItemNumber in ('40.033.131')
	  ) ,
	   comb as ( select cte.ItemNumber,cte.Typ_,cte.Period_YM,cte.Value,m.StandardCost,p.Pareto,m.UOM,m.PrimarySupplier from cte left join JDE_DB_Alan.Master_ML345 m on cte.ItemNumber = m.ItemNumber
			 left join JDE_DB_Alan.FCPRO_Fcst_Pareto p on cte.Itemnumber = p.ItemNumber
			 where cte.ItemNumber in ( select SKU from @tvpItem)
			      and m.PrimarySupplier in ( select SupplierNum from @tvpSupplier)
			       
		)

	select comb.ItemNumber,'HD' as BranchPlant,comb.UOM,'BF' as ForcastType
			,comb.Period_YM,convert(date,dateadd(d,-1,dateadd(mm,1,convert(datetime,comb.Period_YM+'01',103))),103) as Period_YMD,comb.Value as ForecastQty,0 as ForecastAmt,0 as CustomerNumber,'N' as BypassForcing,comb.Pareto from comb
	where comb.Typ_ in ('Adj_FC')
	order by Pareto asc,comb.ItemNumber,comb.Period_YM

END

DECLARE  @tblSkuList as tvpItemList ;
Declare  @tblSupplierList as tvpSupplierList;
INSERT into @tblSkuList(SKU) values ('27.171.785'),('27.171.879');
INSERT into @tblSupplierList(SupplierNum) values ('20037'),('20039');
EXECUTE JDE_DB_Alan.sp_Exp_FPFcst_tvp  @tblSkuList,@tblSupplierList

drop procedure JDE_DB_Alan.sp_Exp_FPFcst_tvp


--------------------------------------------------------------------------------------
--- To get list of table type,columns and datatype for a user-defined table type ---

select tt.name AS table_Type
      ,c.name AS table_Type_col_name
      ,st.name AS table_Type_col_datatype
from sys.table_types tt
inner join sys.columns c on c.object_id = tt.type_table_object_id
INNER JOIN sys.systypes AS ST  ON ST.xtype = c.system_type_id

-------------------------------------------------------------------------
IF EXISTS (SELECT * FROM sys.types WHERE is_table_type = 1 AND name = 'StrTable')
 drop type StrTable
SELECT * FROM sys.types WHERE is_table_type = 1 AND name = 'IntTable'

---------------------------------------------------------------------------------------------------------------------------------------------

---=============================================================================================================================
--- Transfer/Export to JDE Method 3-1. (Use Table Variable )  ---Very Versatile it include Hist/Hierarchy etc -- ALan's method -- Priod in format as 'YYYYMM' - needto further convert text to Int for easy handling ? - on Monthly Bases By SKU - 14/12/2017
--- Below Works (in SSMS Using Table Variable ), However How to use in 'Programmability' ? How to pass Parameters to Code in 'Programmability' ?
---=============================================================================================================================
declare @ItemIDs table ( Item_ID nvarchar(1000) )
declare @SupplierIDs table (Supplier_ID  varchar(1000) );

--insert into @ItemIDs values ('2780143000'),('2780047000'),('2851236354')
--insert into @SupplierIDs values ('979516'),('1262'),('35610'),('20025')			--Imelda_Chan
--insert into @SupplierIDs values ('503978'),('20037')								--Margaret_Dost
insert into @SupplierIDs values ('1459')											--Salman_Saeed

;with cte as 
	(
	 select f.ItemNumber,convert(varchar(6),f.Date,112) as Period_YM,f.Value,'Adj_FC' as Typ_
	  from JDE_DB_Alan.FCPRO_Fcst f 
	 --where s.ItemNumber in (select ids from @ItemIDs)
	 --where f.ItemNumber in ('40.033.131')
	  f.DataType1 in ('Adj_FC')					--26/2/2018
	union all
	 select s.ItemNumber,convert(varchar(6),convert(datetime,concat(s.CYM,'01')),112) Period_YM,s.SalesQty,'Sales' as Typ_
	 from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload s 
	--where s.ItemNumber in (select ids from @ItemIDs)
	--where s.ItemNumber in ('40.033.131')
  ) ,

   comb as ( select cte.ItemNumber,cte.Typ_,cte.Period_YM,cte.Value,m.StandardCost,p.Pareto,m.UOM,m.Description,m.LeadtimeLevel,m.QtyOnHand,m.SellingGroup,m.FamilyGroup,m.Family
				,m.PrimarySupplier
				,m.PlannerNumber
				,case m.PlannerNumber when '20071' then 'Rosie Ashpole'
										  when '20072' then 'Salman Saeed'
										  when '20004' then 'Margaret Dost'	
										  when '20005' then 'Imelda Chan'										  
										  else 'Unknown'
					end as Owner_
			 from cte left join JDE_DB_Alan.Master_ML345 m on cte.ItemNumber = m.ItemNumber
					 left join JDE_DB_Alan.FCPRO_Fcst_Pareto p on cte.Itemnumber = p.ItemNumber					 
	        where 
				-- cte.ItemNumber in (select Item_ID from @ItemIDs)
				  m.PrimarySupplier in (select Supplier_ID from @SupplierIDs)		       
		 	     --m.PrimarySupplier in ('20037')		
				 -- or cte.ItemNumber in ('27.266.000','27.310.036','27.232.700','27.241.785','27.247.785')			
	  ),

   staging as 
			(select  comb.*
					,c.LongDescription as SellingGroup_
					,d.LongDescription as FamilyGroup_
					,e.LongDescription as Family_0
					--,tbl.Family as Family_1
					--,f.StandardCost,f.WholeSalePrice
			from comb left join JDE_DB_Alan.MasterSellingGroup c  on comb.SellingGroup = c.Code
					 left join JDE_DB_Alan.MasterFamilyGroup d  on comb.FamilyGroup = d.Code
					 left join JDE_DB_Alan.MasterFamily e  on comb.Family = e.Code
			   ),
	np as ( select * from JDE_DB_Alan.FCPRO_Fcst_NP_upload_tmp )
  

 select staging.ItemNumber,'HD' as BranchPlant,staging.UOM,'BF' as ForcastType
		,staging.Period_YM
		-- Get Last day of the Previous month,and format to dd/mm/yyyy for JDE format
		,convert(varchar(10),convert(date,dateadd(d,-1,dateadd(mm,1,convert(datetime,staging.Period_YM+'01',105))),103),103) as Period_YMD		
		,staging.Value as ForecastQty,0 as ForecastAmt,0 as CustomerNumber,'N' as BypassForcing,staging.Pareto 
		,np.Range,staging.StandardCost
		--,staging.Description,staging.FamilyGroup_
		,staging.QtyOnHand as SOH
		,staging.PlannerNumber,staging.PrimarySupplier,staging.Owner_
 from staging left join np on staging.ItemNumber = np.ItemNumber
 where  staging.Typ_ in ('Adj_FC')
	--and np.Range is null	 
	  --and staging.ItemNumber not in ( select np.ItemNumber from JDE_DB_Alan.FCPRO_Fcst_NP_upload_tmp np )
	  and not exists ( select np.ItemNumber from JDE_DB_Alan.FCPRO_Fcst_NP_upload_tmp np where np.ItemNumber = staging.ItemNumber)
 order by Pareto asc,staging.ItemNumber,staging.Period_YM


 select convert(varchar(10),getdate(),103)

   --- Use this Query to Get Summmary On SKU level ---
--select comb.ItemNumber,comb.Pareto,sum(comb.value) FC_24 from comb
--where comb.Typ_ in ('Forecast')
--group by comb.ItemNumber,comb.Pareto
--order by Pareto asc,FC_24 desc

---================ End of Transfer / Export to JDE =============================================================================================================================================================




---=========================================================================================================================================================================================
  --------------------------------- Some Code Snippet ------------------------------------------------------------------------------

  
--**********************From GWA Old SQL Code 23/1/2018, Pay attention to Join Table *********************************************************

Update a
set a.PeriodicValue = f.Value
from  (((DSX_BK_301381.dbo.EXP_ADJFC_View a
        left join Staging.dbo.DSX_ITEM_WAREHOUSE_MASTER b
         on a.ItemName = b.Item and a.[Ship To] = b.Whse and a.Dept = b.State) 
         left join STAGING.dbo.MVXItemMaster d  on a.ItemName = d.ITEM)
       inner join 
       ( select b.ItemName,b.State,b.Whse,b.Value,b.Date  from STAGING.dbo.FinalFcstShot_PRD b
				where 
				--b.itemname in ('1512')and
			     b.Whse in ('200') 
				and b.State not in ('OS')
				and b.DType in ('Units') 
				and b.DataType in ('Adjusted Forecast')
				and b.DownLoadDate in ('2015-01-31')
		) f
       on a.ItemName = f.ItemName and a.Dept = f.State and a.[Ship To] = f.Whse and a.PeriodicDate = f.Date )

where -- a.ItemName='F6001' and a.Dept='NSW' and a.[Ship To]='200'
      a.ItemName in
     ('1512')    
    -- and a.Dept in ('NSW','VIC','QLD','SA','WA')
       and a.Dept in ('NSW')
    --  and a.[Ship To] in ('200','300','400','500','550','521','350')
       and a.[Ship To] in ('200')
      and a.PeriodicDataElementType='Forecast' and a.PeriodicDataElement='Adjusted Forecast'

     -- and a.PeriodicDate = '2015-01-01'
      and a.PeriodicDate between '2015-02-01' and '2016-01-01'
     -- and a.PeriodicDate= convert(varchar(10),dateadd(mm,11,convert(varchar(7),GETDATE(),126)+'-01'),126)            
     --and PeriodicDate between  convert(varchar(10),dateadd(mm,1,convert(varchar(7),GETDATE(),126)+'-01'),126)
                         --and convert(varchar(10),dateadd(mm,11,convert(varchar(7),GETDATE(),126)+'-01'),126)
      and a.Div is not null and LEN(a.Div)!=0 and
      a.Dept is not null and LEN(a.Dept)!=0 and
      a.[Ship To] is not null and LEN(a.[Ship To])!=0 and
      a.[ItemName] is not null and LEN(a.[ItemName]) !=0 and
      b.FcstMethod in ('Y')     

---**************************************************************************************************


  ----------------------- Update FCPRo FC to Pad with leading zero ------------------------------	
   
------- UnPivot Function Example ( from Horizontal way to Vertical - good of source data for Pivot table manupilation, but when you talk about Pivot table, 
------- You are talking about 'Pivot' which is about bring Data in Horizontal way thus 'Pivot' for Nice presentation  ) ----------------- 25/11/2017
with CalendarFrame as (
 select 1 as t,cast(DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,GETDATE())-35,0)) as datetime) as eom
 union all
 select t+1,dateadd(mm, 1, eom)
 from CalendarFrame
),
MonthlyCalendar as
(
 select top 36 t,cast(replace(convert(varchar(8),[eom],126),'-','') as integer) [eom] from CalendarFrame
)
select * from MonthlyCalendar   

SELECT [ItemNumber]
,[DataType1]
,[1]
,[2]
,[3]
,[4]
,[5]
,[6]
,[7]
,[8]
,[9]
,[10]
,[11]
,[12]
,[13]
,[14]
,[15]
,[16]
,[17]
,[18]
,[19]
,[20]
,[21]
,[22]
,[23]
,[24]
FROM [JDE_DB_Alan].[JDE_DB_Alan].[FCPRO_Fcst_downloaded]


select ItemNumber,DataType1,period,value
from JDE_DB_Alan.JDE_DB_Alan.FCPRO_Fcst_downloaded
unpivot
( value for period in ([1],[2],[3],[4],[5],[6],[7],[8]
						,[9],[10],[11],[12],[13],[14],[15],[16]
						,[17],[18],[19],[20],[21],[22],[23],[24] ) 
) as unpvt

-------------- Pivot Function Example ( this is better version with Join to Calendar CTE and simplifed Period using number as improve performance significantly 29/11/2017-----------------------
select distinct s.ItemNumber from JDE_DB_Alan.JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload s
select * from JDE_DB_Alan.JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload s

with CalendarFrame as 
	(
	  select 1 as t,cast(DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,GETDATE())-35,0)) as datetime) as eom
	  union all
	  select t+1,dateadd(mm, 1, eom)
	  from CalendarFrame
	)
	,MonthlyCalendar as
	 (
	  select top 36 t,cast(replace(convert(varchar(8),[eom],126),'-','') as integer) [eom] from CalendarFrame
	 )
	--select * from MonthlyCalendar   

	,fc_ as (
		select s.ItemNumber
				,case 
						when s.Month >= 10 then concat(s.CY,format(s.Month,'0') )						 
							when s.Month <10 then concat(s.CY,format(s.Month,'00') )
					end as CYM
			   ,s.SalesQty
		 from JDE_DB_Alan.JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload s 
		-- where s.ItemNumber in ('18.605.018')		
		  where s.ItemNumber in ('42.210.031')		 		
				)

	  -- fc as (select * from fc_ left join MonthlyCalendar mc on fc_.CYM = mc.eom)
	  -- select * from fc  order by fc.ItemNumber,eom
	 -- select fc_.ItemNumber,fc_.CYM,fc_.SalesQty,mc.t from fc_ left join MonthlyCalendar mc on fc_.CYM = mc.eom

  ,pvt as (
  
		select *
		 from ( 
				select fc_.ItemNumber,fc_.CYM,fc_.SalesQty,mc.t from fc_ left join MonthlyCalendar mc on fc_.CYM = mc.eom
			  ) as sourcetb
			
		pivot
		  ( sum(salesqty) for t in ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24]) 	
		   ) as pivottable
            
				) 
select ItemNumber,[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24] from pvt
    

select ItemNumber,ISNULL([1],0) [1],ISNULL([2],0) [2],ISNULL([3],0) [3],ISNULL([4],0) [4],ISNULL([5],0) [5],
       ISNULL([6],0) [6],ISNULL([7],0) [7],ISNULL([8],0) [8],ISNULL([9],0) [9],ISNULL([10],0) [10],ISNULL([11],0) [11],ISNULL([12],0) [12], 
       ISNULL([13],0) [13],ISNULL([14],0) [14],ISNULL([15],0) [15],ISNULL([16],0) [16],ISNULL([17],0) [17],ISNULL([18],0) [18],ISNULL([19],0) [19], 
       ISNULL([20],0) [20],ISNULL([21],0) [21],ISNULL([22],0) [22],ISNULL([23],0) [23],ISNULL([24],0) [24] 
from pvt
order by pvt.ItemNumber


----------------  This is slow version but using hard coded Period Name  29/11/2017------------------------------
 pivot
  (sum(salesqty) for CYM in ( [201501],[201502],[201503],[201504],[201505],[201506],[201507],[201508],[201509],[201510],[201511],[201512]
							 ,[201601],[201602],[201603],[201604],[201605],[201606],[201607],[201608],[201609],[201610],[201611],[201612]	
							 ,[201701],[201702],[201703],[201704],[201705],[201706],[201707],[201708],[201709],[201710] )  	 ) as pivottable
            
			) 
------------------------------------------------------------------------------------------------------------------
---=================================================================================================================

  --- a Nice Table show all Records and Break down on each Upload date For Monthly Cycle------ 7/12/2017
  -- can use OLAP sum or Running Total Function to get your result ---
  --use JDE_DB_Alan
  --go

     --- Version 1 -------
  with cte as 
  (
	  select convert(varchar(13),h.ReportDate,120) as Date_Uploaded
				,count(*)  as Records_Uploaded
	  from JDE_DB_Alan.FCPRO_Fcst_History h
	  group by  convert(varchar(13),h.ReportDate,120) )
  
  ,c as (select *, sum(cte.Records_Uploaded) over (order by Date_Uploaded) TTL_Records_HistTbl from cte 
		  --where cte.Date_Uploaded > '2019-07-02' and cte.Date_Uploaded < '2019-07-26 14:59:00'
		  --order by cte.Date_Uploaded asc
		  )
  --select * from c
   
  	SELECT COALESCE(Date_Uploaded, 'Total') as Date_Uploaded				---If you want to display more column values without an aggregation function use GROUPING SETS instead of ROLLUP:	
	       ,isnull(TTL_Records_HistTbl,0) as TTL_Records_HistTbl
			,SUM(Records_Uploaded) as Records_Uploaded
	FROM c
	GROUP BY GROUPING SETS((Date_Uploaded,TTL_Records_HistTbl),())
	--order by TTL_Records_HistTbl;											--- --Displays summary row as the first row in query result;

       
		
	--- Version 2 ------- better version for validation
   -- Revised on 16/11/2018 to include aggregated Forecast Quantities & Values
  with cte as 
		  (
			  select convert(varchar(13),fh.ReportDate,120) as Date_Uploaded
						,count(*)  as Records_Uploaded
						,sum(fh.FC_Vol) as FC_Qty 
						,sum(fh.FC_Vol*m.WholeSalePrice) as FC_Val
			  from JDE_DB_Alan.vw_FC_Hist fh
			           left join JDE_DB_Alan.vw_Mast m on fh.ItemNumber = m.ItemNumber
			  --from JDE_DB_Alan.FCPRO_Fcst_History fh
			  --  where fh.ItemNumber in ('42.210.031') and fh.myReportDate4 = 20181115
			  group by  convert(varchar(13),fh.ReportDate,120) 
			 -- order by Date_Uploaded       
			   )
  
	  select *
			, sum(cte.Records_Uploaded) over (order by Date_Uploaded) TTL_Records_HistTbl 	        
	  from cte 
	  --where cte.Date_Uploaded > '2018-11-06' and cte.Date_Uploaded < '2018-11-26 14:59:00'
	  order by cte.Date_Uploaded asc


  exec JDE_DB_Alan.sp_Z_FC_Hist_Summary 


     select * from JDE_DB_Alan.FCPRO_Fcst_History h where  h.ReportDate > '2019-12-10' and h.ReportDate <'2019-12-15'
   select * from JDE_DB_Alan.FCPRO_Fcst_History h where h.ItemNumber in ('52.034.000') and h.ReportDate > '2019-12-15' and h.ReportDate <'2019-12-25'
    select * from JDE_DB_Alan.FCPRO_Fcst_History h where h.ItemNumber in ('52.034.000') and h.ReportDate > '2019-12-10' and h.ReportDate <'2019-12-15'

 select distinct * from JDE_DB_Alan.FCPRO_Fcst f where f.ItemNumber in ('82.058.928')


  select distinct h.ReportDate from JDE_DB_Alan.FCPRO_Fcst_History h where h.ItemNumber in ('82.058.928')
  select * from JDE_DB_Alan.FCPRO_Fcst_History h where h.ItemNumber in ('42.210.031') and h.ReportDate > '2018-09-02'
  select * from JDE_DB_Alan.FCPRO_Fcst_History fh where fh.ItemNumber in ('27.176.320')
  select distinct fh.ReportDate from JDE_DB_Alan.FCPRO_Fcst_History fh 
  select distinct fh.ItemNumber from JDE_DB_Alan.FCPRO_Fcst_History fh where fh.ReportDate  between '2018-11-06 13:20' and '2018-11-16 13:39:00'
  select * from JDE_DB_Alan.FCPRO_Fcst_History fh where fh.ReportDate  between '2018-11-06 13:20' and '2018-11-16 13:39:00'  select distinct fh.ItemNumber from JDE_DB_Alan.FCPRO_Fcst_History fh where fh.ReportDate  between '2018-11-06 13:20' and '2018-11-16 13:39:00'

    select * from JDE_DB_Alan.FCPRO_Fcst_History fh where fh.ReportDate  between '2020-12-01' and '2020-12-15 17:00:00'
    select * from JDE_DB_Alan.FCPRO_Fcst_History fh where fh.ReportDate  between '2021-01-01' and '2021-01-16 15:00:00'


   select fh.ReportDate,count(fh.Value) from JDE_DB_Alan.FCPRO_Fcst_History fh where fh.ReportDate > '2018-04-10' group by fh.ReportDate order by fh.ReportDate
   select fh.ReportDate,count(fh.Value) from JDE_DB_Alan.FCPRO_Fcst_History fh where fh.ReportDate between '2018-01-11' and '2018-01-18 13:00:00' group by fh.ReportDate order by fh.ReportDate
  select fh.ReportDate,count(fh.Value) from JDE_DB_Alan.FCPRO_Fcst_History fh where fh.ReportDate between '2018-03-01' and '2018-03-09 13:00:00' group by fh.ReportDate order by fh.ReportDate
  select fh.ReportDate,count(fh.Value) RecordCt from JDE_DB_Alan.FCPRO_Fcst_History fh where fh.ReportDate between '2018-06-15' and '2018-06-29 13:00:00' group by fh.ReportDate order by fh.ReportDate
  select fh.ReportDate,count(fh.Value) RecordCt from JDE_DB_Alan.FCPRO_Fcst_History fh where fh.ReportDate > '2018-07-02' and fh.ReportDate <'2018-07-26 14:59:00' group by fh.ReportDate order by fh.ReportDate
  
  --- last month fc aggregated ---
  ;with a as (
		  select * from JDE_DB_Alan.FCPRO_Fcst_History fh 
		  where  ReportDate between '2019-07-01' and '2019-08-01 17:00:00' 
				--and fh.Date < '2020-07-01'
				and fh.Date < DATEADD(mm, DATEDIFF(m,0,GETDATE())+11,0)						--- next 12 month
				and fh.ItemNumber in ('Ucs801')
		  )
	select a.ItemNumber,sum(a.value) as FC_12m 
	from a 
	group by a.ItemNumber


	select dateadd(d,-1,getdate())

  select fh.ReportDate,count(fh.Value) from JDE_DB_Alan.FCPRO_Fcst_History fh where fh.ReportDate > dateadd(d,-3,getdate()) group by fh.ReportDate order by fh.ReportDate
   delete from JDE_DB_Alan.FCPRO_Fcst_History where ReportDate > '2018-08-02'
  delete from JDE_DB_Alan.FCPRO_Fcst_History where ReportDate > select dateadd(d,-3,getdate())
   delete from JDE_DB_Alan.FCPRO_Fcst_History where ReportDate > select DATEADD(mm, DATEDIFF(m,0,GETDATE()),0) +1
  delete from JDE_DB_Alan.FCPRO_Fcst_History where  ReportDate between '2018-11-05 13:00' and '2018-11-05 15:00:00'
   delete from JDE_DB_Alan.FCPRO_Fcst_History where  ReportDate > '2020-11-10' and ReportDate <'2020-11-25'
 delete from JDE_DB_Alan.FCPRO_Fcst_History where  ReportDate > '2018-12-01' and ReportDate <'2018-12-05 14:59:00'
    delete from JDE_DB_Alan.FCPRO_Fcst_History where  ReportDate between '2020-12-01' and '2020-12-15 17:00:00'

  delete from JDE_DB_Alan.FCPRO_Fcst_History where  ReportDate between '2021-01-01' and '2021-01-16 17:00:00'

  select dateadd(d,-11,getdate())
  select  getdate()+1

  select DATEADD(mm, DATEDIFF(m,0,GETDATE()),0)+1 as startdate							--	this  month	+1 day		2018-03-02 00:00:00.000	
 select DATEADD(mm, DATEDIFF(m,0,GETDATE()),0) as startdate									 --	this  month			2018-03-01 00:00:00.000	
select DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0) as startdate									-- last  month		2018-02-01 00:00:00.000
select count(*) cnt from JDE_DB_Alan.FCPRO_Fcst_History h where h.ReportDate > DATEADD(mm, DATEDIFF(m,0,GETDATE()),0) +1	

exec JDE_DB_Alan.sp_Z_FC_Hist_Summary

-- delete one month data --
select * from JDE_DB_Alan.FCPRO_Fcst_History h where h.ReportDate between '2019-11-01' and '2019-11-26'
select * from JDE_DB_Alan.FCPRO_Fcst_History h where h.ReportDate between '2018-09-28' and '2018-09-30'              -- '2018-09-30' will default to 2018-09-30 00:00:00
select * from JDE_DB_Alan.FCPRO_Fcst_History h where h.ReportDate between '2018-09-28' and '2018-09-30 17:00:00'
select distinct h.ItemNumber from JDE_DB_Alan.FCPRO_Fcst_History h where h.ReportDate between '2018-09-28' and '2018-09-30 17:00:00'
select * from JDE_DB_Alan.FCPRO_Fcst_History h where h.Date in ('2018-09-01') and h.ReportDate between '2018-09-28' and '2018-09-30 17:00:00:00'	
select * from JDE_DB_Alan.FCPRO_Fcst_History h where h.ItemNumber in ('42.210.031') and h.Date in ('2018-09-01 00:00:00.000') and h.ReportDate between '2018-09-28' and '2018-09-30 17:00:00:00'
select * from JDE_DB_Alan.FCPRO_Fcst_History h where h.ItemNumber in ('42.210.031') and h.Date in ('2018-09-01') and h.ReportDate between '2018-09-28' and '2018-09-30 17:00:00:00'			-- change h.Date format it yield same result
select * from JDE_DB_Alan.FCPRO_Fcst_History h where h.ItemNumber in ('34.081.000') and h.ReportDate between '2019-04-10' and '2019-04-30 17:00:00:00' and h.Date in ('2019-09-01')

  delete from JDE_DB_Alan.FCPRO_Fcst_History 
  where  Date in ('2018-09-01') and ReportDate between '2018-09-28' and '2018-09-30 17:00:00:00'



 -- https://stackoverflow.com/questions/19094023/sql-server-update-column-from-data-in-the-same-table    --- Update table
---============= Update FC table =========

   --- update forecast value using same table, replacing one month saved fc value with previous month value --- if something is wrong --- 11/2/2020  --- Yeah works !
;update f
 set f.value = f2.value
   from JDE_DB_Alan.FCPRO_Fcst_History f inner join JDE_DB_Alan.FCPRO_Fcst_History f2 on f.ItemNumber = f2.ItemNumber -- and f.Date = f2.Date    -- No Need ? Need !
     where f.ItemNumber = '43.205.532M' 
	       and cast(SUBSTRING(REPLACE(CONVERT(char(10),f.reportdate,126),'-',''),1,6) as integer) =202001
		   and cast(SUBSTRING(REPLACE(CONVERT(char(10),f2.reportdate,126),'-',''),1,6) as integer) =201912


;update f
set f.Value = 803
from JDE_DB_Alan.FCPRO_Fcst f
where f.DataType1 = 'Adj_FC' and f.ItemNumber in ('24.7220.1858')

select * from JDE_DB_Alan.FCPRO_Fcst f where f.ItemNumber in ('24.7220.1858') and f.DataType1 in ('Adj_FC')


select * from JDE_DB_Alan.vw_FC f where f.ItemNumber in ('18.013.089')

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


---********************************************************************
  delete from JDE_DB_Alan.FCPRO_Fcst_History 
  where  Date in ('2018-11-01') and ReportDate between '2018-11-29' and '2018-12-01 17:00:00:00'

   select * from JDE_DB_Alan.FCPRO_Fcst_History 
  where  Date in ('2018-11-01') and ReportDate between '2018-11-29' and '2018-12-01 17:00:00:00'

     select distinct h.ItemNumber  from JDE_DB_Alan.FCPRO_Fcst_History h
   where ReportDate between '2018-11-30' and '2018-12-01 17:00:00:00'
   ---********************************************************************


------------------------------------------------------------------------

DECLARE @Today DATETIME, @nMonths TINYINT
SET @Today = GETDATE()
SET @nMonths = 12

--- Month End Date ---
SELECT MonthEndDate = DATEADD(dd, -1, DATEADD(month, n.n + DATEDIFF(month, 0, @Today),0)) 
FROM (SELECT TOP(@nMonths) n = ROW_NUMBER() OVER (ORDER BY NAME) FROM master.dbo.syscolumns) n

--- Month Begin Date ---
SELECT MonthBeginDate =  DATEADD(month, n.n + DATEDIFF(month, 0, @Today),0)
FROM (SELECT TOP(@nMonths) n = ROW_NUMBER() OVER (ORDER BY NAME) FROM master.dbo.syscolumns) n

select top 12 ROW_NUMBER() OVER (ORDER BY NAME) FROM master.dbo.syscolumns
select * from master.dbo.syscolumns


-----------------------------------------------------------------------------
;update h
set h.Value = 20
--select * 
from JDE_DB_Alan.FCPRO_Fcst_History h
--where h.ReportDate between '2018-03-01' and '2018-03-02 13:00:00'
 where h.ReportDate between '2019-04-10' and '2019-04-30 17:00:00:00'
      and h.ItemNumber in ('34.081.000') 
	  and h.Date in ('2019-09-01')

;update h
set h.ReportDate = '2018-04-30 15:00:00'
--select * 
from JDE_DB_Alan.FCPRO_Fcst_History h
--where h.ReportDate between '2018-03-01' and '2018-03-02 13:00:00'
where h.ReportDate between '2018-04-20' and '2018-05-03 13:00:00'

;update h
set h.ReportDate = '2018-06-30 15:00:00'
select * 
from JDE_DB_Alan.FCPRO_Fcst_History h
--where h.ReportDate between '2018-03-01' and '2018-03-02 13:00:00'
where h.ReportDate between '2018-06-25' and '2018-06-29 13:00:00'


;update h
set h.ReportDate = '2018-07-31 15:00:00'
--select * 
from JDE_DB_Alan.FCPRO_Fcst_History h
--where h.ReportDate between '2018-03-01' and '2018-03-02 13:00:00'
where h.ReportDate between '2018-07-25' and '2018-08-1 13:00:00'

;update h
set h.ReportDate = '2019-03-31 15:00:00'
--select * 
from JDE_DB_Alan.FCPRO_Fcst_History h
--where h.ReportDate between '2018-03-01' and '2018-03-02 13:00:00'
where h.ReportDate between '2019-03-01' and '2019-03-30 13:00:00'


;update h
set h.ReportDate = '2020-04-30 15:00:00'
--select * 
from JDE_DB_Alan.FCPRO_Fcst_History h
--where h.ReportDate between '2018-03-01' and '2018-03-02 13:00:00'
where h.ReportDate between '2020-04-01' and '2020-04-15 13:00:00'

;update h
set h.ReportDate = '2020-05-31 15:00:00'
--select * 
from JDE_DB_Alan.FCPRO_Fcst_History h
--where h.ReportDate between '2018-03-01' and '2018-03-02 13:00:00'
where h.ReportDate between '2020-05-01' and '2020-05-19 13:00:00'

---------------------------------------------------------------------------
-------- 4/4/2020  -----------------

select distinct f.ItemNumber from JDE_DB_Alan.FCPRO_Fcst f 
where f.DataType1 in ('Adj_FC')

select * from JDE_DB_Alan.FCPRO_Fcst f 
where f.ItemNumber in ('40.381.000','42.210.031') and f.DataType1 in ('Adj_FC')

select * from JDE_DB_Alan.FCPRO_Fcst_History fh 
where fh.ItemNumber in ('42.210.031') and fh.DataType1 in ('Adj_FC')
	  and fh.ReportDate between '2020-04-01' and '2020-04-09 17:00:00:00'
	  and fh.Date between '2020-04-01' and '2020-09-01'

--------- CVID-19 forecast update -------------- 30% down except 3 areas        ------ 7/4/2020
;update f
set f.Value = f.value /0.7
from JDE_DB_Alan.FCPRO_Fcst f
where --f.ReportDate between '2020-04-01' and '2020-09-01 13:00:00'
       f.ItemNumber in ('42.210.031')
     --where f.ItemNumber in ('38.001.005') 
     --  and f.Date = '2020-04-01'
	  and f.Date between '2020-04-01' and '2020-09-01'
	  and f.DataType1 = 'Adj_FC'


;update f
set f.Value = f.value * 0.7
from JDE_DB_Alan.FCPRO_Fcst f
where 
       f.ItemNumber not in  ('25.020.0155','25.020.1858','25.021.0155','25.021.1858','25.022.0155','25.022.1858','25.023.0155','25.023.1858','25.024.0155','25.024.1858','25.025.0155','25.025.1858','25.026.0155','25.026.1858','25.027.0155','25.027.1858','25.028.0155','25.028.1858','25.029.000','25.030.0155','25.031.0155','25.030.1858','25.031.1858','25.032.000','25.033.000','25.034.000','25.035.000','25.036.000','25.037.030','25.038.0155','25.039.0155','25.038.1858','25.039.1858','25.040.0155','25.040.1858','25.041.0155','25.041.1858','25.013.0155 ','25.013.1858 ','24.7257.0952','32.379.200','32.455.155','24.7121.0155','24.7100.0199','32.340.000','24.7122.0155','24.7127.0155','24.7120.0155','24.7200.0001','24.7125.0155','24.7002.0001','24.7121.1858','24.7110.0155','24.7100.1858','32.455.855','24.7122.1858','24.7120.1858','24.7127.1858','24.7124.0155','24.7102.0199','24.7201.0000','24.7100.7052A','24.7125.1858','24.7121.0952A','24.5411.0000','24.5398.0000','24.5404.0000','24.7127.0952','24.7100.4459A','24.5358.0000','32.455.460','24.7102.1858','24.7334.0199','24.5403.0000','24.7128.0155','24.7121.4459A','24.7121.0952','24.7002.0001T','24.7127.4459','32.455.462','24.7219.0952','24.7120.0952A','24.7002.0000T','24.5399.0000','24.5426.0204','24.7122.0952A','24.7200.0001T','32.341.155','24.7110.1858','24.7201.0000T','24.7125.0952A','24.7121.4459','24.5353.0204','32.455.461','24.5427.0204','24.7120.4459A','24.7128.0155A','24.7122.4459A','24.7364.0199','24.7333.0199','24.7124.1858','24.7120.0952','24.7200.0000','24.7125.4459A','24.7219.0199','24.7002.0000','24.5414.0000','24.7122.0952','24.5415.0000','24.5397.0000','24.7202.0000','24.5425.0204','24.7120.4459','24.7122.4459','24.5416.0000','24.7128.1858A','24.7219.1858','24.7124.0952','24.7202.0001','24.5418.0000','24.7334.1858','24.5349.0204','24.7124.4459','24.7334.0952','24.7219.4459','24.5417.0000','24.5405.0000','24.7110.0952','24.7334.4459','32.341.855','24.7333.1858','24.7102.7052A','24.7114.0155','24.7110.0952A','24.7128.0952A','24.7333.0952','24.7128.1858','24.5396.0000','24.5426.1858','24.7114.1858','24.5353.1858','24.5427.1858','24.7110.4459','24.5427.4459','24.5424.0204','24.5426.4459','24.5349.1858','24.5413.0000','24.7364.1858','24.7363.0199','32.455.465','24.7110.4459A','24.7333.4459','24.7128.0952','24.7124.0952A','24.7200.0000T','24.7125.0952','24.5353.4459','24.7219.4464','24.5425.1858','24.7363.1858','24.5425.4459','32.341.176','24.7364.0952','24.7102.4459A','24.5354.1858','24.5427.0952','24.5354.0204','24.5426.0952','24.7114.0952A','24.7219.4460','24.5412.0000','24.5353.0952','24.7125.4459','24.7219.4462','24.7364.4459','24.5349.4459','24.7128.4459A','24.7124.4459A','24.5425.0952','24.7128.4459','24.5360.1858','24.5424.1858','24.7114.4459A','24.5349.0952','24.7307.1858','24.7201.0002','24.5424.4459','24.5354.0952','24.5424.0952','24.5354.4459','24.7219.4465','24.5361.1858','24.5360.0204','24.7363.0952','24.7300.7060','24.7196.7060A','24.7363.4459','24.7116.0155','24.7193.0199A','24.7195.0199A','24.7195.1858A','24.5362.0204','24.5110.7178','24.5362.1858','24.5361.0204','24.5363.1858','24.5363.0204','24.7102.7052','24.7192.7060A','82.691.901','82.696.901','82.696.903','82.691.909','82.691.903','82.696.930','82.696.910','82.696.909','82.696.921','82.696.926','82.691.906','82.691.910','82.696.933','82.696.906','82.696.904','82.691.926','82.696.932','82.691.933','82.696.922','82.696.928','82.691.930','82.696.927','82.696.931','82.691.904','82.696.913','82.691.932','82.696.924','82.696.920','82.696.912','82.696.902','82.696.911','82.691.911','82.691.928','82.696.923','82.691.931','82.696.918','82.696.907','82.696.919','82.696.915','22.748.091','82.691.907','82.696.905','82.691.902','82.696.914','82.691.927','82.691.919','82.696.929','82.691.912','82.691.905','82.696.908','82.696.941','82.691.929','82.696.925','82.691.908','82.696.934','22.749.091','43.525.101','43.525.102','43.525.103','43.525.105','43.525.107','43.525.403','43.525.404','43.525.405','43.530.101','43.530.102','43.530.103','43.530.105','43.530.107','43.530.403','43.530.404','43.530.405','40.199.850','40.196.850','40.197.850','40.191.000','40.174.131','40.129.131','40.280.120','40.152.131','40.129.433','40.169.173','40.129.378','40.368.173','40.129.804','40.173.850','40.345.131','40.367.173','40.153.131','40.260.131','40.041.131','40.042.131','40.129.430','40.132.131','40.024.131','40.153.378','40.263.131','40.176.850','40.262.131','40.200.850','40.132.378','40.041.378','40.132.430','40.189.002','40.129.805','40.198.850','40.153.433','40.042.433','40.270.131','40.170.173','40.260.378','40.132.433','40.041.433','40.163.131','40.162.131','40.153.804','40.025.131','40.042.804','40.187.850','40.260.804','40.129.280','40.026.131','40.132.804','40.153.430','40.467.850','40.023.000','40.129.228','40.042.228','40.153.228','40.042.378','40.381.000','40.041.804','40.260.430','40.034.000','40.271.850','40.041.430','40.042.430','40.260.433','40.041.228','40.264.131','40.175.002','40.153.805','40.346.131','40.132.280','40.340.173','40.260.805','40.042.805','40.131.131','40.041.805','40.171.173','40.188.850','40.158.131','40.132.805','40.172.850','40.046.850','40.041.280','40.371.173','40.132.228','40.260.228','40.379.000','40.131.378','40.042.280','40.026.378','40.415.173','40.035.120','40.030.131','40.048.131','40.047.856','40.380.002','40.029.131','40.377.000','40.031.131','40.001.850','40.051.048','40.032.131','40.033.131')
	  and f.Date between '2020-04-01' and '2020-09-01'
	  and f.DataType1 = 'Adj_FC'

select (5138 - 386) * 6   --> 28,512      there are total 5138 SKUs get forecasted in April 2020, 386 SKUs are in exception list ( RB 242 + Commodity line 40 + Blue Pacific 104 ( FG 964 ) ), only reduce FC 30% for 6 months    --- 4/4/2020


 --- update FC History as well ---
;update fh
set fh.Value = fh.value * 0.7
from JDE_DB_Alan.FCPRO_Fcst_History fh
where 
      fh.ReportDate between '2020-04-01' and '2020-04-09 17:00:00:00'
	  and fh.Date between '2020-04-01' and '2020-09-01'
      and fh.ItemNumber not in  ('25.020.0155','25.020.1858','25.021.0155','25.021.1858','25.022.0155','25.022.1858','25.023.0155','25.023.1858','25.024.0155','25.024.1858','25.025.0155','25.025.1858','25.026.0155','25.026.1858','25.027.0155','25.027.1858','25.028.0155','25.028.1858','25.029.000','25.030.0155','25.031.0155','25.030.1858','25.031.1858','25.032.000','25.033.000','25.034.000','25.035.000','25.036.000','25.037.030','25.038.0155','25.039.0155','25.038.1858','25.039.1858','25.040.0155','25.040.1858','25.041.0155','25.041.1858','25.013.0155 ','25.013.1858 ','24.7257.0952','32.379.200','32.455.155','24.7121.0155','24.7100.0199','32.340.000','24.7122.0155','24.7127.0155','24.7120.0155','24.7200.0001','24.7125.0155','24.7002.0001','24.7121.1858','24.7110.0155','24.7100.1858','32.455.855','24.7122.1858','24.7120.1858','24.7127.1858','24.7124.0155','24.7102.0199','24.7201.0000','24.7100.7052A','24.7125.1858','24.7121.0952A','24.5411.0000','24.5398.0000','24.5404.0000','24.7127.0952','24.7100.4459A','24.5358.0000','32.455.460','24.7102.1858','24.7334.0199','24.5403.0000','24.7128.0155','24.7121.4459A','24.7121.0952','24.7002.0001T','24.7127.4459','32.455.462','24.7219.0952','24.7120.0952A','24.7002.0000T','24.5399.0000','24.5426.0204','24.7122.0952A','24.7200.0001T','32.341.155','24.7110.1858','24.7201.0000T','24.7125.0952A','24.7121.4459','24.5353.0204','32.455.461','24.5427.0204','24.7120.4459A','24.7128.0155A','24.7122.4459A','24.7364.0199','24.7333.0199','24.7124.1858','24.7120.0952','24.7200.0000','24.7125.4459A','24.7219.0199','24.7002.0000','24.5414.0000','24.7122.0952','24.5415.0000','24.5397.0000','24.7202.0000','24.5425.0204','24.7120.4459','24.7122.4459','24.5416.0000','24.7128.1858A','24.7219.1858','24.7124.0952','24.7202.0001','24.5418.0000','24.7334.1858','24.5349.0204','24.7124.4459','24.7334.0952','24.7219.4459','24.5417.0000','24.5405.0000','24.7110.0952','24.7334.4459','32.341.855','24.7333.1858','24.7102.7052A','24.7114.0155','24.7110.0952A','24.7128.0952A','24.7333.0952','24.7128.1858','24.5396.0000','24.5426.1858','24.7114.1858','24.5353.1858','24.5427.1858','24.7110.4459','24.5427.4459','24.5424.0204','24.5426.4459','24.5349.1858','24.5413.0000','24.7364.1858','24.7363.0199','32.455.465','24.7110.4459A','24.7333.4459','24.7128.0952','24.7124.0952A','24.7200.0000T','24.7125.0952','24.5353.4459','24.7219.4464','24.5425.1858','24.7363.1858','24.5425.4459','32.341.176','24.7364.0952','24.7102.4459A','24.5354.1858','24.5427.0952','24.5354.0204','24.5426.0952','24.7114.0952A','24.7219.4460','24.5412.0000','24.5353.0952','24.7125.4459','24.7219.4462','24.7364.4459','24.5349.4459','24.7128.4459A','24.7124.4459A','24.5425.0952','24.7128.4459','24.5360.1858','24.5424.1858','24.7114.4459A','24.5349.0952','24.7307.1858','24.7201.0002','24.5424.4459','24.5354.0952','24.5424.0952','24.5354.4459','24.7219.4465','24.5361.1858','24.5360.0204','24.7363.0952','24.7300.7060','24.7196.7060A','24.7363.4459','24.7116.0155','24.7193.0199A','24.7195.0199A','24.7195.1858A','24.5362.0204','24.5110.7178','24.5362.1858','24.5361.0204','24.5363.1858','24.5363.0204','24.7102.7052','24.7192.7060A','82.691.901','82.696.901','82.696.903','82.691.909','82.691.903','82.696.930','82.696.910','82.696.909','82.696.921','82.696.926','82.691.906','82.691.910','82.696.933','82.696.906','82.696.904','82.691.926','82.696.932','82.691.933','82.696.922','82.696.928','82.691.930','82.696.927','82.696.931','82.691.904','82.696.913','82.691.932','82.696.924','82.696.920','82.696.912','82.696.902','82.696.911','82.691.911','82.691.928','82.696.923','82.691.931','82.696.918','82.696.907','82.696.919','82.696.915','22.748.091','82.691.907','82.696.905','82.691.902','82.696.914','82.691.927','82.691.919','82.696.929','82.691.912','82.691.905','82.696.908','82.696.941','82.691.929','82.696.925','82.691.908','82.696.934','22.749.091','43.525.101','43.525.102','43.525.103','43.525.105','43.525.107','43.525.403','43.525.404','43.525.405','43.530.101','43.530.102','43.530.103','43.530.105','43.530.107','43.530.403','43.530.404','43.530.405','40.199.850','40.196.850','40.197.850','40.191.000','40.174.131','40.129.131','40.280.120','40.152.131','40.129.433','40.169.173','40.129.378','40.368.173','40.129.804','40.173.850','40.345.131','40.367.173','40.153.131','40.260.131','40.041.131','40.042.131','40.129.430','40.132.131','40.024.131','40.153.378','40.263.131','40.176.850','40.262.131','40.200.850','40.132.378','40.041.378','40.132.430','40.189.002','40.129.805','40.198.850','40.153.433','40.042.433','40.270.131','40.170.173','40.260.378','40.132.433','40.041.433','40.163.131','40.162.131','40.153.804','40.025.131','40.042.804','40.187.850','40.260.804','40.129.280','40.026.131','40.132.804','40.153.430','40.467.850','40.023.000','40.129.228','40.042.228','40.153.228','40.042.378','40.381.000','40.041.804','40.260.430','40.034.000','40.271.850','40.041.430','40.042.430','40.260.433','40.041.228','40.264.131','40.175.002','40.153.805','40.346.131','40.132.280','40.340.173','40.260.805','40.042.805','40.131.131','40.041.805','40.171.173','40.188.850','40.158.131','40.132.805','40.172.850','40.046.850','40.041.280','40.371.173','40.132.228','40.260.228','40.379.000','40.131.378','40.042.280','40.026.378','40.415.173','40.035.120','40.030.131','40.048.131','40.047.856','40.380.002','40.029.131','40.377.000','40.031.131','40.001.850','40.051.048','40.032.131','40.033.131')
	   and fh.DataType1 = 'Adj_FC'


----------------------------------------------------------------------------------
--- update one month data --- fc table
;update f
set f.Value = 205
--select * 
from JDE_DB_Alan.FCPRO_Fcst f
--where h.ReportDate between '2018-03-01' and '2018-03-02 13:00:00'
 where f.ItemNumber in ('38.001.005') 
	  and f.Date in ('2020-02-01')
	  and f.DataType1 = 'Adj_FC'



--- update one month data --- fc history table
;update h
set h.Value = 20
--select * 
from JDE_DB_Alan.FCPRO_Fcst_History h
--where h.ReportDate between '2018-03-01' and '2018-03-02 13:00:00'
 where h.ReportDate between '2019-04-10' and '2019-04-30 17:00:00:00'
      and h.ItemNumber in ('34.081.000') 
	  and h.Date in ('2019-09-01')

--------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------
-- Add new table
CREATE TABLE TOY.BRANDS
(
ID INT NOT NULL,
NAME VARCHAR(20) NULL
)
GO

-- Load the table with data
INSERT INTO TOY.BRANDS (ID, NAME) VALUES
(1, 'Ford'),
(2, 'Chevy'),
(3, 'Dodge'),
(4, 'Plymouth'),
(5, 'Oldsmobile'),
(6, 'Lincoln'),
(7, 'Mercury');
GO

--- from one table --
CREATE TABLE suppliers
  AS (SELECT id, address, city, state, zip
      FROM companies
      WHERE id > 1000);

--- from 2 tables ---
CREATE TABLE suppliers
  AS (SELECT companies.id, companies.address, categories.cat_type
      FROM companies, categories
      WHERE companies.id = categories.id
      AND companies.id > 1000);


 --- This would create a new table called suppliers that included all columns from the companies table, but no data from the companies table --- retain table structure but no data is copied over
CREATE TABLE suppliers
  AS (SELECT *
      FROM companies WHERE 1=2);



--------- Create table and insert data multiple rows-----------

CREATE TABLE recipes (
  recipe_id INT NOT NULL,
  recipe_name VARCHAR(30) NOT NULL,
  PRIMARY KEY (recipe_id),
  UNIQUE (recipe_name)
);

INSERT INTO recipes (recipe_id, recipe_name) 
VALUES 
    (1,"Tacos"),
    (2,"Tomato Soup"),
    (3,"Grilled Cheese");

---------- create temp table # ( if need > 1000 records )-----------------

Local Temporary Tables (#temp)  
Global Temporary Tables (##temp)  
  
CREATE TABLE #StudentTemp  
(  
    StudentID int,  
    Name varchar(50),   
    Address varchar(150)  
)  
GO  
INSERT INTO #StudentTemp VALUES ( 1, 'Dipendra','Pune');  
GO  
SELECT * FROM #StudentTemp  

------------Create table variable @ -----------------------------------
DECLARE @table AS TABLE (id INT, col VARCHAR(20))

 DECLARE @TStudent TABLE  
 (  
    RollNo INT IDENTITY(1,1),  
    StudentID INT,  
    Name INT  
 )   
 --Insert data to Table variable @TStudent   
 INSERT INTO @TStudent(StudentID,Name)  
 SELECT DISTINCT StudentID, Name FROM StudentMaster ORDER BY StudentID ASC 

 ----------------- Update FC using temp table  25/2/2020 --------- works ! -------------------------

select * from JDE_DB_Alan.FCPRO_Fcst_History h  where h.ItemNumber in ('38.001.005') and h.ReportDate between '2020-02-01' and '2020-02-25' 
select * from JDE_DB_Alan.FCPRO_Fcst f where f.ItemNumber in ('38.001.005') and f.DataType1 = 'Adj_FC' 

declare @fc table ( item varchar(100),datatype varchar(100),fcdate datetime,fcqty decimal(18,0))


----- Creating temporary tables --> SQL Server provided two ways to create temporary tables via SELECT INTO and CREATE TABLE statements. --- https://www.sqlservertutorial.net/sql-server-basics/sql-server-temporary-tables/

--- Make sure that the table is deleted after use --- 25/2/2020

If(OBJECT_ID('tempdb..#temp') Is Not Null)
Begin
    Drop Table #Temp
End

If(OBJECT_ID('tempdb..#fc') Is Not Null)
Begin
    Drop Table #fc
End


drop table #fc
select * from #fc
select f.ItemNumber,f.DataType1,f.Date,f.Value  into #fc  from JDE_DB_Alan.FCPRO_Fcst f where 1=2 

insert into #fc values
('38.001.005','Adj_FC','2020/02/01',500 ), 
('38.001.005','Adj_FC','2020/03/01',811 ),
('38.001.005','Adj_FC','2020/04/01',1004),
('38.001.005','Adj_FC','2020/05/01',1123),
('38.001.005','Adj_FC','2020/06/01',1198),
('38.001.005','Adj_FC','2020/07/01',1244),
('38.001.005','Adj_FC','2020/08/01',1273),
('38.001.005','Adj_FC','2020/09/01',1291),
('38.001.005','Adj_FC','2020/10/01',1302),
('38.001.005','Adj_FC','2020/11/01',1308),
('38.001.005','Adj_FC','2020/12/01',1313),
('38.001.005','Adj_FC','2021/01/01',1315),
('38.001.005','Adj_FC','2021/02/01',500 ),
('38.001.005','Adj_FC','2021/03/01',811 ),
('38.001.005','Adj_FC','2021/04/01',1004),
('38.001.005','Adj_FC','2021/05/01',1123),
('38.001.005','Adj_FC','2021/06/01',1198),
('38.001.005','Adj_FC','2021/07/01',1244),
('38.001.005','Adj_FC','2021/08/01',1273),
('38.001.005','Adj_FC','2021/09/01',1291),
('38.001.005','Adj_FC','2021/10/01',1302),
('38.001.005','Adj_FC','2021/11/01',1308),
('38.001.005','Adj_FC','2021/12/01',1313),
('38.001.005','Adj_FC','2022/01/01',1315)

  --- update 'Adj_FC' --- fc table
;update f
 set f.value = f2.value
  from JDE_DB_Alan.FCPRO_Fcst f inner join #fc f2 on f.ItemNumber = f2.ItemNumber  and f.Date = f2.Date and f.DataType1 = f2.DataType1     ---N0 Need ? Need !                                                                                
     where f.ItemNumber = '38.001.005' and f.DataType1 ='Adj_FC'


  --- update 'Stat_FC' --- fc table
  	  
;update f
 set f.value = f2.value
  from JDE_DB_Alan.FCPRO_Fcst f inner join 
							 ( select * from JDE_DB_Alan.FCPRO_Fcst ff where ff.DataType1 = 'Adj_FC') f2 
							               on f.ItemNumber = f2.ItemNumber  and f.Date = f2.Date												 ---N0 Need ? Need !                                                                                
  where f.ItemNumber = '38.001.005' and f.DataType1 ='Stat_FC' and f.Date = '2020-04-01'


  --- update 'Adj_FC' --- fc history table -- works !
;update h
 set h.value = f2.value
  from JDE_DB_Alan.FCPRO_Fcst_History h inner join #fc f2 on h.ItemNumber = f2.ItemNumber  and h.Date = f2.Date and h.DataType1 = f2.DataType1     ---N0 Need ? Need !                                                                                
     where h.ItemNumber = '38.001.005' and h.DataType1 ='Adj_FC' and h.ReportDate between '2020-02-01' and '2020-02-25' 


----------------------------------------------------------------------------------
--- update one month data --- fc table
;update f
set f.Value = 205
--select * 
from JDE_DB_Alan.FCPRO_Fcst f
--where h.ReportDate between '2018-03-01' and '2018-03-02 13:00:00'
 where f.ItemNumber in ('38.001.005') 
	  and f.Date in ('2020-02-01')
	  and f.DataType1 = 'Adj_FC'


	  
--- update one month data --- fc history table
;update h
set h.Value = 20
--select * 
from JDE_DB_Alan.FCPRO_Fcst_History h
--where h.ReportDate between '2018-03-01' and '2018-03-02 13:00:00'
 where h.ReportDate between '2019-04-10' and '2019-04-30 17:00:00:00'
      and h.ItemNumber in ('34.081.000') 
	  and h.Date in ('2019-09-01')

------------------------------------------------------------------------------------------------------------



---================= Update Records in FC history table ================================================================================================================
	 
select * from JDE_DB_Alan.Px_AWF_HD_MT_FCPro_upload px where px.ItemNumber in ('24.023.165')	
-------------------------------- test To Update FC History 25/5/2018 -------------------------------------------
select convert(varchar(10),dateadd(d,-1,DATEADD(mm, DATEDIFF(m,0,GETDATE())-2,0)),120)        --- 2018-02-28
select convert(varchar(10),dateadd(d,-1,DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0)),120)        --- 2018-03-31
select convert(varchar(10),dateadd(d,-1,DATEADD(mm, DATEDIFF(m,0,GETDATE()),0)),120)        --- 2018-04-31
select convert(varchar(10), DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),120)							--2018-04-01
select * from JDE_DB_Alan.FCPRO_Fcst_History 
select distinct fh.DataType1 from JDE_DB_Alan.FCPRO_Fcst_History fh where convert(varchar(10),fh.ReportDate,120) = convert(varchar(10),dateadd(d,-1,DATEADD(mm, DATEDIFF(m,0,GETDATE()),0)),120)


--- change ( add more records ) to FC history table ---
insert into JDE_DB_Alan.FCPRO_Fcst_History 
select fh.ItemNumber,fh.DataType1,fh.Date,isnull(fh.value,0) as Value,'2018-03-31 15:00:00.000' as ReportDate
      -- ,fh.ReportDate as OriginalRP
	from JDE_DB_Alan.FCPRO_Fcst_History fh				-- 24/5/2018 did not have  condition before --> where fct.DataType1 like ('%Adj_FC%')	
		where fh.DataType1 like ('%Adj_FC%')				-- 24/5/2018
				and convert(varchar(10),fh.ReportDate,120) = convert(varchar(10),dateadd(d,-1,DATEADD(mm, DATEDIFF(m,0,GETDATE())-2,0)),120)		---Get data which is saved last last month - because every month you save FC exclude current month, say if you are in May, to get May forecast you need to go back to Reportdata of Apri but since your SQL Code's time function is quite unique ( look your code ) you do not use m-1 ! try run the code and see youself -- do not be fooled by parameters until you run the code and see it - 25/5/2018
				and fh.Date = convert(varchar(10), DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),120)					--- Get last month FC and used it compared with History, in future need to use leadtime offset FC.  Say this month is June ( you are in June ) then, go back to fetch FC save in last day of May which is 31/5 ( which will have FC in May,in June, in July, in Aug etc), then you pick up May forecast and compared with History, in future you need to pick up May forecast saved 3 month earliery ( in Mar - depends on leadtime ) which is leadtime offset and compared with May Sales to get forecast accuracy. Also remember it is important to save forecast at last day of each month because 1) SQL code is based this date 2) it will save fc in the month you are in otherwise if you do it in June you will last May forecast ( the logic is in SQL code )
				and fh.ItemNumber in ('42.210.031')


--- validate after change the records ( afer insert additional records into table )
select * from JDE_DB_Alan.FCPRO_Fcst_History fh
where fh.DataType1 like ('%Adj_FC%')
      and convert(varchar(10),fh.ReportDate,120) = convert(varchar(10),dateadd(d,-1,DATEADD(mm, DATEDIFF(m,0,GETDATE()),0)),120)
	  --and fh.Date = convert(varchar(10), DATEADD(mm, DATEDIFF(m,0,GETDATE()),0),120)
	  --and fh.ItemNumber in ('42.210.031')
	  --  and fh.ItemNumber in ('03.986.000')
order by fh.ItemNumber,fh.Date

--- delete test records --- be very careful when deleting data !
delete from JDE_DB_Alan.FCPRO_Fcst_History
where DataType1 like ('%Adj_FC%')
      and convert(varchar(10),ReportDate,120) = convert(varchar(10),dateadd(d,-1,DATEADD(mm, DATEDIFF(m,0,GETDATE()),0)),120)
	  and Date = convert(varchar(10), DATEADD(mm, DATEDIFF(m,0,GETDATE()),0),120)
	  and ItemNumber in ('42.210.031')


------------------------------
select * from JDE_DB_Alan.FCPRO_Fcst_History fh
where fh.DataType1 like ('%Adj_FC%')
      and convert(varchar(10),fh.ReportDate,120) = convert(varchar(10),dateadd(d,-1,DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0)),120)
	  --and fh.Date = convert(varchar(10), DATEADD(mm, DATEDIFF(m,0,GETDATE()),0),120)
	  and fh.ItemNumber in ('42.210.031')
order by fh.ItemNumber,fh.Date
------=======================End of Update Records in FC history table =========================================================================================================


  ------------------------------------------------------------------------------------------------------------------------
-- does not work as Data Type is a issue...
  select sls.ItemNumber,concat(sls.cy,sls.Month) as CYM,sls.SalesQty,'Sales' as Typ from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload sls where sls.ItemNumber like ('%085552500D212%')
  union all
  select fc.ItemNumber,fc.Date,fc.Value,'FC' as Typ from JDE_DB_Alan.FCPRO_Fcst fc where fc.ItemNumber like ('%085552500D212%')
																						and f.DataType1 in ('Adj_FC')			--26/2/2018 ??


  select fc.ItemNumber,fc.Date,fc.Value,sls.SalesQty
  from JDE_DB_Alan.FCPRO_Fcst fc left join JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload sls   on fc.ItemNumber = sls.ItemNumber 
  where fc.ItemNumber like ('%085552500D212%')

  and f.DataType1 in ('Adj_FC')			--26/2/2018 ??

------ works by converting datatime to String then back to Int to Match datatype in Sls table ---- 8/12/2017
 declare @item varchar(100) = '085552500D212'

 declare @item varchar(1000) = ('085552500D212','40.033.131')		-- does not work

 declare @values table 
(
    Value varchar(1000)
)

insert into @values values ('A')
insert into @values values ('B')
insert into @values values ('C')


declare @values table (  Value varchar(1000) )
insert into @values values ('A'),('B'),('C')

------------------------------------------------------ 11/12/2017 ---------------
Value (without century)	Value (with century)	Explanation
	100	mon dd yyyy hh:miAM/PM (Default)
	101	mm/dd/yyyy (US standard)
	102	yy.mm.dd (ANSI standard)
	103	dd/mm/yy (British/French standard)
	104	dd.mm.yy (German standard)
	105	dd-mm-yy (Italian standard)
	106	dd mon yy
	107	Mon dd, yy
	108	hh:mi:ss
	109	mon dd yyyy hh:mi:ss:mmmAM/PM
	110	mm-dd-yy (USA standard)
	111	yy/mm/dd (Japan standard)
	112	yyyymmdd (ISO standard)
	113	dd mon yyyy hh:mi:ss:mmm (Europe standard - 24 hour clock)
	114	hh:mi:ss:mmm (24 hour clock)
	120	yyyy-mm-dd hh:mi:ss (ODBC canonical - 24 hour clock)
	121	yyyy-mm-dd hh:mi:ss:mmm (ODBC canonical - 24 hour clock)
 	126	yyyy-mm-ddThh:mi:ss:mmm (ISO8601 standard)
 	127	yyyy-mm-ddThh:mi:ss:mmmZ (ISO8601 standard)
 	130	dd mon yyyy hh:mi:ss:mmmAM/PM (Hijri standard)
 	131	dd/mm/yy hh:mi:ss:mmmAM/PM (Hijri standard)

SELECT convert(varchar, getdate(), 109)
select CONVERT(datetime, convert(varchar(10), 20120103));

SELECT convert(date,CONVERT(varchar(10),columname,101))
SELECT convert(date,CONVERT(varchar(10),getdate(),101))
SELECT CONVERT(date, CONVERT(varchar(6), your_column) + '01') myDate
SELECT CONVERT(date, CONVERT(varchar(6),201610) + '01')								--- good working -> from Int to Date
SELECT CONVERT(datetime, CONVERT(varchar(6),201610) + '01',120)						--- good working --> yiedl 2016-10-01 00:00:00 000

select cast(CONVERT(VARCHAR(6),fc.Date, 112) as int) from JDE_DB_Alan.FCPRO_Fcst fc		--- good working -> from Date to Int
Select Convert(DATETIME, LEFT(20130101, 8))					--- More on Int to Date 
SELECT SUBSTRING(CONVERT(VARCHAR, DOB),5,2) AS mob			-- More on Int to Date, if data is in decimal datatype - [DOB] [decimal](8, 0) NOT NULL - eg - 19700109.	
SELECT strftime("%Y-%d-%m", col_name, 'unixepoch') AS col_name	-- More on Int to Date : if you db is Sqlite


---- Convert format Date in SQL server --- 16/12/2017

http://www.sql-server-helper.com/tips/date-formats.aspx
https://docs.microsoft.com/en-us/sql/t-sql/functions/cast-and-convert-transact-sql
https://www.w3schools.com/sql/func_sqlserver_convert.asp


select getdate()

select convert(varchar(7),getdate(),120) as myDate1							-- yield 2018-09 -- this month												
select cast(SUBSTRING(REPLACE(CONVERT(char(10),getdate(),126),'-',''),1,6) as integer) as [myDate2]		-- yield 201809 -- this month in Integer
select cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-',''),1,6) as integer) as [myDate2]		-- yield 201808 --- last month in Integer
select cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-37,0),126),'-',''),1,6) as integer) as dt			-- yield 201508 ---  36 month ago
select cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())+6,0),126),'-',''),1,6) as integer) as dt			-- next 6 month

select convert(varchar(10),getdate(),112) -- yield 20171216 - ISO
select convert(varchar(6),getdate(),112)  -- yield 201712 - ISO

select convert(int,convert(varchar(6),getdate(),112))+11 -- yield 201712 - ISO

select convert(varchar(10),getdate(),110) -- yield 12-16-2017 - US
select convert(varchar(10),getdate(),101) -- yield 12/16/2017 - US

select convert(varchar(10),getdate(),105) -- yield 16-12-2017 - Italian
select convert(varchar(10),getdate(),103) -- yield 16/12/2017 - British / French
select convert(varchar(10),getdate(),3) -- yield 16/12/2017

select convert(varchar(10),getdate(),111) -- yield 2017/12/16 - Japan

select convert(varchar(10),getdate(),120)  --- yield 2017-02-05  ODBC -- yyyy-mm-dd hh:mi:ss	/ ODBC canonical (24 hour clock)

-- Get Month Name --
select datename (month, DATEADD(mm, DATEDIFF(m,0,GETDATE()),0))						-- Will yield 'Febuary'
select cast(datename (month, DATEADD(mm, DATEDIFF(m,0,GETDATE())-13,0))  as char(3))	-- will yield 'Jan'
select left ( datename (month, DATEADD(mm, DATEDIFF(m,0,GETDATE())-13,0)) ,3)			-- will yield 'Jan'	
   select FORMAT(GETDATE(),'MMM') AS [Short Month Name]					-- SQL2012		-- will yield 'Feb'
   select  FORMAT(GETDATE(),'ddd') AS [Short Weekday Name]				--sql2012		-- will yield 'Thu'

-- Get last 12 Month ---
select replace(convert(varchar(8), DATEADD(mm, DATEDIFF(m,0,GETDATE())-13,0),126),'-','')		--last 12 months
select DATEDIFF(m,0,GETDATE())

select  DATEDIFF(m,0,GETDATE()) as startdate	
select DATEADD(mm, DATEDIFF(m,0,GETDATE()),0) as startdate	


select convert(varchar(10), '2011-02-25 21:17:33.933', 120)
select convert(varchar(10), getdate(), 120)
select dateadd(d, datediff(d,0, getdate()), 0)					-- today without time '2020-06-12 00:00:00.000'


select  dateadd(s,-1, dateadd(d, datediff(d,0, getdate()), 0))		-- last second of yesterday or max of yesterday

select dateadd(d, datediff(s,-1, getdate()), 0)	

somedate <= select datediff(d, 0, getdate())


select cast(DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,GETDATE())+6,0)) as datetime) as startdate		-- Set the StartDate for changing FC from Jun/2018 onwards ( + 6 months ),pay attention to 's' --> seconds, that is clever
select DATEADD(mm, DATEDIFF(m,0,GETDATE()),0) as startdate									--	this  month			2018-02-01 00:00:00.000
select DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0) as startdate									-- last  month		2018-01-01 00:00:00.000
select DATEADD(mm, DATEDIFF(m,0,GETDATE())-18,0) as startdate									-- last 18 month		2018-01-01 00:00:00.000
select DATEADD(mm, DATEDIFF(m,0,GETDATE())+11,0) as startdate									-- next 12  month		2018-01-01 00:00:00.000
select DATEADD(mm, DATEDIFF(m,0,GETDATE())-37,0) as startdate									-- last 36  month		2018-01-01 00:00:00.000



select dateadd(d,-1,DATEADD(mm, DATEDIFF(m,0,GETDATE()),0))									-- last day of preceding month
select convert(varchar(10),dateadd(d,-1,DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0)),120)     -- last day of preceding month - only 10 Character includes YYYY-MM-DD

select DATEADD(mm, DATEDIFF(m,0,GETDATE()),0)
select dateadd(d,0,DATEADD(mm, DATEDIFF(m,0,GETDATE()),0))
select dateadd(d,-1,DATEADD(mm, DATEDIFF(m,0,GETDATE())-2,0))				  --- yied 2018-02-28 00:00:00.000  -- this is start of day of 28/2/2018 in dawn very early in the morning, you just past last moment of previous day which is 27/2/2018 ( after mid mnight )
select dateadd(ss,1,dateadd(d,-1,DATEADD(mm, DATEDIFF(m,0,GETDATE())-2,0)))	  --- yied 2018-02-28 00:00:01.000   -- your foot is first step in the morning of 28/2/2018 , you just start new day in last day of Feb ! to be eactly you are entering in 1st seconds of 28/2/2018 in the morning !
select dateadd(ss,-1,dateadd(d,-1,DATEADD(mm, DATEDIFF(m,0,GETDATE())-2,0)))  --- yields 2018-02-27 23:59:59.000  -- this is last month of previous day -> 27/2/2018


select GETDATE()					-- yield 2018-02-28 10:41:06.147

-- Get Data in Different Fomat for JDE ---
declare @Period_YM varchar(6)
set @Period_YM = '201801'
select convert(date,dateadd(d,-1,dateadd(mm,1,convert(datetime,@Period_YM+'01',103))),103) as Period_YMD_1			-- to get 'Jde FC Date' Format ie 31/Month/Year
select convert(date,dateadd(d,-1,dateadd(mm,0,convert(datetime,@Period_YM+'01',103))),103) as Period_YMD_2			 -- to get 'Jde FC Date' Format ie 31/Month/Year,however when FC loaded into Jde, Jde will automatically add 1 day and push FC to Following month, ie 31/1/2018 FC will be push into Month slot of 1/Feb/2018, so here you need to change date again
select convert(varchar(10),convert(date,dateadd(d,-1,dateadd(mm,0,convert(datetime,@Period_YM+'01',105))),103),103) Period_YMD_3

select dateadd(d,-1,DATEADD(mm, DATEDIFF(m,0,GETDATE()),0))

declare @Period_YM varchar(7)
set @Period_YM = '2018-07'
select convert(datetime,@Period_YM+'-01',111) as Period_YMD_1	
select convert(date,dateadd(d,-1,dateadd(mm,1,convert(datetime,@Period_YM+'-01',111))),111) as Period_YMD_1		



------------------------------------------------------------------------------------------------------
select * from JDE_DB_Alan.MasterPrice p where p.ItemNumber in ('18.616.017')
select * from JDE_DB_Alan.Master_ML345 a where a.ItemNumber in ('18.616.017','18.613.031')
select * from JDE_DB_Alan.Master_ML345 a where a.ItemNumber in ('24.057.165S','28.164.000B')
select * from JDE_DB_Alan.SalesHistoryHDAWF a where a.ItemNumber in ('28.164.000B')
select distinct a.FinancialMonth from JDE_DB_Alan.SalesHistoryHDAWF a order by a.FinancialMonth desc

SELECT p.ItemNumber, COUNT(*) as countof
FROM JDE_DB_Alan.MasterPrice p
GROUP BY p.ItemNumber
HAVING COUNT(*) > 1


--- 06/10/2017 ---

SELECT 
      distinct [FinancialYear]
      ,[FinancialMonth]
   
  FROM [JDE_DB_Alan].[JDE_DB_Alan].[SalesHistoryHDAWF] a
  order by a.FinancialYear,a.FinancialMonth
  

  --- 14/10/17 --- find duplicate records in ML345 file
  SELECT [BU]
      ,[ItemNumber]
      ,[Description]
      ,[ShortItemNumber]
      ,[SellingGroup]
      ,[FamilyGroup]
      ,[Family]
  FROM [JDE_DB_Alan].[JDE_DB_Alan].[Master_ML345] a
  where a.ItemNumber in ('24.023.165S','8.20E+12','8.51E+11')


 select a.ItemNumber,count(a.ShortItemNumber) 
 from JDE_DB_Alan.Master_ML345 a
 group by a.ItemNumber
 order by count(a.ShortItemNumber) desc


 select * from JDE_DB_Alan.MasterPrice a where a.ItemNumber like ('%32000')
 select * from JDE_DB_Alan.SalesHistoryHDAWF a where a.ItemNumber in ('18.615.024') and a.Century in ('20') and a.FinancialYear in ('15') and a.FinancialMonth in ('09')


 ----- General Query for Sales History Transaction table -------
 with cte as (
			select a.*
 				,case  
					when a.FinancialMonth  >= 10  then concat(a.Century,a.FinancialYear,format(a.FinancialMonth,'0')) 		
					when a.FinancialMonth  <10  then concat(a.Century,a.FinancialYear,format(a.FinancialMonth,'00')) 
					end as CYM

			from  JDE_DB_Alan.SalesHistoryHDAWF a   )
select * from cte
where cte.ItemNumber in ('18.615.024') and cte.CYM in ('201508')

exec JDE_DB_Alan.sp_GetMyHDHist @ItemNumber= '18.615.024',@CenturyYearMonth= '201708'
exec JDE_DB_Alan.sp_GetMyHDHist @ShortItemNum= '1074571',@CenturyYearMonth= '201508'
-------------------------------------------------------------------------------------------------------------

 --- Get duplicate row for Sales History Transaction table  ---
  select  a.ItemNumber,a.Century,a.FinancialYear,a.FinancialMonth,count(a.bu) cnt
 from JDE_DB_Alan.SalesHistoryHDAWF a
 where a.ItemNumber in ('8.51E+11')
 group by a.ItemNumber,a.Century,a.FinancialYear,a.FinancialMonth
 order by a.ItemNumber,a.Century,a.FinancialYear,a.FinancialMonth


  --- Consolidate for Sales History Transaction table  ---
  select a.bu,a.ItemNumber,a.Century,a.FinancialYear,a.FinancialMonth,count(a.bu) cnt
 from JDE_DB_Alan.SalesHistoryHDAWF a
 where a.ItemNumber in ('8.51E+11')
 group by a.ItemNumber,a.Century,a.FinancialYear,a.FinancialMonth
 order by a.ItemNumber,a.Century,a.FinancialYear,a.FinancialMonth



 --- olap function for Price Table---
 with cte as (
 select *, row_number() over(partition by a.itemnumber order by itemnumber ) rownumber   
 from JDE_DB_Alan.MasterPrice a 
 --where a.ItemNumber in ('24.023.165S','7.51E+11')
  )
 select cte.RawLabel,cte.SellingGroup,cte.FamilyGroup,cte.Family,ltrim(rtrim(cte.Itemnumber)),cte.StandardCost,cte.WholeSalePrice
   from cte 
  where rownumber =1

  ----- Unique item in R45ML345 ---
select * from JDE_DB_Alan.Master_ML345 t 
where t.ItemNumber like ('%7840001000')

 with cte as (
--select t.ItemNumber,t.Description,row_number() over(partition by t.itemnumber order by itemnumber ) rn  
select *,row_number() over(partition by t.itemnumber order by itemnumber ) rn 
 from JDE_DB_Alan.Master_ML345 t 
 where t.itemnumber in ('24.023.165S')
 )

 select * from cte 
  where rn = 1 and cte.itemnumber in ('24.023.165S')
 order by rn desc
 

 ------ To get one string for Year + Month ----- 17/10/2017
 select  *
      ,case  
		     when a.FinancialMonth  >= 10  then format(a.FinancialMonth,'0') 
			 --else right('000'+cast(a.financialMonth as varchar(2)),3)  
			 when a.FinancialMonth  <10  then format(a.FinancialMonth,'00') 
		end as MM
 from	JDE_DB_Alan.SalesHistoryHDAWF a 
 where a.ItemNumber in ('18.009.001') and a.FinancialYear in ('17') and a.FinancialMonth in ('9')

 select format(a.FinancialMonth,'00') from  JDE_DB_Alan.SalesHistoryHDAWF a 
  where a.ItemNumber in ('18.009.001')
  

  ---------- Check instance version --------------------------------------

  DECLARE @GetInstances TABLE
( Value nvarchar(100),
 InstanceNames nvarchar(100),
 Data nvarchar(100))

Insert into @GetInstances
EXECUTE xp_regread
  @rootkey = 'HKEY_LOCAL_MACHINE',
  @key = 'SOFTWARE\Microsoft\Microsoft SQL Server',
  @value_name = 'InstalledInstances'

Select InstanceNames from @GetInstances 


-------------- Join table with Null and Compress process into One step 26/10/2017 -------------------------------------------
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
		  from JDE_DB_Alan.SalesHistoryMT a left join JDE_DB_Alan.Master_ML345 x
			   on a.ShortItemNumber = x.ShortItemNumber 
		  ),
m as ( 
        select t.*,l.myItemNumber
		       ,case when l.myItemNumber is null then t.ItemNumber
			       else t.ItemNumber 
		        end as fItemNumber
		from t left join l on t.ShortItemNumber = l.ShortItemNo 
		where  t.ShortItemNumber in ('1218124','159804') 
				and concat(t.Century,t.FinancialYear,t.FinancialMonth) = '201512'
		)

--select * from m where m.myItemNumber is null
select * from m 

------------------ Original code Not Compressing so it is two steps but Need to write more COde ---------------------------------------------------------
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
		  from JDE_DB_Alan.SalesHistoryMT a left join JDE_DB_Alan.Master_ML345 x
			   on a.ShortItemNumber = x.ShortItemNumber 
		  ),
m as ( 
        select t.*,l.myItemNumber from t left join l on t.ShortItemNumber = l.ShortItemNo 
		)

--select * from m where m.myItemNumber is null
select * from m 
where m.ShortItemNumber in ('1218124','159804') 
      and concat(m.Century,m.FinancialYear,m.FinancialMonth) = '201512'
order by m.Century,m.FinancialYear,m.FinancialMonth



------ cast and convert ------
SELECT 9.5 AS Original, CAST(9.5 AS int) AS int, 
    CAST(9.5 AS decimal(6,4)) AS decimal;

SELECT 9.5 AS Original, CONVERT(int, 9.5) AS int, 
    CONVERT(decimal(6,4), 9.5) AS decimal;

----- find columns with only numbers ------------

select * from JDE_DB_Alan.MasterFamily a where a.code not like ('%[^0-9]%')

----- find columns with only letters ------------
select * from JDE_DB_Alan.MasterFamily a where a.code not like ('%[^a-z]%')


select * from JDE_DB_Alan.MasterFamily a where a.code not like ('%[^0-9]%')  --- wrong need to put carat inside box
select * from JDE_DB_Alan.MasterFamily a where a.code not like ('%[^0-9]%')  --- show all items only with numbers
select * from JDE_DB_Alan.MasterFamily a where substring(a.Code,1,1) not like ('%[^0-9]%')  --- show all items starts with numbers 
select * from JDE_DB_Alan.MasterFamily a where a.code not like ('%[^a-z]%')  --- show all items only with letters


------ Create View ------- 2/2/2018
CREATE VIEW [Products Above Average Price] AS
SELECT ProductName, UnitPrice
FROM Products
WHERE UnitPrice > (SELECT AVG(UnitPrice) FROM Products);
WHERE Discontinued = No;


DROP VIEW view_name;
drop view [JDE_DB_Alan].[vw_NP_FC_Analysis]
drop view [JDE_DB_Alan].[vw_NP_FC_Override_upload]


-------------------------------------  View  9/3/2018 12/3/2018----------------------------------------------------------------------
--select * from JDE_DB_Alan.FCPRO_NP_tmp np where np.ItemNumber in ('34.519.000') order by np.ItemNumber
--select DATEADD(mm, DATEDIFF(m,0,GETDATE())+1,0)

--delete from JDE_DB_Alan.FCPRO_NP_tmp
--create view as derived table from 'FCPRO_NP_tmp'
drop view [JDE_DB_Alan].[vw_NP_FC_Analysis]

create view [JDE_DB_Alan].[vw_NP_FC_Analysis] with schemabinding
as

  --- Syntax '*' is not allowed in schema-bound objects ! ---   So in your final Select you need to pick up All columns --- 12/3/2018
  --- it is OK to list all columns , so when you want to use View table you can select whatever columns you want ---
  --- Need to design a SP to automatically refresh the View every month or any time  your loaded your NP table --- 12/3/2018
 
 with _np as 
			( select npfc.ItemNumber,npfc.date,npfc.Value,npfc.DataType,npfc.CN_Number,npfc.Comment,npfc.Creator,npfc.LastUpdated,npfc.ReportDate 
				from JDE_DB_Alan.FCPRO_NP_tmp npfc
				where npfc.Value > 0)

	,np_ as ( select _np.ItemNumber,_np.Date,_np.Value,_np.DataType,_np.CN_Number,_np.Comment,_np.Creator,_np.LastUpdated,_np.ReportDate
					,min(_np.Date) over(partition by _np.ItemNumber) as FcStartDate
					,max(_np.Date) over(partition by _np.ItemNumber) as FcEndDate					
					,DATEADD(mm, DATEDIFF(m,0,GETDATE()),0) as CurrentMth_
					,sum(_np.value) over (partition by _np.ItemNumber) as FcTTL_12_Qty			--- note this is true 12 FC Qty regardless of when is your current month, FC in 'FCPRO_Fcst' will cut off whatever the month passed by --- 12/3/2018
					,avg(_np.value) over (partition by _np.ItemNumber) as FcTTL_12_Qty_MthlyAvg		--- note when calculating Averge, if there is 0 quantities it will skip and count less to be divided, so maybe it is safe to hard coded to be divided by 12 - just a thought? -- 12/3/2018
					,count(_np.date) over (partition by _np.ItemNumber) as FcMthCount
					,datediff(m,min(_np.Date) over(partition by _np.ItemNumber),DATEADD(mm, DATEDIFF(m,0,GETDATE()),0) ) as Mth_Elapsed
			from _np					 				 
			where 
					--_np.ItemNumber in ('34.513.000 ')	and	 
                     _np.Value >0
			)
                 
		--select * from np_	   
        select np_.ItemNumber,np_.Date,np_.Value,np_.DataType,np_.CN_Number,np_.Comment,np_.Creator,np_.LastUpdated,np_.ReportDate 
					 ,np_.FcStartDate,np_.FcEndDate,np_.CurrentMth_,np_.FcTTL_12_Qty,np_.FcTTL_12_Qty_MthlyAvg,np_.FcMthCount,np_.Mth_Elapsed
				from np_
				--where np_.Mth_Elapsed > 7

--where tbl.ItemNumber in ('2801381324')
--order by tbl.ItemNumber,tbl.Date


exec JDE_DB_Alan.sp_Refresh_View_NP_Analysis

 -------------- Execute View --------------------
 select * from dbo.vw_NP_FC_Analysis

 ------ Check all the View, and Excute all of them one by one making sure all View are updated ------
 select quotename(table_schema) +'.' + quotename(table_name) as ViewNAme,
 identity(int,1,1) as ID
  into #test
  from information_schema.tables
 where table_type = 'view'

 --select * from #test
 declare @Loopid int,@MaxID int


select @LoopID =1,@MaxID =MAX(id) 
from #test

declare @ViewName varchar(100)

while @LoopID <= @MaxID
begin

select @ViewName = ViewNAme 
from #test
where id = @LoopID

exec ('select top 1 * from ' + @ViewName)
set @LoopID = @LoopID + 1
end

drop table #test

  --------------------------------- End of Some Code Snippet ------------------------------------------------------------------------------------------------
  ---=========================================================================================================================================================================================





---=============================== Demand Planning Aanlysis Code =========================================================================================================================


  --===========================================================================================================
  --------- Pareto/Portfolio Analysis: on Monthly level -- Link with stock, sales history 1/12/2017,revise 25/1/2018 -- Works!!!  Use this One ---------------------
  --===========================================================================================================
  select * from JDE_DB_Alan.FCPRO_Fcst
  select p.ItemNumber,p.rnk,p.DataType1,p.Pareto from JDE_DB_Alan.FCPRO_Fcst_Pareto p where p.DataType1 like ('%pri%')
  select * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload
  declare @fcdatatype varchar(100) = '%point%'
  select replace(convert(varchar(8), DATEADD(mm, DATEDIFF(m,0,GETDATE())-12,0),126),'-','')

  	declare @Supplier_id varchar(4000)
	declare @Item_id varchar(4000)
	-- ,@DataType varchar (100) = null
	--,@ItemNumber varchar(100) = null
	--,@ShortItemNumber varchar(100) = null
	--,@CenturyYearMonth int = null
	declare @OrderByClause varchar(100)	
    declare @Start datetime
	declare @End datetime 

	--set @Supplier_id = '20037'
	--set @Item_id = '2974000000,7495500001'
	set @OrderByClause ='rnk'
	--set @OrderByClause ='SlsAmt_12'
	--set @OrderByClause ='SOHAmt'
	set @Start ='2018-08-01'
	set @End = '2019-03-01'

   ;with CalendarFrame as (
					--select -24 as t,1 as n,cast(DATEADD(mm, DATEDIFF(mm, 0, GETDATE())-24, 0) as datetime) as start
						select 1 as t,1 as n,cast(DATEADD(mm, DATEDIFF(mm, 0, GETDATE())-24, 0) as datetime) as start
					union all
					select case when t +1 >24 then 1 else t+1 end ,case when n=12 then 1 else n+1 end,dateadd(mm, 1, start)
					-- select t+1 ,case when n=12 then 1 else n+1 end,dateadd(mm, 1, start)
					from CalendarFrame
				)
				--select top 50 * from CalendarFrame
			,MonthlyCalendar as
					(
					select top 48 t, RIGHT('00'+CAST(n AS VARCHAR(3)),2) nmb,cast(SUBSTRING(REPLACE(CONVERT(char(10),start,126),'-',''),1,6) as integer) as [StartDate],
					DATENAME(mm,start) MnthName,DATENAME(yyyy,start) YearName from CalendarFrame
				)
			 --select * from MonthlyCalendar
			--cldr as
			--		(select mc.t
			--			,left(mc.eom,6)  as eom_
			--		from MonthlyCalendar mc 
			--		--where left(mc.eom,4)=2015
			--		where mc.eom> replace(convert(varchar(8), DATEADD(mm, DATEDIFF(m,0,GETDATE())-13,0),126),'-','')		--last 12 months
			--	),

			 --hist_ as ( select *,					
				--					case 
				--						when h.Month >= 10 then format(h.Month,'0') 
				--						--else right('000'+cast(a.financialMonth as varchar(2)),3) 
				--						when h.Month <10 then format(h.Month,'00') 
				--					end as MM
				--			from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h
				--			),
				--hist as ( select *,concat(hist_.CY,hist_.MM) as CYM_
				--				from hist_
				--			), 
				--histy as (select x.ItemNumber,count(x.CYM_) Sls_freq,sum(isnull(x.SalesQty,0)) SlsVol_TTL_12
				--			from hist x 
				--			--where x.ItemNumber in ('26.353.000') and x.CYM >201612
				--			where x.cym_ >replace(convert(varchar(8), DATEADD(mm, DATEDIFF(m,0,GETDATE())-13,0),126),'-','')				-- last 12 months
				--			group by x.ItemNumber )	,				--- sales about 9139 records
      

			,itm as ( select distinct h.ItemNumber as ItemNumber_ from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h )
			,list as ( select * from itm cross join MonthlyCalendar cldr 
						where StartDate between replace(convert(varchar(8), DATEADD(mm, DATEDIFF(m,0,GETDATE())-12,0),126),'-','' )			-- last 12 months		
												 and  replace(convert(varchar(8), DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-','' )		-- last 12 months
					  )		     
			-- Padded Item with all Months ---
			,hist as 
			(  select list.ItemNumber_ ,case when h.SalesQty is null then 0 else h.SalesQty end as SalesQty_
					,list.StartDate as CYM,list.t
				from list left join JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h on list.StartDate = h.CYM and list.ItemNumber_ = h.ItemNumber
			--where list.ItemNumber in ('18.615.024') 		
			)
			,histy as 
				( select x.ItemNumber_
				,count(isnull(x.CYM,0)) TTL_SlsMths
				,sum( case when salesqty_ >0 then 1 else 0 end ) as Sls_freq
				,sum(x.SalesQty_) SlsVol_TTL_12 
				from hist x 
				group by x.ItemNumber_)
			--select * from histy where histy.ItemNumber_ in ('03.986.000')

			,stk as (
					select a.ItemNumber,sum(coalesce(a.QtyOnHand,0)) SOHVol 
					from JDE_DB_Alan.Master_ML345 a 
					--from m
					--where a.ItemNumber in ('24.7206.0000')
					--where a.ItemNumber in ('03.986.000')
					-- where a.ItemNumber in ('24.057.165s')   -- cannot find '24.057.165s' in ML345 file hence later table join will yield Null Value causing potential issue in coding - 29/1/18
					group by a.ItemNumber
					)					
			,fc_Vol as  
				( select fct.DataType1,fct.ItemNumber,sum(isnull(fct.value,0)) as ItemLvlFCVol_1To24,count(isnull(fct.Date,0)) TTL_FCMths		
					from JDE_DB_Alan.FCPRO_Fcst fct							-- 22/1/2018 did not have  condition before --> where fct.DataType1 like ('%Adj_FC%')	
					 where fct.DataType1 like ('%Adj_FC%')			-- 26/2/2018
					    and fct.Date between '2018-08-01' and '2019-03-01'				-- For Signature New Product Post Launch Analysis --- 5/6/2018
						-- and fct.Date between @Start and @End
					group by fct.DataType1,fct.ItemNumber)	
		
			,fcVol as (	select fc_Vol.ItemNumber
							,fc_Vol.DataType1							
							,fc_Vol.ItemLvlFCVol_1To24
							,fc_Vol.TTL_FCMths							
							,fcprt.Pareto
							--,sum(f.value) FCVol_ttl_24
						--from JDE_DB_Alan.FCPRO_Fcst f 		
						from fc_Vol inner join JDE_DB_Alan.FCPRO_Fcst_Pareto fcprt on fc_Vol.DataType1 = fcprt.DataType1 and fc_Vol.ItemNumber = fcprt.ItemNumber
						
						where fc_Vol.DataType1 like ('%Adj_FC%')			--26/2/2018
						--where fc_Vol.DataType1 like ('%default%')
						--where f.DataType1 like ('%point%') 		
						--group by f.ItemNumber,f.DataType1
							)
					--select * from fcVol where fcvol.ItemNumber = '03.986.000'
					--where fcVol.ItemLvlFCVol_24 is null		-- where fc.ItemNumber = '18.615.024' --- fc about 10125 record

				   --- Item Level ----
			,comb_Vol as (select fc_Vol.ItemNumber,histy.SlsVol_TTL_12,histy.Sls_Freq
									,stk.SOHVol
									,fc_Vol.ItemLvlFCVol_1To24
									,fc_Vol.TTL_FCMths
									--,coalesce(stk.SOHVol/(nullif(fc_Vol.ItemLvlFCVol_1To24/24,0)),0) as SOHWksCover						--if divisor is 0						 
									,coalesce(stk.SOHVol/(nullif(fc_Vol.ItemLvlFCVol_1To24/fc_Vol.TTL_FCMths,0)),0) as SOHWksCover		 --if divisor is 0 And FC month count varies --- 19/7/2018					 
							from fc_Vol left join histy on fc_Vol.ItemNumber = histy.ItemNumber_
										left join stk on stk.ItemNumber = histy.ItemNumber_
							)
			-- select * from comb_vol  where comb_Vol.SOHWksCover is null
			-- where comb_vol.ItemNumber = ('03.986.000')

			,combVol as ( select comb_Vol.*,px.StandardCost as Cost,px.WholeSalePrice as Price
							from comb_Vol left join JDE_DB_Alan.Px_AWF_HD_MT_FCPro_upload px on comb_Vol.ItemNumber = px.ItemNumber
							)

			,pareto as ( select p.ItemNumber,p.rnk,p.DataType1,p.Pareto from JDE_DB_Alan.FCPRO_Fcst_Pareto p where p.DataType1 like ('%Adj_FC%')			--26/2/2018
							)

			,comb_Amt as ( select combVol.*,Pareto.Pareto,pareto.rnk,ss.SS_
								,combVol.SlsVol_ttl_12*combVol.price as SlsAmt_12
								,combVol.ItemLvlFCVol_1To24*combVol.price as FCAmt_1To24
								,combVol.SOHVol*combVol.cost as SOHAmt										 
								from combVol left join pareto on combVol.ItemNumber = pareto.ItemNumber
												left join JDE_DB_Alan.FCPRO_SafetyStock ss on combVol.ItemNumber = ss.ItemNumber
						)
			 --select * from comb_Amt where comb_Amt.SlsAmt_12 is null or comb_Amt.FCAmt_24 is null or SOHAmt  is null


			,fl_ as ( select * 
								,sum(comb_Amt.SlsVol_TTL_12) over() as SlsVol_Grd
								,sum(comb_Amt.ItemLvlFCVol_1To24) over() as FCVol_Grd
								,sum(comb_Amt.SOHVol) over() as SOHVol_Grd
								,sum(comb_Amt.SlsAmt_12) over() as SlsAmt_Grd
								,sum(comb_Amt.FCAmt_1To24) over() as FCAmt_Grd
								,sum(comb_Amt.SOHAmt) over() as SOHAmt_Grd
							from comb_Amt)

			        --- Get Supplier name ---
			,_m as ( select a.ItemNumber
						,a.PrimarySupplier
					 ,case a.PlannerNumber when '20072' then 'Salman Saeed'
						when '20004' then 'Margaret Dost'	
						when '20005' then 'Imelda Chan'
						when '20071' then 'Domenic Cellucci'
						else 'Unknown'
					  end as Owner_
					  ,a.Description
						,row_number() over(partition by a.itemnumber order by a.itemnumber) as rn 
				  from JDE_DB_Alan.Master_ML345 a)
			,m as ( select * 
				from _m where rn =1 )

		  ,_fl as ( select fl_.*,m.PrimarySupplier,m.Owner_,m.Description from fl_ left join m on fl_.ItemNumber = m.ItemNumber) 

		 select * from _fl
		 where 
			--where fl_.ItemNumber like (@ItemNumber)
			-- where fl_.ItemNumber like ('%85053100%')	
			-- where fl_.ItemNumber in ('7495500001')	
		  -- where fl_.ItemNumber in (2974000000'	
			-- where fl_.ItemNumber in ('24.057.165s')					-- cannot find '24.057.165s' in ML345 file hence later table join will yield Null Value causing potential issue in coding - 29/1/18
		  
			-- m.PrimarySupplier in ( select data from JDE_DB_Alan.dbo.Split(@Supplier_id,','))
			--	_fl.ItemNumber in ( select splitdata from JDE_DB_Alan.dbo.fnSplitString(@Item_id,','))
			  _fl.ItemNumber in ('38.001.001','38.003.001','38.004.000','38.001.002','38.001.003','38.001.004','38.001.005','38.001.006','38.002.001','38.002.002','38.002.003','38.002.004','38.002.005','38.002.006','38.003.002','38.003.003','38.003.004','38.003.005','38.003.006')
		   --order by fl_.SlsAmt_12 desc
		   --  order by fl_.rnk	
	    order by 			 
	 			case when @OrderByClause ='rnk' then _fl.rnk end,
				case when @OrderByClause ='SlsAmt_12' then _fl.SlsAmt_12 end desc,
				case when @OrderByClause ='SOHAmt' then _fl.SOHAmt end desc
		option (maxrecursion 0)				 
						     

select distinct ml.PlannerNumber from JDE_DB_Alan.Master_ML345 ml
select ml.ItemNumber,ml.PlannerNumber,ROW_NUMBER() over(partition by ml.itemnumber order by ml.itemnumber) rnk from JDE_DB_Alan.Master_ML345 ml

 exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis @OrderBYClause = 'rnk'
exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis @OrderBYClause = 'SlsAmt_12' 
 exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis @Item_id = '%34.360.000%'
  exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis @Item_id = '42.642.000,34.017.000,UR13112,26.351.820'
 exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis @Item_id = '%085552500D212%'
 exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis @Item_id = '2974000000,7495500001,24.057.165s' ,@OrderBYClause ='SOHAmt'   --- works
 exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis @Item_id =  '24.7206.0000,2974000000,45.124.000'_tmp
  exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis @Item_id = 'S3000NET5250N902,18.017.163'
  exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis @Supplier_id = '20037',@Item_id = '34.016.000'
  exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis @Item_id = '8328001H'

 exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis @Item_id =  '45.142.100,45.142.000,45.131.100,45.131.000,45.130.100,45.130.000,45.124.100,45.124.000,45.113.000,45.112.000,45.107.000,45.106.000,45.307.000,45.676.100,45.676.000,45.644.000,45.643.000,45.615.100,45.400.103,45.400.102,45.319.100,45.318.000,45.309.100,45.307.100,45.263.000,45.236.100,45.234.100,45.231.100,45.222.100,45.220.100,45.064.063,45.052.063,45.033.063,45.031.063,45.027.063,45.025.063,45.606.100,45.606.000,45.134.000,45.134.100,45.133.000,45.133.100,45.147.100,45.147.000,45.625.134,45.237.100,45.238.100,45.239.100,45.240.100,45.241.100,45.242.100'    -- For Leiner Awning Parts Discontinuation - AWF meetings
 exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis @Item_id =  '82.610.901,82.610.902,82.610.903,82.610.904,82.611.901,82.611.902,82.611.903,82.611.904,82.612.901,82.612.902,82.612.903,82.612.904,82.613.901,82.613.902,82.613.903,82.613.904,82.614.901,82.614.902,82.614.903,82.614.904,82.615.901,82.615.902,82.615.903,82.615.904'			-- For CN8526
 exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis @Item_id =  '82.613.902'
  exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis @Item_id = '45.106.000,45.107.000,45.112.000,45.113.000,45.124.000,45.124.100,45.130.000,45.130.100,45.131.000,45.131.100,45.142.000,45.142.100,45.147.000,45.147.100,45.220.100,45.222.100,45.231.100,45.232.100,45.233.100,45.234.100,45.235.100,45.236.100,45.237.100,45.238.100,45.239.100,45.240.100,45.241.100,45.242.100,45.263.000,45.307.000,45.307.100,45.318.000,45.643.000,45.644.000,45.676.000,45.676.100'			
 exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis @Item_id =  '27.252.713'
  exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis @Item_id =  '0751031000202H'
  exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis @Item_id = '03.986.000'
   exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis @Item_id =  '4170681133,4170681320,4170681785,4170681862,4170681885,4170681651,4170681180,4170681426'
   exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis @Item_id = '26.058.104'
    exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis @Item_id = '34.218.000,34.219.000,34.085.000,34.086.000,34.026.000,34.084.000,34.024.000,34.025.000,34.067.000,34.068.000,34.087.000,34.088.000,34.065.000'

--- Signature New Product Post launch Analysis ---
 exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis @Item_id = '2851542072,2851548072,2851542167,2851548167,2851542245,2851548245,2851542351,2851548351,2851542661,2851548661,2851542669,2851548669,2851542689,2851548689,2851542785,2851548785,2851542862,2851548862,2801381661,2801381862,2801381320,2801381276,2801381810,2801381324,2801382661,2801382785,2801382320,2801382810,2801382689,2801382180,2801382862,2801382048,2801382879,2801382580,2801382324,2801382276,2801382609,2801382551,2801382669,2801382496,2801406661,2801406862,2801406072,2801406276,2801406351,2801406324,2801407661,2801407862,2801407072,2801407276,2801407351,2801407324,2801389661,2801389785,2801389072,2801389351,2801389689,2801389167,2801389862,2801389048,2801389354,2801389245,2801389324,2801389276,2801389609,2801389551,2801389669,2801389095,2801390661,2801390785,2801390072,2801390351,2801390689,2801390167,2801390862,2801390048,2801390354,2801390245,2801390324,2801390276,2801390609,2801390551,2801390669,2801390095,2801385661,2801385862,2801385320,2801385276,2801385810,2801385324,2801386661,2801386785,2801386320,2801386810,2801386689,2801386180,2801386862,2801386048,2801386879,2801386580,2801386324,2801386276,2801386609,2801386551,2801386669,2801386496,2801395661,2801395862,2801395072,2801395276,2801395351,2801395324,2801396661,2801396785,2801396072,2801396351,2801396689,2801396167,2801396862,2801396048,2801396354,2801396245,2801396324,2801396276,2801396609,2801396551,2801396669,2801396095,2801404000,2801403661,2801403862,2801403072,2801403276,2801403351,2801403324,2801436661,2801436785,2801436072,2801436351,2801436689,2801436167,2801436862,2801436048,2801436354,2801436245,2801436324,2801436276,2801436609,2801436551,2801436669,2801436095,2801405661,2801405785,2801405072,2801405351,2801405689,2801405167,2801405862,2801405048,2801405354,2801405245,2801405324,2801405276,2801405609,2801405551,2801405669,2801405095,KIT2758,KIT2759,2911529661,2911529862,2911529072,2911529276,2911529351,2911529324,2911530661,2911530862,2911530072,2911530276,2911530351,2911530324,2911531661,2911531785,2911531072,2911531351,2911531689,2911531167,2911531862,2911531048,2911531354,2911531245,2911531324,2911531276,2911531609,2911531551,2911531669,2911531095,2911532661,2911532785,2911532072,2911532351,2911532689,2911532167,2911532862,2911532048,2911532354,2911532245,2911532324,2911532276,2911532609,2911532551,2911532669,2911532095,2801471000,7502000000,7502001000,7501005000,7501001000,7804000000,2801499661,2801499785,2801499072,2801499351,2801499689,2801499167,2801499862,2801499048,2801499354,2801499245,2801499324,2801499276,2801499609,2801499551,2801499669,2801499095,2801999000,2781208000,2801454000,2801350000,2801433661,2801433862,2801433072,2801433276,2801433351,2801433324,2801434661,2801434862,2801434072,2801434276,2801434351,2801434324,2801490661,2801490785,2801490072,2801490351,2801490689,2801490167,2801490862,2801490048,2801490354,2801490245,2801490324,2801490276,2801490609,2801490551,2801490669,2801490095,2801491661,2801491785,2801491072,2801491351,2801491689,2801491167,2801491862,2801491048,2801491354,2801491245,2801491324,2801491276,2801491609,2801491551,2801491669,2801491095,2851512661,2851218661,2851224661,2851230661,2851236661,2851284661,2851512785,2851218785,2851224785,2851230785,2851236785,2851284785,2851512072,2851218072,2851224072,2851230072,2851236072,2851284072,2851512351,2851218351,2851224351,2851230351,2851236351,2851284351,2851218689,2851224689,2851230689,2851236689,2851284689,2851512167,2851218167,2851224167,2851230167,2851236167,2851284167,2851512862,2851218862,2851224862,2851230862,2851236862,2851284862,2851284048,2851218354,2851224354,2851230354,2851236354,2851284354,2851218245,2851224245,2851230245,2851236245,2851284245,2851284324,2851218276,2851224276,2851230276,2851236276,2851284276,2851284609,2851218551,2851224551,2851230551,2851236551,2851284551,2851284669,2851284095'
 exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis '2801404000,KIT2758,KIT2759,2801396785,2801386785,2801382785,2801396661,2801386661,2801382661,2801999000,2781208000,2801396862,2801350000,2801454000,2801389785,2801390785,2801396167,2801386862,2801382862,2801389661,2801396072,2801390661,2801396354,2801396669,2801396609,2801396276,2801389167,2801389072,2801386180,2801382180,2801386879,2801382879,2801386669,2801382669,2801386609,2801382609,2801386276,2801382276,2801389862,2801395661,2801386320,2801382320,2801389354,2801389689,2801389276,2801389669,2801389609,2801390862,2801390167,2801395862,2801390072,2801390354,2801390669,2801390609,2801390276,2801389048,2801389351,2801389245,2801390245,2801390689,2801396048,2801396689,2801390351,2801386689,2801382689,7804000000,2801389095,2801389324,2801390048,2801386048,2801382048,2801389551,2801396245,2801390095,2801390324,2801405785,2801396351,2801436785,2851230785,2801499785,7502000000,2801390551,2801386810,2801382810,2801471000,2801490785,2801385661,2801381661,2801405661,2801490661,2801436661,2851230661,2801499661,2801491785,2801386580,2801382580,2801491661,2801405862,2801396095,2801395276,2801436862,2801499862,2851230862,2911531785,2801490072,2801405167,2911532354,2911531661,2911532276,2911532669,2911531862,2911532609,2801405354,2801405669,2801405276,2801436167,2801405609,2801436354,2801436669,2801499167,2801436276,2801436609,2801405072,2801490167,2801499354,2851284609,2801499276,2801499609,2801499669,2851284669,2801385862,2801395324,2801436072,2801386496,2801385320,2801381862,2801382496,2801381320,2801396551,2801491072,2851230072,2801406661,2801499072,2851230354,2851230167,2851230276,2801490354,2801490669,2801490862,2911532661,2801490276,2801490609,2911532862,2801407661,2851224785,2801406072,2801491167,2801490048,2801490689,2801405689,2801395351,2801386551,2801382551,2801406862,2801436689,2801491354,2801491862,2801406276,2801491609,2801491276,2801491669,2911532072,2911531354,2911532785,2801405048,2801499689,2801407862,2801407072,2801407276,2801436048,2851284048,2801499048,2851284661,2851230689,2801406351,2801491048,2801491689,2851224661,2801396324,2801395072,2801407351,2801490351,2851284785,2801405351,7502001000,7501005000,2801386324,2801406324,2801382324,2911531245,2911532095,2911531072,2911531324,2911532167,2911531095,2911531167,2911531276,2911531669,2911532689,2801436351,2911532551,2911531551,2911531609,2801499351,2851236785,2851230351,2801491351,2801490095,2801403661,2851542785,2851548785,2851224862,2801407324,2801405245,2851218785,2801491095,2801499245,2851236661,2801436245,2801385810,2801381810,2801490245,2851230245,2851224354,2801433661,2911531351,2911531689,2911532245,2911532048,2851224072,2851224167,2851542862,2851542661,2851548072,2851542072,2851542167,2851224276,2851548167,2851548862,2851548661,2851284354,2851284072,2851218661,2851284862,2851236862,2851284167,2851284245,2851284551,2851284276,2851284689,2851284351,2851230551,2801491245,2801434661,2801405095,2801433072,2801499095,2851236072,2851218862,2801403072,2801403862,2801436095,2851284095,2801385324,2801385276,2851224689,2801381276,2801381324,2801403324,2801490551,2911529862,2801434072,2911529661,2851236354,2851236167,2851512785,2851224351,2851548351,2851236276,2801436551,2851548669,2911530276,2801405551,2851542689,2851548689,2801499551,2851542245,2851542351,2851542669,2851548245,2801405324,2801491551,7501001000,2801434862,2911530862,2801433276,2911530661,2801434276,2851218354,2851512661,2801436324,2851218167,2851218072,2851218276,2851236689,2801433862,2911529276,2911530072,2801491324,2801434324,2801490324,2911531048,2911532351,2801433324,2911532324,2801499324,2851284324,2851224245,2851512862,2851218689,2851236351,2851224551,2911530324,2801403351,2801433351,2911529072,2911529324,2911530351,2851512072,2801403276,2851218245,2851236245,2851512167,2851512351,2851218351,2851236551,2851218551,2801434351,2911529351','2018-05-01','2018-12-01'
 exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis '2801404000','2018-05-01','2018-12-01'       -- works
 exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis null,'2020-02-01','2021-01-01','SlsAmt_12'		-- works
  exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis null,'2020-02-01','2021-01-01','ParetoAndFCAmt'		-- works
    exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis null,'2020-02-01','2021-01-01','ParetoAndFCQty'		-- works
 exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis '26.812.410,26.812.901,26.812.604,26.812.820,26.812.902,26.812.962,26.815.410,26.815.901,26.815.604,26.815.820,26.815.902,26.815.962,26.814.410,26.814.901,26.814.604,26.814.820,26.814.902,26.814.962','2020-08-01','2021-03-01'       -- works


  exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis '6001130009009H','2018-05-01','2018-12-01'
  exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis '2801406324','2018-05-01','2018-12-01'
  exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis '2801406324','2019-07-01','2019-12-01'
 exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis '18.018.015','2018-08-01','2019-12-01'
 exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis '43.205.563M','2018-08-01','2019-12-01'
    exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis '44.005.102','2018-08-01','2019-12-01'
 exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis '38.001.001,38.003.001,38.004.000,38.001.002,38.001.003,38.001.004,38.001.005,38.001.006,38.002.001,38.002.002,38.002.003,38.002.004,38.002.005,38.002.006,38.003.002,38.003.003,38.003.004,38.003.005,38.003.006','2018-08-01','2019-02-01'
 
  exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis '2801396351','2018-08-01','2019-07-01'
  exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis '7501001000','2019-07-01','2019-12-01'
  exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis '7501001000','2018-08-01','2019-07-01'
 exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis 'S3000NET5250N001,S3000NET5300N001,82.336.906','2018-08-01','2019-07-01'
 exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis '42.210.031','2021-01-01','2022-02-01'
   exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis 'F16174A949,7501001000','2018-11-01','2019-07-01'
  exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis null,'2018-11-01','2019-10-01'

   exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis null,'2020-08-01','2021-07-02'
    exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis null,'2020-09-01','2021-08-02'
 exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis null,'2020-04-01','2021-03-02'
 exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis null,'2021-03-01','2022-02-02'

 exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis null,'2020-02-01','2021-01-02','rnk'
  exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis '31.118.131,31.119.131,31.120.131,31.122.131,31.123.131,31.124.131,31.125.000,31.126.000,31.127.176,31.127.000,31.128.176,31.128.000,31.129.176,31.129.000,31.130.176,31.130.000,31.105.101,31.150.131,31.151.131,31.152.131,31.153.131,31.155.176,31.156.176,31.157.176,31.155.000,31.156.000,31.157.000,31.161.176,31.161.000,31.163.176,31.163.000,31.165.131,31.167.131,31.168.131,31.169.131,31.170.131,31.171.131,31.172.131,31.166.131','2020-02-01','2021-01-02'
  exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis '26.812.410,26.812.604,26.812.820,26.812.901,26.812.902,26.812.962,26.813.604,26.813.820,26.813.962,26.814.410,26.814.604,26.814.820,26.814.901,26.814.902,26.814.962,26.815.410,26.815.604,26.815.820,26.815.901,26.815.902,26.815.962','2020-02-01','2021-01-02'

 -- 7441500001,7441500182,7441500914,7441700001,7441700182,7441700914,7442700001,7442700182,7442700914,7456500182,7457500001,7457500182,7457500914,7460500000,7460700000,7468500001,7468500182,7468500914,7468700001,7468700182,7468700914,7477500001,7477500182,7477500914,7477700001,7477700182,7477700914,7478500001,7478500182,7478500914,7478700001,7478700182,7478700914,7479500001,7479500182,7479500914,7479700001,7479700182,7479700914,7485700000,7488500001,7488500182,7488500914,7488700001,7488700182,7488700914,7489500001,7489500182,7489500914,7489700001,7489700182,7489700914,7491500001,7491500182,7491500914,7491700001,7491700182,7491700914,7493500001,7493500182,7493500914,7493700001,7493700182,7493700914,7494500001,7494500182,7494500914,7494700001,7494700182,7494700914,7497700001,7497700182,7497700914,7498700001,7498700182,7498700914,7499700001,7499700182,7499700914,7766050000,7766070000,7766250000,46.508.500,46.508.700,46.531.500,46.531.700


 exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis null,'2021-02-01','2022-01-01'
   	 
  select * from JDE_DB_Alan.FCPRO_SafetyStock ss where ss.ItemNumber in  ('24.7206.0000','2974000000','45.124.000')
  exec JDE_DB_Alan.sp_Cal_SafetyStock

  select * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h where h.ItemNumber in ('45.124.000') order by h.CYM
  select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('24.7206.0000','2974000000','45.124.000')
  select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('82.336.906')

  select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('31.122.131','31.123.131','31.124.131','31.125.000','31.127.176','31.129.176','31.129.000','31.130.000')


  '24.7206.0000','2974000000','45.124.000'
 ---=======.==============================================================================
 exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis '2974000000'
 --======================================================================================


--select * from comb where comb.ItemNumber in ('18.615.024')								--- comb about 8800 records after join with cost table

   select replace(convert(varchar(8), DATEADD(mm, DATEDIFF(m,0,GETDATE())-6,0),126),'-','')				--yield 201705
   select * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload s where s.ItemNumber in ('18.615.024') order by s.cy,s.Month


 ---------------End of Pareto/Portfolio Analysis: on Monthly level -- Link with stock, sales history 1/12/2017 --------------------- ========================



------------------------------- Inventory analysis Draft 1-----------------------------

select * from JDE_DB_Alan.FCPRO_Fcst_Pareto p 
--where rnk between 800 and 850
 order by p.DataType1,rnk

select p.ItemNumber,p.DataType1,p.ItemLvlFC_24,p.ItemLvlFC_24/24 FC_1MthAvg,p.Pareto from JDE_DB_Alan.FCPRO_Fcst_Pareto p where p.ItemNumber like ('%24.7206.0000')

select 14564.6666/18228.4166
select * from JDE_DB_Alan.Master_ML345 a where a.ItemNumber in ('24.7206.0000')

--------- Run this one ------
with fc as (
			select p.ItemNumber,p.DataType1,p.ItemLvlFC_24,(p.ItemLvlFC_24)/24 as ItemLvlFC_Avg1,p.Pareto,p.rnk
			from JDE_DB_Alan.FCPRO_Fcst_Pareto p
			--where p.ItemNumber in ('24.7206.0000')

			),
	stk as (
			select a.ItemNumber,sum(a.QtyOnHand) SOH,sum(a.StockValue) SOH_Val from JDE_DB_Alan.Master_ML345 a 
			--where a.ItemNumber in ('24.7206.0000')
			group by a.ItemNumber
			),

    fc_stk_ as ( select fc.ItemNumber,rnk,fc.DataType1,fc.ItemLvlFC_24,ItemLvlFC_Avg1,fc.Pareto
				  ,case 
					when fc.DataType1 = 'Point forecasts' then stk.SOH	
					when fc.DataType1 = 'WholeSalePrice' then stk.SOH_Val
				   end as Stock
					--,COALESCE(nullif(stk.SOH,0) / NULLIF(FC_1MthAvg,0), 0)*4.3 as Wks_Cover
					--,nullif((isnull(stk.SOH,0)/FC_1MthAvg),0)*4.3 as WksCover
			 from fc inner join stk on fc.ItemNumber = stk.ItemNumber
			 ),

     fc_stk as (  select fc_stk_.ItemNumber,fc_stk_.rnk,fc_stk_.Pareto
					, case 
						 when fc_stk_.DataType1 = 'Point forecasts' then 'Units'
						 when fc_stk_.DataType1 = 'WholeSalePrice' then  'Dollars' 
					  end as DataType1
					 ,fc_stk_.ItemLvlFC_24,fc_stk_.ItemLvlFC_Avg1,fc_stk_.Stock
					 ,COALESCE(nullif(fc_stk_.Stock,0) / NULLIF(ItemLvlFC_Avg1,0), 0)*4.3 as Wks_Cover
				from fc_stk_
				--where tb.ItemNumber in ('26.353.000')
				--order by tb.DataType1,tb.Pareto,tb.ItemLvlFC_24 desc
				),   

	  hist_ as ( select *,					
					  case  
						 when h.Month  >= 10  then format(h.Month,'0') 
						 --else right('000'+cast(a.financialMonth as varchar(2)),3)  
						 when h.Month  <10  then format(h.Month,'00') 
					  end as MM
					from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h
					),
      hist as ( select *,concat(hist_.CY,hist_.MM) as CYM
				 from hist_
				), 
	  histy as (select x.ItemNumber,count(x.CYM) NumOfSls,sum(x.SalesQty) TTLSls
				from hist x 
				--where x.ItemNumber in ('26.353.000') and x.CYM >201612
				  where x.CYM >201612
				group by x.ItemNumber ),
     
	 comb_ as ( select fc_stk.*
				,histy.NumOfSls,histy.TTLSls 
				from fc_stk inner join histy on fc_stk.ItemNumber = histy.ItemNumber  )

	 select * from comb_ where comb_.ItemNumber in ('75.099.0280')



   ---- history table ------ '26.353.000' has 11 month sales out of 12 months time from 2016.01 - 2017.11 --- about 9139 records
  declare @datetm int = replace(convert(varchar(8), DATEADD(mm, DATEDIFF(m,0,GETDATE())-6,0),126),'-','')	  
  ;with hist_ as ( select *,					
					  case  
						 when h.Month  >= 10  then format(h.Month,'0') 
						 --else right('000'+cast(a.financialMonth as varchar(2)),3)  
						 when h.Month  <10  then format(h.Month,'00') 
					  end as MM
			   from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h
			  ),
      hist as ( select *,concat(hist_.CY,hist_.MM) as CYM
				 from hist_
				), 
     histy as (select x.ItemNumber,count(x.CYM) Sls_freq,sum(x.SalesQty) SlsVol_ttl_24
				from hist x 
				--where x.ItemNumber in ('26.353.000') and x.CYM >201612
				--where x.cym >201512
				where  x.ItemNumber like ('%850531003021%') and x.CYM > @datetm					--'18.615.024'
				group by x.ItemNumber )

      select * from histy 	 
	  order by histy.SlsVol_ttl_24 


 ---========================================================================================================
	--------------------------- Inventory by location -------------------------------
	SELECT  [Short_Item_No]
      ,[Business_Unit]
      ,[Location_]
      ,[Primary_Location]
      ,[QTY_On_Hand]
      ,[QTY_Backordered]
      ,[QTY_On_PO]
      ,[QTY_On_WO_RC]
      ,[Qty_Hard_Committed_WO]
      ,[QTY_In_Transit]
      ,[Last_Rcpt_Date]
	  ,stk.Reportdate
  FROM [JDE_DB_Alan].[JDE_DB_Alan].[StkAvailability] stk 
  where stk.Short_Item_No in ('1074571')

   ---------------------------------- Inventory analysis Draft 2 using Inventory locaiton file 21/11/2017 -----------------------

   select sum(case when stk.Short_Item_No is null then 1 else 0 end ) NonExistItm, count(stk.Short_Item_No) ExistingItme from JDE_DB_Alan.StkAvailability stk		-- stock
   select sum(coalesce(stk.QTY_On_Hand,0)) as SOH  from JDE_DB_Alan.StkAvailability stk
   select count(distinct stk.Short_Item_No) from JDE_DB_Alan.StkAvailability stk
   select distinct stk.Short_Item_No from JDE_DB_Alan.StkAvailability stk
   select * from JDE_DB_Alan.StkAvailability stk where stk.Short_Item_No in ('1337705')

   select * from JDE_DB_Alan.SlsHistoryHD hs where hs.ShortItemNumber in ('1337705')			-- sales history
    select * from JDE_DB_Alan.SlsHistoryHD hs where hs.ItemNumber in ('18.615.024')
	select * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload s where s.ItemNumber like ('%85052000%')

	select * from JDE_DB_Alan.Master_ML345							-- price
	select * from JDE_DB_Alan.FCPRO_Fcst_Pareto	p where p.DataType1 like('%pri%')				-- fc & pareto

   ;with stk_ as (select distinct stk.Short_Item_No
					,sum(coalesce(stk.QTY_On_Hand,0)) as SOH 
					from JDE_DB_Alan.StkAvailability stk 
					where stk.Short_Item_No is not null 
					group by stk.Short_Item_No 
            ),

      sales as ( select *,case when hd.FinancialMonth >= 10  then format(hd.FinancialMonth,'0') 						
						       when hd.FinancialMonth  <10  then format(hd.FinancialMonth,'00') 
						  end as MM
					 from JDE_DB_Alan.SlsHistoryHD hd
	             union all
				 select *,case when mt.FinancialMonth >= 10  then format(mt.FinancialMonth,'0') 						
						       when mt.FinancialMonth  <10  then format(mt.FinancialMonth,'00') 
						  end as MM_
				     from JDE_DB_Alan.SlsHistoryMT mt
				 ),
     
	 sales_ as ( select distinct sales.ShortItemNumber,count(sales.Quantity) as Sls_freq ,sum(sales.Quantity) *(-1) Sls_Vol
				 from sales 
				 where sales.ShortItemNumber in ('1337705')	   
					--	and cast(concat(sales.Century,sales.FinancialYear,mm) as int) > 201701
				 group by sales.ShortItemNumber
			  )
     

     select * from stk_ join sales_ on stk_.Short_Item_No = sales_.ShortItemNumber

	-------------------------------------------------------------------------


	 select * into JDE_DB_Alan.FCPRO_Fcst_old from JDE_DB_Alan.FCPRO_Fcst_temp
	 delete from JDE_DB_Alan.FCPRO_Fcst_History
	 drop table JDE_DB_Alan.FCPRO_Fcst_downloaded
	 select * into JDE_DB_Alan.FCPRO_Fcst_History from JDE_DB_Alan.FCPRO_Fcst		and f.DataType1 in ('Adj_FC')			--26/2/2018
	 select * into JDE_DB_Alan.FCPRO_Fcst_History_ from JDE_DB_Alan.FCPRO_Fcst_History

---======================= End of Inventory Analysis==================================================================================================================================================




---===================================================================================================================================================================
-------- Another Portfolio Analysis - Originally Code for Getting FC from JDE for Particular Supplier -- works Yeah !!! 17/1/2018 ------------ Need First create Table for JDE FC & Item Cross Ref --------------------
---- Code for BroomField FC request by Drake with Diana Altiparmakova's Market Intelligence ---- 11/1/2018

--- need to pick up the latest record in ItemCrossRef Table---- 
--use JDE_DB_Alan
--go

----- This is correct calculation --- 19/1/2018 ---
with cte as (
	select *
    ,rank() over (partition by ItemNumber,Address_Number order by c.expireddate desc ) as myrnk					-- cannot use Expireddate as it is not maintained properly 1/5/2018
	,row_number() over(partition by ItemNumber,Address_Number order by Address_Number desc ) as rnk_							--- Since A Sku can be produced by multiple supplie 	
	,max(c.ExpiredDate) over(partition by ItemNumber order by Address_Number desc ) as max_expir_date		-- please note address_number for 02.060.000 are 1543934,20015,30482,503666 which are all pointed to supplier 155235 which is primary supplier for SKU 02.060.000, this SKU might have multiple (5) supplier against it. however, JDE 'Supplier_Cross_Ref' table as default choose the primary supplier (155235) and put its relevant supplier ref product code in this table. YOu can see for supplier 155235 we changed reference 4 times. 1/5/2018
	,max(c.EffectiveDate) over(partition by ItemNumber order by ItemNumber desc ) as max_effec_date
	,rank() over (partition by ItemNumber  order by c.effectivedate desc ) as rnk							-- use effective  datea as bench mark
	from JDE_DB_Alan.Master_ItemCrossRef c 
	--where c.ItemNumber in ('2950100000') 
	--where c.ItemNumber in ('28.536.850','02.060.000')  
	)
 ,cte_ as 
	( select * from cte where cte.rnk = 1 
	 )
 --select * from cte_  
 --select * from cte_ where cte_.ItemNumber in ('28.536.850','02.060.000') 
--  select cte_.ItemNumber,count(cte_.Xref_Type) myct from cte_  group by cte_.ItemNumber order by myct desc

,itm_mthLvl	 as (
select fc.ShortItemNunber,fc.ItemNumber,m.Description
		--,fc.Date
		,dateadd(mm,-1,dateadd(d,1,fc.Date)) as FC_Date				-- Get first day of month since Jde FC date is end of each month
		,isnull(fc.Qty,0) as FC_Qty
		,isnull(m.QtyOnHand,0) as SOH
		,cte_.Customer_Supplier_ItemNumber,cte_.Address_Number,p.Pareto,m.UOM			-- Need to get UOM and Pareto		
		,isnull(m.StandardCost,0) Cost,isnull(m.WholeSalePrice,0) SlsPx
		,isnull(m.WholeSalePrice * fc.Qty,0) as FC_Amt
		,isnull(m.StandardCost * m.QtyOnHand,0) as SOH_Amt
		--,isnull(avg(fc.qty) over( partition by fc.itemnumber),0) as AvgMthFC
		--,coalesce(isnull(m.QtyOnHand,0)/nullif(isnull(avg(fc.qty) over( partition by fc.itemnumber),0),0),0)  as MthCover
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
         ),

itm_mthLvl_ as 
     ( select l.*
	 ,isnull(avg(l.FC_Qty) over( partition by l.itemnumber),0) as AvgMthFC
	 ,coalesce(isnull(l.SOH,0)/nullif(isnull(avg(l.FC_Qty) over( partition by l.itemnumber),0),0),0)  as TTLMthCover
	 from itm_mthLvl l),
	 
 --select * from itm_mthLvl_  ll
--where ll.ItemNumber in ('2780149661')
 --order by MthCover desc
 --order by Address_Number,Pareto,ItemNumber,itm_Lvl.FC_Date 

 itm_lvl as (
   select ll.ItemNumber,ll.Description,ll.Customer_Supplier_ItemNumber,ll.Address_Number
         ,sum(FC_Qty) as FC_Qty_24mth
		 ,avg(SOH) as SOH_Qty
		 ,avg(ll.TTLMthCover) as TTLMthCover_
		 ,sum(ll.FC_Amt) as FC_Amt_24mth 
		 ,avg(ll.SOH_Amt) as SOH_Amt_24mth 
		 ,case isnull(avg(SOH),0) when 0 then 0 else isnull((avg(SOH) - sum(FC_Qty)/24*12),0)*isnull(avg(cost),0) end as SOH_Amt_Res_12m			-- if SOH qty is 0, then no need to cal residue
		  ,case isnull(avg(SOH),0) when 0 then 0 else isnull((avg(SOH) - sum(FC_Qty)/24*6),0)*isnull(avg(cost),0) end as SOH_Amt_Res_6m				-- if SOH qty is 0, then no need to cal residue

   from itm_mthLvl_ ll 
   group by ll.ItemNumber,ll.Description,ll.Customer_Supplier_ItemNumber,ll.Address_Number
    )


 select tb.*,p.Pareto,t.Comment 
 from itm_lvl tb left join JDE_DB_Alan.FCPRO_MI_tmp t on tb.ItemNumber = t.ItemNumber
                 left join JDE_DB_Alan.FCPRO_Fcst_Pareto p on tb.ItemNumber = p.ItemNumber  
 where 
		t.Comment is not null 
		-- tb.ItemNumber in ('2974000000')
		-- and tb.ItemNumber in ('27.253.000')
-- order by tb.TTLMthCover_ desc,t.Comment desc
order by Pareto



--=========================================================================================================================
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
	 where  m.Address_Number in ('20037')					-- is m.Address_Number correct field to use ??? 1/5/2018

	
	select *
	--from JDE_DB_Alan.Master_ItemCrossRef m where m.Address_Number in ('20037')					-- is m.Address_Number correct field to use ??? 1/5/2018
	from JDE_DB_Alan.Master_ItemCrossRef m where m.ItemNumber in ('2930564000','7612208013') and m.Address_Number in ('20037')		-- is m.Address_Number correct field to use ??? 1/5/2018
	--from JDE_DB_Alan.Master_ItemCrossRef m where m.Customer_Supplier_ItemNumber like ('%*')
	 from JDE_DB_Alan.Master_ItemCrossRef m where m.Customer_Supplier_ItemNumber = ('*') and m.Address_Number in ('20037')			-- is m.Address_Number correct field to use ??? 1/5/2018
--============================================================================================================================

---==============  End of Portfolio Analysis - Originally Code for Getting FC from JDE for Particular Supplier  ==================================================




---------------  Audit --------------------------------------------------------------------
  --- Count Duplicate ItemNumber in ItemMaster ---
  select m.ItemNumber,count(ItemNumber) ItemCount
  from JDE_DB_Alan.Master_ML345 m 
  --where m.ItemNumber in ('0850520000202')
    group by m.ItemNumber
	order by count(ItemNumber) desc,m.ItemNumber

--- Count Primary supplier field has null value ---
  select m.ItemNumber
        ,sum( case when m.primarysupplier is null then 100 else 1 end) as suppliercount
  from JDE_DB_Alan.Master_ML345 m 
  --where m.ItemNumber in ('0850520000202')
    group by m.ItemNumber
	order by sum( case when m.primarysupplier is null then 100 else 1 end) desc,m.ItemNumber

--- Check item has no primary supplier ---  It is OK to hv Item has no supplier if Item is Manufacturing Item ( stockingtype S )
  select m.ItemNumber
  from JDE_DB_Alan.Master_ML345 m
  where m.PrimarySupplier is null

  select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('FT.01367.060.01')

----- Number of Items for TMS and CC --------------------
  select distinct s.ItemNumber from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload s where s.Family like ('%CC%') or s.Family like ('%TM%')



 -------- Temporarily Update Or manually change ML345 -- For Project Simplification -- Need to change StockingTyping Status for Certain SKU as Team is not up to speed and System restriction --- 16/3/2018

 Item with Multi Entry --> ('6000030009001','8200124000901')
All Items --> ('26.802.659T','26.802.676T','26.802.830T','26.802.833T','26.802.971T','26.802.820T','26.802.962T','26.802.963T','26.810.971T','26.810.962T','26.810.830T','26.810.659T','26.810.833T','26.810.676T','26.800.820T','26.800.962T','26.800.963T','26.810.963T','26.800.659T','26.800.676T','26.800.830T','26.800.833T','26.800.971T','26.811.820T','26.811.962T','26.811.676T','26.801.820T','26.801.962T','26.801.963T','26.801.676T','26.803.659T','26.803.676T','26.803.830T','26.803.833T','26.803.971T','26.803.820T','26.803.962T','26.803.963T','6000130009001','6000030009001','6000130009004','6000130009008','6000030009005','6000130009003','6000030009011','6000030009012','6000130009002','6000130009011','6000130009010','6000130009012','6000030009004','6000130009006','6000130009009','6000030009007','6000130009005','6000030009003','6000030009009','6000030009002','6000030009010','6000030009006','6000130009007','6000030009008','6000030009001CL','6000030009002CL','6000030009003CL','6000030009004CL','6000030009005CL','6000030009006CL','6000030009007CL','6000030009008CL','6000030009009CL','6000030009010CL','6000030009011CL','6000030009012CL','6000130009001CL','6000130009002CL','6000130009003CL','6000130009004CL','6000130009005CL','6000130009006CL','6000130009007CL','6000130009008CL','6000130009009CL','6000130009010CL','6000130009011CL','6000130009012CL','8SCA3300PR','8SCA3300SB','8SCA3300BI','8SCA3300SU','8SCA3300CO','8SCA3300LQ','8SCA3300OY','8SCA300LQ','8SCA300BI','8SCA300SU','8SCA3300TRE','8SCA300CO','8SCA300SB','8SCA300PR','8SCA300TRE','8SCA300OY','8SCA3300BICL','8SCA3300COCL','8SCA3300LQCL','8SCA3300OYCL','8SCA3300PRCL','8SCA3300SBCL','8SCA3300SUCL','8SCA3300TRECL','8SCA300BICL','8SCA300COCL','8SCA300LQCL','8SCA300OYCL','8SCA300PRCL','8SCA300SBCL','8SCA300SUCL','8SCA300TRECL','6001030009007','6001030009009','6001030009010','6001030009011','6001030009019','6001030009020','6001030009021','6001030009022','6001030009023','6001130009007','6001130009009','6001130009010','6001130009011','6001130009019','6001130009020','6001130009021','6001130009022','6001130009023','6001030009007CL','6001030009009CL','6001030009010CL','6001030009011CL','6001030009019CL','6001030009020CL','6001030009021CL','6001030009022CL','6001030009023CL','6001130009007CL','6001130009009CL','6001130009010CL','6001130009011CL','6001130009019CL','6001130009020CL','6001130009021CL','6001130009022CL','6001130009023CL','6004030009038','6004030009041','6004030009049','6004030009050','6004129009038','6004129009041','6004129009049','6004129009050','6004030009038CL','6004030009041CL','6004030009049CL','6004030009050CL','6004129009038CL','6004129009041CL','6004129009049CL','6004129009050CL','8200124000910','8200124000907','8200124000908','8200124000906','8200124000903','8200124000927','8200124000932','8200124000901','8200124000904','8200124000912','8200124000929','8200124000911','8200124000928','8200124000902','8200124000933','8200124000905','8200124000909','8200124000930','8200124000931','8200124000926','8200128000910','8200128000907','8200128000908','8200128000906','8200128000903','8200128000927','8200128000932','8200128000901','8200128000904','8200128000912','8200128000929','8200128000911','8200128000928','8200128000902','8200128000933','8200128000905','8200128000909','8200128000930','8200128000931','8200128000926')
All ShortItems --> ('1318213','1318221','1318256','1318192','1318205','1318248','1318264','1318230','1365693','1365677','1365651','1365626','1365669','1365634','1318117','1318141','1318109','1365685','1318088','1318096','1318133','1318061','1318070','1365714','1365722','1365706','1318168','1318176','1318150','1318184','1318301','1318310','1318344','1318281','1318299','1318336','1318352','1318328','1194901','1194847','1194935','1228277','1194880','1194927','1228242','1228251','1194919','1228306','1228293','1228314','1194871','1194951','1228285','1228200','1194943','1194863','1228226','1194855','1228234','1194898','1228269','1228218','1374047','1374135','1374768','1374784','1374792','1374805','1374813','1374821','1374830','1374848','1374856','1374864','1374143','1374872','1374881','1374899','1374901','1374910','1374928','1374936','1374944','1374952','1374961','1374979','1241391','1241404','1348674','1348666','1241359','1241375','1348682','1241455','1348771','1348762','1348754','1241439','1241480','1241471','1348797','1348789','1374303','1376149','1376157','1376165','1376173','1376181','1376190','1376202','1374291','1376085','1376093','1384763','1376106','1376114','1376122','1376131','1194960','1194986','1194994','1195006','1348615','1348623','1348631','1348640','1348658','1195049','1195065','1195073','1195081','1348560','1348578','1348586','1348594','1348607','1374055','1374151','1374987','1374995','1375007','1375015','1375023','1375040','1375058','1374160','1375074','1375091','1375103','1375120','1375146','1375154','1375171','1375189','1195284','1195313','1195399','1195401','1193545','1193570','1193625','1193633','1374063','1374178','1375197','1375200','1374186','1375218','1375226','1375234','1344606','1352614','1352622','1344518','1344526','1352657','1344577','1344500','1344534','1344585','1352665','1352649','1344542','1352593','1344593','1352606','1352631','1344551','1344569','1344497','1344489','1352534','1352542','1344391','1344403','1352577','1344454','1344382','1344411','1344462','1352585','1352569','1344420','1352518','1344471','1352526','1352551','1344438','1344446','1344374')
All Items with non 'O','S' Status --> ('6004129009038','6004129009041','6004129009049','6004129009050','6001030009007','6001030009009','6001030009010','6001030009011','6001130009007','6001130009009','6001130009010','6001130009011','6004030009038','6004030009041','6004030009049','6004030009050','6000030009007','6000030009009','8SCA3300CO','8SCA3300PR','8SCA300LQ','8SCA300PR','8SCA300SB','6001130009019','6001130009020','6001130009021','6001130009022','6001130009023','6001030009019','6001030009020','6001030009021','6001030009022','6001030009023','8SCA3300SU','8SCA3300OY','8SCA300SU','8SCA300OY','6001030009007CL','6004030009038CL','6001030009009CL','6001130009007CL','6004030009041CL','6004129009038CL','8SCA300BICL','8SCA3300BICL','6000130009005CL','6000130009006CL','6000130009007CL','6000130009009CL','6001030009010CL','6001030009011CL','6001030009019CL','6001030009020CL','6001030009021CL','6001030009022CL','6001030009023CL','6001130009009CL','6001130009010CL','6001130009011CL','6001130009019CL','6001130009020CL','6001130009021CL','6001130009022CL','6001130009023CL','6004030009049CL','6004030009050CL','6004129009041CL','6004129009049CL','6004129009050CL','8SCA300SUCL','8SCA3300COCL','8SCA3300LQCL','8SCA3300OYCL','8SCA3300PRCL','8SCA3300SUCL')


;update m
set m.StockingType = 'P'
from JDE_DB_Alan.Master_ML345 m
where m.ItemNumber in ('6004129009038','6004129009041')
     and m.StockingType not in ('O','S')

select * from JDE_DB_Alan.Master_ML345 m
where 
       m.ItemNumber in ('6004129009038','6004129009041')
		--m.ShortItemNumber in ('1318213','1318221','1318256','1318192','1318205','1318248','1318264','1318230','1365693','1365677','1365651','1365626','1365669','1365634','1318117','1318141','1318109','1365685','1318088','1318096','1318133','1318061','1318070','1365714','1365722','1365706','1318168','1318176','1318150','1318184','1318301','1318310','1318344','1318281','1318299','1318336','1318352','1318328','1194901','1194847','1194935','1228277','1194880','1194927','1228242','1228251','1194919','1228306','1228293','1228314','1194871','1194951','1228285','1228200','1194943','1194863','1228226','1194855','1228234','1194898','1228269','1228218','1374047','1374135','1374768','1374784','1374792','1374805','1374813','1374821','1374830','1374848','1374856','1374864','1374143','1374872','1374881','1374899','1374901','1374910','1374928','1374936','1374944','1374952','1374961','1374979','1241391','1241404','1348674','1348666','1241359','1241375','1348682','1241455','1348771','1348762','1348754','1241439','1241480','1241471','1348797','1348789','1374303','1376149','1376157','1376165','1376173','1376181','1376190','1376202','1374291','1376085','1376093','1384763','1376106','1376114','1376122','1376131','1194960','1194986','1194994','1195006','1348615','1348623','1348631','1348640','1348658','1195049','1195065','1195073','1195081','1348560','1348578','1348586','1348594','1348607','1374055','1374151','1374987','1374995','1375007','1375015','1375023','1375040','1375058','1374160','1375074','1375091','1375103','1375120','1375146','1375154','1375171','1375189','1195284','1195313','1195399','1195401','1193545','1193570','1193625','1193633','1374063','1374178','1375197','1375200','1374186','1375218','1375226','1375234','1344606','1352614','1352622','1344518','1344526','1352657','1344577','1344500','1344534','1344585','1352665','1352649','1344542','1352593','1344593','1352606','1352631','1344551','1344569','1344497','1344489','1352534','1352542','1344391','1344403','1352577','1344454','1344382','1344411','1344462','1352585','1352569','1344420','1352518','1344471','1352526','1352551','1344438','1344446','1344374')
       and m.StockingType not in ('O','S')


select * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload s 
where s.ItemNumber in ('6004030009038CL')



---------- Open Purchase order Report ------------ 1/5/2018
select * from JDE_DB_Alan.Master_ItemCrossRef

select * from JDE_DB_Alan.OpenPO op where op.ItemNumber in ('02.199.000') order by op.ItemNumber
select op.ItemNumber,count(op.OrderNumber) from JDE_DB_Alan.OpenPO op 
group by op.ItemNumber
order by op.ItemNumber



with cte as (
	select *
    ,rank() over (partition by ItemNumber,Address_Number order by c.expireddate desc ) as myrnk					-- cannot use Expireddate as it is not maintained properly 1/5/2018
	,row_number() over(partition by ItemNumber,Address_Number order by Address_Number desc ) as rnk_							--- Since A Sku can be produced by multiple supplie 	
	,max(c.ExpiredDate) over(partition by ItemNumber order by Address_Number desc ) as max_expir_date		-- please note address_number for 02.060.000 are 1543934,20015,30482,503666 which are all pointed to supplier 155235 which is primary supplier for SKU 02.060.000, this SKU might have multiple (5) supplier against it. however, JDE 'Supplier_Cross_Ref' table as default choose the primary supplier (155235) and put its relevant supplier ref product code in this table. YOu can see for supplier 155235 we changed reference 4 times. 1/5/2018
	,max(c.EffectiveDate) over(partition by ItemNumber order by ItemNumber desc ) as max_effec_date
	,rank() over (partition by ItemNumber  order by c.effectivedate desc ) as rnk							-- use effective  datea as bench mark
	from JDE_DB_Alan.Master_ItemCrossRef c 
	--where c.ItemNumber in ('2950100000') 
	--where c.ItemNumber in ('28.536.850','02.060.000')
	--where c.ItemNumber in ('34.421.000')
	--  where c.ItemNumber in ('09.508.000')
	 --where c.Xref_Type in ('VN')  
	--order by c.ItemNumber
	)
 ,cte_ as 
	( select * from cte where cte.rnk = 1 
	 )

 -- select * from cte_
 --select * from cte_ where cte_.ItemNumber in ('28.536.850','02.060.000') 
-- select * from cte_ where cte_.ItemNumber in ('703156')
 -- select cte_.ItemNumber,count(cte_.Xref_Type) myct from cte_  group by cte_.ItemNumber order by myct desc         --- this to check which item has mulitple effective date  2/5/2018

select * 
from JDE_DB_Alan.OpenPO op left join cte_ on op.ItemNumber = cte_.ItemNumber


-------------------------------------------------------------------
--- To Get Supplier Name and its Number --- 3/5/2018
select distinct op.SupplierNumber,op.SupplierName from JDE_DB_Alan.OpenPO op where op.SupplierName like('%lein%')
select distinct op.SupplierNumber,op.SupplierName from JDE_DB_Alan.OpenPO op where op.SupplierNumber like('2002%')

select * from JDE_DB_Alan.OpenPO op where op.ItemNumber in ('02.199.000') order by op.ItemNumber
select * from JDE_DB_Alan.OpenPO op where op.ItemNumber in ('34.430.000') order by op.ItemNumber
select * from JDE_DB_Alan.Master_ML345


-------------------------------------------- PO/Demand Report ---------------------------------------------------------
ALTER TABLE JDE_DB_Alan.FCPRO_Fcst_ ADD ID int NOT NULL IDENTITY (1,1) PRIMARY KEY	

--use JDE_DB_Alan
--go


SET STATISTICS XML ON
--select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('34.430.000')

---------- Final PO/FC Analysis 11/5/2018  works Yeah !! revised 15/5/2018---------------------

select * from JDE_DB_Alan.vw_FC f where f.ItemNumber in ('0751031003001H')
select * from JDE_DB_Alan.vw_OpenPO p where p.ItemNumber in ('XUR10516')
select * from JDE_DB_Alan.vw_Mast m where m.ItemNumber in ('0751031003001H')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('0751031003001H')
select * from DATEADD(mm, DATEDIFF(m,0,GETDATE())+10,0)



 DECLARE @TotalProduct AS TABLE 
(ProductID INT NOT NULL PRIMARY KEY,
 Quantity INT NOT NULL)
 
 INSERT INTO @TotalProduct
         ( [ProductID], [Quantity] )

----------------------------- Mismatch Report 12/7/2018  Version 1 ( left join ) ---------------------------------------------------
  -- Table variables For Market Intelligence ( Ad Hoc change either need to add or reduce FC ) --- 11/7/2018  -- Data Type should be matching data type in 'JDE_DB_Alan.vw_FC' 
declare @mymi as table
( ItemID varchar(100) not null primary key ,
  FcDate varchar(100) not null,
  FcQty  decimal(18,2) not null )
  
 Insert into @mymi ( ItemId,FcDate,FcQty)
 values 
('42.210.030','2018-09',397.08);

   
--select * from @mymi

DECLARE @dt datetime
SET @dt = DATEADD(mm, DATEDIFF(m,0,GETDATE())+10,0)

--Declare @Item_id varchar(8000)
--SET @Item_id = '45.103.000,27.252.713'

			 --first sumarize PO by month ---     
;with         
		   po as (
					 select tb.ItemNumber,tb.DataType1,tb.PODate_,tb.poyr,tb.pomth,tb.BuyerName,tb.BuyerNumber,tb.TransactionOriginator,tb.TransactionOrigName,tb.SupplierName
							,sum(tb.PO_Volume) as PO_Vol
					    from JDE_DB_Alan.vw_OpenPO tb
					 -- where tb.ItemNumber in  ( select splitdata from JDE_DB_Alan.dbo.fnSplitString(@Item_id,','))	
					  group by tb.ItemNumber,tb.DataType1,tb.PODate_,tb.poyr,tb.pomth,tb.BuyerName,tb.BuyerNumber,tb.TransactionOriginator,tb.TransactionOrigName,tb.SupplierName

					  )
				--select * from po
			
			  -- FC --- updated 12/7/2018 to include MI in table variable ( Or Temp table)
			 ,fc as																		
				   ( select f.ItemNumber,f_.ItemID,f.Date,f.FCDate_,f.FC_Vol,f_.FcQty
				            ,case when FcQty is null then f.FC_Vol
							      when FcQty is not null then f.FC_Vol + f_.FcQty 
								   --   else f.FC_Vol + f_.FcQty
							   end as  FC_Vol_f	   
				     from JDE_DB_Alan.vw_FC f left join @mymi f_ on f.ItemNumber = f_.ItemID and f.FCDate_ = f_.FcDate		-- Use '.vw_FC f' to left join when you need to run Mismatch for whole business -- including ~ 7000 SKUs ( remember that planner might not place order when they should be - that is when you see all outstanding PO in JDE might not mean ALL order has been placed - need to check action message - there might be a gap between requirment of action message and actual execution which is number of outstanding PO placed)
																															    --- Use '@mymi ' to left join when you need to just pull out dataset for MI as you do not need to pull out whole records

																																--- use '.vw_FC f' full outer join with @mymi when necessary since they might be null value on both table after join  --- 20/7/2018
																																--- You need to select/use different ItemNumber depend on which join you select  as per above other you will end up with having different data set ! 
					 -- from  @mymi f_  left join JDE_DB_Alan.vw_FC f on f.ItemNumber = f_.ItemID and f.FCDate_ = f_.FcDate 	 
					 -- from JDE_DB_Alan.FCPRO_MI_orig f_ left join fc_mas f on f.ItemNumber = f_.ItemID and f.Date = f_.Date	         --- not good causing big problems for SOH etc because on Mi raw table you only have 1 or 2 or 3 month, say if MI is for 2018-09 then you will not get SOH ( since SOH is always default to current month you are in ) and you need visibility for each month, YOU can use left join if you are not concerning SOH figure but in order to keep your code consistent, you should keep use full outer join and filter out on specific SKUs at end,this might best solution for this issue 25/7/2018 --- Will Use this lead to risk of lossing item has no sales history 18.013.089	--- No ???																																	
					-- where f.ItemNumber in ( '42.210.031','24.7207.4459')
					     --  and f.Date < '2019-03-01'
					 )
               --select * from fc 
			   -- select distinct fc.ItemNumber from fc 
			  --select  * from fc  where fc.ItemID in ('18.013.089') or fc.ItemNumber in ('18.013.089')			--- note 18.013.089 has no existence in 'FVPRO_Fcst' table as there is no sales history over 12 month. Therefore when join table you will have unexpected result - be careful here in where condition be careful to which ItemNumber or ItemId you need to use. Also be careful using 'Not In ( )' conditional because if there is null value SQL will return empty dataset ! --- 20/7/2018
			   
			           --- Start --- Get your Opening stock ---
				,tb as 
					( select f.ItemNumber,f.Date,f.FCDate_,f.FC_Vol_f as FC_Vol				-- will it cause issues if you rename 'f.FC_Vol_f' as 'FC_Vol' since you already have 'FC_Vol' column ?
						 -- select f.ItemNumber,f.Date,f.FCDate_,f.FC_Vol_f
							,isnull(p.PO_Vol,0) PO_Vol
							--,isnull(m.QtyOnHand,0) SOH_Vol
							,isnull(m.QtyOnHand,0) as SOH_Begin_M
							 ,0 as SOH_Vol				 
							--, isnull(m.QtyOnHand,0) as SOH_End_M
							,0 as SOH_End_M
							,m.WholeSalePrice
							 
					-- from JDE_DB_Alan.vw_FC f left join po p on f.ItemNumber = p.ItemNumber and f.FCDate_ = p.PODate_
					  from fc f left join po p on f.ItemNumber = p.ItemNumber and f.FCDate_ = p.PODate_
											left join JDE_DB_Alan.vw_Mast m on f.ItemNumber  = m.ItemNumber and f.FCDate_ = m.SOHDate   -- SOHDate is current month name,also note 'vw_Mast' is clearn without duplicated records
					 where f.Date< @dt						--- be careful if there is null value in f.Date 
					 -- where f.Date < '2018-10-01'
						  -- and f.ItemNumber in ('45.103.000')
								 )
						
			   --select * from tb  where tb.ItemNumber in ('42.210.031')     
			           --- Get your SOH_Vol_ ---
				  ,tb_ as (
							select tb.ItemNumber,tb.Date,tb.FCDate_,tb.FC_Vol,tb.PO_Vol,tb.SOH_Vol 
									,case 
										   when tb.Date >DATEADD(mm, DATEDIFF(m,0,GETDATE()),0)  then (tb.PO_Vol -tb.FC_Vol)
										   when tb.date = DATEADD(mm, DATEDIFF(m,0,GETDATE()),0) then (tb.PO_Vol -tb.FC_Vol + tb.SOH_Begin_M)
										   else tb.SOH_Vol
										  end as  SOH_Vol_
								  -- ,(tb.PO_Vol -tb.FC_Vol) as SOH_Vol_
								   ,tb.SOH_Begin_M,tb.SOH_End_M
								   ,tb.WholeSalePrice					  
							from tb				
							)  
				-- select * from tb_ where tb_.ItemNumber in ('42.210.031')  
						   --- running total preparation --- Prepare to get your proper End Period Stock ---     
				   ,tbl as ( select *,
									row_number() over ( partition by tb_.ItemNumber order by tb_.FCDate_ ) as rnk 
								from tb_      
                
							)
							--- running total To get End period inventory ---
				 ,tbl_ as 
						(	select *
								  ,sum(tbl.SOH_Vol_) over (partition by tbl.ItemNumber order by tbl.rnk ) as SOH_End_M_
								from tbl
						 )
      
				  --select * from tbl_ where tbl_.ItemNumber in ('42.210.031')  
							--- Beginning period inventory preparation ---
				  ,stk_beg as
						  ( select tbl_.ItemNumber as myItemNumber,tbl_.Date as myDate
									,DATEADD(mm, DATEDIFF(m,0,tbl_.Date)+1,0) dte
									,tbl_.SOH_End_M_ as mySOH_Begin_M_
			            
							 from tbl_)
					 --  select * from stk_beg where stk_beg.myItemNumber in ('42.210.031')  

				 ,t as ( select *
								 from tbl_ left join stk_beg on tbl_.ItemNumber = stk_beg.myItemNumber and tbl_.Date = stk_beg.dte 
							  )
					--  select * from t
							  --- Get Begining period inventory ---
				 ,t_ as ( select t.ItemNumber,t.Date,t.FCDate_,t.FC_Vol,t.PO_Vol,t.SOH_Vol,t.SOH_Vol_
									,case 
											when t.mySOH_Begin_M_ is null then t.SOH_Begin_M
											else t.mySOH_Begin_M_
									  end as  Final_SOH_Begin_M_
									,t.SOH_End_M_,t.rnk
									,t.WholeSalePrice
									--,t.myWSP
								 from t
								 )

					  --select * from t_
					  -- ,pri as ( select t_.ItemNumber,t_.WholeSalePrice from t_ where t_.WholeSalePrice is not null)

					 --  select * from pri
					--   ,_t as ( select t_.*,																			-- cost too long time to run
								   --       case when t_.WholeSalePrice is null then pri.WholeSalePrice
											 --   else t_.WholeSalePrice
										  --  end as mywholesaleprice
									--from t_ left join pri on t_.ItemNumber = pri.ItemNumber )
          
				  ,_t as ( --select t_.ItemNumber,t_.Date,t_.FCDate_,t_.FC_Vol,t_.PO_Vol,t_.SOH_Vol,t_.SOH_Vol_,t_.Final_SOH_Begin_M_,t_.SOH_End_M_,m.WholeSalePrice     -- will spit out column by column saves the performance issue ? Not really  -- 14/5/2018
								select t_.*
										, mm.WholeSalePrice as Mywholesaleprice
										,(mm.WholeSalePrice * t_.FC_Vol) FC_Amt
									   , case when t_.Final_SOH_Begin_M_ <= 0  then 'Y 'else 'N' end as Stk_Out_Stauts
									   ,sum(t_.FC_Vol) over (partition by t_.ItemNumber order by t_.FCDate_ Rows between current row and 2 following ) as CumulativeTotal_FC_Vol_3M			-- only works in SQL 2012 upwards, if you using 2008 need to use below...  https://docs.microsoft.com/en-us/sql/t-sql/queries/select-over-clause-transact-sql?view=sql-server-2017
									   ,sum(t_.FC_Vol) over (partition by t_.ItemNumber order by t_.FCDate_ Rows between 1 following and 3 following ) as CumulativeTotal_FC_Vol_Nxt3M	
									   ,avg(t_.FC_Vol) over (partition by t_.ItemNumber) as Avg_FC_Vol_Nxt8M			--- SQL2008 support this 
									 --  ,mm.PlannerNumber
						 				,case mm.PlannerNumber 
											when '20071' then 'Domenic Cellucci'		
											--when '20071' then 'Rosie Ashpole'
											when '20072' then 'Salman Saeed'
											when '20004' then 'Margaret Dost'	
											when '20005' then 'Imelda Chan'										  
											else 'Unknown'
										end as Owner_
									   ,mm.PrimarySupplier,mm.Description,mm.FamilyGroup_,mm.Family_0									   
							  from t_ left join JDE_DB_Alan.vw_Mast mm on t_.ItemNumber = mm.ItemNumber )				-- note that 'vw_Mast ' has clean data, also best to use Inner Join ( see below for reason )  - 23/7/2018
							 --  from t_ inner join JDE_DB_Alan.vw_Mast mm on t_.ItemNumber_f = mm.ItemNumber				-- Use inner join to filter out SKUs not showing up in HD using ML345 (HD), so SKUs against AWF will filter out ( like in CommonWealth Bank Proj - '7089895','709901' ) -- 23/7/2018 
							  -- where mm.StockingType not in ('O','U') 
								  where mm.StockingType in ('O','K','W','X','S','F','P','U','Q','Z','C','M','0','I')			
								--  where mm.StockingType in ('K','W','X','S','F','U','Q','Z','C','M','0','I')				   -- this could be best to avoid issue of returning empty dataSet due to Null value --- 23/7/2018
								            )
		 
					   select * from _t where _t.ItemNumber in ('42.210.031')
						--where _t.ItemNumber in ('45.103.000','45.200.100','42.210.031') 
						 -- where _t.ItemNumber in ('0751031003001H')
						 --order by _t.ItemNumber,_t.Date		 

				 ,com as ( select _t.ItemNumber,_t.Date d1,_t.FCDate_ d2,'FC_Qty' as DataType,_t.FC_Vol as Value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0 from _t
							   union all
							   select _t.ItemNumber,_t.Date d1,_t.FCDate_ d2,'PO_Qty' as DataType,_t.PO_Vol as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0 from _t
							  union all
							   select _t.ItemNumber,_t.Date d1,_t.FCDate_ d2,'SOH_Qty' as DataType,_t.SOH_Vol_ as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0 from _t
							  union all
								select _t.ItemNumber,_t.Date d1,_t.FCDate_ d2,'Start_Stk' as DataType,_t.Final_SOH_Begin_M_ as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0 from _t
							  union all
								select _t.ItemNumber,_t.Date d1,_t.FCDate_ d2,'End_Stk' as DataType,_t.SOH_End_M_ as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0 from _t
							  union all
								select _t.ItemNumber,_t.Date d1,_t.FCDate_ d2,'FC_Amt' as DataType,_t.FC_Amt as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0 from _t				   
                              union all
								select _t.ItemNumber,_t.Date d1,_t.FCDate_ d2,'Weeks_Cover1' as DataType,coalesce(_t.SOH_End_M_/nullif(_t.CumulativeTotal_FC_Vol_Nxt3M/12,0),0) as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0 from _t				  
							--  union all
							--	select _t.ItemNumber,_t.Date d1,_t.FCDate_ d2,'Weeks_Cover2' as DataType,(_t.SOH_End_M_)/(_t.Avg_FC_Vol_Nxt8M/4) as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0 from _t				  							  						  	 
							   )
             
				 select * from com 
					 --where com.Stk_Out_Stauts in ('Y')
					   -- where com.ItemNumber in ('45.103.000','45.200.100')
					--where com.ItemNumber in ('4152336048B')
				 	-- where com.ItemNumber in ( select splitdata from JDE_DB_Alan.dbo.fnSplitString(@Item_id,','))	
					  --where com.PrimarySupplier in ('20037','1102')
                    where com.ItemNumber in ('32.501.000','18.010.035','18.615.007','18.010.036','2780229000','82.391.909','32.379.200','18.013.089','24.7002.0001','24.7334.4459','24.7102.1858','24.7219.4459','32.455.155','24.7121.4459','24.7122.4459','24.7124.4459','24.7127.4459','24.5349.4459','24.7120.4459','24.7250.4459','24.7251.4459','24.7253.4459','24.7146.4459A','24.7207.4459','24.7168.4459A','24.7169.4459A','24.7163.0000A')  
					order by com.ItemNumber,com.DataType,com.d2
         		             


select * from JDE_DB_Alan.OpenPO p where p.ItemNumber in ('45.103.000')
exec JDE_DB_Alan.sp_Mismatch '45.103.000,27.252.713',null, DATEADD(mm, DATEDIFF(m,0,GETDATE())+5,0)
select DATEADD(mm, DATEDIFF(m,0,GETDATE())+5,0)
exec JDE_DB_Alan.sp_Mismatch '45.103.000,27.252.713',null, '2018-09-01 00:00:00 .000'
exec JDE_DB_Alan.sp_Mismatch '45.103.000,27.252.713',null,null
exec JDE_DB_Alan.sp_Mismatch_ '45.103.000','2018-09-01'   -- does not work
exec JDE_DB_Alan.sp_Mismatch @Item_id='45.103.000'      --  works but takes same amount of time to run whole table - takes 15'35''
exec JDE_DB_Alan.sp_Mismatch null, '2019-01-01'        --  works but takes same amount of time to run whole table - takes 16'06''         
exec JDE_DB_Alan.sp_Mismatch  --- need to put parameter for datetime otherwise will not run
exec JDE_DB_Alan.sp_Mismatch_  null,null, '2018-09-01 00:00:00'

-- below works --- Yeah 04/7/2018 !
exec JDE_DB_Alan.sp_Mismatch '2019-09-01'
exec JDE_DB_Alan.sp_Mismatch_Multi '38.002.001',null,'2019-09-01'
exec JDE_DB_Alan.sp_Mismatch_Multi null,'2140857','2019-09-01'
exec JDE_DB_Alan.sp_Mismatch_Multi null,'180704','2019-03-01 00:00:00'   -- does not work why ?
exec JDE_DB_Alan.sp_Mismatch_Multi null,null,'2019-09-02 00:00:00'			--- query all SKUs , yield 644,096 records in 33 seconds --- 26/10/2018

exec JDE_DB_Alan.sp_Mismatch_Multi  '34.523.000,34.522.000,34.521.000,34.519.000,34.514.000,34.515.000,34.516.000,34.520.000,34.513.000,34.517.000,34.518.000',null,'2019-03-03'
exec JDE_DB_Alan.sp_Mismatch_Multi  'F16174A949',null,'2019-03-03'
exec JDE_DB_Alan.sp_Mismatch_Multi '42.210.031',null,'2019-09-03'



exec JDE_DB_Alan.sp_Mismatch_Multi_V9 '42.210.031','2019-09-03',null,null							-- no 'Start_Fc-SavedDate' or 'End_Fc-SavedDate' - using default setting mean to using current month FC
exec JDE_DB_Alan.sp_Mismatch_Multi_V9 '42.210.031,24.7128.4462,38.001.001','2019-09-03','2018-09-28','2018-09-30 17:00:00'  -- has 'Start_Fc-SavedDate' or 'End_Fc-SavedDate' range, use FC saved during that range period


select m.ItemNumber,m.PrimarySupplier from JDE_DB_Alan.Master_ML345 m where m.PrimarySupplier like ('%180%')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('42.210.031')

----------------------------- Mismatch Report 12/7/2018  Version 2 ( Full Outer join ) 20/7/2018  ---------------------------------------------------



----------------------------- Mismatch Report 12/7/2018  Version 2-1 ( Full Outer join - Use date as 'Varchar' datatype ) 20/7/2018 ---------------------------------------------------
--- Good for simulation --- What if -- Before plug FC into System --- 23/7/2018
--- Good also for Production --- Need to design Code to plug MI into Production System as MI After Commercial Order is confirmed --- ( Step 1 to Merge MI Raw with Current FC , Step 2 to Upload Merged FC into FC Pro as MI upload file )

--use JDE_DB_Alan
--go

declare @mymi as table
( ItemID varchar(100) not null 
  ,myFcDate varchar(7) not null 
  --,myFcDate datetime not null
  ,myFcQty  decimal(18,2) not null 
  --,constraint primary key PK_myID (ItemID,FcDate)
  )
  
 Insert into @mymi ( ItemId,myFcDate,myFcQty)
 values 
 
--('18.010.035','20180901',193.8),
--('18.013.089','20180901',193.8),		   -- item has no sales history in last 12 months ( Ramler Proj), how about if SKU discontinued like 32.501.000 ?
--('32.501.000','20180901',150),			   -- item discontinued ( Ramler Proj / CommonWealth Bank Proj )
--('709901','20180901',250);				   -- item does not exists in ML345(HD), it is set up with AWF only ( CommonWealth Bank Proj)
 
('18.010.035','2018-09',193.8),
('18.013.089','2018-09',193.8),				-- item has no sales history in last 12 months ( Ramler Proj), how about if SKU discontinued like 32.501.000 ?
('32.501.000','2018-09',150),				-- item discontinued ( Ramler Proj / CommonWealth Bank Proj )
('709901','2018-09',250);					-- item does not exists in ML345(HD), it is set up with AWF only ( CommonWealth Bank Proj)

--('18.010.035','201809',193.8),
--('18.013.089','201809',193.8),				-- item has no sales history in last 12 months ( Ramler Proj), how about if SKU discontinued like 32.501.000 ?
--('32.501.000','201809',150),				-- item discontinued ( Ramler Proj / CommonWealth Bank Proj )
--('709901','201809',250);					-- item does not exists in ML345(HD), it is set up with AWF only ( CommonWealth Bank Proj)

  
--select * from @mymi

DECLARE @dt datetime
SET @dt = DATEADD(mm, DATEDIFF(m,0,GETDATE())+10,0)

--Declare @Item_id varchar(8000)
--SET @Item_id = '45.103.000,27.252.713'

			 --first sumarize PO by month ---     
;with         
		   po as (
					 select tb.ItemNumber,tb.DataType1,tb.PODate_,tb.poyr,tb.pomth,tb.BuyerName,tb.BuyerNumber,tb.TransactionOriginator,tb.TransactionOrigName,tb.SupplierName
							,sum(tb.PO_Volume) as PO_Vol
					    from JDE_DB_Alan.vw_OpenPO tb
					 -- where tb.ItemNumber in  ( select splitdata from JDE_DB_Alan.dbo.fnSplitString(@Item_id,','))	
					  group by tb.ItemNumber,tb.DataType1,tb.PODate_,tb.poyr,tb.pomth,tb.BuyerName,tb.BuyerNumber,tb.TransactionOriginator,tb.TransactionOrigName,tb.SupplierName

					  )
				--select * from po
			
			  -- FC --- updated 12/7/2018 to include MI in table variable ( Or Temp table)
			  ,fc_mas as ( select * from JDE_DB_Alan.vw_FC f 
						where f.ItemNumber in ('18.010.035','42.210.031')			-- deliberately choose 2 items in vw_FC, 1 is 18.010.035 which also exists in MI_orig table, 1 is 42.210.031 which does exist in Mi_orig table but exists in vw_FC master table to check what result it will yield after Join --- 25/7/2018
						     and f.Date < '2019-03-02'								-- choose small date range to return small data set for easy manupilation
						   )
              ,_fc as																		
				   ( select f_.ItemID,f_.myFcDate,f_.myFcQty,f.ItemNumber,f.Date,f.FCDate_,f.FC_Vol,convert(datetime,f_.myFcDate+'-01',111) as myDate
                     from fc_mas f full outer join @mymi f_ on f.ItemNumber = f_.ItemID and f.FCDate_ = f_.myFcDate
					  --select f_.ItemID,f_.myFcDate,f_.myFcQty,f.ItemNumber,f.Date,f.FCDate_,f.FC_Vol,f_.myFcDate as myDate
					 -- from fc_mas f full outer join @mymi f_ on f.ItemNumber = f_.ItemID and f.Date = f_.myFcDate
  
					 )
              -- select * from _fc
			 ,fc as																		
				   ( select f.ItemID,f.myFcDate,f.myFcQty,f.ItemNumber,f.Date,f.FCDate_,f.FC_Vol
				            ,case when f.myFcQty is null then f.FC_Vol
							      when f.myFcQty is not null then 
														case when f.FC_Vol is not null then f.FC_Vol+f.myFcQty
															 when f.FC_Vol is null then f.myFcQty
															 end
								   
							   end as  FC_Vol_f
							,case when f.ItemNumber is not null then f.ItemNumber
							      when f.ItemNumber is null then f.ItemID
							 end as ItemNumber_f
							,case when f.Date is not null then f.Date
							      when f.date is null then f.myDate
							 end as Date_f
							,case when f.FCDate_ is not null then f.FCDate_
							      when f.FCDate_ is null then f.myFcDate
							 end as FcDate_f
					  		  	        	   
                      from  _fc f 
                    -- from JDE_DB_Alan.vw_FC f full outer join @mymi f_ on f.ItemNumber = f_.ItemID and f.FCDate_ = f_.FcDate  
				    -- from JDE_DB_Alan.vw_FC f left join @mymi f_ on f.ItemNumber = f_.ItemID and f.FCDate_ = f_.FcDate 
					--  from  @mymi f_  left join JDE_DB_Alan.vw_FC f on f.ItemNumber = f_.ItemID and f.FCDate_ = f_.FcDate_Raw			--- not good causing big problems for SOH etc because on Mi raw table you only have 1 or 2 or 3 month, say if MI is for 2018-09 then you will not get SOH ( since SOH is always default to current month you are in ) and you need visibility for each month, YOU can use left join if you are not concerning SOH figure but in order to keep your code consistent, you should keep use full outer join and filter out on specific SKUs at end,this might best solution for this issue 25/7/2018 --- Will Use this lead to risk of lossing item has no sales history 18.013.089	--- No ???
					-- where f.ItemNumber in ( '42.210.031','24.7207.4459')
					     --  and f.Date < '2019-03-01'
                     --where f.ItemNumber in ('18.010.035')
					 )
              -- select distinct fc.ItemNumber from fc 
			  --select  * from fc  where fc.ItemID in ('18.013.089') or fc.ItemNumber in ('18.013.089')			--- note 18.013.089 has no existence in 'FVPRO_Fcst' table as there is no sales history over 12 month. Therefore when join table you will have unexpected result - be careful here in where condition be careful to which ItemNumber or ItemId you need to use. Also be careful using 'Not In ( )' conditional because if there is null value SQL will return empty dataset ! --- 20/7/2018
			  -- select * from fc

				,tb as 
					( select f.ItemNumber_f,f.FcDate_f,f.Date_f,f.FC_Vol_f as FC_Vol				-- will it cause issues if you rename 'f.FC_Vol_f' as 'FC_Vol' since you already have 'FC_Vol' column ?
						 -- select f.ItemNumber,f.Date,f.FCDate_,f.FC_Vol_f
							,isnull(p.PO_Vol,0) PO_Vol
							--,isnull(m.QtyOnHand,0) SOH_Vol
							,isnull(m.QtyOnHand,0) as SOH_Begin_M
							 ,0 as SOH_Vol				 
							--, isnull(m.QtyOnHand,0) as SOH_End_M
							,0 as SOH_End_M
							,m.WholeSalePrice
							 
					-- from JDE_DB_Alan.vw_FC f left join po p on f.ItemNumber = p.ItemNumber and f.FCDate_ = p.PODate_
					  from fc f left join po p on f.ItemNumber_f = p.ItemNumber and f.FcDate_f = p.PODate_
											left join JDE_DB_Alan.vw_Mast m on f.ItemNumber  = m.ItemNumber and f.FCDate_ = m.SOHDate   -- SOHDate is current month name,also note 'vw_Mast' is clearn without duplicated records
											  --left join JDE_DB_Alan.vw_Mast m on f.ItemNumber_f  = m.ItemNumber
					 where f.Date_f< @dt							--- be careful if you have null value resulting from pervious step in join -- you will miss value --- 20/7/2018
					 -- where f.Date < '2018-10-01'
						  -- and f.ItemNumber in ('45.103.000')
								 )
								 						
			   --select * from tb order by tb.ItemNumber_f,tb.FCDate_f
				  ,tb_ as (
							select tb.ItemNumber_f,tb.Date_f,tb.FCDate_f,tb.FC_Vol,tb.PO_Vol,tb.SOH_Vol 
									,case 
										   when tb.Date_f >DATEADD(mm, DATEDIFF(m,0,GETDATE()),0)  then (tb.PO_Vol -tb.FC_Vol)
										   when tb.Date_f = DATEADD(mm, DATEDIFF(m,0,GETDATE()),0) then (tb.PO_Vol -tb.FC_Vol + tb.SOH_Begin_M)
										   else tb.SOH_Vol
										  end as  SOH_Vol_
								  -- ,(tb.PO_Vol -tb.FC_Vol) as SOH_Vol_
								   ,tb.SOH_Begin_M,tb.SOH_End_M
								   ,tb.WholeSalePrice					  
							from tb				
							)  
				 --select * from tb_
						   --- running total preparation ---      
				   ,tbl as ( select *,
									row_number() over ( partition by tb_.itemNumber_f order by tb_.FCDate_f ) as rnk 
								from tb_      
                
							)
							--- running total To get End period inventory ---
				 ,tbl_ as 
						(	select *
								  ,sum(tbl.SOH_Vol_) over (partition by tbl.ItemNumber_f order by tbl.rnk ) as SOH_End_M_
								from tbl
						 )
      
				  --select * from tbl_
							--- Beginning period inventory preparation ---
				  ,stk_beg as
						  ( select tbl_.ItemNumber_f as myItemNumber,tbl_.FcDate_f as myDate
									,DATEADD(mm, DATEDIFF(m,0,tbl_.Date_f)+1,0) dte
									,tbl_.SOH_End_M_ as mySOH_Begin_M_
			            
							 from tbl_)
					   --select * from stk_beg

				 ,t as ( select *
								 from tbl_ left join stk_beg on tbl_.ItemNumber_f = stk_beg.myItemNumber and tbl_.Date_f = stk_beg.dte 
							  )
					--  select * from t
							  --- Get Begining period inventory ---
				 ,t_ as ( select t.ItemNumber_f,t.Date_f,t.FCDate_f,t.FC_Vol,t.PO_Vol,t.SOH_Vol,t.SOH_Vol_
									,case 
											when t.mySOH_Begin_M_ is null then t.SOH_Begin_M
											else t.mySOH_Begin_M_
									  end as  Final_SOH_Begin_M_
									,t.SOH_End_M_,t.rnk
									,t.WholeSalePrice
									--,t.myWSP
								 from t
								 )

					 -- select * from t_
					  -- ,pri as ( select t_.ItemNumber,t_.WholeSalePrice from t_ where t_.WholeSalePrice is not null)

					 --  select * from pri
					--   ,_t as ( select t_.*,																			-- cost too long time to run
								   --       case when t_.WholeSalePrice is null then pri.WholeSalePrice
											 --   else t_.WholeSalePrice
										  --  end as mywholesaleprice
									--from t_ left join pri on t_.ItemNumber = pri.ItemNumber )
          
				  ,_t as ( --select t_.ItemNumber,t_.Date,t_.FCDate_,t_.FC_Vol,t_.PO_Vol,t_.SOH_Vol,t_.SOH_Vol_,t_.Final_SOH_Begin_M_,t_.SOH_End_M_,m.WholeSalePrice     -- will spit out column by column saves the performance issue ? Not really  -- 14/5/2018
								select t_.*
										, mm.WholeSalePrice as Mywholesaleprice
										,(mm.WholeSalePrice * t_.FC_Vol) FC_Amt
									   , case when t_.Final_SOH_Begin_M_ <= 0  then 'Y 'else 'N' end as Stk_Out_Stauts
									   ,sum(t_.FC_Vol) over (partition by t_.ItemNumber_f order by t_.FCDate_f Rows between current row and 2 following ) as CumulativeTotal_FC_Vol_3M			-- only works in SQL 2012 upwards, if you using 2008 need to use below...  https://docs.microsoft.com/en-us/sql/t-sql/queries/select-over-clause-transact-sql?view=sql-server-2017
									   ,sum(t_.FC_Vol) over (partition by t_.ItemNumber_f order by t_.FCDate_f Rows between 1 following and 3 following ) as CumulativeTotal_FC_Vol_Nxt3M	
									   ,avg(t_.FC_Vol) over (partition by t_.ItemNumber_f) as Avg_FC_Vol_Nxt8M			--- SQL2008 support this 
									   ,mm.PlannerNumber
						 				,case mm.PlannerNumber 
											when '20071' then 'Domenic Cellucci'		
											--when '20071' then 'Rosie Ashpole'
											when '20072' then 'Salman Saeed'
											when '20004' then 'Margaret Dost'	
											when '20005' then 'Imelda Chan'										  
											else 'Unknown'
										end as Owner_
									   ,mm.PrimarySupplier,mm.Description,mm.FamilyGroup_,mm.Family_0,mm.Leadtime_Mth									   
								--from t_ left join JDE_DB_Alan.vw_Mast mm on t_.ItemNumber_f = mm.ItemNumber	)				-- note that 'vw_Mast ' has clean data, also best to use Inner Join ( see below for reason )  - 23/7/2018
								  from t_ inner join JDE_DB_Alan.vw_Mast mm on t_.ItemNumber_f = mm.ItemNumber					-- Use inner join to filter out SKUs not showing up in HD using ML345 (HD), so SKUs against AWF will filter out ( like in CommonWealth Bank Proj - '7089895','709901' ) -- 23/7/2018 
								  where mm.StockingType not in ('O','U') 
								--  where mm.StockingType in ('O','K','W','X','S','F','P','U','Q','Z','C','M','0','I')			
								--  where mm.StockingType in ('K','W','X','S','F','U','Q','Z','C','M','0','I')				   -- this could be best to avoid issue of returning empty dataSet due to Null value --- 23/7/2018
											)		
		 
					  -- select * from _t
						--where _t.ItemNumber in ('45.103.000','45.200.100','42.210.031') 
						 -- where _t.ItemNumber in ('0751031003001H')
						 --order by _t.ItemNumber,_t.Date	
						 	 
					--select _t.ItemNumber_f,_t.Date_f d1,_t.FCDate_f d2,'Start_Stk' as DataType,_t.Final_SOH_Begin_M_ as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.Leadtime_Mth,_t.PlannerNumber from _t

				 ,com as ( select _t.ItemNumber_f,_t.Date_f d1,_t.FCDate_f d2,'FC_Qty' as DataType,_t.FC_Vol as Value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.Leadtime_Mth,_t.PlannerNumber from _t
							   union all
							   select _t.ItemNumber_f,_t.Date_f d1,_t.FCDate_f d2,'PO_Qty' as DataType,_t.PO_Vol as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.Leadtime_Mth,_t.PlannerNumber from _t
							  union all
							   select _t.ItemNumber_f,_t.Date_f d1,_t.FCDate_f d2,'SOH_Qty' as DataType,_t.SOH_Vol_ as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.Leadtime_Mth,_t.PlannerNumber from _t
							  
							  union all
								select _t.ItemNumber_f,_t.Date_f d1,_t.FCDate_f d2,'Start_Stk' as DataType,_t.Final_SOH_Begin_M_ as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.Leadtime_Mth,_t.PlannerNumber from _t
							  union all
								select _t.ItemNumber_f,_t.Date_f d1,_t.FCDate_f d2,'End_Stk' as DataType,_t.SOH_End_M_ as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.Leadtime_Mth,_t.PlannerNumber from _t
							  union all
								select _t.ItemNumber_f,_t.Date_f d1,_t.FCDate_f d2,'FC_Amt' as DataType,_t.FC_Amt as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.Leadtime_Mth,_t.PlannerNumber from _t				   
                              union all
								select _t.ItemNumber_f,_t.Date_f d1,_t.FCDate_f d2,'Weeks_Cover1' as DataType,coalesce(_t.SOH_End_M_/nullif(_t.CumulativeTotal_FC_Vol_Nxt3M/12,0),0) as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.Leadtime_Mth,_t.PlannerNumber from _t				  
							--  union all
							--	select _t.ItemNumber,_t.Date d1,_t.FCDate_ d2,'Weeks_Cover2' as DataType,(_t.SOH_End_M_)/(_t.Avg_FC_Vol_Nxt8M/4) as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0 from _t				  							  						  	 
							   )
             
				 select * from com 
					 --where com.Stk_Out_Stauts in ('Y')
					   -- where com.ItemNumber in ('45.103.000','45.200.100')
					--where com.ItemNumber in ('4152336048B')
				 	-- where com.ItemNumber in ( select splitdata from JDE_DB_Alan.dbo.fnSplitString(@Item_id,','))	
					  --where com.PrimarySupplier in ('20037','1102')
                    --where com.ItemNumber in ('32.501.000','18.010.035','18.615.007','18.010.036','2780229000','82.391.909','32.379.200','18.013.089','24.7002.0001','24.7334.4459','24.7102.1858','24.7219.4459','32.455.155','24.7121.4459','24.7122.4459','24.7124.4459','24.7127.4459','24.5349.4459','24.7120.4459','24.7250.4459','24.7251.4459','24.7253.4459','24.7146.4459A','24.7207.4459','24.7168.4459A','24.7169.4459A','24.7163.0000A')  
					--  where com.ItemNumber in ('24.7218.4465','32.501.000','43.211.004','32.379.200','32.380.855','18.607.016','24.7201.0000','24.7102.7052','24.7102.7052','32.455.465','24.7115.0952A','24.7114.0952A','24.7128.0952','709895','24.7353.0000A','24.7136.0155A','709901','24.7120.0952')
					-- where com.ItemNumber in ('32.501.000','18.010.035','18.615.007','18.010.036','2780229000','82.391.909','32.379.200','18.013.089','24.7002.0001','24.7334.4459','24.7102.1858','24.7219.4459','32.455.155','24.7121.4459','24.7122.4459','24.7124.4459','24.7127.4459','24.5349.4459','24.7120.4459','24.7250.4459','24.7251.4459','24.7253.4459','24.7146.4459A','24.7207.4459','24.7168.4459A','24.7169.4459A','24.7163.0000A')
					-- where com.ItemNumber in ('42.210.031')
					--where com.ItemNumber_f in ('18.013.089')
					order by com.ItemNumber_f,com.DataType,com.d2

--------------------------End of Mismatch Version 2-1 -------------------------------------------------



----------------------------- Mismatch Report 12/7/2018  Version 2-2 ( Full Outer join - Use date as 'datetime' datatype ) 20/7/2018 ---------------------------------------------------
--- Good for simulation --- What if -- Before plug FC into System --- 23/7/2018
--- Good also for Production --- Need to design Code to plug MI into Production System as MI After Commercial Order is confirmed --- ( Step 1 to Merge MI Raw with Current FC , Step 2 to Upload Merged FC into FC Pro as MI upload file )

--use JDE_DB_Alan
--go

declare @mymi as table
( ItemID varchar(100) not null 
  --,myFcDate varchar(7) not null 
  ,myDate datetime not null
  ,myFcQty  decimal(18,2) not null 
  --,constraint primary key PK_myID (ItemID,FcDate)
  )
  
 Insert into @mymi ( ItemId,myDate,myFcQty)
 values 
 
('18.010.035','20180901',193.8),
('18.013.089','20180901',193.8),		   -- item has no sales history in last 12 months ( Ramler Proj), how about if SKU discontinued like 32.501.000 ?
('32.501.000','20180901',150),			   -- item discontinued ( Ramler Proj / CommonWealth Bank Proj )
('709901','20180901',250);				   -- item does not exists in ML345(HD), it is set up with AWF only ( CommonWealth Bank Proj)

 
--('18.010.035','2018-09',193.8),
--('18.013.089','2018-09',193.8),				-- item has no sales history in last 12 months ( Ramler Proj), how about if SKU discontinued like 32.501.000 ?
--('32.501.000','2018-09',150),				-- item discontinued ( Ramler Proj / CommonWealth Bank Proj )
--('709901','2018-09',250);					-- item does not exists in ML345(HD), it is set up with AWF only ( CommonWealth Bank Proj)

--('18.010.035','201809',193.8),
--('18.013.089','201809',193.8),				-- item has no sales history in last 12 months ( Ramler Proj), how about if SKU discontinued like 32.501.000 ?
--('32.501.000','201809',150),				-- item discontinued ( Ramler Proj / CommonWealth Bank Proj )
--('709901','201809',250);					-- item does not exists in ML345(HD), it is set up with AWF only ( CommonWealth Bank Proj)
  
--select * from @mymi

DECLARE @dt datetime
SET @dt = DATEADD(mm, DATEDIFF(m,0,GETDATE())+12,0)

--Declare @Item_id varchar(8000)
--SET @Item_id = '45.103.000,27.252.713'

			 --first sumarize PO by month ---     
;with         
		   po as (
					 select tb.ItemNumber,tb.DataType1,tb.PODate_,tb.poyr,tb.pomth,tb.BuyerName,tb.BuyerNumber,tb.TransactionOriginator,tb.TransactionOrigName,tb.SupplierName
							,sum(tb.PO_Volume) as PO_Vol
					    from JDE_DB_Alan.vw_OpenPO tb
					 -- where tb.ItemNumber in  ( select splitdata from JDE_DB_Alan.dbo.fnSplitString(@Item_id,','))	
					  group by tb.ItemNumber,tb.DataType1,tb.PODate_,tb.poyr,tb.pomth,tb.BuyerName,tb.BuyerNumber,tb.TransactionOriginator,tb.TransactionOrigName,tb.SupplierName

					  )
				--select * from po
			
			  -- FC --- updated 12/7/2018 to include MI in table variable ( Or Temp table)
			  ,fc_mas as ( select * from JDE_DB_Alan.vw_FC f 
						where f.ItemNumber in ('18.010.035','42.210.031')			-- deliberately choose 2 items in vw_FC, 1 is 18.010.035 which also exists in MI_orig table, 1 is 42.210.031 which does exist in Mi_orig table but exists in vw_FC master table to check what result it will yield after Join --- 25/7/2018
						     and f.Date < '2019-03-02'								-- choose small date range to return small data set for easy manupilation
						   )
              ,_fc as																		
				   ( --select f_.ItemID,f_.myFcDate,f_.myFcQty,f.ItemNumber,f.Date,f.FCDate_,f.FC_Vol,convert(datetime,f_.myFcDate+'-01',111) as myDate
                      --from fc_mas f full outer join @mymi f_ on f.ItemNumber = f_.ItemID and f.FCDate_ = f_.myFcDate
					  select f_.ItemID,f_.myDate,f_.myFcQty,f.ItemNumber,f.Date,f.FCDate_,f.FC_Vol
								,convert(varchar(7),f_.myDate,120) as myFcDate								
					  from fc_mas f full outer join @mymi f_ on f.ItemNumber = f_.ItemID and f.Date = f_.myDate
						--from fc_mas f full outer join JDE_DB_Alan.FCPRO_MI_orig f_ on f.ItemNumber = f_.ItemID and f.Date = f_.Date							

					 )
               --select * from _fc
			 ,fc as																		
				   ( select f.ItemID,f.myFcDate,f.myFcQty,f.ItemNumber,f.Date,f.FCDate_,f.FC_Vol
				            ,case when f.myFcQty is null then f.FC_Vol												-- if Item doest not exists in MI raw but exists in vw_FC master					
							      when f.myFcQty is not null then													-- if Item exists in MI raw, see if it exists in vw_FC master,if do, combine two fc together			
														case when f.FC_Vol is not null then f.FC_Vol+f.myFcQty		-- if Item exists in MI raw, see if it exists in vw_FC master,if do not, then use Mi Raw ( it could be Item with no 12 mth sales history, item discontinued, or item belongs to AWF )
															 when f.FC_Vol is null then f.myFcQty
															 end
								   
							   end as  FC_Vol_f
							,case when f.ItemNumber is not null then f.ItemNumber
							      when f.ItemNumber is null then f.ItemID
							 end as ItemNumber_f
							,case when f.Date is not null then f.Date
							      when f.date is null then f.myDate
							 end as Date_f
							,case when f.FCDate_ is not null then f.FCDate_
							      when f.FCDate_ is null then f.myFcDate
							 end as FcDate_f
					  		  	        	   
                      from  _fc f 
                    -- from JDE_DB_Alan.vw_FC f full outer join @mymi f_ on f.ItemNumber = f_.ItemID and f.FCDate_ = f_.FcDate  
				    -- from JDE_DB_Alan.vw_FC f left join @mymi f_ on f.ItemNumber = f_.ItemID and f.FCDate_ = f_.FcDate 
					--  from  @mymi f_  left join JDE_DB_Alan.vw_FC f on f.ItemNumber = f_.ItemID and f.FCDate_ = f_.FcDate_Raw			--- not good causing big problems for SOH etc because on Mi raw table you only have 1 or 2 or 3 month, say if MI is for 2018-09 then you will not get SOH ( since SOH is always default to current month you are in ) and you need visibility for each month, YOU can use left join if you are not concerning SOH figure but in order to keep your code consistent, you should keep use full outer join and filter out on specific SKUs at end,this might best solution for this issue 25/7/2018 --- Will Use this lead to risk of lossing item has no sales history 18.013.089	--- No ???
					-- where f.ItemNumber in ( '42.210.031','24.7207.4459')
					     --  and f.Date < '2019-03-01'
                     --where f.ItemNumber in ('18.010.035')
					 )

              -- select distinct fc.ItemNumber from fc 
			  --select  * from fc  where fc.ItemID in ('18.013.089') or fc.ItemNumber in ('18.013.089')			--- note 18.013.089 has no existence in 'FVPRO_Fcst' table as there is no sales history over 12 month. Therefore when join table you will have unexpected result - be careful here in where condition be careful to which ItemNumber or ItemId you need to use. Also be careful using 'Not In ( )' conditional because if there is null value SQL will return empty dataset ! --- 20/7/2018
			  -- select * from fc

				,tb as 
					( select f.ItemNumber_f,f.FcDate_f,f.Date_f,f.FC_Vol_f as FC_Vol				-- will it cause issues if you rename 'f.FC_Vol_f' as 'FC_Vol' since you already have 'FC_Vol' column ?
						 -- select f.ItemNumber,f.Date,f.FCDate_,f.FC_Vol_f
							,isnull(p.PO_Vol,0) PO_Vol
							--,isnull(m.QtyOnHand,0) SOH_Vol
							,isnull(m.QtyOnHand,0) as SOH_Begin_M
							 ,0 as SOH_Vol				 
							--, isnull(m.QtyOnHand,0) as SOH_End_M
							,0 as SOH_End_M
							,m.WholeSalePrice							
							 
					-- from JDE_DB_Alan.vw_FC f left join po p on f.ItemNumber = p.ItemNumber and f.FCDate_ = p.PODate_
					  from fc f left join po p on f.ItemNumber_f = p.ItemNumber and f.FcDate_f = p.PODate_
											left join JDE_DB_Alan.vw_Mast m on f.ItemNumber  = m.ItemNumber and f.FCDate_ = m.SOHDate   -- SOHDate is current month name,also note 'vw_Mast' is clearn without duplicated records
											  --left join JDE_DB_Alan.vw_Mast m on f.ItemNumber_f  = m.ItemNumber
					 where f.Date_f< @dt							--- be careful if you have null value resulting from pervious step in join -- you will miss value --- 20/7/2018
					 -- where f.Date < '2018-10-01'
						  -- and f.ItemNumber in ('45.103.000')
								 )
								 						
			   --select * from tb order by tb.ItemNumber_f,tb.FCDate_f
				  ,tb_ as (
							select tb.ItemNumber_f,tb.Date_f,tb.FCDate_f,tb.FC_Vol,tb.PO_Vol,tb.SOH_Vol 
									,case 
										   when tb.Date_f >DATEADD(mm, DATEDIFF(m,0,GETDATE()),0)  then (tb.PO_Vol -tb.FC_Vol)
										   when tb.Date_f = DATEADD(mm, DATEDIFF(m,0,GETDATE()),0) then (tb.PO_Vol -tb.FC_Vol + tb.SOH_Begin_M)
										   else tb.SOH_Vol
										  end as  SOH_Vol_
								  -- ,(tb.PO_Vol -tb.FC_Vol) as SOH_Vol_
								   ,tb.SOH_Begin_M,tb.SOH_End_M
								   ,tb.WholeSalePrice					  
							from tb				
							)  
				 --select * from tb_
						   --- running total preparation ---      
				   ,tbl as ( select *,
									row_number() over ( partition by tb_.itemNumber_f order by tb_.FCDate_f ) as rnk 
								from tb_      
                
							)
							--- running total To get End period inventory ---
				 ,tbl_ as 
						(	select *
								  ,sum(tbl.SOH_Vol_) over (partition by tbl.ItemNumber_f order by tbl.rnk ) as SOH_End_M_
								from tbl
						 )
      
				  --select * from tbl_
							--- Beginning period inventory preparation ---
				  ,stk_beg as
						  ( select tbl_.ItemNumber_f as myItemNumber,tbl_.FcDate_f as myDate
									,DATEADD(mm, DATEDIFF(m,0,tbl_.Date_f)+1,0) dte
									,tbl_.SOH_End_M_ as mySOH_Begin_M_
			            
							 from tbl_)
					   --select * from stk_beg

				 ,t as ( select *
								 from tbl_ left join stk_beg on tbl_.ItemNumber_f = stk_beg.myItemNumber and tbl_.Date_f = stk_beg.dte 
							  )
					--  select * from t
							  --- Get Begining period inventory ---
				 ,t_ as ( select t.ItemNumber_f,t.Date_f,t.FCDate_f,t.FC_Vol,t.PO_Vol,t.SOH_Vol,t.SOH_Vol_
									,case 
											when t.mySOH_Begin_M_ is null then t.SOH_Begin_M
											else t.mySOH_Begin_M_
									  end as  Final_SOH_Begin_M_
									,t.SOH_End_M_,t.rnk
									,t.WholeSalePrice
									--,t.myWSP
									,replace(convert(varchar(8), DATEADD(mm, DATEDIFF(m,0,t.Date_f),0),126),'-','') as Date_f_2
								 from t
								 )

					 -- select * from t_
					  -- ,pri as ( select t_.ItemNumber,t_.WholeSalePrice from t_ where t_.WholeSalePrice is not null)

					 --  select * from pri
					--   ,_t as ( select t_.*,																			-- cost too long time to run
								   --       case when t_.WholeSalePrice is null then pri.WholeSalePrice
											 --   else t_.WholeSalePrice
										  --  end as mywholesaleprice
									--from t_ left join pri on t_.ItemNumber = pri.ItemNumber )
          
				  ,_t as ( --select t_.ItemNumber,t_.Date,t_.FCDate_,t_.FC_Vol,t_.PO_Vol,t_.SOH_Vol,t_.SOH_Vol_,t_.Final_SOH_Begin_M_,t_.SOH_End_M_,m.WholeSalePrice     -- will spit out column by column saves the performance issue ? Not really  -- 14/5/2018
								select t_.*
										, mm.WholeSalePrice as Mywholesaleprice
										,(mm.WholeSalePrice * t_.FC_Vol) FC_Amt
									   , case when t_.Final_SOH_Begin_M_ <= 0  then 'Y 'else 'N' end as Stk_Out_Stauts
									   ,sum(t_.FC_Vol) over (partition by t_.ItemNumber_f order by t_.FCDate_f Rows between current row and 2 following ) as CumulativeTotal_FC_Vol_3M			-- only works in SQL 2012 upwards, if you using 2008 need to use below...  https://docs.microsoft.com/en-us/sql/t-sql/queries/select-over-clause-transact-sql?view=sql-server-2017
									   ,sum(t_.FC_Vol) over (partition by t_.ItemNumber_f order by t_.FCDate_f Rows between 1 following and 3 following ) as CumulativeTotal_FC_Vol_Nxt3M	
									   ,avg(t_.FC_Vol) over (partition by t_.ItemNumber_f) as Avg_FC_Vol_Nxt8M			--- SQL2008 support this 
									   ,mm.PlannerNumber
						 				,case mm.PlannerNumber 
											when '20071' then 'Domenic Cellucci'		
											--when '20071' then 'Rosie Ashpole'
											when '20072' then 'Salman Saeed'
											when '20004' then 'Margaret Dost'	
											when '20005' then 'Imelda Chan'										  
											else 'Unknown'
										end as Owner_
									   ,mm.PrimarySupplier,mm.Description,mm.FamilyGroup_,mm.Family_0,mm.Leadtime_Mth									   
								--from t_ left join JDE_DB_Alan.vw_Mast mm on t_.ItemNumber_f = mm.ItemNumber	)				-- note that 'vw_Mast ' has clean data, also best to use Inner Join ( see below for reason )  - 23/7/2018
								  from t_ inner join JDE_DB_Alan.vw_Mast mm on t_.ItemNumber_f = mm.ItemNumber					-- Use inner join to filter out SKUs not showing up in HD using ML345 (HD), so SKUs against AWF will filter out ( like in CommonWealth Bank Proj - '7089895','709901' ) -- 23/7/2018 
								  where mm.StockingType not in ('O','U') 
								--  where mm.StockingType in ('O','K','W','X','S','F','P','U','Q','Z','C','M','0','I')			
								--  where mm.StockingType in ('K','W','X','S','F','U','Q','Z','C','M','0','I')				   -- this could be best to avoid issue of returning empty dataSet due to Null value --- 23/7/2018
											)		
		 
					 -- select * from _t
						--where _t.ItemNumber in ('45.103.000','45.200.100','42.210.031') 
						 -- where _t.ItemNumber in ('0751031003001H')
						 --order by _t.ItemNumber,_t.Date	
						 	 
					--select _t.ItemNumber_f,_t.Date_f d1,_t.FCDate_f d2,'Start_Stk' as DataType,_t.Final_SOH_Begin_M_ as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.Leadtime_Mth,_t.PlannerNumber from _t

				 ,com as ( select _t.ItemNumber_f,_t.Date_f d1,_t.Date_f_2 d3,_t.FCDate_f d2,'FC_Qty' as DataType,_t.FC_Vol as Value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.Leadtime_Mth,_t.PlannerNumber from _t
							   union all
							   select _t.ItemNumber_f,_t.Date_f d1,_t.Date_f_2 d3,_t.FCDate_f d2,'PO_Qty' as DataType,_t.PO_Vol as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.Leadtime_Mth,_t.PlannerNumber from _t
							  union all
							   select _t.ItemNumber_f,_t.Date_f d1,_t.Date_f_2 d3,_t.FCDate_f d2,'SOH_Qty' as DataType,_t.SOH_Vol_ as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.Leadtime_Mth,_t.PlannerNumber from _t
							  
							  union all
								select _t.ItemNumber_f,_t.Date_f d1,_t.Date_f_2 d3,_t.FCDate_f d2,'Start_Stk' as DataType,_t.Final_SOH_Begin_M_ as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.Leadtime_Mth,_t.PlannerNumber from _t
							  union all
								select _t.ItemNumber_f,_t.Date_f d1,_t.Date_f_2 d3,_t.FCDate_f d2,'End_Stk' as DataType,_t.SOH_End_M_ as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.Leadtime_Mth,_t.PlannerNumber from _t
							  union all
								select _t.ItemNumber_f,_t.Date_f d1,_t.Date_f_2 d3,_t.FCDate_f d2,'FC_Amt' as DataType,_t.FC_Amt as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.Leadtime_Mth,_t.PlannerNumber from _t				   
                              union all
								select _t.ItemNumber_f,_t.Date_f d1,_t.Date_f_2 d3,_t.FCDate_f d2,'Weeks_Cover1' as DataType,coalesce(_t.SOH_End_M_/nullif(_t.CumulativeTotal_FC_Vol_Nxt3M/12,0),0) as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.Leadtime_Mth,_t.PlannerNumber from _t				  
							--  union all
							--	select _t.ItemNumber,_t.Date d1,_t.FCDate_ d2,'Weeks_Cover2' as DataType,(_t.SOH_End_M_)/(_t.Avg_FC_Vol_Nxt8M/4) as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0 from _t				  							  						  	 
							   )
             
				 ,fcst as 
					 (select * from com 
						 --where com.Stk_Out_Stauts in ('Y')
						   -- where com.ItemNumber in ('45.103.000','45.200.100')
						--where com.ItemNumber in ('4152336048B')
				 		-- where com.ItemNumber in ( select splitdata from JDE_DB_Alan.dbo.fnSplitString(@Item_id,','))	
						  --where com.PrimarySupplier in ('20037','1102')
						--where com.ItemNumber in ('32.501.000','18.010.035','18.615.007','18.010.036','2780229000','82.391.909','32.379.200','18.013.089','24.7002.0001','24.7334.4459','24.7102.1858','24.7219.4459','32.455.155','24.7121.4459','24.7122.4459','24.7124.4459','24.7127.4459','24.5349.4459','24.7120.4459','24.7250.4459','24.7251.4459','24.7253.4459','24.7146.4459A','24.7207.4459','24.7168.4459A','24.7169.4459A','24.7163.0000A')  
						--  where com.ItemNumber in ('24.7218.4465','32.501.000','43.211.004','32.379.200','32.380.855','18.607.016','24.7201.0000','24.7102.7052','24.7102.7052','32.455.465','24.7115.0952A','24.7114.0952A','24.7128.0952','709895','24.7353.0000A','24.7136.0155A','709901','24.7120.0952')
						-- where com.ItemNumber in ('32.501.000','18.010.035','18.615.007','18.010.036','2780229000','82.391.909','32.379.200','18.013.089','24.7002.0001','24.7334.4459','24.7102.1858','24.7219.4459','32.455.155','24.7121.4459','24.7122.4459','24.7124.4459','24.7127.4459','24.5349.4459','24.7120.4459','24.7250.4459','24.7251.4459','24.7253.4459','24.7146.4459A','24.7207.4459','24.7168.4459A','24.7169.4459A','24.7163.0000A')
						-- where com.ItemNumber in ('42.210.031')
						--where com.ItemNumber_f in ('18.013.089')
						where com.DataType in ('FC_Qty')
						and com.ItemNumber_f in (select o.ItemID from JDE_DB_Alan.FCPRO_MI_orig o)				-- pick up item only appearing in Mi_orig table, if you omit this clause, you can pick up all items both in Mi_orig and vw_FC table   --- 25/7/2018
																												    -- better to do filter here to avoid performance bottleneck in following Pivot function 
						--order by com.ItemNumber_f,com.DataType,com.d2
					       )
 
                 -- select * from fcst
                
				, mypvt as 
					( select *
						 from 
								( select f.ItemNumber_f,f.d3,f.Value  from fcst f  ) as sourcetb
                         pivot 
						       ( sum(value) for d3 in ( [201807],[201808],[201809],[201810],[201811],[201812],[201901],[201902]) 
								) as p

								
					)

		       	select pv.ItemNumber_f
					   ,isnull(pv.[201807],0) [201807]
					   ,isnull(pv.[201808],0) [201808]
					   ,isnull(pv.[201809],0) [201809]
					   ,isnull(pv.[201810],0) [201810]
					   ,isnull(pv.[201811],0) [201811]
					   ,isnull(pv.[201812],0) [201812]
					   ,isnull(pv.[201901],0) [201901]
					   ,isnull(pv.[201902],0) [201902]			   	
				 from mypvt pv


------------------------ End of  Mismatch Report 12/7/2018  Version 2-2 ----------------------



----------------------------- Mismatch Report  Version -sp ( store procedure) - ( Full Outer join - Use date as 'datetime' datatype ) 25/7/2018 ---------------------------------------------------
--- Good for simulation --- What if -- Before plug FC into System --- 23/7/2018
--- Good also for Production --- Need to design Code to plug MI into Production System as MI After Commercial Order is confirmed --- ( Step 1 to Merge MI Raw with Current FC , Step 2 to Upload Merged FC into FC Pro as MI upload file )

--use JDE_DB_Alan
--go

declare @mymi as table
( ItemID varchar(100) not null 
  --,myFcDate varchar(7) not null 
  ,myDate datetime not null
  ,myFcQty  decimal(18,2) not null 
  --,constraint primary key PK_myID (ItemID,FcDate)
  )
  
 Insert into @mymi ( ItemId,myDate,myFcQty)
 values 
 
('18.010.035','20180901',193.8),
('18.013.089','20180901',193.8),		   -- item has no sales history in last 12 months ( Ramler Proj), how about if SKU discontinued like 32.501.000 ?
('32.501.000','20180901',150),			   -- item discontinued ( Ramler Proj / CommonWealth Bank Proj )
('709901','20180901',250);				   -- item does not exists in ML345(HD), it is set up with AWF only ( CommonWealth Bank Proj)

 
--('18.010.035','2018-09',193.8),
--('18.013.089','2018-09',193.8),				-- item has no sales history in last 12 months ( Ramler Proj), how about if SKU discontinued like 32.501.000 ?
--('32.501.000','2018-09',150),				-- item discontinued ( Ramler Proj / CommonWealth Bank Proj )
--('709901','2018-09',250);					-- item does not exists in ML345(HD), it is set up with AWF only ( CommonWealth Bank Proj)

--('18.010.035','201809',193.8),
--('18.013.089','201809',193.8),				-- item has no sales history in last 12 months ( Ramler Proj), how about if SKU discontinued like 32.501.000 ?
--('32.501.000','201809',150),				-- item discontinued ( Ramler Proj / CommonWealth Bank Proj )
--('709901','201809',250);					-- item does not exists in ML345(HD), it is set up with AWF only ( CommonWealth Bank Proj)

  
--select * from @mymi

DECLARE @dt datetime
SET @dt = DATEADD(mm, DATEDIFF(m,0,GETDATE())+12,0)

--Declare @Item_id varchar(8000)
--SET @Item_id = '45.103.000,27.252.713'

			 --first sumarize PO by month ---     
        
       ;with  po as (
					 select tb.ItemNumber,tb.DataType1,tb.PODate_,tb.poyr,tb.pomth,tb.BuyerName,tb.BuyerNumber,tb.TransactionOriginator,tb.TransactionOrigName,tb.SupplierName
							,sum(tb.PO_Volume) as PO_Vol
					    from JDE_DB_Alan.vw_OpenPO tb
					 -- where tb.ItemNumber in  ( select splitdata from JDE_DB_Alan.dbo.fnSplitString(@Item_id,','))	
					  group by tb.ItemNumber,tb.DataType1,tb.PODate_,tb.poyr,tb.pomth,tb.BuyerName,tb.BuyerNumber,tb.TransactionOriginator,tb.TransactionOrigName,tb.SupplierName

					  )
				--select * from po
			
			  -- FC --- updated 12/7/2018 to include MI in table variable ( Or Temp table)
			  ,fc_mas as ( select * from JDE_DB_Alan.vw_FC f 
						 where f.ItemNumber in ('18.010.035','42.210.031')			-- deliberately choose 2 items in vw_FC, 1 is 18.010.035 which also exists in MI_orig table, 1 is 42.210.031 which does exist in Mi_orig table but exists in vw_FC master table to check what result it will yield after Join --- 25/7/2018
						     and f.Date < '2019-03-02'								-- choose small date range to return small data set for easy manupilation
						   )
              ,_fc as																		
				   ( --select f_.ItemID,f_.myFcDate,f_.myFcQty,f.ItemNumber,f.Date,f.FCDate_,f.FC_Vol,convert(datetime,f_.myFcDate+'-01',111) as myDate
                      --from fc_mas f full outer join @mymi f_ on f.ItemNumber = f_.ItemID and f.FCDate_ = f_.myFcDate
					  select f_.ItemID,f_.Date as myDate,f_.Value as myFcQty,f.ItemNumber,f.Date,f.FCDate_,f.FC_Vol
								,convert(varchar(7),f_.Date,120) as myFcDate								
					  --from fc_mas f full outer join @mymi f_ on f.ItemNumber = f_.ItemID and f.Date = f_.myDate
					  -- from fc_mas f full outer join JDE_DB_Alan.FCPRO_MI_orig f_ on f.ItemNumber = f_.ItemID and f.Date = f_.Date		-- use this will have all data (includes 18.013.089) but big recordsets, because you are picking up all SKUs in 'Master' file regardless if they have forecast or not ( currently you filter out items has no sales history over last 12 months and prevent them generating fc )	--- ?				 
					   -- from JDE_DB_Alan.FCPRO_MI_orig f_ left join fc_mas f on f.ItemNumber = f_.ItemID and f.Date = f_.Date	         --- not good causing big problems for SOH etc because on Mi raw table you only have 1 or 2 or 3 month, say if MI is for 2018-09 then you will not get SOH ( since SOH is always default to current month you are in ) and you need visibility for each month, YOU can use left join if you are not concerning SOH figure but in order to keep your code consistent, you should keep use full outer join and filter out on specific SKUs at end,this might best solution for this issue 25/7/2018 --- Will Use this lead to risk of lossing item has no sales history 18.013.089	--- No ???
					   from fc_mas f full outer join JDE_DB_Alan.FCPRO_MI_2_Raw_Data_tmp f_ on f.ItemNumber = f_.ItemID and f.Date = f_.Date		-- 31/7/2018, change table name -- use this will have all data (includes 18.013.089) but big recordsets, because you are picking up all SKUs in 'Master' file regardless if they have forecast or not ( currently you filter out items has no sales history over last 12 months and prevent them generating fc )	--- ?				 
					 )
             --  select * from _fc
			 ,fc as																		
				   ( select f.ItemID,f.myFcDate,f.myFcQty,f.ItemNumber,f.Date,f.FCDate_,f.FC_Vol
				            ,case when f.myFcQty is null then f.FC_Vol												-- if Item doest not exists in MI raw but exists in vw_FC master
							      when f.myFcQty is not null then													-- if Item exists in MI raw, see if it exists in vw_FC master,if do, combine two fc together			
														case when f.FC_Vol is not null then f.FC_Vol+f.myFcQty		-- if Item exists in MI raw, see if it exists in vw_FC master,if do not, then use Mi Raw ( it could be Item with no 12 mth sales history, item discontinued, or item belongs to AWF )
															 when f.FC_Vol is null then f.myFcQty
															 end
								   
							   end as  FC_Vol_f
							,case when f.ItemNumber is not null then f.ItemNumber
							      when f.ItemNumber is null then f.ItemID
							 end as ItemNumber_f
							,case when f.Date is not null then f.Date
							      when f.date is null then f.myDate
							 end as Date_f
							,case when f.FCDate_ is not null then f.FCDate_
							      when f.FCDate_ is null then f.myFcDate
							 end as FcDate_f
					  		  	        	   
                      from  _fc f 
                    -- from JDE_DB_Alan.vw_FC f full outer join @mymi f_ on f.ItemNumber = f_.ItemID and f.FCDate_ = f_.FcDate  
				    -- from JDE_DB_Alan.vw_FC f left join @mymi f_ on f.ItemNumber = f_.ItemID and f.FCDate_ = f_.FcDate 
					--  from  @mymi f_  left join JDE_DB_Alan.vw_FC f on f.ItemNumber = f_.ItemID and f.FCDate_ = f_.FcDate_Raw			--- not good causing big problems for SOH etc because on Mi raw table you only have 1 or 2 or 3 month, say if MI is for 2018-09 then you will not get SOH ( since SOH is always default to current month you are in ) and you need visibility for each month, YOU can use left join if you are not concerning SOH figure but in order to keep your code consistent, you should keep use full outer join and filter out on specific SKUs at end,this might best solution for this issue 25/7/2018 --- Will Use this lead to risk of lossing item has no sales history 18.013.089	--- No ???
					-- where f.ItemNumber in ( '42.210.031','24.7207.4459')
					     --  and f.Date < '2019-03-01'
                     --where f.ItemNumber in ('18.010.035')
					 )

              -- select distinct fc.ItemNumber from fc 
			  --select  * from fc  where fc.ItemID in ('18.013.089') or fc.ItemNumber in ('18.013.089')			--- note 18.013.089 has no existence in 'FVPRO_Fcst' table as there is no sales history over 12 month. Therefore when join table you will have unexpected result - be careful here in where condition be careful to which ItemNumber or ItemId you need to use. Also be careful using 'Not In ( )' conditional because if there is null value SQL will return empty dataset ! --- 20/7/2018
			  -- select * from fc

				,tb as 
					( select f.ItemNumber_f,f.FcDate_f,f.Date_f,f.FC_Vol_f as FC_Vol				-- will it cause issues if you rename 'f.FC_Vol_f' as 'FC_Vol' since you already have 'FC_Vol' column ?
						 -- select f.ItemNumber,f.Date,f.FCDate_,f.FC_Vol_f
							,isnull(p.PO_Vol,0) PO_Vol
							--,isnull(m.QtyOnHand,0) SOH_Vol
							,isnull(m.QtyOnHand,0) as SOH_Begin_M
							 ,0 as SOH_Vol				 
							--, isnull(m.QtyOnHand,0) as SOH_End_M
							,0 as SOH_End_M
							,m.WholeSalePrice							
							 
					-- from JDE_DB_Alan.vw_FC f left join po p on f.ItemNumber = p.ItemNumber and f.FCDate_ = p.PODate_
					  from fc f left join po p on f.ItemNumber_f = p.ItemNumber and f.FcDate_f = p.PODate_
											left join JDE_DB_Alan.vw_Mast m on f.ItemNumber  = m.ItemNumber and f.FCDate_ = m.SOHDate   -- SOHDate is current month name,also note 'vw_Mast' is clearn without duplicated records
											  --left join JDE_DB_Alan.vw_Mast m on f.ItemNumber_f  = m.ItemNumber
					 where f.Date_f< @dt							--- be careful if you have null value resulting from pervious step in join -- you will miss value --- 20/7/2018
					 -- where f.Date < '2018-10-01'
						  -- and f.ItemNumber in ('45.103.000')
								 )
								 						
			   --select * from tb order by tb.ItemNumber_f,tb.FCDate_f
				  ,tb_ as (
							select tb.ItemNumber_f,tb.Date_f,tb.FCDate_f,tb.FC_Vol,tb.PO_Vol,tb.SOH_Vol 
									,case 
										   when tb.Date_f >DATEADD(mm, DATEDIFF(m,0,GETDATE()),0)  then (tb.PO_Vol -tb.FC_Vol)
										   when tb.Date_f = DATEADD(mm, DATEDIFF(m,0,GETDATE()),0) then (tb.PO_Vol -tb.FC_Vol + tb.SOH_Begin_M)
										   else tb.SOH_Vol
										  end as  SOH_Vol_
								  -- ,(tb.PO_Vol -tb.FC_Vol) as SOH_Vol_
								   ,tb.SOH_Begin_M,tb.SOH_End_M
								   ,tb.WholeSalePrice					  
							from tb				
							)  
				 --select * from tb_
						   --- running total preparation ---      
				   ,tbl as ( select *,
									row_number() over ( partition by tb_.itemNumber_f order by tb_.FCDate_f ) as rnk 
								from tb_      
                
							)
							--- running total To get End period inventory ---
				 ,tbl_ as 
						(	select *
								  ,sum(tbl.SOH_Vol_) over (partition by tbl.ItemNumber_f order by tbl.rnk ) as SOH_End_M_
								from tbl
						 )
      
				  --select * from tbl_
							--- Beginning period inventory preparation ---
				  ,stk_beg as
						  ( select tbl_.ItemNumber_f as myItemNumber,tbl_.FcDate_f as myDate
									,DATEADD(mm, DATEDIFF(m,0,tbl_.Date_f)+1,0) dte
									,tbl_.SOH_End_M_ as mySOH_Begin_M_
			            
							 from tbl_)
					   --select * from stk_beg

				 ,t as ( select *
								 from tbl_ left join stk_beg on tbl_.ItemNumber_f = stk_beg.myItemNumber and tbl_.Date_f = stk_beg.dte 
							  )
					--  select * from t
							  --- Get Begining period inventory ---
				 ,t_ as ( select t.ItemNumber_f,t.Date_f,t.FCDate_f,t.FC_Vol,t.PO_Vol,t.SOH_Vol,t.SOH_Vol_
									,case 
											when t.mySOH_Begin_M_ is null then t.SOH_Begin_M
											else t.mySOH_Begin_M_
									  end as  Final_SOH_Begin_M_
									,t.SOH_End_M_,t.rnk
									,t.WholeSalePrice
									--,t.myWSP
									,replace(convert(varchar(8), DATEADD(mm, DATEDIFF(m,0,t.Date_f),0),126),'-','') as Date_f_2
								 from t
								 )

					 -- select * from t_
					  -- ,pri as ( select t_.ItemNumber,t_.WholeSalePrice from t_ where t_.WholeSalePrice is not null)

					 --  select * from pri
					--   ,_t as ( select t_.*,																			-- cost too long time to run
								   --       case when t_.WholeSalePrice is null then pri.WholeSalePrice
											 --   else t_.WholeSalePrice
										  --  end as mywholesaleprice
									--from t_ left join pri on t_.ItemNumber = pri.ItemNumber )          
				 
				    --- Filter out Item does not exist (inner join) Or discontinued ( stocking type )---
				  ,_t as ( --select t_.ItemNumber,t_.Date,t_.FCDate_,t_.FC_Vol,t_.PO_Vol,t_.SOH_Vol,t_.SOH_Vol_,t_.Final_SOH_Begin_M_,t_.SOH_End_M_,m.WholeSalePrice     -- will spit out column by column saves the performance issue ? Not really  -- 14/5/2018
								select t_.*
										, mm.WholeSalePrice as Mywholesaleprice
										,(mm.WholeSalePrice * t_.FC_Vol) FC_Amt
									   , case when t_.Final_SOH_Begin_M_ <= 0  then 'Y 'else 'N' end as Stk_Out_Stauts
									   ,sum(t_.FC_Vol) over (partition by t_.ItemNumber_f order by t_.FCDate_f Rows between current row and 2 following ) as CumulativeTotal_FC_Vol_3M			-- only works in SQL 2012 upwards, if you using 2008 need to use below...  https://docs.microsoft.com/en-us/sql/t-sql/queries/select-over-clause-transact-sql?view=sql-server-2017
									   ,sum(t_.FC_Vol) over (partition by t_.ItemNumber_f order by t_.FCDate_f Rows between 1 following and 3 following ) as CumulativeTotal_FC_Vol_Nxt3M	
									   ,avg(t_.FC_Vol) over (partition by t_.ItemNumber_f) as Avg_FC_Vol_Nxt8M			--- SQL2008 support this 
									   ,mm.PlannerNumber
						 				,case mm.PlannerNumber 
											when '20071' then 'Domenic Cellucci'		
											--when '20071' then 'Rosie Ashpole'
											when '20072' then 'Salman Saeed'
											when '20004' then 'Margaret Dost'	
											when '20005' then 'Imelda Chan'										  
											else 'Unknown'
										end as Owner_
									   ,mm.PrimarySupplier,mm.Description,mm.FamilyGroup_,mm.Family_0,mm.Leadtime_Mth									   
								--from t_ left join JDE_DB_Alan.vw_Mast mm on t_.ItemNumber_f = mm.ItemNumber	)				-- note that 'vw_Mast ' has clean data, also best to use Inner Join ( see below for reason )  - 23/7/2018
								  from t_ inner join JDE_DB_Alan.vw_Mast mm on t_.ItemNumber_f = mm.ItemNumber					-- Use inner join to filter out SKUs not showing up in HD using ML345 (HD), so SKUs against AWF will filter out ( like in CommonWealth Bank Proj - '7089895','709901' ) -- 23/7/2018 
								  where mm.StockingType not in ('O','U') 
								--  where mm.StockingType in ('O','K','W','X','S','F','P','U','Q','Z','C','M','0','I')			
								--  where mm.StockingType in ('K','W','X','S','F','U','Q','Z','C','M','0','I')				   -- this could be best to avoid issue of returning empty dataSet due to Null value --- 23/7/2018
											)		
		 
					-- select * from _t
						--where _t.ItemNumber in ('45.103.000','45.200.100','42.210.031') 
						 -- where _t.ItemNumber in ('0751031003001H')
						 --order by _t.ItemNumber,_t.Date	
						 	 
					--select _t.ItemNumber_f,_t.Date_f d1,_t.FCDate_f d2,'Start_Stk' as DataType,_t.Final_SOH_Begin_M_ as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.Leadtime_Mth,_t.PlannerNumber from _t

				 ,com as ( select _t.ItemNumber_f,_t.Date_f d1,_t.Date_f_2 d3,_t.FCDate_f d2,'FC_Qty' as DataType,_t.FC_Vol as Value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.Leadtime_Mth,_t.PlannerNumber from _t
							   union all
							   select _t.ItemNumber_f,_t.Date_f d1,_t.Date_f_2 d3,_t.FCDate_f d2,'PO_Qty' as DataType,_t.PO_Vol as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.Leadtime_Mth,_t.PlannerNumber from _t
							  union all
							   select _t.ItemNumber_f,_t.Date_f d1,_t.Date_f_2 d3,_t.FCDate_f d2,'SOH_Qty' as DataType,_t.SOH_Vol_ as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.Leadtime_Mth,_t.PlannerNumber from _t
							  
							  union all
								select _t.ItemNumber_f,_t.Date_f d1,_t.Date_f_2 d3,_t.FCDate_f d2,'Start_Stk' as DataType,_t.Final_SOH_Begin_M_ as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.Leadtime_Mth,_t.PlannerNumber from _t
							  union all
								select _t.ItemNumber_f,_t.Date_f d1,_t.Date_f_2 d3,_t.FCDate_f d2,'End_Stk' as DataType,_t.SOH_End_M_ as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.Leadtime_Mth,_t.PlannerNumber from _t
							  union all
								select _t.ItemNumber_f,_t.Date_f d1,_t.Date_f_2 d3,_t.FCDate_f d2,'FC_Amt' as DataType,_t.FC_Amt as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.Leadtime_Mth,_t.PlannerNumber from _t				   
                              union all
								select _t.ItemNumber_f,_t.Date_f d1,_t.Date_f_2 d3,_t.FCDate_f d2,'Weeks_Cover1' as DataType,coalesce(_t.SOH_End_M_/nullif(_t.CumulativeTotal_FC_Vol_Nxt3M/12,0),0) as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0,_t.Leadtime_Mth,_t.PlannerNumber from _t				  
							--  union all
							--	select _t.ItemNumber,_t.Date d1,_t.FCDate_ d2,'Weeks_Cover2' as DataType,(_t.SOH_End_M_)/(_t.Avg_FC_Vol_Nxt8M/4) as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0 from _t				  							  						  	 
							   )

                 --select distinct com.ItemNumber_f from com
				 ,fcst as 
					 (select * from com 
						 --where com.Stk_Out_Stauts in ('Y')
						   -- where com.ItemNumber in ('45.103.000','45.200.100')
						--where com.ItemNumber in ('4152336048B')
				 		-- where com.ItemNumber in ( select splitdata from JDE_DB_Alan.dbo.fnSplitString(@Item_id,','))	
						  --where com.PrimarySupplier in ('20037','1102')
						--where com.ItemNumber in ('32.501.000','18.010.035','18.615.007','18.010.036','2780229000','82.391.909','32.379.200','18.013.089','24.7002.0001','24.7334.4459','24.7102.1858','24.7219.4459','32.455.155','24.7121.4459','24.7122.4459','24.7124.4459','24.7127.4459','24.5349.4459','24.7120.4459','24.7250.4459','24.7251.4459','24.7253.4459','24.7146.4459A','24.7207.4459','24.7168.4459A','24.7169.4459A','24.7163.0000A')  
						--  where com.ItemNumber in ('24.7218.4465','32.501.000','43.211.004','32.379.200','32.380.855','18.607.016','24.7201.0000','24.7102.7052','24.7102.7052','32.455.465','24.7115.0952A','24.7114.0952A','24.7128.0952','709895','24.7353.0000A','24.7136.0155A','709901','24.7120.0952')
						-- where com.ItemNumber in ('32.501.000','18.010.035','18.615.007','18.010.036','2780229000','82.391.909','32.379.200','18.013.089','24.7002.0001','24.7334.4459','24.7102.1858','24.7219.4459','32.455.155','24.7121.4459','24.7122.4459','24.7124.4459','24.7127.4459','24.5349.4459','24.7120.4459','24.7250.4459','24.7251.4459','24.7253.4459','24.7146.4459A','24.7207.4459','24.7168.4459A','24.7169.4459A','24.7163.0000A')
						-- where com.ItemNumber in ('42.210.031')
						--where com.ItemNumber_f in ('18.013.089')
						where com.DataType in ('FC_Qty')
						        and com.ItemNumber_f in (select o.ItemID from JDE_DB_Alan.FCPRO_MI_2_Raw_Data_tmp o)				-- Changed table name 31/7/2018	
							 --and com.ItemNumber_f in (select o.ItemID from JDE_DB_Alan.FCPRO_MI_orig o)				-- pick up item only appearing in Mi_orig table, if you omit this clause, you can pick up all items both in Mi_orig and vw_FC table   --- 25/7/2018
																												    -- better to do filter here to avoid performance bottleneck in following Pivot function		--- 25/7/2018
						    -- and com.ItemNumber_f in  ( select splitdata from JDE_DB_Alan.dbo.fnSplitString(@Item_id,','))	--- No need in Mi_Raw since you only pick up Forecast, but if you do Generic Mismatch it is good to have alternative to choose ItemNumber --- 25/7/2018
						--order by com.ItemNumber_f,com.DataType,com.d2
					       )
 
                 -- select * from fcst

				  --- Get Preparation to Pivot Data using SQL --- It is better to use Numbwe Array ([1],[2],[3] ) instead of ([201807],[201808],[201809]) as it is more versatile and flexible to avoid hard coding --- 25/7/2018
				,R(N,_T,T_,T,XX,YY,start) AS
						(
						 select 1 as N,-24 as _T,24 as T_,-23 as T,24 as XX,24 as YY,cast(DATEADD(mm, DATEDIFF(mm, 0, GETDATE())-24, 0) as datetime) as start      -- pay attention T starts -23,you need this so you can get XXX Column/Field in current month you start as 1, otherwise you can use XX field
						 UNION ALL
						 select  N+1, _T+1,T_-1,case when T+1<0 then T+1 else case when T+1 =0 then 1 else T+1 end end as T						
												,case when N >= 24  then _T+1
												   else  
													   XX-1
													end as XX
												 ,case when N >= 24  then T							     
												   else  
													   YY-1
													end as YY
								 ,dateadd(mm,1,start)
						  from R
						 where N < 49
						)
					--select * from r
					--select R.N,case when R._T < 0 then R.T_ else R._T end as T, start from R
					--select R.N,case when R._T < 0 then R.T_ else R.YY end as T, start from R
				  ,MthCal as (
									select  n as rnk
									 ,YY
									,_T
									,cast(SUBSTRING(REPLACE(CONVERT(char(10),start,126),'-',''),1,6) as integer) as [StartDt]		
									,LEFT(datename(month,start),3) AS [month_name]
									,datepart(month,start) AS [month]
									,datepart(year,start) AS [year]				
								   from R  )
				 --select * from MthCal
                
				 --- Need to Pivot data to display in Horizontal way --- Need to think it to join Calendar table ( with integer t number ) rather using [201808],[201809] instead using [1],[2] to speed up execution time,also to avoid hard coding !
				
			 ,fcst_ as ( select f.ItemNumber_f,f.Description,f.d1,f.d3,f.d2,f.Value
								,c.*																				--- join cal to get YY value which is your month rank/order
				    
						from fcst f left join MthCal c on f.d3 = c.StartDt												--- no need to cross join cal table as FC tb always has data in 24 mth				
					  -- where fc.ItemNumber = ('42.210.031') order by fc.ItemNumber,fc.StartDt,fc.Date
						)
				
              -- select * from fcst_

				, mypvt as 
					( select *
						 from 
								( select f.ItemNumber_f,f.Description,f._T,f.Value  from fcst_ f  ) as sourcetb
                         pivot 
						       ( sum(value) for _T in ( [0],[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11]) 
								) as p								
					)
				
				
				select pv.ItemNumber_f
					   ,pv.Description
					   ,isnull(pv.[0],0) [0]
					   ,isnull(pv.[1],0) [1]
					   ,isnull(pv.[2],0) [2]
					   ,isnull(pv.[3],0) [3]
					   ,isnull(pv.[4],0) [4]
					   ,isnull(pv.[5],0) [5]
					   ,isnull(pv.[6],0) [6]
					   ,isnull(pv.[7],0) [7]
					   ,isnull(pv.[8],0) [8]
					   ,isnull(pv.[9],0) [9]
					   ,isnull(pv.[10],0) [10]
					   ,isnull(pv.[11],0) [11]
					   
				 from mypvt pv
				 order by pv.ItemNumber_f


				--, mypvt as 
				--	( select *
				--		 from 
				--				( select f.ItemNumber_f,f.Description,f.d3,f.Value  from fcst f  ) as sourcetb
                --        pivot 
				--		       ( sum(value) for d3 in ( [201807],[201808],[201809],[201810],[201811],[201812],[201901],[201902],[201903],[201904],[201905],[201906]) 
				--				) as p								
				--	)

		   --    	select pv.ItemNumber_f
					--   ,pv.Description
					--   ,isnull(pv.[201807],0) [201807]
					--   ,isnull(pv.[201808],0) [201808]
					--   ,isnull(pv.[201809],0) [201809]
					--   ,isnull(pv.[201810],0) [201810]
					--   ,isnull(pv.[201811],0) [201811]
					--   ,isnull(pv.[201812],0) [201812]
					--   ,isnull(pv.[201901],0) [201901]
					--   ,isnull(pv.[201902],0) [201902]	
					--   ,isnull(pv.[201903],0) [201903]	
					--   ,isnull(pv.[201904],0) [201904]	
					--   ,isnull(pv.[201905],0) [201905]			   	
					--   ,isnull(pv.[201906],0) [201906]	
				 --from mypvt pv
				 --order by pv.ItemNumber_f

---------------------- End of  Mismatch Report  Version -sp ( store procedure) - ( Full Outer join - Use date as 'datetime' datatype ) 25/7/2018 ---

----------------------------- End of  Mismatch Report 12/7/2018  Version 2 ( Full Outer join ) 20/7/2018 ----------------------------------------------------------

exec JDE_DB_Alan.sp_MI_2_Raw_Mismatch_Combine null,'2018-12-02'
exec JDE_DB_Alan.sp_MI_2_Raw_Mismatch_Combine null,'2019-01-02'
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------


--- NP MI Exception Report--- 22/6/2018
with cte as (
				select m.*
						,row_number() over(partition by m.itemNumber order by itemnumber ) as rn 
				from JDE_DB_Alan.Master_ML345 m )
	,cte_ as (
					select cte.*
					       ,case when cte.stockingType in ('O','U') then 'N' 			-- if discontinue it is 'N'	otherwise it is 'Y'			         
								  else 'Y'   end as JdeValidStatus
				     from cte where rn =1 					
				 )
	,tb as ( select np.*,cte_.StockingType,cte_.JdeValidStatus
					,case when cte_.JdeValidStatus is null then 'NotFind' else cte_.JdeValidStatus end as STKTYP_St 		  --- in case Your ML345 is not updated hence you could hve 'Null' - left join
			 from JDE_DB_Alan.FCPRO_NP_tmp np left join cte_ on np.ItemNumber = cte_.ItemNumber
			  --where np.ItemNumber in ('34.528.000') 		  
			 )
    
	--- Get Your final list ---
	,tb_ as (select tb.*,case when tb.ValidStatus ='N' then 'N'				-- Considering Your input in Excel file ( 'ValidStatus')
	                 when tb.STKTYP_St ='NotFind' then 'N'			    -- Considering JdeValidStatus
	                 else tb.STKTYP_St									-- Considering JdeValidStatus
					 end as fSTKTYP_St
			from tb
			)
    --select distinct t.ItemNumber
	select t.ItemNumber,t.Date,t.Value,t.DataType,t.CN_Number,t.Comment,t.Creator,t.LastUpdated,t.fSTKTYP as ValidStatus_,t.RefNum,t.ReportDate
	from tb_ t
	where t.fSTKTYP_St = 'N'
	where t.ItemNumber in ('34.528.000','34.527.000','KIT8105')
	order by t.ItemNumber,t.Date


 ----------------------------------------------------------------------------------------------------------




---============= Update FC table =========
;update f
set f.Value = 803
from JDE_DB_Alan.FCPRO_Fcst f
where f.DataType1 = 'Adj_FC' and f.ItemNumber in ('24.7220.1858')

select * from JDE_DB_Alan.FCPRO_Fcst f where f.ItemNumber in ('24.7220.1858') and f.DataType1 in ('Adj_FC')



--------------------------------------------------------------------------------

exec JDE_DB_Alan.sp_FCPro_FC_Accy_Rpt_New 'LT'

--- Forecast accuracy data are in 'Waterfall' format ---
exec JDE_DB_Alan.sp_FCPro_FC_Accy_Data '38.001.001'
exec JDE_DB_Alan.sp_FCPro_FC_Accy_Data '42.210.031'

---================================================================
exec JDE_DB_Alan.sp_FCPro_FC_Sales_Analysis null,'43.205.532M'
exec JDE_DB_Alan.sp_FCPro_FC_Sales_Analysis 'Last_Mth_FC','43.205.532M'				-- old, manual set date to 'This_Mth_FC' Or 'Last_Mth_FC' -- not good, what if FC is saved in mid of month not End of month ?
exec JDE_DB_Alan.sp_FCPro_FC_Sales_Analysis 'This_Mth_FC','38.001.001'				--old, manual set date to 'This_Mth_FC' Or 'Last_Mth_FC' -- not good
exec JDE_DB_Alan.sp_FCPro_FC_Sales_Analysis '42.210.031','2018-10-01','2019-09-03'		    	-- FC Saving date Range is too large,note 'start' and 'end' date here is FC Saving date ! Not FC Period date !-- 5/10/2018
exec JDE_DB_Alan.sp_FCPro_FC_Sales_Analysis '42.210.031','2018-10-01','2018-10-03'			   -- good, working
exec JDE_DB_Alan.sp_FCPro_FC_Sales_Analysis '42.210.031','2018-09-28','2018-09-30 17:00:00'    -- good, working


exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis null,'2018-11-01','2019-10-02'
exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis '2801499661,2801499785,2801499072,2801499351,2801499689,2801499167,2801499862,2801499048,2801499354,2801499245,2801499324,2801499276,2801499609,2801499669,2801499095','2020-10-01','2021-09-02'



select * from JDE_DB_Alan.vw_FC_Hist h where h.ItemNumber in ('42.210.031') and h.myReportDate3 between '2018-09-28' and '2018-10-01'
select * from JDE_DB_Alan.vw_FC_Hist h where h.ItemNumber in ('42.210.031') and h.myReportDate3 between '2018-09-28' and '2018-09-30 17:00:00'
select * from JDE_DB_Alan.vw_FC_Hist h where h.ItemNumber in ('42.210.031') and h.myReportDate3 between '2018-10-02' and '2018-10-05'


select distinct h.ReportDate from JDE_DB_Alan.vw_FC_Hist h where h.ItemNumber in ('42.210.031')
select distinct h.myReportDate3,h.myReportDate4,h.myReportDate2 from JDE_DB_Alan.vw_FC_Hist h where h.ItemNumber in ('42.210.031')

select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('18.013.089')
select * from JDE_DB_Alan.FCPRO_Fcst_History h where h.ReportDate between '2018-09-28' and '2018-10-01'
select * from JDE_DB_Alan.FCPRO_Fcst_History h where h.ItemNumber in ('42.210.031') and h.Date in ('2018-09-01 00:00:00.000') and h.ReportDate between '2018-09-28' and '2018-10-01'
select * from JDE_DB_Alan.FCPRO_Fcst_History h where h.ItemNumber in ('42.210.031') and h.Date in ('2018-09-01') and h.ReportDate between '2018-09-28' and '2018-10-01'

exec JDE_DB_Alan.sp_Z_FC_Hist_Summary 


----------------------------------------
--- Test CO Summary --- Commercial orders

delete from JDE_DB_Alan.TestCO where OrderNumber in ('5510877')
delete from JDE_DB_Alan.TestCO where Reportdate > '2018-11-05'
delete from JDE_DB_Alan.TestWO where Reportdate > '2018-10-25'
select * from JDE_DB_Alan.TestWO w where Reportdate > '2018-10-25'

select * from JDE_DB_Alan.TestCO
select * from JDE_DB_Alan.TestCO
select c.OrderNumber,c.LineNumber,c.BranchPlant,c.RelatedWONum,c.OrderQty,c.ListPrice,c.OrderQty*c.ListPrice as OrderAmt,c.Customer,c.CustomerName,c.EnterDate,c.PromiseDelDate,c.CO_Name,c.ItemNumber,c.ItemDescription,c.SlsCd2,c.SlsCd3,c.Brand,c.OrderTakenBy,c.Reportdate
from JDE_DB_Alan.TestCO c
exec JDE_DB_Alan.sp_Exp_Test_CO_mast

  ------ Check if records in Test CO has duplicated -------

    with cte as 
  (
	  select   c.RelatedWONum,convert(varchar(19),c.ReportDate,120) as Date_Uploaded
				,count(*)  as WO_Uploaded
	  from JDE_DB_Alan.TestCO C
	  group by  c.RelatedWONum,convert(varchar(19),c.ReportDate,120) )
  
  select *, sum(cte.WO_Uploaded) over (partition by RelatedWONUm order by Date_Uploaded) TTL_WO_Tbl
          ,ROW_NUMBER() over( partition by RelatedWONum order by Date_Uploaded) as rn
		  ,rank() over ( partition by RelatedWONum order by Date_Uploaded) rk								--Use rank ( not dense_rank), although using rank will skip but rank will give you right final counts
  from cte 
 -- where cte.WO_Date_Uploaded > '2018-08-02' and cte.Date_Uploaded < '2018-08-26 14:59:00'
  order by cte.Date_Uploaded asc



---  Get Details of Test CO/WO --- 23/10/2018
select * from JDE_DB_Alan.TestCO
select * from JDE_DB_Alan.TestWO

exec JDE_DB_Alan.sp_Exp_Test_WO_mast


	;with tb as
	   ( select w.ItemNumber,w.OrderQuantity,w.UM,w.WONumber,c.OrderNumber as CO,c.CustomerName
				,c.ItemNumber as FinItemNumber,c.ItemDescription as FinItemDesp,c.SlsCd2,SlsCd3,c.CO_Name as Proj_Name,c.StateCode2
				,c.OrderTakenBy as Comments,w.Reportdate
			from JDE_DB_Alan.TestWO w left join JDE_DB_Alan.TestCO c 
				   on w.WONumber = c.RelatedWONum

		 )
	   ,tbl as ( select tb.ItemNumber,tb.OrderQuantity,tb.UM,tb.CO,tb.WONumber,tb.CustomerName
						,tb.FinItemNumber,tb.FinItemDesp,tb.SlsCd2,tb.SlsCd3,tb.Proj_Name,tb.StateCode2						
						,m.StockingType,m.WholeSalePrice
						--,tb.OrderQuantity*m.WholeSalePrice as Amt
						,m.Description
						,tb.Comments
						,tb.Reportdate
					from tb left join JDE_DB_Alan.vw_Mast m
							on tb.ItemNumber = m.ItemNumber
							)            

		select * from tbl
		order by tbl.Reportdate,tbl.WONumber,tbl.ItemNumber

    ------ Check if records in Test WO has duplicated -------

    with cte as 
  (
	  select   w.WONumber,convert(varchar(19),w.ReportDate,120) as Date_Uploaded
				,count(*)  as WO_Records_Uploaded
	  from JDE_DB_Alan.TestWO w
	  group by  w.WONumber,convert(varchar(19),w.ReportDate,120) )
  
  select *, sum(cte.WO_Records_Uploaded) over (order by Date_Uploaded) TTL_WO_Records_Tbl
          ,ROW_NUMBER() over( partition by WONumber order by Date_Uploaded) as rn
		  ,rank() over ( partition by WONumber order by Date_Uploaded) rk								--Use rank ( not dense_rank), although using rank will skip but rank will give you right final counts
  from cte 
 -- where cte.WO_Date_Uploaded > '2018-08-02' and cte.Date_Uploaded < '2018-08-26 14:59:00'
  order by cte.Date_Uploaded asc


---==========================================================
  -------- Forecast accuracy By Range --------- 26/10/2018
  -----------------------------------------------------------

  select * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h

  ;with t as (
    
		  select distinct h.SellingGroup , h.FamilyGroup,  h.Family
		  from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h
		  )

   ,fm as ( select distinct t.SellingGroup,t.FamilyGroup,t.Family
		   from t 
		   where t.SellingGroup like ('%win%')

		   )
   ,_fm as (
            select fm.*
			       --,RANK() over ( partition by sellinggroup order by familygroup) as rnk_family_
			       ,DENSE_RANK() over ( partition by sellinggroup order by familygroup) as rnk_family
				   ,DENSE_RANK() over ( partition by familygroup order by family) as rnk_familygroup
				   ,row_number() over ( partition by sellinggroup order by sellinggroup) as rn
			from fm
			)
 
    select top 3 * from _fm


---========================================================================
  ------------------- Inventory Value ------------------- 13/12/2018
--------------------------------------------------------------------------
  select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('42.210.031')
  select * from JDE_DB_Alan.vw_Mast m where m.ItemNumber in ('05.980.000')


 --select * from JDE_DB_Alan.vw_Mast m where m.ItemNumber in ('05.980.000')
 
  
  with a as 			
    ----- Use left join --- remove scrap items -- method 1
    (  select m.ItemNumber as myItm ,m.QtyOnHand as mySOH,m.StockValue as mySOHVal
		  from JDE_DB_Alan.vw_Mast m
		  where m.GLCat in ('SCRA')	
		        )

  ,_tb as ( select * 
				from JDE_DB_Alan.vw_Mast m left join a on m.ItemNumber = a.myItm
				where a.myItm is null 
				--where m.ItemNumber in ('42.210.031','32.379.200','05.980.000')	
				)

    ---- Use 'except' --- remove scrap items -- method 2
  ,aa as ( select * from JDE_DB_Alan.vw_Mast m where m.GLCat in ('SCRA')   )
  ,_ttb as ( select * from JDE_DB_Alan.vw_Mast a except select * from aa )

  --select * from _ttb

    ------- Inventory On SKU level ------
  ,tb as (select t.BU,t.ItemNumber,t.ShortItemNumber,t.StockingType,t.PlannerNumber,t.PrimarySupplier,t.SellingGroup_,t.FamilyGroup_,t.Family_0
                 ,t.StandardCost,t.WholeSalePrice,t.Description,t.QtyOnHand,t.SOHDate,t.SOHDate_,t.masyr,t.masmth,t.masdte,t.LeadtimeLevel,t.UOM,t.Leadtime_Mth
				 ,t.rn,t.SellingGroup,t.FamilyGroup,t.Family
			--from _tb t	
			  from _ttb t 
			)

		 --- Inventory aggregate level 1 ---
   ,agg1 as (  select t.SellingGroup_,t.FamilyGroup_,t.Family_0,sum(t.QtyOnHand) as TTL_Stk_Units,sum(t.StockValue) as TTL_Stk_Dollar
			   from _tb t
			   group by t.SellingGroup_,t.FamilyGroup_,t.Family_0
			   )

         --- Inventory aggregate level 2 ---
	,agg2 as ( select t.FamilyGroup_,sum(t.TTL_Stk_Units) as StkUnits,sum(t.TTL_Stk_Dollar) as StkDollar
				from agg1 t
            group by t.FamilyGroup_
            )

    select * from agg2 order by StkDollar desc
	--select * from tb


-----  Textile Forecast --------

;update f
set f.Reportdate = '2019-05-22'
from JDE_DB_Alan.TextileFC f
where cast(replace(convert(varchar(10),f.Reportdate,126),'-','') as integer) = '20190628' 

;update f
set f.ArticleUOM = 'Yard'
from JDE_DB_Alan.TextileFC f
--where cast(replace(convert(varchar(10),f.Reportdate,126),'-','') as integer) = '20190628' 

select * from JDE_DB_Alan.TextileFC t where t.Reportdate between '2019-10-01' and '2019-10-30 17:00:00:00' 

  delete from JDE_DB_Alan.TextileFC
where Reportdate between '2019-10-01' and '2019-10-30 17:00:00:00' 


----------Textile FC in nice format -------------
;with _tfc as
 (
	select *
	        ,cast(SUBSTRING(REPLACE(CONVERT(char(10),t.Date,126),'-',''),1,6) as integer) as YM_FC_Date
			,cast(SUBSTRING(REPLACE(CONVERT(char(10),t.Reportdate,126),'-',''),1,6) as integer) YM_Report_Date 
			,cast(REPLACE(CONVERT(char(10),t.Reportdate,126),'-','') as integer) YMD_Report_Date
	from JDE_DB_Alan.TextileFC t
	)

 , tfc_ as 
    ( select a.ArticleNumber,c.HDItemNumber,a.ArticleDescription,a.Quantity,a.ArticleUOM,a.YM_FC_Date,a.YM_Report_Date,a.YMD_Report_Date,a.Reportdate,a.Vendor,m.family,m.familygroup,m.Colour,m.Description
		 from _tfc a left join JDE_DB_Alan.Textile_ItemCrossRef c on a.ArticleNumber = c.SupplierItemNumber
		             left join JDE_DB_Alan.vw_Mast m on c.HDItemNumber = m.ItemNumber 
	 )

select * from tfc_
order by tfc_.Reportdate


--where tfc_.Reportdt in ( '20190628')


---------- difference between FC file beginning of Month and Middle of Month ( diagnois tool ) --------------------------------


select * from (

(
select distinct fh.ItemNumber
 from JDE_DB_Alan.FCPRO_Fcst_History fh
 where fh.ReportDate >'2019-09-01'
      --and fh.ItemNumber in ('42.210.031')
          )
except
(

select distinct f.ItemNumber
 from JDE_DB_Alan.FCPRO_Fcst f
 where f.DataType1 in ('Adj_FC')

       )
  ) z left join JDE_DB_Alan.vw_Mast m on z.ItemNumber = m.ItemNumber 



--------   Upload NP forecast into JDE If you miss the month cycle, but you still need to load FC into FC Pro next month 18/9/2019 --------------------		
		with cte as (
							select f.ItemNumber,convert(varchar(6),f.Date,112) as Period_YM,f.Value,'Adj_FC' as Typ_
							 --from JDE_DB_Alan.FCPRO_Fcst f 
							   from JDE_DB_Alan.FCPRO_NP_tmp f
							 --where s.ItemNumber in (select ids from @ItemIDs)
							 --where f.ItemNumber in ('40.033.131')
							 --  where f.DataType1 in ('Adj_FC')				--- 26/2/2018
							union all
							select s.ItemNumber,convert(varchar(6),convert(datetime,concat(s.CYM,'01')),112) Period_YM,s.SalesQty,'Sales' as Typ_
							from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload s 
							--where s.ItemNumber in (select ids from @ItemIDs)
							--where s.ItemNumber in ('40.033.131')
						 ) 
						 ,comb_ as ( select cte.ItemNumber,cte.Typ_,cte.Period_YM,cte.Value,m.StandardCost,m.WholeSalePrice,p.Pareto,m.UOM,m.PrimarySupplier 					
										,m.PlannerNumber
										,m.SellingGroup,m.FamilyGroup,m.Family
										,case m.PlannerNumber when '20072' then 'Salmon Saeed'
															 when '20004' then 'Margaret Dost'	
															 when '20005' then 'Imelda Chan'
															 when '20071' then 'Domenic Cellucci'
															 else 'Unknown'
											end as Owner_
									from cte left join JDE_DB_Alan.Master_ML345 m on cte.ItemNumber = m.ItemNumber
										 left join JDE_DB_Alan.FCPRO_Fcst_Pareto p on cte.Itemnumber = p.ItemNumber
								 where 
										--m.PrimarySupplier in ( select data from JDE_DB_Alan.dbo.Split(@Supplier_id,','))
										-- cte.ItemNumber in ( select splitdata from JDE_DB_Alan.dbo.fnSplitString(@Item_id,','))
										--cte.ItemNumber in ('38.013.001','43.525.101')
										cte.ItemNumber in ('43.525.101','43.525.102','43.525.103','43.525.105','43.525.107','43.525.403','43.525.404','43.525.405','43.530.101','43.530.102','43.530.103','43.530.105','43.530.107','43.530.403','43.530.404','43.530.405')
							)
							--select * from comb_

					 ,staging as 
								(select comb_.*
										,c.LongDescription as SellingGroup_
										,d.LongDescription as FamilyGroup_
										,e.LongDescription as Family_0
										--,tbl.Family as Family_1
										--,f.StandardCost,f.WholeSalePrice
								from comb_ left join JDE_DB_Alan.MasterSellingGroup c on comb_.SellingGroup = c.Code
										 left join JDE_DB_Alan.MasterFamilyGroup d on comb_.FamilyGroup = d.Code
										 left join JDE_DB_Alan.MasterFamily e on comb_.Family = e.Code
								 )

					 ,comb as ( select * from staging )

					 ,fl as (	select comb.ItemNumber,'HD' as BranchPlant,comb.UOM,'BF' as ForcastType
							,comb.Period_YM
							,convert(date,dateadd(d,-1,dateadd(mm,0,convert(datetime,comb.Period_YM+'01',103))),103) as Period_YMD_1		-- to get 'Jde FC Date' Format ie 31/Month/Year,however when FC loaded into Jde, Jde will automatically add 1 day and push FC to Following month, ie 31/1/2018 FC will be push into Month slot of 1/Feb/2018, so here you need to change date again
							,convert(date,dateadd(d,-1,dateadd(mm,1,convert(datetime,comb.Period_YM+'01',103))),103) as Period_YMD_2        -- Current month + 1 month minus 1 day to get last day of same month , to get 'Jde FC Date' Format ie 31/Month/Year, get last day of last month 
							,convert(varchar(10),convert(date,dateadd(d,-1,dateadd(mm,1,convert(datetime,comb.Period_YM+'01',105))),103),103) Period_YMD_3 
							,comb.Typ_
							,comb.Value as Qty
							,comb.Value * comb.WholeSalePrice as Amt_Actual
							,0 as Amt
							,0 as CustomerNumber,'N' as BypassForcing,comb.Pareto 			
							,comb.PlannerNumber,comb.primarysupplier,comb.Owner_
							,comb.Family_0
							from comb

						--where comb.Typ_ in ('')
						
						--order by Pareto asc,comb.ItemNumber,comb.Typ_,comb.Period_YM

						)
				
				   --select * from fl
					  select fl.ItemNumber,fl.BranchPlant,fl.UOM,fl.ForcastType
						--	,fl.Period_YM,fl.Period_YMD_1,fl.Period_YMD_2
							,fl.Period_YMD_3,fl.Qty,fl.Amt,fl.CustomerNumber,fl.BypassForcing
							--,fl.Amt_Actual,fl.Pareto
					  from fl
					  where fl.Typ_ in ('Adj_FC')
					  order by Pareto asc,fl.ItemNumber,fl.Typ_,fl.Period_YM
					  option (maxrecursion 0)






----- ALWAYS ENTER YOUR CODE ABOVE THIS LINE -------- ----- ALWAYS ENTER YOUR CODE ABOVE THIS LINE -------- ----- ALWAYS ENTER YOUR CODE ABOVE THIS LINE --------
----- NEVER ENTER YOUR CODE BELOW THIS LINE --------- ----- NEVER ENTER YOUR CODE BELOW THIS LINE --------- ----- NEVER ENTER YOUR CODE BELOW THIS LINE ---------

 ---&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&------------------
-- END_EXIT:

-- last line of the script
set noexec off -- Turn execution back on; only needed in SSMS, so as to be able 
               -- to run this script again in the same session.



