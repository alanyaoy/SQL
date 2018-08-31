
use JDE_DB_Alan
go
--/****** Script for SelectTopNRows command from SSMS ******/
--SELECT [ItemNumber]
--,[Date]
--,[Value]
--,[DataType]
--,[CN_Number]
--,[Comment]
--,[Creator]
--,[LastUpdated]
--,[ReportDate]
--FROM [JDE_DB_Alan].[JDE_DB_Alan].[FCPRO_NP_tmp]


--select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('2801381810')
--select * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload s where s.ItemNumber in ('2801381810')
--select * from JDE_DB_Alan.MasterMTLeadingZeroItemList l

------------------------------ Create NP PlaceHolder in FC Pro by Checking History tbl--------------------------------------------------------------------------------------------------

   --- First To Get NP Master SKU List ( create a place holder if there is no History )by checking if  Sls_History table--- 12/2/2018
   --- what about there is no records ( empty ) will it loaded into Sls table ? --- tested, it will not pick up any records.
   --- Note following step MUST be taken After Reload Sls History, you need First pull Sales History from JDE First, run upload HD history and Re Generate 'SlsHist_AWFHDMT_FCPro_upload' table ---
   --- You do not start from --> 'JDE_DB_Alan.SlsHistoryHD'  table For NP loading process, Because 
   -- 1) you have no Short number / UOM for NP 2) you do not need to do process for superssion & stocking Type 3) it will be clean start by Just add/append records to '.SlsHist_AWFHDMT_FCPro_upload'  table, you just need to remember this is start pointfor NP loading Process. 13/2/2018
   
;------------------------------ Create NP PlaceHolder in FC Pro by Checking History tbl--------------------------------------------------------------------------------------------------

		   --- First To Get NP Master SKU List ( create a place holder if there is no History )by checking if  Sls_History table--- 12/2/2018
		   --- what about there is no records ( empty ) will it loaded into Sls table ? --- tested, it will not pick up any records.
		   --- Note following step MUST be taken After Reload Sls History, you need First pull Sales History from JDE First, run upload HD history and Re Generate 'SlsHist_AWFHDMT_FCPro_upload' table ---
		   --- You do not start from --> 'JDE_DB_Alan.SlsHistoryHD'  table For NP loading process, Because 
		   -- 1) you have no Short number / UOM for NP 2) you do not need to do process for superssion & stocking Type 3) it will be clean start by Just add/append records to '.SlsHist_AWFHDMT_FCPro_upload'  table, you just need to remember this is start pointfor NP loading Process. 13/2/2018
   
		;with tb as (
				select np.ItemNumber,Comment,min(np.date) as FCStartDate
				from JDE_DB_Alan.FCPRO_NP_tmp np 		
				where not exists( 
									select distinct s.ItemNumber from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload s where np.ItemNumber = s.ItemNumber)		
								 -- select distinct s.ItemNumber from JDE_DB_Alan.SlsHistoryHD s where np.ItemNumber = s.ItemNumber)	
					  and np.Value >0										-- to pick up first Value --- tested it is working 12/2/2018
					--and np.ItemNumber in ('34.522.000','2851542072')
				group by np.ItemNumber,Comment
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
						,tb.Comment,tb.FCStartDate			
				     from tb left join l on tb.ItemNumber = l.ItemNumber)		--- not join by ShortItem Number as HD+MT Uploading do

			,ml as ( select tb_.fItemNumber
							,m.Description,m.SellingGroup,m.FamilyGroup,m.Family
							,m.StandardCost,m.WholeSalePrice,tb_.FCStartDate							
					from tb_ left join JDE_DB_Alan.Master_ML345 m on tb_.fItemNumber = m.ItemNumber ) -- ItemNumber short be 1:1 relation to ShortItemNum
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
					--,stg.FCStartDate		
					,cast(replace(convert(varchar(8),stg.FCStartDate,126),'-','') as integer) as CYM		 
					,cast(substring(replace(convert(varchar(8),stg.FCStartDate,126),'-',''),1,4) as integer) CY
					,cast(substring(replace(convert(varchar(8),stg.FCStartDate,126),'-',''),5,2) as integer) Month
					,'12' as PPY, '12' as PPC
					,0 as SalesQty					
					--,getdate() as ReportDate
				 from stg
					--where stg.fItemNumber in ('29115290720')		-- intentionally/deliberately to create a wrong SKU number by add '0' at end of SKU Number so query return no records, see if query will insert any value into table 'SlsHist_AWFHDMT_FCPro_upload' - 12/2/2018
				 -- where stg.fItemNumber in ('2911529072','2851542072')
					)
           --select top 5 fl.* from fl --where z.fItemNumber in ('2911529072')
        ,myfl as ( select fl.RowLabel,fl.SellingGroup,fl.FamilyGroup,fl.Family,fl.fItemNumber,fl.Description,fl.CY,fl.Month,fl.PPY,fl.PPC,fl.SalesQty,fl.CYM,getdate() as ReportDate
					 from fl
		           )   
           
		   --select * from myfl   
           --select top 5 myfl.* from myfl
			insert into JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload select * from myfl  --where myfl.fItemNumber in ('2911529072')
			select * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload l --where l.ItemNumber in ('2911529072')
			--delete from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload where ItemNumber in ('2911529072')


			--select l.ReportDate,count(l.ItemNumber) from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload l group by l.ReportDate


			------------------------------------------------------------------
			-- select * from dbo.vw_NP_FC
