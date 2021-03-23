   --- Create view for SKU level Accuracy is because we only need to Select certain columns, not all columns from FCPRO_FC_Accy_SKU' table --- 10/4/2020

CREATE view  [JDE_DB_Alan].[vw_FC_Accy_SKU_Rpt] with schemabinding as 
	
	      select  z.Item,z.Sales,z.Fcst,z.Bias,z.ABS_,z.ErrPct,z.AccuracyPct,z.Description
				 ,z.FamilyGroup_,z.Family_0,z.PrimarySupplier,z.PlannerNumber,z.StockingType
				 ,z.FamilyGroup,z.Family,z.Leadtime_Mth,z.LT_Type
				,z.ReportDate
		 from  JDE_DB_Alan.FCPRO_FC_Accy_SKU z
		 where z.DataType in ('Units')


		 
GO