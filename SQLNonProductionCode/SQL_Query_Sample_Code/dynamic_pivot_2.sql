	DECLARE @Columns AS NVARCHAR(MAX)
	declare @sql     NVARCHAR(MAX) = '';

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
		
			where m.PrimarySupplier in ('1102')			
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
					
						)	



			  --,tb_YM as ( select distinct f.FC_Date as YM from _fcst f ) 	  
			

			   select f.HD_Item_Number,f.Description,f.Vendor_Item_Number,f.UOM,f.PrimarySupplier,f.PlannerNumber,f.Owner_,f._T,f.value,f.FC_Date as YM
				into #fc from _fcst f 
			    
			    SELECT  @Columns = ISNULL(@Columns + ',','')+ QUOTENAME([YM]) 
							FROM (select distinct #fc.YM as YM  from #fc ) as tb_YM



			    set @sql = ' select *
							 from
								(select f.HD_Item_Number,f.Description,f.Vendor_Item_Number,f.UOM,f.PrimarySupplier,f.PlannerNumber,f.Owner_,f.YM,f.value  from #fc f ) as sourcetb

							 pivot 
						       ( sum(value) for YM in ('+ @Columns +') 
								) as p		
							';

				EXECUTE sp_executesql @sql;

				drop table #fc 


exec JDE_DB_Alan.sp_Z_Vendor_FC_Report_Test '1102','M-1'
exec JDE_DB_Alan.sp_Z_Vendor_FC_Report_Test '1102','M+0'
