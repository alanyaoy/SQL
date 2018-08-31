
--------------- Create FC Overrides File for FC Pro Uploading Using MI File ( Comptible with FC PRo Format with Date/Hierarchy ) --- 25/1/2018, 2/2/2018-------------------------
use JDE_DB_Alan
go

with cte as (
            select m.*
					,row_number() over(partition by m.itemNumber order by itemnumber ) as rn  
			from  JDE_DB_Alan.Master_ML345 m )
     ,cte_ as (
				select * from cte where rn =1  
			--order by m.ItemNumber
			 )
     ,ref_ as ( select *
					 ,row_number() over(partition by rf.itemNumber order by rf.Xref_Type) as rn 
				from JDE_DB_Alan.Master_ItemCrossRef rf where rf.Address_Number in ('20037'))		--please note there might be same item Number under multi suppliers!So need to filter here !
      ,ref as ( select * from ref_ where rn=1)

     ,fc as ( select f.*
	                  --,f.Date as Date_
				      ,convert(varchar(21),f.Date,103) as SimpDate
					  ,convert(varchar(4),f.date, 111) +'-'+ left (datename(mm,DATEADD(dd, DATEDIFF(d,0,f.Date)+1,0)),3) as WrongDate			-- wrong date as it will not advance year digit
					  ,convert(varchar(10),DATEADD(dd, DATEDIFF(d,0,f.Date)+1,0),120) as Right_Date
					  ,left(datename(mm,DATEADD(dd, DATEDIFF(d,0,f.Date)+1,0)),3) as Right_MthName
					  ,left(convert(varchar(10),DATEADD(dd, DATEDIFF(d,0,f.Date)+1,0),120),4) +'-'+ left(datename(mm,DATEADD(dd, DATEDIFF(d,0,f.Date)+1,0)),3) as Date_pro
					  ,convert(varchar(10),DATEADD(dd, DATEDIFF(d,0,f.Date)+1,0),120) as Date_
					-- ,cast(DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,GETDATE())+5,0)) as datetime) as startdate			-- Set the StartDate for changing from Jun/2018 onwards
					,'2018-02-01' as startdate1			-- Set the StartDate for changing from Jun/2018 onwards
					,'2018-06-01' as startdate2
			  from JDE_DB_Alan.JDE_Fcst_DL f
				 )
      -- select * from fc where fc.ItemNumber in ('27.161.320')
    
      ,_fc as (																										-- this is Monthly SKU level data
				select 'Total' as RowLabel
				        ,cte_.SellingGroup
						,cte_.FamilyGroup
						,cte_.Family
					    ,fc.ItemNumber
					   ,fc.Date_ 
					   ,fc.Date_pro
					   ,'Override 1' as Row
					   ,isnull(fc.Qty,0) as Baseline
					   ,case 
							when fc.Date_ >= fc.startdate1 and CHARINDEX('70%',mi.Comment) >0 and CHARINDEX('now',lower(mi.Comment)) >0 then isnull(fc.Qty,0) *0.3			-- when comments has '70%' string
							when fc.Date_ >= fc.startdate2 and CHARINDEX('70%',mi.Comment) >0 and CHARINDEX('jun',lower(mi.Comment)) >0 then isnull(fc.Qty,0) *0.3
							when fc.Date_ >= fc.startdate1 and CHARINDEX('50%',mi.Comment) >0 and CHARINDEX('now',lower(mi.Comment)) >0 then isnull(fc.Qty,0) *0.5			-- when comments has '50%' string
							when fc.Date_ > fc.startdate2 and CHARINDEX('50%',mi.Comment) >0 and CHARINDEX('jun',lower(mi.Comment)) >0 then isnull(fc.Qty,0) *0.5
							when  CHARINDEX('obsolete',lower(mi.Comment)) >0 then isnull(fc.Qty,0) *0
							else isnull(fc.Qty,0)
						 end as Formula
                       ,case 
							when fc.Date_ >= fc.startdate1 and CHARINDEX('70%',mi.Comment) >0 and CHARINDEX('now',lower(mi.Comment)) >0 then isnull(fc.Qty,0) *0.3			-- when comments has '70%' string
							when fc.Date_ >= fc.startdate2 and CHARINDEX('70%',mi.Comment) >0 and CHARINDEX('jun',lower(mi.Comment)) >0 then isnull(fc.Qty,0) *0.3
							when fc.Date_ >= fc.startdate1 and CHARINDEX('50%',mi.Comment) >0 and CHARINDEX('now',lower(mi.Comment)) >0 then isnull(fc.Qty,0) *0.5			-- when comments has '50%' string
							when fc.Date_ > fc.startdate2 and CHARINDEX('50%',mi.Comment) >0 and CHARINDEX('jun',lower(mi.Comment)) >0 then isnull(fc.Qty,0) *0.5
							when  CHARINDEX('obsolete',lower(mi.Comment)) >0 then isnull(fc.Qty,0) *0
							else isnull(fc.Qty,0)
						 end as Override
                       ,mi.Comment
					   ,mi.LastUpdated
					   ,cte_.Description
					   ,ref.Customer_Supplier_ItemNumber
					   ,ref.Address_Number
					   ,sum(isnull(fc.Qty,0)) over( partition by fc.itemnumber) as FC_OrigQty_24m
				from fc	 left join  ref on fc.ShortItemNunber = ref.ShortItemNumber		--please note there might be same item Number under multi suppliers !
						 left join cte_ on fc.ItemNumber = cte_.ItemNumber
				         left join JDE_DB_Alan.FCPRO_MI_tmp mi on fc.ItemNumber = mi.ItemNumber
						
				where  ref.Address_Number in ('20037')
					--	and fc.ItemNumber  in ('2770011785')
						
				)
             -- select * from _fc
	  ,stg as 
			(select  _fc.*
					,c.LongDescription as SellingGroup_
					,d.LongDescription as FamilyGroup_
					,e.LongDescription as Family_0
					--,tbl.Family as Family_1
					--,f.StandardCost,f.WholeSalePrice
					,p.Pareto
			from _fc left join JDE_DB_Alan.MasterSellingGroup c  on _fc.SellingGroup = c.Code
					 left join JDE_DB_Alan.MasterFamilyGroup d  on _fc.FamilyGroup = d.Code
					 left join JDE_DB_Alan.MasterFamily e  on _fc.Family = e.Code
					 left join JDE_DB_Alan.FCPRO_Fcst_Pareto p on _fc.ItemNumber = p.ItemNumber
			   )

      ,fc_ as ( select stg.RowLabel,SellingGroup_ as SellingGroup,stg.FamilyGroup_ as FamilyGroup,stg.Family_0 as Family,stg.ItemNumber
					  ,stg.Date_ as date_
                      ,stg.Date_pro as date										--- for FC Pro  Date Format	     		 
						,stg.Row			
					  ,stg.Baseline,stg.Formula,stg.Override,stg.Comment
					  --,stg.LastUpdated	
					  ,convert(varchar(21),stg.LastUpdated,103) as LastUpdated_				--- for FC Pro  Date Format
					  ,stg.Pareto
					  ,stg.Description
				from stg )
   
   --------- Execute elow to Output Format for Overrideing for Uploading into FC Pro  ---------
   --select fc_.ItemNumber,count(fc_.date) as ct
   select *
   from fc_ 
   where fc_.Comment is not null 
  -- group by fc_.ItemNumber
   --having count(fc_.date)  <24
			--and fc_.ItemNumber in ('27.160.320','2770002534')
			--  and fc_.ItemNumber in ('27.160.785')
			--and fc_.ItemNumber in ('2974000000')
   order by fc_.ItemNumber
            ,left(fc_.date,4) 
            ,case  right(fc_.Date,3) when 'Jan' then 1
									 when 'Feb' then 2
									 when 'Mar' then 3
									 when 'Apr' then 4
									 when 'May' then 5
									 when 'Jun' then 6
									 when 'Jul' then 7
									 when 'Aug' then 8
									 when 'Sep' then 9
									 when 'Oct' then 10
									 when 'Nov' then 11
									 when 'Dec' then 12
			  end 
   			 
  --   select * from fc_  where  fc_.Comment is not null and fc_.ItemNumber in ('27.164.882')			---- Sanity check one Item, works 1/2/2018
	 -- select fc_.ItemNumber,fc_.Comment,sum(isnull(fc_.Baseline,0)) as FC_TTL							--- Sanity check to make sure total SKU count is correct, works 1/2/2018				
		--from fc_ where fc_.Comment is not null
		--group by fc_.ItemNumber,fc_.Comment 


--select * from JDE_DB_Alan.JDE_Fcst_DL dl where dl.ItemNumber in ('27.264.850')

  -------- Execute Below to Output Format for Product Team (b Diana A)  -----------
 --  select _fc.ItemNumber,_fc.Description,_fc.Customer_Supplier_ItemNumber,_fc.Address_Number,_fc.Comment		--- Output Format for Diana A,Note dataSet is from '_fc',it is same source of dataset for'fc',but include more fields, since format for Uploading and format for Diana A ( product team ) are required differently 1/2/2018
	--		,avg(_fc.FC_OrigQty_24m) as FC_OrigQty_24m_				
	--from _fc
	----'where fc_.ItemNumber in ('27.164.882')
	----'where fc_.ItemNumber in ('2974000000','F8174A977')					-- ML345 - primarysupplier no is nil --need to update 25/1/2018
	--where  _fc.Comment is not null --and _fc.ItemNumber in ('27.164.882')
	--group by _fc.ItemNumber,_fc.Description,_fc.Customer_Supplier_ItemNumber,_fc.Address_Number,_fc.Comment
 --  order by 
 --           case when upper(substring(Comment,1,1))= 'W' then 1									-- Custom Order by Clause , Yeah !
	--			 when upper(substring(Comment,1,6))= 'MOVING' then 2
	--			 when upper(substring(Comment,1,1))= 'T' then 3
	--			 when upper(substring(Comment,1,1))= 'R' then 4
	--			 when upper(substring(Comment,1,1))= 'S' then 5
	--             when upper(substring(Comment,1,1))= 'D' then 6
	--			 when upper(substring(Comment,1,1))= 'M' then 7
 --             end desc
	--		  ,FC_OrigQty_24m_ desc

--select * 
--from JDE_DB_Alan.FCPRO_MI_tmp
--   order by 
--            case when upper(substring(Comment,1,1))= 'W' then 1									-- Custom Order by Clause , Yeah !
--				 when upper(substring(Comment,1,6))= 'MOVING' then 2
--				 when upper(substring(Comment,1,1))= 'T' then 3
--				 when upper(substring(Comment,1,1))= 'R' then 4
--				 when upper(substring(Comment,1,1))= 'S' then 5
--	             when upper(substring(Comment,1,1))= 'D' then 6
--				 when upper(substring(Comment,1,1))= 'M' then 7
--              end desc
----------------------------------------------------------------------------------------------------------

--select cast(DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,GETDATE())+6,0)) as datetime)
 --select cast(DATEADD(mm, DATEDIFF(mm, 0, '2018-04-01 00:00:00')+6, 0) as datetime) 
--select cast(DATEADD(mm, DATEDIFF(mm, 0, GETDATE())-24, 0) as datetime) 

--select cast(DATEADD(mm, DATEDIFF(mm, 0, GETDATE())+1, 0)) as datetime
--select convert(varchar(10),cast(DATEADD(mm, DATEDIFF(mm, 0, GETDATE())+1, 0) as datetime),103)
--select DATEDIFF(mm, 0, GETDATE())