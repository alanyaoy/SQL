
   	--- Updated 21/5/2021 to remove/prevent  duplicate in HD (Textile) Work Center --------

    --- Created on 18/8/2020 ---- Use Single Select SQL command ------ Re write code ---- Will this be more efficient in term of performance if use base Master table 
	--- this will help to create view Index becuase View Index does not support ------ 

    --- Updated 4/6/2020 to include Pareto, Safety stock details ------

--CREATE view [JDE_DB_Alan].[vw_Mast] with schemabinding as
--- please note following view for Master only includes Items which is forecastable ---


create view [JDE_DB_Alan].[vw_Mast_Classic_No_4102APlanning] as

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
			when wc.WorkCenterCode_f is not null then wc.WorkCenterCode_f
			--when wc.WorkCenter is null then 'No_WC_Assigned'		
				when wc.WorkCenterCode_f is null then '0'		
			end as WCCode_fl
		,case 
				when wc.WorkCenterName_f is not null then wc.WorkCenterName_f
				--when wc.WorkCenter is null then 'No_WC_Assigned'		
					when wc.WorkCenterName_f is null then '0'		
		end as WCName_fl					
        ,case 
			when wc.WorkCenterGroupCode_f is not null then wc.WorkCenterGroupCode_f
			--when wc.WorkCenter is null then 'No_WC_Assigned'		
				when wc.WorkCenterGroupCode_f is null then '0'		
			end as WCGroupCode_fl
            ,case 
			when wc.WorkCenterGroupName_f is not null then wc.WorkCenterGroupName_f
			--when wc.WorkCenter is null then 'No_WC_Assigned'		
				when wc.WorkCenterGroupName_f is null then '0'		
			end as WCGroupName_fl

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

        left join ( select a.ShortItemNumber as ShortItemNumber_wc,a.WorkCenterCode_f,a.WorkCenterName_f,a.WorkCenterGroupCode_f,a.WorkCenterGroupName_f
		             from JDE_DB_Alan.HD_WorkCenter a ) wc 
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
  --where ItemNumber in ('82.028.903','82.068.911','40.041.131')

GO