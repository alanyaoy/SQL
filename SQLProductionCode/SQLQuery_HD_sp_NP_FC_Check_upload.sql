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
/****** Object:  StoredProcedure [JDE_DB_Alan].[sp_NP_FC_Check_upload]    Script Date: 22/06/2018 12:05:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [JDE_DB_Alan].[sp_NP_FC_Check_upload]
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

	------- This code check before Upload NP FC into FC Pro to see and make sure all NP SKUs exist in FC Pro system so that you can override Stat FC --- 15/2/2018 --------
	---- this code then will list all items which does not have FC ---


   ;with cte as (
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
	--select t.ItemNumber,t.Date,t.Value,t.DataType,t.CN_Number,t.Comment,t.Creator,t.LastUpdated,t.fSTKTYP as ValidStatus_,t.RefNum,t.ReportDate
	--from tb_ t
	--where t.fSTKTYP_St = 'N'
	--where t.ItemNumber in ('34.528.000','34.527.000','KIT8105')
	--order by t.ItemNumber,t.Date   
   
    ,_tb as (
			select np.ItemNumber,Comment,min(np.date) as FCStartDate   
			--from JDE_DB_Alan.FCPRO_NP_tmp np 				--- old way 22/6/2018
			from tb_ as np	
			where 
					not exists( 
								select distinct f.ItemNumber from JDE_DB_Alan.FCPRO_Fcst f where np.ItemNumber = f.ItemNumber) 			-- check with Forecast table not history ( unlike NP_PlaceHolder ), assuming FC has been Generated using Dummy records for NP PlaceHolder -- 14-02-2018					
				  
				and np.Value >0										-- Need to pick up first Value because as more items are add in Excel Master file, different SKU has different Qty with initial Launch Month,if Item has an entry in Excel Master file but with 0 FC qty across the month, then it requires no FC or not ready yet or there is data issue , so simply put, no FC there will be no Need to create PlaceHolder & upload NP FC --- tested it is working 12/2/2018-- Need to pick up first Value because as more items are add in Excel Master file, different SKU has different Qty with initial Launch Month--- tested it is working 12/2/2018
					
				and np.Date > DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0)	-- Need to pick up data which is greater than current month in & onwards, albeit FC Pro when loading data it will cut off any data older than current month but it is better to do it here to ensure right data is loaded in - 28/2/2018 --- note cut off only relate to History not FC, so need to pick up FC from current month onwards, otherwise you will lost one month FC -- 12/3/2018
					--and np.ItemNumber in ('34.522.000','2851542072')
				  --and np.ItemNumber in ('2801381810')					--- Activate this line for Testing Purpose -- 15/2/2018

                --and np.ValidStatus = 'Y'				-- by valid status           --- 31/5/2018    , be careful if you want to join 'FCPRO_MI_tmp' table with other table you need to first filter out by status then join NOT put condition straightaway when join (in same select statement),otherwise you will lose data in null value -- see 'sp_funct2Jde_ZeroOut'  ---8/6/2018
			      and np.fSTKTYP_St = 'Y'																		--- 12/6/2018 --- You will manually put some intelligence in 'ValidStatus' column in Excel, it will not be ideal to add 'StockingType' which CAN affect 'ValidStatus' Y or N since it will 1) violate 'normalization' principle 2) add difficulty to updae in Excel column of 'StockingType'  --- 14/6/2018
			group by np.ItemNumber,Comment
			--order by np.ItemNumber 
		)

	 select * from _tb
	 order by _tb.ItemNumber


	--- Old Method ---
	 --;with tb as (
		--	select np.ItemNumber,Comment,min(np.date) as FCStartDate   
		--	from JDE_DB_Alan.FCPRO_NP_tmp np 			
		--	where 
		--			not exists( 
		--						select distinct f.ItemNumber from JDE_DB_Alan.FCPRO_Fcst f where np.ItemNumber = f.ItemNumber) 			-- check with Forecast table not history ( unlike NP_PlaceHolder ), assuming FC has been Generated using Dummy records for NP PlaceHolder -- 14-02-2018					
				  
		--		and np.Value >0										-- Need to pick up first Value because as more items are add in Excel Master file, different SKU has different Qty with initial Launch Month,if Item has an entry in Excel Master file but with 0 FC qty across the month, then it requires no FC or not ready yet or there is data issue , so simply put, no FC there will be no Need to create PlaceHolder & upload NP FC --- tested it is working 12/2/2018-- Need to pick up first Value because as more items are add in Excel Master file, different SKU has different Qty with initial Launch Month--- tested it is working 12/2/2018
					
		--		and np.Date > DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0)	-- Need to pick up data which is greater than current month in & onwards, albeit FC Pro when loading data it will cut off any data older than current month but it is better to do it here to ensure right data is loaded in - 28/2/2018 --- note cut off only relate to History not FC, so need to pick up FC from current month onwards, otherwise you will lost one month FC -- 12/3/2018
		--			--and np.ItemNumber in ('34.522.000','2851542072')
		--		  --and np.ItemNumber in ('2801381810')					--- Activate this line for Testing Purpose -- 15/2/2018

  --              and np.ValidStatus = 'Y'				-- by valid status           --- 31/5/2018    , be careful if you want to join 'FCPRO_MI_tmp' table with other table you need to first filter out by status then join NOT put condition straightaway when join (in same select statement),otherwise you will lose data in null value -- see 'sp_funct2Jde_ZeroOut'  ---8/6/2018
		--	    																	--- 12/6/2018 --- You will manually put some intelligence in 'ValidStatus' column in Excel, it will not be ideal to add 'StockingType' which CAN affect 'ValidStatus' Y or N since it will 1) violate 'normalization' principle 2) add difficulty to updae in Excel column of 'StockingType'  --- 14/6/2018
		--	group by np.ItemNumber,Comment
		--	--order by np.ItemNumber 
		--)

	 --select * from tb
	 --order by tb.ItemNumber

END
