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
/****** Object:  StoredProcedure [JDE_DB_Alan].[sp_FCPro_Create_Pareto_old]    Script Date: 14/11/2017 11:38:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [JDE_DB_Alan].[sp_FCPro_Create_Pareto_old] 
	-- Add the parameters for the stored procedure here
	--<@Param1, sysname, @p1> <Datatype_For_Param1, , int> = <Default_Value_For_Param1, , 0>, 
	--<@Param2, sysname, @p2> <Datatype_For_Param2, , int> = <Default_Value_For_Param2, , 0>
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	--SELECT <@Param1, sysname, @p1>, <@Param2, sysname, @p2>
	---------------------Method 1. use Order by works this is fastest takes 2 sec awesome !-----------------------------------------------------------------
		--- Get ItemLvl FC ---
		with sm as ( select t.ItemNumber,t.SellingGroup,t.FamilyGroup,t.Family,t.DataType1,sum(t.Value) as ItemLvlFC_24 from JDE_DB_Alan.FCPRO_Fcst as t 
					 where 
						t.DataType1 in ('WholeSalePrice') 
						-- and t.ItemNumber in ('2851218661','18.615.024','26.803.676','4250084126','4150951785','2851236862')
					group by t.ItemNumber,t.SellingGroup,t.FamilyGroup,t.Family,t.DataType1 
					--order by t.DataType1, sum(t.Value) desc
					 ),		 
		x as (
		select *
				 ,(select sum(ItemLvlFC_24) from sm) as GrandTTL
				 ,cast(sm.ItemLvlFC_24/(select sum(sm.ItemLvlFC_24) from sm ) as decimal(18,12)) as Pct
				--,(select sum(value) from FCPRO_Fcst where id<=t.id)/(select sum(value) from FCPRO_Fcst ) as Running_Percent	 
			from sm
			--order by FCPRO_Fcst.value
		),

		--- Sort the records First Very important !---
		y as ( select x.*,row_number() over ( order by x.Pct desc) as rnk
				from x ),

		tbl as (
				select y.*,sum(y.ItemLvlFC_24) over (order by rnk ) as RunningTTL from y ),


		--- Calculate Percentage ( And if there is an% sign in number remove it first )
		ftb as ( select tbl.ItemNumber,tbl.SellingGroup,tbl.FamilyGroup,tbl.Family,tbl.DataType1
					,tbl.ItemLvlFC_24,tbl.RunningTTL,tbl.GrandTTL,tbl.Pct,(tbl.RunningTTL/tbl.GrandTTL) as RunningTTLPct,tbl.rnk
					 , (case 
								when convert(decimal(18,2),replace((tbl.RunningTTL/tbl.GrandTTL),'%','')) < 0.80 then 'A'		---20
								when convert(decimal(18,5),replace((tbl.RunningTTL/tbl.GrandTTL),'%','')) < 0.95 then 'B'		---30
								else 'C' end ) as Pareto																		---50
					from tbl
					)

		select * from ftb --where ftb.rnk =819

END
