create view [JDE_DB_Alan].[vw_Mast] with schemabinding as
--- please note following view for Master only includes Items which is forecastable ---
with fc as (
		select f.ItemNumber,f.DataType1,f.Date
				,convert(varchar(7),f.Date,120) as FCDate_
				,datepart(year,f.date) fcyr
				,datepart(month,f.date) fcmth
				,f.Value as FC_Vol
		from JDE_DB_Alan.FCPRO_Fcst f 
		where f.Date < DATEADD(mm, DATEDIFF(m,0,GETDATE())+5,0)	and f.DataType1 in ('Adj_FC')
				--and f.ItemNumber in ('45.103.000','45.200.100') 
          )
    
	,po as (																				-- do you need to use po table in this query ? Maybe not   --- 6/68/2018
		select p.ItemNumber,'WIP' as DataType1,p.DueDate
				,convert(varchar(7),p.DueDate,120) as PODate_
				,datepart(year,p.DueDate) poyr
				,datepart(month,p.DueDate ) pomth
				,p.QuantityOrdered as PO_Vol
		 from JDE_DB_Alan.OpenPO p 
		where  p.DueDate < DATEADD(mm, DATEDIFF(m,0,GETDATE())+8,0)
			--	and p.ItemNumber in ('45.103.000','45.200.100')    
		 )
		 --- get your master ---
	 ,_mas as (
            select   m.BU
					,m.ItemNumber
				   ,m.ShortItemNumber
				    ,m.StockingType,m.PlannerNumber,m.PrimarySupplier
					,m.StandardCost,m.WholeSalePrice,m.Description,m.QtyOnHand 	
					,m.LeadtimeLevel
					,m.UOM,m.ConvUOM,m.ConversionFactor						
					,case when isnull(round(m.LeadtimeLevel/30,0),0) <0.5 then 1
					      else isnull(cast(round(m.LeadtimeLevel/30,0) as int),0 ) end as Leadtime_Mth
					,c.LongDescription as SellingGroup_
					,d.LongDescription as FamilyGroup_
					,e.LongDescription as Family_0		
			        ,convert(varchar(7),GETDATE(),120) as SOHDate
					,convert(varchar(7),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),120) as SOHDate_
					,datepart(year,GETDATE()) masyr
				  ,datepart(month,GETDATE()) masmth
				  ,datepart(day,GETDATE()) masdte
				  ,row_number() over(partition by m.itemNumber order by itemnumber ) as rn     -- filter out duplicate records
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
				  ,m.Colour	
				  ,m.ReportDate as OrigMasterDataDate			

			from  JDE_DB_Alan.Master_ML345 m 
			         left join JDE_DB_Alan.MasterSellingGroup c  on m.SellingGroup = c.Code
					 left join JDE_DB_Alan.MasterFamilyGroup d  on m.FamilyGroup = d.Code
					 left join JDE_DB_Alan.MasterFamily e  on m.Family = e.Code							 	   
			 --where exists ( select fc.ItemNumber from fc where fc.ItemNumber = m.ItemNumber )   --- Probably need to remove this condition as it has significant impact on performance and any code using this view table --- 30/5/2018

			  )  			   
     ,mas_ as (
				select m.BU,m.ItemNumber,m.ShortItemNumber,m.StockingType,m.PlannerNumber,m.PrimarySupplier
				     ,m.SellingGroup_,m.FamilyGroup_,m.Family_0
					,m.StandardCost,m.WholeSalePrice,m.Description,m.QtyOnHand,m.SOHDate,m.SOHDate_
					,m.masyr,m.masmth,m.masdte
					,m.LeadtimeLevel
					,m.UOM
					,m.ConvUOM
					,m.ConversionFactor
					,m.Leadtime_Mth
					,m.rn 
					,m.SellingGroup,m.FamilyGroup,m.Family
					,m.GLCat,m.StockValue
					,m.Owner_
					,m.Colour
					,m.OrigMasterDataDate
					
				from _mas as m where rn =1  )

      ,mas as (select a.BU,a.ItemNumber,a.ShortItemNumber,a.StockingType,a.PlannerNumber,a.PrimarySupplier
	             ,a.SellingGroup_,a.FamilyGroup_,a.Family_0
				,a.StandardCost,a.WholeSalePrice,a.Description,a.Colour,a.QtyOnHand,a.SOHDate,a.SOHDate_
				,a.masyr,a.masmth,a.masdte
				,a.LeadtimeLevel
				,a.UOM,a.ConvUOM,a.ConversionFactor	
				,a.Leadtime_Mth
				,a.rn
				,a.SellingGroup,a.FamilyGroup,a.Family 	
				,a.GLCat,a.StockValue	
				,a.Owner_
				,s.SupplierName				
				,case 
					when wc.WorkCenter is not null then wc.WorkCenter
					--when wc.WorkCenter is null then 'No_WC_Assigned'		
					  when wc.WorkCenter is null then '0'		
					end as WC	
				,a.OrigMasterDataDate

                from mas_ a left join JDE_DB_Alan.MasterSupplier s on a.PrimarySupplier = s.SupplierNumber
				            left join JDE_DB_Alan.TextileWC wc on a.ShortItemNumber = wc.ShortItemNumber
     -- where a.ItemNumber in ('42.210.031')
	 	          )

      select a.BU,a.ItemNumber,a.ShortItemNumber,a.StockingType,a.PlannerNumber,a.PrimarySupplier
	             ,a.SellingGroup_,a.FamilyGroup_,a.Family_0
				,a.StandardCost,a.WholeSalePrice,a.Description,a.Colour,a.QtyOnHand,a.SOHDate,a.SOHDate_
				,a.masyr,a.masmth,a.masdte
				,a.LeadtimeLevel
				,a.UOM,a.ConvUOM,a.ConversionFactor	
				,a.Leadtime_Mth
				,a.rn
				,a.SellingGroup,a.FamilyGroup,a.Family 	
				,a.GLCat,a.StockValue	
				,a.Owner_
				,a.SupplierName				
				,WC	
				,a.OrigMasterDataDate

                from mas a

	   --select * from mas 
	   --where z.wc <> '0'