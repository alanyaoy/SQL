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
/****** Object:  StoredProcedure [JDE_DB_Alan].[sp_MI_FC_Check_upload]    Script Date: 3/08/2018 12:36:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [JDE_DB_Alan].[sp_MI_FC_Check_upload]
	-- Add the parameters for the stored procedure here
	--<@Param1, sysname, @p1> <Datatype_For_Param1, , int> = <Default_Value_For_Param1, , 0>, 
	--<@Param2, sysname, @p2> <Datatype_For_Param2, , int> = <Default_Value_For_Param2, , 0>

	@FCCheck_id varchar(10) = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	--SELECT <@Param1, sysname, @p1>, <@Param2, sysname, @p2>

	------- This code check before Upload NP FC into FC Pro to see and make sure all NP SKUs exist in FC Pro system so that you can override Stat FC --- 15/2/2018 --------
	---- this code then will list all items which does not have FC ---

  --if @Check_id = '1'
  if @FCCheck_id = 'MI_1'

			with tb as (
					select mi.ItemNumber,Comment,min(mi.date) as FCStartDate   
					from JDE_DB_Alan.FCPRO_MI_tmp mi 
					where 
							not exists( 
										select distinct f.ItemNumber from JDE_DB_Alan.FCPRO_Fcst f where mi.ItemNumber = f.ItemNumber) 			-- check with Forecast table not history ( unlike NP_PlaceHolder ), assuming FC has been Generated using Dummy records for NP PlaceHolder -- 14-02-2018					
				  
						and mi.Value >0										-- Need to pick up first Value because as more items are add in Excel Master file, different SKU has different Qty with initial Launch Month,if Item has an entry in Excel Master file but with 0 FC qty across the month, then it requires no FC or not ready yet or there is data issue , so simply put, no FC there will be no Need to create PlaceHolder & upload NP FC --- tested it is working 12/2/2018-- Need to pick up first Value because as more items are add in Excel Master file, different SKU has different Qty with initial Launch Month--- tested it is working 12/2/2018
					
						and mi.Date > DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0)	-- Need to pick up data which is greater than current month in & onwards, albeit FC Pro when loading data it will cut off any data older than current month but it is better to do it here to ensure right data is loaded in - 28/2/2018 --- note cut off only relate to History not FC, so need to pick up FC from current month onwards, otherwise you will lost one month FC -- 12/3/2018
							--and np.ItemNumber in ('34.522.000','2851542072')
						  --and np.ItemNumber in ('2801381810')					--- Activate this line for Testing Purpose -- 15/2/2018
						  -- and mi.ItemNumber in ('709901')
						and mi.ValidStatus = 'Y'				-- by valid status           --- 31/5/2018    , be careful if you want to join 'FCPRO_MI_tmp' table with other table you need to first filter out by status then join NOT put condition straightaway when join (in same select statement),otherwise you will lose data in null value -- see 'sp_funct2Jde_ZeroOut'  ---8/6/2018
																							   --- 12/6/2018 --- You will manually put some intelligence in 'ValidStatus' column in Excel, it will not be ideal to add 'StockingType' which CAN affect 'ValidStatus' Y or N since it will 1) violate 'normalization' principle 2) add difficulty to updae in Excel column of 'StockingType'  --- 14/6/2018
					group by mi.ItemNumber,Comment
					--order by np.ItemNumber 
				)

			-- select * from tb  order by tb.ItemNumber			-- this is old code as of 12/6/2018 -- code stops here... after 14/6/2018 code extends to below ... main purpose to get right section of SKU numbers


			 --- Get Right ItemNumber, Fix leading Zero --- NO need for superssion & Stocking Type at this Stage for NP --- make all NP as 'I' in NP file ?
				,l as ( select y.*,
								case 
									when y.ItemWithLeadingZero ='Y' then '0'+ y.ItemNumber
									else y.ItemNumber		 
									end as myItemNumber
							from JDE_DB_Alan.MasterMTLeadingZeroItemList y )

				-- No need to fix leading zero in ML345 itself, it is already clean in its first place
					--,q as ( 
								--select x.*,l.myItemNumber 
								--from JDE_DB_Alan.Master_ML345 x left join l on x.ShortItemNumber = l.ShortItemNo 
								--)
		
					,tb_ as ( select 
								case 
									when l.myItemNumber is null then tb.ItemNumber
									else l.myItemNumber		 
									end as fItemNumber	
								,tb.Comment
								,tb.FCStartDate								
							 from tb left join l on tb.ItemNumber = l.ItemNumber)		--- not join by ShortItem Number as HD+MT Uploading do

					,ml as ( select tb_.fItemNumber
									,m.Description,m.SellingGroup,m.FamilyGroup,m.Family
									,m.StandardCost,m.WholeSalePrice,m.StockingType
									,tb_.FCStartDate,dateadd(m,-1,tb_.FCstartdate) as MockFCStartDate					--- old, should not be using tb_.FCstartdate ?? Really ? Maybe it is better to use Original start date.. but if you do not like you can use below code to use Last Month date ( Getdate())  --- 14/6/2018
									--,tb_.FCStartDate,DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0)  as MockFCStartDate	    -- new --- 14/6/2018											
							from tb_ left join JDE_DB_Alan.Master_ML345 m on tb_.fItemNumber = m.ItemNumber 
				 			--where m.StockingType not in ('O','U')				-- need to filter out discontinued product. Also need to consider to add stocking type Column to MI & NP file  --- 14/6/2018
																				-- need to keep all Stock type since people might provide MI againt O or U product --- 1/8/2018

                               --  where m.StockingType in ('O','K','W','X','S','F','P','U','Q','Z','C','M','0','I')			-- this could be best to avoid issue of returning empty dataSet due to Null value --- 23/7/2018		
							     where m.StockingType in ('K','W','X','S','F','P','Q','Z','C','M','0','I') or m.StockingType is null
							) -- ItemNumber short be 1:1 relation to ShortItemNum

					 select * from ml 
					-- where ml.fItemNumber in ('27.160.661')
					  --where ml.fItemNumber in ('709901')
					 order by ml.fItemNumber

      else if @FCCheck_id = 'MI_2'
	  begin
	   
		  with tb as (
					select mi.ItemNumber,Comment,min(mi.date) as FCStartDate   
					from JDE_DB_Alan.FCPRO_MI_2_tmp mi
					--  from JDE_DB_Alan.FCPRO_MI_2_Raw_Data_tmp mi				-- Use Raw Data or Data has been transformed & loaded in 'FCPRO_MI_2_tmp' ?? Need to think --- 3/8/2018
					where 
							not exists( 
										select distinct f.ItemNumber from JDE_DB_Alan.FCPRO_Fcst f where mi.ItemNumber = f.ItemNumber) 			-- check with Forecast table not history ( unlike NP_PlaceHolder ), assuming FC has been Generated using Dummy records for NP PlaceHolder -- 14-02-2018					
				  
						and mi.Value >0										-- Need to pick up first Value because as more items are add in Excel Master file, different SKU has different Qty with initial Launch Month,if Item has an entry in Excel Master file but with 0 FC qty across the month, then it requires no FC or not ready yet or there is data issue , so simply put, no FC there will be no Need to create PlaceHolder & upload NP FC --- tested it is working 12/2/2018-- Need to pick up first Value because as more items are add in Excel Master file, different SKU has different Qty with initial Launch Month--- tested it is working 12/2/2018
					
						and mi.Date > DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0)	-- Need to pick up data which is greater than current month in & onwards, albeit FC Pro when loading data it will cut off any data older than current month but it is better to do it here to ensure right data is loaded in - 28/2/2018 --- note cut off only relate to History not FC, so need to pick up FC from current month onwards, otherwise you will lost one month FC -- 12/3/2018
							--and np.ItemNumber in ('34.522.000','2851542072')
						  --and np.ItemNumber in ('2801381810')					--- Activate this line for Testing Purpose -- 15/2/2018

						and mi.ValidStatus = 'Y'				-- by valid status           --- 31/5/2018    , be careful if you want to join 'FCPRO_MI_tmp' table with other table you need to first filter out by status then join NOT put condition straightaway when join (in same select statement),otherwise you will lose data in null value -- see 'sp_funct2Jde_ZeroOut'  ---8/6/2018
																							   --- 12/6/2018 --- You will manually put some intelligence in 'ValidStatus' column in Excel, it will not be ideal to add 'StockingType' which CAN affect 'ValidStatus' Y or N since it will 1) violate 'normalization' principle 2) add difficulty to updae in Excel column of 'StockingType'  --- 14/6/2018
					group by mi.ItemNumber,Comment
					--order by np.ItemNumber 
				)

			-- select * from tb  order by tb.ItemNumber			-- this is old code as of 12/6/2018 -- code stops here... after 14/6/2018 code extends to below ... main purpose to get right section of SKU numbers


			 --- Get Right ItemNumber, Fix leading Zero --- NO need for superssion & Stocking Type at this Stage for NP --- make all NP as 'I' in NP file ?
				,l as ( select y.*,
								case 
									when y.ItemWithLeadingZero ='Y' then '0'+ y.ItemNumber
									else y.ItemNumber		 
									end as myItemNumber
							from JDE_DB_Alan.MasterMTLeadingZeroItemList y )

				-- No need to fix leading zero in ML345 itself, it is already clean in its first place
					--,q as ( 
								--select x.*,l.myItemNumber 
								--from JDE_DB_Alan.Master_ML345 x left join l on x.ShortItemNumber = l.ShortItemNo 
								--)
		
					,tb_ as ( select 
								case 
									when l.myItemNumber is null then tb.ItemNumber
									else l.myItemNumber		 
									end as fItemNumber	
								,tb.Comment
								,tb.FCStartDate								
							 from tb left join l on tb.ItemNumber = l.ItemNumber)		--- not join by ShortItem Number as HD+MT Uploading do

					,ml as ( select tb_.fItemNumber
									,m.Description,m.SellingGroup,m.FamilyGroup,m.Family
									,m.StandardCost,m.WholeSalePrice,m.StockingType
									,tb_.FCStartDate,dateadd(m,-1,tb_.FCstartdate) as MockFCStartDate					--- old, should not be using tb_.FCstartdate ?? Really ? Maybe it is better to use Original start date.. but if you do not like you can use below code to use Last Month date ( Getdate())  --- 14/6/2018
									--,tb_.FCStartDate,DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0)  as MockFCStartDate	    -- new --- 14/6/2018											
							from tb_ left join JDE_DB_Alan.Master_ML345 m on tb_.fItemNumber = m.ItemNumber 
				 			--where m.StockingType not in ('O','U')				-- need to filter out discontinued product. Also need to consider to add stocking type Column to MI & NP file  --- 14/6/2018
																					-- need to keep all Stock type since people might provide MI againt O or U product --- 1/8/2018
          
		                         --  where m.StockingType in ('O','K','W','X','S','F','P','U','Q','Z','C','M','0','I')		-- this could be best to avoid issue of returning empty dataSet due to Null value --- 23/7/2018
		                        where m.StockingType in ('K','W','X','S','F','P','Q','Z','C','M','0','I') or m.StockingType is null
							) -- ItemNumber short be 1:1 relation to ShortItemNum

					 select * from ml 
					-- where ml.fItemNumber in ('27.160.661')
						 --where ml.fItemNumber in ('709901')		
					 order by ml.fItemNumber
       end 
  

END
