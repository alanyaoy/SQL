

use JDE_DB_Alan
go

ALTER TABLE JDE_DB_Alan.FCPRO_Fcst_ ADD ID int NOT NULL IDENTITY (1,1) PRIMARY KEY	

use JDE_DB_Alan
go


SET STATISTICS XML ON
--select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('34.430.000')

          --- first get all forecast items ---
;with fc as (
		select f.ItemNumber,f.DataType1,f.Date
				,convert(varchar(7),f.Date,120) as FCDate_
				,datepart(year,f.date) fcyr
				,datepart(month,f.date) fcmth
				,f.Value as FC_Vol
		from JDE_DB_Alan.FCPRO_Fcst_ f 
		where f.Date < DATEADD(mm, DATEDIFF(m,0,GETDATE())+5,0)	and f.DataType1 in ('Adj_FC')
				and f.ItemNumber in ('45.103.000','45.200.100') 
          )
    ,po as (
		select p.ItemNumber,'WIP' as DataType1,p.DueDate
				,convert(varchar(7),p.DueDate,120) as PODate_
				,datepart(year,p.DueDate) poyr
				,datepart(month,p.DueDate ) pomth
				,p.QuantityOrdered as PO_Vol
		 from JDE_DB_Alan.OpenPO p 
		where  p.DueDate < DATEADD(mm, DATEDIFF(m,0,GETDATE())+5,0)
			--	and p.ItemNumber in ('45.103.000','45.200.100')    
		 )
		 --- get your master ---
	 ,mas as (
            select m.ItemNumber,m.WholeSalePrice,m.Description,m.QtyOnHand 
			        ,convert(varchar(7),GETDATE(),120) as SOHDate
					,convert(varchar(7),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),120) as SOHDate_
					,datepart(year,GETDATE()) masyr
				  ,datepart(month,GETDATE()) masmth
					,row_number() over(partition by m.itemNumber order by itemnumber ) as rn  
			from  JDE_DB_Alan.Master_ML345 m 
			where exists ( select fc.ItemNumber from fc where fc.ItemNumber = m.ItemNumber )
			  )
     ,mas_ as (
				select mas.ItemNumber,mas.WholeSalePrice,mas.Description,mas.QtyOnHand,mas.SOHDate,mas.SOHDate_
				,mas.masyr,mas.masmth
				,mas.rn from mas where rn =1  
			--order by m.ItemNumber
			 )

      --insert into JDE_DB_Alan.mastb select * from mas_		
	 -- select * from JDE_DB_Alan.mastb
	-- select * from mas_

	      --- get your blueprint ---  
	 ,tb as (  	
			 select fc.ItemNumber,fc.Date,fc.FCDate_,fc.FC_Vol,isnull(po.PO_Vol,0) PO_Vol
					--,isnull(mas_.QtyOnHand,0) SOH_Vol,isnull(mas_.QtyOnHand,0) as SOH_Begin_M, isnull(mas_.QtyOnHand,0) as SOH_End_M,mas_.WholeSalePrice
 			 from fc left join po on fc.ItemNumber = po.ItemNumber 
						--and fc.fcyr = po.poyr and fc.fcmth = po.pomth 
						    and datepart(year,fc.date) = datepart(year,po.DueDate) and datepart(month,fc.date) = datepart(month,po.DueDate )

					  -- left join mas_ on fc.ItemNumber = mas_.ItemNumber
								--	 and fc.fcyr = mas_.masyr and fc.fcmth = mas_.masmth
			 )   
      
	  select * from tb
	  ,_tb as ( select tb.itm,tb.FC_Vol from tb left join mas_ on tb.Itm = mas_.ItemNumber and tb.FCDate_ = mas_.SOHDate_)	 

	  select * from _tb
			 --- get your internal cal---   
	  ,tb_ as (
	            select tb.ItemNumber,tb.Date,tb.FCDate_,tb.FC_Vol,tb.PO_Vol,tb.SOH_Vol, 
						case 
						       when tb.Date >DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0)  then (tb.PO_Vol -tb.FC_Vol)
							   else tb.SOH_Vol
							  end as  SOH_Vol_
				       ,tb.SOH_Begin_M,tb.SOH_End_M
					   ,tb.WholeSalePrice
				from tb				
				)  
	           --- running total preparation ---      
	   ,tbl as ( select *,
	                    row_number() over ( partition by tb_.ItemNumber order by tb_.FCDate_ ) as rnk 
					from tb_      
                
                )
				--- running total To get End period inventory ---
         ,tbl_ as 
			(	select *
			          ,sum(tbl.SOH_Vol_) over (partition by tbl.ItemNumber order by tbl.rnk ) as SOH_End_M_
					from tbl
             )
				--- Beginning period inventory preparation ---
		  ,stk_beg as
		      ( select tbl_.ItemNumber as myItemNumber,tbl_.Date as myDate,DATEADD(mm, DATEDIFF(m,0,tbl_.Date)+1,0) dte,tbl_.SOH_End_M_ as mySOH_Begin_M_
			            
				 from tbl_)

         ,t as ( select *
		             from tbl_ left join stk_beg on tbl_.ItemNumber = stk_beg.myItemNumber and tbl_.Date = stk_beg.dte 
                  )
				  --- Get Begining period inventory ---
         ,t_ as ( select t.ItemNumber,t.Date,t.FCDate_,t.FC_Vol,t.PO_Vol,t.SOH_Vol,t.SOH_Vol_
						,case 
								when t.mySOH_Begin_M_ is null then t.SOH_End_M_
								else t.mySOH_Begin_M_
						  end as  final_SOH_Begin_M_
						,t.SOH_End_M_,t.rnk
						,t.WholeSalePrice
		             from t
                     )

         select * from t_


		 
---============================================================================================================================================================---		 		 
   -------------- Forecast table  -------------

   select * from JDE_DB_Alan.vw_FC
   select * from JDE_DB_Alan.FCPRO_Fcst
	select * into JDE_DB_Alan.fctb  from  
	
	-- Use physical table --
	insert into JDE_DB_Alan.fctb 
	select f.ItemNumber,f.DataType1,f.Date,convert(varchar(7),f.Date,120) as FCDate_,f.Value as FC_Vol
		from JDE_DB_Alan.FCPRO_Fcst_ f 
		where f.Date < DATEADD(mm, DATEDIFF(m,0,GETDATE())+5,0)	and f.DataType1 in ('Adj_FC') 

	-- Use View ---	  
    drop view JDE_DB_Alan.vw_FC		 
	create view  JDE_DB_Alan.vw_FC with schemabinding as 
	select f.ItemNumber,f.DataType1,f.Date,convert(varchar(7),f.Date,120) as FCDate_,datepart(year,f.date) fcyr,datepart(month,f.date) fcmth,DATEPART(day,f.date) fcdte				
			,f.Value as FC_Vol,f.ReportDate
		from JDE_DB_Alan.FCPRO_Fcst f 
		where f.DataType1 in ('Adj_FC')


		drop table JDE_DB_Alan.fctb
		CREATE TABLE JDE_DB_Alan.fctb
   (	ItemNumber     varchar(100)      not null,	
		DataType1		varchar(100)      ,	
		Date			datetime,
		FCDate_			varchar(7),
		FC_Vol			decimal(18,0),
		--ReportDate		datetime default(getdate()),
		--constraint PK_Item_FC primary key (ItemNumber,date,DataType1)			--- if there is violation of constraint you enforced & you are using RecordSet rather using CSV ( to bulk insert ) you will receive error message which is a very good thing -- 2/3/2018
  )  
GO	

     -- Use Temporary table ---
	insert into #fctb 
	select f.ItemNumber,f.DataType1,f.Date,convert(varchar(7),f.Date,120) as FCDate_,f.Value as FC_Vol
		from JDE_DB_Alan.FCPRO_Fcst_ f 
		where f.Date < DATEADD(mm, DATEDIFF(m,0,GETDATE())+5,0)	and f.DataType1 in ('Adj_FC') 

		CREATE TABLE #fctb
   (	ItemNumber     varchar(100)      not null,	
		DataType1		varchar(100)      ,	
		Date			datetime,
		FCDate_			varchar(7),
		FC_Vol			decimal(18,0),
		--ReportDate		datetime default(getdate()),
		--constraint PK_Item_FC primary key (ItemNumber,date,DataType1)			--- if there is violation of constraint you enforced & you are using RecordSet rather using CSV ( to bulk insert ) you will receive error message which is a very good thing -- 2/3/2018
  )  
GO	


select * from JDE_DB_Alan.fctb

-------------- Purchase order Table -------------
drop view JDE_DB_Alan.vw_OpenPO

    -- Use physical table --
select * from JDE_DB_Alan.OpenPO
insert into JDE_DB_Alan.potb

		select p.ItemNumber,'WIP' as DataType1,p.DueDate,convert(varchar(7),p.DueDate,120) as PODate_,p.QuantityOrdered as PO_Vol
		 from JDE_DB_Alan.OpenPO p 
		where  p.DueDate < DATEADD(mm, DATEDIFF(m,0,GETDATE())+5,0)


	-- Use View ---	
select * from JDE_DB_Alan.vw_OpenPO
drop view JDE_DB_Alan.vw_OpenPO

    --- Version 1 --- PO 
create view JDE_DB_Alan.vw_OpenPO with schemabinding as
   
   select ItemNumber,'WIP' as DataType1,OrderNumber,QuantityOrdered as PO_Volume,QuantityReceived,QuantityOpen
		  ,OrderDate,ExSupplierShipDate,DueDate,convert(varchar(7),p.DueDate,120) as PODate_,datepart(year,p.DueDate) poyr,datepart(month,p.DueDate ) pomth,datepart(day,p.DueDate ) pomdte
		  ,InTransitDays,BuyerNumber,BuyerName,TransactionOriginator,TransactionOrigName,SupplierNumber,SupplierName,ShipmentNumber,ShpSts,ShipStatus,Reportdate,OpenPOID           
   from JDE_DB_Alan.OpenPO p
   where  p.DueDate < DATEADD(mm, DATEDIFF(m,0,GETDATE())+5,0)


		select p.ItemNumber,'WIP' as DataType1,p.DueDate,convert(varchar(7),p.DueDate,120) as PODate_,p.QuantityOrdered as PO_Vol
		 from JDE_DB_Alan.OpenPO p 
		where  p.DueDate < DATEADD(mm, DATEDIFF(m,0,GETDATE())+5,0)

             --- Version 2 --- PO 
  create view [JDE_DB_Alan].[vw_OpenPO] with schemabinding as
   
   with tb as (	
			select ItemNumber,'WIP' as DataType1,OrderNumber,QuantityOrdered as PO_Volume,QuantityReceived,QuantityOpen
				  ,OrderDate,ExSupplierShipDate,DueDate,convert(varchar(7),p.DueDate,120) as PODate_,datepart(year,p.DueDate) poyr,datepart(month,p.DueDate ) pomth,datepart(day,p.DueDate ) pomdte
				  ,InTransitDays,BuyerNumber,BuyerName,TransactionOriginator,TransactionOrigName,SupplierNumber,SupplierName,ShipmentNumber,ShpSts,ShipStatus,Reportdate,OpenPOID           
		   from JDE_DB_Alan.OpenPO p
		   where  p.DueDate < DATEADD(mm, DATEDIFF(m,0,GETDATE())+5,0)
				  and p.ItemNumber in ('XUR10516')
		   --order by p.DueDate
		   ) 
        
		 select tb.ItemNumber,tb.DataType1,tb.PODate_,tb.poyr,tb.pomth,tb.BuyerName,tb.BuyerNumber,tb.TransactionOriginator,tb.TransactionOrigName,tb.SupplierName
		        ,sum(tb.PO_Volume) as PO_Vol
		  from tb
		  group by tb.ItemNumber,tb.DataType1,tb.PODate_,tb.poyr,tb.pomth,tb.BuyerName,tb.BuyerNumber,tb.TransactionOriginator,tb.TransactionOrigName,tb.SupplierName


drop table JDE_DB_Alan.potb

CREATE TABLE JDE_DB_Alan.potb
   (	ItemNumber     varchar(100)      not null,	
		DataType1		varchar(100)      ,	
		DueDate			datetime,
		PODate_			varchar(7),
		PO_Vol			decimal(18,0),
		--ReportDate		datetime default(getdate()),
		--constraint PK_Item_FC primary key (ItemNumber,date,DataType1)			--- if there is violation of constraint you enforced & you are using RecordSet rather using CSV ( to bulk insert ) you will receive error message which is a very good thing -- 2/3/2018
  )  
GO


   -- Use Temporary table ---
insert into #potb

		select p.ItemNumber,'WIP' as DataType1,p.DueDate,convert(varchar(7),p.DueDate,120) as PODate_,p.QuantityOrdered as PO_Vol
		 from JDE_DB_Alan.OpenPO p 
		where  p.DueDate < DATEADD(mm, DATEDIFF(m,0,GETDATE())+5,0)

CREATE TABLE #potb
   (	ItemNumber     varchar(100)      not null,	
		DataType1		varchar(100)      ,	
		DueDate			datetime,
		PODate_			varchar(7),
		PO_Vol			decimal(18,0),
		--ReportDate		datetime default(getdate()),
		--constraint PK_Item_FC primary key (ItemNumber,date,DataType1)			--- if there is violation of constraint you enforced & you are using RecordSet rather using CSV ( to bulk insert ) you will receive error message which is a very good thing -- 2/3/2018
  )  
GO


-------------- Master Table -------------

   -- Use View/Temporary table / Physical table  ---

select * from JDE_DB_Alan.Master_ML345
drop view JDE_DB_Alan.vw_Mast
select * from JDE_DB_Alan.vw_Mast


             --- please note following view for Master only includes Items which is forecastable ---
create view [JDE_DB_Alan].[vw_Mast] with schemabinding as
--- please note following view for Master only includes Items which is forecastable ---
with fc as (
		select f.ItemNumber,f.DataType1,f.Date
				,convert(varchar(7),f.Date,120) as FCDate_
				,datepart(year,f.date) fcyr
				,datepart(month,f.date) fcmth
				,f.Value as FC_Vol
		from JDE_DB_Alan.FCPRO_Fcst f 
		where f.Date < DATEADD(mm, DATEDIFF(m,0,GETDATE())+5,0)	and f.DataType1 in ('Adj_FC')
				--and f.ItemNumber in ('45.103.000','45.200.100') 
          )
    ,po as (
		select p.ItemNumber,'WIP' as DataType1,p.DueDate
				,convert(varchar(7),p.DueDate,120) as PODate_
				,datepart(year,p.DueDate) poyr
				,datepart(month,p.DueDate ) pomth
				,p.QuantityOrdered as PO_Vol
		 from JDE_DB_Alan.OpenPO p 
		where  p.DueDate < DATEADD(mm, DATEDIFF(m,0,GETDATE())+5,0)
			--	and p.ItemNumber in ('45.103.000','45.200.100')    
		 )
		 --- get your master ---
	 ,mas as (
            select m.ItemNumber
				   ,m.ShortItemNumber
				    ,m.StockingType,m.PlannerNumber,m.PrimarySupplier
					,m.StandardCost,m.WholeSalePrice,m.Description,m.QtyOnHand 
			        ,convert(varchar(7),GETDATE(),120) as SOHDate
					,convert(varchar(7),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),120) as SOHDate_
					,datepart(year,GETDATE()) masyr
				  ,datepart(month,GETDATE()) masmth
				  ,datepart(day,GETDATE()) masdte
					,row_number() over(partition by m.itemNumber order by itemnumber ) as rn     -- filter out duplicate records
			from  JDE_DB_Alan.Master_ML345 m 
			where exists ( select fc.ItemNumber from fc where fc.ItemNumber = m.ItemNumber )
			  )   
     ,mas_ as (
				select mas.ItemNumber,mas.ShortItemNumber,mas.PlannerNumber,mas.PrimarySupplier
				,mas.StandardCost,mas.WholeSalePrice,mas.Description,mas.QtyOnHand,mas.SOHDate,mas.SOHDate_
				,mas.masyr,mas.masmth,mas.masdte
				,mas.rn 
				from mas where rn =1  )

     select a.ItemNumber,a.ShortItemNumber,a.PlannerNumber,a.PrimarySupplier
				,a.StandardCost,a.WholeSalePrice,a.Description,a.QtyOnHand,a.SOHDate,a.SOHDate_
				,a.masyr,a.masmth,a.masdte
				,a.rn 				
                from mas_ a 
	
 

  insert into #mastb select * from mas_
  insert into JDE_DB_Alan.mastb select * from mas_


  drop table JDE_DB_Alan.mastb
  CREATE TABLE JDE_DB_Alan.mastb
   (	
		ItemNumber			 varchar(100) not null,	
		WholeSalePrice		varchar(100)      ,	
		Description			varchar(200),
		QtyOnHand			decimal(18,0),		
		SOHDate			varchar(7),
		SOHDate_		varchar(7),
		rn				int
		--ReportDate		datetime default(getdate()),
		--constraint PK_Item_FC primary key (ItemNumber,date,DataType1)			--- if there is violation of constraint you enforced & you are using RecordSet rather using CSV ( to bulk insert ) you will receive error message which is a very good thing -- 2/3/2018
  ) 
  
  --
    CREATE TABLE #mastb
   (	
		ItemNumber			 varchar(100) not null,	
		WholeSalePrice		varchar(100)      ,	
		Description			varchar(200),
		QtyOnHand			decimal(18,0),		
		SOHDate			varchar(7),
		SOHDate_		varchar(7),
		rn				int
		--ReportDate		datetime default(getdate()),
		--constraint PK_Item_FC primary key (ItemNumber,date,DataType1)			--- if there is violation of constraint you enforced & you are using RecordSet rather using CSV ( to bulk insert ) you will receive error message which is a very good thing -- 2/3/2018
  ) 


------------------- Query ------------------------------------

  ------ query using View ------
DECLARE @mydt datetime
SET @mydt = DATEADD(mm, DATEDIFF(m,0,GETDATE())+5,0)

 select vw_FC.ItemNumber,vw_FC.FCDate_,vw_FC.FC_Vol,vw_OpenPO.PO_Vol,vw_Mast.QtyOnHand
 from JDE_DB_Alan.vw_FC left join JDE_DB_Alan.vw_OpenPO on vw_FC.ItemNumber = vw_OpenPO.ItemNumber and vw_FC.FCDate_ = vw_OpenPO.PODate_
      left join JDE_DB_Alan.vw_Mast on vw_FC.ItemNumber  = vw_Mast.ItemNumber and vw_FC.FCDate_ = vw_Mast.SOHDate_
where vw_fc.Date< @mydt
--where vw_fc.Date< '2018-10-01'
--where vw_fc.date < DATEADD(mm, DATEDIFF(m,0,GETDATE())+5,0)


select DATEADD(mm, DATEDIFF(m,0,GETDATE())+5,0)


select * from JDE_DB_Alan.vw_fc
where vw_fc.Date < DATEADD(mm, DATEDIFF(m,0,GETDATE())+5,0)

  ------ query using Physical table --------
  
 select *
 from JDE_DB_Alan.fctb left join JDE_DB_Alan.potb on fctb.ItemNumber = potb.ItemNumber and fctb.FCDate_ = potb.PODate_
      left join JDE_DB_Alan.mastb on fctb.ItemNumber = mastb.ItemNumber and fctb.FCDate_ = mastb.SOHDate_

-------

 select *
 from #fctb left join #potb on #fctb.ItemNumber = #potb.ItemNumber and #fctb.FCDate_ = #potb.PODate_
      left join #mastb on #fctb.ItemNumber = #mastb.ItemNumber and #fctb.FCDate_ = #mastb.SOHDate_

	  
---------- Final PO/FC Analysis 11/5/2018  works Yeah !! revised 15/5/2018---------------------

select * from JDE_DB_Alan.vw_FC f where f.ItemNumber in ('0751031003001H')
select * from JDE_DB_Alan.vw_OpenPO p where p.ItemNumber in ('XUR10516')
select * from JDE_DB_Alan.vw_Mast m where m.ItemNumber in ('0751031003001H') 
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('0751031003001H')

---
DECLARE @dt datetime
SET @dt = DATEADD(mm, DATEDIFF(m,0,GETDATE())+5,0)

--Declare @Item_id varchar(8000)
--SET @Item_id = '45.103.000,27.252.713'

      -- first sumarize PO by month ---     
with         
			po as (
					select tb.ItemNumber,tb.DataType1,tb.PODate_,tb.poyr,tb.pomth,tb.BuyerName,tb.BuyerNumber,tb.TransactionOriginator,tb.TransactionOrigName,tb.SupplierName
						,sum(tb.PO_Volume) as PO_Vol
					from JDE_DB_Alan.vw_OpenPO tb
					-- where tb.ItemNumber in  ( select splitdata from JDE_DB_Alan.dbo.fnSplitString(@Item_id,','))	
					group by tb.ItemNumber,tb.DataType1,tb.PODate_,tb.poyr,tb.pomth,tb.BuyerName,tb.BuyerNumber,tb.TransactionOriginator,tb.TransactionOrigName,tb.SupplierName

					)
			--select * from po
				,tb as 
				(  select f.ItemNumber,f.Date,f.FCDate_,f.FC_Vol
						,isnull(p.PO_Vol,0) PO_Vol
						--,isnull(m.QtyOnHand,0) SOH_Vol
						,isnull(m.QtyOnHand,0) as SOH_Begin_M
							,0 as SOH_Vol				 
						--, isnull(m.QtyOnHand,0) as SOH_End_M
						,0 as SOH_End_M
						,m.WholeSalePrice
							 
					from JDE_DB_Alan.vw_FC f left join po p on f.ItemNumber = p.ItemNumber and f.FCDate_ = p.PODate_
										left join JDE_DB_Alan.vw_Mast m on f.ItemNumber  = m.ItemNumber and f.FCDate_ = m.SOHDate   -- SOHDate is current month name,also note 'vw_Mast' is clearn without duplicated records
					where f.Date< @dt
				-- where f.Date < '2018-10-01'
						-- and f.ItemNumber in ('45.103.000')
								)

			-- select * from tb        
				,tb_ as (
						select tb.ItemNumber,tb.Date,tb.FCDate_,tb.FC_Vol,tb.PO_Vol,tb.SOH_Vol 
								,case 
										when tb.Date >DATEADD(mm, DATEDIFF(m,0,GETDATE()),0)  then (tb.PO_Vol -tb.FC_Vol)
										when tb.date = DATEADD(mm, DATEDIFF(m,0,GETDATE()),0) then (tb.PO_Vol -tb.FC_Vol + tb.SOH_Begin_M)
										else tb.SOH_Vol
										end as  SOH_Vol_
								-- ,(tb.PO_Vol -tb.FC_Vol) as SOH_Vol_
								,tb.SOH_Begin_M,tb.SOH_End_M
								,tb.WholeSalePrice					  
						from tb				
						)  
				--select * from tb_
						--- running total preparation ---      
				,tbl as ( select *,
								row_number() over ( partition by tb_.ItemNumber order by tb_.FCDate_ ) as rnk 
							from tb_      
                
						)
						--- running total To get End period inventory ---
				,tbl_ as 
					(	select *
								,sum(tbl.SOH_Vol_) over (partition by tbl.ItemNumber order by tbl.rnk ) as SOH_End_M_
							from tbl
						)
      
				-- select * from tbl_
						--- Beginning period inventory preparation ---
				,stk_beg as
						( select tbl_.ItemNumber as myItemNumber,tbl_.Date as myDate
								,DATEADD(mm, DATEDIFF(m,0,tbl_.Date)+1,0) dte
								,tbl_.SOH_End_M_ as mySOH_Begin_M_
			            
							from tbl_)
					--select * from stk_beg

				,t as ( select *
								from tbl_ left join stk_beg on tbl_.ItemNumber = stk_beg.myItemNumber and tbl_.Date = stk_beg.dte 
							)
				--  select * from t
							--- Get Begining period inventory ---
				,t_ as ( select t.ItemNumber,t.Date,t.FCDate_,t.FC_Vol,t.PO_Vol,t.SOH_Vol,t.SOH_Vol_
								,case 
										when t.mySOH_Begin_M_ is null then t.SOH_Begin_M
										else t.mySOH_Begin_M_
									end as  Final_SOH_Begin_M_
								,t.SOH_End_M_,t.rnk
								,t.WholeSalePrice
								--,t.myWSP
								from t
								)

					--select * from t_
					-- ,pri as ( select t_.ItemNumber,t_.WholeSalePrice from t_ where t_.WholeSalePrice is not null)

					--  select * from pri
				--   ,_t as ( select t_.*,																			-- cost too long time to run
								--       case when t_.WholeSalePrice is null then pri.WholeSalePrice
											--   else t_.WholeSalePrice
										--  end as mywholesaleprice
								--from t_ left join pri on t_.ItemNumber = pri.ItemNumber )
          
				,_t as ( --select t_.ItemNumber,t_.Date,t_.FCDate_,t_.FC_Vol,t_.PO_Vol,t_.SOH_Vol,t_.SOH_Vol_,t_.Final_SOH_Begin_M_,t_.SOH_End_M_,m.WholeSalePrice     -- will spit out column by column saves the performance issue ? Not really  -- 14/5/2018
							select t_.*, mm.WholeSalePrice as Mywholesaleprice,(mm.WholeSalePrice * t_.FC_Vol) FC_Amt
									, case when t_.Final_SOH_Begin_M_ <0  then 'Y 'else 'N' end as Stk_Out_Stauts
									,sum(t_.FC_Vol) over (partition by t_.ItemNumber order by t_.FCDate_ Rows between current row and 2 following ) as CumulativeTotal_FC_Vol_3M			-- only works in SQL 2012 upwards, if you using 2008 need to use below...  https://docs.microsoft.com/en-us/sql/t-sql/queries/select-over-clause-transact-sql?view=sql-server-2017
									,sum(t_.FC_Vol) over (partition by t_.ItemNumber order by t_.FCDate_ Rows between 1 following and 3 following ) as CumulativeTotal_FC_Vol_Nxt3M	
									,avg(t_.FC_Vol) over (partition by t_.ItemNumber) as Avg_FC_Vol_Nxt8M			--- SQL2008 support this 
									--  ,mm.PlannerNumber
						 			,case mm.PlannerNumber 
										when '20071' then 'Domenic Cellucci'
										when '20072' then 'Salman Saeed'
										when '20004' then 'Margaret Dost'	
										when '20005' then 'Imelda Chan'										  
										else 'Unknown'
									end as Owner_
									,mm.PrimarySupplier,mm.Description,mm.FamilyGroup_,mm.Family_0						   
							from t_ left join JDE_DB_Alan.vw_Mast mm on t_.ItemNumber = mm.ItemNumber )				-- note that 'vw_Mast ' has clean data 
		 
					--select * from _t
					--where _t.ItemNumber in ('45.103.000','45.200.100','42.210.031') 
						-- where _t.ItemNumber in ('0751031003001H')
						--order by _t.ItemNumber,_t.Date		 

				,com as ( select _t.ItemNumber,_t.Date d1,_t.FCDate_ d2,'FC_Qty' as DataType,_t.FC_Vol as Value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0 from _t
							union all
							select _t.ItemNumber,_t.Date d1,_t.FCDate_ d2,'PO_Qty' as DataType,_t.PO_Vol as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0 from _t
							union all
							select _t.ItemNumber,_t.Date d1,_t.FCDate_ d2,'SOH_Qty' as DataType,_t.SOH_Vol_ as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0 from _t
							union all
							select _t.ItemNumber,_t.Date d1,_t.FCDate_ d2,'Start_Stk' as DataType,_t.Final_SOH_Begin_M_ as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0 from _t
							union all
							select _t.ItemNumber,_t.Date d1,_t.FCDate_ d2,'End_Stk' as DataType,_t.SOH_End_M_ as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0 from _t
							union all
							select _t.ItemNumber,_t.Date d1,_t.FCDate_ d2,'FC_Amt' as DataType,_t.FC_Amt as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0 from _t				   
                            union all
							select _t.ItemNumber,_t.Date d1,_t.FCDate_ d2,'Weeks_Cover1' as DataType,coalesce(_t.SOH_End_M_/nullif(_t.CumulativeTotal_FC_Vol_Nxt3M/12,0),0) as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0 from _t				  
						--  union all
						--	select _t.ItemNumber,_t.Date d1,_t.FCDate_ d2,'Weeks_Cover2' as DataType,(_t.SOH_End_M_)/(_t.Avg_FC_Vol_Nxt8M/4) as value,_t.Stk_Out_Stauts,_t.Owner_,_t.PrimarySupplier,_t.Description,_t.FamilyGroup_,_t.Family_0 from _t				  
							  							  	 
							)
             
				select * from com 
					--where com.Stk_Out_Stauts in ('Y')
					--   where com.ItemNumber in ('45.103.000','45.200.100')
				-- where com.ItemNumber in ( select splitdata from JDE_DB_Alan.dbo.fnSplitString(@Item_id,','))	
					-- where com.PrimarySupplier in ('20037','1102')
						order by com.ItemNumber,com.DataType,com.d2
         		             
         		             

select * from JDE_DB_Alan.vw_Mast
select  DATEADD(mm, DATEDIFF(m,0,GETDATE())+5,0)
select * from JDE_DB_Alan.OpenPO p where p.ItemNumber in ('45.103.000')
exec JDE_DB_Alan.sp_Mismatch '45.103.000,27.252.713',null, DATEADD(mm, DATEDIFF(m,0,GETDATE())+5,0)
select DATEADD(mm, DATEDIFF(m,0,GETDATE())+5,0)
exec JDE_DB_Alan.sp_Mismatch '45.103.000,27.252.713',null, '2018-09-01 00:00:00 .000'
exec JDE_DB_Alan.sp_Mismatch '45.103.000,27.252.713',null,null
exec JDE_DB_Alan.sp_Mismatch '45.103.000','2018-09-01'   -- does not work
exec JDE_DB_Alan.sp_Mismatch  @Item_id='45.103.000'      --  works but takes same amount of time to run whole table - takes 15'35''
exec JDE_DB_Alan.sp_Mismatch null, '2019-01-01'        --  works but takes same amount of time to run whole table - takes 16'06''         
exec JDE_DB_Alan.sp_Mismatch null, select DATEADD(mm, DATEDIFF(m,0,GETDATE())+5,0)



------------------------

select * from JDE_DB_Alan.FCPRO_Fcst_ f where f.ItemNumber in ('45.103.000')

;update f
set f.Value = 3
--select * 
from JDE_DB_Alan.FCPRO_Fcst_ f 
where f.ItemNumber in ('45.103.000')

select * from JDE_DB_Alan.vw_fc f where f.ItemNumber in ('45.103.000')

;update f
set f.FC_Vol = 3
--select * 
from JDE_DB_Alan.vw_fc f 
where f.ItemNumber in ('45.103.000')



--- Refresh all views in a Database --- 9/5/2018
exec sp_RefreshView 'JDE_DB_Alan.vw_fc'

USE <<Database_Name>>
GO
DECLARE @sqlcmd NVARCHAR(MAX) = ''
SELECT @sqlcmd = @sqlcmd +  'EXEC sp_refreshview ''' + name + ''';' 
FROM sys.objects AS so 
WHERE so.type = 'V' 

SELECT @sqlcmd

--EXEC(@sqlcmd)


-------- create view with schemabinding --------


Create sample table and sample view
USE AdventureWorks 
GO 
SELECT * INTO SampleTable  
FROM sales.SalesOrderDetail 
GO 
CREATE VIEW [dbo].[vw_sampleView] WITH SCHEMABINDING AS 
SELECT salesorderid, productid, unitprice, linetotal, rowguid,modifieddate  
FROM dbo.SAMPLETABLE 
GO

--If the view already existed we could use this to add SCHEMABINDING 
ALTER VIEW [dbo].[vw_sampleView] WITH SCHEMABINDING AS 
SELECT salesorderid, productid, unitprice, linetotal, rowguid,modifieddate  
FROM dbo.SAMPLETABLE 
GO  


