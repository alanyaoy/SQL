use JDE_DB_Alan
go


-- Restore a Database from 2012 Express ( 11.xxx )  instance to 2016 ( 13.xxx ) work ... from lower to higher version works in Express -- how about from Higer to lower ( downgraded ?? )

--- 1/12/2018 --- works pay attention that directory might need to changed ---

-- Sounds like the backup was taken on a machine whose paths do not match yours. Try performing the backup using T-SQL instead of the UI. Also make sure that the paths you're specifying actually exist and that there isn't already a copy of these mdf/ldf files in there
--The backup stores the original location of the database files and, by default, attempts to restore to the same location. Since your new server installation is in new directories and, presumably, the old directories no longer exist, you need to alter the directories from the defaults to match the location you wish it to use.
--Depending on how you are restoring the database, the way to do this will differ. If you're using SSMS, look through the tabs and lists until you find the list of files and their associated disk locations - you can then edit those locations before restorin

restore database AlanDB
from disk='C:\Program Files\Microsoft SQL Server\MSSQL13.SQLEXPRESS\MSSQL\Backup\AlanDB.bak'
WITH MOVE 'AlanDB' TO 'C:\Program Files\Microsoft SQL Server\MSSQL13.SQLEXPRESS\MSSQL\DATA\AlanDB.mdf',
MOVE 'AlanDB_log' TO 'C:\Program Files\Microsoft SQL Server\MSSQL13.SQLEXPRESS\MSSQL\DATA\AlanDB.ldf';


RESTORE DATABASE MYDB_ABC FROM DISK = 'C:\path\file.bak'
WITH MOVE 'mydb' TO 'c:\valid_data_path\MYDB_ABC.mdf',
MOVE 'mydb_log' TO 'c:\valid_log_path\MYDB_ABC.ldf';