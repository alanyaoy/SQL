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

/****** Object:  StoredProcedure [JDE_DB_Alan].[sp_FCPRO_SlsHistory_upload]    Script Date: 4/05/2021 11:33:37 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [JDE_DB_Alan].[sp_FCPRO_SlsHistory_upload_Old_V2]
	-- Add the parameters for the stored procedure here
	--<@Param1, sysname, @p1> <Datatype_For_Param1, , int> = <Default_Value_For_Param1, , 0>, 
	--<@Param2, sysname, @p2> <Datatype_For_Param2, , int> = <Default_Value_For_Param2, , 0>
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	--------------- Notes for logic and code flow & Business rules as Below ---------------------------------------
	--1. Sequence is important here ! --> Need to do superssion first before filter out 'O' Or 'U' productu, otherwise you will lost sales ---
	--2. One step in this code is as final step we need to remove/excluding any SKUs which has not history 
	--3.   4/9/2020  de commissioned code for MT business --- Finally after 2 years ! ------ Only leave HD history ----------



    -- Insert statements for procedure here
	--SELECT <@Param1, sysname, @p1>, <@Param2, sysname, @p2>
	-----------------------------  MT History     25/10/2017 ------------------------------------------------------

			--with t as ( select * 
					--from JDE_DB_Alan.SalesHistoryAWFHDMT a )

			--==============================================================================
			--- First need to delete old data for HD,MT,AWF table, important !!! ----
			--==============================================================================

			--select * from JDE_DB_Alan.SalesHistoryAWFHDMT
			--select * from JDE_DB_Alan.SalesHistoryHD
			--select * from JDE_DB_Alan.SalesHistoryMT

			--delete from JDE_DB_Alan.SalesHistoryAWFHDMT
			--delete from JDE_DB_Alan.SalesHistoryHD
			--delete from JDE_DB_Alan.SalesHistoryMT


			---- Start to fix issue for Item with leading zero --------
	   delete from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload


		--------------------------------------------------------------------------------------------------------------------------------

			    ------- Below MthCal code is used for Rectify Covid-19 period sales history,Original 'Sales upload programme does not have MthCal -------
			  
			  ------------- Alan's New code for Calendar ------------------ 1/6/2018 -------------------------------					

                  --->>>  New parameters for Alan's MthCal  ------ 16/4/2021 
				  --->>> old code has only 2 years of past months + 2 years future ( forward )     --- key is 24; length N <49;boundary m.rnk <25 and m.rnk >12 ;  
				  --->>> new code has 3 years of past months ( back ) + 2 years future ( forward )  ---key is 36; length N <61;boundary m.rnk <37 and m.rnk >24 ;
				  --->>> for Portfolio Analysis purpose only fetch last 12 months sales history

				  ---***Basically Extend 24 to 36 month for past; did not change Peter's code ( 24 months ? )
   
   	
	   ;with R(N,_T,T_,T,XX,YY,start) AS
						(
							select 1 as N,-36 as _T,36 as T_,-35 as T,36 as XX,36 as YY,cast(DATEADD(mm, DATEDIFF(mm, 0, GETDATE())-36, 0) as datetime) as start      -- pay attention T starts -23,you need this so you can get XXX Column/Field in current month you start as 1, otherwise you can use XX field
							UNION ALL
							select  N+1, _T+1,T_-1,case when T+1<0 then T+1 else case when T+1 =0 then 1 else T+1 end end as T						
												,case when N >= 36  then _T+1
													else  
														XX-1
													end as XX
													,case when N >= 36  then T							     
													else  
														YY-1
													end as YY
									,dateadd(mm,1,start)
							from R
							where N < 61
						)
				--select * from r
					--select R.N,case when R._T < 0 then R.T_ else R._T end as T, start from R
					--select R.N,case when R._T < 0 then R.T_ else R.YY end as T, start from R
			  ,MthCal as (
									select  n as rnk
										,XX
										,YY 
									,cast(SUBSTRING(REPLACE(CONVERT(char(10),start,126),'-',''),1,6) as integer) as [StartDt]		-- [StartDt] is calendar date in MthCal
									,LEFT(datename(month,start),3) AS [month_name]
									,datepart(month,start) AS [month]
									,datepart(year,start) AS [year]				
									from R  )
			--select * from MthCal


        ---=========================================== Note below part is original 'sale upload ' code =======================================================--- 20/4/2021
		,l as ( select y.*,
							case 
							   when y.ItemWithLeadingZero ='Y' then '0'+ y.ItemNumber
								else  y.ItemNumber		    
							   end as myItemNumber
						 from JDE_DB_Alan.MasterMTLeadingZeroItemList y
      
				  )

			--- get stocking type ---
		  ,tt as (
					  select a.*,x.StockingType 
					  --from JDE_DB_Alan.SlsHistoryMT a left join JDE_DB_Alan.Master_ML345 x
					    from JDE_DB_Alan.SlsHistoryMT a left join JDE_DB_Alan.vw_Mast x							--- 5/9/2019
						   on a.ShortItemNumber = x.ShortItemNumber			-- it is critical to use Short ItemNumber here 
					 -- where  x.PrimarySupplier is not null						-- add on 8/3/2018 -- One item Code can only have one primary supplier but S ( which is manufacturing items ) item has no primary supplier since it is manufacturing items
					  )
             -- select * from t where t.ItemNumber in ('26.802.659T')

			,m as ( 
					select tt.*,l.myItemNumber
						   ,case when l.myItemNumber is null then tt.ItemNumber
							   --else t.ItemNumber			-- Mistake 6/11/2017
							     else l.myItemNumber
							end as fItemNumber
					from tt left join l on tt.ShortItemNumber = l.ShortItemNo 
					--where  t.ShortItemNumber in ('1218124','159804') 
							--and concat(t.Century,t.FinancialYear,t.FinancialMonth) = '201512'
					)            
			
			--select * from m where m.myItemNumber is null
			--select * from m 
			--where m.ShortItemNumber in ('1218124','159804') and concat(m.Century,m.FinancialYear,m.FinancialMonth) = '201512'
			--order by m.Century,m.FinancialYear,m.FinancialMonth

			,_tbb as ( select m.bu,m.ShortItemNumber,m.fItemNumber
			   --    case 
				  --     when m.myItemNumber is null then m.ItemNumber
					 --   else  m.myItemNumber		    
						--end as fItemNumber,
					,m.Century,m.FinancialYear,m.FinancialMonth,m.DocumentType,m.Quantity,m.UOM,m.StockingType					
					 from m
				 )
			--select * from _tb 

  			--- Superssion for Bricos Item --- do superssion first, then if there is any U items ( which need to be superseded, can leave filter U later ) otherwise if you not have history for superseded items -- 6/3/2018
			  ,tbb_ as (
				select _tbb.*,b.NewItemNumberHD,b.NewShortItemNumberHD
				from _tbb 
					 left join JDE_DB_Alan.MasterMTSuperssionItemList b on _tbb.fItemNumber = b.CurrentItemNumberMT   
				--where _tb.StockingType in ('P','S')					-- leave the task of pick up StockingType to later stage   -- 7/3/2018
				   --   and a.ItemNumber in ('28.380.108')
				)

				
			  ,mt as (select case 
					   when tbb_.BU ='MT' then 'HD'
						else  'HD'		    
						end as BU
					,case  
					  when tbb_.NewShortItemNumberHD is null then tbb_.ShortItemNumber
						else tbb_.NewShortItemNumberHD 
						end as FinalShortItemNumber
				   , case 
					   when tbb_.NewItemNumberHD is null then tbb_.fItemNumber
						else tbb_.NewItemNumberHD 
						end as FinalItemNumber
					,tbb_.Century,tbb_.FinancialYear,tbb_.FinancialMonth,tbb_.DocumentType,tbb_.Quantity,tbb_.UOM
		
					 from tbb_ )

			 --select * from mt  where mt.FinalItemNumber in ('26.802.659T')			
			-- select * from JDE_DB_Alan.SlsHistoryHD a

			---------------------------  HD History  -----------------------------------------------------------------

			--- fix leading zero For HD ---
			 ,dd as ( 
					select h.*,l.myItemNumber from JDE_DB_Alan.SlsHistoryHD h left join l on h.ShortItemNumber = l.ShortItemNo 
					)
	  
			,_hd as ( select dd.bu,dd.ShortItemNumber,
						case 
							 when dd.myItemNumber is null then dd.ItemNumber
							 else  dd.myItemNumber		    
							end as fItemNumber
							,
						dd.Century,dd.FinancialYear,dd.FinancialMonth,dd.DocumentType,dd.Quantity,dd.UOM					
					 from dd )

				--- get stocking type --- 20/2/2018
			 ,hd_ as (
					  select _hd.*,x.StockingType
					  from _hd left join JDE_DB_Alan.Master_ML345 x
						   on _hd.ShortItemNumber = x.ShortItemNumber 
                     -- where x.StockingType not in ('O','U')			'You cannot filter like this for superssion purpose if people already put O or U against a SKU, do it after superssioin - 22/2/2018
					  )
               
			 ,hd as ( select rtrim(ltrim(hd_.BU)) as BU,hd_.ShortItemNumber,hd_.fItemNumber,hd_.Century,hd_.FinancialYear,hd_.FinancialMonth,hd_.DocumentType,hd_.Quantity,hd_.UOM 
						from hd_)

			---------------- Combine MT and HD History together ---------------
			 ---********   4/9/2020 ********** ---- de commissioned code for MT business --- Finally after 2 years !
			 ------ Only leave HD history ----------

			,cb_old as (		
					select * from mt
					union all
					select * from hd 
				 )
			
			,cb as (		
					--select * from mt
					--union all
					select * from hd 
				 )
			
			--select distinct cb.fItemNumber,cb.ShortItemNumber from cb

			 ------ ###################################### ------
			  --- Code to Rectify Covid period sales history -- namely 202003,202004,202005 ( perhaps with possibility to include 202002 to be replaced as well ) to be replaced by prior year history 201903,201904,201905 ( perhaps using 201902 for 202002 as well )  --- 16/4/2021
			 ------ ###################################### ------

			 --- Decide to move 'Covid sales adjustment' to After 'Sales History' table ( JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload )  is generated ... 16/4/2021
			 --- Decide to pack back into this Master code file, however put code at the end of programme block. Main consideration to put code at ending part is to reduce number of records as theoritically you could have 5000 x 36 = 180,000 records when padded 0 for each month for each product		--- 20/4/2021


			 
			-- select * from cb_old t where t.FinalItemNumber in ('42.210.031')

			 --select * from cb where cb.FinalItemNumber in ('18.017.163')

			 ---========================================================
			 --- Need to delete History first before Insert data into 'SalesHistoryAWFHDMT' Table  ---
			  ---========================================================
			--delete from JDE_DB_Alan.SalesHistoryAWFHDMT

			--INSERT INTO JDE_DB_Alan.SalesHistoryAWFHDMT
			--SELECT * FROM cb
  

			------------------------------------------------------------
			--select * from JDE_DB_Alan.SalesHistoryAWFHDMT

			--select * from JDE_DB_Alan.SalesHistoryHDAWF
			--delete from JDE_DB_Alan.SalesHistoryHDAWF


			---=================== CTE for Hunter Douglas Sales History =====================================================================
			
				------ Consolidate/Merge Very First HD & MT Data for Single Item --- on ItemNum , ShortItemNum level 

			 ,con as (
					select BU,fItemNumber as ItemNum,cb.ShortItemNumber as ShortItemNum,cb.Century,cb.FinancialYear,cb.FinancialMonth,cb.UOM,sum(cb.Quantity) as Quantity
					 --from JDE_DB_Alan.SalesHistoryAWFHDMT a 
					 from cb
					 group by BU,fItemNumber,cb.ShortItemNumber,cb.Century,cb.FinancialYear,cb.FinancialMonth,cb.UOM
					 --order by BU,a.ItemNumber,a.ShortItemNum,a.Century asc,a.FinancialYear asc,a.FinancialMonth desc
				)              
				
							
				--select * from con where con.ItemNum in ('26.802.659','26.802.659T','27.253.000')

              --------- Superssion --------- 21/2/2018 ---
             ,sup_list as ( select * from JDE_DB_Alan.MasterSuperssionItemList l where l.ValidStatus = 'Y')                    --- 8/6/2018
			 ,_sp as ( select con.ItemNum,con.ShortItemNum
						,sup.NewItemNumber,sup.NewShortItemNumber
							  , case
									when sup.NewItemNumber is null then con.ItemNum
									else sup.NewItemNumber
									end as fItemNum                            
                               , case
									when sup.NewShortItemNumber is null then con.ShortItemNum
									else sup.NewShortItemNumber
									end as fShortItemNum
							  ,con.Century,con.FinancialYear as Year,con.FinancialMonth as Month,con.UOM,con.Quantity
							  ,sup.ConversionRate_UOM					-- use this field as it is good  for debugging purpose  -- 7/3/2018
							  ,case																	--- Superssion for Converstion rate 
							        when sup.ConversionRate_UOM is null then con.Quantity
									when sup.ConversionRate_UOM = 1 then con.Quantity							        
									when sup.ConversionRate_UOM <> 1 then con.Quantity/sup.ConversionRate_UOM
									 end as fQuantity	
                             ,sup.ValidStatus

						from con left join sup_list sup on con.ShortItemNum = sup.CurrentShortItemNumber		-- join by ShortItemNumber						
						--where sup.ValidStatus = 'Y'					--- Check the status 8/6/2018 -- You cannot put condition here otherwise you will filter out all 'null' value in 'ValidStatus' column, rather you better start with a new temp table -- 'sup_list', check above code in line 196 for 'sup_list'
						)	
									   					
              --select * from _sp 
			  --where _sp.ItemNum in ('26.802.659','26.802.659T','27.253.000')
			  --select * from _sp where _sp.ItemNum in ('6000130009001H','6000130009001','27.253.000')

			  ------ Group data together by ItemNumber & Short Item Number / Month after superssion ------
			  ,sp as (select _sp.fItemNum,_sp.fShortItemNum,_sp.Century,_sp.Year,_sp.Month,_sp.UOM,sum(isnull(_sp.fQuantity,0)) as Qty
						 from _sp
						 group by _sp.fItemNum,_sp.fShortItemNum,_sp.Century,_sp.Year,_sp.Month,_sp.UOM
						)
					-- select * from sp_ where sp_.fItemNum in ('26.802.659','26.802.659T','27.253.000') 
					-- order by sp_.fItemNum,sp_.Century,sp_.Year,sp_.Month
               
         
			 ------ First to get rough selling group/family group/family info from R55ML345 Table,also Select ALL SKUs with right Stocking type so that Obsolete /phase out Product does not generate FC - Can ERP do this job ??  22/2/2018 ---------
			   --- the reason to do join of Hierarchy is it can take advantage of ShortItemNumber since it is unique ---

			,_tbl as (
			   select x.BU,sp.fItemNum
					,sp.fShortItemNum
					,x.StockingType,x.PrimarySupplier		
				 --   , case a.FinancialMonth 
					   --   when > 10  then a.FinancialMonth
						  --else right('00'+a.financialMonth,2)  end

					,sp.Century,sp.Year,sp.Month
					,sp.Qty,sp.Qty * (-1) as SalesQty,x.Description,x.SellingGroup,x.FamilyGroup,x.Family,sp.UOM,x.StandardCost,x.WholeSalePrice
			    from	--JDE_DB_Alan.SalesHistoryHDAWF a 
					 sp
					left join JDE_DB_Alan.Master_ML345 x			--R55ML345 Table
				 --  on a.ItemNumber = b.ItemNumber
				   on sp.fShortItemNum = x.ShortItemNumber
               --where x.StockingType not in ('O','U','Q','M')		     --- Filter out U / O stocking type -- Important so No FC generated for these SKUs - 22/2/2018, also add P/Q (BTO )and S/M (MTO) --- 5/9/2019
			     where x.StockingType not in ('O','U','Z')		     --- Filter out U / O stocking type -- Important so No FC generated for these SKUs - 22/2/2018, do not exclude  P/Q (BTO )and S/M (MTO), we need to allow fc generated for Make to Order items --- 12/9/2019
			   --  where mm.StockingType in ('O','K','W','X','S','F','P','U','Q','Z','C','M','0','I')			
			   --  where mm.StockingType in ('K','W','X','S','F','P','Q','Z','C','M','0','I')				   -- this could be best to avoid issue of returning empty dataSet due to Null value --- 23/7/2018
			--where a.ItemNumber in ('27.161.135')					-- also need to consider to use (not)/exists instead of (not)/in  because of null ( see some of articale about using 'exist/in/except'   - 10/5/2018
				   )												-- need to remove out discontinued SKU, that means you can have outdated items in Excel spreadsheet as data source but need to filter out active items before populate data into 'MI' table. - 10/5/2018				
			--select * from _tbl where _tbl.fItemNum in ('14.001.001','14.002.000','14.107.000','1444004503','1444004528','1444004707','1444004721','1444004722','19.009.001','19.360.500','19.360.600','19.360.700','22.689.091','26.021.903','26.032.906','26.033.908','26.034.347','26.092.104','26.092.133','26.092.134','26.092.711','26.401.855','26.402.855','26.532.000','26.881.030','26.883.000','26.885.000','26.886.000','26.887.000','26.888.000','26.889.000','26.893.000','26.894.000','26.895.000','26.896.000','2801463000','34.216.000','40.041.827','40.343.131','40.362.173','40.789.000','6431050000','6865255206')
			-- where tbl.fItemNum in ('18.017.163','42.210.031') 

			
			----- Filter out any SKUs that are tempararily reinstated by Stevyn/Planner (stock type changed from U or O back to P or S temporarily --- but no need to generated FC against those 'P' or 'S' items --- 10/12/2020
			---- One way to do this to avoid generate fc is filter out all 'P','Q','S','M' SKU under supplier '506196 ('P','Q') / '506197 ('S','M') --- Stevyn has intentionally use Obsolete supplier code '506196'/'506197' for those temporarily re activated Items.
			---- The other way to do this is filter out all 'P','Q','S','M' SKU with Planning code '0' which is not planned by MRP from 'vw_mast_planning' table ( V4102A) , when Stevyn obsolete products, he will change the planning code as well. 
			
		    ---====================================================
			--- Option 1, use Obsolete supplier 506196/506197---
			---===================================================
			,Invlid_supplier as ( select m.ItemNumber,m.Description,m.FamilyGroup,m.PrimarySupplier,m.StockingType 
									from JDE_DB_Alan.vw_Mast m 
									--where m.PrimarySupplier in ('506196','506197') and m.StockingType in ('P','Q','S','M','K')		--Q is BTO; 'M' is MTO,'K' is Kit/Parent Item
									where m.PrimarySupplier in ('506196','506197') and m.StockingType in ('P','Q','S','M')		--Q is BTO; 'M' is MTO
									
									)               
			,tbl_1 as ( select * from _tbl where not exists ( select i.ItemNumber from Invlid_supplier i where _tbl.fItemNum =i.ItemNumber) )
			 --select * from tbl_1	where tbl_1.fItemNum in ('26.021.903')			--- yield 103,038 records


			 ---=============================================================
			  --- Option 2, use Planning Code Value , to filter out Item with '0' planning code---
			  --- use below code so that you have visibility of which Item has zero planning code against them ---
			  ---=============================================================
			,Invlid_Item_Zero_PlanningCode as ( 
											select m.Item_Number,m.FamilyGroup,m.Primary_Supplier,m.Stocking_Type,m.Planning_Code 
											from JDE_DB_Alan.vw_Mast_Planning m 
											where m.Planning_Code in ('0') 
													and m.Primary_Supplier in ('506196','506197')	--be careful since under planning code 0, there are some other items which is not under '506196'/'506197', since need to put a filter on supplier, 11/12/2020
											  											
						)  
           --  select * from Invlid_Item_Zero_PlanningCode m			--- 1248 records

			---~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			--- Sanity Check to see what Items using 'exists' conditions !! - is result returned overlapping items ? - Yes !	--11/12/2020
			--,tbl_2 as (select * from tbl_1 where exists ( select i.Item_Number from Invlid_Item_Zero_PlanningCode i where tbl_1.fItemNum =i.Item_Number) )			 
			--select distinct tbl_2.fItemNum from tbl_2
			---~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

			---~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			--- Excludes Items using 'Not exists' conditions !!
			,tbl_2 as (select * from tbl_1 where not exists ( select i.Item_Number from Invlid_Item_Zero_PlanningCode i where tbl_1.fItemNum =i.Item_Number) )			 

			--,tbl as ( select t.*,m.Planning_Code,m.Planning_Code_Description 
			--		  from tbl_ t left join JDE_DB_Alan.vw_Mast_Planning m  on t.fItemNum = m.Item_Number 
			--		  where m.Planning_Code in ('1','2','3','4','5','6')				--- excludes '0' which is not planned by MRP
			--			)

			--select distinct tbl_2.fItemNum from tbl_2			--- yield 99,047 records/102,572 records ( 466 diff from 103,038 )
			---~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			--select * from tbl_2			--- yield 102,594 records ( 444 diff from 103,038 - all are cut length items( 20 SKUs roughly)  ie 44.003.105CL, 44.003.106CL with 'K' stock type but under 506196/506197etc.
			
			
			-- Alan Yao you have the choice to use tbl_1 or tbl_2 , up to you  ---
			--,tbl as ( select * from tbl_2 )
			  ,tbl as ( select * from tbl_1 )


			------ Then get your long description of selling group/family group/family which Nic wants ------
			,staging as 
			  (select  tbl.*
					,c.LongDescription as SellingGroup_
					,d.LongDescription as FamilyGroup_
					,e.LongDescription as Family_0
					--,tbl.Family as Family_1
					--,f.StandardCost,f.WholeSalePrice
			  from tbl left join JDE_DB_Alan.MasterSellingGroup c  on tbl.SellingGroup = c.Code
					 left join JDE_DB_Alan.MasterFamilyGroup d  on tbl.FamilyGroup = d.Code
					 left join JDE_DB_Alan.MasterFamily e  on tbl.Family = e.Code
			   )

			----- Then get your final Customerised Output ------
			--  select * from staging where staging.fItemNum in ('42.210.031')

			,z as  (
				select 'Total' as RowLabel,staging.SellingGroup_ as SellingGroup,staging.FamilyGroup_ as FamilyGroup,staging.Family_0 as Family
					--,staging.Family as fam,
					--staging.Family_1,
					,staging.fItemNum as ItemNum,staging.fShortItemNum as ShortItemNum,staging.Description
					--,cast(staging.Century as varchar(10))+ cast(staging.FinancialYear as varchar(10))+cast(staging.FinancialMonth as varchar(10)) as CYM
					,cast(staging.Century as varchar(10))+ cast(staging.Year as varchar(10)) as CY
					,staging.Century,staging.Year,staging.Month
					,case  
						 when staging.Month  >= 10  then format(staging.Month,'0') 
						 --else right('000'+cast(a.financialMonth as varchar(2)),3)  
						 when staging.Month  <10  then format(staging.Month,'00') 
					end as MM
					,'12' as PPY, '12' as PPC
					,staging.SalesQty,staging.StandardCost,staging.WholeSalePrice,SalesQty*StandardCost as InventoryVal, SalesQty*WholeSalePrice as SalesVal
				from staging

				)

			--select * from z
			--where z.ItemNum in ('42.210.031')
			--where StandardCost > WholeSalePrice
			--order by SalesVal desc
          

			  ----- Need to consolidate Sales History if there are one ItemNum but mulitple ShortItemNum ?--- After this operation you will lost your descriiption since for  one  item you might have 2 different description, to get ItemNum level data, you NEED aggregate and remove description level,your data set will only have this info--> Hierarchy/ItemNum/Year/Month/Qty
			,zz as (
				select z.RowLabel,z.SellingGroup,z.FamilyGroup,z.Family,z.ItemNum,concat(z.CY,z.MM) as CYM,z.CY,z.Century,z.Year,z.Month,z.PPY,z.PPC
				--,z.fam
				,sum(SalesQty) as SalesQty_,sum(z.InventoryVal) as InventoryVal_,sum(z.SalesVal) as SalesVal_
				from z 
			--where z.ItemNumber in ('8.51E+11') 
				  -- and z.Year in ('15') and z.month in ('1')
					-- and (z.Year + z.Month like '%20151')
				group by  z.RowLabel,z.SellingGroup,z.FamilyGroup,z.Family,z.ItemNum,concat(z.CY,z.MM),z.CY,z.Century,z.Year,z.Month,z.PPY,z.PPC
						--,z.fam
			  )

        --  select * from zz where zz.FinalItemNumber in ('26.802.659')

		 --------- To get your description from ML345 to join back your data set but First need to fix the ItemNumber with leading zero for ML345  ------

			 --- First fix Leading Zero for ML345 table --- This can be obsolete since this process has already been done ---
			 ,q as ( 
					select x.*,l.myItemNumber from JDE_DB_Alan.Master_ML345 x 
					left join l on x.ShortItemNumber = l.ShortItemNo 
					)			  
			,ml as ( select q.BU,
				   case 
					   when q.myItemNumber is null then q.ItemNumber
						else  q.myItemNumber		    
						end as fItemNumber
					,q.ShortItemNumber,q.description,q.SellingGroup,q.FamilyGroup,q.Family,q.Standardcost,q.WholeSalePrice					
					 from q )
               ---------------------------------------------------------
			,cte1 as (
					select ml.fItemNumber,ml.Description,ml.StandardCost,ml.WholeSalePrice
							,row_number() over(partition by ml.fitemnumber order by fitemnumber ) rn  
					from ml
			 )
			 ,cte as (
					 select * from cte1 
					 where rn = 1 )


			 --- Below will yield result for Combined MT + HD History Ready for Upload to Forecast Pro ---
		  , fl_ as (
			 select zz.RowLabel,zz.SellingGroup,zz.FamilyGroup,zz.Family,rtrim(ltrim(zz.ItemNum)) as ItemNumber_,cte.Description,cte.standardcost,cte.wholesaleprice,zz.CYM,zz.CY,zz.Month,zz.PPY,zz.PPC,zz.SalesQty_
			        --,zz.fam
			 from zz left join cte on zz.ItemNum = cte.fItemNumber
			 --  from zz inner join cte on zz.ItemNumber = cte.ItemNumber
			 -- where zz.CYM < cast(convert(varchar(6),getdate(),112) as int)				--- to exclude current month Sales --- 5/3/2018
			  where cast(zz.CYM as int) < cast(convert(varchar(6),getdate(),112) as int)				--- to exclude current month Sales --- 4/4/2018		
			       -- and zz.ItemNum in ('18.009.029')			 --- '18.009.029' has no sales last 12 month ---16/8/2018
			   )				

            --select * from fl  
			--select top 3 fl.* from fl 
			--where fl.ItemNumber_ in ('44.132.000')
			--order by fl.SellingGroup,fl.FamilyGroup,fl.Family,fl.ItemNumber_,fl.CYM		
			      
				--- Note full_ table -- sum(fl_.SalesQty_) is the sum of total history of last 36 months --- full_ table is same as fl_ but on aggregate level --- 16/8/2018
				--- Creation of this full_ table is only to help you to get Invlid list -- see below 
			,full_ as 
			       (  select fl_.ItemNumber_,count(fl_.cym) as SlsFrq_12m,sum(fl_.SalesQty_) as SlsQty_12m
						from fl_
						--where cast(myfl.CYM as int) >= replace(convert(varchar(8), DATEADD(mm, DATEDIFF(m,0,GETDATE())-13,0),126),'-','')		--- last 12 months						      
						group by fl_.ItemNumber_
						--having sum(myfl.SalesQty_) >0			--- filter out sales is less than 0
					)						
			--select * from ful			         
			
			--- Exception table which hold list of Item has no sales Activity over most recently 12 months --- 4/4/2018
			--- First Get SKU list which has sales activitiy in last 12 months ---You need to use combination of 'where' and 'having' condition to filter out
			--- You cannot simply change the 'having sum(fl_.SalesQty_) >0 ' to 'having sum(fl_.SalesQty_) =0' to get Invalid list !! -- Using 2nd below code to get your Invalid SKU list !! ---
			,Vlid as ( select fl_.ItemNumber_,count(fl_.cym) as SlsFrq_12m,sum(fl_.SalesQty_) as SlsQty_12m
						from fl_
						where cast(fl_.CYM as int) > replace(convert(varchar(8), DATEADD(mm, DATEDIFF(m,0,GETDATE())-13,0),126),'-','')		--- last 12 months						      
						group by fl_.ItemNumber_
						having sum(fl_.SalesQty_) >0			--- Filter out sales is less than 0   -- this is major change 
						)
                
              ---***************** Below is the Invalid SKU list which has No Sales activity last 12 month -- Logic applied here is Use ( Full list - Vlid List )  -- this is right way 16/8/2018 ************** -------
             ,Invlid as ( select full_.ItemNumber_ from full_ except select Vlid.ItemNumber_ from Vlid )                  -- except will treat Null as match  -- https://stackoverflow.com/questions/1662902/when-to-use-except-as-opposed-to-not-exists-in-transact-sql
			 ,_Invlid as ( select * 
								from Invlid i left join JDE_DB_Alan.vw_Mast m on i.ItemNumber_= m.ItemNumber)			
			
		--	select * from _Invlid order by _Invlid.ItemNumber_
			 
			 --- Manually Exclude Items which has no sales over last 12 months --- 5/4/2018 -- we should O or U all these SKUs in first place in JDE
			 ,fl as 
			 (
				 select * 
				 from fl_
				 --where myfl.ItemNumber_  in ( select Vlid.ItemNumber_ from Vlid)				--EXISTS is much faster than IN when the subquery results is very large.
				 --where myfl.ItemNumber_ not in ( select * from Invlid)						--IN is faster than EXISTS when the subquery results is very small.
		    
				  where  exists ( select * from Vlid  where Vlid.ItemNumber_ = fl_.ItemNumber_)			-- use exists -- good			5/4/2018
				 --where not exists ( select * from Invlid where myfl.ItemNumber_ = Invlid.ItemNumber_)		-- use not exists --- good		5/4/2018

				-- select * from full_

				--select * from Vlid
				--order by Vlid.SlsFrq_12m
				--where Vlid.ItemNumber_ in ('26.802.659','27.253.000','45.112.000') 
				       and fl_.CYM > cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-37,0),126),'-',''),1,6) as integer)	   --last 36 month to 201508  -- 14/9/2018

				 )
			   
			,myfl as (
						select fl.RowLabel,fl.SellingGroup,fl.FamilyGroup,fl.Family,fl.ItemNumber_ ,fl.Description,fl.CY,fl.Month,fl.PPY,fl.PPC
							,fl.CYM,fl.SalesQty_,fl.SalesQty_ as SalesQty_Adj_,'N' as ValidStatus_					--- 12/6/2020, reset every month  ( everything will rely on exception tbl )-  defaul Validstatus is 'N' , which means No it is not qualified Adjustment, you need to adjust sales history.
							,getdate() as ReportDate 
							,a.ShortItemNumber
								  -- ,fl.fam
						from fl left join JDE_DB_Alan.vw_Mast a on fl.ItemNumber_ = a.ItemNumber

					--where fl.ItemNumber_ in ('18.615.024')
					--  where fl.CYM < cast(convert(varchar(6),getdate(),112) as int)				--- to exclude current month Sales --- Move this filter up one step so all records extracted from this SP will be consistent with Px table -- 5/3/2018
					--where fl.CYM > cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-37,0),126),'-',''),1,6) as integer)	   --last 36 month to 201508  -- 14/9/2018
					)      
			
			 -- select * from myfl a									--- Total records 79,901 ( 5091 SKUs should have 5091* 36 = 180,000 records but many sku are slow moving and do not have sales every months ; - 3176 are C pareto, out of 3176 there are 1837 eligible for ROP ( less than 3 hits ) and among them 1220 ROP are for HD Planners	
				
				--where myfl.FamilyGroup is null					--- This is very good code to see & identify any field you have null value, since you put constraint in table definition and if you go to insert into table when you have null value you will be thrown with error like --> Cannot insert the value NULL into column 'SellingGroup', table 'JDE_DB_Alan.JDE_DB_Alan.Px_AWF_HD_MT_FCPro_upload'; column does not allow nulls. INSERT fails. --- 1/3/2018  --- The most important things here is how to identify which records cause insert fail and where is the null value as error message does not give enough clue like which row which line. So it begs the question is it worthvile to implement null value or not in table definition ?
				--where myfl.Family is null
				--select * from myfl where myfl.Family is null
				--where myfl_.ItemNumber in ('26.802.659','27.253.000','45.112.000') order by myfl.ItemNumber_,myfl.CYM
				--where myfl.ItemNumber_ in ('34.079.000')
				--where myfl.ItemNumber_ in ('7491700182')
				-- where a.ItemNumber_ in ('310200','42.210.031')
				-- order by a.ItemNumber_,a.CYM

				--where a.CYM in ('202003','202004','202005')			  --- 6092 records 
				--where a.CYM in ('201903','201904','201905')			  --- 6186  records 
				--where a.CYM not in ('202003','202004','202005')			--- 73,809 records ( 79901 - 6092 ), if excluding Covid period records in Year 2020


				---'select distinct list.ItemNumber_ from list								--- Do not use too slow
				---'where list.ItemNumber_  not in ( select excp.ItemNumber_ from excp )    --- Do not  use too slow			
				--where myfl_.ItemNumber_ in ('18.017.163')
				 --select top 3 myfl_.* from myfl _
				--select distinct myfl_.CYM  from myfl_ order by myfl_.CYM desc
				--delete from JDE_DB_Alan.SalesHistoryAWFHDMTuploadToFCPRO
				--select * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload 				
			
			
			---=================================== End of original 'sale upload ' code --> time taken is appox 12 sec =======================================================---
		
		
		
	  ---============================ Below is part for Rectify Covid period sales history 202003/202004/202005 ====================================---  20/4/2021
	                  --- it is like a big superssession ---- but not an easy one !
					  --- this can be removed in 2023 or automatically removed when you move to 2023 when your sales history will have no 2020 sales ( only 3 years are allowed ) ---


	                         ------ it will use MthCal table which I put at the very top of this programme ------
			
		  ---***** Important to join vw_Mast table here to get your shortItem number, so avoid system crash later if you join table use ItemNumber because Indexing is based on SHortItemNumber !!! --- 16/4/2021
			------ Get your unique SKU list ------
			,itm as ( 
			            -- select distinct h.ItemNumber as ItemNumber_,a.ShortItemNumber from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h left join JDE_DB_Alan.vw_Mast a on h.ItemNumber = a.ItemNumber			---5,127 records
						select distinct h.ItemNumber_ ,a.ShortItemNumber from myfl h left join JDE_DB_Alan.vw_Mast a on h.ItemNumber_ = a.ItemNumber			---5,127 records
						-- select distinct h.ItemNumber from JDE_DB_Alan.SlsHistoryHD h											    --- 8,864 records
						-- select distinct h.ItemNumber as ItemNumber_ ,h.ShortItemNumber from JDE_DB_Alan.SlsHistoryHD h			--- 8,939 records
						
						-- where h.CYM in ('201903','201904','201905','202003','202004','202005')			--- Not a good idea to put filter here 23/4/2021, why system run slow at here?
						
						 )
			
			---- Get your frame & skeleton with all months
			,mylist as ( select * from itm cross join MthCal )	
		 	  
			--select * from mylist m where m.ItemNumber_ in ('310200')	
			-- select * from mylist m where m.ItemNumber_ in ('34.252.000')
		 		  	     
			----------------- Padded Item with all Months --------------------		
		  

					--- below is tb padded Item with all Months ---
			,hist_Covid_19 as																													
			(  select   

						m.ItemNumber_,m.ShortItemNumber
				            
						,h.CYM
						,h.CY
						,case
								when h.CY is null then m.year
								else m.year
                          end as CY_2
									
						,case
								when h.Month is null then m.month
								else m.month
                          end as month_2
						,m.month_name
						,h.ReportDate
						,case when h.SalesQty_Adj_ is null then 0 else h.SalesQty_Adj_ end as _SalesQty_				
						,getdate() as ReportDate_												-- there is no different version of history, so do not bother to use old ReportData in History table UNLESS you need to join back to History table using ReportData as a key --- 5/9/2018
						,m.StartDt
						--,m.YY, m.rnk,m.month as mth						  
						,case 
							when h.CYM is null	then cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-',''),1,6) as integer) 		-- why use this ?						
							else h.CYM
						end as CYM_
						,case 
							when h.CYM is null	then m.StartDt					
							else h.CYM
						end as CYM_2
						,m.YY
						,m.rnk
						,h.SellingGroup,h.FamilyGroup,h.Family,h.Description
						

			    	--from list m left join JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h on m.StartDt2 = h.CYM and  m.ItemNumber_ = h.ItemNumber			--- old  6/8/2020
					--from mylist m left join JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h on m.StartDt = h.CYM and  m.ItemNumber_ = h.ItemNumber			--- new 7/8/2020
					from mylist m left join myfl h on m.StartDt = h.CYM and  m.ShortItemNumber = h.ShortItemNumber			--- new 7/8/2020
			     	where    
						--list.StartDt = cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-',''),1,6) as integer)			-- Watch out use List.StartDt Not h.CYM !!!   --- 29/5/2018
						-- h.CYM = '201804' and																													-- Performance issue ?
						--c.rnk =24																												-- last month ( for last month Sales)
					--where  m.StartDt <= cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-',''),1,6) as integer)    --- old 6/9/2020  
						-- m.rnk <= 36 and m.rnk >=1
						-- m.rnk < 37 and m.rnk > 24			--- last 12 month	
						-- m.rnk <= 36 and m.rnk >=12			--- recent 24 month, 201903 to 202103 
						-- m.rnk <= 27 and m.rnk >=12			--- distant 16 month, 201902 to 202107    isolate history for 2019 and 2020 (update 03/04/05 of 2020 sales using 2019 sales - leave 2021 history as is )
					
					  -- m.StartDt between 201903 and 202005	--- 16 months							--- hard coded to include Covid19 and pre Covid-19 period, use 16 months data slows down server performance it takes 3 mins to finish query
					   m.StartDt in ('201903','201904','201905','202003','202004','202005')				--- 23/4/2021,this boost performance significantly

					)
              
			,_t as (						
					  select a.*
					   ,case
						 when a.month_2 = 3 and a.CYM_2 = 202003 then 201903			-- Critical !! ( not another way around to 'Then 2020 ... ). This is used for join purpose ( hard coded);better ( alternative) way to do that is by create 2 table - padded with 0 if there is no sales ( 1 with only 3 months 201903/201904/201905, 1 with 202003/202004/202005 and join by month (3/4/5 ) & ItemNumber)
						 when a.month_2 = 4 and a.CYM_2 = 202004 then 201904
						 when a.month_2 = 5 and a.CYM_2 = 202005 then 201905
					  else 0
						 end as CYM_stag 
					  from hist_Covid_19 a 
					  where 
						 -- a.month_2 in ('3','4','5')
						   a.CYM_2 in ('201903','201904','201905','202003','202004','202005')
					    -- and  a.ItemNumber_ in ('310200','34.008.000','42.210.031')	
						 -- and  a.ItemNumber_ in ('310200')			
					  --order by a.ItemNumber_,a.rnk
					  )
					

           ,t_ as 
				( select t1.*
						,t2._SalesQty_ as Qty_stag_Yr_2019																--- Critical !!  YOu need to choose qty from t2 not t1 to get 2020 qty !
					from _t t1 left join _t as t2 on t1.ShortItemNumber = t2.ShortItemNumber and t1.CYM_stag = t2.CYM_2
					)
           --select * from t_ a where a.ItemNumber_ in ('42.210.031') order by a.ItemNumber_,a.CYM_2

		
		      --- Get your replacement value for Covid-19 period 202003/202004/202004 using 201903/201904/201905 sales
		   ,t as ( select 
					--a.*
					a.ItemNumber_,a.ShortItemNumber
					,a.SellingGroup,a.FamilyGroup,a.Family,a.Description
					,a.CY_2,a.month_2,'12' as PPY,'12' as PPC,a.CYM_2,a._SalesQty_
					,case 
					   when a._SalesQty_ >= a.Qty_stag_Yr_2019 then a._SalesQty_
					   when a._SalesQty_ < a.Qty_stag_Yr_2019 then a.Qty_stag_Yr_2019
					 else 0              
					 end as Final_Sales_Qty_Covid_adj
				 
				  from t_ a --left join JDE_DB_Alan.vw_Mast b on a.ShortItemNumber = b.ShortItemNumber
				  where a.Qty_stag_Yr_2019 is not null
				  
				     )

		   -- select * from t a
		   -- where a.ItemNumber_ in ('310200')
		   -- order by a.ItemNumber_,a.CY_2,a.month_2


		   --- Now get your Original 'SlsHist_AWFHDMT_FCPro_upload' table after normal 'sales_adj ' --- Need to filter out records which has  month 202003/202004/202005 First, then join back new records for 202003/202004/202005 
           ,tb as ( select *														--- Total records 79,901 ( 5091 SKUs should have 5091* 36 = 180,000 records but many sku are slow moving and do not have sales every months ; - 3176 are C pareto, out of 3176 there are 1837 eligible for ROP ( less than 3 hits ) and among them 1220 ROP are for HD Planners	
					from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload a					
					where a.CYM not in ('202003','202004','202005')					--- 74,131 records	
					) 
             
          
		    --- Covid Exception period --- 202003, 202004,202005  --- this is for debug purpose
		   ,tb_excp as ( 
					select *														--- Total records 79,901 ( 5091 SKUs should have 5091* 36 = 180,000 records but many sku are slow moving and do not have sales every months ; - 3176 are C pareto, out of 3176 there are 1837 eligible for ROP ( less than 3 hits ) and among them 1220 ROP are for HD Planners	
					from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload a

					where a.CYM in ('202003','202004','202005')			  --- 6092 records 
					--where a.CYM in ('201903','201904','201905')			  --- 6186  records 
					--where a.CYM not in ('202003','202004','202005')			--- 73,809 records ( 79901 - 6092 ), if excluding Covid period records in Year 2020

					--where a.CYM not in ('202003','202004','202005')					--- 74,131 records						
					)

 
           ,tb_Covid_adj as 
		      ( 
			    select 'Total' as RowLabel
				       ,t.SellingGroup,t.FamilyGroup,t.Family,t.ItemNumber_,t.Description
					   ,t.CY_2 ,t.month_2,t.PPY,t.PPC,t.CYM_2,t._SalesQty_,t.Final_Sales_Qty_Covid_adj
					   ,'N' as ValidStatus_	
					   ,getdate() as ReportDate
				from t

			     )

          ,comb as 
		     ( select * from tb
			    union all
              select * from tb_Covid_adj
			  )

			
			--select * from comb a												--- total 88,558 records if include Covid-19 consideration; takes about 2'15"
																				--- total 88,558 records if include Covid-19 consideration; takes about 1'22" if reduce number of records when join table to get 'hist' table
			--where a.ItemNumber in ('310200','34.008.000','42.210.031')	
			--order by a.ItemNumber,a.CYM

			-- Then Use Insert or delete old 'JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload a' table ??
			-- Or when initially update 'JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload a' table, filter out Covid month records ( 202003/202004/202005 ) ??



			--- Need to update Px sp as well (  content update & also to ensure same structure )	
			
			
			
			
			--insert into JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload  select * from myfl
			insert into JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload  select * from comb								--> time taken is appox 2'12" sec
			select * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload
			

END


GO


