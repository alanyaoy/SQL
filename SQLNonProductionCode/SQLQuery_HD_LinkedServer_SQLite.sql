--- in SQL Server SSMS ---
USE [master]
GO
EXEC sp_addlinkedserver 
@server = 'SQLite3_Proj5_32', -- the name you give the server in SSMS 
@srvproduct = '', -- Can be blank but not NULL
@provider = 'MSDASQL', 
@datasrc = 'SQLite3_Proj5_32' -- the name of the system dsn connection you created
GO



Select *
from openquery("SQLite3_Proj5_32", 'select * from trac_dates x where x.abs_period =24181')
GO


--- in WINSql code file ---

-------- 11/10/2017 -------------------------------------------------------------------------------------------------------------
select * from trac_items a where a.itemid4 in ('2851218661')

--------------------------------------------
select * from trac_forecasts limit 10
select count(*) from trac_forecasts
select count(distinct a.forecastId) from trac_forecasts a

select * from trac_forecasts where forecastid in ('5971')
---------------------------------------------