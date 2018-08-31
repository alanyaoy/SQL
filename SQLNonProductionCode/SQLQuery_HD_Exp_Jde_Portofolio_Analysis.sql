use JDE_DB_Alan
go


------------------------------------- FC/History/SOH/Cost/Pareto --------------------------------------

declare @Supplier_id varchar(4000)
declare @Item_id varchar(4000)
declare @DataType as varchar(100)
--set @Supplier_id= '503978,1459'
--set @Item_id = '42.522.000,46.502.000,42.603.855,46.505.000'
--set @Item_id = '27.253.000'

set @Supplier_id = '503978,1459,20615'
--set @Item_id = 's3000NET5300N901'
--set @DataType = 'Forecast'
set @DataType = 'Forecast,Sales'
--set @DataType = 'Forecast'

  ;with cte as (
		select f.ItemNumber,convert(varchar(6),f.Date,112) as Period_YM,f.Value,'Forecast' as Typ_
		 from JDE_DB_Alan.FCPRO_Fcst f 
		 --where s.ItemNumber in (select ids from @ItemIDs)
		 --where f.ItemNumber in ('40.033.131')
		union all
		select s.ItemNumber,convert(varchar(6),convert(datetime,concat(s.CYM,'01')),112) Period_YM,s.SalesQty,'Sales' as Typ_
		from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload s 
		--where s.ItemNumber in (select ids from @ItemIDs)
		--where s.ItemNumber in ('40.033.131')
	  ) 

	 ,comb_ as ( select cte.ItemNumber,cte.Typ_,cte.Period_YM,cte.Value,m.StandardCost,p.Pareto,m.UOM,m.PrimarySupplier 					
					,m.PlannerNumber
					,m.SellingGroup,m.FamilyGroup,m.Family,m.Description
					,case m.PlannerNumber when '20071' then 'Domenic Cellucci'
										  when '20072' then 'Salmon Saeed'
										  when '20004' then 'Margaret Dost'	
										  when '20005' then 'Imelda Chan'										  
										  else 'Unknown'
						end as Owner_
				from cte left join JDE_DB_Alan.Master_ML345 m on cte.ItemNumber = m.ItemNumber
					 left join JDE_DB_Alan.FCPRO_Fcst_Pareto p on cte.Itemnumber = p.ItemNumber

			   where cte.ItemNumber in ( select data from JDE_DB_Alan.dbo.Split(@Item_id,','))
			        or m.PrimarySupplier in ( select data from JDE_DB_Alan.dbo.Split(@Supplier_id,','))
			     --   or m.PrimarySupplier in ( select data from JDE_DB_Alan.dbo.Split(@Supplier_id,','))
		)
	,staging as 
			(select  comb_.*
					,c.LongDescription as SellingGroup_
					,d.LongDescription as FamilyGroup_
					,e.LongDescription as Family_0
					--,tbl.Family as Family_1
					--,f.StandardCost,f.WholeSalePrice
			from comb_ left join JDE_DB_Alan.MasterSellingGroup c  on comb_.SellingGroup = c.Code
					 left join JDE_DB_Alan.MasterFamilyGroup d  on comb_.FamilyGroup = d.Code
					 left join JDE_DB_Alan.MasterFamily e  on comb_.Family = e.Code
			   )   

     ,comb as ( select * from staging )
     
	 ,np as ( select * from JDE_DB_Alan.FCPRO_NP_tmp )

	select comb.ItemNumber,'HD' as BranchPlant,comb.UOM,'BF' as ForcastType
			,comb.Period_YM
			,convert(date,dateadd(mm,0,convert(datetime,comb.Period_YM+'01',103))) as Period_YMD_0
			,convert(date,dateadd(d,-1,dateadd(mm,1,convert(datetime,comb.Period_YM+'01',103))),103) as Period_YMD_1		-- to get 'Jde FC Date' Format ie 31/Month/Year
			,convert(date,dateadd(d,-1,dateadd(mm,0,convert(datetime,comb.Period_YM+'01',103))),103) as Period_YMD_2     -- to get 'Jde FC Date' Format ie 31/Month/Year,however when FC loaded into Jde, Jde will automatically add 1 day and push FC to Following month, ie 31/1/2018 FC will be push into Month slot of 1/Feb/2018, so here you need to change date again
			,convert(varchar(10),convert(date,dateadd(d,-1,dateadd(mm,0,convert(datetime,comb.Period_YM+'01',105))),103),103) Period_YMD_3
			,comb.Typ_
			,comb.Value as Qty
			,0 as Amt
			,0 as CustomerNumber,'N' as BypassForcing,comb.Pareto 			
			,comb.PlannerNumber,comb.primarysupplier,comb.Owner_
			,comb.Family_0
			,comb.Description
			from comb
	--where comb.Typ_ in ('Forecast')
	  where comb.Typ_ in (select data from JDE_DB_Alan.dbo.Split(@DataType,','))
	      --  and  and not exists ( select np.ItemNumber from JDE_DB_Alan.FCPRO_NP_tmp np where np.ItemNumber = staging.ItemNumber)				--- exclude New Product Forecast  ---
	order by Pareto asc,comb.PlannerNumber,comb.ItemNumber,comb.Typ_,comb.Period_YM


----------------------------------------------------------------------------------------------------------------------------------------------------------------


SELECT convert(varchar, getdate(), 109)
select CONVERT(datetime, convert(varchar(10), 20120103));

SELECT convert(date,CONVERT(varchar(10),columname,101))
SELECT convert(date,CONVERT(varchar(10),getdate(),101))
SELECT CONVERT(date, CONVERT(varchar(6), your_column) + '01') myDate
SELECT CONVERT(date, CONVERT(varchar(6),201610) + '01')								--- good working -> from Int to Date
SELECT CONVERT(datetime, CONVERT(varchar(6),201610) + '01',120)						--- good working --> yiedl 2016-10-01 00:00:00 000

select cast(CONVERT(VARCHAR(6),fc.Date, 112) as int) from JDE_DB_Alan.FCPRO_Fcst fc		--- good working -> from Date to Int
Select Convert(DATETIME, LEFT(20130101, 8))					--- More on Int to Date 
SELECT SUBSTRING(CONVERT(VARCHAR, DOB),5,2) AS mob			-- More on Int to Date, if data is in decimal datatype - [DOB] [decimal](8, 0) NOT NULL - eg - 19700109.	
SELECT strftime("%Y-%d-%m", col_name, 'unixepoch') AS col_name	-- More on Int to Date : if you db is Sqlite


---- Convert format Date in SQL server --- 16/12/2017

http://www.sql-server-helper.com/tips/date-formats.aspx
https://docs.microsoft.com/en-us/sql/t-sql/functions/cast-and-convert-transact-sql
https://www.w3schools.com/sql/func_sqlserver_convert.asp


select getdate()
select convert(varchar(10),getdate(),112) -- yield 20171216 - ISO

select convert(varchar(10),getdate(),110) -- yield 12-16-2017 - US
select convert(varchar(10),getdate(),101) -- yield 12/16/2017 - US

select convert(varchar(10),getdate(),105) -- yield 16-12-2017 - Italian
select convert(varchar(10),getdate(),103) -- yield 16/12/2017 - British / French
select convert(varchar(10),getdate(),3) -- yield 16/12/2017

select convert(varchar(10),getdate(),111) -- yield 2017/12/16 - Japan



--------------------------------------- FC History -----
select *,cast(convert(varchar(6),f.Date,112) as int) CYM from JDE_DB_Alan.FCPRO_Fcst f where f.ItemNumber in ('40.033.131') 
		and f.date > cast(DATEADD(mm, DATEDIFF(mm, 0, GETDATE()), 0) as datetime)

select cast(DATEADD(mm, DATEDIFF(mm, 0, GETDATE()), 0) as datetime)

select * from JDE_DB_Alan.FCPRO_Fcst f where f.ItemNumber in ('40.033.131')
select * from JDE_DB_Alan.FCPRO_Fcst_History h where h.ItemNumber in ('40.033.131')


select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('2780047000')
select * from JDE_DB_Alan.Master_ML345 m where m.PrimarySupplier in ('20037')
select * from JDE_DB_Alan.FCPRO_Fcst f where f.ItemNumber in ('2780047000')	


------------------------------------------------------------------------------------------------------------------


  --- a Nice Table show all Records and Break down on each Upload date For Monthly Cycle------ 7/12/2017
  -- can use OLAP sum or Running Total Function to get your result ---
  with cte as 
  (
	  select h.ReportDate as Date_Uploaded,count(*)  as Records_Uploaded
	  from JDE_DB_Alan.FCPRO_Fcst_History h
	  group by  h.ReportDate )
  
  select *, sum(cte.Records_Uploaded) over (order by Date_Uploaded) TTL_Records_HistTbl from cte

