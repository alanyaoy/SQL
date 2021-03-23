
 --------------------------------------  WhiteBoard  -----------------------------------------------

  ---=================How to Skip SQL Query --- Method 3   30/7/2018= ========================================= 
 --https://stackoverflow.com/questions/659188/sql-server-stop-or-break-execution-of-a-sql-script?noredirect=1&lq=1

print 'hi'
go

print 'Fatal error, script will not continue!'

set noexec on
print 'ho'
go


use JDE_DB_Alan
go


SELECT c.local_net_address
FROM sys.dm_exec_connections AS c
WHERE c.session_id = @@SPID;

SELECT TOP(1) c.local_net_address
FROM sys.dm_exec_connections AS c
WHERE c.local_net_address IS NOT NULL;

SELECT @@SERVERNAME
select * from sys.servers where is_linked = 1

select * from HD_2016EXPAD.JDE_DB_Alan.dbo.t1
select * from RYDWS366.HD_2016EXPAD.JDE_DB_Alan.dbo.cj				-- does not work !

select * from [RYDWS366\HD_2016EXPAD].JDE_DB_Alan.dbo.cj			-- works !		--10/12/2019
select * from [RYDWS366\HD_2016EXPAD].JDE_DB_Alan.jde_db_alan.vw_Mast  -- works !

;select * from [hd-vm-bi-sql01].HDDW_PRD.star.d_product p where p.item_code in ('44.011.007')

select * from  Jde_db_alan.FCPRO_Fcst fc where fc.ItemNumber like ('%40.033.131%') and fc.Date in ('2020-06-01')
select * from Jde_db_alan.FCPRO_Fcst fc where fc.ItemNumber like ('%40.033.131%') and fc.Date in ('2020-06-01')

select * from dbo.cj			-- works !

select * from JDE_DB_Alan.vw_Mast m where m.ItemNumber like ('38.%')
select * from JDE_DB_Alan.vw_Mast m where m.ItemNumber like ('34.7%')

select * from JDE_DB_Alan.vw_Mast m where m.ItemNumber like ('44.013.00%')



select distinct f.ItemNumber from  JDE_DB_Alan.FCPRO_Fcst f 
  where f.ItemNumber in ( select m.ItemNumber from JDE_DB_Alan.vw_Mast m where m.FamilyGroup in ('910') )

select distinct f.ItemNumber from  JDE_DB_Alan.FCPRO_Fcst f 
  where f.ItemNumber in ( select m.ItemNumber from JDE_DB_Alan.vw_Mast m where m.FamilyGroup in ('965') )




select * from JDE_DB_Alan.vw_Mast m where m.ItemNumber like ('42.361.%')
select * from JDE_DB_Alan.vw_Mast m where m.ItemNumber in ('7441500001','7441500182','7441500914','7441700001','7441700182','7441700914','7442700001','7442700182','7442700914','7456500182','7457500001','7457500182','7457500914','7460500000','7460700000','7468500001','7468500182','7468500914','7468700001','7468700182','7468700914','7477500001','7477500182','7477500914','7477700001','7477700182','7477700914','7478500001','7478500182','7478500914','7478700001','7478700182','7478700914','7479500001','7479500182','7479500914','7479700001','7479700182','7479700914','7485700000','7488500001','7488500182','7488500914','7488700001','7488700182','7488700914','7489500001','7489500182','7489500914','7489700001','7489700182','7489700914','7491500001','7491500182','7491500914','7491700001','7491700182','7491700914','7493500001','7493500182','7493500914','7493700001','7493700182','7493700914','7494500001','7494500182','7494500914','7494700001','7494700182','7494700914','7497700001','7497700182','7497700914','7498700001','7498700182','7498700914','7499700001','7499700182','7499700914','7766050000','7766070000','7766250000','46.508.500','46.508.700','46.531.500','46.531.700')
order by m.Pareto


select * from [JDE_DB_Alan].[SlsHistoryHD]

select * from [hd-vm-bi-sql01.hd.local].HDDW_PRD.star.d_product p where p.item_code in ('44.011.007')      --- works ! 3/6/2020  -- need to created new linked server : hd-vm-bi-sql01.hd.local
select * from [hd-vm-bi-sql01].HDDW_PRD.star.d_product p where p.item_code in ('44.011.007')              --- not working, if your linked server is : hd-vm-bi-sql01   3/6/2020


select p.item_code,p.Item_Number,p.stock_type_desc,m.Pareto,m.StockValue
	from [hd-vm-bi-sql01.hd.local].HDDW_PRD.star.d_product p left join JDE_DB_Alan.JDE_DB_Alan.vw_Mast m 
			on p.Item_code collate database_default  = m.ItemNumber collate database_default
	where p.item_code in ('RBSC','24.7334.0199') and p.jde_business_unit = 'HD'

select p.item_code,p.stock_type_desc,m.Pareto,m.StockValue
from [hd-vm-bi-sql01.hd.local].HDDW_PRD.star.d_product p left join JDE_DB_Alan.JDE_DB_Alan.vw_Mast m 
      on p.Item_code collate database_default  = m.ItemNumber collate database_default
	  where p.item_code in ('RBSC','24.7334.0199','42.210.031') and p.jde_business_unit = 'HD'



---------*********************************************************************************************************************---------
---=========== Use linked server hd-vm-bi-sql01.hd.local to created a query to query data in HDDDW ! 3/6/2020 ==========------



---------------  Get WO parts number from Work orders --------------------------------------        17/2/2020 ----------------------
 -------------  Get all Sales history On components level across HD and AWF channel ---- by exploring Comp level details from AWF Sales order ( breaks/exploded down to parts level from Finished Blinds to component ) --- 19/3/2020

select count(*) from HDDW_PRD.star.f_wo_parts_list      --- 17,656,155 rows , 96 columns --- huge table --- 2017 to 2019 ( total 3 years records of WO details )
select * from HDDW_PRD.star.f_wo_parts_list				--- 17 million records, appox 1 min = 1 million records ( nearlly 100 columns )
select top 3 *  from HDDW_PRD.star.f_wo_parts_list	


select l.wo_number from HDDW_PRD.star.f_wo_parts_list l    --- search 1 column only, it takes 2 mins

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
   
   ,part_list as 
   
	   (select so.order_number as So_num,so.work_order_number as So_wo_num,pr.wo_number as Part_wo_num
			 ,so.d_product_key as Parent_pd_key,so.item_code as Parent,pr.d_product_key Child_pd_key,pr.item_code as Child,pr.parts_description2,so.primary_quantity as ParentSoldQty,pr.quantity as ChildSoldQty,pr.uom Child_uom,c.contact_name as customer,so.order_date
		 from so left join [hd-vm-bi-sql01.hd.local].HDDW_PRD.star.f_wo_parts_list pr on so.work_order_number = pr.wo_number
			   left join  [hd-vm-bi-sql01.hd.local].HDDW_PRD.star.d_product pd on so.d_product_key = pd.d_product_key 
			   left join [hd-vm-bi-sql01.hd.local].HDDW_PRD.star.d_customer c on so.d_customer_key = c.d_customer_key
		  where --so.item_code in ('FAMT')
		  --  and so.jde_business_unit = 'AWF'    
			--and so.work_order_number = '04685890'   
			--and pr.item_code in ('42.421.855','52.018.000','44.011.007')
			-- so.order_number in ('5641025')						--  Fabrique store Project - DUMMY ORDER FOR FABRIQUE FOR LARGE COMMERCIAL ORDER 5641025 -- 1/6/2020
		    so.order_number in ('5642227')							--  NELLIE MELBA RETIREMENT Vic            11/6/2020

			)
	  select p.*,m.PlannerNumber from  part_list p left join JDE_DB_Alan.vw_Mast m 
				-- on p.Child COLLATE Latin1_General_CS_AS = m.ItemNumber COLLATE Latin1_General_CS_AS			--- works 3/6/2020    'The root cause is that the sql server database you took the schema from has a collation that differs from your local installation. If you don't want to worry about collation re install SQL Server locally using the same collation as the SQL Server 2008 database.
				 on p.Child	COLLATE DATABASE_DEFAULT = m.ItemNumber COLLATE DATABASE_DEFAULT			 --- works 3/6/2020			'This is extremely useful. I'm using a local database and querying against a linked server and they have two different collations. Obviously I can't change the collation on the linked server, and I didn't want to change mine locally, so this is absolutely the best answer. 


---===============================================================================================================================------


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


 ------------- Vendor XRef Cross Ref---------------------- 9/9/2020  

-- select * from JDE_DB_Alan.vw_Mast m where m.StockingType in ('P','Q','S','M')  	--- 48,652 records   --- 7107 active items  14%, 86% rubbish
-- select * from JDE_DB_Alan.Master_Vendor_Item_CrossRef c							--- 32,640 records		 --- 8493 active items 26%, 74% rubbish

/****** Script for SelectTopNRows command from SSMS  ******/
SELECT m.*,c.Customer_Supplier_ItemNumber,c.Address_Number,c.EffectiveDate,c.ExpiredDate
  FROM JDE_DB_Alan.vw_Mast m left join JDE_DB_Alan.Master_Vendor_Item_CrossRef c
      on m.ShortItemNumber = c.ShortItemNumber
      and m.PrimarySupplier = c.Address_Number

where m.StockingType in ('P','Q','S','M')                       --- 7445 
     -- and c.Customer_Supplier_ItemNumber is null				--- 1983	
	  -- and c.Customer_Supplier_ItemNumber is not  null		-- 5459, sometime null means Xref has not updated yet, not necessarily does not have one
	 -- and m.ItemNumber in ('26.108.000')
	  and c.ExpiredDate = '1950-12-31'							-- 5071 


select * 
	from JDE_DB_Alan.vw_Mast m left join 

	(select  c.ShortItemNumber,c.Customer_Supplier_ItemNumber,c.Address_Number,c.EffectiveDate,c.ExpiredDate
		from JDE_DB_Alan.Master_Vendor_Item_CrossRef c
		where c.ShortItemNumber in ( select a.ShortItemNumber from JDE_DB_Alan.vw_Mast a where a.StockingType in  ('P','Q','S','M')   )
		)tb  on m.ShortItemNumber = tb.ShortItemNumber and m.PrimarySupplier = tb.Address_Number

where m.StockingType in ('P','Q','S','M')  
      and tb.ExpiredDate = '1950-12-31'

select * from JDE_DB_Alan.vw_Mast_Vendor_Item_CrossRef m where m.ItemNumber in ('26.108.000')

select * from JDE_DB_Alan.vw_Mast m where m.ItemNumber in ('26.805.000')

--------------------------------------------------------------------------------



 ----------------- Update FC using temp table  25/2/2020 --------- works ! -------------------------

 SELECT Name
FROM sys.procedures
--WHERE OBJECT_DEFINITION(OBJECT_ID) LIKE '%TableNameOrWhatever%'
  WHERE OBJECT_DEFINITION(OBJECT_ID) LIKE '%Master_Vendor_Item_CrossRef%'

 SELECT Name
FROM sys.procedures
--WHERE OBJECT_DEFINITION(OBJECT_ID) LIKE '%TableNameOrWhatever%'
  WHERE OBJECT_DEFINITION(OBJECT_ID) LIKE '%CrossRef%'

select * from JDE_DB_Alan.MasterFamily m where m.code in ('653')

select * from JDE_DB_Alan.MasterFamily m where m.code like ('%653&')

select * from JDE_DB_Alan.FCPRO_Fcst_History h  where h.ItemNumber in ('38.001.005') and h.ReportDate between '2020-02-01' and '2020-02-25' 
select * from JDE_DB_Alan.FCPRO_Fcst_History h  where h.ItemNumber in ('6001130009010H') and h.ReportDate between '2020-02-01' and '2020-02-25' 

select * from JDE_DB_Alan.FCPRO_Fcst f where f.ItemNumber in ('38.001.005') and f.DataType1 = 'Adj_FC' 
select * from JDE_DB_Alan.FCPRO_Fcst f where f.ItemNumber in ('6001130009010H') and f.DataType1 = 'Adj_FC' 



declare @fc table ( item varchar(100),datatype varchar(100),fcdate datetime,fcqty decimal(18,0))

select * from JDE_DB_Alan.vw_Mast m
--where m.Family in ('E23','E24')
--where m.ItemNumber in ('44.011.007')
where m.ItemNumber in ('43.212.001')
--where m.ItemNumber in ('26.800.963','26.800.820','26.800.971','26.800.830','26.800.659','26.800.676','26.801.963','26.801.820','26.802.963','26.802.820','26.802.971','26.802.830','26.802.659','26.802.676','26.803.963','26.803.820','26.803.971','26.803.830','26.803.659','26.803.676')

select * from JDE_DB_Alan.FCPRO_SafetyStock s 

select * from JDE_DB_Alan.vw_FC



select * from JDE_DB_Alan.vw_Mast m
select * from JDE_DB_Alan.Master_ML345 m

where m.Family in ('89K','89J','89S','89T') 
     
  and m.StockingType in ('P') order by m.ItemNumber
where m.ItemNumber like ('24.7207.%')




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

;update f
 set f.value = 33
  from JDE_DB_Alan.FCPRO_Fcst f                                                                              
     where f.ItemNumber = '6001130009010H' and f.DataType1 ='Stat_FC' and f.ReportDate between '2020-02-01' and '2020-02-25' 




------- 11/1/2021 -------------

select * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload d where d.ItemNumber in ('42.210.031')
select * from JDE_DB_Alan.vw_Sls_History_HD h where h.ItemNumber_ in ('42.210.031')
select max(h.SlsMth_latest) as LatestMonth from JDE_DB_Alan.vw_Sls_History_HD h
select cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-',''),1,6) as integer)
select cast(SUBSTRING(REPLACE(CONVERT(char(10),getdate(),126),'-',''),1,6) as integer)

select cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-',''),1,6) as integer) - max(h.SlsMth_latest) as LatestMonth from JDE_DB_Alan.vw_Sls_History_HD h

 select cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE()),0),126),'-',''),1,6) as integer) - max(h.SlsMth_latest) as LatestMonth from JDE_DB_Alan.vw_Sls_History_HD h
-------- 03/03/2020 ------------

--SELECT distinct h.ItemNumber
select * 
  FROM [JDE_DB_Alan].[JDE_DB_Alan].[SlsHistoryHD] h
  where h.ItemNumber in ('1444004701','1444004528','1444004707','1444004721','1444004503','1444004708','1444004806','1444004853','1444004859','1444004722')


select * from JDE_DB_Alan.vw_Mast m where m.ItemNumber in 
('1444004701','1444004528','1444004707','1444004721','1444004503','1444004708','1444004806','1444004853','1444004859','1444004722')


select * from JDE_DB_Alan.FCPRO_NP_tmp p where p.ItemNumber in ('38.013.001')

select * from JDE_DB_Alan.vw_Mast m where m.ItemNumber in ('26.812.410','26.812.901','26.812.604','26.812.820','26.812.902','26.812.962','26.815.410','26.815.901','26.815.604','26.815.820','26.815.902','26.815.962','26.814.410','26.814.901','26.814.604','26.814.820','26.814.902','26.814.962')

select * from JDE_DB_Alan.vw_Mast m where m.ItemNumber in  ('18.010.035','18.010.036','18.607.016','18.615.007','24.5418.0000','24.7102.7052A','24.7120.0952','24.7121.0952','24.7122.0952','24.7124.0952','24.7127.0952','24.7200.0001','24.7220.0952','24.7334.0952','32.379.200','32.380.002','32.455.155','32.501.000','43.525.105','82.696.931')
select * from JDE_DB_Alan.Master_ML345

select * from JDE_DB_Alan.OpenPO
select * from JDE_DB_Alan.FCPRO_Fcst f


select * f
select distinct f.DataType1 from JDE_DB_Alan.vw_FC f
select f.ItemNumber,f.DataType1,f.FCDate_,f.fcyr,f.fcmth,f.fcdte,f.FC_Vol from JDE_DB_Alan.vw_FC f 
where f.ItemNumber in ('42.210.031','1019884')


select * from JDE_DB_Alan.vw_FC 


-------- 04/03/2020 ------------
select * from JDE_DB_Alan.OpenPO p where p.ItemNumber in ('24.7209.1858')


-------- 06/03/2020 ------------
select * from JDE_DB_Alan.vw_Mast m where m.ItemNumber in ('7236120001','7236127035','7236120049','42.210.031')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('7236120001','7236127035','7236120049','42.210.031')
select * from JDE_DB_Alan.vw_Mast m where m.ItemNumber in ('2780135000B')

select * from JDE_DB_Alan.vw_Mast m where m.ItemNumber in ('82336.3000.00.20')

select * from JDE_DB_Alan.vw_Mast m where m.ItemNumber like ('82336%')


-------- 12/03/2020 ------------
select * from JDE_DB_Alan.vw_Mast m where m.FamilyGroup in ('989') and m.StockingType not in ('O','U')
select * from JDE_DB_Alan.Master_ML345 m


select * from JDE_DB_Alan.TextileWC 
-------- 17/03/2020 ------------
select m.ItemNumber,m.PlannerNumber,m.Owner_,m.SupplierName,m.SupplierName

select distinct m.SupplierName,m.PrimarySupplier
from JDE_DB_Alan.vw_Mast m
where m.PrimarySupplier in ('2829284')
--where m.PlannerNumber = '20072'
order by m.SupplierName

where m.SupplierName like ('pan%')
where m.ItemNumber in ('18.010.035','18.010.036','18.607.016','18.615.007','24.5398.0000','24.7120.0155','24.7121.0155','24.7122.0155','24.7125.0155','24.7127.0155','24.7146.0155A','24.7163.0000A','24.7168.0155A','24.7169.0155A','24.7200.0001','24.7207.0199','24.7208.0199','24.7209.0199','24.7219.4459','24.7240.0199','24.7257.0952','24.7333.0199','24.7362.1858','32.340.000','32.379.200','32.455.155','32.501.000','82.691.909')

-------- 30/03/2020 -- 14/2020------------
select m.*,m.ItemNumber,m.PlannerNumber,m.Owner_
from JDE_DB_Alan.vw_Mast m
where  m.ItemNumber in ('43.477.532')
	  --m.ItemNumber like ('44.015.404')
      -- m.ItemNumber like ('42.%') and m.FamilyGroup in ('989')

select *
from JDE_DB_Alan.FCPRO_Fcst_History h 
where h.ReportDate between '2019-03-02' and '2020-03-25 17:00:00'

select *
from JDE_DB_Alan.vw_Mast m
 where m.ItemNumber in ('24.7220.0199','32.501.000','18.010.035','18.615.007','18.010.036','43.212.001','32.379.200','32.380.002','18.013.089','24.7200.0001','24.7206.0000','24.7100.0199','24.7100.0199','32.455.155','24.7110.0155','24.7121.0155','24.7122.0155','24.7124.0155','24.7127.0155','24.5353.0204','24.7120.0155')
 --where m.ItemNumber like ('44.010.007')
--where m.FamilyGroup in ('964') and m.StockingType not in ('O','U')

select *
from JDE_DB_Alan.vw_FC f left join JDE_DB_Alan.vw_Mast m on f.ItemNumber = m.ItemNumber
where m.FamilyGroup in ('964')

select distinct f.ItemNumber
from JDE_DB_Alan.vw_FC f left join JDE_DB_Alan.vw_Mast m on f.ItemNumber = m.ItemNumber
where m.FamilyGroup in ('964')


select *
from JDE_DB_Alan.vw_Mast m
where m.ItemNumber in ('6000130009004H','82.601.901')
--where m.ItemNumber in ('24.7121.0155','24.7122.1858')

select m.ItemNumber,m.StockingType,m.FamilyGroup,m.Family_0,m.FamilyGroup_,m.Family,m.Description
from JDE_DB_Alan.vw_Mast m
where m.ItemNumber in ('587002','42.198.000','585020','42.421.855','46.598.000','594001','591010','42.327.215','588002','510511','52.003.032','42.206.031','580011','44.011.007','42.151.855','42.187.855','52.002.000','46.610.000','42.328.000','588001','40.367.173','42.218.031','52.018.000','46.019.000','42.357.252','44.011.003','44.016.404','18.013.090','42.056.000','44.011.004','46.599.000','596555','52.012.000','510144','44.016.408','44.132.000','82.401.024','52.004.000','44.011.006','46.002.000','42.220.031','42.512.000','591050','46.306.000','42.613.886','52.001.134','46.508.500','44.010.007','46.612.700','52.013.000','44.015.404','42.211.031','42.210.031','44.016.405','44.012.007','42.057.000','42.212.031','42.357.131','45.032.063','596547','46.011.000','42.357.481','46.506.000','42.357.804','46.005.000','46.019.063','42.357.493','52.010.032','44.016.808','52.005.000','46.612.500','42.607.032','52.016.000','46.524.000','46.011.134','42.157.031','44.011.002','46.012.000','44.017.405','46.607.000','42.184.049','46.606.000','52.020.000','44.011.005','52.000.063','52.015.000','42.236.000','46.607.134','82.401.015','46.606.134','52.008.000','52.021.000','82.401.022','42.601.886','596557','46.203.000','591012','42.209.031','46.611.000','46.521.700','46.609.000','42.357.286','46.507.000','44.010.004','42.334.000','7156010000','46.002.063','46.419.000','44.012.004','82.401.012','42.077.032','52.014.000','46.108.063','46.505.000','44.015.405','46.011.850','44.012.003','46.021.000','46.005.850','42.213.031','46.517.000','44.011.001','46.005.134','52.016.100','46.011.100','46.012.850','46.615.063','42.230.000','46.606.850','45.624.000','46.607.850','46.502.837','45.658.000','46.500.000','42.320.493','46.012.134','42.614.063','46.607.100','52.008.100','46.607.810','46.606.100','52.011.030S','42.180.049','52.020.100','52.021.100','52.016.134','46.614.700','42.323.031','46.606.810','42.320.850','46.608.000','52.007.063','44.016.107','46.005.100','52.027.000','46.504.000','52.006.000','52.029.010','46.011.810','82.401.013','42.206.063','44.010.006','46.602.134','82.401.004','46.421.000','596554','52.009.000','52.015.100','52.014.100','52.030.000','44.012.008','52.021.134','42.645.002','42.505.000','52.020.134','42.506.030','46.005.810','42.064.000','42.058.000','46.607.734','52.008.134','46.606.734','46.012.810','52.001.850','42.320.481','52.004.000V','52.022.000','510003','82.401.023','52.015.134','46.422.030','46.012.100','82.401.001','46.423.100','42.357.273','44.016.505','42.357.810','42.357.805','46.530.063','46.011.734','82.401.002','44.004.103','46.614.500','52.014.134','46.004.134','46.602.000','46.004.000','40.340.173','42.320.252','18.616.003','44.003.104K','42.320.804','46.608.134','594003','82.296.943','82.401.019','510002','44.005.104K','46.603.134','44.010.003','46.602.100','46.603.000','44.005.102K','42.062.000','82.401.016','34.249.000','46.502.100','52.016.810','709847','34.097.000','18.099.032','46.513.000','42.060.000','46.606.737','52.008.810','52.021.850','82.401.008','46.518.063','46.607.737','46.005.734','82.296.972','6610260000','52.021.810','46.601.000','42.501.855','82.401.017','52.020.850','46.600.000','46.012.734','82.401.009','46.013.000','52.020.810','18.696.031','46.602.810','46.502.122','46.004.100','44.004.114K','46.011.737','40.371.173','52.017.000','46.608.850','42.357.104','44.010.001','52.016.850','46.608.100','46.005.737','46.602.734','42.361.493','46.004.810','52.014.850','52.015.810','34.260.000','44.004.104K','34.096.000','52.014.737','46.514.000','82.401.020','42.632.855','46.608.810','46.603.100','52.022.100','34.020.000','42.655.000','45.623.000','52.008.734','46.012.737','46.603.810','52.016.734','44.003.114K','42.631.855','44.003.113K','52.014.810','82.296.965','42.361.173','44.010.005','510190','510182','42.214.031','52.015.734','46.419.100','52.021.734','42.649.850','42.157.063','82.296.953','6610200000','34.216.000','52.020.734','82.401.003','52.015.850','44.010.002','42.333.000','46.608.734','34.230.000','52.016.737','42.651.000','46.004.734','82.296.986','52.020.737','52.021.737','42.361.481','52.017.134','42.630.493','42.320.810','6610300000','52.008.737','46.550.000','46.016.000','44.005.102','7761030001','42.063.000','82.296.973','46.602.737','45.305.000','42.623.031','42.211.063','46.013.100','42.630.252','42.361.804','594011','46.013.850','46.608.737','46.603.734','46.004.737','42.361.252','46.013.134','52.022.134','42.320.273','42.068.000','40.379.000','52.008.850','42.113.032','46.420.000','52.015.737','82.296.925','42.611.886','46.601.100','82.296.918','82.296.947','46.600.100','42.221.031','52.014.734','42.054.000','46.521.500','42.630.173','46.512.000','42.320.805','82.296.996','42.320.104','46.603.737','42.630.481','34.231.000','82.296.970','82.296.939','42.630.804','82.296.913','7156130000','46.013.810','510140','46.601.810','82.297.949','42.212.063','42.196.031','42.466.030','82.296.909','7441500182','82.296.905','82.296.950','591024','82.297.957','82.296.969','82.296.944','42.610.855','510139','52.022.850','42.222.031','42.157.030','82.296.906','7460700000','46.013.737','44.003.114','42.622.000','52.022.810','82.296.957','82.296.907','46.604.000','42.647.493','82.296.936','42.647.173','42.194.031','42.215.031','46.510.000','46.013.734','42.152.850','46.515.000','82.296.946','45.682.100','52.032.030','46.423.850','42.647.804','45.678.100','52.031.030','82.401.018','46.604.134','42.630.185','52.017.100','45.679.100','34.095.000','585021','82.296.933','46.604.100','42.209.063','42.361.810','82.296.956','42.502.000','42.630.810','34.259.000','34.258.000','46.553.063','42.647.481','45.680.100','82.401.006','45.223.100','42.630.104','34.240.000','52.022.734','45.677.100','45.683.100','42.213.063','42.503.000','45.681.100','42.647.252','34.506.000','82.296.934','510181','46.600.810','45.071.063','42.361.273','42.647.104','46.604.737','705266','82.296.951','82.296.932','42.361.805','7493700914','7478700914','46.414.000','82.401.007','82.296.948','6610340000','6611550000','42.062.173','7479500001','52.022.737','46.604.734','82.297.950','510005','42.055.000','82.296.922','82.296.940','7127930001','42.647.810','44.133.120','42.361.104','46.423.134','46.604.810','46.601.734','46.601.737','45.143.000','82.296.931','510161','46.425.100','590022','82.297.952','45.522.000','510160','7122930182','46.600.734','45.221.100','82.297.948','7457500182','46.600.737','45.057.063','45.403.100','82.297.956','42.065.000','82.296.952','42.180.131','7127910001','44.004.113K','46.020.000','46.205.000','7233020000','42.223.031','46.025.000','7390060182','46.516.000','52.034.000','46.553.030','7127990182','82.296.949','7232127035','7127860182','45.506.000','46.424.100','510705','45.632.000','34.224.000','7127890001','7232147035','52.017.810','7495500001','7153080914','46.020.100','7491500182','7122570182','45.645.100','7126070001','42.611.000','7390400914','7126070914','7127890914','7127910914','42.647.185','7127990001','7495500914','7468500182','82.296.935','42.647.805','45.517.000','510101','7468500914','510709','34.239.000','7394350914','45.625.820','45.288.100','45.402.100','7236010182','7468700182','7394350001','7495700914','45.254.100','7151040914','510074','510070','510145','34.201.000','7495500182','7326080000','42.066.000','510706','7468700914','7127850182','34.246.000','510151','7123080182','45.132.100','45.642.100','45.646.000','45.659.000','510071','7127940914','7390400001','7468500001','510075','45.656.100','42.067.000','7127940001','7127890182','7493700001','7326020000','46.561.000','45.122.100','45.283.000','45.273.100','46.560.000','7370400914','7370350001','7370250001','7491700914','34.237.000','7390300001','7370200182','510072','7326030000','7127620182','45.123.100','45.127.000','45.148.100','7350200001','45.115.000','7390030001','7127710914','7350150001','7152070182','709838','7122720182','7390030182','7232187035','510073','7122910049','45.120.100','45.136.000','45.298.100','45.121.000','45.312.100','45.404.100','45.118.000','7326010000','7390030914','7151030914','45.117.100','45.252.100','45.126.100','45.129.100','45.670.820','45.311.100','82.296.910','7151030001','7390200182','7127660182','7127710182','42.359.286','7122720049','7127710001','34.241.000','7151040001','7122950914','7350200914','7742140001','45.312.000','45.401.100','45.127.100','45.146.000','45.138.100','45.665.063','52.017.734','45.618.100','7127910182','45.103.100','7476500182','7151030182','7390400182','7495700001','7122930049','7370300182','6610520000')

select m.ItemNumber,m.StockingType,m.FamilyGroup,m.Family_0,m.FamilyGroup_,m.Family,m.Description
from JDE_DB_Alan.vw_Mast m
where m.Family in ('89J','89K','89L')
order by m.Family



select * from JDE_DB_Alan.TextileFC f
--where f.ArticleNumber in ('RLAA132A118F')
where f.Reportdate > '2020-10-19'
order by f.Reportdate desc

select dateadd(s,-1,dateadd(d, datediff(d,0, getdate()), 0) )

-------- 4/4/2020  -----------------




select * 
from JDE_DB_Alan.FCPRO_MI_2_Raw_Data_tmp mi2
where mi2.ItemID in ('40.153.131')


select distinct f.ItemNumber from JDE_DB_Alan.FCPRO_Fcst f 
where f.DataType1 in ('Adj_FC')

select * from JDE_DB_Alan.FCPRO_Fcst f 
where f.ItemNumber in ('40.381.000','42.210.031') and f.DataType1 in ('Adj_FC')



---- Nordic range ----- 14/7/2020

--select f.*,m.StockingType,m.PlannerNumber
select f.ItemNumber,avg(f.Value) as fc_avg
from JDE_DB_Alan.FCPRO_Fcst f left join JDE_DB_Alan.vw_Mast m on f.ItemNumber = m.ItemNumber
where f.ItemNumber in
('24.7121.0155','24.7100.0199','24.7002.0001T','32.380.002','32.379.200','24.7120.0155','24.7127.0155','24.7124.0155','24.7220.0952','32.455.155','24.7122.0155','24.7218.0199','24.7201.0000T','24.7121.1858','24.5417.0000','24.7100.1858','24.7120.1858','24.7128.0155A','24.7218.1858','24.7002.0001','24.7110.0155','24.7127.1858','24.7220.0199','24.5415.0000','24.7102.0199','24.7122.1858','24.7200.0000T','32.455.855','24.5416.0000','24.5414.0000','24.5427.0204','32.380.855','24.7206.0000','24.5349.0204','24.5413.0000','24.5353.0204','82.633.902','82.633.901')
--('7122720049','7123050049','7123060049','7127140914','7127180914','7127510914','7129200914','7134210914','7134220001','7134220182','7134220914','7134230001','7134230182','7134230914','7152070914','7152090914','7370200001','7370200182','7370200914','7370250001','7370250182','7370250914','7370300001','7370300182','7370300914','7370350001','7370350182','7370350914','7370400001','7370400182','7370400914','7475500914','7476500914','7477500914','7477700914','7478500914','7478700914','7479500914','7479700914','42.653.000','42.652.000','42.654.000','42.655.000','42.655.850','6610200000','6610220000','6610260000','6610300000','6610340000','6610350000','6610420000','6610480000','6610490000','6610520000','6610580000','6610660000','6610690000','6610930000','6610940000','6611000000','6611060000','6611080000','6611500000','6611510000','6611530000','6611550000','6658500000','7122570001','7122570049','7122570182','7122630001','7122630049','7122630182','7122640001','7122640049','7122640182','7122720001','7122720182','7122900001','7122900049','7122900182','7122910001','7122910049','7122910182','7122920001','7122920049','7122920182','7122930001','7122930049','7122930182','7122950001','7122950182','7122950914','7122960000','7123050001','7123050182','7123051901','7123060001','7123060182','7123061901','7123070001','7123070049','7123070182','7123080001','7123080182','7123080914','7124010001','7124010049','7124010182','7124100001','7124100049','7124100182','7124130001','7124130049','7124130182','7124170001','7124170049','7124170182','7126070001','7126070182','7126070914','7127140001','7127140182','7127150001','7127150182','7127150914','7127180001','7127180182','7127190000','7127500000','7127510001','7127510182','7127600001','7127600182','7127600914','7127620001','7127620182','7127620914','7127650001','7127650182','7127650914','7127660001','7127660182','7127660914','7127690001','7127690182','7127690914','7127710001','7127710182','7127710914','7127800001','7127800182','7127800914','7127850001','7127850182','7127850914','7127860001','7127860182','7127860914','7127890001','7127890182','7127890914','7127900001','7127900182','7127900914','7127910001','7127910182','7127910914','7127930001','7127930182','7127930914','7127940001','7127940182','7127940914','7127950001','7127950182','7127950914','7127960001','7127960182','7127960914','7127970001','7127970182','7127970914','7127990001','7127990182','7127990914','7129200001','7129200182','7134210001','7134210182','7137030000','7137040000','7137050000','7139020000','7143010000','7143020000','7144930000','7146040000','7146180001','7146180049','7146180182','7146500001','7146500182','7146500914','7146580001','7146580049','7146580182','7151030001','7151030182','7151030914','7151040001','7151040182','7151040914','7152070001','7152070182','7152090001','7152090182','7153060001','7153060182','7153060914','7153080001','7153080182','7153080914','7153090001','7153090182','7153090914','7156010000','7156130000','7220050000','7231010000','7231020000','7231060000','7231150000','7231160000','7232080001','7232080049','7232087035','7232127035','7232147035','7232160001','7232160049','7232167035','7232187035','7232247035','7233020000','7233040000','7233080000','7233100000','7233110000','7233120000','7236010001','7236010182','7236010914','7236040000','7236040001','7236080001','7236087035','7236120001','7236120049','7236127035','7321210001','7326000000','7326010000','7326020000','7326030000','7326080000','7350150001','7350150182','7350150914','7350200001','7350200182','7350200914','7350250001','7350250182','7350250914','7350300001','7350300182','7350300914','7390020001','7390020182','7390020914','7390030001','7390030182','7390030914','7390060001','7390060182','7390060914','7390160001','7390160182','7390160914','7390200001','7390200182','7390200914','7390250001','7390250182','7390250914','7390300001','7390300182','7390300914','7390350001','7390350182','7390350914','7390400001','7390400182','7390400914','7390930001','7390930182','7390930914','7390950001','7390950182','7390950914','7394160001','7394160182','7394160914','7394200001','7394200182','7394200914','7394250001','7394250182','7394250914','7394300001','7394300182','7394300914','7394350001','7394350182','7394350914','7394400001','7394400182','7394400914','7441500001','7441500182','7441500914','7441700001','7441700182','7441700914','7456500001','7456500182','7456500914','7457500001','7457500182','7457500914','7460500000','7460700000','7468500001','7468500182','7468500914','7468700001','7468700182','7468700914','7475500001','7475500182','7476500001','7476500182','7477500001','7477500182','7477700001','7477700182','7478500001','7478500182','7478700001','7478700182','7479500001','7479500182','7479700001','7479700182','7483500001','7483500182','7483500914','7483700001','7483700182','7483700914','7485700000','7488500001','7488500182','7488500914','7488700001','7488700182','7488700914','7489500001','7489500182','7489500914','7489700001','7489700182','7489700914','7491500001','7491500182','7491500914','7491700001','7491700182','7491700914','7493500001','7493500182','7493500914','7493700001','7493700182','7493700914','7494500001','7494500182','7494500914','7494700001','7494700182','7494700914','7495500001','7495500182','7495500914','7495700001','7495700182','7495700914','7497700001','7497700182','7497700914','7498700001','7498700182','7498700914','7499700001','7499700182','7499700914','7742140001','7742140182','7742140914','7747720000','7761030001','7761030049','7761030182','7766030000','7766050000','7766070000','7766250000','7766270000','9990710')
  and f.DataType1 in ('Stat_FC')
  and f.Date < '2021-01-01'
  --and f.ItemNumber in ('24.5349.0204')
  group by f.ItemNumber
  order by avg(f.Value) desc


select * from JDE_DB_Alan.vw_Mast m
where m.ItemNumber in ('24.7202.0000','24.7202.0001','24.7364.1858','82.301.922','2801462000')
--where m.ItemNumber in ('7123050049','7127140914','7127180914','7134220001','7134220182','7134220914','7134230182','7152070914','7152090914','7370200001','7370400001','7370400182','7475500914','7476500914','42.653.000','42.655.850','6611500000','7122950182','7122960000','7123050001','7123050182','7123051901','7123070001','7123070049','7123070182','7124100049','7124170001','7127140001','7127140182','7127180001','7127180182','7127190000','7127800182','7137030000','7137040000','7137050000','7139020000','7152070001','7152070182','7152090001','7152090182','7153060001','7153060182','7153060914','7153080001','7153080182','7153090001','7153090182','7220050000','7231010000','7232080001','7232080049','7232247035','7233080000','7233120000','7236010001','7236010182','7236010914','7236087035','7321210001','7350200182','7394160001','7394160182','7394160914','7394200001','7394200914','7394250001','7394250182','7394300001','7394300182','7394300914','7394350182','7394400001','7456500182','7475500001','7475500182','7476500001','7476500182','7483700001','7483700914','7485700000','7491500001','7491700001','7742140914','7761030049','7761030182','9990710')


select * from JDE_DB_Alan.FCPRO_Fcst_History fh 
where fh.ItemNumber in ('42.210.031') and fh.DataType1 in ('Adj_FC')
	  and fh.ReportDate between '2020-05-01' and '2020-05-18 17:00:00:00'
	  and fh.Date between '2020-05-01' and '2020-10-01'

	  
--select distinct h.ItemNumber
select h.*,concat(h.Century , h.FinancialYear,h.FinancialMonth) as YY, abs( h.Quantity) as Quantities
from JDE_DB_Alan.SlsHistoryHD h
--from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h
where h.ItemNumber in('34.215.000','34.216.000','34.230.000','34.232.000','34.233.000','34.234.000','34.242.000')
--where h.ItemNumber in ('1003724','3400070785','3400112300','3400114300','3400238000','3400272048','3400272064','3400272428','3400272785','3400272810','3400320000','3400350661','3400350785','3400382000','3400383000','3400669048','3400669320','3400669370','3400669661','3400669765','3400669810','3400674000','3400675000','3400679000','3400680000','3400715320','3401095048','3401095320','3401095370','3401095661','3401095765','3401095810','3402194000','3403854500','4150085250','4600300296','KIT9203','KIT9205','KIT9206','342J47622','342J47623','342J47627','342J6108141','342J6108144','342J6108146','342J6108221','342M4501','342M4502','342M4509','342M4511','342M45591','342M45592','342M45594','342M45595','342M45596','342M45599','342P4541','342P4544','342P4547','342P4548','342Q296401','342Q296402','342Q296403','342Q296404','342Q296410','342Q296411','FJ47108A623','FJ5108A141','FJ5108A146','FJ5108A221','FM3108A501','FM3108A502','FM45108A591','FM45108A594','FM45108A599','FP3108A541','FP3108A544','FP3108A548','FPH3108A541','FPH3108A544','FPH3108A547','FPH3108A548','FQ1096A401','FQ1096A402','FZ30088A401','FZ30088A402','FZ40088A501','FZ40088A502','FZ42088A541','FZ42088A544','FZ42088A547','FZ42088A548','FZ45088A591','FZ45088A594','FZ45088A599','FZ47088A623','FZ5088A141','FZ5088A146','FZ5088A221','FZH42088A541','FZH42088A544','FZH42088A547','FZH42088A548','J47108A623','J6096A221','J6108A141','J6108A146','J6108A221','M4108A501','M4108A502','M45108A591','M45108A594','M45108A599','P4108A541','P4108A544','P4108A547','P4108A548','P4H108A541','P4H108A544','P4H108A547','P4H108A548','Q2096A401','Q2096A402','Z18088A141','Z18088A146','Z18088A221','Z27088A401','Z27088A402','Z41088A501','Z41088A502','Z43088A541','Z43088A544','Z43088A547','Z43088A548','Z43H088A541','Z43H088A544','Z43H088A547','Z43H088A548','Z45088A591','Z45088A594','Z45088A599','Z47088A623')


select distinct m.NewItemNumber
from JDE_DB_Alan.MasterSuperssionItemList m
where m.NewItemNumber in ('1003724','3400272048','3400350661','3400669048','3400669370','3400669765','3401095048','342J47622','342J47627','342J6108144','342M4509','342M4511','342M45592','342M45595','342M45596','342Q296403','342Q296404','342Q296410','342Q296411','FPH3108A541','FPH3108A544','FPH3108A547','FPH3108A548','FZH42088A541','FZH42088A544','FZH42088A547','FZH42088A548','J6108A221','P4108A544','P4H108A541','P4H108A544','P4H108A547','P4H108A548','Z43H088A541','Z43H088A544','Z43H088A547','Z43H088A548','Z47088A623')

---------- 28/5/2020 ------------------
  select * 
  FROM [JDE_DB_Alan].[FCPRO_SafetyStock] s
  where s.ItemNumber in ('FT.01391.000.00','26.144.0204')


select * from JDE_DB_Alan.vw_Mast_Vendor_Item_CrossRef v


select distinct m.SellingGroup_,m.FamilyGroup_,m.FamilyGroup,m.Sls_Cd1 from JDE_DB_Alan.vw_Mast_Planning m
order by m.SellingGroup_,m.FamilyGroup_,m.FamilyGroup,m.Sls_Cd1

select * from JDE_DB_Alan.vw_Mast_Planning m where m.Item_Number in ('52.008.104','42.210.031')

select * from JDE_DB_Alan.vw_Mast m
where m.ItemNumber in ('82.691.903')




--------- COVID-19 forecast update April -------------- 30% down except 3 areas        ------ 7/4/2020
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


--------- COVID-19 forecast update May -------------- 15% down except 3 areas        ------ 13/5/2020
;update f
set f.Value = f.value /0.85
from JDE_DB_Alan.FCPRO_Fcst f
where --f.ReportDate between '2020-04-01' and '2020-09-01 13:00:00'
       f.ItemNumber in ('42.210.031')
     --where f.ItemNumber in ('38.001.005') 
     --  and f.Date = '2020-04-01'
	  and f.Date between '2020-05-01' and '2020-10-01'
	  and f.DataType1 = 'Adj_FC'

select * from JDE_DB_Alan.FCPRO_Fcst_History f where f.ItemNumber in ('34.267.0155') and f.DataType1 in ('adj_fc')
select distinct f.ItemNumber from JDE_DB_Alan.FCPRO_Fcst f

;update f
set f.Value = f.value * 0.85
from JDE_DB_Alan.FCPRO_Fcst f
where 
       f.ItemNumber not in  ('25.020.0155','25.020.1858','25.021.0155','25.021.1858','25.022.0155','25.022.1858','25.023.0155','25.023.1858','25.024.0155','25.024.1858','25.025.0155','25.025.1858','25.026.0155','25.026.1858','25.027.0155','25.027.1858','25.028.0155','25.028.1858','25.029.000','25.030.0155','25.031.0155','25.030.1858','25.031.1858','25.032.000','25.033.000','25.034.000','25.035.000','25.036.000','25.037.030','25.038.0155','25.039.0155','25.038.1858','25.039.1858','25.040.0155','25.040.1858','25.041.0155','25.041.1858','25.013.0155 ','25.013.1858 ','24.7257.0952','32.379.200','32.455.155','24.7121.0155','24.7100.0199','32.340.000','24.7122.0155','24.7127.0155','24.7120.0155','24.7200.0001','24.7125.0155','24.7002.0001','24.7121.1858','24.7110.0155','24.7100.1858','32.455.855','24.7122.1858','24.7120.1858','24.7127.1858','24.7124.0155','24.7102.0199','24.7201.0000','24.7100.7052A','24.7125.1858','24.7121.0952A','24.5411.0000','24.5398.0000','24.5404.0000','24.7127.0952','24.7100.4459A','24.5358.0000','32.455.460','24.7102.1858','24.7334.0199','24.5403.0000','24.7128.0155','24.7121.4459A','24.7121.0952','24.7002.0001T','24.7127.4459','32.455.462','24.7219.0952','24.7120.0952A','24.7002.0000T','24.5399.0000','24.5426.0204','24.7122.0952A','24.7200.0001T','32.341.155','24.7110.1858','24.7201.0000T','24.7125.0952A','24.7121.4459','24.5353.0204','32.455.461','24.5427.0204','24.7120.4459A','24.7128.0155A','24.7122.4459A','24.7364.0199','24.7333.0199','24.7124.1858','24.7120.0952','24.7200.0000','24.7125.4459A','24.7219.0199','24.7002.0000','24.5414.0000','24.7122.0952','24.5415.0000','24.5397.0000','24.7202.0000','24.5425.0204','24.7120.4459','24.7122.4459','24.5416.0000','24.7128.1858A','24.7219.1858','24.7124.0952','24.7202.0001','24.5418.0000','24.7334.1858','24.5349.0204','24.7124.4459','24.7334.0952','24.7219.4459','24.5417.0000','24.5405.0000','24.7110.0952','24.7334.4459','32.341.855','24.7333.1858','24.7102.7052A','24.7114.0155','24.7110.0952A','24.7128.0952A','24.7333.0952','24.7128.1858','24.5396.0000','24.5426.1858','24.7114.1858','24.5353.1858','24.5427.1858','24.7110.4459','24.5427.4459','24.5424.0204','24.5426.4459','24.5349.1858','24.5413.0000','24.7364.1858','24.7363.0199','32.455.465','24.7110.4459A','24.7333.4459','24.7128.0952','24.7124.0952A','24.7200.0000T','24.7125.0952','24.5353.4459','24.7219.4464','24.5425.1858','24.7363.1858','24.5425.4459','32.341.176','24.7364.0952','24.7102.4459A','24.5354.1858','24.5427.0952','24.5354.0204','24.5426.0952','24.7114.0952A','24.7219.4460','24.5412.0000','24.5353.0952','24.7125.4459','24.7219.4462','24.7364.4459','24.5349.4459','24.7128.4459A','24.7124.4459A','24.5425.0952','24.7128.4459','24.5360.1858','24.5424.1858','24.7114.4459A','24.5349.0952','24.7307.1858','24.7201.0002','24.5424.4459','24.5354.0952','24.5424.0952','24.5354.4459','24.7219.4465','24.5361.1858','24.5360.0204','24.7363.0952','24.7300.7060','24.7196.7060A','24.7363.4459','24.7116.0155','24.7193.0199A','24.7195.0199A','24.7195.1858A','24.5362.0204','24.5110.7178','24.5362.1858','24.5361.0204','24.5363.1858','24.5363.0204','24.7102.7052','24.7192.7060A','82.691.901','82.696.901','82.696.903','82.691.909','82.691.903','82.696.930','82.696.910','82.696.909','82.696.921','82.696.926','82.691.906','82.691.910','82.696.933','82.696.906','82.696.904','82.691.926','82.696.932','82.691.933','82.696.922','82.696.928','82.691.930','82.696.927','82.696.931','82.691.904','82.696.913','82.691.932','82.696.924','82.696.920','82.696.912','82.696.902','82.696.911','82.691.911','82.691.928','82.696.923','82.691.931','82.696.918','82.696.907','82.696.919','82.696.915','22.748.091','82.691.907','82.696.905','82.691.902','82.696.914','82.691.927','82.691.919','82.696.929','82.691.912','82.691.905','82.696.908','82.696.941','82.691.929','82.696.925','82.691.908','82.696.934','22.749.091','43.525.101','43.525.102','43.525.103','43.525.105','43.525.107','43.525.403','43.525.404','43.525.405','43.530.101','43.530.102','43.530.103','43.530.105','43.530.107','43.530.403','43.530.404','43.530.405','40.199.850','40.196.850','40.197.850','40.191.000','40.174.131','40.129.131','40.280.120','40.152.131','40.129.433','40.169.173','40.129.378','40.368.173','40.129.804','40.173.850','40.345.131','40.367.173','40.153.131','40.260.131','40.041.131','40.042.131','40.129.430','40.132.131','40.024.131','40.153.378','40.263.131','40.176.850','40.262.131','40.200.850','40.132.378','40.041.378','40.132.430','40.189.002','40.129.805','40.198.850','40.153.433','40.042.433','40.270.131','40.170.173','40.260.378','40.132.433','40.041.433','40.163.131','40.162.131','40.153.804','40.025.131','40.042.804','40.187.850','40.260.804','40.129.280','40.026.131','40.132.804','40.153.430','40.467.850','40.023.000','40.129.228','40.042.228','40.153.228','40.042.378','40.381.000','40.041.804','40.260.430','40.034.000','40.271.850','40.041.430','40.042.430','40.260.433','40.041.228','40.264.131','40.175.002','40.153.805','40.346.131','40.132.280','40.340.173','40.260.805','40.042.805','40.131.131','40.041.805','40.171.173','40.188.850','40.158.131','40.132.805','40.172.850','40.046.850','40.041.280','40.371.173','40.132.228','40.260.228','40.379.000','40.131.378','40.042.280','40.026.378','40.415.173','40.035.120','40.030.131','40.048.131','40.047.856','40.380.002','40.029.131','40.377.000','40.031.131','40.001.850','40.051.048','40.032.131','40.033.131','34.274.0155','34.263.0155','34.264.0155','34.265.0155','34.266.0000','34.267.0155','34.268.0000','34.269.0155','34.270.0155','34.271.0155','34.272.0155','34.273.0155','34.276.0000')
	  and f.Date between '2020-05-01' and '2020-10-01'
	  and f.DataType1 = 'Adj_FC'

select (5098 - 386) * 6   --> 28,272/28284      there are total 5098 SKUs get forecasted in May 2020, 386 SKUs are in exception list ( RB 242 + Commodity line 40 + Blue Pacific 104 ( FG 964 ) ), only reduce FC 30% for 6 months    --- 14/5/2020
select (5098 - 386 - 13) * 6   --> 28,206      there are total 5098 SKUs ( but need to exclude Drapery programme as well )  get forecasted in May 2020, 386 SKUs are in exception list ( RB 242 + Commodity line 40 + Blue Pacific 104 ( FG 964 ) ), only reduce FC 30% for 6 months    --- 14/5/2020

 --- update FC History as well ---
;update fh
set fh.Value = fh.value * 0.85
from JDE_DB_Alan.FCPRO_Fcst_History fh
where 
      fh.ReportDate between '2020-05-01' and '2020-05-18 17:00:00:00'
	  and fh.Date between '2020-05-01' and '2020-10-01'
      and fh.ItemNumber not in  ('25.020.0155','25.020.1858','25.021.0155','25.021.1858','25.022.0155','25.022.1858','25.023.0155','25.023.1858','25.024.0155','25.024.1858','25.025.0155','25.025.1858','25.026.0155','25.026.1858','25.027.0155','25.027.1858','25.028.0155','25.028.1858','25.029.000','25.030.0155','25.031.0155','25.030.1858','25.031.1858','25.032.000','25.033.000','25.034.000','25.035.000','25.036.000','25.037.030','25.038.0155','25.039.0155','25.038.1858','25.039.1858','25.040.0155','25.040.1858','25.041.0155','25.041.1858','25.013.0155 ','25.013.1858 ','24.7257.0952','32.379.200','32.455.155','24.7121.0155','24.7100.0199','32.340.000','24.7122.0155','24.7127.0155','24.7120.0155','24.7200.0001','24.7125.0155','24.7002.0001','24.7121.1858','24.7110.0155','24.7100.1858','32.455.855','24.7122.1858','24.7120.1858','24.7127.1858','24.7124.0155','24.7102.0199','24.7201.0000','24.7100.7052A','24.7125.1858','24.7121.0952A','24.5411.0000','24.5398.0000','24.5404.0000','24.7127.0952','24.7100.4459A','24.5358.0000','32.455.460','24.7102.1858','24.7334.0199','24.5403.0000','24.7128.0155','24.7121.4459A','24.7121.0952','24.7002.0001T','24.7127.4459','32.455.462','24.7219.0952','24.7120.0952A','24.7002.0000T','24.5399.0000','24.5426.0204','24.7122.0952A','24.7200.0001T','32.341.155','24.7110.1858','24.7201.0000T','24.7125.0952A','24.7121.4459','24.5353.0204','32.455.461','24.5427.0204','24.7120.4459A','24.7128.0155A','24.7122.4459A','24.7364.0199','24.7333.0199','24.7124.1858','24.7120.0952','24.7200.0000','24.7125.4459A','24.7219.0199','24.7002.0000','24.5414.0000','24.7122.0952','24.5415.0000','24.5397.0000','24.7202.0000','24.5425.0204','24.7120.4459','24.7122.4459','24.5416.0000','24.7128.1858A','24.7219.1858','24.7124.0952','24.7202.0001','24.5418.0000','24.7334.1858','24.5349.0204','24.7124.4459','24.7334.0952','24.7219.4459','24.5417.0000','24.5405.0000','24.7110.0952','24.7334.4459','32.341.855','24.7333.1858','24.7102.7052A','24.7114.0155','24.7110.0952A','24.7128.0952A','24.7333.0952','24.7128.1858','24.5396.0000','24.5426.1858','24.7114.1858','24.5353.1858','24.5427.1858','24.7110.4459','24.5427.4459','24.5424.0204','24.5426.4459','24.5349.1858','24.5413.0000','24.7364.1858','24.7363.0199','32.455.465','24.7110.4459A','24.7333.4459','24.7128.0952','24.7124.0952A','24.7200.0000T','24.7125.0952','24.5353.4459','24.7219.4464','24.5425.1858','24.7363.1858','24.5425.4459','32.341.176','24.7364.0952','24.7102.4459A','24.5354.1858','24.5427.0952','24.5354.0204','24.5426.0952','24.7114.0952A','24.7219.4460','24.5412.0000','24.5353.0952','24.7125.4459','24.7219.4462','24.7364.4459','24.5349.4459','24.7128.4459A','24.7124.4459A','24.5425.0952','24.7128.4459','24.5360.1858','24.5424.1858','24.7114.4459A','24.5349.0952','24.7307.1858','24.7201.0002','24.5424.4459','24.5354.0952','24.5424.0952','24.5354.4459','24.7219.4465','24.5361.1858','24.5360.0204','24.7363.0952','24.7300.7060','24.7196.7060A','24.7363.4459','24.7116.0155','24.7193.0199A','24.7195.0199A','24.7195.1858A','24.5362.0204','24.5110.7178','24.5362.1858','24.5361.0204','24.5363.1858','24.5363.0204','24.7102.7052','24.7192.7060A','82.691.901','82.696.901','82.696.903','82.691.909','82.691.903','82.696.930','82.696.910','82.696.909','82.696.921','82.696.926','82.691.906','82.691.910','82.696.933','82.696.906','82.696.904','82.691.926','82.696.932','82.691.933','82.696.922','82.696.928','82.691.930','82.696.927','82.696.931','82.691.904','82.696.913','82.691.932','82.696.924','82.696.920','82.696.912','82.696.902','82.696.911','82.691.911','82.691.928','82.696.923','82.691.931','82.696.918','82.696.907','82.696.919','82.696.915','22.748.091','82.691.907','82.696.905','82.691.902','82.696.914','82.691.927','82.691.919','82.696.929','82.691.912','82.691.905','82.696.908','82.696.941','82.691.929','82.696.925','82.691.908','82.696.934','22.749.091','43.525.101','43.525.102','43.525.103','43.525.105','43.525.107','43.525.403','43.525.404','43.525.405','43.530.101','43.530.102','43.530.103','43.530.105','43.530.107','43.530.403','43.530.404','43.530.405','40.199.850','40.196.850','40.197.850','40.191.000','40.174.131','40.129.131','40.280.120','40.152.131','40.129.433','40.169.173','40.129.378','40.368.173','40.129.804','40.173.850','40.345.131','40.367.173','40.153.131','40.260.131','40.041.131','40.042.131','40.129.430','40.132.131','40.024.131','40.153.378','40.263.131','40.176.850','40.262.131','40.200.850','40.132.378','40.041.378','40.132.430','40.189.002','40.129.805','40.198.850','40.153.433','40.042.433','40.270.131','40.170.173','40.260.378','40.132.433','40.041.433','40.163.131','40.162.131','40.153.804','40.025.131','40.042.804','40.187.850','40.260.804','40.129.280','40.026.131','40.132.804','40.153.430','40.467.850','40.023.000','40.129.228','40.042.228','40.153.228','40.042.378','40.381.000','40.041.804','40.260.430','40.034.000','40.271.850','40.041.430','40.042.430','40.260.433','40.041.228','40.264.131','40.175.002','40.153.805','40.346.131','40.132.280','40.340.173','40.260.805','40.042.805','40.131.131','40.041.805','40.171.173','40.188.850','40.158.131','40.132.805','40.172.850','40.046.850','40.041.280','40.371.173','40.132.228','40.260.228','40.379.000','40.131.378','40.042.280','40.026.378','40.415.173','40.035.120','40.030.131','40.048.131','40.047.856','40.380.002','40.029.131','40.377.000','40.031.131','40.001.850','40.051.048','40.032.131','40.033.131','34.274.0155','34.263.0155','34.264.0155','34.265.0155','34.266.0000','34.267.0155','34.268.0000','34.269.0155','34.270.0155','34.271.0155','34.272.0155','34.273.0155','34.276.0000')
	   and fh.DataType1 = 'Adj_FC'

----------------------------------------------------------------------------------
--- update one month data --- fc table
;update f
set f.Value = 350
--select * 
from JDE_DB_Alan.FCPRO_Fcst f
--where h.ReportDate between '2018-03-01' and '2018-03-02 13:00:00'
 where f.ItemNumber in ('43.211.001') 
	  and f.Date between '2020-08-01' and '2021-03-01'
	  and f.DataType1 = 'Adj_FC'

select * from JDE_DB_Alan.FCPRO_Fcst f where f.ItemNumber in ('43.211.001')  and f.Date between '2020-08-01' and '2021-03-01'  and f.DataType1 = 'Adj_FC'

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

--------- 6/4/2020 ---------------

select * from JDE_DB_Alan.TextileWC 
select * from JDE_DB_Alan.TextileFC f where f.Reportdate > '2020-01-30' and f.date < 20200601 
order by f.Date,f.Quantity desc

select sum(f.Quantity) from JDE_DB_Alan.TextileFC f where f.Reportdate > '2020-01-30' 
select max(f.date) from JDE_DB_Alan.TextileFC f where f.Reportdate > '2020-01-30' 

select * from JDE_DB_Alan.Textile_ItemCrossRef  
select distinct f.Reportdate from JDE_DB_Alan.TextileFC f

select * from JDE_DB_Alan.vw_Mast m where m.ItemNumber in ('2781211001') 
select * from JDE_DB_Alan.vw_Mast m where m.SupplierName like ('%BR%') 
select * from JDE_DB_Alan.vw_Mast m where m.Family in ('VE1','VE2') order by m.Family,m.ItemNumber

select * from JDE_DB_Alan.vw_FC f left join JDE_DB_Alan.vw_Mast m on f.ItemNumber = m.ItemNumber
  where m.Description like  ('%plaza%') and m.StockingType not in ('O','U') and m.FamilyGroup in ('982')
  

select distinct f.ItemNumber
from JDE_DB_Alan.FCPRO_Fcst f left join JDE_DB_Alan.vw_Mast m on f.ItemNumber = m.ItemNumber
where m.PrimarySupplier in ('20037')
      and f.DataType1 = 'Adj_FC'
	  and f.Date between '2020-04-01'  and '2020-09-01'

select distinct f.ItemNumber
from JDE_DB_Alan.FCPRO_Fcst f left join JDE_DB_Alan.vw_Mast m on f.ItemNumber = m.ItemNumber
where m.ItemNumber like ('42.129.%')
      and f.DataType1 = 'Adj_FC'
	 

select * from JDE_DB_Alan.vw_Mast m 
where m.ItemNumber in ('44.010.007')
-- where m.ItemNumber in ('40.041.131','40.042.131','40.041.378','40.042.433','40.041.433','40.042.804','40.042.228','40.042.378','40.041.804','40.042.430','40.041.430','40.041.228','40.042.805','40.041.805','40.041.280','40.042.280','40.024.131','40.263.131','40.262.131','40.025.131','40.026.131','40.046.850','40.026.378','40.030.131','40.029.131','40.031.131','40.032.131','40.033.131','40.153.131','40.153.378','40.132.378','40.132.430','40.153.433','40.132.433','40.153.804','40.153.430','40.132.804','40.153.228','40.153.805','40.132.280','40.158.131','40.132.805','40.132.228','40.174.131','40.176.850','40.175.002','40.415.173','40.129.131','40.129.433','40.129.378','40.129.804','40.129.430','40.132.131','40.129.805','40.129.280','40.129.228','40.131.131','40.131.378','40.199.850','40.196.850','40.197.850','40.191.000','40.152.131','40.169.173','40.173.850','40.200.850','40.189.002','40.198.850','40.170.173','40.163.131','40.162.131','40.187.850','40.171.173','40.188.850','40.260.131','40.260.378','40.260.804','40.260.430','40.260.433','40.260.805','40.260.228','40.280.120','40.467.850','40.264.131','40.001.850','40.345.131','40.346.131','40.051.048','40.368.173','40.367.173','40.270.131','40.023.000','40.381.000','40.034.000','40.271.850','40.340.173','40.172.850','40.371.173','40.379.000','40.035.120','40.048.131','40.047.856','40.380.002','40.377.000')


----- 10/2/2021 ---- Nordic range review
select distinct f.ItemNumber,m.FamilyGroup,m.Description,m.Family_0,m.PrimarySupplier,m.SupplierName,m.Owner_
from JDE_DB_Alan.FCPRO_Fcst f left join JDE_DB_Alan.vw_Mast m on f.ItemNumber = m.ItemNumber
where --m.PrimarySupplier in ('20037')
       m.FamilyGroup in ('965')
      and f.DataType1 = 'Adj_FC'
	  and f.Date between '2021-02-01'  and '2021-12-01'
order by m.Owner_,m.PrimarySupplier


select * from JDE_DB_Alan.vw_Mast m 
where m.ItemNumber in ('26.478.000','46.025.000','46.410.063','46.414.000','46.421.000','46.422.030','46.423.100','46.423.134','46.423.850','46.424.100','46.425.100','46.508.500','46.508.700','46.559.030')

where m.ItemNumber in ('9990710','6610200000','6610220000','6610260000','6610300000','6610340000','6610350000','6610420000','6610480000','6610490000','6610520000','6610580000','6610660000','6610690000','6610930000','6610940000','6611000000','6611060000','6611080000','6611500000','6611510000','6611530000','6611550000','6658500000','6865255122','7020080000','7122570001','7122570049','7122570182','7122630001','7122630049','7122630182','7122640001','7122640049','7122640182','7122720001','7122720049','7122720182','7122900001','7122900049','7122900182','7122910001','7122910049','7122910182','7122920001','7122920049','7122920182','7122930001','7122930049','7122930182','7122950001','7122950182','7122950914','7122960000','7123060001','7123060049','7123060182','7123061901','7123070001','7123070049','7123070182','7123080001','7123080182','7123080914','7124010001','7124010049','7124010182','7124100001','7124100049','7124100182','7124130001','7124130049','7124130182','7124170001','7124170049','7124170182','7126070001','7126070182','7126070914','7127150001','7127150182','7127150914','7127500000','7127510001','7127510182','7127510914','7127600001','7127600182','7127600914','7127620001','7127620182','7127620914','7127650001','7127650182','7127650914','7127660001','7127660182','7127660914','7127690001','7127690182','7127690914','7127700001','7127700182','7127700914','7127710001','7127710182','7127710914','7127800001','7127800182','7127800914','7127850001','7127850182','7127850914','7127860001','7127860182','7127860914','7127890001','7127890182','7127890914','7127900001','7127900182','7127900914','7127910001','7127910182','7127910914','7127930001','7127930182','7127930914','7127940001','7127940182','7127940914','7127950001','7127950182','7127950914','7127960001','7127960182','7127960914','7127970001','7127970182','7127970914','7127990001','7127990182','7127990914','7129200001','7129200182','7129200914','7134210001','7134210182','7134210914','7134230001','7134230182','7134230914','7137030000','7137040000','7137050000','7139020000','7143010000','7143020000','7144930000','7146040000','7146180001','7146180049','7146180182','7146500001','7146500182','7146500914','7146520000','7146580001','7146580049','7146580182','7151030001','7151030182','7151030914','7151040001','7151040182','7151040914','7153060001','7153060182','7153060914','7153080001','7153080182','7153080914','7153090001','7153090182','7153090914','7156130000','7220050000','7231010000','7231020000','7231060000','7231150000','7231160000','7232080001','7232080049','7232087035','7232127035','7232147035','7232160001','7232160049','7232167035','7232187035','7232247035','7233020000','7233040000','7233080000','7233100000','7233110000','7233120000','7236040000','7236040001','7236080001','7236087035','7236120001','7236120049','7236127035','7310200000','7321210001','7326000000','7326010000','7326020000','7326030000','7326080000','7350150001','7350150182','7350150914','7350200001','7350200182','7350200914','7350250001','7350250182','7350250914','7350300001','7350300182','7350300914','7370200001','7370200182','7370200914','7370250001','7370250182','7370250914','7370300001','7370300182','7370300914','7370350001','7370350182','7370350914','7370400001','7370400182','7370400914','7390020001','7390020182','7390020914','7390030001','7390030182','7390030914','7390060001','7390060182','7390060914','7390160001','7390160182','7390160914','7390200001','7390200182','7390200914','7390250001','7390250182','7390250914','7390300001','7390300182','7390300914','7390350001','7390350182','7390350914','7390400001','7390400182','7390400914','7390930001','7390930182','7390930914','7390950001','7390950182','7390950914','7394160001','7394160182','7394160914','7394200001','7394200182','7394200914','7394250001','7394250182','7394250914','7394300001','7394300182','7394300914','7394350001','7394350182','7394350914','7394400001','7394400182','7394400914','7441500182','7442700001','7442700182','7442700914','7456500001','7456500182','7456500914','7457500001','7457500182','7457500914','7460500000','7460700000','7468500001','7468500182','7468500914','7468700001','7468700182','7468700914','7477500001','7477500182','7477500914','7477700001','7477700182','7477700914','7478500001','7478500182','7478500914','7478700001','7478700182','7478700914','7479500001','7479500182','7479500914','7479700001','7479700182','7479700914','7483500001','7483500182','7483500914','7483700001','7483700182','7483700914','7485700000','7488500001','7488500182','7488500914','7488700001','7488700182','7488700914','7489500001','7489500182','7489500914','7489700001','7489700182','7489700914','7491500001','7491500182','7491500914','7491700001','7491700182','7491700914','7493500001','7493500182','7493500914','7493700001','7493700182','7493700914','7494500001','7494500182','7494500914','7494700001','7494700182','7494700914','7495500001','7495500182','7495500914','7495700001','7495700182','7495700914','7497700001','7497700182','7497700914','7498700001','7498700182','7498700914','7499700001','7499700182','7499700914','7742140001','7742140182','7742140914','7747720000','7761030001','7761030049','7761030182','7766030000','7766050000','7766070000','7766250000','7766270000','26.478.000','40.499.000','40.500.000','40.501.000','40.503.062','40.509.000','40.510.000','40.513.000','42.466.030','42.496.000','42.501.855','42.502.000','42.503.000','42.504.886','42.505.000','42.506.030','42.512.000','42.520.000','42.652.000','42.653.000','42.654.000','42.655.000','42.655.850','46.025.000','46.410.063','46.414.000','46.421.000','46.422.030','46.423.100','46.423.134','46.423.850','46.424.100','46.425.100','46.508.500','46.508.700','46.559.030')

----- 9/4/2020 -----

/****** Script for SelectTopNRows command from SSMS  ******/
SELECT *
  FROM [JDE_DB_Alan].[JDE_DB_Alan].[Textile_ItemCrossRef] t

  order by t.updatedate asc

 ; 
  where Reportdate > '20200407'
 where f.ArticleNumber in('1015637')
  oselect * from JDE_DB_Alan.JDE_DB_Alan.TextileFC frder by f.Date,f.Reportdate desc

 delete from JDE_DB_Alan.JDE_DB_Alan.TextileFC 
 where Reportdate > '20200407'

 select distinct f.Reportdate from JDE_DB_Alan.JDE_DB_Alan.TextileFC f

	  select f.ArticleNumber,f.Quantity,f.Date,max(f.Reportdate) as reportdt
	   from JDE_DB_Alan.JDE_DB_Alan.TextileFC f
	   group by f.ArticleNumber,f.Quantity,f.Date


----- 21/4/2020 -----

select * from JDE_DB_Alan.FCPRO_SafetyStock s 
where s.ItemNumber in ('2801490785')


----- 28/4/2020 -----
select distinct f.ItemNumber
--select f.ItemNumber,f.Value,f.Date,m.Description,m.Colour,m.FamilyGroup,m.Family,m.FamilyGroup_,m.Family_0
from JDE_DB_Alan.FCPRO_Fcst f left join JDE_DB_Alan.vw_Mast m on f.ItemNumber = m.ItemNumber
where m.FamilyGroup in ('966')  --and m.Family in ('635')
      and f.DataType1 = 'Adj_FC'
	  --and f.Date between '2020-04-01' and '2020-07-01'
	  and m.Colour like ('nocturnal%')


select 336/24


----- 12/5/2020 -----
select * from JDE_DB_Alan.vw_Mast m where m.ItemNumber in ('24.7257.0952','26.144.0204','26.132.1858','26.144.1858')
select * from JDE_DB_Alan.vw_Mast m where m.ItemNumber in ('FT.01468.000.01','34.073.000','24.5403.0000')
select * from JDE_DB_Alan.vw_Mast m where m.Description like ('%WEATHER%')
select * from JDE_DB_Alan.vw_Mast m where m.Description like ('%stance scrn%') and m.Description not like ('%ctl%')
select * from JDE_DB_Alan.vw_Mast m 
where m.ItemNumber like ('XUR%') or  m.ItemNumber like ('XUEC%') or  m.ItemNumber like('XUCLC%')
order by m.ItemNumber




select * from JDE_DB_Alan.vw_Mast m where m.Description like ('%chain loop%') and m.Family in ('374') and m.StockingType in ('P','s')
select * from JDE_DB_Alan.vw_Mast m where m.ItemNumber in ('24.7100.0199','24.7220.0199','32.455.155','24.7295.0952','34.480.000','34.540.000')

select * from JDE_DB_Alan.vw_Mast m where m.ItemNumber in
('26.478.000','40.499.000','40.500.000','40.501.000','40.502.000','40.503.062','40.509.000','40.510.000','40.513.000','42.448.000','42.466.030','42.492.000','42.496.000','42.501.855','42.502.000','42.503.000','42.504.886','42.505.000','42.506.030','42.512.000','42.520.000','46.025.000','46.414.000','46.421.000','46.422.030','46.423.100','46.423.134','46.423.850','46.424.100','46.424.850','46.425.100','46.508.500','46.508.700','46.531.500','46.531.700','46.559.030','46.577.000','6802255122','6865255122','6865255206','7020080000','7310200000','7441500001B','7441500182B','7441500914B','7441700001B','7441700182B','7441700914B','TUFA20HS')

select * from JDE_DB_Alan.FCPRO_Fcst f where f.ItemNumber in ('24.7002.0001','26.144.0204','26.132.1858') and f.DataType1 in ('Adj_FC')
select * from JDE_DB_Alan.FCPRO_MI_2_tmp i where i.ItemNumber in ('24.7002.0001')
select * from JDE_DB_Alan.FCPRO_MI_2_tmp i where i.ItemNumber in ('24.7002.0001')
select * from  [JDE_DB_Alan].[FCPRO_MI_2_Raw_Data_tmp] i where i.ItemID in ('24.7002.0001')

select * from JDE_DB_Alan.MasterFamily m where m.Code in ('E26')

select * from JDE_DB_Alan.FCPRO_SafetyStock ss where ss.ItemNumber in('26.144.0204','26.144.0192')

select * from JDE_DB_Alan.FCPRO_Fcst f where f.ItemNumber in ('34.306.000','34.513.000') and f.DataType1 in ('adj_fc')
select * from JDE_DB_Alan.vw_Mast m where m.ItemNumber in ('34.263.0155')


------- 1/6/2020 ------
 select h.*, m.StockingType,m.FamilyGroup_,m.Family_0,m.Description
        ,concat(h.Century,h.FinancialYear) as YY
		, case when h.FinancialMonth <10 then concat(h.Century,h.FinancialYear,'0',h.FinancialMonth)
		       when h.FinancialMonth >=10 then concat(h.Century,h.FinancialYear,h.FinancialMonth)
		 end as YY_MM
		 ,abs(h.Quantity) as Quantity_		 	
  --select distinct h.ItemNumber
 FROM JDE_DB_Alan.SlsHistoryHD h
		left join JDE_DB_Alan.vw_Mast m on h.ItemNumber = m.ItemNumber
  where --h.ItemNumber in ('34.215.000','34.216.000','34.230.000','34.232.000','34.233.000','34.234.000')
		--h.ItemNumber in ('27.252.000','27.253.000','27.257.000','27.258.000','27.170.135','27.170.810','27.170.661','27.170.862','27.170.879','27.170.048','27.170.785','27.171.810','27.171.661','27.171.862','27.171.879','27.171.048','27.171.785','27.175.810','27.175.661','27.175.862','27.175.879','27.175.048','27.175.785','27.176.810','27.176.661','27.176.862','27.176.879','27.176.048','27.176.785','27.174.810','27.174.661','27.174.862','27.174.879','27.174.048','27.174.785','27.160.661','27.160.862','27.160.879','27.160.882','27.160.320','27.160.785','27.161.661','27.161.862','27.161.879','27.161.882','27.161.320','27.161.785','27.162.661','27.162.862','27.162.879','27.162.882','27.162.320','27.162.785','27.163.661','27.163.862','27.163.879','27.163.882','27.163.320','27.163.785','27.164.661','27.164.862','27.164.879','27.164.882','27.164.320','27.164.785','27.165.661','27.165.862','27.165.879','27.165.882','27.165.320','27.165.785','27.166.661','27.166.862','27.166.879','27.166.882','27.166.320','27.166.785')
        h.ItemNumber in ('42.210.031')
		and h.FinancialYear >=18

  select * from [JDE_DB_Alan].[SlsHistoryAWF_HD_MT]
  select * from [JDE_DB_Alan].[SlsHistoryMT]
    select * from [JDE_DB_Alan].[SlsHistoryhd] h where h.ItemNumber in ('42.210.031')

  select * from [JDE_DB_Alan].[FCPRO_SafetyStock] ss where ss.ItemNumber in ('FT.01468.000.01','26.144.0204')
   select * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h where h.ItemNumber in ('26.144.0204')

  select * from 


;with his as (
			select h.FamilyGroup,h.CYM,'Sls_' as DataType,sum(h.SalesQty) as Value_
			from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h
			group by h.FamilyGroup,h.CYM
			--order by h.FamilyGroup,h.CYM
			  )
   ,fc as (  select m.FamilyGroup_,f.FCDate2_,'Fc_' as DataType,sum(f.FC_Vol) as Value_
	         from JDE_DB_Alan.vw_FC f left join JDE_DB_Alan.vw_Mast m on f.ItemNumber = m.ItemNumber
			 group by m.FamilyGroup_,f.FCDate2_
			-- order by m.FamilyGroup_,f.FCDate2_
			  )
  , comb as (
               select * from his
			   union 
			   select * from fc
             )

  select * from comb c
  --where c.FamilyGroup like ('%Motor%')
  order by c.FamilyGroup,c.CYM


--------------------------------------------------------------
-----------------------------------------------

select * from JDE_DB_Alan.vw_Mast m where m.ItemNumber in ('43.212.003','24.5403.0000','43.212.001','24.7121.0155')
select * from [hd-vm-bi-sql01].HDDW_PRD.star.d_product p
where p.item_code in ('44.011.007')

select * from JDE_DB_Alan.FCPRO_SafetyStock s where s.ItemNumber in ('82.058.913')
select * from JDE_DB_Alan.vw_Mast m where m.ItemNumber in ('82.058.913','82.058.914','82.058.915','82.058.918','82.696.913','82.696.914','82.696.915','82.696.918','82.696.919','82.696.920','82.696.921','82.696.922','82.696.923','82.696.924','82.696.925') 


select top 3 * from JDE_DB_Alan.OpenPO o
select * from JDE_DB_Alan.MasterSupplier



---------- 15/6/2020 Update Sales History Adjustment ---------------------------------------

  --- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  -- be careful when update Sales History, because sometimes spike in the past is legitmate and you want to keep it for Safety stock calculation --
  -- sometimes, you just want to remove it from history for creating good FC, but want to leave history with spike for Safetty stock calculation !!!
  -- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



/****** Script for SelectTopNRows command from SSMS  ******/

  select top 3 * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload l 
  select * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload l where l.ItemNumber in ('24.7257.0952','6000130009004H')
    select * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload l where l.ValidStatus in ('Y')

  select * from JDE_DB_Alan.SlsHist_Excp_FCPro_upload e order by e.Date_Updated desc, ReportDate desc, e.Index_Row_Number

   select l.ItemNumber,l.CYM,l.SalesQty,l.SalesQty_Adj,l.ValidStatus
   from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload l 
   --where l.ItemNumber in ('26.132.0204')
   where l.ItemNumber in ('6000130009004H')
    

	select   dateadd(s,-1,dateadd(d, datediff(d,0, getdate()), 0)	)

	select *
	from JDE_DB_Alan.SlsHist_Excp_FCPro_upload e
	where e.Date_Updated > dateadd(s,-1,dateadd(d, datediff(d,0, getdate()), 0)	)


	delete from JDE_DB_Alan.SlsHist_Excp_FCPro_upload 
	where Date_Updated > dateadd(s,-1,dateadd(d, datediff(d,0, getdate()), 0)	)

   update s
   set s.SalesQty_Adj = e.Value_Sls_Adj
       ,s.ValidStatus = e.ValidStatus
	--select * 
   from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload s inner join 
                   ( 
				        select * from ( select a.*,dense_rank()over(order by Date_Updated desc ) as rn
										from JDE_DB_Alan.SlsHist_Excp_FCPro_upload a ) b
						     where b.rn = 1 
					) e

			on s.ItemNumber = e.ItemNumber and s.CYM = e.Date
     where  e.ValidStatus = 'Y'
		    -- and s.ItemNumber ='26.132.0204'


SELECT *
  FROM [JDE_DB_Alan].[JDE_DB_Alan].[SlsHist_AWFHDMT_FCPro_upload] h
 --where h.[ItemNumber] like ('%850531003021%')
 where h.ItemNumber in ('26.132.0204')



 ------------------------------------------------------------------------------------

   --- Update Sales History ---- if there is noise in history -- 16/10/2020 -- Using existing Sls_history_upld file rather than updating Sls_Excp_file, because next month, your provcess will pick it up first ! 16/10/2020
  
  --- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  -- be careful when update Sales History, because sometimes spike in the past is legitmate and you want to keep it for Safety stock calculation --
  -- sometimes, you just want to remove it from history for creating good FC, but want to leave history with spike for Safetty stock calculation !!!
  -- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


 select * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload l where l.ItemNumber in ('38.001.005')

 select * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h
 where h.Validstatus in ('Y')

   update s
   set s.SalesQty_Adj = 2000
       ,s.ValidStatus = 'Y'	
   from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload s 
                  
     where  s.ItemNumber = '38.001.005'
		    and s.CYM in ( '201810','201811')
			


select * from JDE_DB_Alan.SlsHist_Excp_FCPro_upload order by Date_Updated desc
select * from jde


--- 2/12/2020 ---

select f.*,m.Description,m.PlannerNumber,m.UOM,m.Owner_,m.SupplierName,m.FamilyGroup
from JDE_DB_Alan.vw_FC f left join JDE_DB_Alan.vw_Mast m on f.ItemNumber = m.ItemNumber
 where  f.ItemNumber in
		('26.800.659','26.800.820','26.800.830','26.800.962','26.800.963','26.801.820','26.801.962','26.801.963','26.802.659','26.802.820','26.802.830','26.802.962','26.802.963','26.810.659','26.810.820','26.810.830','26.810.962','26.810.963','26.811.820','26.811.962','26.811.963','26.803.659','26.803.820','26.803.830','26.803.962','26.803.963','26.803.971')
		--('18.010.035','18.010.036','18.607.016','18.615.007','24.5418.0000','24.7102.7052A','24.7120.0952','24.7121.0952','24.7122.0952','24.7123.0952A','24.7124.0952','24.7127.0952','24.7128.0952','24.7129.0952','24.7134.0952A','24.7200.0001','24.7201.0000','24.7202.0000','24.7203.0000','24.7206.0000','24.7220.0952','32.379.200','32.380.002','32.455.155','32.501.000','43.525.105','43.530.105','82.696.931')
		--('26.800.676','26.800.833','26.800.971','26.801.676','26.802.676','26.802.833','26.802.971','26.803.676','26.803.833','26.810.676','26.810.833','26.810.971','26.811.676')		
		and f.FCDate2_ < 202202


select * from JDE_DB_Alan.vw_Mast m where m.ItemNumber in ('18.607.016','24.7102.0199','24.7120.0155','24.7123.0155A','24.7128.0155','24.7129.0155','24.7133.0155A','24.7136.0155A','24.7201.0000','24.7220.0952','32.379.200','32.380.002','32.455.155','32.501.000','34.080.000','82.691.931','82.696.931','FT.01391.000.00')


select * from JDE_DB_Alan.vw_Mast m													-- 48,762
select * from JDE_DB_Alan.vw_Mast m where m.PrimarySupplier not in ('506196')		-- 32,926
select * from JDE_DB_Alan.vw_Mast m where m.PrimarySupplier  in ('506196')			-- 13,486 +35,276 = 48,762
select * from JDE_DB_Alan.vw_Mast m where m.PrimarySupplier is null					-- 2,350 ;  32,926 +2350 = 35,276


with a as ( select * from JDE_DB_Alan.vw_Mast m)
     ,b as (  select * from JDE_DB_Alan.vw_Mast m where m.PrimarySupplier  in ('506196') )

	,Vlid as 
	( 
	  select * from a except select * from b
	 )
 select * from Vlid
 -------------------------------------------------------

---============================*** HD DW data warehouse query *** =================================---
---------------------------------- HD Data Warehouse Query ------------------------------------------- works !
---------- remember you have admin right in 'JDE_DB_Alan ' db, so you have control and can link to '[hd-vm-bi-sql01].HDDW_PRD' , however you cannot do reverse because you do not control data warehouse and you do not have control , unless you have admin right to set access to hdd dw. ----


select * from HDDW_PRD.star.d_region		-- does not work , need full qualification 

select * from [hd-vm-bi-sql01].HDDW_PRD.star.d_region  --- works !
o
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

---------------- Textile Work Center Query ------------------------------------------



exec JDE_DB_Alan.sp_Mismatch_Textile_RCCP null,'2021-01-02'
exec JDE_DB_Alan.sp_Mismatch_Textile_RCCP null,'2021-02-02'
exec JDE_DB_Alan.sp_Mismatch_Textile_RCCP null,'2021-03-02'
exec JDE_DB_Alan.sp_Mismatch_Textile_RCCP null,'2021-04-02'				--- Run @19/5/2020
exec JDE_DB_Alan.sp_Mismatch_Textile_RCCP null,'2021-05-02'				--- Run @15/6/2020
exec JDE_DB_Alan.sp_Mismatch_Textile_RCCP null,'2021-06-02'				--- Run @14/7/2020


select * from JDE_DB_Alan.vw_Mast m where m.WC <>0
select * from JDE_DB_Alan.vw_Mast m where m.wc <> '0' and m.StockingType in ('O','U') 
select * from JDE_DB_Alan.vw_Mast m where m.wc <> '0' and m.StockingType not in ('O','U') and m.FamilyGroup  in ('981')


select * from JDE_DB_Alan.vw_Mast_z m where m.WC <>'0'				-- use this one to test to see if 'WC' column is showing available or not  --- it works ! the trick is use another CTE table and then select all columns ! --- 4/12/2019

select convert(varchar(7),getdate(),120) as myDate1		
select cast(SUBSTRING(REPLACE(CONVERT(char(10),getdate(),126),'-',''),1,6) as integer) as [myDate2]

select m.ItemNumber,m.Description from JDE_DB_Alan.vw_Mast m

select * from JDE_DB_Alan.vw_Mast m where m.WC <> ('No_WC_Assigned')

select * from JDE_DB_Alan.vw_Mast m where m.ItemNumber in ('83.529.901')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('83.529.901')
select sum(m.stockvalue) as stkval from JDE_DB_Alan.vw_Mast m
select sum(m.stockvalue) as stkval from JDE_DB_Alan.Master_ML345 m

select * from JDE_DB_Alan.TextileWC w
where w.ShortItemNumber not in ( select m.ShortItemNumber from JDE_DB_Alan.vw_Mast m where m.WC <> ('No_WC_Assigned')
)


select distinct f.ItemNumber from JDE_DB_Alan.FCPRO_Fcst f where f.ItemNumber like ('%46.614.%')

---- Blue Pacific --- Sales query --- 2/3/2020
select * from JDE_DB_Alan.vw_Mast m 
where 
       m.Description like ('%TRNDAD C PANEL%')
		--m.Description like ('%KNGSTN PTIO C PNL%')
      and m.StockingType not in  ('O','U')
order by m.Colour


select * from JDE_DB_Alan.vw_Mast m 
where 
       m.Description like ('%Link PiVOT PIN%')
		--m.Description like ('%KNGSTN PTIO C PNL%')
      and m.StockingType not in  ('O','U')


---------------------------------------------------------------------------------------------
select * from JDE_DB_Alan.vw_Mast m where m.PlannerNumber like  ('')
select * from JDE_DB_Alan.FCPRO_SafetyStock s where s.ItemNumber in ('18.617.056')

select * from  Jde_db_alan.FCPRO_Fcst fc where fc.ItemNumber like ('%40.033.131%') and fc.Date in ('2020-06-01')


select m.ItemNumber,m.StandardCost from JDE_DB_Alan.vw_Mast m where m.ItemNumber in ('44.003.102','44.003.103','44.003.104','44.003.105','44.003.106','44.003.107','44.003.108','44.003.109','44.003.110','44.003.111','44.003.112','44.003.113','44.003.114','44.004.102','44.004.103','44.004.104','44.004.105','44.004.106','44.004.107','44.004.108','44.004.109','44.004.110','44.004.111','44.004.112','44.004.113','44.004.114','44.004.115','44.004.116','44.004.117','44.004.118','44.005.102','44.005.104','44.005.109','44.005.110','44.005.111')

select * from JDE_DB_Alan.vw_Mast m where m.ItemNumber like ('25.0%') order by SUBSTRING(m.Itemnumber,5,2)
select * from JDE_DB_Alan.SO_Inquiry_Super 
select * from JDE_DB_Alan.TextileFC
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('82.600.902CL','82.600.903CL','82.600.904CL','82.600.905CL','82.600.906CL','82.600.907CL','82.600.908CL','82.601.901CL','82.601.902CL','82.601.903CL','82.601.905CL','82.601.906CL','82.601.907CL','82.601.908CL','82.602.901CL','82.602.902CL','82.602.903CL','82.602.905CL','82.602.906CL','82.602.907CL','82.602.908CL') order by ItemNumber
select * from JDE_DB_Alan.Master_ML345 m where m.ShortItemNumber in ('34.480.000')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('2801640785','2801687785')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('2801640862','2801687862')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('2801462000','2801463000','2780066000','2780067000')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('43.212.001','43.212.002','43.212.003','43.212.004')
select * from JDE_DB_Alan.Master_ML345 m where m.ShortItemNumber in ('1377977','1379753','1379770','1379788')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('0850525000707','0850525003020','085052500M178','0850525003061','0850525000222','0850525000207','0850525000220','2801471000')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('34.513.000','34.514.000','34.515.000','34.516.000','34.517.000','34.518.000','34.519.000','34.520.000','34.521.000','34.522.000','34.523.000')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('XQ4PV426HD','XQ4PV414HD','XS4PV330HD','XS4PV620HD','XQ4PV914HD','XS5PV530HD','XQ5PV626HD','XQ5PV926HD','XQ5PV1530HD','XQ5PV2017HD','XQ5PV3017HD','XQ5PV4017HD','XQ4PV430HD','XQ4PV334HD','XS4PV624HD','XQ4PV915HD','XS5PV525HD','XQ5PV634HD','XQ5PV934HD','XQ5PV1234HD','XQ5PV2521HD','XQ5PV3521HD','XQ5PV4016HD')
select * from JDE_DB_Alan.Master_ML345 m where m.PrimarySupplier in ('1239','2037359')
select * from JDE_DB_Alan.Master_ML345 m where m.Description like ('%stealth%')
select * from JDE_DB_Alan.Master_ML345 m where m.Description like ('%Willandra%') and m.Description like ('%linnet%')
select * from JDE_DB_Alan.Master_ML345 m where m.Description like ('%screen%')
select * from JDE_DB_Alan.Master_ML345 m where m.Description like ('%elli%') and m.Description like ('%rail%')
select * from JDE_DB_Alan.vw_Mast m where m.FamilyGroup_ like ('%910%')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('4199030822')
select * from JDE_DB_Alan.Master_ML345 m where m.Description like ('%Eco%') and m.Description like ('%3[%]%') and m.Description like ('%plan%')
select * from JDE_DB_Alan.Master_ML345 m where m.Description like ('%3[%]%')
select m.ItemNumber,m.ShortItemNumber,m.PlannerNumber,m.FamilyGroup,m.Description,m.Family_0,m.StandardCost 
from JDE_DB_Alan.vw_Mast m where m.Description like ('%3[%]%') and m.FamilyGroup in ('986') and m.StockingType not in ('o','u','k')

select m.ItemNumber,m.ShortItemNumber,m.PlannerNumber,m.FamilyGroup,m.Description,m.Family_0,m.StandardCost,m.Colour
from JDE_DB_Alan.vw_Mast m 
where m.Family_0 like ('%635%') and m.StockingType not in ('o','u','k')

select * from JDE_DB_Alan.MasterFamily m

select * from JDE_DB_Alan.vw_SO_Inquiry_Super sh
select * from JDE_DB_Alan.FCPRO_NP_tmp n
where n.ItemNumber in ('38.005.001')

select * from JDE_DB_Alan.vw_FC f where f.ItemNumber in ('38.005.001')
select * from JDE_DB_Alan.FCPRO_Fcst f
where f.ItemNumber in ('38.005.001') order by f.DataType1

select * from JDE_DB_Alan.vw_Mast f where f.ItemNumber in ('2801499661')



select * from JDE_DB_Alan.FCPRO_MI_2_tmp m
where m.ItemNumber in ('38.005.001')


select * from JDE_DB_Alan.vw_Mast m 
where m.ItemNumber in ('38.013.006')

select * from JDE_DB_Alan.vw_FC f where f.ItemNumber in ('34.306.000')


--select f.ItemNumber,f.FCDate2_,f.FC_Vol,m.Description,m.Family,m.FamilyGroup
select f.*,m.Description,m.Family,m.FamilyGroup
from JDE_DB_Alan.vw_FC f left join JDE_DB_Alan.vw_Mast m on f.ItemNumber = m.ItemNumber
where m.Family in ('VE1','VE2')


select * from JDE_DB_Alan.vw_Mast m where m.SupplierName like ('Qmot%')
select f.*,m.Description,m.Family,m.FamilyGroup,m.SupplierName,m.PrimarySupplier,m.StandardCost,f.FC_Vol * m.StandardCost as  Stk_Amt,m.QtyOnHand
from JDE_DB_Alan.vw_FC f left join JDE_DB_Alan.vw_Mast m on f.ItemNumber = m.ItemNumber
where m.PrimarySupplier in ('1167')



select f.*,m.Description,m.Family,m.FamilyGroup,m.SupplierName,m.PrimarySupplier,m.StandardCost,f.FC_Vol * m.StandardCost as  Stk_Amt,m.QtyOnHand
from JDE_DB_Alan.vw_FC f left join JDE_DB_Alan.vw_Mast m on f.ItemNumber = m.ItemNumber
     
where m.PrimarySupplier in ('1102')
----where m.PrimarySupplier in ('1167')



----- Forecast for 1102 - Qmotion -----
select * from JDE_DB_Alan.vw_FC f where f.ItemNumber in ('34.306.000')
select * from JDE_DB_Alan.Master_Vendor_Item_CrossRef v where v.ItemNumber in ('34.306.000')
select * from JDE_DB_Alan.vw_Mast_Vendor_Item_CrossRef v where v.ItemNumber in ('34.306.000')

select f.*,m.Description,m.UOM,m.PrimarySupplier
from JDE_DB_Alan.vw_FC f left join JDE_DB_Alan.vw_Mast m on f.ItemNumber = m.ItemNumber
     left join JDE_DB_Alan.vw_Mast_Vendor_Item_CrossRef v on f.ItemNumber = v.ItemNumber    
where m.PrimarySupplier in ('1102')
     -- and f.ItemNumber in ('34.363.000')


----- Forecast for 1102 - Qmotion ----- one month old

select a.ItemNumber as HD_Item_Number,v.Customer_Supplier_ItemNumber as Qmotion_Item_Number,m.Description,m.UOM
       ,a.myDate2 as FC_Date,a.FC_Vol as FC_Quantity,a.ReportDate,m.PrimarySupplier,m.PlannerNumber,m.Owner_
from  (

					select fh.*,fh.myDate1 as FCDate_
						 from JDE_DB_Alan.vw_FC_Hist fh												-- Need to Get Last month Saved FC data -- 14/9/2018
						 where fh.myReportDate2 = cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-',''),1,6) as integer)	
							   and	fh.Date	> DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0) 		-- since using last month data, so need to push out fc 1 month --- 6/12/2018
						       and fh.Date  <  DATEADD(mm, DATEDIFF(m,0,GETDATE())+12,0) 	-- only provide 12 month fc, but need to add 1 since you push out 1 month7/10/2020
							 
							 --and fh.ItemNumber in ('34.306.000')
           ) a left join JDE_DB_Alan.vw_Mast m on a.ItemNumber = m.ItemNumber
		   left join JDE_DB_Alan.vw_Mast_Vendor_Item_CrossRef v on a.ItemNumber = v.ItemNumber 
where m.PrimarySupplier in ('1102')
order by m.PrimarySupplier,a.ItemNumber,a.myDate2


select * from JDE_DB_Alan.vw_Mast m where m.ItemNumber in ('44.013.001','44.014.001')

select * from JDE_DB_Alan.TextileFC f
order by f.Reportdate desc


exec JDE_DB_Alan.sp_Z_Vendor_FC_Report'1102','M-1'
exec JDE_DB_Alan.sp_Z_Vendor_FC_Report'1102','M+0'


select * from JDE_DB_Alan.vw_Mast m where m.ItemNumber like ('28.%') and m.StockingType in ('P')


select * from JDE_DB_Alan.vw_Mast m where m.ItemNumber like ('6610930000')

select * from JDE_DB_Alan.


------------------------------
select * from JDE_DB_Alan.vw_FC f
--where f.ItemNumber in ('34.306.000')
where f.ItemNumber in ( select m.ItemNumber from JDE_DB_Alan.vw_Mast m where m.Family in ('E22'))
      and f.FCDate2_ < 202101

select * from JDE_DB_Alan.vw_Mast m where m.Family like ('E22') order by m.ItemNumber                  --- use this one as for Qmotion some product switched to Delfin
--select * from JDE_DB_Alan.vw_Mast m where m.SupplierName like ('%QMO%') order by m.ItemNumber        -- this code will only yield Qmotion supplied product  

select * from JDE_DB_Alan.vw_Mast m where m.ItemNumber in ('34.310.000')

--------------------------------

select * from JDE_DB_Alan.OpenPO p where p.ItemNumber in ('44.011.007')
select f.* from JDE_DB_Alan.FCPRO_MI_tmp f  where f.ItemNumber in ('82.696.901')
select f.* from JDE_DB_Alan.FCPRO_MI_2_tmp f  where f.ItemNumber in ('24.5110.7178')
select f.* from JDE_DB_Alan.FCPRO_MI_2_tmp f  where f.ItemNumber in ('82.696.901')


/****** Script for SelectTopNRows command from SSMS  ******/
SELECT t.ItemNumber
       ,count(t.DataType) as cnt
  FROM [JDE_DB_Alan].[JDE_DB_Alan].[FCPRO_MI_2_tmp] t
  group by t.ItemNumber
  
  having count(t.DataType) >10
  order by t.ItemNumber

  SELECT t.ItemID as itm ,t.*
  FROM JDE_DB_Alan.FCPRO_MI_2_Raw_Data_tmp t
  --where t.ItemNumber in ('24.7219.4460')
  where t.ItemID in ('24.7221.0952')

  select * from JDE_DB_Alan.vw_FC f where f.ItemNumber in ('24.7221.0952')

  SELECT t.ItemNumber as itm ,t.*
  FROM [JDE_DB_Alan].[JDE_DB_Alan].[FCPRO_MI_2_tmp] t
  --where t.ItemNumber in ('24.7219.4460')
  where t.ItemNumber in ('24.7221.0952')


    SELECT t.ItemNumber as itm,t.*
  FROM [JDE_DB_Alan].[JDE_DB_Alan].[FCPRO_MI_2_tmp] t
  where t.ItemNumber in ('24.7219.4460')
 -- where t.ItemNumber in ('24.7221.0952')


 select * from JDE_DB_Alan.vw_Mast m where m.SupplierName like ('%hand%')

 ---------------------------------------------------------------------------------------

select f.ItemNumber,f.FC_Vol,f.FCDate2_,m.Description,m.StandardCost,UOM,m.SupplierName,m.Owner_
from JDE_DB_Alan.vw_FC f left join JDE_DB_Alan.vw_Mast m on f.ItemNumber = m.ItemNumber
where m.FamilyGroup in ('992')
where m.PrimarySupplier in ('1102') and f.FCDate2_ <'202107'



select f.ItemNumber,f.Value,f.Date
from JDE_DB_Alan.FCPRO_Fcst f left join JDE_DB_Alan.vw_Mast m on f.ItemNumber = m.ItemNumber
where m.PrimarySupplier in ('1102') and f.Date <'202001'


select * from JDE_DB_Alan.Master_ML345 m where m.Description like ('%ellipse%')
select * from JDE_DB_Alan.vw_Mast m where m.ItemNumber in ('44.010.003','44.010.004','44.010.005','44.010.001','44.010.002','44.010.006','44.010.007','44.011.003','44.011.004','44.011.005','44.011.001','44.011.002','44.011.006','44.011.007','44.012.003','44.012.004','44.012.008','44.012.007')

select * from JDE_DB_Alan.vw_Mast m where m.ItemNumber in ('38.004.000','38.004.000S')

select * from JDE_DB_Alan.vw_Mast m where m.


select * from JDE_DB_Alan.FCPRO_Fcst

select m.FamilyGroup,sum (case 
		when m.StockValue is null then 0 
		when m.StockValue is not null then m.StockValue
		end ) as stockdollar

  from JDE_DB_Alan.vw_Mast m
  group by m.FamilyGroup
  order by m.FamilyGroup


select * from JDE_DB_Alan.vw_Mast m where m.PrimarySupplier in ('506196')

select * from JDE_DB_Alan.vw_Mast m where m.Family in ('376')

where m.ItemNumber in ('2780034000B','2781211001')

select * from JDE_DB_Alan.Px_AWF_HD_MT_FCPro_upload p where p.ItemNumber in ('1001690')

select * from JDE_DB_Alan.vw_OpenPO p where p.ItemNumber in ('42.210.031')
select * from JDE_DB_Alan.MasterSuperssionItemList l where l.CurrentItemNumber in ('26.802.659t')


select * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h
select * from JDE_DB_Alan.FCPRO_Fcst f where f.ItemNumber in ('52.008.850') and f.DataType1 in ('Adj_FC')

select * from JDE_DB_Alan.vw_Mast m
where m.ItemNumber in ('63328.3000.00.01','63328.3000.00.02','63328.3000.00.12','63328.3000.00.14','63328.3000.00.15','63328.3000.00.16','63328.3000.00.17','63328.3000.00.18','63328.3000.00.20','63328.3000.00.30','63328.3000.00.50','63328.3000.00.60','82336.3000.00.01','82336.3000.00.02','82336.3000.00.12','82336.3000.00.14','82336.3000.00.15','82336.3000.00.16','82336.3000.00.17','82336.3000.00.18','82336.3000.00.20','82336.3000.00.50','82336.3000.00.60','82336.3000.01.01','82336.3000.01.KB','82336.3000.02.02','82336.3000.12.12','82336.3000.16.16','82336.3000.17.17','82336.3000.18.18','82336.3000.20.20','82336.3000.30.30','82336.3000.50.50','82336.3000.50.KB','82336.3000.60.60','82336.3000.60.KB','82536.3000.00.02','82536.3000.00.12','82536.3000.00.16','82536.3000.00.17','82536.3000.00.20')


select * from JDE_DB_Alan.SlsHistoryHD hd where hd.ItemNumber in ('34.417')

select * from JDE_DB_Alan.TestWO

select * from JDE_DB_Alan.FCPRO_NP_tmp n where n.ItemNumber in ('38.013.001')
select * from JDE_DB_Alan.vw_NP_FC_Analysis n where n.ItemNumber in ('38.013.001')
select * from JDE_DB_Alan.FCPRO_Fcst f where f.ItemNumber in ('42.210.031')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('38.013.001','43.525.101')


;WITH n(n) AS
(
    SELECT 1
    UNION ALL
    SELECT n+1 FROM n WHERE n < 50000
)
SELECT n FROM n ORDER BY n
OPTION (MAXRECURSION 0);

---
;WITH x AS (  SELECT TOP (224) [object_id] FROM sys.all_objects )
	 ,t as ( SELECT TOP (50000) n = ROW_NUMBER() OVER (ORDER BY x.[object_id]) 
				FROM x CROSS JOIN x AS y --ORDER BY n 
				)
    ,a as ( select distinct f.ItemNumber from  JDE_DB_Alan.vw_FC f )

select a.ItemNumber,m.Description,rank()over(order by a.itemnumber ) as rnk
from  a left join JDE_DB_Alan.vw_Mast m on a.ItemNumber=m.ItemNumber 

 
select * from JDE_DB_Alan.MasterFamily fm where fm.Code like ('mc%') order by fm.Code
select * from JDE_DB_Alan.SlsHistoryHD hd where hd.ItemNumber in ('45.021.000')
select * from JDE_DB_Alan.SlsHistoryHD hd where hd.ItemNumber in ('82.391.901')
select * from JDE_DB_Alan.SlsHistoryMT mt where mt.ItemNumber in ('45.021.000')
select * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h where h.ItemNumber in ('34.709.000')
select * from JDE_DB_Alan.SlsHistoryHD hd where hd.ItemNumber in ('7454010000')
select * from JDE_DB_Alan.SlsHistoryMT mt where mt.ItemNumber in ('7454010000')

select * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload l where l.ItemNumber in ('82.038.901')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('27.160.661')
select * from JDE_DB_Alan.FCPRO_Fcst f where f.ItemNumber in ('27.160.661','27.246.785')
select * from JDE_DB_Alan.vw_Mast m where m.ItemNumber in ('2780461882','34.345.000')

select * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload l where l.ItemNumber in ('S3000NET5300N001','46.614.500')
select * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload l where l.ItemNumber in ('27.246.785')
select * from JDE_DB_Alan.SlsHistoryHD hd where hd.ItemNumber in ('34.480.000')
select * from JDE_DB_Alan.SlsHistoryMT mt where mt.ItemNumber in ('34.480.000')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('27.246.785')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('34.528.000')
select * from JDE_DB_Alan.FCPRO_NP_tmp np where np.ItemNumber in ('34.528.000')
select * from JDE_DB_Alan.FCPRO_Fcst f where f.ItemNumber in ('34.528.000') order by f.DataType1,Date
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('26.484.000','26.534.000','4171324050','4150155137')
select * from JDE_DB_Alan.Master_ML345 m where m.PrimarySupplier in ('2140857')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('24.7250.4459')
select * from JDE_DB_Alan.FCPRO_Fcst_Accuracy y order by y.Item
select * from JDE_DB_Alan.vw_Mast m 
select * from JDE_DB_Alan.vw_FC
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('82.391.909')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('24.7218.4465','32.501.000','43.211.004','32.379.200','32.380.855','18.607.016','24.7201.0000','24.7102.7052','24.7102.7052','32.455.465','24.7115.0952A','24.7114.0952A','24.7128.0952','709895','24.7353.0000A','24.7136.0155A','709901','24.7120.0952')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('82.391.912')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('24.7218.4465','32.501.000','43.211.004','32.379.200','32.380.855','18.607.016','24.7201.0000','24.7102.7052','24.7102.7052','32.455.465','24.7115.0952A','24.7114.0952A','24.7128.0952','709895','24.7353.0000A','24.7136.0155A','709901','24.7120.0952')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('34.218.000','28.617.002')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('18.010.035')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('82.513.902','82.514.901')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('18.013.089')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('32.521.1858','2780115000','34.710.000')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('7460700000','45.128.000','46.508.500','82.696.921')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('S3000NET5300N904')
select distinct m.StockingType from JDE_DB_Alan.Master_ML345 m 
select distinct m.UOM from JDE_DB_Alan.Master_ML345 m 
select * from JDE_DB_Alan.vw_FC f where f.ItemNumber in ('18.010.035') and f.DataType1 in ('Adj_Fc')
select * from JDE_DB_Alan.FCPRO_Fcst f where f.ItemNumber in ('18.010.035') and f.DataType1 in ('Adj_Fc')
select * from JDE_DB_Alan.FCPRO_MI_2_Raw_Data_tmp f where f.ItemID in ('18.010.035')
select * from JDE_DB_Alan.FCPRO_Fcst f where f.DataType1 in ('Adj_Fc')
select * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload
select * from JDE_DB_Alan.Px_AWF_HD_MT_FCPro_upload
select * from JDE_DB_Alan.OpenPO
 select * from JDE_DB_Alan.vw_FC f where f.ItemNumber in ('43.295.532')
 select * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h
 select * from JDE_DB_Alan.vw_Mast m where m.ItemNumber in ('s3000net5300n001','82.058.901','43.295.532','82.696.901','82.691.901','6431050000')
 select * from JDE_DB_Alan.vw_Mast m where m.ItemNumber in ('24.7250.0000','24.7250.4459','24.7251.0000','24.7399.0199','24.7399.1858','24.7400.7040','32.503.000','32.504.000','32.505.000','32.506.000','34.425.000','34.426.000','34.427.000','34.428.000','34.429.000','34.431.000','34.433.000','34.434.000','34.480.000','34.481.000','34.482.000')
 select * from JDE_DB_Alan.Px_AWF_HD_MT_FCPro_upload p where p.ItemNumber in ('27.161.810')
 select * from JDE_DB_Alan.vw_Mast m where m.ItemNumber in ('18.010.035','18.010.036','18.615.007','24.7102.0199','24.7127.0155','24.7128.0155','24.7129.0155A','24.7201.0000','24.7206.0000','32.379.200','18.013.089','32.380.002','32.455.155','24.5358.0000','24.7124.0155','24.7203.0000','24.7220.0199','S3000NET5300N001','82.696.901','82.696.930')
  select * from JDE_DB_Alan.vw_Mast m where m.ItemNumber in ('42.210.031','46.598.000',)

select p.ItemNumber,count(p.OrderNumber) as ordercnt
from JDE_DB_Alan.vw_OpenPO p
group by p.ItemNumber
order by count(p.OrderNumber) desc


 select * from JDE_DB_Alan.FCPRO_Fcst f where f.ItemNumber in ('0751031000202H')

select * 
from JDE_DB_Alan.FCPRO_Fcst f left join JDE_DB_Alan.vw_Mast m on f.ItemNumber = m.ItemNumber
where 
-- m.PrimarySupplier in ('1228')


--- Inventory probe ----------------

select * from JDE_DB_Alan.vw_Mast m where m.SupplierName like ('%lei%')

 --- WIP PO value by SKU---
SELECT o.ItemNumber,o.QuantityOrdered,m.StandardCost,o.QuantityOrdered * m.StandardCost as CostDollars
  FROM [JDE_DB_Alan].[JDE_DB_Alan].[OpenPO] o left join JDE_DB_Alan.vw_Mast m on o.ItemNumber = m.ItemNumber


  --- WIP PO value Sum --- Use this one
 SELECT sum( o.QuantityOrdered * m.StandardCost) as Total_PO_Amt
  FROM [JDE_DB_Alan].[JDE_DB_Alan].[OpenPO] o left join JDE_DB_Alan.vw_Mast m on o.ItemNumber = m.ItemNumber

  --- SOH value Sum --- 1
Select sum(case when m.QtyOnHand is null then 0 * m.StandardCost
				when m.QtyOnHand is not null then m.QtyOnHand * m.StandardCost
								end ) as SOH_Amt 
								
 from JDE_DB_Alan.vw_Mast m 
 where m.StockingType not in ('Z')
   
   --Or --- SOH value Sum --- 2       -- Use this one since 'U' stocking type there is some diff in terms of calculation
Select sum(case when m.StockValue is null then 0 
				when m.StockValue is not null then StockValue
								end ) as SOH_Amt 
								
 from JDE_DB_Alan.vw_Mast m 

   
   --- combined together ---
   ;with z as 
   (  Select sum(case when m.StockValue is null then 0 
				when m.StockValue is not null then StockValue
								end ) as SOH_Amt , 0 as PO_Amt								
     from JDE_DB_Alan.vw_Mast m 

	 union 

     SELECT 0 as SOH_Amt,sum( o.QuantityOrdered * m.StandardCost) as PO_Amt
     FROM [JDE_DB_Alan].[JDE_DB_Alan].[OpenPO] o left join JDE_DB_Alan.vw_Mast m on o.ItemNumber = m.ItemNumber

	  )
	 select z.SOH_Amt,z.PO_Amt from z



	 select 'store1' as mystore,convert(int,3) as sales
	 union 
	 select 'store1' as mystore,convert(int,5) as sales
	 union 
	 select 'store2' as mystore,convert(int,1) as sales

     select 1 
	 union 
	 select 1 
	 union 
	 select 2 


	 with a as (Select sum(case when m.StockValue is null then 0 
				when m.StockValue is not null then StockValue
								end )  as S_Amt 								
     from JDE_DB_Alan.vw_Mast m 
	   )
	 ,b as
      ( SELECT  sum( o.QuantityOrdered * m.StandardCost)  as S_Amt
        FROM [JDE_DB_Alan].[JDE_DB_Alan].[OpenPO] o left join JDE_DB_Alan.vw_Mast m on o.ItemNumber = m.ItemNumber
		  )

    select * from 


 --- Safety stock calculation --- Exception Reporting that Item has negative sales ( Credits/Returns causing issues for SS calculation ) --- Good it is working --- 6/6/2019

 select * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h 
where h.CYM > 201805 and h.ItemNumber in ('26.058.104')

select * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h 
where h.CYM > 201805 and  h.SalesQty <0  and  h.ItemNumber in ('18.017.117','26.058.104')

-------
with z as (
		 select h.ItemNumber,sum(case when h.SalesQty <0 then 1 else 0 end ) as NegSls_Cnt
		 from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h
		 where h.CYM > 201805 and  h.SalesQty <0  ---and h.ItemNumber in ('26.058.104')
		  group by h.ItemNumber
		)
	,hist as
		 ( select h.ItemNumber,h.SalesQty,h.CYM,sum(h.SalesQty) over (partition by h.itemnumber) as ItemSlsTotal,avg(h.SalesQty) over (partition by h.itemnumber) as ItemSlsAvg
				from  JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h	
				where h.CYM > 201805		
		   )  
select * from z left join hist as h on z.ItemNumber = h.ItemNumber
where h.CYM > 201805 and  h.SalesQty <0 
order by z.NegSls_Cnt desc


exec JDE_DB_Alan.sp_FCPro_ROP_Analysis  null,'2021-03-01','2022-02-01'
exec JDE_DB_Alan.sp_FCPro_ROP_Analysis '26.529.000', '2021-03-01','2022-02-01'			--- has to be C item and under 'ROP' category


select * from JDE_DB_Alan.vw_SafetyStock a where a.ItemNumber in ('42.129.856')						--- SS 1378, x 1.1 for 'B' ; LT extended ( 5 months,with Stdevp of 327 )
 
select * from JDE_DB_Alan.FCPRO_SafetyStock a where a.ItemNumber in ('26.805.000','42.129.856')				--- changed original Jde parameters in Addl System Info        22/3/2021
select * from JDE_DB_Alan.vw_SafetyStock a where a.ItemNumber in ('26.805.000') 

select a.ItemNumber,a.StockingType,a.Pareto from JDE_DB_Alan.vw_Mast a where a.ItemNumber in ('7441500001','7441500182','7441500914','7441700001','7441700182','7441700914','7442700001','7442700182','7442700914','7456500182','7457500001','7457500182','7457500914','7460500000','7460700000','7468500001','7468500182','7468500914','7468700001','7468700182','7468700914','7477500001','7477500182','7477500914','7477700001','7477700182','7477700914','7478500001','7478500182','7478500914','7478700001','7478700182','7478700914','7479500001','7479500182','7479500914','7479700001','7479700182','7479700914','7485700000','7488500001','7488500182','7488500914','7488700001','7488700182','7488700914','7489500001','7489500182','7489500914','7489700001','7489700182','7489700914','7491500001','7491500182','7491500914','7491700001','7491700182','7491700914','7493500001','7493500182','7493500914','7493700001','7493700182','7493700914','7494500001','7494500182','7494500914','7494700001','7494700182','7494700914','7497700001','7497700182','7497700914','7498700001','7498700182','7498700914','7499700001','7499700182','7499700914','7766050000','7766070000','7766250000','46.508.500','46.508.700','46.531.500','46.531.700')	



------------------------------------------------------------------------------

select m.ItemNumber,m.StockingType,m.PlannerNumber,m.SellingGroup
from JDE_DB_Alan.vw_Mast m 
where m.FamilyGroup in ('913')
      and m.StockingType not in ('O','U')
order by m.StockingType


 select distinct n.ItemNumber from JDE_DB_Alan.FCPRO_NP_tmp n
 --select * from JDE_DB_Alan.FCPRO_NP_tmp n
 where n.Comment like ('%lutron%')
       and n.CN_Number like ('%8705%')


exec JDE_DB_Alan.sp_FCPro_FC_Accy_SKU 'LT'
select top 3 * from JDE_DB_Alan.FCPRO_FC_Accy_SKU a where a.DataType in ('Units')


exec JDE_DB_Alan.sp_Cal_SafetyStock 

---- data for accuracy SKU level ---
select z.Item,z.Sales,z.Fcst,z.Bias,z.ABS_,z.ErrPct,z.AccuracyPct,z.Description,z.FamilyGroup_,z.Family_0,z.PrimarySupplier,z.PlannerNumber,z.StockingType,z.FamilyGroup,z.Family,z.Leadtime_Mth,z.LT_Type
from JDE_DB_Alan.FCPRO_FC_Accy_SKU z
where z.DataType in ('Units')
 
---- data for accuracy Family Group level ---

select f.Reportdate,COUNT(*)  from JDE_DB_Alan.FCPRO_FC_Accy_Group f group by f.Reportdate
select * from JDE_DB_Alan.FCPRO_FC_Accy_Group f where f.Reportdate > '20200429'
select * from JDE_DB_Alan.FCPRO_FC_Accy_Group f where f.Reportdate > '2020-04-29 11:00:00'
select * from JDE_DB_Alan.FCPRO_FC_Accy_Group f where f.Reportdate < '20200408'
delete from JDE_DB_Alan.FCPRO_FC_Accy_Group  where Reportdate > '20200408'
delete from JDE_DB_Alan.FCPRO_FC_Accy_Group  where Reportdate > '20200429'
delete from JDE_DB_Alan.FCPRO_FC_Accy_Group  where Reportdate > '2020-04-30 9:00:00'


select * from JDE_DB_Alan.FCPRO_FC_Accy_Group f order by f.DataType,f.Hierarchy_Cat desc,f.Reportdate

select f.Hierarchy_0,f.Sls_,f.FC_,f.Bias_,f.Abs_,f.err1,f.err2,f.err3,f.acc1,f.acc2,f.acc3,f.Reportdate
from JDE_DB_Alan.FCPRO_FC_Accy_Group f
where f.Reportdate = ( select max(a.Reportdate) from JDE_DB_Alan.FCPRO_FC_Accy_Group a )
     and f.DataType in ('Units')
	 and f.Hierarchy_Cat in ('FamilyGroup_')

---- data for accuracy Family level ---

select * from JDE_DB_Alan.FCPRO_FC_Accy_Group f

select f.Hierarchy_0,f.Sls_,f.FC_,f.Bias_,f.Abs_,f.err1,f.err2,f.err3,f.acc1,f.acc2,f.acc3,f.Reportdate
from JDE_DB_Alan.FCPRO_FC_Accy_Group f
where f.Reportdate = ( select max(a.Reportdate) from JDE_DB_Alan.FCPRO_FC_Accy_Group a )
     and f.DataType in ('Units')
	 and f.Hierarchy_Cat in ('Family_')

----------------------------
select f.Hierarchy_0,f.Sls_,f.FC_,f.Bias_,f.Abs_,f.err3,f.acc3,DATEADD(mm, DATEDIFF(m,0,GETDATE()),0) as date_ from JDE_DB_Alan.vw_FC_Accy_FamilyGroup_Rpt f
where f.Hierarchy_0 not in ('Grand_Total')



exec JDE_DB_Alan.sp_FCPro_FC_Accy_Rpt_New 'LT'
exec JDE_DB_Alan.sp_FCPro_FC_Accy_Rpt_New 'Non_LT'

exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis 'cs100','2019-08-01','2020-07-03'

exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis '28.670.000','2020-10-01','2021-09-03'
exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis null,'2020-10-01','2021-09-03'


exec JDE_DB_Alan.sp_Mismatch_Textile_RCCP '82.036.915,82.011.908',null,'2020-08-03'
exec JDE_DB_Alan.sp_Mismatch_Textile_RCCP  null,null,'2021-01-03'				-- works ! 14/2/2020
exec JDE_DB_Alan.sp_Mismatch_Multi '42.210.031',null,'2020-08-03'


exec JDE_DB_Alan.sp_Exp_SO_Inquiry_Super_Mast 
exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis '2801381661,2801381862,2801381320,2801381276,2801381810,2801381324,2801382661,2801382785,2801382320,2801382810,2801382689,2801382180,2801382862,2801382048,2801382879,2801382580,2801382324,2801382276,2801382609,2801382551,2801382669,2801382496,2801406661,2801406862,2801406072,2801406276,2801406351,2801406324,2801407661,2801407862,2801407072,2801407276,2801407351,2801407324,2801389661,2801389785,2801389072,2801389351,2801389689,2801389167,2801389862,2801389048,2801389354,2801389245,2801389324,2801389276,2801389609,2801389551,2801389669,2801389095,2801390661,2801390785,2801390072,2801390351,2801390689,2801390167,2801390862,2801390048,2801390354,2801390245,2801390324,2801390276,2801390609,2801390551,2801390669,2801390095,2801385661,2801385862,2801385320,2801385276,2801385810,2801385324,2801386661,2801386785,2801386320,2801386810,2801386689,2801386180,2801386862,2801386048,2801386879,2801386580,2801386324,2801386276,2801386609,2801386551,2801386669,2801386496,2801395661,2801395862,2801395072,2801395276,2801395351,2801395324,2801396661,2801396785,2801396072,2801396351,2801396689,2801396167,2801396862,2801396048,2801396354,2801396245,2801396324,2801396276,2801396609,2801396551,2801396669,2801396095,2801404000,2801403661,2801403862,2801403072,2801403276,2801403351,2801403324,2801436661,2801436785,2801436072,2801436351,2801436689,2801436167,2801436862,2801436048,2801436354,2801436245,2801436324,2801436276,2801436609,2801436551,2801436669,2801436095,2801405661,2801405785,2801405072,2801405351,2801405689,2801405167,2801405862,2801405048,2801405354,2801405245,2801405324,2801405276,2801405609,2801405551,2801405669,2801405095,KIT2758,KIT2759,2911529661,2911529862,2911529072,2911529276,2911529351,2911529324,2911530661,2911530862,2911530072,2911530276,2911530351,2911530324,2911531661,2911531785,2911531072,2911531351,2911531689,2911531167,2911531862,2911531048,2911531354,2911531245,2911531324,2911531276,2911531609,2911531551,2911531669,2911531095,2911532661,2911532785,2911532072,2911532351,2911532689,2911532167,2911532862,2911532048,2911532354,2911532245,2911532324,2911532276,2911532609,2911532551,2911532669,2911532095,2801471000,7502000000,7502001000,7501005000,7501001000,7804000000,2801499661,2801499785,2801499072,2801499351,2801499689,2801499167,2801499862,2801499048,2801499354,2801499245,2801499324,2801499276,2801499609,2801499551,2801499669,2801499095,2801999000,2781208000,2801454000,2801350000,2801433661,2801433862,2801433072,2801433276,2801433351,2801433324,2801434661,2801434862,2801434072,2801434276,2801434351,2801434324,2801490661,2801490785,2801490072,2801490351,2801490689,2801490167,2801490862,2801490048,2801490354,2801490245,2801490324,2801490276,2801490609,2801490551,2801490669,2801490095,2801491661,2801491785,2801491072,2801491351,2801491689,2801491167,2801491862,2801491048,2801491354,2801491245,2801491324,2801491276,2801491609,2801491551,2801491669,2801491095,2851512661,2851218661,2851224661,2851230661,2851236661,2851284661,2851512785,2851218785,2851224785,2851230785,2851236785,2851284785,2851512072,2851218072,2851224072,2851230072,2851236072,2851284072,2851512351,2851218351,2851224351,2851230351,2851236351,2851284351,2851218689,2851224689,2851230689,2851236689,2851284689,2851512167,2851218167,2851224167,2851230167,2851236167,2851284167,2851512862,2851218862,2851224862,2851230862,2851236862,2851284862,2851284048,2851218354,2851224354,2851230354,2851236354,2851284354,2851218245,2851224245,2851230245,2851236245,2851284245,2851284324,2851218276,2851224276,2851230276,2851236276,2851284276,2851284609,2851218551,2851224551,2851230551,2851236551,2851284551,2851284669,2851284095','2018-10-01','2019-09-03'
exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis '18.017.031,82.336.901,82.336.901','2019-03-01','2019-12-03'
exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis 'S3000NET5300N904,WS03AA-A118118,26.228.000,2982028000B,40.129.131','2019-11-01','2020-10-03'
exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis null,'2020-09-01','2021-08-03'
exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis '82.058.901,43.295.532,43.207.637M,63328.3000.00.12,43.207.565M,0850531003030H,44.011.007','2019-11-01','2020-10-03'
exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis '2991497000,45.104.000,34.480.000,34.519.000,24.7361.1858,24.7378.1858,34.710.000,34.711.000','2019-06-01','2020-03-03'
exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis '26.528.030,26.519.030,6000130009004H,4199030822','2019-09-01','2020-08-03'
exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis '24.7250.0000,24.7250.4459,24.7251.0000,24.7399.0199,24.7399.1858,24.7400.7040,32.503.000,32.504.000,32.505.000,32.506.000,34.425.000,34.426.000,34.427.000,34.428.000,34.429.000,34.431.000,34.433.000,34.434.000,34.480.000,34.481.000,34.482.000','2019-05-01','2020-04-03'
exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis 'S3000NET5250N001,S3000NET5250N002,S3000NET5250N003,S3000NET5250N010,S3000NET5250N012,S3000NET5250N025,S3000NET5250N301,S3000NET5250N901,S3000NET5250N903,S3000NET5250N904,S3000NET5300N001,S3000NET5300N002,S3000NET5300N003,S3000NET5300N010,S3000NET5300N012,S3000NET5300N025,S3000NET5300N301,S3000NET5300N901,S3000NET5300N902,S3000NET5300N903,S3000NET5300N904','2019-09-01','2020-08-03'
exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis '2780142000B,2780157000B,4199020000,4199070000,82.081.901,28.602.000','2019-12-01','2020-11-03'
exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis '34.263.0155,34.264.0155,34.265.0155,34.266.0000,34.267.0155,34.268.0000,34.269.0000,34.270.0000,34.271.0300,34.272.0155,34.273.0155,34.274.0155,34.275.0155,34.276.0000,34.277.0155,34.278.0300,34.279.0300,34.280.0300,34.281.0155,34.283.0300,34.284.0300,34.285.0155','2020-10-01','2021-09-03'


exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis '31.001.131,31.001.952,31.002.131,31.002.952,31.003.131,31.003.952,31.004.131,31.004.952,31.005.063,31.006.063,31.034.000,31.035.000,31.008.952,31.009.952,31.010.030,31.010.131,31.011.030,31.011.131,31.012.030,31.012.131,31.013.131,31.013.133,31.014.131,31.014.133,31.015.131,31.015.133,31.016.131,31.016.133,31.017.133,31.018.133,31.019.131,31.019.133,31.020.131,31.020.133,31.021.133,31.022.133,31.023.131,31.023.133,31.024.131,31.024.133,31.025.131,31.025.133,31.026.131,31.026.133,31.027.131,31.027.133,31.028.131,31.028.133,31.029.131,31.029.952,31.030.131,31.030.133,31.031.952,31.032.131,31.032.952,31.033.131,31.033.952','2019-07-01','2020-06-03'

select * from JDE_DB_Alan.vw_Mast m where m.ItemNumber in ('31.010.030','31.005.063')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('31.010.030','31.005.063')

exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis 'S3000NET5250N001,S3000NET5250N002,S3000NET5250N003,S3000NET5250N010,S3000NET5250N012,S3000NET5250N025,S3000NET5250N301,S3000NET5250N901,S3000NET5250N903,S3000NET5250N904,S3000NET5300N001,S3000NET5300N002,S3000NET5300N003,S3000NET5300N010,S3000NET5300N012,S3000NET5300N025,S3000NET5300N301,S3000NET5300N901,S3000NET5300N902,S3000NET5300N903,S3000NET5300N904','2019-09-01','2020-08-03'

exec JDE_DB_Alan.sp_Exp_FPFcst_func2Jde_AdHoc '38.013.001,38.013.002'

select * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload u 
where u.SalesQty_Adj = 600 and u.CYM = 202007
order by u.FamilyGroup

select * from JDE_DB_Alan.vw_FC f where f.ItemNumber in ('4152336785B')     --- tension body  -- Duette

 -------------    Sales & FC Discrepancy ------------------------
exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis null,'2019-02-01','2020-01-03','rnk'
exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis null,'2019-01-01','2019-06-03','Ratio_Sls_FC'

select * from JDE_DB_Alan.vw_NP_FC_Analysis a
select * from JDE_DB_Alan.vw_Mast m where m.ItemNumber in ('24.7363.0199','24.7364.0199','24.7363.1858','24.7364.1858')
select * from JDE_DB_Alan.vw_Mast m where m.ItemNumber in ('82.691.930','43.525.101')
select * from JDE_DB_Alan.Master_ML345


exec JDE_DB_Alan.sp_MI_2_Raw_Combine_Sim_Mismatch_1mOff '6610350000','2019-06-03'
exec JDE_DB_Alan.sp_MI_2_Raw_Combine_Sim_Mismatch_1mOff '46.005.000,46.012.000,46.011.000,46.606.000,46.607.000,46.608.000','2020-06-03'


select * from JDE_DB_Alan.Px_AWF_HD_MT_FCPro_upload p where p.Family is null
select * from JDE_DB_Alan.vw_Mast m where m.ItemNumber in ('05.980.000')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('7520065000','43.216.001','2780144451','43.216.002','2780145451','43.216.003','4152336450','43.216.004','2780144680','45.133.000','45.134.100','45.133.100','2780145680')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('24.7129.0155A')
select * from JDE_DB_Alan.vw_Mast m where m.Family in ('635') 
select * from JDE_DB_Alan.vw_Mast m where m.FamilyGroup in ('964')  and m.StockingType in ('P','S')
select * from JDE_DB_Alan.vw_Mast m where m.Family in ('89J','89K','89L') 
select distinct m.ItemNumber from JDE_DB_Alan.vw_Mast m where m.FamilyGroup in ('965')  and m.StockingType in ('P','S')

select * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload p where p.ItemNumber in ('28.672.000')


---------------- PO All --------------- 25/2/2021

select * from JDE_DB_Alan.PO_All 

select * from JDE_DB_Alan.PO_All p where p.Item_Number in ('34.223.000*OP100','7390060182')				-- 7390060182 standard lead time is 105 days however actual shipment takes from 94 ( by air ?? ) - 141 days, how much you need to stretch ? maxium ? or Average ? 
select * from JDE_DB_Alan.PO_All p where p.Order_Number in ('511999')              --- this order has air freight line in it
select * from JDE_DB_Alan.PO_All p where p.Order_Number in ('515133')				-- comma delimit issue ( 1,033.20 )

select * from JDE_DB_Alan.PO_All p where p.Address_Number in ('1228')

select p.Item_Number,p.Order_Number,p.Quantity_Ordered,p.Order_Date,p.Actual_Ship_Date,p.Descrip,p.UM from JDE_DB_Alan.PO_All_Staging p where p.Item_Number in ('34.223.000*OP100')
select * from JDE_DB_Alan.vw_Mast m where m.ItemNumber in ('7390060182','24.7219.0952')

-- supplier which has most spending dollars with, their supplier DIFOT change ( graphy ) over last 12 month ( how good or how bad they are );is it only US or global - what is total picture look like; supplier DIFOT by planner, 
--- what is maximum delay you can see ? what category has been impacted most ? how about margin impact ?
-- what is conclusion and recommendations going forward ? Tier 1 / Tier 2 supplier ; also is it a fact that we are paying air freifght only for volumes exceeding our normal yearly FC ? so that means even if we are incurring high amount of
--- air freight cost, we are getting more sales and profits albeit at a bit of cost
--- For any PO which past due date - you can design exception report


select * 
from JDE_DB_Alan.PO_All

 ----- old, no need use 'View' ------
;with p as
  ( 	select p.Short_Item_No,p.Item_Number,p.Or_Ty,p.Order_Number,p.Order_Date,p.Actual_Ship_Date,p.Shipment_Number,p.Quantity_Ordered,p.Quantity_Open
              ,p.Address_Number as Vendor_,p.Buyer_Number,p.Unit_Cost,p.Extended_Price,p.Next_Stat,p.Last_Stat,m.LeadtimeLevel
		from JDE_DB_Alan.PO_All p left join JDE_DB_Alan.vw_Mast m on p.Item_Number = m.ItemNumber
		where p.Item_Number in ('7390060182','24.7219.0952')
	)

select * from p
--where p.Order_Date > '2020-06-01'


select * from JDE_DB_Alan.vw_Mast_Planning m where m.Item_Number in ( '7457500182','7456500182','42.210.031')

select * from JDE_DB_Alan.FCPRO_SafetyStock a where a.ItemNumber in ('42.210.031')
select * from JDE_DB_Alan.vw_SafetyStock a where a.ItemNumber in ('42.210.031')

select a.ItemNumber,a.SS_Adj,max(a.ReportDate)
from JDE_DB_Alan.FCPRO_SafetyStock a
--where a.ReportDate = max(a.ReportDate)
group by a.ItemNumber,a.SS_Adj


select * from JDE_DB_Alan.MasterFamily a where a.Code like ('H58%')
select distinct f.DataType1 from JDE_DB_Alan.vw_FC f
select * from JDE_DB_Alan.vw_FC f


select * from JDE_DB_Alan.vw_Mast_Planning p where p.Item_Number in ('42.210.031')
select * from JDE_DB_Alan.Master_V4102A p where p.Item_Number in ('42.210.031')
select distinct p.ABC_1_Sls from JDE_DB_Alan.Master_V4102A p where p.Item_Number in ('42.210.031')

select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('42.210.031')

select * from JDE_DB_Alan.vw_SafetyStock m where m.ItemNumber in ('42.210.031')
select distinct m.ReportDate from JDE_DB_Alan.vw_SafetyStock m where m.ItemNumber in ('42.210.031')

  --- Use 'View ' --- Simple

 select * from JDE_DB_Alan.vw_PO_All p where p.Item_Number in ('7457500182','7390060182','24.7219.0952')

;with p as ( 
		select 
			   max(LT_Diff) over(partition by p.item_number) as Max_Gap_day	
			  ,min(LT_Diff) over(partition by p.item_number) as Min_Gap_day	
			  ,rank() over ( partition by p.item_number order by order_number) rk_1
			  ,dense_rank() over ( partition by p.item_number order by order_number) rk_2
			  ,count(Order_Number) over( partition by p.item_number) as Orde_Count
			  ,avg(Actual_Ship_LT_Days) over( partition by p.item_number) as Avg_Ship_Days
				,p.*
		      --,p.LT_Diff

		from JDE_DB_Alan.vw_PO_All p
		where p.Item_Number in ('7390060182','24.7219.0952')
		  )

select p.* 
from p
where  p.Order_Date > DATEADD(mm, DATEDIFF(m,0,GETDATE())-11,0)
--order by p.Item_Number,p.LT_Diff desc
order by p.Item_Number,p.rk_1

select distinct p.Item_Number from JDE_DB_Alan.vw_PO_All p

select * from JDE_DB_Alan.vw_OpenPO
select * from JDE_DB_Alan.Master_V4102A
select * from JDE_DB_Alan.vw_Mast

--------------------------- xxxxxxxx ----------------------------------------


select schema_name(o.schema_id) + '.' + o.name as [table],
       'is used by' as ref,
       schema_name(ref_o.schema_id) + '.' + ref_o.name as [object],
       ref_o.type_desc as object_type
from sys.objects o
join sys.sql_expression_dependencies dep
     on o.object_id = dep.referenced_id
join sys.objects ref_o
     on dep.referencing_id = ref_o.object_id
where o.type in ('V', 'U')
      and schema_name(o.schema_id) = 'JDE_DB_Alan'  -- put schema name here
      and o.name = 'vw_NP_FC_Analysis'   -- put table/view name here
order by [object]



select * from JDE_DB_Alan.FCPRO_Fcst f  where f.ItemNumber in ('18.010.035') and f.DataType1 in ('adj_fc')

select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('s3000net5250n001')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('2801748000','2801749000','2801482000','2801483000')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('34.345.000','34.346.000','34.347.000','34.348.000','34.349.000','34.350.000','34.351.000','34.359.000','34.360.000','34.361.000','34.370.000','34.449.000','34.451.000','34.452.000')
select * from JDE_DB_Alan.SlsHistoryHD hd where hd.ItemNumber in ('34.345.000','34.346.000','34.347.000','34.348.000','34.349.000','34.350.000','34.351.000','34.359.000','34.360.000','34.361.000','34.370.000','34.449.000','34.451.000','34.452.000')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('18.017.154')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('4150249103')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('34.429.000','34.460.000','34.474.000','34.475.000','34.476.000','34.478.000')
select * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload l where l.ItemNumber in ('KIT9125')
select * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload l where l.ItemNumber in ('18.013.089','18.009.029')
select * from JDE_DB_Alan.Px_AWF_HD_MT_FCPro_upload l where l.ItemNumber in ('18.013.089','18.009.029')
select distinct l.ItemNumber from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload l
select distinct l.ItemNumber from JDE_DB_Alan.Px_AWF_HD_MT_FCPro_upload l
select * from JDE_DB_Alan.FCPRO_SafetyStock s where s.ItemNumber in ('7501001000')
select * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h where h.ItemNumber in ('7501001000')
select * from JDE_DB_Alan.FCPRO_SafetyStock
select * from JDE_DB_Alan.FCPRO_Fcst f where f.ItemNumber in ('38.001.001') and f.DataType1 like ('Adj%')
select * from JDE_DB_Alan.FCPRO_Fcst f where f.ItemNumber like ('XEC%')

select * from JDE_DB_Alan.vw_Mast m where m.FamilyGroup in ('989') and m.StockingType not in ('O','U') and m.ItemNumber in ('44.015.405')


exec JDE_DB_Alan.sp_FCPro_FC_Sales_Analysis null,null,null
exec JDE_DB_Alan.sp_FCPro_FC_Accy_Data 
exec JDE_DB_Alan.sp_Exp_FPFcst_func2Jde null,'82.633.901,82.633.908,82.633.909,38.001.001,38.003.001,38.004.000,38.001.002,38.001.003,38.001.004,38.001.005,38.001.006,38.002.001,38.002.002,38.002.003,38.002.004,38.002.005,38.002.006,38.003.002,38.003.003,38.003.004,38.003.005,38.003.006','Adj_FC'

select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('P4H108A547')

select  f.ItemID as ItemNumber,f.Date, f.Value
		                from JDE_DB_Alan.FCPRO_MI_2_Raw_Data_tmp f
						where  f.ItemID in ('32.501.000')
select * from JDE_DB_Alan.FCPRO_MI_2_Raw_Data_tmp l order by l.ItemID


select * from JDE_DB_Alan.FCPRO_Fcst_Accuracy a order by a.DataType,a.Item,a.Date_
select * from JDE_DB_Alan.FCPRO_Fcst_Accuracy a where a.Item in ('42.210.031') order by a.Item,a.Date_
select distinct a.ReportDate from JDE_DB_Alan.FCPRO_Fcst_Accuracy a
select * from JDE_DB_Alan.FCPRO_Fcst_History h where h.ItemNumber in ('42.210.031') and h.ReportDate > '2018-09-02' 
order by h.Date

select * 
 from JDE_DB_Alan.FCPRO_NP_tmp np
--from JDE_DB_Alan.vw_NP_FC_Analysis np
where np.ItemNumber in ('4600000230')


select * from JDE_DB_Alan.vw_FC

--select * from JDE_DB_Alan.FCPRO_MI_2_Raw_Data_tmp t order by t.ItemID
--select * from JDE_DB_Alan.FCPRO_MI_2_Raw_Data_tmp t where t.ItemID in ('18.013.089','18.009.029')
--insert into JDE_DB_Alan.FCPRO_MI_2_Raw_Data_tmp values ('18.009.029','2018-10-01',15,'test','test','test','test','2018-08-16','Y','test','2018-08-16')
--delete from JDE_DB_Alan.FCPRO_MI_2_Raw_Data_tmp  where ItemID in ('18.009.029')


select * from JDE_DB_Alan.FCPRO_MI_2_tmp t order by t.ItemNumber
select * from JDE_DB_Alan.FCPRO_MI_2_tmp t order by t.ItemNumber
select * from JDE_DB_Alan.FCPRO_MI_2_tmp t where t.ItemNumber in  ('18.013.089','18.009.029') order by t.ItemNumber
--insert into JDE_DB_Alan.FCPRO_MI_2_tmp values ('18.009.029','2018-10-01',15,'Market Intelligence_2','test','test','test','2018-08-16','Y','test','2018-08-16')
--delete from JDE_DB_Alan.FCPRO_MI_2_tmp  where ItemNumber in ('18.009.029')
select * from JDE_DB_Alan.FCPRO_MI_2_tmp t where ItemNumber in ('24.7218.4462')


select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('43.207.536M')
select * from JDE_DB_Alan.Master_ML345 m where m.Description like ('%lina%')
select * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h where h.ItemNumber in ('6001130009009H')
select * from JDE_DB_Alan.FCPRO_Fcst f where f.ItemNumber in ('38.001.001')

select h.*,m.Colour,m.Description from JDE_DB_Alan.SlsHistoryHD h
                     left join JDE_DB_Alan.vw_Mast m on h.ShortItemNumber = m.ShortItemNumber
 where h.ItemNumber in ('26.353.000','26.353.131','26.353.133','26.353.256','26.353.737','26.353.688','26.353.746')


select * from JDE_DB_Alan.FCPRO_MI_2_Raw_Data_tmp t where t.ItemID in ('18.010.035')

select * from JDE_DB_Alan.FCPRO_Fcst f where f.ItemNumber in ('24.7220.1858')

select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('38.001.001','38.003.001','38.004.000','38.001.002','38.001.003','38.001.004','38.001.005','38.001.006','38.002.001','38.002.002','38.002.003','38.002.004','38.002.005','38.002.006','38.003.002','38.003.003','38.003.004','38.003.005','38.003.006')
 order by m.ItemNumber
 
 select * 
 from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('42.421.855','46.019.000','46.019.063','46.002.000','46.002.063','9761001','9707027','42.180.049','42.603.855','44.209.000','44.210.000','46.504.000','46.505.000','46.506.000','46.507.000','46.614.700','46.614.500','42.204.000','42.230.000','42.236.000','46.203.000','46.524.000','46.510.000','46.011.000','46.011.100','46.011.134','46.011.734','46.011.737','46.011.810','46.011.850','46.602.000','46.602.100','46.602.134','46.602.734','46.602.737','46.602.810','46.011.850','46.021.000','46.517.000','46.005.000','46.005.100','46.005.134','46.005.734','46.005.737','46.005.810','46.005.850','46.004.000','46.004.100','46.004.134','46.004.734','46.004.737','46.004.810','46.005.850','46.012.000','46.012.100','46.012.134','46.012.734','46.012.737','46.012.810','46.012.850','46.603.000','46.603.100','46.603.134','46.603.734','46.603.737','46.603.810','46.012.850','46.013.000','46.013.100','46.013.134','46.013.734','46.013.737','46.013.810','46.013.850','46.604.000','46.604.100','46.604.134','46.604.734','46.604.737','46.604.810','46.013.850','46.608.000','46.608.100','46.608.134','46.608.734','46.608.737','46.608.810','46.608.850','46.606.000','46.606.100','46.606.134','46.606.734','46.606.737','46.606.810','46.606.850','46.607.000','46.607.100','46.607.134','46.607.734','46.607.737','46.607.810','46.607.850','46.610.000','46.609.000','46.611.000','46.306.000','46.599.000','42.064.000','42.065.000','42.066.000','42.067.000','46.518.063','42.068.000','46.108.063','46.530.063','46.405.063','46.406.063','46.407.000','46.408.000','46.409.000','46.410.063','46.411.000','46.412.000','46.025.000','46.414.000','46.416.100','46.419.000','46.419.100','46.420.000','46.020.000','46.020.100','46.205.000','46.502.100','46.502.837','46.502.122','46.512.000','46.513.000','46.514.000','46.515.000','46.516.000','46.500.000','46.520.000','42.198.000','46.550.000','46.551.855','46.552.855','46.553.030','46.553.063','46.556.000','46.557.000','46.558.000','46.559.030','46.560.000','46.561.000','44.132.000','510006','42.063.000','42.056.000','42.057.000','42.058.000','42.501.855','42.505.000','42.506.030','42.512.000','42.649.850','42.651.000','42.522.000','44.131.855','34.095.000','34.099.000','34.075.000','34.076.000','34.098.000','34.080.000','34.097.000','34.020.000','34.216.000','34.230.000','34.215.000','34.231.000','2984495001','34.240.000','34.241.000')
 order by m.ItemNumber

 select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('3400715320','1001690','1001693','1001694','1001696','1001698','1001701','1001707','1001710','1001711','1001715','1001717','1001720','1001726')
  select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('27.285.178','82.691.901')
  select * from JDE_DB_Alan.Px_AWF_HD_MT_FCPro_upload p where p.ItemNumber in ('27.285.178')

select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in  ('S3000NET5250N071','S3000NET5250N201','S3000NET5250N801','S3000NET5250N902','S3000RR3250RR23','S3000RR3250RR44','S3000RR3250RR84','S3000RR3250RR98')
select * from JDE_DB_Alan.FCPRO_Fcst f where f.ItemNumber in ('42.210.031') and f.DataType1 in ('adj_fc') and f.Date between '2021-03-01' and '2022-02-01'

exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis '2974000000','2018-11-01','2019-07-01'
exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis '085552500D064','2018-09-01','2019-07-01'
exec JDE_DB_Alan.sp_FCPro_FC_Sales_Analysis 
exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis '24.7218.4462','2018-09-01','2019-07-01'
exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis '24.7364.1858,24.7200.0001T,24.7221.1858','2018-09-01','2019-07-01'
exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis '7127970914,7493500182,7146040000','2018-09-01','2019-07-01'
exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis '82.696.921,S3000NET5300N904,82.604.904,26.418.000','2019-02-01','2019-12-01'
exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis '4181301785,82.691.932,43.207.532M','2019-11-01','2020-12-01'
exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis '42.210.031','2021-03-01','2022-02-01'
exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis null,'2021-03-01','2022-02-01'




---when using Portfolio report, some points need to remember: 
 --1) Is it Awning ? avoid seasonal trap,not wise to use recent 4 months sales for immediate futue 4 month FC ?
 --) Is it new product ? if it is, then chances are last 3-4 months you may not have sales yet
 --)  




exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis '34.073.000,34.095.000,34.099.000,34.221.000,34.223.000,34.237.000,34.245.000,34.247.000,34.248.000,34.295.000,FT.01391.000.00,FT.01468.000.01','2019-03-01','2019-12-01'

exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis null,'2019-04-01','2020-03-01'

exec JDE_DB_Alan.sp_Exp_FPFcst_func2Jde null,'82.633.906,82.633.904,82.633.903,82.633.908,82.633.905,82.633.901,82.633.907,82.633.902,82.633.909,46.610.000,46.603.134,46.504.000,24.5405.0000,46.606.850,24.7002.0001,46.409.000,24.7102.1858,46.602.000,24.7114.1858,46.604.737,24.7121.1858,46.608.000,24.7122.1858,18.010.035,24.7125.1858,46.414.000,24.7127.1858,46.517.000,24.7129.1858A,46.602.737,24.7202.0001,46.604.000,24.7206.0000,46.606.134,24.7218.4462,46.607.734,32.340.000,46.608.737,32.379.200,7545000000,32.380.855,46.407.000,32.455.462,46.411.000,32.501.000,46.419.100,42.064.000,46.507.000,42.065.000,46.524.000,42.066.000,46.602.134,42.067.000,46.603.000,42.068.000,46.603.737,42.421.855,46.604.134,42.603.855,46.606.000,46.002.000,46.606.737,46.002.063,46.607.100,46.004.000,46.607.810,46.004.100,46.608.134,46.004.134,46.608.850,46.004.734,46.614.500,46.004.737,7602209491,46.004.810,18.607.016,46.005.000,46.408.000,46.005.100,46.410.063,46.005.134,46.412.000,46.005.734,46.419.000,46.005.737,46.420.000,46.005.810,46.506.000,46.005.850,46.510.000,46.011.000,46.518.063,46.011.100,46.530.063,46.011.134,46.602.100,46.011.734,46.602.734,46.011.737,46.602.810,46.011.810,46.603.100,46.011.850,46.603.734,46.012.000,46.603.810,46.012.100,46.604.100,46.012.134,46.604.734,46.012.734,46.604.810,46.012.737,46.606.100,46.012.810,46.606.734,46.012.850,46.606.810,46.013.000,46.607.000,46.013.100,46.607.134,46.013.134,46.607.737,46.013.734,46.607.850,46.013.737,46.608.100,46.013.810,46.608.734,46.013.850,46.608.810,46.019.000,46.609.000,46.019.063,46.611.000,46.021.000,46.614.700,7543000000,7602209490,82.696.931,7602209492,7541002000,18.010.036,46.405.063,18.615.007,46.406.063,46.025.000,S3000NET5250N903,46.108.063,46.306.000','Adj_FC'
exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis '82.691.910,82.696.910','2019-12-01','2020-07-01'
exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis '38.001.001,38.003.001,38.004.000,38.001.002,38.001.003,38.001.004,38.001.005,38.001.006,38.003.002,38.003.003,38.003.004,38.003.005,38.003.006','2019-03-01','2020-02-03'
exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis null,'2019-02-01','2020-01-03'
select * from JDE_DB_Alan.Master_ML345 m where m.itemnumber in ('18.615.007')

select * from JDE_DB_Alan.MasterSupplier s where s.SupplierName like ('%del%')
select * from JDE_DB_Alan.vw_Mast m where m.Description like ('%zen%') and m.StockingType not in ('O','U') and m.FamilyGroup in ('982') and m.Description like ('%bounty%')

select * from JDE_DB_Alan.vw_Mast m where m.StockingType not in ('O','U') and m.FamilyGroup in ('982') order by m.Family


select * from JDE_DB_Alan.FCPRO_SafetyStock ss where ss.ItemNumber in ('7501001000')
select * from JDE_DB_Alan.FCPRO_NP_tmp

select * from JDE_DB_Alan.FCPRO_Fcst m where m.ItemNumber in ('7602209490')
select * from JDE_DB_Alan.FCPRO_Fcst m where m.ItemNumber in ('42.210.031') and m.DataType1 in ('Adj_FC')
select * from JDE_DB_Alan.vw_FC_Hist m where m.ItemNumber in ('42.210.031') and m.DataType1 in ('Adj_FC')
select * from JDE_DB_Alan.vw_FC f where f.ItemNumber in ('42.210.031')
select * from JDE_DB_Alan.FCPRO_Fcst_History h where h.ItemNumber in ('42.210.031')
select distinct h.DataType1 from JDE_DB_Alan.FCPRO_Fcst_History h
select distinct h.DataType1 from JDE_DB_Alan.FCPRO_Fcst h

 select * from JDE_DB_Alan.v m where m.ItemNumber in ('FA.S3300.280.CT','42.210.031')

select * from JDE_DB_Alan.Master_ML345 m where m.Description like ('%petra%') and m.StockingType in ('P','S')
select * from JDE_DB_Alan.Master_ML345 m where m.Description like ('%chester%') and m.StockingType in ('P','S') order by m.ItemNumber
select * from JDE_DB_Alan.Master_ML345 m where (m.Description like ('%linna%') or m.Description like ('%chester%')) and m.StockingType in ('S')  and m.ManFC in ('M') order by m.ItemNumber
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('2780144000','2780143000','2780155000','2780159000')


---  Sales Analysis ------
select distinct h.ItemNumber from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h 
where substring(h.FamilyGroup,1,3) in ( '913','981','982','983')
       
--select top 3 * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h 
select * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h 
where substring(h.FamilyGroup,1,3) in ( '913','981','982','983')
       and h.cym > 201712 and h.CYM < 201901
order by h.FamilyGroup,h.ItemNumber,h.CYM

select * from JDE_DB_Alan.vw_FC f left join JDE_DB_Alan.vw_Mast m on f.ItemNumber = m.ItemNumber   
  where f.ItemNumber in ( 
			  select distinct h.ItemNumber from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h 
				where substring(h.FamilyGroup,1,3) in ( '913','981','982','983')
				   and h.cym > 201712 and h.CYM < 201901
			--order by h.FamilyGroup,h.ItemNumber,h.CYM
)


select * from JDE_DB_Alan.vw_Mast m
where m.SupplierName like ('%turnils%')

--- Love light Roller blind change over --- RB Fabric but exclude Lux Designer fabric/Internal Sunscreen -- total 725 (494+231) SKUs
select distinct f.ItemNumber,FamilyGroup,m.Family 
from JDE_DB_Alan.vw_FC f left join JDE_DB_Alan.vw_Mast m on f.ItemNumber = m.ItemNumber
where m.FamilyGroup in ('986')
       and m.Family in ('70P','70Q','BSF','BSG')
order by m.FamilyGroup,m.family


select distinct f.ItemNumber,FamilyGroup,m.Family 
from JDE_DB_Alan.vw_FC f left join JDE_DB_Alan.vw_Mast m on f.ItemNumber = m.ItemNumber
where m.FamilyGroup in ('982')
       and m.Family in ('H50','H51','H52','H53','H54','H27')								--- Aria only
order by m.FamilyGroup,m.family


select distinct f.ItemNumber,FamilyGroup,m.Family 
from JDE_DB_Alan.vw_FC f left join JDE_DB_Alan.vw_Mast m on f.ItemNumber = m.ItemNumber
where m.FamilyGroup in ('982')
       and m.Family in ('H47','H48')								--- Zen only
order by m.FamilyGroup,m.family




select distinct f.ItemNumber,m.StockingType,m.PlannerNumber,m.Owner_,f.ReportDate 
from JDE_DB_Alan.FCPRO_Fcst_History f left join JDE_DB_Alan.vw_Mast m on f.ItemNumber = m.ItemNumber
where m.FamilyGroup in ('982') and ReportDate between '2019-10-31' and '2019-11-01 9:00:00' 


select distinct f.ItemNumber,m.Description,m.StockingType,m.PlannerNumber,m.Owner_,m.FamilyGroup,m.Family
from JDE_DB_Alan.vw_FC f left join JDE_DB_Alan.vw_Mast m on f.ItemNumber = m.ItemNumber
where m.FamilyGroup in ('982')


select distinct f.ItemNumber,m.Description, m.Family from JDE_DB_Alan.vw_FC f left join JDE_DB_Alan.vw_Mast m on f.ItemNumber = m.ItemNumber   
  where f.ItemNumber in ( 
				  select distinct h.ItemNumber from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h 
			    	--where substring(h.FamilyGroup,1,3) in ( '900') and SUBSTRING(h.family,1,3) in ('E24') 
					  where substring(h.FamilyGroup,1,3) in ( '982')
					   and  (h.cym > 201712 and h.CYM < 201901)
							--order by h.FamilyGroup,h.ItemNumber,h.CYM
							)
order by m.Family

------------- Sales by different UOM -----------------

select  s.ItemNumber
          ,m.ShortItemNumber
		  ,s.Sold_To,s.Date_Req,s.Secondary_Quantity,s.Secondary_UOM,m.FamilyGroup,m.Description
	      ,u.UOM_From,u.UOM_To,u.ShortItemNumber Conv_shtItm,u.Conv_Factor,u.Conv_Factor_2ndToPmy
		  ,s.Secondary_Quantity/u.Conv_Factor as Pack_Qty,s.Extended_Amount,s.Doument_Type,s.Sold_To_Name
		 -- ,GETDATE() as reportdate
	from (JDE_DB_Alan.vw_SO s left join JDE_DB_Alan.vw_Mast m on s.ItemNumber = m.ItemNumber) 
			left join JDE_DB_Alan.Master_UOMConversion u on m.ShortItemNumber = u.ShortItemNumber  and m.UOM = u.UOM_To
   where m.FamilyGroup in ('966')
   


select * from JDE_DB_Alan.TesTSO s where s.Second_Item_Number in ('40.498.004')
select * from JDE_DB_Alan.vw_Mast m where m.ShortItemNumber in ('764158')
select * from JDE_DB_Alan.Master_UOMConversion u where u.ShortItemNumber in ('739833')




select s.Second_Item_Number,s.Sold_To,s.Secondary_Quantity,s.Secondary_Quantity,s.Secondary_UOM,m.ShortItemNumber,m.FamilyGroup
		,u.UOM_From,u.UOM_To,u.Conv_Factor
	from JDE_DB_Alan.TesTSO s left join JDE_DB_Alan.vw_Mast m on s.Second_Item_Number = m.ItemNumber 
			left join JDE_DB_Alan.Master_UOMConversion u on m.ShortItemNumber = u.ShortItemNumber

select * from JDE_DB_Alan.vw_Mast m 
where m.Description like ('%anvil%')
     and m.Family_0 like ('%baha%')

--'913' and left(h.Family,3) = 'X01'

select substring(h.FamilyGroup,1,3) from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h where h.ItemNumber in ('42.210.031')


select * from JDE_DB_Alan.FCPRO_Fcst_History fh where fh.ItemNumber in ('43.205.532M') and fh.ReportDate between '2018-02-01' and '2018-03-01'
select * from JDE_DB_Alan.FCPRO_Fcst_History fh where fh.ItemNumber in ('43.205.532M') and fh.ReportDate > '2020-01-28' and fh.ReportDate <'2020-02-01' 

--- display all record where save date is later than Oct 2019
select * from JDE_DB_Alan.FCPRO_Fcst_History fh where fh.ItemNumber in ('43.205.532M') and
						cast(SUBSTRING(REPLACE(CONVERT(char(10),fh.reportdate,126),'-',''),1,6) as integer) = 202001


---****************************************************************************** ---
--------------------------- xxxxxxxx ----------------------------------------

------- Query forecast For Ana ----- 3/3/2021

select * from JDE_DB_Alan.vw_FC f
select * from JDE_DB_Alan.vw_Mast m where m.PrimarySupplier in ('1228')

select distinct f.ItemNumber
from JDE_DB_Alan.FCPRO_Fcst f left join JDE_DB_Alan.vw_Mast m on f.ItemNumber=m.ItemNumber
--where f.ItemNumber in ('34.247.000')
where m.PrimarySupplier in ('2092128') and f.DataType1 in ('Adj_FC')


select f.ItemNumber,f.DataType1,f.Date,f.Value,
		m.PlannerNumber,m.PrimarySupplier,m.FamilyGroup,m.SupplierName
from JDE_DB_Alan.FCPRO_Fcst f left join JDE_DB_Alan.vw_Mast m on f.ItemNumber=m.ItemNumber
--where f.ItemNumber in ('34.247.000')
where m.PrimarySupplier in ('503947') and f.DataType1 in ('Adj_FC')
     and f.Date <'2020-02-01'


select f.ItemNumber,m.Description,f.DataType1,f.FCDate2_,f.FC_Vol,m.UOM
		,m.PlannerNumber,m.Owner_,m.PrimarySupplier,m.FamilyGroup,m.SupplierName
from JDE_DB_Alan.vw_FC f left join JDE_DB_Alan.vw_Mast m on f.ItemNumber=m.ItemNumber
--where f.ItemNumber in ('4181301661','4181301048','4181301320','4181301765','4181301785','4181301176','3051303661','3051303048','3051303320','3051303765','3051303785','3051303176','4231301661','4231301048','4231301320','4231301765','4231301785','4231301176','6121302','2151308','2151307','2781211000','6281301','6281303','5241301','2131301','4231303','4231302','1081401','7231303','15281','6191403','8291401','CS5822105','CS5822210','4161301','XEC785','XEC105','XEC118','XEC124','XEC131','XEC199')
 where f.ItemNumber in ('34.502.000','34.503.000','34.504.000','34.505.000','34.218.000','34.219.000','34.026.000','34.084.000','34.024.000','34.025.000','34.085.000','34.086.000')

where m.PrimarySupplier in ('1228') and f.DataType1 in ('Adj_FC')				--- 1228 is 'HUNTER DOUGLAS SCANDINAVIA  AB'
     and f.Date <'2022-01-01'


select * from JDE_DB_Alan.FCPRO_SafetyStock s where s.ItemNumber in ('7491700001','7491700914','26.144.0952')


---****************************************************************************** ---



---============= Update FC table =========
 
   --- update forecast value using same table, replacing one month saved fc value with previous month value --- if something is wrong --- 11/2/2020  --- Yeah works !
;update f
 set f.value = f2.value
  from JDE_DB_Alan.FCPRO_Fcst_History f inner join JDE_DB_Alan.FCPRO_Fcst_History f2 on f.ItemNumber = f2.ItemNumber  and f.Date = f2.Date     ---N0 Need ? Need !                                                                                
     where f.ItemNumber = '43.205.532M' 
	       and cast(SUBSTRING(REPLACE(CONVERT(char(10),f.reportdate,126),'-',''),1,6) as integer) =202001
		   and cast(SUBSTRING(REPLACE(CONVERT(char(10),f2.reportdate,126),'-',''),1,6) as integer) =201912


;update f
set f.Value = 803
from JDE_DB_Alan.FCPRO_Fcst f
where f.DataType1 = 'Adj_FC' and f.ItemNumber in ('24.7220.1858')

select * from JDE_DB_Alan.FCPRO_Fcst f where f.ItemNumber in ('24.7220.1858') and f.DataType1 in ('Adj_FC')


select * from JDE_DB_Alan.vw_FC f where f.ItemNumber in ('18.013.089')
select * from JDE_DB_Alan.FCPRO_MI_orig mi 
order by mi.Date,mi.Itemid

select * from JDE_DB_Alan.FCPRO_MI_tmp
select * from JDE_DB_Alan.FCPRO_MI_2_tmp

exec JDE_DB_Alan.sp_Exp_FPFcst_func2Jde_ZeroOut '1385969'

exec JDE_DB_Alan.sp_MI_FC_Check_upload 'MI_1'
exec JDE_DB_Alan.sp_MI_FC_Override_upload 'MI_1'

exec JDE_DB_Alan.sp_FCPRO_Px_MI_PlaceHolder_upload  MI_2
exec JDE_DB_Alan.sp_FCPRO_SlsHistory_MI_PlaceHolder_upload MI_2
 exec [JDE_DB_Alan].sp_FCPRO_SlsHistory_MI_PlaceHolder_upload 'MI_2'


select * from JDE_DB_Alan.FCPRO_MI_tmp mi where mi.ItemNumber in ('311202') order by mi.Date
select * from JDE_DB_Alan.FCPRO_MI_tmp mi where mi.ItemNumber in ('709901') order by mi.Date

select * from JDE_DB_Alan.FCPRO_MI_2_Raw_Data_tmp mi2 order by mi2.ItemID,mi2.Date

select * from JDE_DB_Alan.MasterFamilyGroup
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in  ('82.633.903','82.633.908','S3000NET5300N0AL','S3000NET5300N0PW','S3000NET5300N0SS','S3000NET5300NAMB','S3000NET5300NMMS','S3000NET5300NMTS','S3000NET5300NPMB','S3000NET5300NSAP','S3000NET5300NWWP')
-------------------------------------------------------------------------------------------
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

------------------------------------------------------------------------------------------



select distinct hd.FinancialYear,hd.FinancialMonth from JDE_DB_Alan.SlsHistoryHD hd order by   hd.FinancialYear,hd.FinancialMonth

select * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h where h.ItemNumber in ('45.665.063','45.004.855','45.047.063','45.067.063')
select * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h where h.ItemNumber in ('Z18088A141')

select distinct f.ItemNumber from JDE_DB_Alan.FCPRO_Fcst f where f.ItemNumber in ('2780136000')
where f.ItemNumber in ('42.210.031') and f.DataType1 in ('Adj_FC')
where f.ItemNumber in ('82.391.901') and f.DataType1 in ('Adj_FC')
where f.ItemNumber in ('45.142.100') and f.DataType1 in ('Adj_FC')

select replace(convert(varchar(8), DATEADD(mm, DATEDIFF(m,0,GETDATE())-13,0),126),'-','')


select dateadd(d,-1,dateadd(mm,1,'2018-01-01'))
select dateadd(d,-1,dateadd(mm,1,'2018-02-01'))


;update p
set p.StockingType = 'U'
from JDE_DB_Alan.Master_ML345 p
where p.ShortItemNumber in ( '1377977','1379753','1379770','1379788')


select distinct mi.ItemNumber  from JDE_DB_Alan.FCPRO_MI_tmp mi
select * from JDE_DB_Alan.FCPRO_Fcst_Pareto
select * from JDE_DB_Alan.FCPRO_SafetyStock

select m.ItemNumber,m.LeadtimeLevel,m.PrimarySupplier from JDE_DB_Alan.Master_ML345 m 
where m.PlannerNumber in ('20072')


select distinct f.ItemNumber from JDE_DB_Alan.FCPRO_Fcst f where f.ItemNumber like ('%e%')

select * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h where h.ItemNumber in ('2801471000')

select * from JDE_DB_Alan.SlsHistoryAWF_HD_MT h where h.ItemNumber in ('18.012.053','18.012.047')
select * from JDE_DB_Alan.SlsHistoryHD hd where hd.ItemNumber in ('18.012.053','18.012.047')
select * from JDE_DB_Alan.SlsHistoryMT mt where mt.ItemNumber in ('8328001')
select * from JDE_DB_Alan.SlsHistoryHD hd where hd.ItemNumber in ('8328001')
select * from JDE_DB_Alan.SlsHistorymt mt where mt.ItemNumber in ('4231301320')


select * from JDE_DB_Alan.FCPRO_MI_tmp mi where mi.ItemNumber in ('26.526.030')
select * from JDE_DB_Alan.FCPRO_MI_tmp mi where mi.ItemNumber in ('27.161.320')
select * from JDE_DB_Alan.FCPRO_MI_tmp mi where mi.ItemNumber in ('1081401')
select * from JDE_DB_Alan.FCPRO_NP_tmp np where np.ItemNumber in ('82.604.904')
select distinct np.ItemNumber from JDE_DB_Alan.FCPRO_NP_tmp np

select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('27.170.450')
select * from JDE_DB_Alan.FCPRO_Fcst_History fh where fh.ItemNumber in ('24.7002.0000')
select * from JDE_DB_Alan.SlsHistoryHD hd where hd.ItemNumber in ('2789000748')
select * from JDE_DB_Alan.SlsHistoryHD hd where hd.ItemNumber in ('2789000713')
select * from JDE_DB_Alan.FCPRO_Fcst f where f.ItemNumber in ('18.018.015') order by f.DataType1,f.Date

select * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h where h.ItemNumber in ('18.015.020')



select * from JDE_DB_Alan.OpenPO

select m.ItemNumber,count(m.Description) ct from  JDE_DB_Alan.Master_ML345 m
group by m.ItemNumber
order by ct desc

select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('F8174A908','2932623885') order by m.ItemNumber


select * from JDE_DB_Alan.FCPRO_Fcst f where f.DataType1 not like ('Adj%')
delete from JDE_DB_Alan.FCPRO_Fcst_ where DataType1 not like ('Adj%')

select * into JDE_DB_Alan.FCPRO_Fcst_ from JDE_DB_Alan.FCPRO_Fcst
select * from JDE_DB_Alan.FCPRO_Fcst_

select top 3 * from JDE_DB_Alan.vw_Mast_Planning


select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('4170681133','4170681320','4170681785','4170681862','4170681885','4170681651','4170681180','4170681426','4171290133','4171290120','4171290785','4171290862','4171290885','4171290651','4171290180','4171290426')
order by m.ItemNumber


select * from JDE_DB_Alan.FCPRO_NP_tmp n where n.ItemNumber in ('34.527.000')

select * from JDE_DB_Alan.SlsHistorymt mt where mt.ItemNumber in ('34.079.000')
select * from JDE_DB_Alan.SlsHistoryHD hd where hd.ItemNumber in ('34.079.000')
select * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h where h.ItemNumber in ('34.079.000')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('34.079.000')

select * from JDE_DB_Alan.SlsHistorymt mt where mt.ItemNumber in ('2801385810')
select * from JDE_DB_Alan.SlsHistoryHD hd where hd.ItemNumber in ('2801385810')


select * from JDE_DB_Alan.SlsHistorymt mt where mt.ItemNumber in ('7454010000','46.414.000')
select * from JDE_DB_Alan.SlsHistoryHD hd where hd.ItemNumber in ('7454010000','46.414.000')

select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('7454010000')
select * from JDE_DB_Alan.FCPRO_MI_tmp mi where mi.ItemNumber in ('3024954849F')

select * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h where h.ItemNumber in ('34.107.000')
select * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h where h.ItemNumber in ('27.252.713')


select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('7127400022')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('03.986.000')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('18.012.055','18.012.056')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('45.200.100')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('42.210.031')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('26.881.030')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('24.023.165')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('4231301320')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('03.986.000')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('05.980.000')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('D7174Q748')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('46.614.000')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('38.001.005')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('18.618.041')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('43.212.001','43.212.002','43.212.003','43.212.004')
select * from JDE_DB_Alan.vw_FC f where f.ItemNumber in ('42.210.031') 
select * from JDE_DB_Alan.vw_FC_Hist f where f.ItemNumber in ('42.210.031') and f.ReportDate between ('2018-09-30') and ('2018-09-30 17:00:00')


select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('82.604.905CL')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('34.528.000')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('KIT8105','4152336450','2801471000','45.133.000','45.133.100','45.134.000','45.134.100','2780145680','2780145451','2780144680','2780144451')
select distinct np.ItemNumber from JDE_DB_Alan.FCPRO_NP_tmp np where np.ItemNumber in  ('KIT8105','4152336450','2801471000','45.133.000','45.133.100','45.134.000','45.134.100','2780145680','2780145451','2780144680','2780144451')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('34.524.000','34.525.000','34.526.000')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('4152336451B','4152336849B','4152336450B')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('26.484.000')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('82.296.956')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('42.210.031')
select * from JDE_DB_Alan.MasterFamily fm where fm.Code like ('h%')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('28.676.000')
exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis '34.215.000,34.216.000,34.230.000,34.232.000,34.233.000,34.234.000,34.242.000','2020-01-02','2020-12-01'


select * from JDE_DB_Alan.FCPRO_Fcst f where f.ItemNumber in ('28.676.000')

select * from JDE_DB_Alan.vw_Mast m where m.ItemNumber in ('34.215.000','34.216.000','34.230.000','34.232.000','34.233.000','34.234.000','34.242.000')

exec JDE_DB_Alan.sp_Mismatch_Multi '42.210.031',null,'2020-09-01'
exec JDE_DB_Alan.sp_Mismatch_Multi '34.215.000,34.216.000,34.230.000,34.232.000,34.233.000,34.234.000,34.242.000',null,'2020-09-01'
exec JDE_DB_Alan.sp_Mismatch_Multi_1mOff '34.215.000,34.216.000,34.230.000,34.232.000,34.233.000,34.234.000,34.242.000',null,'2020-09-01'
exec JDE_DB_Alan.sp_Mismatch_Multi '44.003.102,44.003.102CL,44.003.102K,44.003.103,44.003.103CL,44.003.104,44.003.104CL,44.003.104K,44.003.105,44.003.105CL,44.003.106,44.003.106CL,44.003.107,44.003.107CL,44.003.108,44.003.108CL,44.003.109,44.003.109CL,44.003.110,44.003.110CL,44.003.111,44.003.111CL,44.003.112,44.003.112CL,44.003.113,44.003.113CL,44.003.113K,44.003.114,44.003.114CL,44.003.114K,44.004.102,44.004.102CL,44.004.102K,44.004.103,44.004.103CL,44.004.104,44.004.104CL,44.004.104K,44.004.105,44.004.105CL,44.004.106,44.004.106CL,44.004.107,44.004.107CL,44.004.108,44.004.108CL,44.004.109,44.004.109CL,44.004.110,44.004.110CL,44.004.111,44.004.111CL,44.004.112,44.004.112CL,44.004.113,44.004.113CL,44.004.113K,44.004.114,44.004.114CL,44.004.114K,44.004.115,44.004.115CL,44.004.116,44.004.116CL,44.004.117,44.004.117CL,44.004.118,44.004.118CL,44.005.102,44.005.102CL,44.005.102K,44.005.104,44.005.104CL,44.005.104K,44.005.109,44.005.109CL,44.005.110,44.005.110CL,44.005.111,44.005.111CL,44.010.001,44.010.001CL,44.010.002,44.010.002CL,44.010.003,44.010.003CL,44.010.004,44.010.004CL,44.010.005,44.010.005CL,44.010.006,44.010.006CL,44.010.007,44.010.007CL,44.011.001,44.011.001CL,44.011.002,44.011.002CL,44.011.003,44.011.003CL,44.011.004,44.011.004CL,44.011.005,44.011.005CL,44.011.006,44.011.006CL,44.011.007,44.011.007CL,44.012.003,44.012.003CL,44.012.004,44.012.004CL,44.012.007,44.012.007CL,44.012.008,44.012.008CL,44.015.404,44.015.405,44.016.107,44.016.404,44.016.405,44.016.408,44.016.505,44.016.808,44.017.405,44.132.000,44.207.000,44.209.000,44.210.000',null,'2020-09-05'
exec JDE_DB_Alan.sp_Mismatch_Multi '63328.3000.00.01,63328.3000.00.02,63328.3000.00.12,63328.3000.00.15,63328.3000.00.16,63328.3000.00.17,63328.3000.00.18,63328.3000.00.20,63328.3000.00.30,63328.3000.00.50,63328.3000.00.60,82336.2000.15.30,82336.3000.00.01,82336.3000.00.02,82336.3000.00.12,82336.3000.00.14,82336.3000.00.15,82336.3000.00.16,82336.3000.00.17,82336.3000.00.18,82336.3000.00.20,82336.3000.00.30,82336.3000.00.50,82336.3000.00.60,82336.3000.01.01,82336.3000.01.KB,82336.3000.02.02,82336.3000.12.12,82336.3000.15.30,82336.3000.16.16,82336.3000.17.17,82336.3000.18.18,82336.3000.20.20,82336.3000.30.30,82336.3000.50.50,82336.3000.50.KB,82336.3000.60.60,82336.3000.60.KB,82536.3000.00.02,82536.3000.00.12,82536.3000.00.16,82536.3000.00.17,82536.3000.00.20,83.106.902,83.106.903',null,'2020-09-03'
exec JDE_DB_Alan.sp_Mismatch_Multi '42.210.031',null,null
exec JDE_DB_Alan.sp_Mismatch_Multi '18.010.035,18.010.036,18.607.016,18.615.007,24.5403.0000,24.7102.0199,24.7114.0155,24.7125.0155,24.7127.0155,24.7128.0155,24.7129.0155A,24.7201.0000,24.7203.0001,24.7206.0000,24.7220.1858,32.340.000,32.379.200,32.380.855,32.455.855,32.501.000,43.207.565M,82.633.908',null,'2019-09-03'
exec JDE_DB_Alan.sp_Mismatch_Multi '42.210.031','2020-01-05','2020-09-03'

exec JDE_DB_Alan.sp_Mismatch_Multi_V9 '42.210.031','2019-09-03',null,null							-- no 'Start_Fc-SavedDate' or 'End_Fc-SavedDate' - using default setting mean to using current month FC
exec JDE_DB_Alan.sp_Mismatch_Multi_V9 '42.210.031','2019-09-03','2018-09-28','2018-09-30 17:00:00'  -- has 'Start_Fc-SavedDate' or 'End_Fc-SavedDate' range, use FC saved during that range period


select * from JDE_DB_Alan.MasterSuperssionItemList

select * from JDE_DB_Alan.Master_ML345  m
where m.ItemNumber in ('82.691.901','82.691.902','82.691.903','82.691.904','82.691.905','82.691.906','82.691.907','82.691.908','82.691.909','82.691.910','82.691.911','82.691.912','82.691.919','82.691.920','82.691.921','82.691.922','82.691.923','82.691.924','82.691.924','82.691.925','82.691.926','82.691.927','82.691.928','82.691.929','82.691.930','82.691.931','82.691.932','82.691.933','82.691.934','82.696.901','82.696.902','82.696.903','82.696.904','82.696.905','82.696.906','82.696.907','82.696.908','82.696.909','82.696.910','82.696.911','82.696.912','82.696.913','82.696.914','82.696.915','82.696.916','82.696.917','82.696.918','82.696.919','82.696.920','82.696.921','82.696.922','82.696.923','82.696.924','82.696.924','82.696.925','82.696.926','82.696.927','82.696.928','82.696.929','82.696.930','82.696.931','82.696.932','82.696.933','82.696.934','82.696.940','82.696.941','82.696.942')

select * from JDE_DB_Alan.FCPRO_MI_tmp mi order by mi.ItemNumber
select top 1 m.* from JDE_DB_Alan.FCPRO_MI_tmp m
select top 1 n.* from JDE_DB_Alan.FCPRO_NP_tmp n
select * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload s where s.ItemNumber in ('42.210.031')

select * from JDE_DB_Alan.FCPRO_Fcst
select * from  JDE_DB_Alan.FCPRO_SafetyStock s where s.ItemNumber in ('38.003.006')

select * from JDE_DB_Alan.vw_Mast m where m.ItemNumber in ('03.986.000')
select * from JDE_DB_Alan.FCPRO_Fcst f where f.ItemNumber in ('34.363.000')
select * from JDE_DB_Alan.FCPRO_Fcst_Pareto p where p.ItemNumber in ('05.980.000')

select round(5.53,0)



select 
 select * from JDE_DB_Alan.FCPRO_Fcst f where f.DataType1 in ('Adj_FC')
 exec JDE_DB_Alan.sp_Exp_FPFcst_func2Jde null,null,'Adj_FC'

 exec JDE_DB_Alan.sp_Exp_FPFcst_func2Jde  null,'34.523.000,34.522.000,34.521.000,34.519.000,34.514.000,34.515.000,34.516.000,34.520.000,34.513.000,34.517.000,34.518.000','Adj_FC'
 exec JDE_DB_Alan.sp_Exp_FPFcst_func2Jde  null,'38.004.000S','Adj_FC'

  exec JDE_DB_Alan.sp_Exp_FPFcst_func2Jde  null,'25.010.0155,25.010.1858,25.012.0155,25.012.1858,25.020.0155,25.020.1858,25.021.0155,25.021.1858,25.022.0155,25.022.1858,25.023.0155,25.023.1858,25.024.0155,25.024.1858,25.025.0155,25.025.1858,25.026.0155,25.026.1858,25.027.0155,25.027.1858,25.028.0155,25.028.1858,25.029.000,25.030.0155,25.030.1858,25.031.0155,25.031.1858,25.032.000,25.033.000,25.034.000,25.035.000,25.036.000,25.037.030,25.038.0155,25.038.1858,25.039.0155,25.039.1858,25.040.0155,25.040.1858','Adj_FC'
  exec JDE_DB_Alan.sp_Exp_FPFcst_func2Jde  null,'25.010.0155,25.010.1858,25.012.0155,25.012.1858,25.020.0155,25.020.1858,25.021.0155,25.021.1858,25.022.0155,25.022.1858,25.023.0155,25.023.1858,25.024.0155,25.024.1858,25.025.0155,25.025.1858,25.026.0155,25.026.1858,25.027.0155,25.027.1858,25.028.0155,25.028.1858,25.029.000,25.030.0155,25.030.1858,25.031.0155,25.031.1858,25.032.000,25.033.000,25.034.000,25.035.000,25.036.000,25.037.030,25.038.0155,25.038.1858,25.039.0155,25.039.1858,25.040.0155,25.040.1858','Adj_FC'

  exec JDE_DB_Alan.sp_Exp_FPFcst_func2Jde  null,'42.198.000,42.421.855,46.598.000,42.327.215,52.003.032,42.206.031,44.011.007,42.151.855,42.187.855,52.002.000,46.610.000,42.328.000,40.367.173,42.218.031,52.018.000,46.019.000,42.357.252,44.011.003,44.016.404,18.013.090,42.056.000,44.011.004,46.599.000,52.012.000,44.016.408,44.132.000,82.401.024,52.004.000,44.011.006,46.002.000,42.220.031,42.512.000,46.306.000,42.613.886,52.001.134,46.508.500,44.010.007,46.612.700,52.013.000,44.015.404,42.211.031,42.210.031,44.016.405,44.012.007,42.057.000,42.212.031,42.357.131,45.032.063,46.011.000,42.357.481,46.506.000,42.357.804,46.005.000,46.019.063,42.357.493,52.010.032,44.016.808,52.005.000,46.612.500,42.607.032,52.016.000,46.524.000,46.011.134,42.157.031,44.011.002,46.012.000,44.017.405,46.607.000,42.184.049,46.606.000,52.020.000,44.011.005,52.000.063,52.015.000,42.236.000,46.607.134,82.401.015,46.606.134,52.008.000,52.021.000,82.401.022,42.601.886,46.203.000,42.209.031,46.611.000,46.521.700,46.609.000,42.357.286,46.507.000,44.010.004,42.334.000,7156010000,46.002.063,46.419.000,44.012.004,82.401.012,42.077.032,52.014.000,46.108.063,46.505.000,44.015.405,46.011.850,44.012.003,46.021.000,46.005.850,42.213.031,46.517.000,44.011.001,46.005.134,52.016.100,46.011.100,46.012.850,46.615.063,42.230.000,46.606.850,46.607.850,45.624.000,46.502.837,45.658.000,46.500.000,42.320.493,46.012.134,42.614.063,52.008.100,46.607.100,46.607.810,46.606.100,52.011.030S,42.180.049,52.020.100,52.021.100,52.016.134,46.614.700,42.323.031,46.606.810,42.320.850,46.608.000,52.007.063,44.016.107,46.005.100,52.027.000,46.504.000,52.006.000,52.029.010,46.011.810,82.401.013,42.206.063,44.010.006,46.602.134,82.401.004,46.421.000,52.009.000,52.015.100,52.014.100,52.030.000,44.012.008,52.021.134,42.645.002,42.505.000,52.020.134,42.506.030,46.005.810,42.064.000,42.058.000,46.607.734,52.008.134,46.606.734,46.012.810,52.001.850,42.320.481,52.004.000V,52.022.000,82.401.023,52.015.134,46.422.030,46.012.100,82.401.001,46.423.100,42.357.273,44.016.505,42.357.810,42.357.805,46.530.063,46.011.734,82.401.002,44.004.103,46.614.500,52.014.134,46.004.134,46.602.000,46.004.000,40.340.173,42.320.252,18.616.003,44.003.104K,42.320.804,46.608.134,82.296.943,82.401.019,44.005.104K,46.603.134,44.010.003,46.602.100,46.603.000,44.005.102K,42.062.000,82.401.016,34.249.000,46.502.100,52.016.810,18.099.032,34.097.000,46.513.000,42.060.000,52.008.810,46.606.737,52.021.850,82.401.008,46.518.063,46.005.734,46.607.737,82.296.972,6610260000,52.021.810,46.601.000,42.501.855,52.020.850,82.401.017,46.600.000,46.012.734,82.401.009,46.013.000,52.020.810,18.696.031,46.602.810,46.502.122,46.004.100,44.004.114K,46.011.737,40.371.173,52.017.000,46.608.850,42.357.104,44.010.001,52.016.850,46.608.100,46.005.737,46.602.734,42.361.493,46.004.810,52.014.850,52.015.810,34.260.000,44.004.104K,34.096.000,52.014.737,82.401.020,46.514.000,42.632.855,46.608.810,46.603.100,52.022.100,34.020.000,42.655.000,45.623.000,52.008.734,46.012.737,52.016.734,46.603.810,44.003.114K,44.003.113K,42.631.855,52.014.810,82.296.965,42.361.173,44.010.005,42.214.031,52.015.734,46.419.100,52.021.734,42.649.850,42.157.063,82.296.953,6610200000,34.216.000,52.020.734,82.401.003,52.015.850,44.010.002,42.333.000,46.608.734,34.230.000,52.016.737,42.651.000,46.004.734,82.296.986,52.021.737,52.020.737,42.361.481,52.017.134,42.630.493,42.320.810,6610300000,52.008.737,46.550.000,46.016.000,7761030001,42.063.000,44.005.102,82.296.973,46.602.737,45.305.000,42.623.031,42.211.063,46.013.100,42.630.252,42.361.804,46.013.850,46.608.737,46.603.734,46.004.737,42.361.252,46.013.134,52.022.134,42.320.273,42.068.000,40.379.000,52.008.850,42.113.032,46.420.000,52.015.737,82.296.925,42.611.886,46.601.100,82.296.918,82.296.947,46.600.100,42.221.031,52.014.734,42.054.000,46.521.500,42.630.173,46.512.000,42.320.805,82.296.996,42.320.104,46.603.737,34.231.000,42.630.481,82.296.970,82.296.939,42.630.804,82.296.913,7156130000,46.013.810,46.601.810,82.297.949,42.212.063,42.196.031,42.466.030,82.296.909,7441500182,82.296.905,82.296.950,82.297.957,82.296.969,82.296.944,42.610.855,52.022.850,42.222.031,42.157.030,82.296.906,7460700000,46.013.737,44.003.114,42.622.000,52.022.810,82.296.907,82.296.957,46.604.000,42.647.493,82.296.936,42.647.173,42.194.031,42.215.031,46.510.000,46.013.734,42.152.850,45.682.100,46.515.000,82.296.946,52.032.030,46.423.850,42.647.804,82.401.018,45.678.100,52.031.030,46.604.134,42.630.185,52.017.100,45.679.100,34.095.000,46.604.100,82.296.933,42.209.063,42.361.810,82.296.956,42.502.000,42.630.810,34.258.000,34.259.000,46.553.063,42.647.481,45.680.100,82.401.006,45.223.100,34.240.000,42.630.104,52.022.734,45.677.100,45.683.100,42.503.000,42.213.063,45.681.100,42.647.252,34.506.000,82.296.934,46.600.810,45.071.063,42.361.273,42.647.104,46.604.737,82.296.951,82.296.932,7478700914,42.361.805,7493700914,82.296.948,82.401.007,46.414.000,6610340000,6611550000,42.062.173,7479500001,52.022.737,46.604.734,82.297.950,42.055.000,82.296.922,82.296.940,42.647.810,44.133.120,7127930001,42.361.104,46.604.810,46.423.134,46.601.734,82.296.931,46.601.737,45.143.000,46.425.100,45.522.000,82.297.952,7122930182,82.297.948,46.600.734,45.221.100,7457500182,46.600.737,45.057.063,45.403.100,82.297.956,42.065.000,82.296.952,42.180.131,44.004.113K,7127910001,46.020.000,46.205.000,42.223.031,7233020000,46.025.000,7390060182,46.516.000,46.553.030,52.034.000,7127990182,82.296.949,7232127035,7127860182,46.424.100,45.506.000,45.632.000,7232147035,34.224.000,7127890001,52.017.810,7495500001,7153080914,46.020.100,7491500182,7122570182,45.645.100,7126070001,42.611.000,7126070914,7127890914,42.647.185,7127910914,7390400914,7127990001,7468500182,7495500914,82.296.935,42.647.805,45.517.000,7394350914,7468500914,34.239.000,45.625.820,45.402.100,7394350001,7236010182,7468700182,7495700914,45.288.100,7151040914,45.254.100,7326080000,42.066.000,7468700914,34.201.000,7123080182,34.246.000,7495500182,7127850182,45.642.100,45.659.000,45.646.000,7390400001,45.132.100,7127940914,7468500001,45.656.100,7493700001,42.067.000,7127940001,7326020000,7127890182,46.561.000,46.560.000,7127620182,45.273.100,45.122.100,7370250001,7491700914,34.237.000,7390300001,7370200182,7370400914,45.283.000,7370350001,7326030000,7152070182,7350200001,7390030182,7127710914,7122910049,45.115.000,45.148.100,7122720182,7232187035,45.123.100,45.127.000,7390030001,7350150001,45.312.100,45.404.100,45.298.100,45.136.000,45.121.000,45.117.100,7151030914,45.118.000,7390030914,45.120.100,7326010000,45.670.820,45.311.100,82.296.910,7151030001,42.359.286,45.252.100,45.126.100,7122950914,7390200182,7127710001,45.129.100,7122720049,34.241.000,7742140001,7151040001,7350200914,7127710182,7127660182,45.618.100,45.312.000,45.401.100,45.665.063,52.017.734,7122930049,7390400182,7476500182,7127910182,45.103.100,45.146.000,45.127.100,7495700001,7370300182,6610520000,45.138.100,7151030182','Adj_FC'
   exec JDE_DB_Alan.sp_Exp_FPFcst_func2Jde  null,'34.263.0155,34.264.0155,34.265.0155,34.266.0000,34.267.0155,34.268.0000,34.269.0000,34.270.0000,34.271.0300,34.272.0155,34.273.0155,34.274.0155,34.275.0155,34.276.0000,34.277.0155,34.278.0300,34.279.0300,34.280.0300,34.281.0155,34.283.0300,34.284.0300,34.285.0155','Adj_FC'


  exec JDE_DB_Alan.sp_Exp_FPFcst_func2Jde_ZeroOut '1371516'
  select * from JDE_DB_Alan.FCPRO_NP_tmp n where n.ItemNumber in ('26.544.407')
  

select* from JDE_DB_Alan.FCPRO_Fcst_Pareto
select * from JDE_DB_Alan.FCPRO_Fcst_History f where f.ItemNumber in ('46.508.700','46.508.500','46.612.700','7470500000','7470700000')
      and f.ReportDate > '2018-05-05'

select DATEADD(mm, DATEDIFF(m,0,GETDATE())+5,0)


select * from JDE_DB_Alan.vw_Mast m where m.ItemNumber in ('25.037.000')
select * from JDE_DB_Alan.vw_Mast m where m.ItemNumber in ('25.037.030')

--- Signature New Product Post launch Analysis ---
 exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis @Item_id = '2851542072,2851548072,2851542167,2851548167,2851542245,2851548245,2851542351,2851548351,2851542661,2851548661,2851542669,2851548669,2851542689,2851548689,2851542785,2851548785,2851542862,2851548862,2801381661,2801381862,2801381320,2801381276,2801381810,2801381324,2801382661,2801382785,2801382320,2801382810,2801382689,2801382180,2801382862,2801382048,2801382879,2801382580,2801382324,2801382276,2801382609,2801382551,2801382669,2801382496,2801406661,2801406862,2801406072,2801406276,2801406351,2801406324,2801407661,2801407862,2801407072,2801407276,2801407351,2801407324,2801389661,2801389785,2801389072,2801389351,2801389689,2801389167,2801389862,2801389048,2801389354,2801389245,2801389324,2801389276,2801389609,2801389551,2801389669,2801389095,2801390661,2801390785,2801390072,2801390351,2801390689,2801390167,2801390862,2801390048,2801390354,2801390245,2801390324,2801390276,2801390609,2801390551,2801390669,2801390095,2801385661,2801385862,2801385320,2801385276,2801385810,2801385324,2801386661,2801386785,2801386320,2801386810,2801386689,2801386180,2801386862,2801386048,2801386879,2801386580,2801386324,2801386276,2801386609,2801386551,2801386669,2801386496,2801395661,2801395862,2801395072,2801395276,2801395351,2801395324,2801396661,2801396785,2801396072,2801396351,2801396689,2801396167,2801396862,2801396048,2801396354,2801396245,2801396324,2801396276,2801396609,2801396551,2801396669,2801396095,2801404000,2801403661,2801403862,2801403072,2801403276,2801403351,2801403324,2801436661,2801436785,2801436072,2801436351,2801436689,2801436167,2801436862,2801436048,2801436354,2801436245,2801436324,2801436276,2801436609,2801436551,2801436669,2801436095,2801405661,2801405785,2801405072,2801405351,2801405689,2801405167,2801405862,2801405048,2801405354,2801405245,2801405324,2801405276,2801405609,2801405551,2801405669,2801405095,KIT2758,KIT2759,2911529661,2911529862,2911529072,2911529276,2911529351,2911529324,2911530661,2911530862,2911530072,2911530276,2911530351,2911530324,2911531661,2911531785,2911531072,2911531351,2911531689,2911531167,2911531862,2911531048,2911531354,2911531245,2911531324,2911531276,2911531609,2911531551,2911531669,2911531095,2911532661,2911532785,2911532072,2911532351,2911532689,2911532167,2911532862,2911532048,2911532354,2911532245,2911532324,2911532276,2911532609,2911532551,2911532669,2911532095,2801471000,7502000000,7502001000,7501005000,7501001000,7804000000,2801499661,2801499785,2801499072,2801499351,2801499689,2801499167,2801499862,2801499048,2801499354,2801499245,2801499324,2801499276,2801499609,2801499551,2801499669,2801499095,2801999000,2781208000,2801454000,2801350000,2801433661,2801433862,2801433072,2801433276,2801433351,2801433324,2801434661,2801434862,2801434072,2801434276,2801434351,2801434324,2801490661,2801490785,2801490072,2801490351,2801490689,2801490167,2801490862,2801490048,2801490354,2801490245,2801490324,2801490276,2801490609,2801490551,2801490669,2801490095,2801491661,2801491785,2801491072,2801491351,2801491689,2801491167,2801491862,2801491048,2801491354,2801491245,2801491324,2801491276,2801491609,2801491551,2801491669,2801491095,2851512661,2851218661,2851224661,2851230661,2851236661,2851284661,2851512785,2851218785,2851224785,2851230785,2851236785,2851284785,2851512072,2851218072,2851224072,2851230072,2851236072,2851284072,2851512351,2851218351,2851224351,2851230351,2851236351,2851284351,2851218689,2851224689,2851230689,2851236689,2851284689,2851512167,2851218167,2851224167,2851230167,2851236167,2851284167,2851512862,2851218862,2851224862,2851230862,2851236862,2851284862,2851284048,2851218354,2851224354,2851230354,2851236354,2851284354,2851218245,2851224245,2851230245,2851236245,2851284245,2851284324,2851218276,2851224276,2851230276,2851236276,2851284276,2851284609,2851218551,2851224551,2851230551,2851236551,2851284551,2851284669,2851284095'
 exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis @Item_id = '2801404000,KIT2758,KIT2759,2801396785,2801386785,2801382785,2801396661,2801386661,2801382661,2801999000,2781208000,2801396862,2801350000,2801454000,2801389785,2801390785,2801396167,2801386862,2801382862,2801389661,2801396072,2801390661,2801396354,2801396669,2801396609,2801396276,2801389167,2801389072,2801386180,2801382180,2801386879,2801382879,2801386669,2801382669,2801386609,2801382609,2801386276,2801382276,2801389862,2801395661,2801386320,2801382320,2801389354,2801389689,2801389276,2801389669,2801389609,2801390862,2801390167,2801395862,2801390072,2801390354,2801390669,2801390609,2801390276,2801389048,2801389351,2801389245,2801390245,2801390689,2801396048,2801396689,2801390351,2801386689,2801382689,7804000000,2801389095,2801389324,2801390048,2801386048,2801382048,2801389551,2801396245,2801390095,2801390324,2801405785,2801396351,2801436785,2851230785,2801499785,7502000000,2801390551,2801386810,2801382810,2801471000,2801490785,2801385661,2801381661,2801405661,2801490661,2801436661,2851230661,2801499661,2801491785,2801386580,2801382580,2801491661,2801405862,2801396095,2801395276,2801436862,2801499862,2851230862,2911531785,2801490072,2801405167,2911532354,2911531661,2911532276,2911532669,2911531862,2911532609,2801405354,2801405669,2801405276,2801436167,2801405609,2801436354,2801436669,2801499167,2801436276,2801436609,2801405072,2801490167,2801499354,2851284609,2801499276,2801499609,2801499669,2851284669,2801385862,2801395324,2801436072,2801386496,2801385320,2801381862,2801382496,2801381320,2801396551,2801491072,2851230072,2801406661,2801499072,2851230354,2851230167,2851230276,2801490354,2801490669,2801490862,2911532661,2801490276,2801490609,2911532862,2801407661,2851224785,2801406072,2801491167,2801490048,2801490689,2801405689,2801395351,2801386551,2801382551,2801406862,2801436689,2801491354,2801491862,2801406276,2801491609,2801491276,2801491669,2911532072,2911531354,2911532785,2801405048,2801499689,2801407862,2801407072,2801407276,2801436048,2851284048,2801499048,2851284661,2851230689,2801406351,2801491048,2801491689,2851224661,2801396324,2801395072,2801407351,2801490351,2851284785,2801405351,7502001000,7501005000,2801386324,2801406324,2801382324,2911531245,2911532095,2911531072,2911531324,2911532167,2911531095,2911531167,2911531276,2911531669,2911532689,2801436351,2911532551,2911531551,2911531609,2801499351,2851236785,2851230351,2801491351,2801490095,2801403661,2851542785,2851548785,2851224862,2801407324,2801405245,2851218785,2801491095,2801499245,2851236661,2801436245,2801385810,2801381810,2801490245,2851230245,2851224354,2801433661,2911531351,2911531689,2911532245,2911532048,2851224072,2851224167,2851542862,2851542661,2851548072,2851542072,2851542167,2851224276,2851548167,2851548862,2851548661,2851284354,2851284072,2851218661,2851284862,2851236862,2851284167,2851284245,2851284551,2851284276,2851284689,2851284351,2851230551,2801491245,2801434661,2801405095,2801433072,2801499095,2851236072,2851218862,2801403072,2801403862,2801436095,2851284095,2801385324,2801385276,2851224689,2801381276,2801381324,2801403324,2801490551,2911529862,2801434072,2911529661,2851236354,2851236167,2851512785,2851224351,2851548351,2851236276,2801436551,2851548669,2911530276,2801405551,2851542689,2851548689,2801499551,2851542245,2851542351,2851542669,2851548245,2801405324,2801491551,7501001000,2801434862,2911530862,2801433276,2911530661,2801434276,2851218354,2851512661,2801436324,2851218167,2851218072,2851218276,2851236689,2801433862,2911529276,2911530072,2801491324,2801434324,2801490324,2911531048,2911532351,2801433324,2911532324,2801499324,2851284324,2851224245,2851512862,2851218689,2851236351,2851224551,2911530324,2801403351,2801433351,2911529072,2911529324,2911530351,2851512072,2801403276,2851218245,2851236245,2851512167,2851512351,2851218351,2851236551,2851218551,2801434351,2911529351'
 exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis '2801404000','2018-05-01','2018-12-01'       -- works
 exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis null,'2019-03-02','2020-03-03'		-- works
  exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis '6001130009009H,34.247.000','2019-03-01','2020-02-01'
exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis '27.239.664,27.239.470,27.239.502,27.239.467,27.239.487,27.240.664,27.240.470,27.240.502,27.240.467,27.240.487','2019-02-02','2019-12-03'


select m.ItemNumber,m.WholeSalePrice,m.UOM from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('18.010.035','18.010.036','18.607.016','18.615.007','24.5405.0000','24.7002.0001','24.7102.1858','24.7114.1858','24.7121.1858','24.7122.1858','24.7125.1858','24.7127.1858','24.7129.1858A','24.7202.0001','24.7206.0000','24.7218.4462','32.340.000','32.379.200','32.380.855','32.455.462','32.501.000','82.396.931','S3000NET5250N903')

exec JDE_DB_Alan.sp_FCPro_FC_Accy_Data '42.210.031'
exec JDE_DB_Alan.sp_FCPro_FC_Accy_Data '82.501.904'
exec JDE_DB_Alan.sp_FCPro_FC_Accy_Data '42.210.031,32.379.200'

select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber like ('%850531%')
select * from JDE_DB_Alan.FCPRO_Fcst_History h where h.ItemNumber in ('42.210.031') order by h.ItemNumber,h.ReportDate,h.Date

 ------------------------------------------------------------------------------------------------------------------------------------------------------------
 ----- Last Consecutive 12 month -----

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
--select * from r
--select R.N,case when R._T < 0 then R.T_ else R._T end as T, start from R
--select R.N,case when R._T < 0 then R.T_ else R.YY end as T, start from R
  select  n as rnk
        ,YY
        ,cast(SUBSTRING(REPLACE(CONVERT(char(10),start,126),'-',''),1,6) as integer) as [StartDate]		
		,LEFT(datename(month,start),3) AS [month_name]
        ,datepart(month,start) AS [month]
        ,datepart(year,start) AS [year]				
  from R
	order by rnk asc


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



--------------------------------------------------
 select * 
 from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload  h
    where h.ItemNumber in ('18.008.021')
      where h.CYM = cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-',''),1,6) as integer)		

	  	  
--------------------------------------------------------------------------------------------------------------
--- table variable join Mismatch ---

declare @mymi as table
( ItemID varchar(100) not null primary key ,
  FcDate varchar(100) not null,
  FcQty  decimal(18,2) not null )
  
 Insert into @mymi ( ItemId,FcDate,FcQty)
 values 
('32.501.000','2018-09',397.08),
('18.010.035','2018-09',183.6),
('18.615.007','2018-09',183.6),
('18.010.036','2018-09',183.6),
('2780229000','2018-09',1533.96),
('82.391.909','2018-09',500.22),
('32.379.200','2018-09',423.72),
('18.013.089','2018-09',183.6),
('24.7002.0001','2018-09',409.68),
('24.7334.4459','2018-09',183.6),
('24.7102.1858','2018-09',367.38),
('24.7219.4459','2018-09',405.9),
('32.455.155','2018-09',183.6),
('24.7121.4459','2018-09',367.38),
('24.7122.4459','2018-09',183.6),
('24.7124.4459','2018-09',183.6),
('24.7127.4459','2018-09',183.6),
('24.5349.4459','2018-09',183.6),
('24.7120.4459','2018-09',183.6),
('24.7250.4459','2018-09',433.8),
('24.7251.4459','2018-09',433.8),
('24.7253.4459','2018-09',183.6),
('24.7146.4459A','2018-09',183.6),
('24.7207.4459','2018-09',826.02),
('24.7168.4459A','2018-09',367.38),
('24.7169.4459A','2018-09',367.38),
('24.7163.0000A','2018-09',1101.96);
   
--select * from @mymi

 with         
			 po as (
						 select tb.ItemNumber,tb.DataType1,tb.PODate_,tb.poyr,tb.pomth,tb.BuyerName,tb.BuyerNumber,tb.TransactionOriginator,tb.TransactionOrigName,tb.SupplierName
							,sum(tb.PO_Volume) as PO_Vol
					    from JDE_DB_Alan.vw_OpenPO tb
					 -- where tb.ItemNumber in  ( select splitdata from JDE_DB_Alan.dbo.fnSplitString(@Item_id,','))	
					  group by tb.ItemNumber,tb.DataType1,tb.PODate_,tb.poyr,tb.pomth,tb.BuyerName,tb.BuyerNumber,tb.TransactionOriginator,tb.TransactionOrigName,tb.SupplierName

					  )
				--select * from po

				,fc as 
				   ( select f.ItemNumber,f.Date,f.FCDate_,f.FC_Vol,f_.FcQty
				            ,case when FcQty is null then f.FC_Vol
							      when FcQty is not null then f.FC_Vol + f_.FcQty 
								   --   else f.FC_Vol + f_.FcQty
							   end as  FC_Vol_f	   
				     from JDE_DB_Alan.vw_FC f left join @mymi f_ on f.ItemNumber = f_.ItemID and f.FCDate_ = f_.FcDate 
					-- where f.ItemNumber in ( '42.210.031','24.7207.4459')
					     --  and f.Date < '2019-03-01'
					 )
               --select * from fc   
				,tb as 
					(  select f.ItemNumber,f.Date,f.FCDate_,f.FC_Vol_f as FC_Vol
							,isnull(p.PO_Vol,0) PO_Vol
							--,isnull(m.QtyOnHand,0) SOH_Vol
							,isnull(m.QtyOnHand,0) as SOH_Begin_M
							 ,0 as SOH_Vol				 
							--, isnull(m.QtyOnHand,0) as SOH_End_M
							,0 as SOH_End_M
							,m.WholeSalePrice
							 
					 from fc f left join po p on f.ItemNumber = p.ItemNumber and f.FCDate_ = p.PODate_
											left join JDE_DB_Alan.vw_Mast m on f.ItemNumber  = m.ItemNumber and f.FCDate_ = m.SOHDate   -- SOHDate is current month name,also note 'vw_Mast' is clearn without duplicated records
					-- where f.Date< @dt
					 where f.Date < '2019-03-01'
						  -- and f.ItemNumber in ('45.103.000')
								 )
						
			  -- select * from tb        
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
				 --select * from tb_
						   --- running total preparation ---      
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
      
				 -- select * from tbl_
							--- Beginning period inventory preparation ---
				  ,stk_beg as
						  ( select tbl_.ItemNumber as myItemNumber,tbl_.Date as myDate
									,DATEADD(mm, DATEDIFF(m,0,tbl_.Date)+1,0) dte
									,tbl_.SOH_End_M_ as mySOH_Begin_M_
			            
							 from tbl_)
					   --select * from stk_beg

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
								select t_.*, mm.WholeSalePrice as Mywholesaleprice,(mm.WholeSalePrice * t_.FC_Vol) FC_Amt
									   , case when t_.Final_SOH_Begin_M_ <= 0  then 'Y 'else 'N' end as Stk_Out_Stauts
									   ,sum(t_.FC_Vol) over (partition by t_.ItemNumber order by t_.FCDate_ Rows between current row and 2 following ) as CumulativeTotal_FC_Vol_3M			-- only works in SQL 2012 upwards, if you using 2008 need to use below...  https://docs.microsoft.com/en-us/sql/t-sql/queries/select-over-clause-transact-sql?view=sql-server-2017
									   ,sum(t_.FC_Vol) over (partition by t_.ItemNumber order by t_.FCDate_ Rows between 1 following and 3 following ) as CumulativeTotal_FC_Vol_Nxt3M	
									   ,avg(t_.FC_Vol) over (partition by t_.ItemNumber) as Avg_FC_Vol_Nxt8M			--- SQL2008 support this 
									 --  ,mm.PlannerNumber
						 				,case mm.PlannerNumber 
											--when '20071' then 'Domenic Cellucci'		
											when '20071' then 'Rosie Ashpole'
											when '20072' then 'Salman Saeed'
											when '20004' then 'Margaret Dost'	
											when '20005' then 'Imelda Chan'										  
											else 'Unknown'
										end as Owner_
									   ,mm.PrimarySupplier,mm.Description,mm.FamilyGroup_,mm.Family_0									   
								from t_ left join JDE_DB_Alan.vw_Mast mm on t_.ItemNumber = mm.ItemNumber )				-- note that 'vw_Mast ' has clean data 
		 
					   --select * from _t
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
					--   where com.ItemNumber in ('24.7207.4459')
					      where com.ItemNumber in ('32.501.000','18.010.035','18.615.007','18.010.036','2780229000','82.391.909','32.379.200','18.013.089','24.7002.0001','24.7334.4459','24.7102.1858','24.7219.4459','32.455.155','24.7121.4459','24.7122.4459','24.7124.4459','24.7127.4459','24.5349.4459','24.7120.4459','24.7250.4459','24.7251.4459','24.7253.4459','24.7146.4459A','24.7207.4459','24.7168.4459A','24.7169.4459A','24.7163.0000A')
				  --where com.ItemNumber in ( select splitdata from JDE_DB_Alan.dbo.fnSplitString(@Item_id,','))
				  order by com.ItemNumber,com.DataType,com.d2 		



---------------------------------------------------------------------------------------------------------------------------------------
--- Below code is used in JDE_DB_Alan_     --- 6/07/2018 database

/****** Script for SelectTopNRows command from SSMS  ******/
SELECT distinct a.ReportDate
  FROM [JDE_DB_Alan_].[JDE_DB_Alan].[FCPRO_Fcst_Accuracy] a

  --- check numb of records in 'FC_history' table in JDE_DB_Alan_ database
   ;with cte as 
  (
	  select convert(varchar(13),y.ReportDate,120) as Date_Uploaded
				,count(*)  as Records_Uploaded
	  from JDE_DB_Alan.FCPRO_Fcst_Accuracy y
	  group by  convert(varchar(13),y.ReportDate,120) )
  
  select *, sum(cte.Records_Uploaded) over (order by Date_Uploaded) TTL_Records_AccuTbl from cte 
 -- where cte.Date_Uploaded between '2018-05-01' and '2018-05-25'
  order by cte.Date_Uploaded asc


  select * from JDE_DB_Alan.JDE_DB_Alan.FCPRO_Fcst_Accuracy
  select * from JDE_DB_Alan.JDE_DB_Alan.FCPRO_Fcst 
  insert into JDE_DB_Alan.JDE_DB_Alan.FCPRO_Fcst_Accuracy select * from JDE_DB_Alan_.JDE_DB_Alan.FCPRO_Fcst_Accuracy				--- transfer data from one tabel to another table

--- table and its size ---
  
SELECT 
    t.NAME AS TableName,
    s.Name AS SchemaName,
    p.rows AS RowCounts,
    SUM(a.total_pages) * 8 AS TotalSpaceKB, 
    CAST(ROUND(((SUM(a.total_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)) AS TotalSpaceMB,
    SUM(a.used_pages) * 8 AS UsedSpaceKB, 
    CAST(ROUND(((SUM(a.used_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)) AS UsedSpaceMB, 
    (SUM(a.total_pages) - SUM(a.used_pages)) * 8 AS UnusedSpaceKB,
    CAST(ROUND(((SUM(a.total_pages) - SUM(a.used_pages)) * 8) / 1024.00, 2) AS NUMERIC(36, 2)) AS UnusedSpaceMB
FROM 
    sys.tables t
INNER JOIN      
    sys.indexes i ON t.OBJECT_ID = i.object_id
INNER JOIN 
    sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
INNER JOIN 
    sys.allocation_units a ON p.partition_id = a.container_id
LEFT OUTER JOIN 
    sys.schemas s ON t.schema_id = s.schema_id
WHERE 
    t.NAME NOT LIKE 'dt%' 
    AND t.is_ms_shipped = 0
    AND i.OBJECT_ID > 255 
GROUP BY 
    t.Name, s.Name, p.Rows
ORDER BY 
    t.Name


--- spaced used by index  ---

SELECT
    OBJECT_NAME(i.OBJECT_ID) AS TableName,
    i.name AS IndexName,
    i.index_id AS IndexID,
    8 * SUM(a.used_pages) AS 'Indexsize(KB)'
FROM
    sys.indexes AS i JOIN 
    sys.partitions AS p ON p.OBJECT_ID = i.OBJECT_ID AND p.index_id = i.index_id JOIN 
    sys.allocation_units AS a ON a.container_id = p.partition_id
GROUP BY
    i.OBJECT_ID,
    i.index_id,
    i.name
ORDER BY
    OBJECT_NAME(i.OBJECT_ID),
    i.index_id


	------------------------------------------------

select * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h
where h.ItemNumber in ('0751031000202H','0751031000207H','0751031003001H','0751031003030H','0751031003061H','0850525000202H','0850525000207H','0850525000220H','0850525000222H','0850525000707H','0850525003001H','0850525003020H','0850525003021H','0850525003030H','0850525003061H','085052500M178H','0850531000202H','0850531000207H','0850531000220H','0850531000221H','0850531000222H','0850531000707H','0850531000720H','0850531002022H','0850531003001H','0850531003010H','0850531003020H','0850531003021H','0850531003030H','0850531003061H','085053100M178H','43.205.532M','43.205.535M','43.205.536M','43.205.537M','43.205.563M','43.205.568M','43.205.569M','43.205.574M','43.205.582M','43.205.583M','43.205.584M','43.207.532M','43.207.535M','43.207.536M','43.207.537M','43.207.565M','43.207.582M','43.207.584M','43.295.530','43.295.532','43.295.535','43.295.536','43.295.537')


----------------------------------------

-- To Get Details of Test CO/WO ---
select * from JDE_DB_Alan.TestCO 
select * from JDE_DB_Alan.TestWO


;with tb as
   ( select w.ItemNumber,w.OrderQuantity,w.UM,w.WONumber,c.OrderNumber as CO,c.CustomerName
            ,c.ItemNumber as FinItemNumber,c.ItemDescription as FinItemDesp,c.SlsCd2,SlsCd3,c.CO_Name as Proj_Name,c.StateCode2
		from JDE_DB_Alan.TestWO w left join JDE_DB_Alan.TestCO c 
		       on w.WONumber = c.RelatedWONum

     )
   ,tbl as ( select tb.*,m.StockingType,m.WholeSalePrice,m.Description
				from tb left join JDE_DB_Alan.vw_Mast m
                        on tb.ItemNumber = m.ItemNumber
						)
            

    select * from tbl


 select *  from JDE_DB_Alan.FCPRO_Fcst f where f.ItemNumber in ('38.001.001') and f.DataType1 like ('%adj%')         
  select fh.ItemNumber,fh.Date,fh.myDate2,fh.myReportDate1,fh.myReportDate2,fh.myReportDate3,fh.myReportDate4   from JDE_DB_Alan.vw_FC_Hist fh    where fh.ItemNumber in ('38.001.001') 
   select max(fh.reportdate)
   from JDE_DB_Alan.vw_FC_Hist fh 
  where fh.ItemNumber in ('38.001.001') 
        and fh.myDate2 = '201810' 



----------------------------------------------------------
exec JDE_DB_Alan.sp_FCPro_FC_Accy_Rpt 'non-lt'
select * from JDE_DB_Alan.FCPRO_Fcst_Accuracy y where y.Item in ('42.210.031') order by y.DataType desc,y.Item
		 

----------- Isolate Textfile forecast 15/1/2019 -----------------------------------
select * from JDE_DB_Alan.vw_Mast;

with _t as (
			select m.PlannerNumber,m.Owner_,StockingType,count(m.ItemNumber) as SKU_Cnt
			from JDE_DB_Alan.vw_Mast m
			group by m.PlannerNumber,m.Owner_,StockingType
			--order by m.PlannerNumber,SKU_Cnt desc
			)
      ,t_ as ( select t.PlannerNumber,t.Owner_,t.StockingType,t.SKU_Cnt
	                  ,sum(t.SKU_Cnt) over ( partition by t.plannerNumber order by t.SKU_Cnt ) as RunnTTL
	            from _t as t 
				)
      select * from t_
	  order by t_.PlannerNumber desc


select 155832/24

;with fc as (
	select f.*,p.Pareto 
	from JDE_DB_Alan.FCPRO_Fcst f left join JDE_DB_Alan.FCPRO_Fcst_Pareto p on f.ItemNumber = p.ItemNumber
	where f.DataType1 like ('%Adj_FC')		 
	)
select fc.ItemNumber,fc.DataType1,fc.Date,fc.value as QTY,fc.Value * m.WholeSalePrice as FC_Revenue,m.PlannerNumber,m.Owner_
       ,m.UOM
	   ,m.FamilyGroup_,m.Family_0
	   ,fc.Pareto
  from fc left join JDE_DB_Alan.vw_Mast m on fc.ItemNumber = m.ItemNumber
  where m.PlannerNumber in ('20003')



  ---

  select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('09.400.951','09.566.000','82.865.000')



  select * from JDE_DB_Alan.vw_Hist_RM r
  where r.ItemNumber in ('09.400.951')

  select distinct fh.ItemNumber,fh.ReportDate  from JDE_DB_Alan.vw_FC_Hist fh 
  where fh.ReportDate between '2019-01-01 13:20' and '2019-01-10 17:39:00'
    

 select * from JDE_DB_Alan.vw_Mast m where m.ItemNumber like ('%171%')

---
select distinct fh.ItemNumber
from JDE_DB_Alan.vw_FC_Hist fh 
where fh.ReportDate  > '2019-01-10' and fh.ReportDate < '2019-02-10'

select fh.ItemNumber,count(fh.DataType1) cnt
from JDE_DB_Alan.vw_FC_Hist fh 
where fh.ReportDate  > '2019-01-05' and fh.ReportDate < '2019-02-01'
group by fh.ItemNumber


select distinct fh.ItemNumber,ReportDate 
from JDE_DB_Alan.vw_FC_Hist fh 
where fh.ReportDate  > '2019-01-20'
      and fh.ItemNumber in ('82.068.930')


------------------------
   ------ Modifiers  Manupilation ------ 8/10/2019

   with x as 
    ( select * 
	   from JDE_DB_Alan.FCPRO_Modifiers_tmp t
	   
      )
   ,_tb as 
   (
	select  t.*,c.ItemNumber as itm ,c.Comment,c.LastUpdated,c.Modifier as modifier_,c.ReportDate
		from JDE_DB_Alan.FCPRO_Modifiers_tmp t full outer join JDE_DB_Alan.FCPRO_Modifiers_cmt c on t.ItemNumber = c.ItemNumber
	   )
   ,tb_ as 
      ( select _tb.*,m.StockingType 
		from _tb left join JDE_DB_Alan.vw_Mast m on _tb.ItemNumber = m.ItemNumber )

   select * from tb_
   
   

   ----------------------- Sales Order Super Inquiry ------------------------- 17/10/2019

   select * from JDE_DB_Alan.SO_Inquiry_Super
   select * from JDE_DB_Alan.vw_SO_Inquiry_Super s where s.Item_Number in ('43.207.637M','46.598.000')
   select s.Item_Number,s.Description,s.Qty_Ordered,s.YM_Req,s.Extended_Cost,s.Extended_Price from JDE_DB_Alan.vw_SO_Inquiry_Super s

   ;with OpenSO as 
		 ( select 'OpenSO' as Datatype,s.Item_Number,s.Qty_Ordered_LowestLvl,s.Date_Req as Date_
			from JDE_DB_Alan.vw_SO_Inquiry_Super s 
			where s.LastStatus in ('520','540','900','902','904')					-- '520' Sales order entered;'540' Ready to pick;'900' Back order in S/O Entry
         )     
   ,SaleSO as 
		 ( select 'SaleSO' as Datatype ,s.Item_Number,s.Qty_Ordered_LowestLvl,s.Date_Req as Date_
			from JDE_DB_Alan.vw_SO_Inquiry_Super s 
			where s.LastStatus not in ('520','540','900','902','904')				
			--where s.LastStatus in ('902','904','912','980')	-- '902' Backorder in Commitments;'904' Backorder in Ship. Conf.;'912'Added in Commitments';'980' Canceled in Order Entry
         )     

   ,fc as ( select 'FC' as Datatype,f.ItemNumber,f.FC_Vol,f.FCDate2_
				from JDE_DB_Alan.vw_FC f left join JDE_DB_Alan.vw_Mast m on f.ItemNumber = m.ItemNumber				
				)   
   ,comb as ( select * from OpenSO 
            union all
			select * from SaleSO
			union all
			select * from fc
			)
   
   select c.*,m.Description,m.FamilyGroup,m.Family,m.StockingType,m.UOM
    from comb c left join JDE_DB_Alan.vw_Mast m on c.Item_Number = m.ItemNumber
	where m.FamilyGroup in ('913') and m.Family in ('X06','X07')




----- ALWAYS ENTER YOUR CODE ABOVE THIS LINE -------- ----- ALWAYS ENTER YOUR CODE ABOVE THIS LINE -------- ----- ALWAYS ENTER YOUR CODE ABOVE THIS LINE --------
----- NEVER ENTER YOUR CODE BELOW THIS LINE --------- ----- NEVER ENTER YOUR CODE BELOW THIS LINE --------- ----- NEVER ENTER YOUR CODE BELOW THIS LINE ---------

 ---&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&------------------
-- END_EXIT:

-- last line of the script
set noexec off -- Turn execution back on; only needed in SSMS, so as to be able 
               -- to run this script again in the same session.



