 use JDE_DB_Alan
 go
 
  with	l as ( select y.*,case 
						   when y.ItemWithLeadingZero ='Y' then '0'+ y.ItemNumber
							else  y.ItemNumber		    
						   end as myItemNumber
			from JDE_DB_Alan.MasterMTLeadingZeroItemList y      
				  ),
    l_ as ( select distinct l.ItemNumber,l.myItemNumber 
	            ,case when isnumeric(myItemNumber)=1 then cast(myItemnumber as float) else 0 end SortVal
			from l),

	--select * from l_ order by SortVal desc
	
	   fc as (	select 
				 case when 
						 l_.myItemNumber is null then f.ItemNumber
					 else l_.myItemNumber 
					 end as ItemNumber
				,f.DataType1
				,f.Value,f.Date,f.ReportDate
					
				--,sum(f.value) FCVol_ttl_24
			--from JDE_DB_Alan.FCPRO_Fcst f 		
			from JDE_DB_Alan.FCPRO_Fcst f left join l_ on f.ItemNumber = l_.ItemNumber
			--where f.DataType1 like ('%point%') 		
			--group by f.ItemNumber,f.DataType1
				)

	select * from fc
	--order by fc.ItemNumber
	 where fc.ItemNumber like ('%850531003021%')
	 order by fc.ItemNumber asc

----- update Master table -----------------------
;update m 
		set m.NewItemNumber = case m.ItemWithLeadingZero
									 when 'Y' then '0'+ m.ItemNumber
					                 else  m.ItemNumber		    
							  end 
from JDE_DB_Alan.MasterMTLeadingZeroItemList m 

SELECT * FROM [JDE_DB_Alan].[JDE_DB_Alan].[MasterMTLeadingZeroItemList]

----- update FCPRO_FC table --------------
;update fc 
 set fc.ItemNumber = m.NewItemNumber
from JDE_DB_Alan.FCPRO_Fcst fc inner join JDE_DB_Alan.MasterMTLeadingZeroItemList m on fc.ItemNumber = m.ItemNumber

select * from JDE_DB_Alan.FCPRO_Fcst fc where fc.ItemNumber like ('%850531003021%') order by fc.ItemNumber desc




--select distinct l.ItemNumber from JDE_DB_Alan.MasterMTLeadingZeroItemList l  


-----------------------------------------------------------------------------------------
 -- with	l as ( select y.*,case 
	--					   when y.ItemWithLeadingZero ='Y' then '0'+ y.ItemNumber
	--						else  y.ItemNumber		    
	--					   end as myItemNumber
	--		from JDE_DB_Alan.MasterMTLeadingZeroItemList y      
	--			  ),
 --   l_ as ( select distinct l.ItemNumber,l.myItemNumber 
	--            ,case when isnumeric(myItemNumber)=1 then cast(myItemnumber as float) else 0 end SortVal
	--		from l),

	----select * from l_ order by SortVal desc
	
	--   fc as (	select 
	--			 case when 
	--					 l_.myItemNumber is null then f.ItemNumber
	--				 else l_.myItemNumber 
	--				 end as ItemNumber
	--			,f.DataType1
	--			,f.ItemLvlFC_24 as ItemLvlFCVol_24
	--			,f.Pareto
	--			--,sum(f.value) FCVol_ttl_24
	--		--from JDE_DB_Alan.FCPRO_Fcst f 		
	--		from JDE_DB_Alan.FCPRO_Fcst_Pareto f left join l_ on f.ItemNumber = l_.ItemNumber
	--		where f.DataType1 like ('%point%') 		
	--		--group by f.ItemNumber,f.DataType1
	--			)

	--select * from fc
	----order by fc.ItemNumber
	-- where fc.ItemNumber like ('%85053%')


