


use JDE_DB_Alan
go


----------------------------------------

  select top 3 * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload l 
  select * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload l where l.ItemNumber in ('24.7257.0952','6000130009004H')
    select * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload l where l.ValidStatus in ('Y')
   select 1 from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload l where l.ValidStatus in ('Y')

  select * from JDE_DB_Alan.SlsHist_Excp_FCPro_upload e order by e.Date_Updated desc, ReportDate desc

   select l.ItemNumber,l.CYM,l.SalesQty,l.SalesQty_Adj,l.ValidStatus
   from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload l 
   --where l.ItemNumber in ('26.132.0204')
   where l.ItemNumber in ('6000130009004H')
    

	select   dateadd(s,-1,dateadd(d, datediff(d,0, getdate()), 0)	)

	select *
	from JDE_DB_Alan.SlsHist_Excp_FCPro_upload e
	where e.Date_Updated > dateadd(s,-1,dateadd(d, datediff(d,0, getdate()), 0)	)


	delete from JDE_DB_Alan.SlsHist_Excp_FCPro_upload 
	where Date_Updated > dateadd(s,-1,dateadd(d, datediff(d,0, getdate()), 0)	)



--select a.*,dense_rank()over(partition by Date_updated order by Date_Updated desc ) as rn				--- use dense_rank, also use date_updated desc to pick up latest records 12/6/2020
--from JDE_DB_Alan.SlsHist_Excp_FCPro_upload a 
--order by a.Date_Updated,a.ReportDate


select a.*,dense_rank()over(order by Date_Updated desc) as rn				--- use dense_rank, also use date_updated desc to pick up latest records 12/6/2020
from JDE_DB_Alan.SlsHist_Excp_FCPro_upload a 
order by a.Date_Updated,a.ReportDate

select a.*,dense_rank()over(order by reportdate ) as rn				--- use dense_rank, also use date_updated desc to pick up latest records 12/6/2020
from JDE_DB_Alan.SlsHist_Excp_FCPro_upload a 
order by a.Date_Updated,a.ReportDate


DECLARE @IntervalMinutes int = 5;
with t as ( select  count(*) as cnt,DATEADD(minute, (DATEDIFF(minute, 0, reportdate)/@IntervalMinutes)*@IntervalMinutes, 0) as start_
            from JDE_DB_Alan.SlsHist_Excp_FCPro_upload l
			group by DATEADD(minute, (DATEDIFF(minute, 0, reportdate)/@IntervalMinutes)*@IntervalMinutes, 0)
			)
   --select * from t
	,a as (
			SELECT *
	         ,dense_rank() OVER( order by date_updated desc ) as date_group
	         ,DATEADD(minute, (DATEDIFF(minute, 0, reportdate)/@IntervalMinutes)*@IntervalMinutes, 0) as start_t
			 ,ROW_NUMBER() OVER( PARTITION BY --ID
					(DATEADD(minute, (DATEDIFF(minute, 0, reportdate)/@IntervalMinutes)*@IntervalMinutes, 0) ) ORDER BY reportdate) AS filter_row
			--,ROW_NUMBER() OVER( partition by date_updated  order by DATEADD(MINUTE, DATEDIFF(MINUTE, '2000', reportdate) / 10 * 10, '2000') ) as rnk
			
		 from JDE_DB_Alan.SlsHist_Excp_FCPro_upload l
	--order by l.Date_Updated desc,l.ReportDate desc
	)
select *
    , dense_rank() over ( order by start_t desc ) as rnk
 from a
--where a.date_group =1
order by a.Date_Updated desc,a.ReportDate desc


select DATEDIFF(minute, 0,'2020-06-17 09:38:47.000')
select DATEDIFF(minute, '','2020-06-17 09:38:47.000')
select DATEDIFF(minute, '',getdate())

select dateadd(minute,(DATEDIFF(minute, '', '2020-06-17 09:38:47.000')/5)*5,0)


        SELECT DISTINCT ReportDate              
        FROM JDE_DB_Alan.SlsHist_Excp_FCPro_upload AS a
        WHERE NOT EXISTS(
            SELECT 1
            FROM JDE_DB_Alan.SlsHist_Excp_FCPro_upload AS b
            WHERE
                b.ItemNumber = a.ItemNumber
				and b.ValidStatus = a.ValidStatus
				and b.Value_Sls_Adj = a.Value_Sls_Adj
				and b.Date = a.Date
				--and b.ReportDate = a.ReportDate
                AND b.ReportDate < a.ReportDate
                AND b.ReportDate > DATEADD(minute, -5, a.ReportDate)
            )

        SELECT DISTINCT ReportDate              
        FROM JDE_DB_Alan.SlsHist_Excp_FCPro_upload AS a
        WHERE NOT EXISTS(
            SELECT 1
            FROM JDE_DB_Alan.SlsHist_Excp_FCPro_upload AS b
            WHERE
                b.ItemNumber = a.ItemNumber
				and b.ValidStatus = a.ValidStatus
				and b.Value_Sls_Adj = a.Value_Sls_Adj
				and b.Date = a.Date
				--and b.ReportDate = a.ReportDate
                AND b.ReportDate < a.ReportDate
                AND b.ReportDate > DATEADD(minute, 5, a.ReportDate)
            )



CREATE TABLE my_table(ID VARCHAR(5), in_time DATETIME)

INSERT INTO my_table (ID, in_time) VALUES
('4844', '2017-04-06 10:15:00.000'),
('5221', '2017-11-24 11:18:00.000'),
('5221', '2017-11-24 11:18:00.000'),
('5221', '2017-11-25 14:23:00.000'),
('8486', '2017-10-10 15:30:00.000'),
('8486', '2017-10-10 15:32:00.000'),
('8486', '2017-10-10 15:46:00.000'), -- new row after updating question
('8486', '2017-10-10 16:00:00.000'), -- new row after updating question
('8486', '2017-10-10 16:19:00.000') -- new row after updating question


delete from my_table
select * from my_table
select  DATEADD(minute, -15,'2017-10-10 15:30:00.000' ) 
select  DATEADD(minute, -15,'2017-10-10 15:32:00.000' ) 
select  DATEADD(minute, -15,'2017-10-10 15:46:00.000' ) 
select  DATEADD(minute, -15,'2017-10-10 16:00:00.000' ) 
select DATEDIFF(minute,0, '2017-10-10 15:30:00.000') > select DATEDIFF(minute,0, '2017-10-10 16:00:00.000')


DECLARE @IntervalMinutes int = 15;
WITH
    start_intervals AS (
        SELECT DISTINCT
              ID
             ,in_time			
        FROM dbo.my_table AS a
        WHERE not EXISTS(
            SELECT 1
            FROM dbo.my_table AS b
            WHERE
                b.ID = a.ID
                AND b.in_time < a.in_time
              --AND b.in_time > DATEADD(minute, -@IntervalMinutes, a.in_time )
			  AND b.in_time > DATEADD(minute, -15, a.in_time  )
            )
        )
	select * from start_intervals
    , end_intervals AS (
        SELECT  --DISTINCT
              ID
            , in_time
        FROM dbo.my_table AS a
        WHERE  EXISTS(
            SELECT 1
            FROM dbo.my_table AS b
            WHERE
                b.ID = a.ID
                AND b.in_time > a.in_time
                AND b.in_time < DATEADD(minute, @IntervalMinutes, a.in_time)
            )
    )
	--select * from end_intervals
    , intervals AS (
        SELECT
              ID
            , start_intervals.in_time AS start_interval
            , end_intervals.in_time AS end_interval
        FROM start_intervals
        CROSS APPLY(
            SELECT TOP(1) in_time
            FROM end_intervals 
            WHERE
                end_intervals.ID = start_intervals.ID
                AND end_intervals.in_time >= start_intervals.in_time
            ) AS end_intervals
        )
   --select * from intervals
SELECT 
      my_table.ID
    , my_table.in_time
    , ROW_NUMBER() OVER(PARTITION BY my_table.ID, intervals.start_interval ORDER BY(intervals.start_interval)) AS filter_row
FROM dbo.my_table
   --JOIN intervals ON my_table.in_time BETWEEN intervals.start_interval AND intervals.end_interval
inner JOIN intervals ON my_table.in_time BETWEEN intervals.start_interval AND intervals.end_interval

------ Original post --------

DECLARE @IntervalMinutes int = 15;
WITH
    start_intervals AS (
        SELECT DISTINCT
              ID
            , in_time
        FROM dbo.my_table AS a
        WHERE NOT EXISTS(
            SELECT 1
            FROM dbo.my_table AS b
            WHERE
                b.ID = a.ID
                AND b.in_time < a.in_time
                AND b.in_time > DATEADD(minute, -@IntervalMinutes, a.in_time)
            )
        )
    , end_intervals AS (
        SELECT
              ID
            , in_time
        FROM dbo.my_table AS a
        WHERE NOT EXISTS(
            SELECT 1
            FROM dbo.my_table AS b
            WHERE
                b.ID = a.ID
                AND b.in_time > a.in_time
                AND b.in_time < DATEADD(minute, @IntervalMinutes, a.in_time)
            )
    )
    , intervals AS (
        SELECT
              ID
            , start_intervals.in_time AS start_interval
            , end_intervals.in_time AS end_interval
        FROM start_intervals
        CROSS APPLY(
            SELECT TOP(1) in_time
            FROM end_intervals 
            WHERE
                end_intervals.ID = start_intervals.ID
                AND end_intervals.in_time >= start_intervals.in_time
            ) AS end_intervals
        )
SELECT 
      my_table.ID
    , my_table.in_time
    , ROW_NUMBER() OVER(PARTITION BY my_table.ID, intervals.start_interval ORDER BY(intervals.start_interval)) AS filter_row
FROM dbo.my_table
JOIN intervals ON my_table.in_time BETWEEN intervals.start_interval AND intervals.end_interval


--- end of original post ----



-------- Use Lag ------------

select cte.*,
          datediff(minute,lag(ReportDate,5) over (order by reportdate), reportdate ) as diff
from JDE_DB_Alan.SlsHist_Excp_FCPro_upload cte;

select *, row_number() over (partition by  grp order by reportdate) as [ROWNUMBER]
from (select *, (case when datediff(minute,lag(ReportDate,5) over (order by reportdate), reportdate ) <= 1 
                      then 1 else 2 
                 end) as grp
      from JDE_DB_Alan.SlsHist_Excp_FCPro_upload l
     ) t
order by reportdate

select *, row_number() over (partition by number, grp order by id) as [ROWNUMBER]
from (select *, (case when datediff(day, lag(date,1,date) over (partition by number order by id), date) <= 1 
                      then 1 else 2 
                 end) as grp
      from JDE_DB_Alan.SlsHist_Excp_FCPro_upload l
     ) t;
