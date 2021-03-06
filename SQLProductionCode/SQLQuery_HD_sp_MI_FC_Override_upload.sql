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
/****** Object:  StoredProcedure [JDE_DB_Alan].[sp_MI_FC_Override_upload]    Script Date: 29/04/2021 2:53:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [JDE_DB_Alan].[sp_MI_FC_Override_upload]
	-- Add the parameters for the stored procedure here
	--<@Param1, sysname, @p1> <Datatype_For_Param1, , int> = <Default_Value_For_Param1, , 0>, 
	--<@Param2, sysname, @p2> <Datatype_For_Param2, , int> = <Default_Value_For_Param2, , 0>


	 -- @start_mth datetime DATEADD(mm, DATEDIFF(m,0,GETDATE()),0)
	 --,@end_mth  datetime DATEADD(mm, DATEDIFF(m,0,GETDATE()),0)
	    @FCCheck_id varchar(10) = null

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	--SELECT <@Param1, sysname, @p1>, <@Param2, sysname, @p2>
		

		 ---------------------------------------------------------------

		 --- Revised on 29/1/2020 -----

		 --- Updated on 14/2/2020 ---
		 --- Updated logic for Both 'Mi_1' and 'Mi_2' on how to calculate Mature month correctly, if use standard 12 month window for Mi_1 or Mi_2 , it can cause issue. Like 82.696.901, Mi_1 only has 7 month from 1/Apr/2019 t0 1/Oct/2019, but using 12 month mature time, it will extend to Feb/2020 which will cause issue,and because it is fc result from 1st step of whole FC process, then it will complicate issue when you run 2nd step to include Mi_2 !! 
		 --- be careful ! ---

		 -- 7/4/2021 ---
		 -- Note the difference between 'MI_1' section and 'MI_2' section of the coding is that you will need to fetch data from different MI Sql table !
		 ---------------------------------------------------------------
 --select * 
 --from JDE_DB_Alan.FCPRO_MI_tmp mi 
 --where mi.ItemNumber in ('2780301000')
 --order by mi.Date,mi.Comment

   if @FCCheck_id = 'MI_1'

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


			--,_mif as ( select f.*,min(f.date) over(partition by f.itemnumber order by f.date asc) as BirthMth 
					   -- select distinct f.ItemNumber,min(f.date) over(partition by f.itemnumber order by f.date asc) as BirthMth 
					--	 from JDE_DB_Alan.FCPRO_MI_tmp f 
					--	 where f.Value >0 
					--	 )
			 --select * from _mif  where _mif.ItemNumber in ( '27.170.450')

			  --- To Get your distinct item with Birth and Mature Date,choose item has at least one month value greater than 0 ---
			,_mif as ( select f.*
						,min(f.date) over(partition by f.itemnumber order by f.date asc) as BirthMth 
						,dateadd(m,11,min(f.date) over(partition by f.itemnumber order by f.date asc) ) as MatureMth_12			-- this is for standard 12 month Mature time but in real life situation, it could be less than 12 month and if so can cause problem for calculation --- 14/2/2020
						,count(f.Date)over( partition by f.ItemNumber) as Life_Span			--  could be greater than 12 if there is an error
						,dateadd(m,count(f.Date)over( partition by f.ItemNumber)-1,min(f.date) over(partition by f.itemnumber order by f.date asc) ) as MatureMth    --- using 'Life_Span' count; this is true mature month ! 14/2/2020
					
					-- from JDE_DB_Alan.FCPRO_MI_2_tmp f				--- updated		11/2/2020, it is for Mi_1 not Mi_2 !!!
					 from JDE_DB_Alan.FCPRO_MI_tmp f 
					 
					 --where f.Value >0 								-- pick up value greater than 0, it will exclude 0 either inside or outside 12 months life span  --- 18/6/2018		
																	-- idealy you should have non 0 values with 12 months life span ! --- 18/6/2018  
																	
																	-- You can delay below step to last stages of this Store Procedure  --- 29/1/2020 
																	---Need to pick up final combined FC ( Stat + Mi2 ) greater than 0 otherwise you will have negative fc eventually uploaded into JDE  --- 29/1/2020
																	-- Note that this is different filter ( >0 ) compared in First step ( VBA 4-4-1 ) to load negative Mi2 when combining Stat FC ( it is OK to allow negative mi2 ) --- 29/1/2020

					 where	f.Value <> 0				-- There could be negative value or Zero value ( discontinued item ?? --> using MI to remove fc ? ) --- 28/1/2020	
							                            -- note that 'Mi-2' table already consider reducing records to 12 months 	 										
					      
						   and f.ValidStatus in ('Y')	--- 28/4/2021											   
						
						  --and f.ItemNumber in ('24.7221.0952')	
						  --and f.ItemNumber in ('24.7219.4460')											   
						 )
			-- select * from _mif where _mif.ItemNumber in ('24.7221.0952')         --- 29/1/2020
			-- select * from _mif where _mif.ItemNumber in ('24.7219.4460')         --- 29/1/2020


			   --- Get A list from above table,then using it as Master SKU list for 'Join' ---
   			,mif_ as ( select distinct f.ItemNumber as Itm,f.BirthMth,f.MatureMth,f.Life_Span from _mif f )
			--select * from mif_
			--select * from _mif where _mif.ItemNumber in ( '27.17.450')

			  --- Capped FC to 12 months after birth to Mature Period  ---      this is culprit which cause back flow of negative value --- 29/1/2020
			,mif as ( select *
							,count(f.Date)over( partition by f.ItemNumber) as Life_Span_Left_False
							,datediff(m,DATEADD(mm, DATEDIFF(m,0,GETDATE()),0),ff.MatureMth) +1 as Life_Span_Left_True				-- include current month so plus 1
						--from JDE_DB_Alan.FCPRO_MI_2_tmp f left join mif_ ff on f.ItemNumber = ff.Itm			-- old , it is for Mi_1, not Mi_2 !!!
						  from JDE_DB_Alan.FCPRO_MI_tmp f left join mif_ ff on f.ItemNumber = ff.Itm          --- Updated 14/2/2020    
						where f.date <= ff.MatureMth								  	
						)

		 -- select * from mif where mif.ItemNumber in ( '24.7219.4460')                          
		  -- select * from mif where mif.ItemNumber in ( '24.7221.0952')
		   -- select * from mif where mif.ItemNumber in ('18.010.035','F16174A948') 

			--- Start FC from Current Month to Mature Period  ---
			,mifc as ( select f.*
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
						 from mif f				
						  where f.ValidStatus = 'Y'				-- Filter out by Valid status --- 31/5/2018, be careful if you want to join 'FCPRO_MI_tmp' table with other table you need to first filter out by status then join, NOT put condition straightaway when join (in same select statement),otherwise you will lose data in null value -- see 'sp_funct2Jde_ZeroOut'  ---8/6/2018
								--and f.Value >0			--- NO Need for MI , (Need to pick up FC Value from launch date,different SKU has different start date and we do not want to pick all the month ( ignore leading 0 ) -- 14/2/2018 )
								-- and f.Date > DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0)	-- Need to pick up data which is greater than current month in & onwards, albeit FC Pro when loading data it will cut off any data older than current month but it is better to do it here to ensure right data is loaded in - 28/2/2018 -- note cut off only apply to history not to FC, so need to pick up FC from current month onwards otherwise you will lost one month FC - 12/3/2018
					 
							 )

		   -- select * from mifc where mifc.ItemNumber in ('24.7221.0952')				--- 29/1/2020
			-- select * from mifc where mifc.ItemNumber in ('24.7219.4460')				--- 29/1/2020
			 -- select * from mifc where mifc.ItemNumber in ('2780461878')
			--select * from fc where fc.ItemNumber in ('2801381661','34.523.000,')
			,_mifc as (																										-- this is Monthly SKU level data
							select 'Total' as RowLabel
								 ,mifc.BirthMth
								 ,mifc.MatureMth
								 ,mifc.Mth_Count
								 ,cte_.SellingGroup
								,cte_.FamilyGroup
								,cte_.Family
								 ,mifc.ItemNumber
								 ,mifc.Date_ 
								 ,mifc.Date_pro
								 --,'Override 1' as Row
								 ,'Market_Intelligence_1' as Row
								 ,isnull(mifc.Value,0) as Baseline
								 ,isnull(mifc.Value,0)as Formula
								,isnull(mifc.Value,0) as Override
								,mifc.Comment
								 ,mifc.LastUpdated
								 ,cte_.Description	
								 ,cte_.StockingType	
						 			 
							from mifc	 -- left join ref on fc.ItemNumber = ref.ItemNumber		--please note there might be same item Number under multi suppliers !
									 left join cte_ on mifc.ItemNumber = cte_.ItemNumber				 
							--where cte_.StockingType not in ('O','U')						-- need to remove out discontinued SKU, that means you can have outdated items in Excel spreadsheet as data source but need to filter out active items before populate data into 'MI' table. 10/5/2018
							 
							 --where ref.Address_Number in ('20037')						-- also need to consider to use (not)/exists instead of (not)/in  because of null ( see some of articale about using 'exist/in/except'   - 10/5/2018
									--and fc.ItemNumber in ('27.176.320')						
							 
							 --  where m.StockingType in ('O','K','W','X','S','F','P','U','Q','Z','C','M','0','I')			-- this could be best to avoid issue of returning empty dataSet due to Null value --- 23/7/2018		
							     where cte_.StockingType in ('K','W','X','S','F','P','Q','Z','C','M','0','I') or cte_.StockingType is null

							) 

                   --  select * from _mifc where _mifc.ItemNumber in ('24.7219.4460')        ---29/1/2020

                   ---======================================================================================---    
				   --- Get rid of Months with 0 FC value ( only if there are at back end of 12 mths Window Line - not within/in the middle of it ) ---
				   ---======================================================================================---
				,_stg as ( select f.*,row_number() over ( partition by f.ItemNumber order by f.date_ desc) as rnk
						   from _mifc f ) 
			   ,stg_ as ( select y.*,sum(y.override) over (partition by y.ItemNumber order by y.rnk ) as RunningTTL from _stg as y )
			   ,stgg as ( select * from stg_ y where y.RunningTTL <> 0)
			  --select * from stgg where stgg.ItemNumber in ('34.524.000','18.010.035','F16174A948')

			    ---======================================================================================---
	  			--- Get rid of Months with 0 FC value on Reserver order --- this is genius idea created by Alan 26/7/2018 ! ( only if there are at front end of 12 mths Window Line - not within/In the middle of it ) ---
				---======================================================================================---
				,_stgg as ( select f.*,row_number() over ( partition by f.ItemNumber order by f.date_ asc) as rnkk
						   from stgg f ) 
			   ,stgg_ as ( select y.*,sum(y.override) over (partition by y.ItemNumber order by y.rnkk ) as RunningTTLL from _stgg as y )
			   ,stggg as ( select * from stgg_ y where y.RunningTTLL <> 0)

			   --select * from stggg where stggg.ItemNumber in ('34.524.000','18.010.035','F16174A948')
				
				---========================---
				--- Final Touch using stg ---
				---========================---
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

				,mifc_ as ( select stg.RowLabel,SellingGroup_ as SellingGroup,stg.FamilyGroup_ as FamilyGroup,stg.Family_0 as Family,stg.ItemNumber
									 ,stg.Date_pro as date											--- for FC Pro Date Format 		 
									 ,stg.Row			
									 ,stg.Baseline
									 ,stg.Formula
									-- ,stg.Override
									 ,(case 
									      when stg.Override < 0 then 0
										  when stg.Override > 0 then stg.Override
                                       end ) as Override_f
									 ,stg.Comment
									 --,stg.LastUpdated	
									 ,convert(varchar(21),stg.LastUpdated,103) as LastUpdated_					--- for FC Pro Date Format
									 ,stg.Pareto
									 ,stg.Override as Override_Orig
								from stg )

			--------- Execute elow to Output Format for Overrideing for Uploading into FC Pro ---------
			select * 																					
			from mifc_ 
    			where 
						--fc_.date is not null 
						--and fc_.ItemNumber in ('27.160.320','2770002534')
						-- and fc_.ItemNumber in ('27.160.785')
						--npfc_.ItemNumber in ('2801381661','2801381810')
						-- mifc_.ItemNumber in ('27.170.180')
						-- mifc_.ItemNumber in ('27.161.320') and					-- good example that a SKU has 0 value within 12 month time bucket   - 10/5/2018
						mifc_.date between DATEADD(mm, DATEDIFF(m,0,GETDATE()),0) and DATEADD(mm, DATEDIFF(m,0,GETDATE())+11,0)		-- filter out any data which is outside future 12 month time bucket either month before or after (month +12 )   -10/5/2018
																																	-- Need to consider to use parameters rather than use function - if data is big then you will have performance issue - 10/5/2018
						--and mifc_.Override >0					-- 26/7/2018 NO Need if you did Reservers Running Total to get rid of 0 --25/7/2018		--- need to filter out < 0 value if you make by mistake put 0 either within 12 month period or When Month moves to next period ...there will be trailing 0 at end to patch up ... 15/6/2018
																	-- idealy you should have non 0 values with 12 months life span ! --- 18/6/2018        
						 --and mifc_.Override =0
						 --and mifc_.ItemNumber in ('1081401') 
						--and mifc_.ItemNumber in ( '24.7219.4460')
						
						--and mifc_.ItemNumber in ( '24.7221.0952','24.7219.4460')
						

						--  and mifc_.ItemNumber in ( '34.524.000')
						--and mifc_.ItemNumber in ( '18.010.035')
						--  and mifc_.ItemNumber in ('34.524.000','18.010.035','F16174A948')
			order by mifc_.ItemNumber																								
					 ,left(mifc_.date,4) 
					 ,case right(mifc_.Date,3)	 when 'Jan' then 1
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
				 
						END			-- 'END' for Case statement


     else if @FCCheck_id = 'MI_2'
	    begin

		    ;with cte as (
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


			--,_mif as ( select f.*,min(f.date) over(partition by f.itemnumber order by f.date asc) as BirthMth 
					   -- select distinct f.ItemNumber,min(f.date) over(partition by f.itemnumber order by f.date asc) as BirthMth 
					--	 from JDE_DB_Alan.FCPRO_MI_tmp f 
					--	 where f.Value >0 
					--	 )
			 --select * from _mif  where _mif.ItemNumber in ( '27.170.450')

			  --- To Get your distinct item with Birth and Mature Date,choose item has at least one month value greater than 0 ---
			,_mif as ( select f.*
						,min(f.date) over(partition by f.itemnumber order by f.date asc) as BirthMth 
						,dateadd(m,11,min(f.date) over(partition by f.itemnumber order by f.date asc) ) as MatureMth_12			-- this is for standard 12 month Mature time but in real life situation, it could be less than 12 month and if so can cause problem for calculation --- 14/2/2020
						,count(f.Date)over( partition by f.ItemNumber) as Life_Span			--  could be greater than 12 if there is an error
					    ,dateadd(m,count(f.Date)over( partition by f.ItemNumber)-1,min(f.date) over(partition by f.itemnumber order by f.date asc) ) as MatureMth   --- using 'Life_Span' count;this is true mature month ! 14/2/2020

					 from JDE_DB_Alan.FCPRO_MI_2_tmp f 
					-- from JDE_DB_Alan.FCPRO_MI_tmp f					--- this is for Mi_1

					 --where f.Value >0 								-- pick up value greater than 0, it will exclude 0 either inside or outside 12 months life span  --- 18/6/2018		
																	-- idealy you should have non 0 values with 12 months life span ! --- 18/6/2018  
																	
																	-- You can delay below step to last stages of this Store Procedure  --- 29/1/2020 
																	---Need to pick up final combined FC ( Stat + Mi2 ) greater than 0 otherwise you will have negative fc eventually uploaded into JDE  --- 29/1/2020
																	-- Note that this is different filter ( >0 ) compared in First step ( VBA 4-4-1 ) to load negative Mi2 when combining Stat FC ( it is OK to allow negative mi2 ) --- 29/1/2020

					 where	f.Value <> 0				-- There could be negative value or Zero value ( discontinued item ?? --> using MI to remove fc ? ) --- 28/1/2020	
							                            -- note that 'Mi-2' table already consider reducing records to 12 months 	 										
																	   
						    and f.ValidStatus in ('Y')	--- 28/4/2021	

						  --and f.ItemNumber in ('24.7221.0952')	
						  --and f.ItemNumber in ('24.7219.4460')											   
						 )
			-- select * from _mif where _mif.ItemNumber in ('24.7221.0952')         --- 29/1/2020
			-- select * from _mif where _mif.ItemNumber in ('24.7219.4460')         --- 29/1/2020


			   --- Get A list from above table,then using it as Master SKU list for 'Join' ---
   			,mif_ as ( select distinct f.ItemNumber as Itm,f.BirthMth,f.MatureMth,f.Life_Span from _mif f )
			--select * from mif_
			--select * from _mif where _mif.ItemNumber in ( '27.17.450')

			  --- Capped FC to 12 months after birth to Mature Period  ---      this is culprit which cause back flow of negative value --- 29/1/2020
			,mif as ( select *
							,count(f.Date)over( partition by f.ItemNumber) as Life_Span_Left_False
							,datediff(m,DATEADD(mm, DATEDIFF(m,0,GETDATE()),0),ff.MatureMth) +1 as Life_Span_Left_True				-- include current month so plus 1
						from JDE_DB_Alan.FCPRO_MI_2_tmp f left join mif_ ff on f.ItemNumber = ff.Itm
						---from JDE_DB_Alan.FCPRO_MI_tmp f left join mif_ ff on f.ItemNumber = ff.Itm					--- this is for Mi_1 !
						where f.date <= ff.MatureMth		
										--and f.Date >=  DATEADD(mm, DATEDIFF(m,0,GETDATE()),0)				--- 29/4/2021, No need to add, because Mi_2 tmp data already done that						  	
						)

		 -- select * from mif where mif.ItemNumber in ( '24.7219.4460')                          
		  -- select * from mif where mif.ItemNumber in ( '24.7221.0952')
		   -- select * from mif where mif.ItemNumber in ('18.010.035','F16174A948') 

			--- Start FC from Current Month to Mature Period  ---
			,mifc as ( select f.*
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
						 from mif f				
						  where f.ValidStatus = 'Y'				-- Filter out by Valid status --- 31/5/2018, be careful if you want to join 'FCPRO_MI_tmp' table with other table you need to first filter out by status then join, NOT put condition straightaway when join (in same select statement),otherwise you will lose data in null value -- see 'sp_funct2Jde_ZeroOut'  ---8/6/2018
								--and f.Value >0			--- NO Need for MI , (Need to pick up FC Value from launch date,different SKU has different start date and we do not want to pick all the month ( ignore leading 0 ) -- 14/2/2018 )
								-- and f.Date > DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0)	-- Need to pick up data which is greater than current month in & onwards, albeit FC Pro when loading data it will cut off any data older than current month but it is better to do it here to ensure right data is loaded in - 28/2/2018 -- note cut off only apply to history not to FC, so need to pick up FC from current month onwards otherwise you will lost one month FC - 12/3/2018
					 
							 )

		   -- select * from mifc where mifc.ItemNumber in ('24.7221.0952')				--- 29/1/2020
			-- select * from mifc where mifc.ItemNumber in ('24.7219.4460')				--- 29/1/2020
			 -- select * from mifc where mifc.ItemNumber in ('2780461878')
			--select * from fc where fc.ItemNumber in ('2801381661','34.523.000,')
			,_mifc as (																										-- this is Monthly SKU level data
							select 'Total' as RowLabel
								 ,mifc.BirthMth
								 ,mifc.MatureMth
								 ,mifc.Mth_Count
								 ,cte_.SellingGroup
								,cte_.FamilyGroup
								,cte_.Family
								 ,mifc.ItemNumber
								 ,mifc.Date_ 
								 ,mifc.Date_pro
								 --,'Override 1' as Row
								 ,'Market_Intelligence_2' as Row
								 ,isnull(mifc.Value,0) as Baseline
								 ,isnull(mifc.Value,0)as Formula
								,isnull(mifc.Value,0) as Override
								,mifc.Comment
								 ,mifc.LastUpdated
								 ,cte_.Description	
								 ,cte_.StockingType	
						 			 
							from mifc	 -- left join ref on fc.ItemNumber = ref.ItemNumber		--please note there might be same item Number under multi suppliers !
									 left join cte_ on mifc.ItemNumber = cte_.ItemNumber				 
							--where cte_.StockingType not in ('O','U')						-- need to remove out discontinued SKU, that means you can have outdated items in Excel spreadsheet as data source but need to filter out active items before populate data into 'MI' table. 10/5/2018
							 
							 --where ref.Address_Number in ('20037')						-- also need to consider to use (not)/exists instead of (not)/in  because of null ( see some of articale about using 'exist/in/except'   - 10/5/2018
									--and fc.ItemNumber in ('27.176.320')						
							 
							 --  where m.StockingType in ('O','K','W','X','S','F','P','U','Q','Z','C','M','0','I')			-- this could be best to avoid issue of returning empty dataSet due to Null value --- 23/7/2018		
							     where cte_.StockingType in ('K','W','X','S','F','P','Q','Z','C','M','0','I') or cte_.StockingType is null

							) 

                   --  select * from _mifc where _mifc.ItemNumber in ('24.7219.4460')        ---29/1/2020

                   ---======================================================================================---    
				   --- Get rid of Months with 0 FC value ( only if there are at back end of 12 mths Window Line - not within/in the middle of it ) ---
				   ---======================================================================================---
				,_stg as ( select f.*,row_number() over ( partition by f.ItemNumber order by f.date_ desc) as rnk
						   from _mifc f ) 
			   ,stg_ as ( select y.*,sum(y.override) over (partition by y.ItemNumber order by y.rnk ) as RunningTTL from _stg as y )
			   ,stgg as ( select * from stg_ y where y.RunningTTL <> 0)
			  --select * from stgg where stgg.ItemNumber in ('34.524.000','18.010.035','F16174A948')

			    ---======================================================================================---
	  			--- Get rid of Months with 0 FC value on Reserver order --- this is genius idea created by Alan 26/7/2018 ! ( only if there are at front end of 12 mths Window Line - not within/In the middle of it ) ---
				---======================================================================================---
				,_stgg as ( select f.*,row_number() over ( partition by f.ItemNumber order by f.date_ asc) as rnkk
						   from stgg f ) 
			   ,stgg_ as ( select y.*,sum(y.override) over (partition by y.ItemNumber order by y.rnkk ) as RunningTTLL from _stgg as y )
			   ,stggg as ( select * from stgg_ y where y.RunningTTLL <> 0)

			   --select * from stggg where stggg.ItemNumber in ('34.524.000','18.010.035','F16174A948')
				
				---========================---
				--- Final Touch using stg ---
				---========================---
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

				,mifc_ as ( select stg.RowLabel,SellingGroup_ as SellingGroup,stg.FamilyGroup_ as FamilyGroup,stg.Family_0 as Family,stg.ItemNumber
									 ,stg.Date_pro as date											--- for FC Pro Date Format 		 
									 ,stg.Row			
									 ,stg.Baseline
									 ,stg.Formula
									-- ,stg.Override
									 ,(case 
									      when stg.Override < 0 then 0
										  when stg.Override > 0 then stg.Override
                                       end ) as Override_f
									 ,stg.Comment
									 --,stg.LastUpdated	
									 ,convert(varchar(21),stg.LastUpdated,103) as LastUpdated_					--- for FC Pro Date Format
									 ,stg.Pareto
									 ,stg.Override as Override_Orig
								from stg )

			--------- Execute elow to Output Format for Overrideing for Uploading into FC Pro ---------
			select * 																					
			from mifc_ 
    			where 
						--fc_.date is not null 
						--and fc_.ItemNumber in ('27.160.320','2770002534')
						-- and fc_.ItemNumber in ('27.160.785')
						--npfc_.ItemNumber in ('2801381661','2801381810')
						-- mifc_.ItemNumber in ('27.170.180')
						-- mifc_.ItemNumber in ('27.161.320') and					-- good example that a SKU has 0 value within 12 month time bucket   - 10/5/2018
						mifc_.date between DATEADD(mm, DATEDIFF(m,0,GETDATE()),0) and DATEADD(mm, DATEDIFF(m,0,GETDATE())+11,0)		-- filter out any data which is outside future 12 month time bucket either month before or after (month +12 )   -10/5/2018
																																	-- Need to consider to use parameters rather than use function - if data is big then you will have performance issue - 10/5/2018
						--and mifc_.Override >0					-- 26/7/2018 NO Need if you did Reservers Running Total to get rid of 0 --25/7/2018		--- need to filter out < 0 value if you make by mistake put 0 either within 12 month period or When Month moves to next period ...there will be trailing 0 at end to patch up ... 15/6/2018
																	-- idealy you should have non 0 values with 12 months life span ! --- 18/6/2018        
						 --and mifc_.Override =0
						 --and mifc_.ItemNumber in ('1081401') 
						--and mifc_.ItemNumber in ( '24.7219.4460')
						
						--and mifc_.ItemNumber in ( '24.7221.0952','24.7219.4460')                         --- 29/1/2020
						

						--  and mifc_.ItemNumber in ( '34.524.000')
						--and mifc_.ItemNumber in ( '18.010.035')
						--  and mifc_.ItemNumber in ('34.524.000','18.010.035','F16174A948')
			order by mifc_.ItemNumber																								
					 ,left(mifc_.date,4) 
					 ,case right(mifc_.Date,3)	 when 'Jan' then 1
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
				 
						END			-- 'END' for Case statement




           End		-- 'End' for If statement

end
