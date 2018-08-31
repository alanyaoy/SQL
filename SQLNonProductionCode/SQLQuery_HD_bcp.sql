use JDE_DB_Alan
go

select @@version
-- To allow advanced options to be changed.
EXEC sp_configure 'show advanced options', 1
GO
-- To update the currently configured value for advanced options.
RECONFIGURE
GO
-- To enable the feature.
EXEC sp_configure 'xp_cmdshell', 1
GO
-- To update the currently configured value for this feature.
RECONFIGURE
GO

--select * from JDE_DB_Alan.MasterFamily
declare @bcp varchar(8000)
select @bcp = 'bcp "select * from [JDE_DB_Alan].[JDE_DB_Alan].[MasterFamily]" queryout C:\Users\yaoa\Alan_HD\Alan_Work\bcpp.txt -S RYDWS366\SQLEXPRESS -c -t, -T'
exec master..xp_cmdshell @bcp

declare @bcp varchar(8000)
select @bcp = 'bcp  JDE_DB_Alan.dbo.cj out C:\Users\yaoa\Alan_HD\Alan_Work\bcpp.txt -S RYDWS366\SQLEXPRESS -c -T -t,'
exec master..xp_cmdshell @bcp


EXEC master..xp_cmdshell 'DIR C:\Users\yaoa\Alan_HD\Alan_Work\bcpp.txt'

-------

EXEC xp_logininfo

SELECT  DSS.servicename,
        DSS.startup_type_desc,
        DSS.status_desc,
        DSS.last_startup_time,
        DSS.service_account,
        DSS.is_clustered,
        DSS.cluster_nodename,
        DSS.filename,
        DSS.startup_type,
        DSS.status,
        DSS.process_id
FROM    sys.dm_server_services AS DSS;


------

SET NOCOUNT ON
DECLARE @SQLService     VARCHAR(60)
DECLARE @AgentService     VARCHAR(60)
EXEC xp_regread @root_key     = 'HKEY_LOCAL_MACHINE',
         @key         = 'SYSTEM\ControlSet001\Services\MSSQLServer',
         @valuename     = 'ObjectName',
         @value      = @SQLService output

EXEC xp_regread @root_key     = 'HKEY_LOCAL_MACHINE',
      @key         = 'SYSTEM\ControlSet001\Services\SQLSERVERAGENT',
         @valuename     = 'ObjectName',
         @value      = @AgentService output
SELECT 
    @SQLService                             AS 'SQL Service Account',
     @AgentService                             AS 'SQL Agent Account',
    (SELECT TOP 1 phyname FROM master..sysdevices WHERE phyname LIKE '\\%') AS 'Backup Device'