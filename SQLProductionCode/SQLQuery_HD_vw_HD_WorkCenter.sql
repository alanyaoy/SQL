/*    ==Scripting Parameters==

    Source Server Version : SQL Server 2016 (13.0.4001)
    Source Database Engine Edition : Microsoft SQL Server Express Edition
    Source Database Engine Type : Standalone SQL Server

    Target Server Version : SQL Server 2016
    Target Database Engine Edition : Microsoft SQL Server Express Edition
    Target Database Engine Type : Standalone SQL Server
*/

USE [JDE_DB_Alan]
GO

/****** Object:  View [JDE_DB_Alan].[vw_HD_WorkCenter]    Script Date: 24/05/2021 12:59:22 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER view [JDE_DB_Alan].[vw_HD_WorkCenter] with schemabinding as
 
 --- 20/5/2021 ---
 --- Create a code to get distinct ItemNumber with WC name, note some Item might have multiple ( 2 or 3 work center associated with them ) so 
 --- need to get unique item number from 'Textile_Metal_WC' ( at the moment it is called 'Textile_WC'  table , otherwise you will have issue of geting duplicated records when you join 
 --- this table with Master_Planning table or ML_345 table or any other tables

 --- thinking of create another column to differentiate 'Textile' or 'Metal' column ?

    -- select * from JDE_DB_Alan.HD_WorkCenter a

	
			select a1.ItemNumber,a1.ShortItemNumber
					 ,WCCode_f = STUFF
						(
						  (select '-' + cast (WorkCenterCode as varchar(100))
							   --  ,'-' + cast (WorkCenterGroup as varchar(100))
						   from JDE_DB_Alan.HD_WorkCenter a2
						   where a1.Itemnumber = a2.Itemnumber
						   for xml path('')
						   ),1,1,''
						 )
                     ,WCName_f = STUFF
						(
						  (select '/' + cast (WorkCenterName as varchar(100))
							   --  ,'-' + cast (WorkCenterGroup as varchar(100))
						   from JDE_DB_Alan.HD_WorkCenter a2
						   where a1.Itemnumber = a2.Itemnumber
						   for xml path('')
						   ),1,1,''
						 )
					 ,WCGroupCode_f = STUFF
						(
						  (select '-' + cast (WorkCenterGroupcode as varchar(100))
						   from JDE_DB_Alan.HD_WorkCenter a2
						   where a1.Itemnumber = a2.Itemnumber
						   for xml path('')
						   ),1,1,''
						 )
                     ,WCGroupName_f = STUFF
						(
						  (select '/' + cast (WorkCenterGroupName as varchar(100))
						   from JDE_DB_Alan.HD_WorkCenter a2
						   where a1.Itemnumber = a2.Itemnumber
						   for xml path('')
						   ),1,1,''
						 )
		
			  from JDE_DB_Alan.HD_WorkCenter a1	


    
	 --where a.ItemNumber in ('82.028.901')

	 --order by WC_count desc


GO


