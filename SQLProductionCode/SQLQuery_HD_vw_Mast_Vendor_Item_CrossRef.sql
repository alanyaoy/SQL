
create view  [JDE_DB_Alan].[vw_Mast_Vendor_Item_CrossRef] with schemabinding as 

----- created on 16/9/2020 ------


-- select * from JDE_DB_Alan.vw_Mast m where m.StockingType in ('P','Q','S','M')  	--- 48,652 records   --- 7107 active items  14%, 86% rubbish
-- select * from JDE_DB_Alan.Master_Vendor_Item_CrossRef c							--- 32,640 records		 --- 8493 active items 26%, 74% rubbish
-- select * from JDE_DB_Alan.vw_Mast m where m.ItemNumber in ('26.108.000')


    ---================ Below code also works =========================---------

--SELECT m.*,c.Customer_Supplier_ItemNumber,c.Address_Number,c.EffectiveDate,c.ExpiredDate
--  FROM JDE_DB_Alan.vw_Mast m left join JDE_DB_Alan.Master_Vendor_Item_CrossRef c
--      on m.ShortItemNumber = c.ShortItemNumber
--      and m.PrimarySupplier = c.Address_Number

--where m.StockingType in ('P','Q','S','M')                       --- 7445 
--     -- and c.Customer_Supplier_ItemNumber is null				--- 1983	
--	  -- and c.Customer_Supplier_ItemNumber is not  null		-- 5459, sometime null means Xref has not updated yet, not necessarily does not have one
--	 -- and m.ItemNumber in ('26.108.000')
--	  and c.ExpiredDate = '1950-12-31'							-- 5071 


 ---================ Below code works is easy to understand =========================---------
select m.ItemNumber,m.ShortItemNumber,m.Description,m.UOM,m.SupplierName,m.PlannerNumber,m.Owner_
		,m.PrimarySupplier,tb.Customer_Supplier_ItemNumber,tb.EffectiveDate,tb.ExpiredDate
	from JDE_DB_Alan.vw_Mast m left join 

	(select  c.ShortItemNumber,c.Customer_Supplier_ItemNumber,c.Address_Number,c.EffectiveDate,c.ExpiredDate
		from JDE_DB_Alan.Master_Vendor_Item_CrossRef c
		where c.ShortItemNumber in ( select a.ShortItemNumber from JDE_DB_Alan.vw_Mast a where a.StockingType in  ('P','Q','S','M')   )
		)tb  on m.ShortItemNumber = tb.ShortItemNumber and m.PrimarySupplier = tb.Address_Number

where m.StockingType in ('P','Q','S','M')			--- 7445 
      and tb.ExpiredDate = '1950-12-31'				--- 5071
	 -- and m.ItemNumber in ('26.108.000')

	  
GO
