/*    ==Scripting Parameters==

    Source Server Version : SQL Server 2016 (13.0.4001)
    Source Database Engine Edition : Microsoft SQL Server Express Edition
    Source Database Engine Type : Standalone SQL Server

    Target Server Version : SQL Server 2017
    Target Database Engine Edition : Microsoft SQL Server Standard Edition
    Target Database Engine Type : Standalone SQL Server
*/

USE [JDE_DB_Alan]
GO
/****** Object:  StoredProcedure [JDE_DB_Alan].[sp_Cal_Create_Pareto]    Script Date: 6/06/2018 10:02:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [JDE_DB_Alan].[sp_Cal_Create_Pareto] 
	-- Add the parameters for the stored procedure here
	--<@Param1, sysname, @p1> <Datatype_For_Param1, , int> = <Default_Value_For_Param1, , 0>, 
	--<@Param2, sysname, @p2> <Datatype_For_Param2, , int> = <Default_Value_For_Param2, , 0>
	@DataType1 varchar(100) = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from interfering with SELECT statements.
	SET NOCOUNT ON;  
	   
			------Method 1. use Order by works this is fastest takes 2 sec awesome !-----------
				--- Get ItemLvl FC ---

		delete from JDE_DB_Alan.FCPRO_Fcst_Pareto		
		
			-- this is old code ---
		--;with fc as ( select f.ItemNumber,f.DataType1,f.Date,f.Value * px.WholeSalePrice as value,px.SellingGroup,px.FamilyGroup,px.Family
		--				 from JDE_DB_Alan.FCPRO_Fcst f left join JDE_DB_Alan.Px_AWF_HD_MT_FCPro_upload px 					 
		--						on f.ItemNumber = px.ItemNumber
		--				  --where f.DataType1 like ('%default%')    
		--				  where f.DataType1 like ('%Adj_FC%')			-- 26/2/2018
		--				),	


	  ;with fc as ( select f.ItemNumber,f.DataType1,f.Date,f.Value * m.WholeSalePrice as value,m.SellingGroup_,m.FamilyGroup_,m.Family_0,m.StockingType,m.PlannerNumber
					 from JDE_DB_Alan.FCPRO_Fcst f left join JDE_DB_Alan.vw_Mast m 					 
							on f.ItemNumber = m.ItemNumber
					  --where f.DataType1 like ('%default%')    
					  where f.DataType1 like ('%Adj_FC%')			-- 26/2/2018
					),		
	 
						
		sm as ( select t.ItemNumber,t.SellingGroup_,t.FamilyGroup_,t.Family_0,t.DataType1,t.StockingType,t.PlannerNumber,coalesce(sum(t.Value),0) as ItemLvlFC_24_Amt from fc as t 
					-- where 
						--t.DataType1 in ('WholeSalePrice') and 
					--	t.ItemNumber in ('2851218661','18.615.024','26.803.676','4250084126','4150951785','2851236862')
					group by t.ItemNumber,t.SellingGroup_,t.FamilyGroup_,t.Family_0,t.DataType1,t.StockingType,t.PlannerNumber
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
		ftb as ( select tbl.ItemNumber,tbl.SellingGroup_,tbl.FamilyGroup_,tbl.Family_0,tbl.DataType1
					,tbl.ItemLvlFC_24_Amt,tbl.RunningTTL,tbl.GrandTTL,tbl.Pct,(tbl.RunningTTL/tbl.GrandTTL) as RunningTTLPct,tbl.rnk
						, (case 
								when convert(decimal(18,2),replace((tbl.RunningTTL/tbl.GrandTTL),'%','')) <=0.800001 then 'A'		---20
								when convert(decimal(18,5),replace((tbl.RunningTTL/tbl.GrandTTL),'%','')) < 0.95 then 'B'		---30
								else 'C' end ) as Pareto																		---50
                    ,tbl.StockingType,tbl.PlannerNumber
					from tbl
					),

		fltb as (select *,GETDATE() as ReportDate from ftb 
					--where ftb.DataType1 like (@DataType1)
					)
		insert into JDE_DB_Alan.FCPRO_Fcst_Pareto select * from fltb
		select * from JDE_DB_Alan.FCPRO_Fcst_Pareto p order by p.rnk
		--where ftb.DataType1 like ('%price') and ftb.rnk =819
	

	


END
