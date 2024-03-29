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
/****** Object:  StoredProcedure [JDE_DB_Alan].[sp_TextileFC_Analysis]    Script Date: 18/05/2020 2:10:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE  [JDE_DB_Alan].[sp_TextileFC_Analysis]  
	-- Add the parameters for the stored procedure here
	--<@Param1, sysname, @p1> <Datatype_For_Param1, , int> = <Default_Value_For_Param1, , 0>, 
	--<@Param2, sysname, @p2> <Datatype_For_Param2, , int> = <Default_Value_For_Param2, , 0>

	-- This Store Procedure Refresh vw_NP_FC_Analysis  --- 12/3/2018 
	--- Is this Robust way to refresh View in SQL Server ? --- At least you need to implement Schemabinding in View !
AS

 BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	--SELECT <@Param1, sysname, @p1>, <@Param2, sysname, @p2>

	--select  cast(DATEADD(mm, DATEDIFF(mm, 0, GETDATE())-1, 0) as datetime)				--- Last Month

	--- export Textile FC details in conjunction with Cross ref, also include Master data info, in Waterfall format ---
	--- this can help to check Textile forecast accuracy ----- 22/10/2019



		----------Textile FC in nice format -------------
	;with _tfc as
		 (
			select *
					,cast(SUBSTRING(REPLACE(CONVERT(char(10),t.Date,126),'-',''),1,6) as integer) as YM_FC_Date
					,cast(SUBSTRING(REPLACE(CONVERT(char(10),t.Reportdate,126),'-',''),1,6) as integer) YM_Report_Date 
					,cast(REPLACE(CONVERT(char(10),t.Reportdate,126),'-','') as integer) YMD_Report_Date
			from JDE_DB_Alan.TextileFC t
			)

		 , tfc_ as 
			( select a.ArticleNumber,a.ArticleDescription
			         ,c.HDItemNumber,m.Description,m.Colour
					,a.Quantity,a.ArticleUOM,a.YM_FC_Date,a.YM_Report_Date,a.YMD_Report_Date,a.Reportdate,a.Vendor
					,m.family,m.familygroup
					,GETDATE() as AnalysisReporDate

				from _tfc a left join JDE_DB_Alan.Textile_ItemCrossRef c on a.ArticleNumber = c.SupplierItemNumber
							 left join JDE_DB_Alan.vw_Mast m on c.HDItemNumber = m.ItemNumber 
			 )

		select z.ArticleNumber,ArticleDescription
			   ,case when z.HDItemNumber is null then 'Not_Find'
			         when z.HDItemNumber is not null then z.HDItemNumber
					 end as HD_Item
				,case when z.Description is null then 'Not_Find'
			         when  z.Description is not null then z.Description
					 end as HD_Descp
				,case when z.Colour is null then 'Not_Find'
			         when  z.Colour is not null then z.Colour
					 end as Colour_
		       ,z.Quantity,z.ArticleUOM,z.YM_FC_Date,z.YMD_Report_Date,z.Reportdate,z.Vendor,z.Family,z.FamilyGroup
			   ,z.AnalysisReporDate
		from tfc_ z
		---where z.ArticleNumber in ('1015637')
		order by z.Reportdate




 END
