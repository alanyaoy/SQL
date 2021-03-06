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
/****** Object:  StoredProcedure [JDE_DB_Alan].[sp_Z_Vendor_FC_Report]    Script Date: 11/05/2021 3:31:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE  [JDE_DB_Alan].[sp_Z_Vendor_FC_Report]  
	-- Add the parameters for the stored procedure here
	--<@Param1, sysname, @p1> <Datatype_For_Param1, , int> = <Default_Value_For_Param1, , 0>, 
	--<@Param2, sysname, @p2> <Datatype_For_Param2, , int> = <Default_Value_For_Param2, , 0>

	----- This Store Procedure Extract forecast for particular supplier ( at beginning of One month )  --- 7/10/2020
	----- with Vendor item XRef 

	--- Is this Robust way to refresh View in SQL Server ? --- At least you need to implement Schemabinding in View !



	 --- 17/5/2018 ---
	 -- @Item_id varchar(8000) = null
	  @Supplier_id varchar(8000) = null	 
	-- ,@DataType varchar (100) = null
	--,@ItemNumber varchar(100) = null
	--,@ShortItemNumber varchar(100) = null
	--,@CenturyYearMonth int = null
	--,@OrderByClause varchar(1000) = null
	--,@dt datetime  = DATEADD(mm, DATEDIFF(m,0,GETDATE())+5,0)			-- does not work
	 -- ,@dt datetime = null
	 ,@FCSaveTime_id varchar(100) = null
	 , @Columns AS NVARCHAR(MAX) = null
	  ,@sql     NVARCHAR(MAX) = ''



	  --- 14/10/2020 --- works Year, use Dynamic Year/Month for Pivot data !!!

AS

 BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	--SELECT <@Param1, sysname, @p1>, <@Param2, sysname, @p2>

	--select  cast(DATEADD(mm, DATEDIFF(mm, 0, GETDATE())-1, 0) as datetime)				--- Last Month



	
	----- Forecast for 1102 - Qmotion ----- current month
	--select * from JDE_DB_Alan.vw_FC f where f.ItemNumber in ('34.306.000')
	
	--select * from JDE_DB_Alan.vw_FC_Hist f 		
				--inner join ( select fh.ItemNumber,max(fh.reportdate) Max_dt from JDE_DB_Alan.vw_FC_Hist fh group by fh.ItemNumber) a on f.ItemNumber = a.ItemNumber and f.ReportDate = a.Max_dt
			-- where f.ItemNumber = ('34.306.000')	
			 
	--select * from JDE_DB_Alan.Master_Vendor_Item_CrossRef v where v.ItemNumber in ('34.306.000')
	--select * from JDE_DB_Alan.vw_Mast_Vendor_Item_CrossRef v where v.ItemNumber in ('34.306.000')		--- use View table, otherwise you will have duplicate records if you use Original Xref table !

	--select f.*,m.Description,m.UOM,m.PrimarySupplier
	--from JDE_DB_Alan.vw_FC f left join JDE_DB_Alan.vw_Mast m on f.ItemNumber = m.ItemNumber
	--	 left join JDE_DB_Alan.vw_Mast_Vendor_Item_CrossRef v on f.ItemNumber = v.ItemNumber    
	--where m.PrimarySupplier in ('1102')
		 -- and f.ItemNumber in ('34.363.000')


	----- Forecast for 1102 - Qmotion ----- one month old
	
	--select a.*,m.Description,m.UOM,m.PrimarySupplier
	
  	  --- 1.  If Supplier is provided, FC Saving Time is provided with to require Last month FC  ---
   if  @Supplier_id is not null and @FCSaveTime_id = 'M-1'			-- last month saved fc
     
	 begin 

      	with tb as 
		  (

			select a.ItemNumber as HD_Item_Number,v.Customer_Supplier_ItemNumber as Vendor_Item_Number,m.Description,m.UOM
				   ,a.myDate2 as FC_Date,a.FC_Vol as FC_Quantity,a.ReportDate,m.PrimarySupplier,m.PlannerNumber,m.Owner_
			from  (

								select fh.*,fh.myDate1 as FCDate_
									 from JDE_DB_Alan.vw_FC_Hist fh												-- Need to Get Last month Saved FC data -- 14/9/2018
									 where fh.myReportDate2 = cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-',''),1,6) as integer)	
										   and	fh.Date	> DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0) 		-- since using last month data, so need to push out fc 1 month --- 6/12/2018
										   and fh.Date  <  DATEADD(mm, DATEDIFF(m,0,GETDATE())+12,0) 	-- only provide 12 month fc, but need to add 1 since you push out 1 month7/10/2020
							 
										 --and fh.ItemNumber in ('34.306.000')
					   ) a left join JDE_DB_Alan.vw_Mast m on a.ItemNumber = m.ItemNumber
					   left join JDE_DB_Alan.vw_Mast_Vendor_Item_CrossRef v on a.ItemNumber = v.ItemNumber 
		
			--where m.PrimarySupplier in ('1102')
			 where m.PrimarySupplier in  ( select * from string_split(@Supplier_id,','))
				   and a.DataType1 = 'Adj_FC'	

			-- order by m.PrimarySupplier,a.ItemNumber,a.myDate2
	     
		    )

			 -- select * from tb where tb.HD_Item_Number in ('34.306.000')


			---=======================	
			--- Transform your data --- 
			---=======================
			--- Get Preparation to Pivot Data using SQL --- It is better to use Numbwe Array ([1],[2],[3] ) instead of ([201807],[201808],[201809]) as it is more versatile and flexible to avoid hard coding --- 25/7/2018
			--;with
			,R(N,_T,T_,T,XX,YY,start) AS
						(
						 select 1 as N,-24 as _T,24 as T_,-23 as T,24 as XX,24 as YY,cast(DATEADD(mm, DATEDIFF(mm, 0, GETDATE())-24, 0) as datetime) as start      -- pay attention T starts -23,you need this so you can get XXX Column/Field in current month you start as 1, otherwise you can use XX field
						 UNION ALL
						 select  N+1, _T+1,T_-1,case when T+1<0 then T+1 else case when T+1 =0 then 1 else T+1 end end as T						
												,case when N >= 24  then _T+1
												   else  
													   XX-1
													end as XX
												 ,case when N >= 24  then T							     
												   else  
													   YY-1
													end as YY
								 ,dateadd(mm,1,start)
						  from R
						 where N < 49
						)
					--select * from r
					--select R.N,case when R._T < 0 then R.T_ else R._T end as T, start from R
					--select R.N,case when R._T < 0 then R.T_ else R.YY end as T, start from R
			      ,MthCal as (
									select  n as rnk
									 ,YY
									,_T
									,cast(SUBSTRING(REPLACE(CONVERT(char(10),start,126),'-',''),1,6) as integer) as [StartDt]		
									,LEFT(datename(month,start),3) AS [month_name]
									,datepart(month,start) AS [month]
									,datepart(year,start) AS [year]				
								   from R  )
				-- select * from MthCal

				---=====================================================================================================================================
			   --- Need to Pivot data to display in Horizontal way --- Need to think it to join Calendar table ( with integer t number ) rather using [201808],[201809] instead using [1],[2] to speed up execution time,also to avoid hard coding !
			   ---=====================================================================================================================================	
			   ,_fcst as ( select f.HD_Item_Number,f.Description,f.Vendor_Item_Number,f.UOM,f.PrimarySupplier,f.PlannerNumber,f.Owner_
								,f.FC_Date,f.FC_Quantity as value,f.ReportDate							
								,c.*																				--- join cal to get YY value which is your month rank/order
				    
						from tb f left join MthCal c on f.FC_Date = c.StartDt												--- no need to cross join cal table as FC tb always has data in 24 mth				
					  -- where fc.ItemNumber = ('42.210.031') order by fc.ItemNumber,fc.StartDt,fc.Date
						)
				
              -- select * from _fcst  f where f.HD_Item_Number in ('34.306.000')			--- 29/1/2020

			   ---====================
			   --- Output ---
			   ---====================


			    --,tb_YM as ( select distinct f.FC_Date as YM from _fcst f ) 	  
			

			select f.HD_Item_Number,f.Description,f.Vendor_Item_Number,f.UOM,f.PrimarySupplier,f.PlannerNumber,f.Owner_,f._T,f.value,f.FC_Date as YM
				into #fct from _fcst f 
			    
			    SELECT  @Columns = ISNULL(@Columns + ',','')+ QUOTENAME([YM]) 
							FROM (select distinct #fct.YM as YM  from #fct ) as tb_YM



			    --set @sql = ' select *
							-- from
							--	(select f.HD_Item_Number,f.Description,f.Vendor_Item_Number,f.UOM,f.PrimarySupplier,f.PlannerNumber,f.Owner_,f.YM,f.value  from #fct f ) as sourcetb

							-- pivot 
						 --      ( sum(value) for YM in ('+ @Columns +') 
							--	) as p		
							--';

				set @sql = ' select *
						from
						(select f.HD_Item_Number,f.Description,f.Vendor_Item_Number,f.UOM,f.YM,f.value  from #fct f ) as sourcetb

						pivot 
						( sum(value) for YM in ('+ @Columns +') 
						) as p		
					';

				EXECUTE sp_executesql @sql;

				drop table #fct ;


				--- =======================
				--- Old way to Pivot data ---
				--- =======================

			 --  -- select * from fcst_ f order by f.ItemNumber_f					-- Testing --> this is good testing point
			 -- ,mypvt as 
				--	( select *
				--		 from 
				--				( select f.HD_Item_Number,f.Description,f.Vendor_Item_Number,f.UOM,f.PrimarySupplier,f.PlannerNumber,f.Owner_,f._T,f.value  from _fcst f  ) as sourcetb
    --                     pivot 
				--		       ( sum(value) for _T in ( [0],[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11]) 
				--				) as p								
				--	)
				
				
				--select pv.HD_Item_Number
				--       ,pv.Vendor_Item_Number
				--	   ,pv.Description
				--	   ,pv.UOM

					   
				--	   ,isnull(pv.[0],0) [0]
				--	   ,isnull(pv.[1],0) [1]
				--	   ,isnull(pv.[2],0) [2]
				--	   ,isnull(pv.[3],0) [3]
				--	   ,isnull(pv.[4],0) [4]
				--	   ,isnull(pv.[5],0) [5]
				--	   ,isnull(pv.[6],0) [6]
				--	   ,isnull(pv.[7],0) [7]
				--	   ,isnull(pv.[8],0) [8]
				--	   ,isnull(pv.[9],0) [9]
				--	   ,isnull(pv.[10],0) [10]
				--	   ,isnull(pv.[11],0) [11]
				--	   , getdate() as LastUpdated

				-- from mypvt pv
				---- where pv.HD_Item_Number in ('34.306.000')				
				----where pv.ItemNumber_f is null
				-- order by pv.HD_Item_Number	
				
					 
	  end

	  --- 2.  If Supplier is provided ,FC Saving Time is provided with to require current month FC  ---
	else if   @Supplier_id is not null and @FCSaveTime_id = 'M+0'			-- current month saved fc
	  
	   begin
	     -- select * from JDE_DB_Alan.vw_Mast m where m.ItemNumber in ('42.210.031')

		 with tb as 
			  (
				 select a.ItemNumber as HD_Item_Number,v.Customer_Supplier_ItemNumber as Vendor_Item_Number,m.Description,m.UOM
					  ,a.FCDate2_ FC_Date,a.FC_Vol as FC_Quantity,a.ReportDate,m.PrimarySupplier,m.PlannerNumber,m.Owner_
					
					from  JDE_DB_Alan.vw_FC a left join JDE_DB_Alan.vw_Mast m on a.ItemNumber = m.ItemNumber
							   left join JDE_DB_Alan.vw_Mast_Vendor_Item_CrossRef v on a.ItemNumber = v.ItemNumber 
		
					--where m.PrimarySupplier in ('1102')
					 where m.PrimarySupplier in  ( select * from string_split(@Supplier_id,','))	
					     and a.DataType1 = 'Adj_FC'	
						  and	(a.Date	between DATEADD(mm, DATEDIFF(m,0,GETDATE()),0) and  DATEADD(mm, DATEDIFF(m,0,GETDATE())+11,0) )   --- get 12 month fc							 

					-- order by m.PrimarySupplier,a.ItemNumber,a.FCDate2_

	           )

	       	 -- select * from tb where tb.HD_Item_Number in ('34.306.000')


			---=======================	
			--- Transform your data --- 
			---=======================
			--- Get Preparation to Pivot Data using SQL --- It is better to use Numbwe Array ([1],[2],[3] ) instead of ([201807],[201808],[201809]) as it is more versatile and flexible to avoid hard coding --- 25/7/2018
			--;with
			,R(N,_T,T_,T,XX,YY,start) AS
						(
						 select 1 as N,-24 as _T,24 as T_,-23 as T,24 as XX,24 as YY,cast(DATEADD(mm, DATEDIFF(mm, 0, GETDATE())-24, 0) as datetime) as start      -- pay attention T starts -23,you need this so you can get XXX Column/Field in current month you start as 1, otherwise you can use XX field
						 UNION ALL
						 select  N+1, _T+1,T_-1,case when T+1<0 then T+1 else case when T+1 =0 then 1 else T+1 end end as T						
												,case when N >= 24  then _T+1
												   else  
													   XX-1
													end as XX
												 ,case when N >= 24  then T							     
												   else  
													   YY-1
													end as YY
								 ,dateadd(mm,1,start)
						  from R
						 where N < 49
						)
					--select * from r
					--select R.N,case when R._T < 0 then R.T_ else R._T end as T, start from R
					--select R.N,case when R._T < 0 then R.T_ else R.YY end as T, start from R
			      ,MthCal as (
									select  n as rnk
									 ,YY
									,_T
									,cast(SUBSTRING(REPLACE(CONVERT(char(10),start,126),'-',''),1,6) as integer) as [StartDt]		
									,LEFT(datename(month,start),3) AS [month_name]
									,datepart(month,start) AS [month]
									,datepart(year,start) AS [year]				
								   from R  )
				-- select * from MthCal

				---=====================================================================================================================================
			   --- Need to Pivot data to display in Horizontal way --- Need to think it to join Calendar table ( with integer t number ) rather using [201808],[201809] instead using [1],[2] to speed up execution time,also to avoid hard coding !
			   ---=====================================================================================================================================	
			   ,_fcst as ( select f.HD_Item_Number,f.Description,f.Vendor_Item_Number,f.UOM,f.PrimarySupplier,f.PlannerNumber,f.Owner_
								,f.FC_Date,f.FC_Quantity as value,f.ReportDate							
								,c.*																				--- join cal to get YY value which is your month rank/order
				    
						from tb f left join MthCal c on f.FC_Date = c.StartDt												--- no need to cross join cal table as FC tb always has data in 24 mth				
					  -- where fc.ItemNumber = ('42.210.031') order by fc.ItemNumber,fc.StartDt,fc.Date
						)
				
              -- select * from _fcst  f where f.HD_Item_Number in ('34.306.000')			--- 29/1/2020

			   ---====================
			   --- Output ---
			   ---====================


			    --,tb_YM as ( select distinct f.FC_Date as YM from _fcst f ) 	  
			

			   select f.HD_Item_Number,f.Description,f.Vendor_Item_Number,f.UOM,f.PrimarySupplier,f.PlannerNumber,f.Owner_,f._T,f.value,f.FC_Date as YM
				into #fctt from _fcst f 
			    
			    SELECT  @Columns = ISNULL(@Columns + ',','')+ QUOTENAME([YM]) 
							FROM (select distinct #fctt.YM as YM  from #fctt ) as tb_YM



			    --set @sql = ' select *
							-- from
							--	(select f.HD_Item_Number,f.Description,f.Vendor_Item_Number,f.UOM,f.PrimarySupplier,f.PlannerNumber,f.Owner_,f.YM,f.value  from #fctt f ) as sourcetb

							-- pivot 
						 --      ( sum(value) for YM in ('+ @Columns +') 
							--	) as p		
							--';
				
			    set @sql = ' select *
							 from
								(select f.HD_Item_Number,f.Description,f.Vendor_Item_Number,f.UOM,f.YM,f.value  from #fctt f ) as sourcetb

							 pivot 
						       ( sum(value) for YM in ('+ @Columns +') 
								) as p		
							';

				EXECUTE sp_executesql @sql;

				drop table #fctt; 



				--- =======================
				--- Old way to Pivot data ---
				--- =======================

			 --  -- select * from fcst_ f order by f.ItemNumber_f					-- Testing --> this is good testing point
			 -- ,mypvt as 
				--	( select *
				--		 from 
				--				( select f.HD_Item_Number,f.Description,f.Vendor_Item_Number,f.UOM,f.PrimarySupplier,f.PlannerNumber,f.Owner_,f._T,f.value  from _fcst f  ) as sourcetb
    --                     pivot 
				--		       ( sum(value) for _T in ( [0],[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11]) 
				--				) as p								
				--	)
				
				
				--select pv.HD_Item_Number
				--       ,pv.Vendor_Item_Number
				--	   ,pv.Description
				--	   ,pv.UOM

					   
				--	   ,isnull(pv.[0],0) [0]
				--	   ,isnull(pv.[1],0) [1]
				--	   ,isnull(pv.[2],0) [2]
				--	   ,isnull(pv.[3],0) [3]
				--	   ,isnull(pv.[4],0) [4]
				--	   ,isnull(pv.[5],0) [5]
				--	   ,isnull(pv.[6],0) [6]
				--	   ,isnull(pv.[7],0) [7]
				--	   ,isnull(pv.[8],0) [8]
				--	   ,isnull(pv.[9],0) [9]
				--	   ,isnull(pv.[10],0) [10]
				--	   ,isnull(pv.[11],0) [11]
				--	   , getdate() as LastUpdated

				-- from mypvt pv
				---- where pv.HD_Item_Number in ('34.306.000')				
				----where pv.ItemNumber_f is null
				-- order by pv.HD_Item_Number	


	   end

	    --- 3. If Supplier is not provided, FC Saving Time is provided with to require Last month FC  ---	 
	else if    @Supplier_id is null and @FCSaveTime_id = 'M-1'			-- last month saved fc

	   	begin	

		   		select a.ItemNumber as HD_Item_Number,v.Customer_Supplier_ItemNumber as Vendor_Item_Number,m.Description,m.UOM
				  ,a.myDate2 as FC_Date,a.FC_Vol as FC_Quantity,a.ReportDate,m.PrimarySupplier,m.PlannerNumber,m.Owner_
				from  (

							select fh.*,fh.myDate1 as FCDate_
								 from JDE_DB_Alan.vw_FC_Hist fh												-- Need to Get Last month Saved FC data -- 14/9/2018
								 where fh.myReportDate2 = cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-',''),1,6) as integer)	
									   and	fh.Date	> DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0) 		-- since using last month data, so need to push out fc 1 month --- 6/12/2018
									   and fh.Date  <  DATEADD(mm, DATEDIFF(m,0,GETDATE())+12,0) 	-- only provide 12 month fc, but need to add 1 since you push out 1 month7/10/2020
							 
									 --and fh.ItemNumber in ('34.306.000')
				   ) a left join JDE_DB_Alan.vw_Mast m on a.ItemNumber = m.ItemNumber
				   left join JDE_DB_Alan.vw_Mast_Vendor_Item_CrossRef v on a.ItemNumber = v.ItemNumber 
		
			--where m.PrimarySupplier in ('1102')
			-- where m.PrimarySupplier in  ( select * from string_split(@Supplier_id,','))	
			   where  a.DataType1 = 'Adj_FC'


			 order by m.PrimarySupplier,a.ItemNumber,a.myDate2


		end

   	 --- 4. If Supplier is not provided ,FC Saving Time is provided with to require current month FC  ---
   else if   @Supplier_id is null and @FCSaveTime_id = 'M+0'			-- current month saved fc
	  
	   begin
				 select a.ItemNumber as HD_Item_Number,v.Customer_Supplier_ItemNumber as Vendor_Item_Number,m.Description,m.UOM
						  ,a.FCDate2_ as FC_Date,a.FC_Vol as FC_Quantity,a.ReportDate,m.PrimarySupplier,m.PlannerNumber,m.Owner_
					
					from  JDE_DB_Alan.vw_FC a left join JDE_DB_Alan.vw_Mast m on a.ItemNumber = m.ItemNumber
							   left join JDE_DB_Alan.vw_Mast_Vendor_Item_CrossRef v on a.ItemNumber = v.ItemNumber 
		
					--where m.PrimarySupplier in ('1102')
					-- where m.PrimarySupplier in  ( select * from string_split(@Supplier_id,','))	
					 where  a.DataType1 = 'Adj_FC'
					   and	(a.Date	between DATEADD(mm, DATEDIFF(m,0,GETDATE()),0) and  DATEADD(mm, DATEDIFF(m,0,GETDATE())+11,0) )			  --- get 12 month fc

					 order by m.PrimarySupplier,a.ItemNumber,a.FCDate2_

	   end

	
 END
