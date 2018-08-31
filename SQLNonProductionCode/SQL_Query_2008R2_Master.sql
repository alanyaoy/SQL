
--- 29/11/2017 ---

use DemandPlanning
go


create schema da

select * from sys.schemas
create table 


--- check if comma exist ---
drop table da.test
create table da.test (mycol char(20) ,constraint ck_illegal_char check(charindex(',',mycol)=0 ))					  -- do not allow comma	

create schema da
create table da.test_ (mycol char(20) ,constraint ck_illegal_char check (len(mycol) - len(replace(mycol,',',''))>0))   -- allow comma

create table da.test_ (mycol char(20) )   

create table da.test (mycol char(20) )
--insert into JDE_DB_Alan.test values('tes,t')
insert into da.test select 'test'
union all select 'test,'
union all select 'tes,t'
union all select ',test'
union all select 'ab'
select * from da.test
select charindex(',','test')
select len('test') - len(replace('test',',',''))


CREATE TABLE da.Products  
   (ProductID int PRIMARY KEY NOT NULL,  
    ProductName varchar(25) NOT NULL,  
    Price money NULL,  
    ProductDescription text NULL)  
GO

--========================================================================================================================================
