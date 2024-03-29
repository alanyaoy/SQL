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
/****** Object:  StoredProcedure [JDE_DB_Alan].[sp_FCPRO_SlsHistory_MI_PlaceHolder_upload]    Script Date: 14/04/2022 12:07:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [JDE_DB_Alan].[sp_FCPRO_SlsHistory_MI_PlaceHolder_upload]
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


		------------------------------ Create MI PlaceHolder in FC Pro by Checking History tbl--------------------------------------------------------------------------------------------------

		   --- First To Get MI Master SKU List ( create a place holder if there is no History )by checking if  Sls_History table--- 12/2/2018
		   --- what about there is no records ( empty ) will it loaded into Sls table ? --- tested, it will not pick up any records.
		   --- Note following step MUST be taken After Reload Sls History, you need First pull Sales History from JDE First, run upload HD history and Re Generate 'SlsHist_AWFHDMT_FCPro_upload' table ---
		   --- You do not start from --> 'JDE_DB_Alan.SlsHistoryHD'  table For NP loading process, Because 
		   -- 1) you have no Short number / UOM for NP 2) you do not need to do process for superssion & stocking Type 3) it will be clean start by Just add/append records to '.SlsHist_AWFHDMT_FCPro_upload'  table, you just need to remember this is start pointfor NP loading Process. 13/2/2018
   
     --if @Check_id = '1'
  if @FCCheck_id = 'MI_1'

	    --- if MI SKU does not appear in SlsHistory table, then need to append to it ---	
	 with tb as (
				select mi.ItemNumber,Comment,min(mi.date) as FCStartDate
				from JDE_DB_Alan.FCPRO_MI_tmp mi
				where 
						not exists( 
								select distinct s.ItemNumber from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload s where mi.ItemNumber = s.ItemNumber)  
								 -- select distinct s.ItemNumber from JDE_DB_Alan.SlsHistoryHD s where np.ItemNumber = s.ItemNumber)	
						-- and np.Value >0										-- Need to pick up first Value because as more items are add in Excel Master file, different SKU has different Qty with initial Launch Month,if Item has an entry in Excel Master file but with 0 FC qty across the month, then it requires no FC or not ready yet or there is data issue , so simply put, no FC there will be no Need to create PlaceHolder & upload NP FC --- tested it is working 12/2/2018-- Need to pick up first Value because as more items are add in Excel Master file, different SKU has different Qty with initial Launch Month--- tested it is working 12/2/2018
																				-- maybe need to remove this condition ( value > 0 ) because primary goal of this code to put a placeholder for any SKU which is new items, evn we add a dummy sales to the Sls tbl, if forecast exported out with 0 value, we can say no one give us FC yet. However by having 0 value we will be able to cater other situations like superssion, so by hving placeholder code in its first place, we can add superseded history on top of 'existing code' -- 7/3/2018	
						--and np.ItemNumber in ('34.522.000','2851542072')
						  and mi.ValidStatus = 'Y'						--- 12/6/2018 --- You will manually put some intelligence in 'ValidStatus' column in Excel, it will not be ideal to add 'StockingType' which CAN affect 'ValidStatus' Y or N since it will 1) violate 'normalization' principle 2) add difficulty to updae in Excel column of 'StockingType'  --- 14/6/2018
				group by mi.ItemNumber,Comment
				--order by np.ItemNumber 
				)
			--select * from cte	 
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
							,m.StandardCost,m.WholeSalePrice
							,tb_.FCStartDate,dateadd(m,-1,tb_.FCstartdate) as MockFCStartDate					--- old, should not be using tb_.FCstartdate ?? Really ? Maybe it is better to use Original start date.. but if you do not like you can use below code to use Last Month date ( Getdate())  --- 14/6/2018
							--,tb_.FCStartDate,DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0)  as MockFCStartDate	    -- new --- 14/6/2018
							,m.StockingType						
					from tb_ left join JDE_DB_Alan.Master_ML345 m on tb_.fItemNumber = m.ItemNumber 
					--where m.StockingType not in ('O','U')				-- need to filter out discontinued product. Also need to consider to add stocking type Column to MI & NP file  --- 14/6/2018
					        --  or m.StockingType is null					--- https://stackoverflow.com/questions/129077/not-in-clause-and-null-values    -- some good reading 22/6/2018
					--where mm.StockingType in ('O','K','W','X','S','F','P','U','Q','Z','C','M','0','I')			
					  where m.StockingType in ('K','W','X','S','F','P','Q','Z','C','M','0','I')				   -- this could be best to avoid issue of returning empty dataSet due to Null value --- 23/7/2018

					) -- ItemNumber short be 1:1 relation to ShortItemNum

            -- select * from ml
			-- where ml.fItemNumber in ('2780136000')

			,stg as 
			(select ml.*
					,c.LongDescription as SellingGroup_
					,d.LongDescription as FamilyGroup_
					,e.LongDescription as Family_0
					--,tbl.Family as Family_1
					--,f.StandardCost,f.WholeSalePrice
				from ml left join JDE_DB_Alan.MasterSellingGroup c on ml.SellingGroup = c.Code
						left join JDE_DB_Alan.MasterFamilyGroup d on ml.FamilyGroup = d.Code
						left join JDE_DB_Alan.MasterFamily e on ml.Family = e.Code
				)

			 --,cte1 as (
				--select ml.fItemNumber,ml.Description,ml.StandardCost,ml.WholeSalePrice
				--		,row_number() over(partition by ml.fitemnumber order by fitemnumber ) rn from ml
				--	)

			 --,cte as (
				--	select * from cte1 
				--	where rn = 1 )

		,fl as (
				select 'Total' as RowLabel,stg.SellingGroup_ as SellingGroup,stg.FamilyGroup_ as FamilyGroup,stg.Family_0 as Family
					 ,stg.fItemNumber,stg.Description
					 ,stg.StandardCost,stg.WholeSalePrice
					,stg.FCStartDate	
					,stg.MockFCStartDate					-- deliberately set up MockFCStartDate as Month -1, because SlsHistory will cut off any Sales data in current Month -- 26/2/20187
					
										
					--,cast(replace(convert(varchar(8),stg.MockFCStartDate,126),'-','') as integer) as CYM_Mock						--- should not use varchar(8)  --- 13/4/2022
					--,cast(substring(replace(convert(varchar(8),stg.MockFCStartDate,126),'-',''),1,4) as integer) CY_Mock
					--,cast(substring(replace(convert(varchar(8),stg.MockFCStartDate),'-',''),5,2) as integer) Month_Mock			--- missing '126' format, system will interpret yyyy-d-m !!  --- 13/4/2022
						
					,cast(replace(convert(varchar(10),stg.MockFCStartDate,126),'-','') as integer) as CYM_Mock		 
					,cast(substring(replace(convert(varchar(10),stg.MockFCStartDate,126),'-',''),1,4) as integer) CY_Mock
					,cast(substring(replace(convert(varchar(10),stg.MockFCStartDate,126),'-',''),5,2) as integer) Month_Mock

					,'12' as PPY, '12' as PPC
					,0 as SalesQty						-- deliberately set qty to 0	26/2/2018	
					--,getdate() as ReportDate
				 from stg
					--where stg.fItemNumber in ('29115290720')		-- intentionally/deliberately to create a wrong SKU number by add '0' at end of SKU Number so query return no records, see if query will insert any value into table 'SlsHist_AWFHDMT_FCPro_upload' - 12/2/2018
				   -- where stg.fItemNumber in ('2911529072','2851542072')
				  --where stg.fItemNumber in ('2801381810')			--- Activate this line for Testing Purpose -- 15/2/2018
					)
         
		  --select * from fl 	    
           --select top 5 fl.* from fl --where z.fItemNumber in ('2911529072')

        ,myfl as (    
		             select fl.RowLabel,fl.SellingGroup,fl.FamilyGroup,fl.Family,fl.fItemNumber,fl.Description,fl.CY_Mock,fl.Month_Mock,fl.PPY,fl.PPC
						,fl.CYM_Mock,fl.SalesQty,fl.SalesQty as SalesQty_Adj,'N' as ValidStatus_					--- 12/6/2020,  reset every month  ( everything will rely on exception tbl ) - defaul Validstatus is 'N', which means No it is not qualified Adjustment, you need to adjust sales history.
						,getdate() as ReportDate 
							  -- ,fl.fam
                     from fl
		
					--select fl.RowLabel,fl.SellingGroup,fl.FamilyGroup,fl.Family,fl.fItemNumber,fl.Description,fl.CY_Mock,fl.Month_Mock,fl.PPY,fl.PPC,fl.SalesQty,fl.CYM_Mock,getdate() as ReportDate
					 --from fl
		           )   
           
		   --select * from myfl 
		  -- where myfl.fItemNumber in ('2780136000')
		 --  where myfl.fItemNumber in ('2801382551')
		 --  where myfl.SellingGroup is null					--- This is very good code to see & identify any field you have null value, since you put constraint in table definition and if you go to insert into table when you have null value you will be thrown with error like --> Cannot insert the value NULL into column 'SellingGroup', table 'JDE_DB_Alan.JDE_DB_Alan.Px_AWF_HD_MT_FCPro_upload'; column does not allow nulls. INSERT fails. --- 1/3/2018  --- The most important things here is how to identify which records cause insert fail and where is the null value as error message does not give enough clue like which row which line. So it begs the question is it worthvile to implement null value or not in table definition ?
		  -- select * from myfl   
           --select top 5 myfl.* from myfl
			insert into JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload select * from myfl  --where myfl.fItemNumber in ('2801381810')			--- Activate this line for Testing Purpose -- 15/2/2018
			--select * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload l --where l.ItemNumber in ('2911529072')
			--delete from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload where ItemNumber in ('2911529072')

			--select l.ReportDate,count(l.ItemNumber) from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload l group by l.ReportDate

			------------------------------------------------------------------
			-- select * from dbo.vw_NP_FC
			
			--- YOu miss a Key word 'else' !!! 16-8-2018 then whole Programming will not be working ! Pay attention to Grammer / Syntax Alan !
       else if @FCCheck_id = 'MI_2'
	      begin
		      	
				--- if MI SKU does not appear in SlsHistory table, then need to append to it ---
				-- use MI_2_Raw table --- 16/8/2018
		    with  mi2Raw as ( select  f.ItemID as ItemNumber,f.Date, sum(f.Value) as FC_Qty
		                from JDE_DB_Alan.FCPRO_MI_2_Raw_Data_tmp f
						where  f.ValidStatus in  ('Y','S','N')						--Need to pick up all Status ( say if you want do testing and you want to include N or S status as well -- 21/8/2018	--- 12/6/2018 --- You will manually put some intelligence in 'ValidStatus' column in Excel, it will not be ideal to add 'StockingType' which CAN affect 'ValidStatus' Y or N since it will 1) violate 'normalization' principle 2) add difficulty to updae in Excel column of 'StockingType'  --- 14/6/2018
						    --   and f.ItemID in ('32.501.000')
						group by f.ItemID,f.date
						)	          

			 ,tb as (
					select f.ItemNumber,min(f.date) as FCStartDate
					--from JDE_DB_Alan.FCPRO_MI_2_tmp mi
					from mi2Raw f
					where 
							not exists( 
									select distinct s.ItemNumber from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload s where f.ItemNumber = s.ItemNumber) 
									 -- select distinct s.ItemNumber from JDE_DB_Alan.SlsHistoryHD s where np.ItemNumber = s.ItemNumber)	
							-- and np.Value >0									-- Need to pick up first Value because as more items are add in Excel Master file, different SKU has different Qty with initial Launch Month,if Item has an entry in Excel Master file but with 0 FC qty across the month, then it requires no FC or not ready yet or there is data issue , so simply put, no FC there will be no Need to create PlaceHolder & upload NP FC --- tested it is working 12/2/2018-- Need to pick up first Value because as more items are add in Excel Master file, different SKU has different Qty with initial Launch Month--- tested it is working 12/2/2018
																				-- maybe need to remove this condition ( value > 0 ) because primary goal of this code to put a placeholder for any SKU which is new items, evn we add a dummy sales to the Sls tbl, if forecast exported out with 0 value, we can say no one give us FC yet. However by having 0 value we will be able to cater other situations like superssion, so by hving placeholder code in its first place, we can add superseded history on top of 'existing code' -- 7/3/2018																			
							--and np.ItemNumber in ('34.522.000','2851542072')
							--  and f.ValidStatus= 'Y'				--- 12/6/2018 --- You will manually put some intelligence in 'ValidStatus' column in Excel, it will not be ideal to add 'StockingType' which CAN affect 'ValidStatus' Y or N since it will 1) violate 'normalization' principle 2) add difficulty to updae in Excel column of 'StockingType'  --- 14/6/2018
					group by f.ItemNumber
					--order by np.ItemNumber 
					)
				--select * from cte	 
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
							--,tb.Comment
							,tb.FCStartDate								
						 from tb left join l on tb.ItemNumber = l.ItemNumber)		--- not join by ShortItem Number as HD+MT Uploading do

				,ml as ( select tb_.fItemNumber
								,m.Description,m.SellingGroup,m.FamilyGroup,m.Family
								,m.StandardCost,m.WholeSalePrice
								,tb_.FCStartDate,dateadd(m,-1,tb_.FCstartdate) as MockFCStartDate					--- old, should not be using tb_.FCstartdate ?? Really ? Maybe it is better to use Original start date.. but if you do not like you can use below code to use Last Month date ( Getdate())  --- 14/6/2018
								--,tb_.FCStartDate,DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0)  as MockFCStartDate	    -- new --- 14/6/2018											
						from tb_ left join JDE_DB_Alan.Master_ML345 m on tb_.fItemNumber = m.ItemNumber 
				 	      --where m.StockingType not in ('O','U')				-- need to filter out discontinued product. Also need to consider to add stocking type Column to MI & NP file  --- 14/6/2018
							   --  or m.StockingType is null					--- https://stackoverflow.com/questions/129077/not-in-clause-and-null-values    -- some good reading 22/6/2018

						 -- where mm.StockingType in ('O','K','W','X','S','F','P','U','Q','Z','C','M','0','I')			
						     where m.StockingType in ('K','W','X','S','F','P','Q','Z','C','M','0','I')				   -- this could be best to avoid issue of returning empty dataSet due to Null value --- 23/7/2018

						) -- ItemNumber short be 1:1 relation to ShortItemNum

				-- select * from ml where ml.fItemNumber in ('27.160.661')
			    
				,stg as 
				(select ml.*
						,c.LongDescription as SellingGroup_
						,d.LongDescription as FamilyGroup_
						,e.LongDescription as Family_0
						--,tbl.Family as Family_1
						--,f.StandardCost,f.WholeSalePrice
					from ml left join JDE_DB_Alan.MasterSellingGroup c on ml.SellingGroup = c.Code
							left join JDE_DB_Alan.MasterFamilyGroup d on ml.FamilyGroup = d.Code
							left join JDE_DB_Alan.MasterFamily e on ml.Family = e.Code
					)

				 --,cte1 as (
					--select ml.fItemNumber,ml.Description,ml.StandardCost,ml.WholeSalePrice
					--		,row_number() over(partition by ml.fitemnumber order by fitemnumber ) rn from ml
					--	)

				 --,cte as (
					--	select * from cte1 
					--	where rn = 1 )

			,fl as (
					select 'Total' as RowLabel,stg.SellingGroup_ as SellingGroup,stg.FamilyGroup_ as FamilyGroup,stg.Family_0 as Family
						 ,stg.fItemNumber,stg.Description
						 ,stg.StandardCost,stg.WholeSalePrice
						,stg.FCStartDate	
						,stg.MockFCStartDate					-- deliberately set up MockFCStartDate as Month -1, because SlsHistory will cut off any Sales data in current Month -- 26/2/20187
						
						--,cast(replace(convert(varchar(8),stg.MockFCStartDate,126),'-','') as integer) as CYM_Mock						--- should not use varchar(8)  --- 13/4/2022
						--,cast(substring(replace(convert(varchar(8),stg.MockFCStartDate,126),'-',''),1,4) as integer) CY_Mock
						--,cast(substring(replace(convert(varchar(8),stg.MockFCStartDate),'-',''),5,2) as integer) Month_Mock			--- missing '126' format, system will interpret yyyy-d-m !!  --- 13/4/2022
						
						,cast(replace(convert(varchar(10),stg.MockFCStartDate,126),'-','') as integer) as CYM_Mock		 
						,cast(substring(replace(convert(varchar(10),stg.MockFCStartDate,126),'-',''),1,4) as integer) CY_Mock
						,cast(substring(replace(convert(varchar(10),stg.MockFCStartDate,126),'-',''),5,2) as integer) Month_Mock
						,'12' as PPY, '12' as PPC
						,0 as SalesQty						-- deliberately set qty to 0	26/2/2018	
						--,getdate() as ReportDate
					 from stg
						--where stg.fItemNumber in ('29115290720')		-- intentionally/deliberately to create a wrong SKU number by add '0' at end of SKU Number so query return no records, see if query will insert any value into table 'SlsHist_AWFHDMT_FCPro_upload' - 12/2/2018
					   -- where stg.fItemNumber in ('2911529072','2851542072')
					  --where stg.fItemNumber in ('2801381810')			--- Activate this line for Testing Purpose -- 15/2/2018
						)
         
			  --select * from fl 	    
			   --select top 5 fl.* from fl --where z.fItemNumber in ('2911529072')

			,myfl as ( 
			           select fl.RowLabel,fl.SellingGroup,fl.FamilyGroup,fl.Family,fl.fItemNumber,fl.Description,fl.CY_Mock,fl.Month_Mock,fl.PPY,fl.PPC
							,fl.CYM_Mock,fl.SalesQty,fl.SalesQty as SalesQty_Adj,'N' as ValidStatus_					--- 12/6/2020, reset every month  ( everything will rely on exception tbl ) - defaul Validstatus is 'N', which means No it is not qualified Adjustment, you need to adjust sales history.
							,getdate() as ReportDate 
								  -- ,fl.fam
                        from fl

						--select fl.RowLabel,fl.SellingGroup,fl.FamilyGroup,fl.Family,fl.fItemNumber,fl.Description,fl.CY_Mock,fl.Month_Mock,fl.PPY,fl.PPC,fl.SalesQty,fl.CYM_Mock,getdate() as ReportDate
						 --from fl
					   )   
           
			  -- select * from myfl   
			   --select top 5 myfl.* from myfl
			insert into JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload select * from myfl  --where myfl.fItemNumber in ('2801381810')			--- Activate this line for Testing Purpose -- 15/2/2018
				--select * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload l --where l.ItemNumber in ('2911529072')
				--delete from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload where ItemNumber in ('2911529072')

				--select l.ReportDate,count(l.ItemNumber) from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload l group by l.ReportDate

				------------------------------------------------------------------
				-- select * from dbo.vw_NP_FC
			
			------------------------ To Get Your Price Conversion table -----------------------
			--,flpri as ( select fl.RowLabel,fl.SellingGroup,fl.FamilyGroup,fl.Family,fl.fItemNumber,fl.StandardCost,fl.WholeSalePrice
			--				  ,row_number() over(partition by fl.fitemnumber order by fl.fitemnumber) as rn,GETDATE() as ReportDate
			--			from fl
			--			)
        
			--select * from flpri 
			--where flpri.fItemNumber in ('2780136000')
			--where flpri.fItemNumber in ('2801382551')
			--where flpri.Family is null					--- This is very good code to see & identify any field you have null value, since you put constraint in table definition and if you go to insert into table when you have null value you will be thrown with error like --> Cannot insert the value NULL into column 'SellingGroup', table 'JDE_DB_Alan.JDE_DB_Alan.Px_AWF_HD_MT_FCPro_upload'; column does not allow nulls. INSERT fails. --- 1/3/2018  --- The most important things here is how to identify which records cause insert fail and where is the null value as error message does not give enough clue like which row which line. So it begs the question is it worthvile to implement null value or not in table definition ?
			--select top 3 flpri.* from flpri
			--insert into JDE_DB_Alan.Px_AWF_HD_MT_FCPro_upload select * from flpri where flpri.rn =1	

		   end

		   select * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload l 

END
