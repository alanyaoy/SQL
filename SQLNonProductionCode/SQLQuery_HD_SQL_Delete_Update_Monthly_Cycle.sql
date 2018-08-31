/****** Script for SelectTopNRows command from SSMS  ******/
use JDE_DB_Alan
go

  --- FC table: for Auditing purpose ------
 ;with cte as 
  (
	  select h.ReportDate as Date_Uploaded,count(*)  as Records_Uploaded
	  from JDE_DB_Alan.FCPRO_Fcst h
	  group by  h.ReportDate )
  
  select *, sum(cte.Records_Uploaded) over (order by Date_Uploaded) TTL_Records_HistTbl 
  from cte
  

   --- FC History table: a Nice Table show all Records and Break down on each Upload date For Monthly Cycle ------ 7/12/2017
  -- can use OLAP sum or Running Total Function to get your result ---
  ;with cte as 
    (
	  select h.ReportDate as Date_Uploaded,count(*)  as Records_Uploaded
	  from JDE_DB_Alan.FCPRO_Fcst_History h
	  group by  h.ReportDate )
  
  select *, sum(cte.Records_Uploaded) over (order by Date_Uploaded) TTL_Records_HistTbl 
  from cte

---==========================================================================================================
SELECT  [BU]
      ,[ShortItemNumber]
      ,[ItemNumber]
      ,[Century]
      ,[FinancialYear]
      ,[FinancialMonth]
      ,[DocumentType]
      ,[Quantity]
      ,[UOM]
  FROM [JDE_DB_Alan].[JDE_DB_Alan].[SlsHistorymt] s
  where s.ItemNumber like ('%850520000202%')


  select * from JDE_DB_Alan.Master_ML345 m
  where m.StandardCost =0

  select * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload s
  where s.ItemNumber like ('%850520000202%') order by s.ItemNumber,s.cy,s.Month

  select count(*) from JDE_DB_Alan.FCPRO_Fcst 

  select distinct f.ReportDate from JDE_DB_Alan.FCPRO_Fcst f order by f.ReportDate
  select distinct f.ReportDate from JDE_DB_Alan.FCPRO_Fcst f where f.ItemNumber like ('%40.033.131%') and f.ReportDate <='2017-12-07 10:59:00'
  select distinct f.ReportDate from JDE_DB_Alan.FCPRO_Fcst f where f.ItemNumber like ('%40.033.131%') and f.ReportDate >='2017-12-07 10:59:00'
  select * from JDE_DB_Alan.FCPRO_Fcst f where f.ReportDate >='2017-12-03' order by f.ItemNumber,f.Date
  select * from JDE_DB_Alan.FCPRO_Fcst f where f.ReportDate between '2017-12-06 00:00:00' and '2017-12-07 10:00:00'  order by f.ItemNumber,f.Date

  select * from JDE_DB_Alan.FCPRO_Fcst f where f.ReportDate <= '2017-12-07 10:00:00'
  select * from JDE_DB_Alan.FCPRO_Fcst f where f.ReportDate >= '2017-12-07 12:00:00'
  select * from JDE_DB_Alan.FCPRO_Fcst f where f.ItemNumber like ('%2851218661%')
  select * from JDE_DB_Alan.FCPRO_Fcst f where f.ItemNumber like ('%40.033.131%')



   ---- Warning: Dangerours It Is Delete operation -- Always test Using Select statement first to Check then Execute this one !!! Made Mistakt before !! 7/12/2017 ---
  delete from JDE_DB_Alan.FCPRO_Fcst where ReportDate >='2017-12-03'
  delete from JDE_DB_Alan.FCPRO_Fcst where ReportDate >= '2017-12-07 13:00:00'
  delete from JDE_DB_Alan.FCPRO_Fcst where ItemNumber like ('%40.033.131%') and ReportDate <='2017-12-07 10:59:00'

  insert into JDE_DB_Alan.FCPRO_Fcst select * from JDE_DB_Alan.FCPRO_Fcst_History h where h.ReportDate >='2017-12-01'

  select * from JDE_DB_Alan.Px_AWF_HD_MT_FCPro_upload px
  where px.WholeSalePrice =0


  -------------- Forecast table after uploading @7/12/2017 ----------------------------------

  SELECT [ItemNumber]
      ,[DataType1]
      ,[Date]
      ,[Value]
      ,[ReportDate]
  FROM [JDE_DB_Alan].[JDE_DB_Alan].[FCPRO_Fcst]


  select distinct f.ItemNumber from JDE_DB_Alan.FCPRO_Fcst f

  
  select count(*) from JDE_DB_Alan.FCPRO_Fcst f

---------------- Forecast History table after uploading @7/12/2017-----------------------------------
  SELECT  [ItemNumber]
      ,[DataType1]
      ,[Date]
      ,[Value]
      ,[ReportDate]
  FROM [JDE_DB_Alan].[JDE_DB_Alan].[FCPRO_Fcst_History]

  select count(*) from JDE_DB_Alan.FCPRO_Fcst_History h where h.ReportDate <'2017-12-01'


