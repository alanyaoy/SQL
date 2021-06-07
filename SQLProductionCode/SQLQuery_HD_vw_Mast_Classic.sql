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

/****** Object:  View [JDE_DB_Alan].[vw_Mast_Classic]    Script Date: 21/05/2021 4:14:53 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


   	--- Updated 21/5/2021 to remove/prevent  duplicate in HD (Textile) Work Center --------

    --- Created on 18/8/2020 ---- Use Single Select SQL command ------ Re write code ---- Will this be more efficient in term of performance if use base Master table 
	--- this will help to create view Index becuase View Index does not support ------ 

    --- Updated 4/6/2020 to include Pareto, Safety stock details ------

--CREATE view [JDE_DB_Alan].[vw_Mast] with schemabinding as
--- please note following view for Master only includes Items which is forecastable ---


ALTER view [JDE_DB_Alan].[vw_Mast_Classic] as

--select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('42.210.031')
--select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('42.210.031')

select ItemNumber,ShortItemNumber,Colour,StockingType,Pareto,SS_Adj,PlannerNumber,Owner_,PrimarySupplier,SupplierName,FamilyGroup_,Family_0,SellingGroup_
		,LeadtimeLevel,UOM,ConvUOM,ConversionFactor,Leadtime_Mth
		,StandardCost,WholeSalePrice,Description,QtyOnHand
		,convert(varchar(7),GETDATE(),120) as SOHDate
		,convert(varchar(7),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),120) as SOHDate_
		,datepart(year,GETDATE()) masyr,datepart(month,GETDATE()) masmth,datepart(day,GETDATE()) masdte
		,GLCat,StockValue,rn,SellingGroup,FamilyGroup,Family
	    ,case 
			when WC_Group is not null then WC_Group								
			when WC_Group is null then '0'		
			end as WC_Grp 
         ,case 
			when WC_Code is not null then WC_Code							
			when WC_Code is null then '0'		
		end as WC_Cde  
		,LocalImport,CycleCount
		,OrigMasterDataDate
from 
    ((((((( select * from 
		( select m.BU,m.ItemNumber,m.ShortItemNumber,m.StockingType,m.PlannerNumber,m.PrimarySupplier,m.StandardCost,m.WholeSalePrice,m.Description
				,m.QtyOnHand,m.LeadtimeLevel,m.UOM,m.ConvUOM,m.ConversionFactor
				,case when isnull(round(m.LeadtimeLevel/30,0),0) <0.5 then 1
					      else isnull(cast(round(m.LeadtimeLevel/30,0) as int),0 ) end as Leadtime_Mth
				 ,m.SellingGroup,m.Family,m.FamilyGroup
				  ,m.GLCat,m.StockValue
				  ,case m.PlannerNumber when '20072' then 'Salman Saeed'
						when '20004' then 'Margaret Dost'	
						when '20005' then 'Imelda Chan'
						when '20071' then 'Rosie Ashpole'
						when '20003' then 'Lee Roise'
						when '30036' then 'Violet Glodoveza'
						when '30039' then 'Ben'
						when '29917' then 'Metals Planner'
						when '20065' then 'AWF RollForming'
						when '2519718' then 'CutLength Planner'
						--when '20071' then 'Domenic Cellucci'
						else 'Unknown'
					end as Owner_
				  ,m.Colour,m.localImport,m.CycleCount
				  ,m.ReportDate as OrigMasterDataDate					
		        ,row_number() over(partition by m.itemNumber order by itemnumber) as rn from JDE_DB_Alan.Master_ML345 m ) a
	      where a.rn <2 ) b 

		left join (select Code, LongDescription as SellingGroup_ from JDE_DB_Alan.MasterSellingGroup ) c 
					on b.SellingGroup = c.Code )
		left join (select code, LongDescription as FamilyGroup_ from JDE_DB_Alan.MasterFamilyGroup ) d  
					on b.FamilyGroup = d.Code )
		left join (select code, LongDescription as Family_0	 from JDE_DB_Alan.MasterFamily ) e 
					on b.Family = e.Code )
				
		left join ( select SupplierNumber,SupplierName from JDE_DB_Alan.MasterSupplier ) s 
					on b.PrimarySupplier = s.SupplierNumber
	---	left join ( select ShortItemNumber as ShortItemNumber_wc,WorkCenter,WorkCenterName
		         --    from JDE_DB_Alan.TextileWC ) wc 
				--	on b.ShortItemNumber = wc.ShortItemNumber_wc )

        left join ( select a.ShortItemNumber as ShortItemNumber_wc,a.WC_Code,a.WC_Group
		             from JDE_DB_Alan.vw_HD_WorkCenter a ) wc 
					on b.ShortItemNumber = wc.ShortItemNumber_wc )

        left join ( select ItemNumber as ItemNumber_p, Pareto  from  JDE_DB_Alan.FCPRO_Fcst_Pareto )  p 
					on b.ItemNumber = p.ItemNumber_p)
		left join ( select * from
					   (select ItemNumber as ItemNumber_ss ,SS_Adj,dense_rank() over ( partition by x.itemNumber order by x.reportdate desc ) rk_2_dense	
						 from JDE_DB_Alan.FCPRO_SafetyStock x) y
						 where y.rk_2_dense = 1

						)  ss 
					on b.ItemNumber = ss.ItemNumber_ss )

    -- where b.StockingType in ('P','Q','M','S')							--- 'O' has 37018 records, 'U' has 3096 records, ML_345 table has total 48572 records, 'O' & 'U' occupy about 80% of total count.

  --where ItemNumber in ('24.7111.1858A')

GO


