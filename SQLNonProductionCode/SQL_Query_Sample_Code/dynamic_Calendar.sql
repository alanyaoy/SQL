
use JDE_DB_Alan
go

					------------- Alan's New code for Calendar ------------------ 1/6/2018 -------------------------------
					

                  --->>>  New parameters for Alan's MthCal  ------ 16/4/2021 


				  --->>> old code has only 2 years of past months + 2 years future ( forward )     --- key is 24; length N <49;boundary m.rnk <25 and m.rnk >12 ;  
				  --->>> new code has 3 years of past months ( back ) + 2 years future ( forward )  ---key is 36; length N <61;boundary m.rnk <37 and m.rnk >24 ;
				  --->>> for Portfolio Analysis purpose only fetch last 12 months sales history

				  ---***Basically Extend 24 to 36 month for past; did not change Peter's code ( 24 months ? )

   
     ;with CalendarFrame as (
					--select -24 as t,1 as n,cast(DATEADD(mm, DATEDIFF(mm, 0, GETDATE())-24, 0) as datetime) as start
						select 1 as t,1 as n,cast(DATEADD(mm, DATEDIFF(mm, 0, GETDATE())-24, 0) as datetime) as start
					union all
					select case when t +1 >24 then 1 else t+1 end ,case when n=12 then 1 else n+1 end,dateadd(mm, 1, start)
					-- select t+1 ,case when n=12 then 1 else n+1 end,dateadd(mm, 1, start)
					from CalendarFrame
				)
				--select top 50 * from CalendarFrame
				,MonthlyCalendar as
					(
					select top 48 t
								--,RIGHT('00'+CAST(n AS VARCHAR(3)),2) nmb,cast(SUBSTRING(REPLACE(CONVERT(char(10),start,126),'-',''),1,6) as integer) as [StartDate]		-- original name of '[StartDate]' in template
								,RIGHT('00'+CAST(n AS VARCHAR(3)),2) nmb,cast(SUBSTRING(REPLACE(CONVERT(char(10),start,126),'-',''),1,6) as integer) as [StartDt2]			-- 5/9/2018 , changed Name to 'StartDt2'
								,RIGHT('00'+CAST(n AS VARCHAR(3)),2) nmbr,cast(SUBSTRING(REPLACE(CONVERT(char(10),start,126),'-',''),1,6) as integer) as [StartDt]			-- 6/8/2020 , changed Name to 'StartDt2'
								,DATENAME(mm,start) MnthName,DATENAME(yyyy,start) YearName from CalendarFrame
				)
				--select * from MonthlyCalendar
     ,R(N,_T,T_,T,XX,YY,start) AS
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
							where N <61
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
			
			,itm as ( select distinct h.ItemNumber as ItemNumber_ from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h )
			,list as ( select * from itm cross join MonthlyCalendar cldr 
						where --StartDate						-- original name of '[StartDate]' in template 
								StartDt
									between replace(convert(varchar(8), DATEADD(mm, DATEDIFF(m,0,GETDATE())-12,0),126),'-','' )			-- last 12 months		
													and  replace(convert(varchar(8), DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-','' )		-- last 12 months
						)		
		
			,mylist as ( select * from itm cross join MthCal )	
		 	  
				--select * from list m where m.ItemNumber_ in ('34.252.000')	
			-- select * from mylist m where m.ItemNumber_ in ('34.252.000')
		 		  	     
			----------------- Padded Item with all Months --------------------		
		  

					--- below is tb padded Item with all Months ---
			,hist as																													
			(  select m.ItemNumber_
				            
						,h.CYM,h.CY,h.Month
						,h.ReportDate
						,case when h.SalesQty is null then 0 else h.SalesQty end as SalesQty_				
						,getdate() as ReportDate_												-- there is no different version of history, so do not bother to use old ReportData in History table UNLESS you need to join back to History table using ReportData as a key --- 5/9/2018
						,m.StartDt
						--,m.YY, m.rnk,m.month as mth						  
						,case 
							when h.CYM is null	then cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-',''),1,6) as integer) 		-- why use this ?	if no date, then use current month as month 14/4/2021						
							else h.CYM
						end as CYM_
						,case 
							when h.CYM is null	then m.StartDt					
							else h.CYM
						end as CYM_2
						,m.YY
						,m.rnk

				--from list m left join JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h on m.StartDt2 = h.CYM and  m.ItemNumber_ = h.ItemNumber			--- old  6/8/2020
					from mylist m left join JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h on m.StartDt = h.CYM and  m.ItemNumber_ = h.ItemNumber			--- new 7/8/2020
				--where    list.StartDt = cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-',''),1,6) as integer)			-- Watch out use List.StartDt Not h.CYM !!!   --- 29/5/2018
						-- h.CYM = '201804' and																													-- Performance issue ?
						--c.rnk =24																												-- last month ( for last month Sales)
					--where  m.StartDt <= cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-',''),1,6) as integer)    --- old 6/9/2020  
						--where m.rnk <25 and m.rnk >12
						where m.rnk <37 and m.rnk >24

					)

				 select * from hist where hist.ItemNumber_ in ('38.001.001')



------
 
                  
				   --->>>  Old parameters for MthCal  ------ 16/4/2021  
				  --->>> old code has only 2 years of past months + 2 years future ( forward )     --- key is 24; length N <49;boundary m.rnk <25 and m.rnk >12 ;  
				  --->>> new code has 3 years of past months ( back ) + 2 years future ( forward )  ---key is 36; length N <61;boundary m.rnk <37 and m.rnk >24 ;
				  --->>> for Portfolio Analysis purpose only fetch last 12 months sales history
				  
				  ---***Basically Extend 24 to 36 month for past; did not change Peter's code ( 24 months ? )

 
  ;with CalendarFrame as (
					--select -24 as t,1 as n,cast(DATEADD(mm, DATEDIFF(mm, 0, GETDATE())-24, 0) as datetime) as start
						select 1 as t,1 as n,cast(DATEADD(mm, DATEDIFF(mm, 0, GETDATE())-24, 0) as datetime) as start
					union all
					select case when t +1 >24 then 1 else t+1 end ,case when n=12 then 1 else n+1 end,dateadd(mm, 1, start)
					-- select t+1 ,case when n=12 then 1 else n+1 end,dateadd(mm, 1, start)
					from CalendarFrame
				)
				--select top 50 * from CalendarFrame
				,MonthlyCalendar as
					(
					select top 48 t
								--,RIGHT('00'+CAST(n AS VARCHAR(3)),2) nmb,cast(SUBSTRING(REPLACE(CONVERT(char(10),start,126),'-',''),1,6) as integer) as [StartDate]		-- original name of '[StartDate]' in template
								,RIGHT('00'+CAST(n AS VARCHAR(3)),2) nmb,cast(SUBSTRING(REPLACE(CONVERT(char(10),start,126),'-',''),1,6) as integer) as [StartDt2]			-- 5/9/2018 , changed Name to 'StartDt2'
								,RIGHT('00'+CAST(n AS VARCHAR(3)),2) nmbr,cast(SUBSTRING(REPLACE(CONVERT(char(10),start,126),'-',''),1,6) as integer) as [StartDt]			-- 6/8/2020 , changed Name to 'StartDt2'
								,DATENAME(mm,start) MnthName,DATENAME(yyyy,start) YearName from CalendarFrame
				)
				--select * from MonthlyCalendar
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
										,XX
										,YY 
									,cast(SUBSTRING(REPLACE(CONVERT(char(10),start,126),'-',''),1,6) as integer) as [StartDt]		-- [StartDt] is calendar date in MthCal
									,LEFT(datename(month,start),3) AS [month_name]
									,datepart(month,start) AS [month]
									,datepart(year,start) AS [year]				
									from R  )
			 -- select * from MthCal


			,itm as ( select distinct h.ItemNumber as ItemNumber_ from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h )
			,list as ( select * from itm cross join MonthlyCalendar cldr 
						where --StartDate						-- original name of '[StartDate]' in template 
								StartDt
									between replace(convert(varchar(8), DATEADD(mm, DATEDIFF(m,0,GETDATE())-12,0),126),'-','' )			-- last 12 months		
													and  replace(convert(varchar(8), DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-','' )		-- last 12 months
						)		
		
			,mylist as ( select * from itm cross join MthCal )	
		 	  
				--select * from list m where m.ItemNumber_ in ('34.252.000')	
			-- select * from mylist m where m.ItemNumber_ in ('34.252.000')
		 		  	     
			----------------- Padded Item with all Months --------------------		
		  

					--- below is tb padded Item with all Months ---
			,hist as																													
			(  select m.ItemNumber_
				            
						,h.CYM,h.CY,h.Month
						,h.ReportDate
						,case when h.SalesQty is null then 0 else h.SalesQty end as SalesQty_				
						,getdate() as ReportDate_												-- there is no different version of history, so do not bother to use old ReportData in History table UNLESS you need to join back to History table using ReportData as a key --- 5/9/2018
						,m.StartDt
						--,m.YY, m.rnk,m.month as mth						  
						,case 
							when h.CYM is null	then cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-',''),1,6) as integer) 		-- why use this ?	if no date, then use current month as month 14/4/2021						
							else h.CYM
						end as CYM_
						,case 
							when h.CYM is null	then m.StartDt					
							else h.CYM
						end as CYM_2
						,m.YY
						,m.rnk

				--from list m left join JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h on m.StartDt2 = h.CYM and  m.ItemNumber_ = h.ItemNumber			--- old  6/8/2020
					from mylist m left join JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h on m.StartDt = h.CYM and  m.ItemNumber_ = h.ItemNumber			--- new 7/8/2020
				--where    list.StartDt = cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-',''),1,6) as integer)			-- Watch out use List.StartDt Not h.CYM !!!   --- 29/5/2018
						-- h.CYM = '201804' and																													-- Performance issue ?
						--c.rnk =24																												-- last month ( for last month Sales)
					--where  m.StartDt <= cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-',''),1,6) as integer)    --- old 6/9/2020  
						where m.rnk <25 and m.rnk >12
					)

				 select * from hist where hist.ItemNumber_ in ('38.001.001')