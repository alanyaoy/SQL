--drop view dbo.vw_create_pareto
create view [dbo].[vw_Create_Pareto] as 		

		with fc as ( select f.ItemNumber,f.DataType1,f.Date,f.Value * px.WholeSalePrice as value,px.SellingGroup,px.FamilyGroup,px.Family
					 from JDE_DB_Alan.FCPRO_Fcst f left join JDE_DB_Alan.Px_AWF_HD_MT_FCPro_upload px 					 
							on f.ItemNumber = px.ItemNumber
					 where f.DataType1 like ('%default%') 
					),		
							
		sm as ( select t.ItemNumber,t.SellingGroup,t.FamilyGroup,t.Family,t.DataType1,coalesce(sum(t.Value),0) as ItemLvlFC_24_Amt from fc as t 
					-- where 
						--t.DataType1 in ('WholeSalePrice') and 
					--	t.ItemNumber in ('2851218661','18.615.024','26.803.676','4250084126','4150951785','2851236862')
					group by t.ItemNumber,t.SellingGroup,t.FamilyGroup,t.Family,t.DataType1 
					--order by t.DataType1, sum(t.Value) desc
						),		 
		x as (
			select *
					,sum(sm.ItemLvlFC_24_Amt) over(partition by sm.DataType1) as GrandTTL
					,cast(coalesce(sm.ItemLvlFC_24_Amt/nullif(sum(sm.ItemLvlFC_24_Amt) over(partition by sm.DataType1),0),0) as decimal(18,12)) as Pct
				--,(select sum(value) from FCPRO_Fcst where id<=t.id)/(select sum(value) from FCPRO_Fcst ) as Running_Percent	 
			from sm
			--order by FCPRO_Fcst.value
				),

		--select * from x order by x.DataType1,x.ItemLvlFC_24 desc
		--- Sort the records First Very important !---
		y as ( select x.*,row_number() over ( partition by x.DataType1 order by x.Pct desc) as rnk
				from x ),

		tbl as (
				select y.*,sum(y.ItemLvlFC_24_Amt) over (partition by y.DataType1 order by y.rnk ) as RunningTTL from y ),


		--- Calculate Percentage ( And if there is an% sign in number remove it first )
		ftb as ( select tbl.ItemNumber,tbl.SellingGroup,tbl.FamilyGroup,tbl.Family,tbl.DataType1
					,tbl.ItemLvlFC_24_Amt,tbl.RunningTTL,tbl.GrandTTL,tbl.Pct,(tbl.RunningTTL/tbl.GrandTTL) as RunningTTLPct,tbl.rnk
						, (case 
								when convert(decimal(18,2),replace((tbl.RunningTTL/tbl.GrandTTL),'%','')) < 0.800001 then 'A'		---20
								when convert(decimal(18,5),replace((tbl.RunningTTL/tbl.GrandTTL),'%','')) < 0.95 then 'B'		---30
								else 'C' end ) as Pareto																		---50
					from tbl
					),

		fltb as (select *,GETDATE() as ReportDate from ftb 
					--where ftb.DataType1 like (@DataType1)
					)
		 select * from fltb

		

----------------------------------------------------------------------------------

--bcp " select * from JDE_DB_Alan.dbo.vw_create_pareto p where p.itemnumber in ('24.012.160s') " queryout C:\Users\yaoyu\Documents\Documents_Lenovo_Yoga_710\coutt.txt -S DESKTOP-ANE9ABR\HOME_2016EXPAD -c -t, -T
GO
