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
/****** Object:  StoredProcedure [JDE_DB_Alan].[sp_FCPRO_Px_upload]    Script Date: 5/11/2018 10:32:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [JDE_DB_Alan].[sp_FCPRO_Px_upload]
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
	-------------------------------  MT History     25/10/2017 ------------------------------------------------------

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
			 delete from JDE_DB_Alan.Px_AWF_HD_MT_FCPro_upload

			;with l as ( select y.*,
							case 
							   when y.ItemWithLeadingZero ='Y' then '0'+ y.ItemNumber
								else  y.ItemNumber		    
							   end as myItemNumber
						 from JDE_DB_Alan.MasterMTLeadingZeroItemList y
      
				  )

			--- get stocking type ---
			 ,t as (
					  select a.*,x.StockingType 
					  from JDE_DB_Alan.SlsHistoryMT a left join JDE_DB_Alan.Master_ML345 x
						   on a.ShortItemNumber = x.ShortItemNumber 
					  )
             -- select * from t where t.ItemNumber in ('26.802.659T')

			,m as ( 
					select t.*,l.myItemNumber
						   ,case when l.myItemNumber is null then t.ItemNumber
							   --else t.ItemNumber			-- Mistake 6/11/2017
							     else l.myItemNumber
							end as fItemNumber
					from t left join l on t.ShortItemNumber = l.ShortItemNo 
					--where  t.ShortItemNumber in ('1218124','159804') 
							--and concat(t.Century,t.FinancialYear,t.FinancialMonth) = '201512'
					)            
			
			--select * from m where m.myItemNumber is null
			--select * from m 
			--where m.ShortItemNumber in ('1218124','159804') and concat(m.Century,m.FinancialYear,m.FinancialMonth) = '201512'
			--order by m.Century,m.FinancialYear,m.FinancialMonth

			,_tb as ( select m.bu,m.ShortItemNumber,m.fItemNumber
			   --    case 
				  --     when m.myItemNumber is null then m.ItemNumber
					 --   else  m.myItemNumber		    
						--end as fItemNumber,
					,m.Century,m.FinancialYear,m.FinancialMonth,m.DocumentType,m.Quantity,m.UOM,m.StockingType					
					 from m
				 )
			--select * from _tb 

  			--- Superssion for Bricos Item --- do superssion first, then if there is any U items ( which need to be superseded, can leave filter U later ) otherwise if you not have history for superseded items -- 6/3/2018
			  ,tb_ as (
				select _tb.*,b.NewItemNumberHD,b.NewShortItemNumberHD
				from _tb 
					 left join JDE_DB_Alan.MasterMTSuperssionItemList b on _tb.fItemNumber = b.CurrentItemNumberMT   
				--where _tb.StockingType in ('P','S')					-- leave the task of pick up StockingType to later stage   -- 7/3/2018
				   --   and a.ItemNumber in ('28.380.108')
				)

				
			  ,mt as (select case 
					   when tb_.BU ='MT' then 'HD'
						else  'HD'		    
						end as BU
					,case  
					  when tb_.NewShortItemNumberHD is null then tb_.ShortItemNumber
						else tb_.NewShortItemNumberHD 
						end as FinalShortItemNumber
				   , case 
					   when tb_.NewItemNumberHD is null then tb_.fItemNumber
						else tb_.NewItemNumberHD 
						end as FinalItemNumber
					,tb_.Century,tb_.FinancialYear,tb_.FinancialMonth,tb_.DocumentType,tb_.Quantity,tb_.UOM
		
			 from tb_ )

			 --select * from mt  where mt.FinalItemNumber in ('26.802.659T')
			 --select * from JDE_DB_Alan.SalesHistoryHD a
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
			,cb as (		
					select * from mt
					union all
					select * from hd 
				 )

			-- select * from cb

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
					select BU,FinalItemNumber as ItemNum,cb.FinalShortItemNumber as ShortItemNum,cb.Century,cb.FinancialYear,cb.FinancialMonth,cb.UOM,sum(cb.Quantity) as Quantity
					 --from JDE_DB_Alan.SalesHistoryAWFHDMT a 
					 from cb
					 group by BU,FinalItemNumber,cb.FinalShortItemNumber,cb.Century,cb.FinancialYear,cb.FinancialMonth,cb.UOM
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
							  ,case  
							        when sup.ConversionRate_UOM is null then con.Quantity
									when sup.ConversionRate_UOM = 1 then con.Quantity							        
									when sup.ConversionRate_UOM <> 1 then con.Quantity/sup.ConversionRate_UOM
									 end as fQuantity	
                              ,sup.ValidStatus 

						from con left join sup_list sup on con.ShortItemNum = sup.CurrentShortItemNumber		-- join by ShortItemNumber
					  --from con left join JDE_DB_Alan.MasterSuperssionItemList sup on con.ShortItemNum = sup.CurrentShortItemNumber		-- join by ShortItemNumber						  	
						   --where sup.ValidStatus = 'Y'					--- Check the status 8/6/2018 -- You cannot put condition here otherwise you will filter out all 'null' value in 'ValidStatus' column, rather you better start with a new temp table -- 'sup_list', check above code in line 196 for 'sup_list'
						)	
										
             -- select * from _sp where _sp.ItemNum in ('26.802.659','26.802.659T','27.253.000')
			  --select * from _sp where _sp.ItemNum in ('6000130009001H','6000130009001','27.253.000')

			  ------ Group data together by ItemNumber/Month after superssion ------
			  ,sp as (select _sp.fItemNum,_sp.fShortItemNum,_sp.Century,_sp.Year,_sp.Month,_sp.UOM,sum(isnull(_sp.fQuantity,0)) as Qty
						 from _sp
						 group by _sp.fItemNum,_sp.fShortItemNum,_sp.Century,_sp.Year,_sp.Month,_sp.UOM
						)
					-- select * from sp_ where sp_.fItemNum in ('26.802.659','26.802.659T','27.253.000') 
					-- order by sp_.fItemNum,sp_.Century,sp_.Year,sp_.Month
               
         
			 ------ First to get rough selling group/family group/family info from R55ML345 Table,also Select ALL SKUs with right Stocking type so that Obsolete /phase out Product does not generate FC - Can ERP do this job ??  22/2/2018 ---------
			   --- the reason to do join of Hierarchy is it can take advantage of ShortItemNumber since it is unique ---

			,tbl as (
			   select x.BU,sp.fItemNum
					,sp.fShortItemNum		
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
               where x.StockingType not in ('O','U')				--- Filter out U / O stocking type -- Important so No FC generated for these SKUs - 22/2/2018
			     --  where mm.StockingType in ('O','K','W','X','S','F','P','U','Q','Z','C','M','0','I')			
				 --  where mm.StockingType in ('K','W','X','S','F','P','Q','Z','C','M','0','I')			   -- this could be best to avoid issue of returning empty dataSet due to Null value --- 23/7/2018											
				--where a.ItemNumber in ('27.161.135') 
				   )
			--select * from tbl	  

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
			--  select * from staging where staging.ItemNumber in ('27.161.135')

			,z as  (
				select 'Total' as RowLabel,staging.SellingGroup_ as SellingGroup,staging.FamilyGroup_ as FamilyGroup,staging.Family_0 as Family,
					--staging.Family_1,
					staging.fItemNum as ItemNum,staging.fShortItemNum as ShortItemNum,staging.Description
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
			--where z.FinalItemNumber in ('26.802.659','26.802.659T')
			--where StandardCost > WholeSalePrice
			--order by SalesVal desc
          

			  ----- Need to consolidate Sales History if there are one ItemNum but mulitple ShortItemNum ?--- After this operation you will lost your descriiption since for  one  item you might have 2 different description, to get ItemNum level data, you NEED aggregate and remove description level,your data set will only have this info--> Hierarchy/ItemNum/Year/Month/Qty
			,zz as (
				select z.RowLabel,z.SellingGroup,z.FamilyGroup,z.Family,z.ItemNum,concat(z.CY,z.MM) as CYM,z.CY,z.Century,z.Year,z.Month,z.PPY,z.PPC,sum(SalesQty) as SalesQty_,sum(z.InventoryVal) as InventoryVal_,sum(z.SalesVal) as SalesVal_
				from z 
			--where z.ItemNumber in ('8.51E+11') 
				  -- and z.Year in ('15') and z.month in ('1')
					-- and (z.Year + z.Month like '%20151')
				group by  z.RowLabel,z.SellingGroup,z.FamilyGroup,z.Family,z.ItemNum,concat(z.CY,z.MM),z.CY,z.Century,z.Year,z.Month,z.PPY,z.PPC
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
			   )				

            --select * from fl  
			--select top 3 fl.* from fl 
			--where fl.ItemNumber_ in ('44.132.000')
			--order by fl.SellingGroup,fl.FamilyGroup,fl.Family,fl.ItemNumber_,fl.CYM		
			      
			
			,full_ as 
			       (  select fl_.ItemNumber_,count(fl_.cym) as SlsFrq_12m,sum(fl_.SalesQty_) as SlsQty_12m
						from fl_
						--where cast(myfl.CYM as int) >= replace(convert(varchar(8), DATEADD(mm, DATEDIFF(m,0,GETDATE())-13,0),126),'-','')		--- last 12 months						      
						group by fl_.ItemNumber_
						--having sum(myfl.SalesQty_) >0			--- filter out sales is less than 0
					)						
			--select * from ful			         
			
			--- Exception table which hold list of Item has no sales Activity over most recently 12 months --- 4/4/2018
			,Vlid as ( select fl_.ItemNumber_,count(fl_.cym) as SlsFrq_12m,sum(fl_.SalesQty_) as SlsQty_12m
						from fl_
						where cast(fl_.CYM as int) >= replace(convert(varchar(8), DATEADD(mm, DATEDIFF(m,0,GETDATE())-13,0),126),'-','')		--- last 12 months						      
						group by fl_.ItemNumber_
						having sum(fl_.SalesQty_) >0			--- filter out sales is less than 0
						)

             ,Invlid as ( select full_.ItemNumber_ from full_ except select Vlid.ItemNumber_ from Vlid )                  -- except will treat Null as match  -- https://stackoverflow.com/questions/1662902/when-to-use-except-as-opposed-to-not-exists-in-transact-sql

			 -- select * from Invlid order by Invlid.ItemNumber_

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
					select fl.RowLabel,fl.SellingGroup,fl.FamilyGroup,fl.Family,fl.ItemNumber_,fl.Description,fl.CY,fl.Month,fl.PPY,fl.PPC,fl.SalesQty_,fl.CYM,getdate() as ReportDate 
					      -- ,fl.fam
					from fl
					--where fl.ItemNumber_ in ('18.615.024')
					--  where fl.CYM < cast(convert(varchar(6),getdate(),112) as int)				--- to exclude current month Sales --- Move this filter up one step so all records extracted from this SP will be consistent with Px table -- 5/3/2018
					--where fl.CYM > cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-37,0),126),'-',''),1,6) as integer)	   --last 36 month to 201508  -- 14/9/2018
					)      
			
			   --select * from myfl
				--where myfl.FamilyGroup is null					--- This is very good code to see & identify any field you have null value, since you put constraint in table definition and if you go to insert into table when you have null value you will be thrown with error like --> Cannot insert the value NULL into column 'SellingGroup', table 'JDE_DB_Alan.JDE_DB_Alan.Px_AWF_HD_MT_FCPro_upload'; column does not allow nulls. INSERT fails. --- 1/3/2018  --- The most important things here is how to identify which records cause insert fail and where is the null value as error message does not give enough clue like which row which line. So it begs the question is it worthvile to implement null value or not in table definition ?
				--where myfl.Family is null
				--select * from myfl where myfl.Family is null
				--where myfl_.ItemNumber in ('26.802.659','27.253.000','45.112.000') order by myfl.ItemNumber_,myfl.CYM

				---'select distinct list.ItemNumber_ from list								--- Do not use too slow
				---'where list.ItemNumber_  not in ( select excp.ItemNumber_ from excp )    --- Do not  use too slow			
				--where myfl_.ItemNumber_ in ('18.017.163')
				 --select top 3 myfl_.* from myfl _
				--select distinct myfl_.CYM  from myfl_ order by myfl_.CYM desc
				--delete from JDE_DB_Alan.SalesHistoryAWFHDMTuploadToFCPRO

				
			--insert into JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload  select * from myfl
			--select * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload
						

		--------------------------- To Get Your Price Conversion table --------------------------
		,flpri as ( select fl.RowLabel,fl.SellingGroup,fl.FamilyGroup,fl.Family,fl.ItemNumber_,fl.StandardCost,fl.WholeSalePrice
						  ,row_number() over(partition by fl.itemnumber_ order by itemnumber_) as rn,GETDATE() as ReportDate
					from fl
					)

         --select * from flpri 
		-- where flpri.ItemNumber_ in ('2801382551')
		-- where flpri.SellingGroup is null					--- This is very good code to see & identify any field you have null value, since you put constraint in table definition and if you go to insert into table when you have null value you will be thrown with error like --> Cannot insert the value NULL into column 'SellingGroup', table 'JDE_DB_Alan.JDE_DB_Alan.Px_AWF_HD_MT_FCPro_upload'; column does not allow nulls. INSERT fails. --- 1/3/2018  --- The most important things here is how to identify which records cause insert fail and where is the null value as error message does not give enough clue like which row which line. So it begs the question is it worthvile to implement null value or not in table definition ?
		
		insert into JDE_DB_Alan.Px_AWF_HD_MT_FCPro_upload select * from flpri where flpri.rn =1
		
		update px
		set px.WholeSalePrice = ( case 
		                                when px.WholeSalePrice >9998 then 1
										when px.WholeSalePrice = 0 or px.WholeSalePrice is null then
											(case 
													when px.StandardCost=0 or px.StandardCost is null then 0.01
													else px.StandardCost 
													end)							 
										else px.WholeSalePrice
										end )
			,px.StandardCost= ( case 
										when px.StandardCost = 0 or px.StandardCost is null then
											(case 
													when px.WholeSalePrice=0 or px.WholeSalePrice is null then 0.01
													else px.WholeSalePrice 
													end)							 
										else px.StandardCost
										end )
			--,p.Description =( case 
			--						 when CHARINDEX(',',p.Description) >0 then REPLACE(p.Description,',','/')
			--							 else p.Description
			--							 end )
								 										
		from JDE_DB_Alan.Px_AWF_HD_MT_FCPro_upload px

		select * from JDE_DB_Alan.Px_AWF_HD_MT_FCPro_upload
END
