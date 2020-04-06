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
/****** Object:  StoredProcedure [JDE_DB_Alan].[sp_FCPro_FC_Accy_Group]    Script Date: 4/04/2020 10:17:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/****** Object:  StoredProcedure [JDE_DB_Alan].[sp_FCPro_Portfolio_Analysis]    Script Date: 29/01/2018 9:17:10 AM ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [JDE_DB_Alan].[sp_FCPro_FC_Accy_Group] 
	-- Add the parameters for the stored procedure here
	--<@Param1, sysname, @p1> <Datatype_For_Param1, , int> = <Default_Value_For_Param1, , 0>, 
	--<@Param2, sysname, @p2> <Datatype_For_Param2, , int> = <Default_Value_For_Param2, , 0>

	 @Measurement_id varchar(100) = null
	-- @Supplier_id varchar(8000) = null
	-- ,@Item_id varchar(8000) = null
	-- ,@DataType varchar (100) = null
	--,@ItemNumber varchar(100) = null
	--,@ShortItemNumber varchar(100) = null
	--,@CenturyYearMonth int = null
	--,@OrderByClause varchar(1000) = null
	


AS
BEGIN
-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	--set @OrderByClause = 'rnk'	

-- Insert statements for procedure here
	--SELECT <@Param1, sysname, @p1>, <@Param2, sysname, @p2>

	 --- Note this FC Analysis Are using Data from FC History table ( but only 1 month FC history data ) not FC table ( if you need using FC History this is best choice ) --- 4/9/2018

	 --- Point Need to Consider for Forecast Accuracy Report: ---------- 11/1/2019	 
	 --1. Note that we only save forecast for next month ie if you are in Oct you save forecast for Nov ( saved FC will not include Oct FC ), forecast should considered on day base that will make things /logic easy to understand
	 --   This is important when you read your report result for which month forecast you need to pick up
	 --2. Choosing to use XX or YY value in CalMth will have impact on final result
	 --3. Note time function in MS SQL like  'cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-2,0),126),'-',''),1,6) as integer) ' might have different meaning when you get your result, do not get fooled by -2 or -1 in formula, Oftern you when -2 it actually mean you get 1 month away
	 --4. We forecast monthly not daily or weekly, lead time is also rounded to Monthly not daily or weekly otherwise calculation/code will to be revised
	 --5. Need to under [StartDate] is actually ReportDate in Integer format in FC table
	
	 --- 26/2/2020
	 --6. Note this code is calculate fc accy on Group level ( Family group And Fmaily ), and store all data together. 
	     -- data are differentiate by Data type, Hierarchy, Hierarchy description.
     --7. Note there is dependecy before running this code. First you need to run 'sp_FCPro_FC_Accy_SKU' to get SKU error data. Then tbl 'FCPro_Accy-SKU' will be populated. Then below code can be run to get Group level ( Familygroup, Family ) error and accuracy data.
	 --8. Perhaps need to stort this data into a table


	 --- Point Need to Consider for Forecast Accuracy Report: ---------- 21/08/2019	 updated
	 --1. this update fix the issue of has sales but not forecasted ( if lead time is very long - 26.045.0696 )
	 --2. If you want to exclude items that falls in above category ( ie not forecasted item, you can re - instate old code )
	 ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------


	 --- Updated 3/4/2020
	 --- Add code for err, acc etc 
	 --- Find way to avoid divide by zero; and how to select greater value out of 2 or multiple values 


	--delete from JDE_DB_Alan.FCPRO_FC_Accy_Fam_Grp			--- do you want to delete Fcst_Accuracy data every time, is there any such need - maybe you need in test environment ?  --- 8/6/2018
	
	-- if you do not want to delete records every single time, You can avoid this by making Primary key as including 'ReportDate' so here is primary key --> primary key (Item,Date_,DataType,ReportDate)	--- 11/1/2019
	-- it will be good idea to keep accuracy data so better not delete it --- 11/1/2019
	 
	
		------------------------ combined together --------------------------- 25/2/2020

			--- family group, level 1 data --- using it own Bias ( V1), not bias from Family ( V2)  or SKU (V3) ---
		;with _t as 
			   (
					select a.DataType,a.FamilyGroup_ as Hierarchy_0,a.FamilyGroup as Hierarchy_abb,a.LT_Type,sum(a.Sales) as Sls_agrg,sum(a.Fcst) as FC_agrg
					from  JDE_DB_Alan.FCPRO_FC_Accy_SKU a 
					where 
							 a.FamilyGroup_ <> ('991 / SCREEN DOOR')
							--and a.DataType in ('Units')												-- only measure 'Unit' at the moment,if need, can include 'Dollars' in future --- 26/2/2020
					group by a.DataType,a.FamilyGroup_,a.FamilyGroup,a.LT_Type
				  )

			 ,t_ as (  select _t.*
						, sum(_t.Sls_agrg) over(partition by _t.DataType order by _t.DataType) as Sls_Gnd, sum(_t.FC_agrg) over(partition by _t.DataType order by _t.DataType) as FC_Gnd,'FamilyGroup_' as Hierarchy_Cat,'V1' as Version_Lv
						from  _t        
					  )
			  -- select * from t_

			--- family, level 1 data --- using it own Bias ( V1), not bias from SKU ( V3) ---
			 ,_tt as 
			   (
					select a.DataType,a.Family_0 as Hierarchy_0,a.Family as Hierarchy_abb,a.LT_Type,sum(a.Sales) as Sls_aggrg,sum(a.Fcst) as FC_aggrg
					from  JDE_DB_Alan.FCPRO_FC_Accy_SKU a 
					where 
							   a.FamilyGroup_ <> ('991 / SCREEN DOOR')
							-- and a.DataType in ('Units')												-- only measure 'Unit' at the moment,if need, can include 'Dollars' in future   --26/2/2020
					group by a.DataType,a.Family_0,a.Family,a.LT_Type
				  )

			 ,tt_ as (  select _tt.*, sum(_tt.Sls_aggrg) over(partition by _tt.DataType order by _tt.DataType) as Sls_Gnd, sum(_tt.FC_aggrg) over(partition by _tt.DataType order by _tt.DataType) as FC_Gnd,'Family_' as Hierarchy_Cat,'V1' as Version_Lv
						from  _tt
        
					  )

			 ,_comb as ( select * from t_
						  union all
						select * from tt_
						)

			 ,_comb_ as (select b.DataType,b.Hierarchy_0,b.Hierarchy_abb,b.Sls_agrg as Sls_,b.FC_agrg as FC_            
						,b.Sls_Gnd,b.FC_Gnd,b.Hierarchy_Cat,b.Version_Lv,b.LT_Type

						 from _comb b
						--order by b.Hierarchy_Descp desc,b.Hierarchy_ desc
						)

			 ,comb_ as ( select b.DataType,b.Hierarchy_0,b.Hierarchy_abb,b.Sls_,b.FC_,(b.Sls_ - b.FC_) as Bias_,abs(b.Sls_ - b.FC_) as Abs_     
			                    ,(select max(v) from ( values (b.Sls_),(b.FC_) ) as  Alldmd(v) ) as Maxdmd							-- this is genius solutions to choose greater value out of 2 or multiple value --- 3/4/2020 -- https://stackoverflow.com/questions/71022/sql-max-of-multiple-columns   --- https://stackoverflow.com/questions/124417/is-there-a-max-function-in-sql-server-that-takes-two-values-like-math-max-in-ne  
								,b.Sls_Gnd,b.FC_Gnd,b.Hierarchy_Cat,b.Version_Lv,b.LT_Type
						  from _comb_ b

						  )
             
			-- select * from comb_
			 , comb as ( select b.DataType,b.Hierarchy_0,b.Hierarchy_abb,b.Sls_,b.FC_,b.Bias_,b.Abs_
								,sum(b.Bias_) over(partition by b.DataType, Hierarchy_Cat ) as Bias_ttl
								,sum(b.Abs_) over(partition by b.DataType, Hierarchy_Cat ) as Abs_ttl
								,b.Sls_Gnd,b.FC_Gnd,b.Hierarchy_Cat,b.Version_Lv,b.LT_Type
								,coalesce(b.Abs_/nullif(b.Sls_,0),0) as err1,coalesce(b.Abs_/nullif(b.FC_,0),0) as err2, coalesce(b.Abs_/nullif(Maxdmd,0),0) as err3					-- use 'nullif' to avoid divide by zero; NULLIF(expression1, expression2) -> If both the arguments are equal, it returns a null value; If both the arguments are not equal, it returns the value of the first argument --- https://www.sqlshack.com/methods-to-avoid-sql-divide-by-zero-error/ --- https://stackoverflow.com/questions/861778/how-to-avoid-the-divide-by-zero-error-in-sql								
								
						  from comb_ b
						  )

			 , fl as ( select b.*
						  	 ,1- b.err1 as acc1, 1- b.err2 as acc2, 1-b.err3 as acc3
							 ,getdate() as Reportdate
					   from comb b
					  --where b.DataType in ('Units')
					   --where b.DataType in ('Dollars')
						 -- and b.Hierarchy_Descp in ('Family_')
						  -- and b.Hierarchy_Descp in ('FamilyGroup_')
					  --order by b.DataType desc,b.Hierarchy_Cat desc,b.Hierarchy_0 asc 
                       )
			  ----------------------------------------------------------------------

			 -- select * from fl a
			 -- order by a.DataType desc,a.Hierarchy_Cat desc,a.Hierarchy_0 asc 
		  
				insert into JDE_DB_Alan.FCPRO_FC_Accy_Group  select * from fl
				  

	
	    -- select * from JDE_DB_Alan.FC_Accy_Group
						 

END
