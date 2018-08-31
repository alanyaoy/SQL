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

/****** Object:  View [dbo].[vw_NP_FC_Override_upload]    Script Date: 15/02/2018 9:55:27 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



--select * from JDE_DB_Alan.FCPRO_NP_tmp
 --select DATEADD(mm, DATEDIFF(m,0,GETDATE())+1,0)



--delete from JDE_DB_Alan.FCPRO_NP_tmp
--- create view as derived table from 'FCPRO_NP_tmp'

create view [dbo].[vw_NP_FC_Override_upload_] as



---------- Check if NP SKU is uploaded in FC Pro 14/02/2018 , Works  !------------------------
   
--;with tb as (
--		select np.ItemNumber,Comment,min(np.date) as FCStartDate
--		from JDE_DB_Alan.FCPRO_NP_tmp np 		
--		where not exists( 
--							select distinct f.ItemNumber from JDE_DB_Alan.FCPRO_Fcst f where np.ItemNumber = f.ItemNumber)				-- check with Forecast table not history ( unlike NP_PlaceHolder )					
--			  and np.Value >0										-- Need to pick up first Value --- tested it is working 12/2/2018
--			--and np.ItemNumber in ('34.522.000','2851542072')
--		group by np.ItemNumber,Comment
--		--order by np.ItemNumber 
--		)

--  select * from tb
--  order by tb.ItemNumber

  ---------- Load NP FC into FC Pro as Override Format --------------------------------------------------




--------------- Create FC Overrides File for FC Pro Uploading Using NP File ( Comptible with FC PRo Format with Date/Hierarchy ) --- 7/2/2018, 15/2/2018-------------------------
		--- Note The View does not allow Order by clause, so I also created a 'sp_NP_FC_Override_upload' --- 15/2/2018
--use JDE_DB_Alan
--go

with cte as (
				select m.*
						,row_number() over(partition by m.itemNumber order by itemnumber ) as rn 
				from JDE_DB_Alan.Master_ML345 m )
	,cte_ as (
					select * from cte where rn =1 
					--order by m.ItemNumber
				 )
	,ref_ as ( select *
						 ,row_number() over(partition by rf.itemNumber order by rf.Xref_Type) as rn 
				from JDE_DB_Alan.Master_ItemCrossRef rf where rf.Address_Number in ('20037'))		--please note there might be same item Number under multi suppliers!So need to filter here !
	,ref as ( select * from ref_ where rn=1)

	,npfc as ( select f.*
		 --,f.Date as Date_
					 ,convert(varchar(21),f.Date,103) as SimpDate
						 ,convert(varchar(4),f.date, 111) +'-'+ left (datename(mm,DATEADD(dd, DATEDIFF(d,0,f.Date)+1,0)),3) as WrongDate			-- wrong date as it will not advance year digit
						 ,convert(varchar(10),DATEADD(dd, DATEDIFF(d,0,f.Date)+1,0),120) as Right_Date
						 ,left(datename(mm,DATEADD(dd, DATEDIFF(d,0,f.Date)+1,0)),3) as Right_MthName
						 ,left(convert(varchar(10),DATEADD(dd, DATEDIFF(d,0,f.Date)+1,0),120),4) +'-'+ left(datename(mm,DATEADD(dd, DATEDIFF(d,0,f.Date)+1,0)),3) as Date_pro
						 ,convert(varchar(10),DATEADD(dd, DATEDIFF(d,0,f.Date)+1,0),120) as Date_
						-- ,cast(DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,GETDATE())+5,0)) as datetime) as startdate			-- Set the StartDate for changing from Jun/2018 onwards
						,'2018-02-01' as startdate1			-- Set the StartDate for changing from Jun/2018 onwards
						,'2018-06-01' as startdate2
				 from JDE_DB_Alan.FCPRO_NP_tmp f
				 where f.Value >0			--- Need to pick up FC Value from launch date,different SKU has different start date and we do not want to pick all the month ( ignore leading 0 ) -- 14/2/2018
					 )
	--select * from fc where fc.ItemNumber in ('2801381661','34.523.000,')
	,_npfc as (																										-- this is Monthly SKU level data
					select 'Total' as RowLabel
					 ,cte_.SellingGroup
							,cte_.FamilyGroup
							,cte_.Family
						 ,npfc.ItemNumber
						 ,npfc.Date_ 
						 ,npfc.Date_pro
						 --,'Override 1' as Row
						 ,'NP' as Row
						 ,isnull(npfc.Value,0) as Baseline
						 ,isnull(npfc.Value,0)as Formula
						,isnull(npfc.Value,0) as Override
						,npfc.Comment
						 ,npfc.LastUpdated
						 ,cte_.Description					 
					from npfc	 -- left join ref on fc.ItemNumber = ref.ItemNumber		--please note there might be same item Number under multi suppliers !
							 left join cte_ on npfc.ItemNumber = cte_.ItemNumber				 
						
					 --where ref.Address_Number in ('20037')
							--and fc.ItemNumber in ('27.176.320')						
					) 
		 ,stg as 
				(select _npfc.*
						,c.LongDescription as SellingGroup_
						,d.LongDescription as FamilyGroup_
						,e.LongDescription as Family_0
						--,tbl.Family as Family_1
						--,f.StandardCost,f.WholeSalePrice
						,p.Pareto
				from _npfc left join JDE_DB_Alan.MasterSellingGroup c on _npfc.SellingGroup = c.Code
						 left join JDE_DB_Alan.MasterFamilyGroup d on _npfc.FamilyGroup = d.Code
						 left join JDE_DB_Alan.MasterFamily e on _npfc.Family = e.Code
						 left join JDE_DB_Alan.FCPRO_Fcst_Pareto p on _npfc.ItemNumber = p.ItemNumber
				 )

	 ,npfc_ as ( select stg.RowLabel,SellingGroup_ as SellingGroup,stg.FamilyGroup_ as FamilyGroup,stg.Family_0 as Family,stg.ItemNumber
	 ,stg.Date_pro as date											--- for FC Pro Date Format 		 
						 ,stg.Row			
						 ,stg.Baseline,stg.Formula,stg.Override,stg.Comment
						 --,stg.LastUpdated	
						 ,convert(varchar(21),stg.LastUpdated,103) as LastUpdated_					--- for FC Pro Date Format
						 ,stg.Pareto
					from stg )

	--------- Execute elow to Output Format for Overrideing for Uploading into FC Pro ---------
	select * 																					
	from npfc_ 
	--where 
				--fc_.date is not null 
				--and fc_.ItemNumber in ('27.160.320','2770002534')
				-- and fc_.ItemNumber in ('27.160.785')
				--npfc_.ItemNumber in ('2801381661','2801381810')
	--order by npfc_.ItemNumber
	--		 ,left(npfc_.date,4) 
	--		 ,case right(npfc_.Date,3)	 when 'Jan' then 1
	--									 when 'Feb' then 2
	--									 when 'Mar' then 3
	--									 when 'Apr' then 4
	--									 when 'May' then 5
	--									 when 'Jun' then 6
	--									 when 'Jul' then 7
	--									 when 'Aug' then 8
	--									 when 'Sep' then 9
	--									 when 'Oct' then 10
	--									 when 'Nov' then 11
	--									 when 'Dec' then 12
	--			 end 


GO


