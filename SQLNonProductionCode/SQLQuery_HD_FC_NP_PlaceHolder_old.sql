/****** Script for SelectTopNRows command from SSMS  ******/
SELECT  [ItemNumber]
      ,[Date]
      ,[Value]
      ,[DataType]
      ,[CN_Number]
      ,[Comment]
      ,[Creator]
      ,[LastUpdated]
      ,[ReportDate]
  FROM [JDE_DB_Alan].[JDE_DB_Alan].[FCPRO_NP_tmp]


select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('2801381810')
select * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload s where s.ItemNumber in ('2801381810')
select * from JDE_DB_Alan.MasterMTLeadingZeroItemList l


;with tb as (
		select distinct np.ItemNumber,Comment 
		from JDE_DB_Alan.FCPRO_NP_tmp np 
		where not exists( select distinct s.ItemNumber from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload s where np.ItemNumber = s.ItemNumber)
		--order by np.ItemNumber    
		)
	--select * from cte	 
	,l as ( select y.*,
				case 
					when y.ItemWithLeadingZero ='Y' then '0'+ y.ItemNumber
					else  y.ItemNumber		    
					end as myItemNumber
			from JDE_DB_Alan.MasterMTLeadingZeroItemList y   )

	,q as ( 
				select x.*,l.myItemNumber 
				from JDE_DB_Alan.Master_ML345 x left join l on x.ShortItemNumber = l.ShortItemNo 
				)
		--select * from m
	  
	,ml as ( select q.BU,
			case 
				when q.myItemNumber is null then q.ItemNumber
				else  q.myItemNumber		    
				end as fItemNumber
			  ,q.ShortItemNumber,q.description,q.SellingGroup,q.FamilyGroup,q.Family,q.Standardcost,q.WholeSalePrice					
				from q )

	,cte1 as (
	select ml.fItemNumber,ml.Description,ml.StandardCost,ml.WholeSalePrice
			,row_number() over(partition by ml.fitemnumber order by fitemnumber ) rn  
		from ml
		)
	,cte as (
		select * from cte1 
		where rn = 1 )
		--- Below will yield result for Combined MT + HD History Ready for Upload to Forecast Pro ---
	,fl as (
		select zz.RowLabel,zz.SellingGroup,zz.FamilyGroup,zz.Family,rtrim(ltrim(zz.FinalItemNumber)) as ItemNumber_,cte.Description,cte.standardcost,cte.wholesaleprice,zz.CYM,zz.CY,zz.Month,zz.PPY,zz.PPC,zz.SalesQty_
		from zz left join cte on zz.FinalItemNumber = cte.fItemNumber
		--  from zz inner join cte on zz.ItemNumber = cte.ItemNumber
		)

	select * from fl
