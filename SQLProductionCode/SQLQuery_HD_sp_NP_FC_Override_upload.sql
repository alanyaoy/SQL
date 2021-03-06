/*    ==Scripting Parameters==

    Source Server Version : SQL Server 2016 (13.0.4001)
    Source Database Engine Edition : Microsoft SQL Server Express Edition
    Source Database Engine Type : Standalone SQL Server

    Target Server Version : SQL Server 2017
    Target Database Engine Edition : Microsoft SQL Server Standard Edition
    Target Database Engine Type : Standalone SQL Server
*/

USE [JDE_DB_Alan]
GO
/****** Object:  StoredProcedure [JDE_DB_Alan].[sp_NP_FC_Override_upload]    Script Date: 11/09/2020 4:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [JDE_DB_Alan].[sp_NP_FC_Override_upload]
	-- Add the parameters for the stored procedure here
	--<@Param1, sysname, @p1> <Datatype_For_Param1, , int> = <Default_Value_For_Param1, , 0>, 
	--<@Param2, sysname, @p2> <Datatype_For_Param2, , int> = <Default_Value_For_Param2, , 0>
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	--SELECT <@Param1, sysname, @p1>, <@Param2, sysname, @p2>
		

   with cte as (
				select m.*
						,row_number() over(partition by m.itemNumber order by itemnumber ) as rn 
				from JDE_DB_Alan.Master_ML345 m )
	,cte_ as (
					select cte.*
					       ,case when cte.stockingType in ('O','U') then 'Y'  else 'N'  end as JdeValidStatus				--22/6/2018
				     from cte where rn =1 
					--order by m.ItemNumber
				 )
    --select c.ItemNumber,c.StockingType,c.myValidStatus  from cte_ c
	,ref_ as ( select *
						 ,row_number() over(partition by rf.itemNumber order by rf.Xref_Type) as rn 
				from JDE_DB_Alan.Master_Vendor_Item_CrossRef rf 
				--where rf.Address_Number in ('20037')		--please note there might be same item Number under multi suppliers!So need to filter here !
				 )
	,ref as ( select * from ref_ where rn=1)

	--,_npf as ( select f.*,min(f.date) over(partition by f.itemnumber order by f.date asc) as BirthMth 
	--           -- select distinct f.ItemNumber,min(f.date) over(partition by f.itemnumber order by f.date asc) as BirthMth 
	--			 from JDE_DB_Alan.FCPRO_NP_tmp f 
	--			 where f.Value >0 
	--			 )
    -- select * from _npf  where _npf.ItemNumber in ( '82.604.904')


	 --- To Get your distinct item with Birth and Mature Date ---
	,_npf as ( select f.*
				,min(f.date) over(partition by f.itemnumber order by f.date asc) as BirthMth 
				,dateadd(m,11,min(f.date) over(partition by f.itemnumber order by f.date asc) ) as MatureMth
				,count(f.Date)over( partition by f.ItemNumber) as Life_Span			--  could be greater than 12 if there is an error
			 from JDE_DB_Alan.FCPRO_NP_tmp f 
			  where f.Value >0 								-- pick up value greater than 0, it will exclude 0 either inside or outside 12 months life span  --- 18/6/2018		
															-- idealy you should have non 0 values with 12 months life span ! --- 18/6/2018  
                    and f.ValidStatus in ('Y')			--19/2/2019																	        
				 )

	  ,npf_ as ( select distinct f.ItemNumber as Itm,f.BirthMth,f.MatureMth,f.Life_Span from _npf f )

	-- select * from npf_
	--select * from _npf where _npf.ItemNumber in ( 'xuec849')
	--select * from _npf where _npf.ItemNumber in ( '82.604.904')
	--select * from _npf where _npf.ItemNumber in ( 'KIT9126')
	--select * from _npf where _npf.ItemNumber in ( '31121587')

	 --- Capped FC to 12 months after birth to Mature Period  ---
	,npf as ( select *
	                ,count(f.Date)over( partition by f.ItemNumber) as Life_Span_Left_False
					,datediff(m,DATEADD(mm, DATEDIFF(m,0,GETDATE()),0),ff.MatureMth) +1 as Life_Span_Left_True				-- include current month so plus 1
	            from JDE_DB_Alan.FCPRO_NP_tmp f left join npf_ ff on f.ItemNumber = ff.Itm
				where f.date <= ff.MatureMth					--- capped to 12 months after birth to Amature Period	
					 and f.ValidStatus in ('Y')					--- need to apply 'Y' again as you are using Original table 'FCPRO_NP_tmp' again   --- 19/2/2019
							     
				)

   --select * from npf where npf.ItemNumber in ( '1003020')

   --- Start FC from Current Month to Mature Period  ---
	,npfc as ( select f.*
		 --,f.Date as Date_
					 ,convert(varchar(21),f.Date,103) as SimpDate
						 ,convert(varchar(4),f.date, 111) +'-'+ left (datename(mm,DATEADD(dd, DATEDIFF(d,0,f.Date)+1,0)),3) as WrongDate			-- wrong date as it will not advance year digit
						 ,convert(varchar(10),DATEADD(dd, DATEDIFF(d,0,f.Date)+1,0),120) as Right_Date
						 ,left(datename(mm,DATEADD(dd, DATEDIFF(d,0,f.Date)+1,0)),3) as Right_MthName
						 ,left(convert(varchar(10),DATEADD(dd, DATEDIFF(d,0,f.Date)+1,0),120),4) +'-'+ left(datename(mm,DATEADD(dd, DATEDIFF(d,0,f.Date)+1,0)),3) as Date_pro
						 ,convert(varchar(10),DATEADD(dd, DATEDIFF(d,0,f.Date)+1,0),120) as Date_
						 ,cast(DATEADD(mm, DATEDIFF(m,0,GETDATE()),0) as datetime) as startdte
						 ,cast(DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,GETDATE()),0)) as datetime) as _startdate			-- Set the StartDate for changing from Jun/2018 onwards
						 ,cast(DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,GETDATE())+5,0)) as datetime) as startdate_
						,'2018-02-01' as startdate1			-- Set the StartDate for changing from Jun/2018 onwards
						,'2018-06-01' as startdate2
						,count(f.Date)over( partition by f.ItemNumber) as Mth_Count
				 from npf f
				 where   
						f.ValidStatus = 'Y'				-- by valid status		, be careful if you want to join 'FCPRO_MI_tmp' table with other table you need to first filter out by status then join, NOT put condition straightaway when join (in same select statement),otherwise you will lose data in null value -- see 'sp_funct2Jde_ZeroOut'  ---8/6/2018
					  -- and 	f.Value >0			--- Need to pick up FC Value from launch date,different SKU has different start date and we do not want to pick all the month ( ignore leading 0 ) -- 14/2/2018
				       and f.Date > DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0)	-- Need to pick up data which is greater than current month in & onwards, albeit FC Pro when loading data it will cut off any data older than current month but it is better to do it here to ensure right data is loaded in - 28/2/2018 -- note cut off only apply to history not to FC, so need to pick up FC from current month onwards otherwise you will lost one month FC - 12/3/2018
					   					   
					 )
    --  select * from npfc where npfc.ItemNumber in ('1003020')
	-- select * from _npfc where _npfc.ItemNumber in ('82.604.904')
	 ,_npfc as (																										-- this is Monthly SKU level data
 					select 'Total' as RowLabel
					     ,npfc.BirthMth
						 ,npfc.MatureMth
						 ,npfc.Mth_Count
						 ,cte_.SellingGroup
						,cte_.FamilyGroup
						,cte_.Family
						 ,npfc.ItemNumber
						 ,npfc.Date_ 
						 ,npfc.Date_pro
						 --,'Override 1' as Row
						 ,'New Product' as Row
						 ,isnull(npfc.Value,0) as Baseline
						 ,isnull(npfc.Value,0)as Formula
						,isnull(npfc.Value,0) as Override
						,npfc.Comment
						 ,npfc.LastUpdated
						 ,cte_.Description					 
					from npfc	 -- left join ref on fc.ItemNumber = ref.ItemNumber		--please note there might be same item Number under multi suppliers !
							 left join cte_ on npfc.ItemNumber = cte_.ItemNumber				 
					 where cte_.StockingType not in ('O','U')						--- 21/6/2018 Once times progress, you need to filter out 'Old' Items
					 --where ref.Address_Number in ('20037')
							--and fc.ItemNumber in ('27.176.320')						
					) 
		--select * from npfc_ where npfc_.ItemNumber in ('82.604.904') order by npfc_.ItemNumber,npfc_.Date_

	  --- Get rid of Months with 0 FC value ( only if there are at back end - not within ) ---
       ,_stg as ( select f.*,row_number() over ( partition by f.ItemNumber order by f.date_ desc) as rnk
		           from _npfc f ) 
       ,stg_ as ( select y.*,sum(y.override) over (partition by y.ItemNumber order by y.rnk ) as RunningTTL from _stg as y )
	   ,stgg as ( select * from stg_ y where y.RunningTTL <> 0)

	   --select * from stgg where stgg.ItemNumber in ('26.526.030')

	     --- Get rid of Months with 0 FC value on Reserver order --- this is genius idea created by Alan 26/7/2018 ! ( only if there are at front end - not within ) ---
       ,_stgg as ( select f.*,row_number() over ( partition by f.ItemNumber order by f.date_ asc) as rnkk
		           from stgg f ) 
       ,stgg_ as ( select y.*,sum(y.override) over (partition by y.ItemNumber order by y.rnkk ) as RunningTTLL from _stgg as y )
	   ,stggg as ( select * from stgg_ y where y.RunningTTLL <> 0)

		,stg as 
				(select stggg.*
						,c.LongDescription as SellingGroup_
						,d.LongDescription as FamilyGroup_
						,e.LongDescription as Family_0
						--,tbl.Family as Family_1
						--,f.StandardCost,f.WholeSalePrice
						,p.Pareto
				from stggg left join JDE_DB_Alan.MasterSellingGroup c on stggg.SellingGroup = c.Code
						 left join JDE_DB_Alan.MasterFamilyGroup d on stggg.FamilyGroup = d.Code
						 left join JDE_DB_Alan.MasterFamily e on stggg.Family = e.Code
						 left join JDE_DB_Alan.FCPRO_Fcst_Pareto p on stggg.ItemNumber = p.ItemNumber
				 )

	  ,npfc_ as ( select stg.RowLabel,SellingGroup_ as SellingGroup,stg.FamilyGroup_ as FamilyGroup,stg.Family_0 as Family,stg.ItemNumber
						 ,stg.Date_pro as date											--- for FC Pro Date Format 		 
						 ,stg.Row			
						 ,stg.Baseline,stg.Formula,stg.Override,stg.Comment
						 --,stg.LastUpdated	
						 ,convert(varchar(21),stg.LastUpdated,103) as LastUpdated_					--- for FC Pro Date Format
						 ,stg.Pareto
					from stg )

     --  select * from npfc_ p where p.ItemNumber in ('1003020')
	--------- Execute elow to Output Format for Overrideing for Uploading into FC Pro ---------
	select * 																					
	from npfc_
   	--where 
				--fc_.date is not null 
				--and fc_.ItemNumber in ('27.160.320','2770002534')
				-- and fc_.ItemNumber in ('27.160.785')
				--npfc_.ItemNumber in ('2801381661','2801381810')
	            --npfc.ItemNumber in ('UCLC118')  and

				---================================== ---
				--- D you really need below condition ? -- removed 6/2/2019 -- becasue we could hv situation where phase in/out has, say you are currently in Feb 19, stk for outgoing SKU last up to June, and new SKU need to be launched in May 19. But if you capped forecast for next 12 mth period ( Feb 19 - Jan 20), you willl end up cut off forecast from Jan 20 onwards.
				---================================== ---
	           -- npfc_.date between DATEADD(mm, DATEDIFF(m,0,GETDATE()),0) and DATEADD(mm, DATEDIFF(m,0,GETDATE())+11,0)		-- filter out any data which is outside future 12 month time bucket either month before or after (month +12 )   -10/5/2018
																															-- Need to consider to use parameters rather than use function - if data is big then you will have performance issue - 10/5/2018
	           
			--   and npfc.Override >0			   --- need to filter out < 0 value if you make by mistake put 0 either within 12 month period or When Month moves to next period ...there will be trailing 0 at end to patch up ... 15/6/2018   
													-- idealy you should have non 0 values with 12 months life span ! --- 18/6/2018  
		   -- and npfc.Override =0
			 --and npfc_.ItemNumber in ('82.604.904') 
			--  and npfc_.ItemNumber in ('31121587') 
			--and npfc_.ItemNumber in ('XUEC849')
			-- npfc_.ItemNumber in ('34.731.001')

	order by npfc_.ItemNumber
			 ,left(npfc_.date,4) 
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

END


