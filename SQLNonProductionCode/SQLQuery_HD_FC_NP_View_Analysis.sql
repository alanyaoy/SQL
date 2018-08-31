use JDE_DB_Alan
go

--select * from JDE_DB_Alan.FCPRO_NP_tmp
 --select DATEADD(mm, DATEDIFF(m,0,GETDATE())+1,0)



--delete from JDE_DB_Alan.FCPRO_NP_tmp
--- create view as derived table from 'FCPRO_NP_tmp'

create view dbo.vw_NP_FC as
with tb as 
		( select * 
			from JDE_DB_Alan.FCPRO_NP_tmp np
		   where np.Value > 0)

    ,tbl as ( select *
	                 ,min(tb.Date) over(partition by tb.ItemNumber) as FcStartDate
					 ,max(tb.Date) over(partition by tb.ItemNumber) as FcEndDate					
					 ,DATEADD(mm, DATEDIFF(m,0,GETDATE()),0) as CurrentMth
					  ,sum(tb.value) over (partition by tb.ItemNumber) as FcTTL
					 ,count(tb.date) over (partition by tb.ItemNumber) as FcMthCount				
					 ,datediff(m,min(tb.Date) over(partition by tb.ItemNumber),DATEADD(mm, DATEDIFF(m,0,GETDATE()),0) ) as Mth_Elapsed
             from tb)	 		    

select * from tbl 
--where tbl.ItemNumber in ('2801381324')
--order by tbl.ItemNumber,tbl.Date