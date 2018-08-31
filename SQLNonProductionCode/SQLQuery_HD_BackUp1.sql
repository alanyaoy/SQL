
CREATE TABLE JDE_DB_Alan.Products  
   (ProductID int PRIMARY KEY NOT NULL,  
    ProductName varchar(25) NOT NULL,  
    Price money NULL,  
    ProductDescription text NULL)  
GO

select * from dbo.Products 


use JDE_DB_Alan
go

create schema JDE_DB_Alan

CREATE TABLE JDE_DB_Alan.Products  
   (ProductID int PRIMARY KEY NOT NULL,  
    ProductName varchar(25) NOT NULL,  
    Price money NULL,  
    ProductDescription text NULL)  
GO


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
GO	


EXEC sp_configure 'show advanced options', 1
RECONFIGURE
GO
EXEC sp_configure 'ad hoc distributed queries', 1
RECONFIGURE
GO

use JDE_DB_Alan
go
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




-------
use JDE_DB_Alan
go
--26/09/2017

select * from JDE_DB_Alan.MasterFamilyGroup

drop table JDE_DB_Alan.SalesHistoryHDAWF
drop table JDE_DB_Alan.SalesHistoryHD
drop table JDE_DB_Alan.SalesHistoryAWF

drop table JDE_DB_Alan.MasterSellingGroup
drop table JDE_DB_Alan.MasterFamilyGroup
drop table JDE_DB_Alan.MasterFamily
drop table JDE_DB_Alan.MasterPrice

truncate table JDE_DB_Alan.MasterFamilyGroup
delete from JDE_DB_Alan.MasterFamilyGroup

delete from JDE_DB_Alan.SalesHistoryHDAWF

delete from FinalFcstShot where DownLoadDate = '2014-08-01' and date > '2014-08-01'
                                                                and DataType in ('Adjusted History','Revenue History')



--- Transaction Data Tabel Below ---
CREATE TABLE JDE_DB_Alan.SalesHistoryHDAWF 
   ( 
     BU				varchar(100) NOT NULL, 
     ShortItemNum	varchar(100) NOT NULL, 
	 ItemNumber		varchar(100) NOT NULL, 				-- 2nd ItemNumber
	 Century		int NOT NULL,  		 		 
	 FinancialYear	int NOT NULL, 	
	 FinancialMonth	int NOT NULL, 	
	 DocumentType	varchar(100) NOT NULL,
	 Quantity		decimal ,	
	 UOM			varchar(100) NOT NULL 	    
  )  
GO	

CREATE TABLE JDE_DB_Alan.SalesHistoryHD  
   ( 
     BU				varchar(100) NOT NULL, 
     ShortItemNum	varchar(100) NOT NULL, 
	 ItemNumber		varchar(100) NOT NULL, 				-- 2nd ItemNumber
	 Century		int NOT NULL,  		 		 
	 FinancialYear	int NOT NULL, 	
	 FinancialMonth	int NOT NULL, 	
	 DocumentType	varchar(100) NOT NULL, 
	 Quantity		decimal,	
	 UOM			varchar(100) NOT NULL 	    
  )  
GO	

CREATE TABLE JDE_DB_Alan.SalesHistoryAWF  
   ( 
     BU				varchar(100) NOT NULL, 
     ShortItemNum	varchar(100) NOT NULL, 
	 ItemNumber		varchar(100) NOT NULL, 				-- 2nd ItemNumber
	 Century		int NOT NULL,  		 		 
	 FinancialYear	int NOT NULL, 	
	 FinancialMonth	int NOT NULL, 	
	 DocumentType	varchar(100) NOT NULL,
	 Quantity		decimal ,	
	 UOM			varchar(100) NOT NULL 	    
  )  
GO	


--- Master Data Table Below ---

CREATE TABLE JDE_DB_Alan.MasterSellingGroup  
   ( 
     Code			varchar(100) NOT NULL, 
     Description	varchar(100), 
	 LongDescription varchar(100)    
  )  
GO

CREATE TABLE JDE_DB_Alan.MasterFamilyGroup
   ( 
     Code			varchar(100) NOT NULL, 
     Description	varchar(100), 
	 LongDescription varchar(100)    
  )  
GO	

CREATE TABLE JDE_DB_Alan.MasterFamily
   ( 
     Code				varchar(100) NOT NULL, 
     Description		varchar(100), 
	 Description2		varchar(100), 
	 LongDescription	varchar(100)	    
  )  
GO		

CREATE TABLE JDE_DB_Alan.Master_Description_Hierarchy_SKU_Level
   ( 
     BU					varchar(100) NOT NULL, 
	 ItemNumber			varchar(100) NOT NULL, 
     Description		varchar(100), 
	 ShortItemNumber	varchar(100), 
	 SellingGroup		varchar(100),
	 FamilyGroup		varchar(100),
	 Family				varchar(100)
  )  
GO	

CREATE TABLE JDE_DB_Alan.MasterPrice
   ( 
     RawLabel		varchar(100) NOT NULL, 
     SellingGroup	varchar(100) not null, 
	 FamilyGroup	varchar(100) not null, 				-- 2nd ItemNumber
	 Family			varchar(100) not null,  		 		 
	 ItemNumber		varchar(100) not null primary key,	
	 StandardCost	decimal(18,6),	
	 WholeSalePrice	decimal(18,6)	    
  )  
GO	


use JDE_DB_Alan
go


--- bulk insert for Master Data ---

--BULK INSERT JDE_DB_Alan.MasterSellingGroup
--BULK INSERT JDE_DB_Alan.MasterFamilyGroup
--BULK INSERT JDE_DB_Alan.MasterFamily
--BULK INSERT JDE_DB_Alan.Master_Description_Hierarchy_SKU_Level
BULK INSERT JDE_DB_Alan.MasterPrice
    --  from 'C:\Alan_GWA_C\Work\ImportData.csv'
    -- from 'E:\ImportDataa.txt'
       
    --  from 'T:\Forecast Pro\Forecast Pro TRAC\Input\HD Branch Plant\archive\Master\Master_Description_Hierarchy_SKU_Level_CSV.csv'
    --  from 'T:\Forecast Pro\Forecast Pro TRAC\Input\HD Branch Plant\archive\Master\HierarchyMaster_SellingGroup_CSV.csv'
    --  from 'T:\Forecast Pro\Forecast Pro TRAC\Input\HD Branch Plant\archive\Master\HierarchyMaster_FamilyGroup_CSV.csv'
	--  from 'T:\Forecast Pro\Forecast Pro TRAC\Input\HD Branch Plant\archive\Master\HierarchyMaster_Family_CSV.csv'
	   from 'T:\Forecast Pro\Forecast Pro TRAC\Input\HD Branch Plant\archive\Master\Report_HD_Conversions_CSV.csv'
	
	with  (
        --   Fieldteminator='',
        --   Rowteminator ='\n',
            
        FIELDTERMINATOR =',',
        ROWTERMINATOR = '\n',
        FIRSTROW =2     
			
			) 


--- bulk insert for Transaction Data ---

  BULK INSERT JDE_DB_Alan.SalesHistoryHDAWF
--BULK INSERT JDE_DB_Alan.SalesHistoryHD
--BULK INSERT JDE_DB_Alan.SalesHistoryAWF

    --  from 'C:\Alan_GWA_C\Work\ImportData.csv'
    -- from 'E:\ImportDataa.txt'       
   from 'T:\Forecast Pro\Forecast Pro TRAC\Input\HD Branch Plant\archive\FC_Raw_Data\IM and RI Transactions HD_AWF Since Jan15_CSV.csv'
   with  (
        --   Fieldteminator='',
        --   Rowteminator ='\n',
            
        FIELDTERMINATOR =',',
        ROWTERMINATOR = '\n',
        FIRSTROW =2     
			
			) 


select * from JDE_DB_Alan.MasterFamilyGroup a 
--where a.Code = ''
where a.Description like ('%/S2')
 order by a.Code


 
select * from JDE_DB_Alan.MasterSellingGroup a where a.Code like ('A%')
select * from JDE_DB_Alan.Master_Description_Hierarchy_SKU_Level a where a.ItemNumber like ('%3004')

select * from JDE_DB_Alan.SalesHistoryHDAWF a where a.ItemNumber like ('%161.135')


--- Query to get Upload data for Forecasst Pro) ---

ALTER TABLE JDE_DB_Alan.MasterPrice
ALTER COLUMN   WholeSalePrice decimal(18,6);
ALTER COLUMN  StandardCost decimal(18,6);


--- CTE --

with tbl as (
select b.BU,a.ItemNumber,a.FinancialYear,a.FinancialMonth,a.Quantity,a.Quantity * (-1) as SalesQty,b.Description,b.SellingGroup,b.FamilyGroup,b.Family,a.UOM
 from	JDE_DB_Alan.SalesHistoryHDAWF a left join JDE_DB_Alan.Master_Description_Hierarchy_SKU_Level b
		on a.ItemNumber = b.ItemNumber
--where a.ItemNumber in ('27.161.135') 
       ),

staging as 
(select  tbl.*
		,c.LongDescription as SellingGroup_
		,d.LongDescription as FamilyGroup_
		,e.LongDescription as Family_
		,f.StandardCost,f.WholeSalePrice
from tbl left join JDE_DB_Alan.MasterSellingGroup c  on tbl.SellingGroup = c.Code
         left join JDE_DB_Alan.MasterFamilyGroup d  on tbl.FamilyGroup = d.Code
		 left join JDE_DB_Alan.MasterFamily e  on tbl.Family = e.Code
		 left join JDE_DB_Alan.MasterPrice f on tbl.ItemNumber = f.ItemNumber
)

--select * from staging where staging.ItemNumber in ('27.161.135')

--select 'Total' as RowLabel,staging.* from staging
select 'Total' as RowLabel,staging.SellingGroup_ as SellingGroup,staging.FamilyGroup_ as FamilyGroup,staging.Family_ as Family
		,staging.ItemNumber,staging.Description,staging.FinancialYear as Year,staging.FinancialMonth as Month,'12' as PPY, '12' as PPC
		,staging.SalesQty,staging.StandardCost,staging.WholeSalePrice,SalesQty*StandardCost as InventoryVal, SalesQty*WholeSalePrice as SalesVal
from staging
--where staging.ItemNumber in ('27.161.135')
where StandardCost > WholeSalePrice
order by SalesVal desc


--- end of CTE ---


select * from JDE_DB_Alan.MasterPrice p where p.ItemNumber in ('18.016.030')

SELECT p.ItemNumber, COUNT(*) as countof
FROM JDE_DB_Alan.MasterPrice p
GROUP BY p.ItemNumber
HAVING COUNT(*) > 1