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

/****** Object:  StoredProcedure [JDE_DB_Alan].[sp_TextileFC_Analysis]    Script Date: 4/12/2019 3:07:59 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE  [JDE_DB_Alan].[sp_SlsHistoryHD_DW]  
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


	---------------------------------------------------------------------------------------------------------------------
		 -- xxxxxxxxxxx --- Get Sales History using  Invoive date ---xxxxxxxxxxxx --- in Data Warehouse  ---4/12/2019
select  h.jde_business_unit        
		,h.item_code,p.d_product_key		
		 ,p.price_group_desc
		 ,h.d_customer_key
		  ,c.customer_number
		 ,c.contact_name
		
		 ,p.family_group_desc
		 ,u.primary_uom_name 		 
		-- ,substring( cast(f.d_date_key as varchar) , 1, 6) Order_YYMM
		  ,cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,h.invoice_date),0),126),'-',''),1,6) as integer) as Inv_YYMM	
		,sum(h.primary_quantity)   primary_quantity		 

from [hd-vm-bi-sql01].HDDW_PRD.star.f_so_detail_history h left join  [hd-vm-bi-sql01].HDDW_PRD.star.d_product  p 	on h.d_product_key = p.d_product_key 
								left join [hd-vm-bi-sql01].HDDW_PRD.star.d_primary_uom u 	on h.d_primary_uom_key = u.d_primary_uom_key 
								left join [hd-vm-bi-sql01].HDDW_PRD.star.d_customer c on h.d_customer_key = c.d_customer_key

--where    d.item_code = '31121765'
where    h.item_code = '44.011.007'
  --where f.order_number in ('5456172')
   --  and h.invoice_date is not null				--- do you need to include SKUs with no invoice date but possible with Order date ?

group by h.jde_business_unit         
		 ,h.item_code,p.d_product_key	 
		 ,p.price_group_desc
		  ,h.d_customer_key
		  ,c.customer_number
		 ,c.contact_name

		 ,p.family_group_desc
		 ,u.primary_uom_name 
		 --,substring( cast(f.d_date_key as varchar) , 1, 6) Order_YYMM
		 ,cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,h.invoice_date),0),126),'-',''),1,6) as integer) 
 order by h.item_code
         -- ,cast(substring( cast(f.d_date_key as varchar) , 1, 6) as int)
		  ,cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,h.invoice_date),0),126),'-',''),1,6) as integer)



 END
GO


