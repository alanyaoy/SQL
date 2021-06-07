



CREATE PROCEDURE  [JDE_DB_Alan].[sp_FCPro_upd_HDWC]  
	-- Add the parameters for the stored procedure here
	--<@Param1, sysname, @p1> <Datatype_For_Param1, , int> = <Default_Value_For_Param1, , 0>, 
	--<@Param2, sysname, @p2> <Datatype_For_Param2, , int> = <Default_Value_For_Param2, , 0>

	-- This Store Procedure Refresh vw_NP_FC_Analysis  --- 12/3/2018 
	--- Is this Robust way to refresh View in SQL Server ? --- At least you need to implement Schemabinding in View !
AS

 BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	--SELECT <@Param1, sysname, @p1>, <@Param2, sysname, @p2>

	--select  cast(DATEADD(mm, DATEDIFF(mm, 0, GETDATE())-1, 0) as datetime)				--- Last Month


	--- Previously Alan want to create a view but it slows down query performance significantly so create a physical table here --> 'HD_WorkCenter' by using Staging table -> 'HD_WorkCenter_Staging ' ( Raw table )
	
	---Create view [JDE_DB_Alan].[vw_HD_WorkCenter] with schemabinding as
 
 --- 20/5/2021 ---
 --- Create a code to get distinct ItemNumber with WC name, note some Item might have multiple ( 2 or 3 work center associated with them ) so 
 --- need to get unique item number from 'Textile_Metal_WC' ( at the moment it is called 'Textile_WC'  table , otherwise you will have issue of geting duplicated records when you join 
 --- this table with Master_Planning table or ML_345 table or any other tables

 --- thinking of create another column to differentiate 'Textile' or 'Metal' column ?

    -- select * from JDE_DB_Alan.HD_WorkCenter a


	
	with t as 

	(
	select BU, ShortItemNumber,ItemNumber,WCCode_f,WCName_f,WCGroupCode_f,WCGroupName_f,WC_Count,getdate() as ReportDate
	from (
			select a1.ItemNumber,a1.ShortItemNumber
					 ,WCCode_f = STUFF
						(
						  (select '-' + cast (WorkCenterCode as varchar(100))
							   --  ,'-' + cast (WorkCenterGroup as varchar(100))
						   from JDE_DB_Alan.HD_WorkCenter_Staging a2
						   where a1.Itemnumber = a2.Itemnumber
						   for xml path('')
						   ),1,1,''
						 )
                     ,WCName_f = STUFF
						(
						  (select '/' + cast (WorkCenterName as varchar(100))
							   --  ,'-' + cast (WorkCenterGroup as varchar(100))
						   from JDE_DB_Alan.HD_WorkCenter_Staging a2
						   where a1.Itemnumber = a2.Itemnumber
						   for xml path('')
						   ),1,1,''
						 )
					 ,WCGroupCode_f = STUFF
						(
						  (select '-' + cast (WorkCenterGroupcode as varchar(100))
						   from JDE_DB_Alan.HD_WorkCenter_Staging a2
						   where a1.Itemnumber = a2.Itemnumber
						   for xml path('')
						   ),1,1,''
						 )
                     ,WCGroupName_f = STUFF
						(
						  (select '/' + cast (WorkCenterGroupName as varchar(100))
						   from JDE_DB_Alan.HD_WorkCenter_Staging a2
						   where a1.Itemnumber = a2.Itemnumber
						   for xml path('')
						   ),1,1,''
						 )
		
			  from JDE_DB_Alan.HD_WorkCenter_Staging a1	
			  --from ( select a.*,row_number() over(partition by workcentergroupcode order by workcentergroupcode desc ) rownumber from JDE_DB_Alan.HD_WorkCenter a ) a1		
			  group by a1.ItemNumber,a1.ShortItemNumber
				) a

        left join ( select a.BU,a.ItemNumber as Itm,a.ShortItemNumber as ShortItm,count(a.WorkCenterCode) as WC_Count from JDE_DB_Alan.HD_WorkCenter_Staging a
					   group by a.BU,a.ItemNumber,a.ShortItemNumber ) b
                  on a.ItemNumber = b.Itm
          
			 --where a.ItemNumber in ('82.028.901')

	 --order by WC_count desc
  

	   )

	insert into JDE_DB_Alan.HD_WorkCenter select * from t
	select * from JDE_DB_Alan.HD_WorkCenter a
	order by a.WorkCenterGroupCode_f,a.ItemNumber

    




 END
GO