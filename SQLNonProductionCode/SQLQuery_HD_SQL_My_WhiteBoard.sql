
 -- WhiteBoard ---
use JDE_DB_Alan
go

select * from JDE_DB_Alan.Master_ML345

select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('82.600.902CL','82.600.903CL','82.600.904CL','82.600.905CL','82.600.906CL','82.600.907CL','82.600.908CL','82.601.901CL','82.601.902CL','82.601.903CL','82.601.905CL','82.601.906CL','82.601.907CL','82.601.908CL','82.602.901CL','82.602.902CL','82.602.903CL','82.602.905CL','82.602.906CL','82.602.907CL','82.602.908CL') order by ItemNumber
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('45.665.063','45.004.855','45.047.063','45.067.063')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('45.222.100','45.220.100','45.223.100','45.221.100')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('2801462000','2801463000','2780066000','2780067000')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('43.212.001','43.212.002','43.212.003','43.212.004')
select * from JDE_DB_Alan.Master_ML345 m where m.ShortItemNumber in ('1377977','1379753','1379770','1379788')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('0850525000707','0850525003020','085052500M178','0850525003061','0850525000222','0850525000207','0850525000220','2801471000')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('34.513.000','34.514.000','34.515.000','34.516.000','34.517.000','34.518.000','34.519.000','34.520.000','34.521.000','34.522.000','34.523.000')


select * from JDE_DB_Alan.MasterFamily fm where fm.Code like ('mc%') order by fm.Code
select * from JDE_DB_Alan.SlsHistoryHD hd where hd.ItemNumber in ('45.021.000')
select * from JDE_DB_Alan.SlsHistoryHD hd where hd.ItemNumber in ('82.391.901')
select * from JDE_DB_Alan.SlsHistoryMT mt where mt.ItemNumber in ('45.021.000')
select * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h where h.ItemNumber in ('2780136000')
select * from JDE_DB_Alan.SlsHistoryHD hd where hd.ItemNumber in ('2780136000')
select * from JDE_DB_Alan.SlsHistoryMT mt where mt.ItemNumber in ('2780136000')

select * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload l where l.ItemNumber in ('27.160.661')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('27.160.661')
select * from JDE_DB_Alan.FCPRO_Fcst f where f.ItemNumber in ('27.160.661','27.246.785')

select * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload l where l.ItemNumber in ('S3000NET5300N001')
select * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload l where l.ItemNumber in ('27.246.785')
select * from JDE_DB_Alan.SlsHistoryHD hd where hd.ItemNumber in ('27.246.785')
select * from JDE_DB_Alan.SlsHistoryMT mt where mt.ItemNumber in ('27.246.785')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('27.246.785')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('34.528.000')
select * from JDE_DB_Alan.FCPRO_NP_tmp np where np.ItemNumber in ('34.528.000')
select * from JDE_DB_Alan.FCPRO_Fcst f where f.ItemNumber in ('34.528.000') order by f.DataType1,Date
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('26.484.000','26.534.000','4171324050','4150155137')
select * from JDE_DB_Alan.Master_ML345 m where m.PrimarySupplier in ('2140857')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('24.7250.4459')
select * from JDE_DB_Alan.FCPRO_Fcst_Accuracy y order by y.Item
select * from JDE_DB_Alan.vw_Mast m 
select * from JDE_DB_Alan.vw_FC
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('82.391.909')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('24.7218.4465','32.501.000','43.211.004','32.379.200','32.380.855','18.607.016','24.7201.0000','24.7102.7052','24.7102.7052','32.455.465','24.7115.0952A','24.7114.0952A','24.7128.0952','709895','24.7353.0000A','24.7136.0155A','709901','24.7120.0952')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('82.391.912')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('24.7218.4465','32.501.000','43.211.004','32.379.200','32.380.855','18.607.016','24.7201.0000','24.7102.7052','24.7102.7052','32.455.465','24.7115.0952A','24.7114.0952A','24.7128.0952','709895','24.7353.0000A','24.7136.0155A','709901','24.7120.0952')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('34.218.000','28.617.002')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('18.010.035')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('42.210.031')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('18.013.089')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('18.010.035')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('709901')
select distinct m.StockingType from JDE_DB_Alan.Master_ML345 m 
select distinct m.UOM from JDE_DB_Alan.Master_ML345 m 
select * from JDE_DB_Alan.vw_FC f where f.ItemNumber in ('18.010.035') and f.DataType1 in ('Adj_Fc')
select * from JDE_DB_Alan.FCPRO_Fcst f where f.ItemNumber in ('18.010.035') and f.DataType1 in ('Adj_Fc')
select * from JDE_DB_Alan.FCPRO_MI_2_Raw_Data_tmp f where f.ItemID in ('18.010.035')
select * from JDE_DB_Alan.FCPRO_Fcst f where f.DataType1 in ('Adj_Fc')


select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('s3000net5250n001')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('F16174A949')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('34.345.000','34.346.000','34.347.000','34.348.000','34.349.000','34.350.000','34.351.000','34.359.000','34.360.000','34.361.000','34.370.000','34.449.000','34.451.000','34.452.000')
select * from JDE_DB_Alan.SlsHistoryHD hd where hd.ItemNumber in ('34.345.000','34.346.000','34.347.000','34.348.000','34.349.000','34.350.000','34.351.000','34.359.000','34.360.000','34.361.000','34.370.000','34.449.000','34.451.000','34.452.000')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('18.017.154')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('4150249103')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('42.603.855')
select * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload l where l.ItemNumber in ('KIT9125')
select * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload l where l.ItemNumber in ('18.013.089','18.009.029')
select * from JDE_DB_Alan.Px_AWF_HD_MT_FCPro_upload l where l.ItemNumber in ('18.013.089','18.009.029')
select distinct l.ItemNumber from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload l
select distinct l.ItemNumber from JDE_DB_Alan.Px_AWF_HD_MT_FCPro_upload l
select * from JDE_DB_Alan.FCPRO_SafetyStock s where s.ItemNumber in ('7501001000')
select * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h where h.ItemNumber in ('7501001000')
select * from JDE_DB_Alan.FCPRO_SafetyStock 
select * from jde


select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('P4H108A547')

select  f.ItemID as ItemNumber,f.Date, f.Value
		                from JDE_DB_Alan.FCPRO_MI_2_Raw_Data_tmp f
						where  f.ItemID in ('32.501.000')
select * from JDE_DB_Alan.FCPRO_MI_2_Raw_Data_tmp l order by l.ItemID


select * from JDE_DB_Alan.FCPRO_Fcst_Accuracy a order by a.DataType,a.Item,a.Date_
select * from JDE_DB_Alan.FCPRO_Fcst_Accuracy a where a.Item in ('42.210.031') order by a.Item,a.Date_
select distinct a.ReportDate from JDE_DB_Alan.FCPRO_Fcst_Accuracy a


--select * from JDE_DB_Alan.FCPRO_MI_2_Raw_Data_tmp t order by t.ItemID
--select * from JDE_DB_Alan.FCPRO_MI_2_Raw_Data_tmp t where t.ItemID in ('18.013.089','18.009.029')
--insert into JDE_DB_Alan.FCPRO_MI_2_Raw_Data_tmp values ('18.009.029','2018-10-01',15,'test','test','test','test','2018-08-16','Y','test','2018-08-16')
--delete from JDE_DB_Alan.FCPRO_MI_2_Raw_Data_tmp  where ItemID in ('18.009.029')


select * from JDE_DB_Alan.FCPRO_MI_2_tmp t order by t.ItemNumber
select * from JDE_DB_Alan.FCPRO_MI_2_tmp t order by t.ItemNumber
select * from JDE_DB_Alan.FCPRO_MI_2_tmp t where t.ItemNumber in  ('18.013.089','18.009.029') order by t.ItemNumber
insert into JDE_DB_Alan.FCPRO_MI_2_tmp values ('18.009.029','2018-10-01',15,'Market Intelligence_2','test','test','test','2018-08-16','Y','test','2018-08-16')
delete from JDE_DB_Alan.FCPRO_MI_2_tmp  where ItemNumber in ('18.009.029')


select * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h where h.ItemNumber in ('6001130009009H')
select * from JDE_DB_Alan.FCPRO_Fcst f where f.ItemNumber in ('38.001.001')

select * from JDE_DB_Alan.FCPRO_MI_2_Raw_Data_tmp t where t.ItemID in ('18.010.035')

select * from JDE_DB_Alan.FCPRO_Fcst f where f.ItemNumber in ('24.7220.1858')


---============= Update FC table =========
;update f
set f.Value = 803
from JDE_DB_Alan.FCPRO_Fcst f
where f.DataType1 = 'Adj_FC' and f.ItemNumber in ('24.7220.1858')

select * from JDE_DB_Alan.FCPRO_Fcst f where f.ItemNumber in ('24.7220.1858') and f.DataType1 in ('Adj_FC')



select * from JDE_DB_Alan.vw_FC f where f.ItemNumber in ('18.013.089')
select * from JDE_DB_Alan.FCPRO_MI_orig mi 
order by mi.Date,mi.Itemid

select * from JDE_DB_Alan.FCPRO_MI_tmp
select * from JDE_DB_Alan.FCPRO_MI_2_tmp

exec JDE_DB_Alan.sp_Exp_FPFcst_func2Jde_ZeroOut '1385969'

exec JDE_DB_Alan.sp_MI_FC_Check_upload 'MI_1'
exec JDE_DB_Alan.sp_MI_FC_Override_upload 'MI_1'

exec JDE_DB_Alan.sp_FCPRO_Px_MI_PlaceHolder_upload  MI_2
exec JDE_DB_Alan.sp_FCPRO_SlsHistory_MI_PlaceHolder_upload MI_2
 exec [JDE_DB_Alan].sp_FCPRO_SlsHistory_MI_PlaceHolder_upload 'MI_2'


select * from JDE_DB_Alan.FCPRO_MI_tmp mi where mi.ItemNumber in ('311202') order by mi.Date
select * from JDE_DB_Alan.FCPRO_MI_tmp mi where mi.ItemNumber in ('709901') order by mi.Date

select * from JDE_DB_Alan.FCPRO_MI_2_Raw_Data_tmp mi2 order by mi2.ItemID,mi2.Date

select * from JDE_DB_Alan.MasterFamilyGroup
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in  ('82.633.903','82.633.908','S3000NET5300N0AL','S3000NET5300N0PW','S3000NET5300N0SS','S3000NET5300NAMB','S3000NET5300NMMS','S3000NET5300NMTS','S3000NET5300NPMB','S3000NET5300NSAP','S3000NET5300NWWP')
-------------------------------------------------------------------------------------------
with cte as (
				select m.*
						,row_number() over(partition by m.itemNumber order by itemnumber ) as rn 
				from JDE_DB_Alan.Master_ML345 m )
	,cte_ as (
					select cte.*
					       ,case when cte.stockingType in ('O','U') then 'N' 			-- if discontinue it is 'N'	otherwise it is 'Y'			         
								  else 'Y'   end as JdeValidStatus
				     from cte where rn =1 					
				 )
	,tb as ( select np.*,cte_.StockingType,cte_.JdeValidStatus
					,case when cte_.JdeValidStatus is null then 'NotFind' else cte_.JdeValidStatus end as STKTYP_St 		  --- in case Your ML345 is not updated hence you could hve 'Null' - left join
			 from JDE_DB_Alan.FCPRO_NP_tmp np left join cte_ on np.ItemNumber = cte_.ItemNumber
			  --where np.ItemNumber in ('34.528.000') 		  
			 )
    
	--- Get Your final list ---
	,tb_ as (select tb.*,case when tb.ValidStatus ='N' then 'N'				-- Considering Your input in Excel file ( 'ValidStatus')
	                 when tb.STKTYP_St ='NotFind' then 'N'			    -- Considering JdeValidStatus
	                 else tb.STKTYP_St									-- Considering JdeValidStatus
					 end as fSTKTYP_St
			from tb
			)
    --select distinct t.ItemNumber
	select t.ItemNumber,t.Date,t.Value,t.DataType,t.CN_Number,t.Comment,t.Creator,t.LastUpdated,t.fSTKTYP as ValidStatus_,t.RefNum,t.ReportDate
	from tb_ t
	where t.fSTKTYP_St = 'N'
	where t.ItemNumber in ('34.528.000','34.527.000','KIT8105')
	order by t.ItemNumber,t.Date

------------------------------------------------------------------------------------------



select distinct hd.FinancialYear,hd.FinancialMonth from JDE_DB_Alan.SlsHistoryHD hd order by   hd.FinancialYear,hd.FinancialMonth

select * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h where h.ItemNumber in ('45.665.063','45.004.855','45.047.063','45.067.063')
select * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h where h.ItemNumber in ('Z18088A141')

select distinct f.ItemNumber from JDE_DB_Alan.FCPRO_Fcst f where f.ItemNumber in ('2780136000')
where f.ItemNumber in ('42.210.031') and f.DataType1 in ('Adj_FC')
where f.ItemNumber in ('82.391.901') and f.DataType1 in ('Adj_FC')
where f.ItemNumber in ('45.142.100') and f.DataType1 in ('Adj_FC')

select replace(convert(varchar(8), DATEADD(mm, DATEDIFF(m,0,GETDATE())-13,0),126),'-','')


select dateadd(d,-1,dateadd(mm,1,'2018-01-01'))
select dateadd(d,-1,dateadd(mm,1,'2018-02-01'))


;update p
set p.StockingType = 'U'
from JDE_DB_Alan.Master_ML345 p
where p.ShortItemNumber in ( '1377977','1379753','1379770','1379788')


select distinct mi.ItemNumber  from JDE_DB_Alan.FCPRO_MI_tmp mi
select * from JDE_DB_Alan.FCPRO_Fcst_Pareto
select * from JDE_DB_Alan.FCPRO_SafetyStock

select m.ItemNumber,m.LeadtimeLevel,m.PrimarySupplier from JDE_DB_Alan.Master_ML345 m 
where m.PlannerNumber in ('20072')


select distinct f.ItemNumber from JDE_DB_Alan.FCPRO_Fcst f where f.ItemNumber like ('%e%')

select * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h where h.ItemNumber in ('2801471000')

select * from JDE_DB_Alan.SlsHistoryAWF_HD_MT h where h.ItemNumber in ('18.012.053','18.012.047')
select * from JDE_DB_Alan.SlsHistoryHD hd where hd.ItemNumber in ('18.012.053','18.012.047')
select * from JDE_DB_Alan.SlsHistoryMT mt where mt.ItemNumber in ('8328001')
select * from JDE_DB_Alan.SlsHistoryHD hd where hd.ItemNumber in ('8328001')
select * from JDE_DB_Alan.SlsHistorymt mt where mt.ItemNumber in ('4231301320')


select * from JDE_DB_Alan.FCPRO_MI_tmp mi where mi.ItemNumber in ('26.526.030')
select * from JDE_DB_Alan.FCPRO_MI_tmp mi where mi.ItemNumber in ('27.161.320')
select * from JDE_DB_Alan.FCPRO_MI_tmp mi where mi.ItemNumber in ('1081401')
select * from JDE_DB_Alan.FCPRO_NP_tmp np where np.ItemNumber in ('82.604.904')
select distinct np.ItemNumber from JDE_DB_Alan.FCPRO_NP_tmp np

select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('27.170.450')
select * from JDE_DB_Alan.FCPRO_Fcst_History fh where fh.ItemNumber in ('24.7002.0000')
select * from JDE_DB_Alan.SlsHistoryHD hd where hd.ItemNumber in ('2789000748')
select * from JDE_DB_Alan.SlsHistoryHD hd where hd.ItemNumber in ('2789000713')
select * from JDE_DB_Alan.FCPRO_Fcst f where f.ItemNumber in ('18.018.015') order by f.DataType1,f.Date

select * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h where h.ItemNumber in ('18.015.020')



select * from JDE_DB_Alan.OpenPO

select m.ItemNumber,count(m.Description) ct from  JDE_DB_Alan.Master_ML345 m
group by m.ItemNumber
order by ct desc

select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('F8174A908','2932623885') order by m.ItemNumber


select * from JDE_DB_Alan.FCPRO_Fcst f where f.DataType1 not like ('Adj%')
delete from JDE_DB_Alan.FCPRO_Fcst_ where DataType1 not like ('Adj%')

select * into JDE_DB_Alan.FCPRO_Fcst_ from JDE_DB_Alan.FCPRO_Fcst
select * from JDE_DB_Alan.FCPRO_Fcst_


select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('4170681133','4170681320','4170681785','4170681862','4170681885','4170681651','4170681180','4170681426','4171290133','4171290120','4171290785','4171290862','4171290885','4171290651','4171290180','4171290426')
order by m.ItemNumber


select * from JDE_DB_Alan.FCPRO_NP_tmp n where n.ItemNumber in ('34.527.000')

select * from JDE_DB_Alan.SlsHistorymt mt where mt.ItemNumber in ('34.079.000')
select * from JDE_DB_Alan.SlsHistoryHD hd where hd.ItemNumber in ('34.079.000')
select * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h where h.ItemNumber in ('34.079.000')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('34.079.000')

select * from JDE_DB_Alan.SlsHistorymt mt where mt.ItemNumber in ('2801385810')
select * from JDE_DB_Alan.SlsHistoryHD hd where hd.ItemNumber in ('2801385810')


select * from JDE_DB_Alan.SlsHistorymt mt where mt.ItemNumber in ('7454010000','46.414.000')
select * from JDE_DB_Alan.SlsHistoryHD hd where hd.ItemNumber in ('7454010000','46.414.000')

select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('7454010000')
select * from JDE_DB_Alan.FCPRO_MI_tmp mi where mi.ItemNumber in ('3024954849F')

select * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h where h.ItemNumber in ('34.107.000')
select * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h where h.ItemNumber in ('27.252.713')


select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('7127400022')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('03.986.000')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('18.012.055','18.012.056')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('45.200.100')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('42.210.031')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('26.881.030')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('24.023.165')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('4231301320')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('03.986.000')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('05.980.000')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('D7174Q748')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('46.614.000')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('38.001.005')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('18.618.041')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('43.212.001','43.212.002','43.212.003','43.212.004')


select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('82.604.905CL')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('34.528.000')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('KIT8105','4152336450','2801471000','45.133.000','45.133.100','45.134.000','45.134.100','2780145680','2780145451','2780144680','2780144451')
select distinct np.ItemNumber from JDE_DB_Alan.FCPRO_NP_tmp np where np.ItemNumber in  ('KIT8105','4152336450','2801471000','45.133.000','45.133.100','45.134.000','45.134.100','2780145680','2780145451','2780144680','2780144451')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('34.524.000','34.525.000','34.526.000')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('4152336451B','4152336849B','4152336450B')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('26.484.000')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('82.296.956')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('42.210.031')
select * from JDE_DB_Alan.MasterFamily fm where fm.Code like ('h%')
select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber in ('28.676.000')
exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis '28.676.000','2018-07-01','2019-06-01'
select * from JDE_DB_Alan.FCPRO_Fcst f where f.ItemNumber in ('28.676.000')


select * from JDE_DB_Alan.MasterSuperssionItemList

select * from JDE_DB_Alan.Master_ML345  m
where m.ItemNumber in ('82.691.901','82.691.902','82.691.903','82.691.904','82.691.905','82.691.906','82.691.907','82.691.908','82.691.909','82.691.910','82.691.911','82.691.912','82.691.919','82.691.920','82.691.921','82.691.922','82.691.923','82.691.924','82.691.924','82.691.925','82.691.926','82.691.927','82.691.928','82.691.929','82.691.930','82.691.931','82.691.932','82.691.933','82.691.934','82.696.901','82.696.902','82.696.903','82.696.904','82.696.905','82.696.906','82.696.907','82.696.908','82.696.909','82.696.910','82.696.911','82.696.912','82.696.913','82.696.914','82.696.915','82.696.916','82.696.917','82.696.918','82.696.919','82.696.920','82.696.921','82.696.922','82.696.923','82.696.924','82.696.924','82.696.925','82.696.926','82.696.927','82.696.928','82.696.929','82.696.930','82.696.931','82.696.932','82.696.933','82.696.934','82.696.940','82.696.941','82.696.942')

select * from JDE_DB_Alan.FCPRO_MI_tmp mi order by mi.ItemNumber
select top 1 m.* from JDE_DB_Alan.FCPRO_MI_tmp m
select top 1 n.* from JDE_DB_Alan.FCPRO_NP_tmp n
select * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload s where s.ItemNumber in ('42.210.031')

select * from JDE_DB_Alan.FCPRO_Fcst
select * from  JDE_DB_Alan.FCPRO_SafetyStock s where s.ItemNumber in ('38.003.006')

select * from JDE_DB_Alan.vw_Mast m where m.ItemNumber in ('03.986.000')
select * from JDE_DB_Alan.FCPRO_Fcst f where f.ItemNumber in ('34.363.000')
select * from JDE_DB_Alan.FCPRO_Fcst_Pareto p where p.ItemNumber in ('05.980.000')

select round(5.53,0)

 exec JDE_DB_Alan.sp_Exp_FPFcst_func2Jde  null,'34.523.000,34.522.000,34.521.000,34.519.000,34.514.000,34.515.000,34.516.000,34.520.000,34.513.000,34.517.000,34.518.000','Adj_FC'
  exec JDE_DB_Alan.sp_Exp_FPFcst_func2Jde  null,'34.515.000','Adj_FC'

  exec JDE_DB_Alan.sp_Exp_FPFcst_func2Jde  null,'26.544.407,26.881.030','Adj_FC'
  exec JDE_DB_Alan.sp_Exp_FPFcst_func2Jde_ZeroOut '1371516'
  select * from JDE_DB_Alan.FCPRO_NP_tmp n where n.ItemNumber in ('26.544.407')
  

select* from JDE_DB_Alan.FCPRO_Fcst_Pareto
select * from JDE_DB_Alan.FCPRO_Fcst_History f where f.ItemNumber in ('46.508.700','46.508.500','46.612.700','7470500000','7470700000')
      and f.ReportDate > '2018-05-05'

select DATEADD(mm, DATEDIFF(m,0,GETDATE())+5,0)


--- Signature New Product Post launch Analysis ---
 exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis @Item_id = '2851542072,2851548072,2851542167,2851548167,2851542245,2851548245,2851542351,2851548351,2851542661,2851548661,2851542669,2851548669,2851542689,2851548689,2851542785,2851548785,2851542862,2851548862,2801381661,2801381862,2801381320,2801381276,2801381810,2801381324,2801382661,2801382785,2801382320,2801382810,2801382689,2801382180,2801382862,2801382048,2801382879,2801382580,2801382324,2801382276,2801382609,2801382551,2801382669,2801382496,2801406661,2801406862,2801406072,2801406276,2801406351,2801406324,2801407661,2801407862,2801407072,2801407276,2801407351,2801407324,2801389661,2801389785,2801389072,2801389351,2801389689,2801389167,2801389862,2801389048,2801389354,2801389245,2801389324,2801389276,2801389609,2801389551,2801389669,2801389095,2801390661,2801390785,2801390072,2801390351,2801390689,2801390167,2801390862,2801390048,2801390354,2801390245,2801390324,2801390276,2801390609,2801390551,2801390669,2801390095,2801385661,2801385862,2801385320,2801385276,2801385810,2801385324,2801386661,2801386785,2801386320,2801386810,2801386689,2801386180,2801386862,2801386048,2801386879,2801386580,2801386324,2801386276,2801386609,2801386551,2801386669,2801386496,2801395661,2801395862,2801395072,2801395276,2801395351,2801395324,2801396661,2801396785,2801396072,2801396351,2801396689,2801396167,2801396862,2801396048,2801396354,2801396245,2801396324,2801396276,2801396609,2801396551,2801396669,2801396095,2801404000,2801403661,2801403862,2801403072,2801403276,2801403351,2801403324,2801436661,2801436785,2801436072,2801436351,2801436689,2801436167,2801436862,2801436048,2801436354,2801436245,2801436324,2801436276,2801436609,2801436551,2801436669,2801436095,2801405661,2801405785,2801405072,2801405351,2801405689,2801405167,2801405862,2801405048,2801405354,2801405245,2801405324,2801405276,2801405609,2801405551,2801405669,2801405095,KIT2758,KIT2759,2911529661,2911529862,2911529072,2911529276,2911529351,2911529324,2911530661,2911530862,2911530072,2911530276,2911530351,2911530324,2911531661,2911531785,2911531072,2911531351,2911531689,2911531167,2911531862,2911531048,2911531354,2911531245,2911531324,2911531276,2911531609,2911531551,2911531669,2911531095,2911532661,2911532785,2911532072,2911532351,2911532689,2911532167,2911532862,2911532048,2911532354,2911532245,2911532324,2911532276,2911532609,2911532551,2911532669,2911532095,2801471000,7502000000,7502001000,7501005000,7501001000,7804000000,2801499661,2801499785,2801499072,2801499351,2801499689,2801499167,2801499862,2801499048,2801499354,2801499245,2801499324,2801499276,2801499609,2801499551,2801499669,2801499095,2801999000,2781208000,2801454000,2801350000,2801433661,2801433862,2801433072,2801433276,2801433351,2801433324,2801434661,2801434862,2801434072,2801434276,2801434351,2801434324,2801490661,2801490785,2801490072,2801490351,2801490689,2801490167,2801490862,2801490048,2801490354,2801490245,2801490324,2801490276,2801490609,2801490551,2801490669,2801490095,2801491661,2801491785,2801491072,2801491351,2801491689,2801491167,2801491862,2801491048,2801491354,2801491245,2801491324,2801491276,2801491609,2801491551,2801491669,2801491095,2851512661,2851218661,2851224661,2851230661,2851236661,2851284661,2851512785,2851218785,2851224785,2851230785,2851236785,2851284785,2851512072,2851218072,2851224072,2851230072,2851236072,2851284072,2851512351,2851218351,2851224351,2851230351,2851236351,2851284351,2851218689,2851224689,2851230689,2851236689,2851284689,2851512167,2851218167,2851224167,2851230167,2851236167,2851284167,2851512862,2851218862,2851224862,2851230862,2851236862,2851284862,2851284048,2851218354,2851224354,2851230354,2851236354,2851284354,2851218245,2851224245,2851230245,2851236245,2851284245,2851284324,2851218276,2851224276,2851230276,2851236276,2851284276,2851284609,2851218551,2851224551,2851230551,2851236551,2851284551,2851284669,2851284095'
 exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis @Item_id = '2801404000,KIT2758,KIT2759,2801396785,2801386785,2801382785,2801396661,2801386661,2801382661,2801999000,2781208000,2801396862,2801350000,2801454000,2801389785,2801390785,2801396167,2801386862,2801382862,2801389661,2801396072,2801390661,2801396354,2801396669,2801396609,2801396276,2801389167,2801389072,2801386180,2801382180,2801386879,2801382879,2801386669,2801382669,2801386609,2801382609,2801386276,2801382276,2801389862,2801395661,2801386320,2801382320,2801389354,2801389689,2801389276,2801389669,2801389609,2801390862,2801390167,2801395862,2801390072,2801390354,2801390669,2801390609,2801390276,2801389048,2801389351,2801389245,2801390245,2801390689,2801396048,2801396689,2801390351,2801386689,2801382689,7804000000,2801389095,2801389324,2801390048,2801386048,2801382048,2801389551,2801396245,2801390095,2801390324,2801405785,2801396351,2801436785,2851230785,2801499785,7502000000,2801390551,2801386810,2801382810,2801471000,2801490785,2801385661,2801381661,2801405661,2801490661,2801436661,2851230661,2801499661,2801491785,2801386580,2801382580,2801491661,2801405862,2801396095,2801395276,2801436862,2801499862,2851230862,2911531785,2801490072,2801405167,2911532354,2911531661,2911532276,2911532669,2911531862,2911532609,2801405354,2801405669,2801405276,2801436167,2801405609,2801436354,2801436669,2801499167,2801436276,2801436609,2801405072,2801490167,2801499354,2851284609,2801499276,2801499609,2801499669,2851284669,2801385862,2801395324,2801436072,2801386496,2801385320,2801381862,2801382496,2801381320,2801396551,2801491072,2851230072,2801406661,2801499072,2851230354,2851230167,2851230276,2801490354,2801490669,2801490862,2911532661,2801490276,2801490609,2911532862,2801407661,2851224785,2801406072,2801491167,2801490048,2801490689,2801405689,2801395351,2801386551,2801382551,2801406862,2801436689,2801491354,2801491862,2801406276,2801491609,2801491276,2801491669,2911532072,2911531354,2911532785,2801405048,2801499689,2801407862,2801407072,2801407276,2801436048,2851284048,2801499048,2851284661,2851230689,2801406351,2801491048,2801491689,2851224661,2801396324,2801395072,2801407351,2801490351,2851284785,2801405351,7502001000,7501005000,2801386324,2801406324,2801382324,2911531245,2911532095,2911531072,2911531324,2911532167,2911531095,2911531167,2911531276,2911531669,2911532689,2801436351,2911532551,2911531551,2911531609,2801499351,2851236785,2851230351,2801491351,2801490095,2801403661,2851542785,2851548785,2851224862,2801407324,2801405245,2851218785,2801491095,2801499245,2851236661,2801436245,2801385810,2801381810,2801490245,2851230245,2851224354,2801433661,2911531351,2911531689,2911532245,2911532048,2851224072,2851224167,2851542862,2851542661,2851548072,2851542072,2851542167,2851224276,2851548167,2851548862,2851548661,2851284354,2851284072,2851218661,2851284862,2851236862,2851284167,2851284245,2851284551,2851284276,2851284689,2851284351,2851230551,2801491245,2801434661,2801405095,2801433072,2801499095,2851236072,2851218862,2801403072,2801403862,2801436095,2851284095,2801385324,2801385276,2851224689,2801381276,2801381324,2801403324,2801490551,2911529862,2801434072,2911529661,2851236354,2851236167,2851512785,2851224351,2851548351,2851236276,2801436551,2851548669,2911530276,2801405551,2851542689,2851548689,2801499551,2851542245,2851542351,2851542669,2851548245,2801405324,2801491551,7501001000,2801434862,2911530862,2801433276,2911530661,2801434276,2851218354,2851512661,2801436324,2851218167,2851218072,2851218276,2851236689,2801433862,2911529276,2911530072,2801491324,2801434324,2801490324,2911531048,2911532351,2801433324,2911532324,2801499324,2851284324,2851224245,2851512862,2851218689,2851236351,2851224551,2911530324,2801403351,2801433351,2911529072,2911529324,2911530351,2851512072,2801403276,2851218245,2851236245,2851512167,2851512351,2851218351,2851236551,2851218551,2801434351,2911529351'
 exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis '2801404000','2018-05-01','2018-12-01'       -- works
 exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis null,'2018-05-01','2018-12-01'		-- works
  exec JDE_DB_Alan.sp_FCPro_Portfolio_Analysis '6001130009009H','2018-05-01','2018-12-01'

exec JDE_DB_Alan.sp_FCPro_FC_Accy_Data '42.210.031'
exec JDE_DB_Alan.sp_FCPro_FC_Accy_Data '82.501.904'
exec JDE_DB_Alan.sp_FCPro_FC_Accy_Data '42.210.031,32.379.200'

select * from JDE_DB_Alan.Master_ML345 m where m.ItemNumber like ('%850531%')
select * from JDE_DB_Alan.FCPRO_Fcst_History h where h.ItemNumber in ('42.210.031') order by h.ItemNumber,h.ReportDate,h.Date

 ------------------------------------------------------------------------------------------------------------------------------------------------------------
 ----- Last Consecutive 12 month -----

 ------ Get past 12 month and future 12 month -- below is my work draft - 28/5/2018
;WITH R(N,_T,T_,T,X,X2,XX,YY,start) AS
	(
	 select 1 as N,-24 as _T,24 as T_,-23 as T,24 as X,24 as X2
			,24 as XX,24 as YY,cast(DATEADD(mm, DATEDIFF(mm, 0, GETDATE())-24, 0) as datetime) as start
	 UNION ALL
	 select  N+1, _T+1,T_-1,case when T+1<0 then T+1 else case when T+1 =0 then 1 else T+1 end end as T	
							,case when X-1 >= 0  then X-1			-- this algorithm is complicated
							   else  					   
								      case when X > 1 then X+1
										 else X+ 1  
                                      end
								end as X
                             
                            ,case when N >= 24  then _T+1			-- this is simple algorithm because use N 
							   else  					   
								     X
								end as X2

                            ,case when N >= 24  then _T+1
							   else  					   
								     X-1
								end as XX
                           ,case when N >= 24  then T							     
							   else  
							       YY-1
								end as YY
			 ,dateadd(mm,1,start)
	  from R
	 where N < 49
	)
select * from r
select R.N,case when R._T < 0 then R.T_ else R._T end as T, start  

----------------- Below is production code----------------------------------------------------

;WITH R(N,_T,T_,T,XX,YY,start) AS
	(
	 select 1 as N,-24 as _T,24 as T_,-23 as T,24 as XX,24 as YY,cast(DATEADD(mm, DATEDIFF(mm, 0, GETDATE())-24, 0) as datetime) as start      -- pay attention T starts -23,you need this so you can get XXX Column/Field in current month you start as 1, otherwise you can use XX field
	 UNION ALL
	 select  N+1, _T+1,T_-1,case when T+1<0 then T+1 else case when T+1 =0 then 1 else T+1 end end as T						
                            ,case when N >= 24  then _T+1
							   else  
							       XX-1
								end as XX
                             ,case when N >= 24  then T							     
							   else  
							       YY-1
								end as YY
			 ,dateadd(mm,1,start)
	  from R
	 where N < 49
	)
--select * from r
--select R.N,case when R._T < 0 then R.T_ else R._T end as T, start from R
--select R.N,case when R._T < 0 then R.T_ else R.YY end as T, start from R
  select  n as rnk
        ,YY
        ,cast(SUBSTRING(REPLACE(CONVERT(char(10),start,126),'-',''),1,6) as integer) as [StartDate]		
		,LEFT(datename(month,start),3) AS [month_name]
        ,datepart(month,start) AS [month]
        ,datepart(year,start) AS [year]				
  from R
	order by rnk asc


------------------------------
;WITH R(N) AS
(
SELECT 0
UNION ALL
SELECT N+1 
FROM R
WHERE N < 12
)
SELECT  n as rnk
		,LEFT(datename(month,dateadd(month,N,GETDATE())),3) AS [month_name]
        ,datepart(month,dateadd(month,-N,GETDATE())) AS [month]
        ,datepart(year,dateadd(month,-N,GETDATE())) AS [year]		
FROM R
order by rnk desc



--------------------------------------------------
 select * 
 from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload  h
    where h.ItemNumber in ('18.008.021')
      where h.CYM = cast(SUBSTRING(REPLACE(CONVERT(char(10),DATEADD(mm, DATEDIFF(m,0,GETDATE())-1,0),126),'-',''),1,6) as integer)		

	  	  
--------------------------------------------------------------------------------------------------------------
--- table variable join Mismatch ---

declare @mymi as table
( ItemID varchar(100) not null primary key ,
  FcDate varchar(100) not null,
  FcQty  decimal(18,2) not null )
  
 Insert into @mymi ( ItemId,FcDate,FcQty)
 values 
('32.501.000','2018-09',397.08),
('18.010.035','2018-09',183.6),
('18.615.007','2018-09',183.6),
('18.010.036','2018-09',183.6),
('2780229000','2018-09',1533.96),
('82.391.909','2018-09',500.22),
('32.379.200','2018-09',423.72),
('18.013.089','2018-09',183.6),
('24.7002.0001','2018-09',409.68),
('24.7334.4459','2018-09',183.6),
('24.7102.1858','2018-09',367.38),
('24.7219.4459','2018-09',405.9),
('32.455.155','2018-09',183.6),
('24.7121.4459','2018-09',367.38),
('24.7122.4459','2018-09',183.6),
('24.7124.4459','2018-09',183.6),
('24.7127.4459','2018-09',183.6),
('24.5349.4459','2018-09',183.6),
('24.7120.4459','2018-09',183.6),
('24.7250.4459','2018-09',433.8),
('24.7251.4459','2018-09',433.8),
('24.7253.4459','2018-09',183.6),
('24.7146.4459A','2018-09',183.6),
('24.7207.4459','2018-09',826.02),
('24.7168.4459A','2018-09',367.38),
('24.7169.4459A','2018-09',367.38),
('24.7163.0000A','2018-09',1101.96);
   
--select * from @mymi

 with         
			 po as (
						 select tb.ItemNumber,tb.DataType1,tb.PODate_,tb.poyr,tb.pomth,tb.BuyerName,tb.BuyerNumber,tb.TransactionOriginator,tb.TransactionOrigName,tb.SupplierName
							,sum(tb.PO_Volume) as PO_Vol
					    from JDE_DB_Alan.vw_OpenPO tb
					 -- where tb.ItemNumber in  ( select splitdata from JDE_DB_Alan.dbo.fnSplitString(@Item_id,','))	
					  group by tb.ItemNumber,tb.DataType1,tb.PODate_,tb.poyr,tb.pomth,tb.BuyerName,tb.BuyerNumber,tb.TransactionOriginator,tb.TransactionOrigName,tb.SupplierName

					  )
				--select * from po

				,fc as 
				   ( select f.ItemNumber,f.Date,f.FCDate_,f.FC_Vol,f_.FcQty
				            ,case when FcQty is null then f.FC_Vol
							      when FcQty is not null then f.FC_Vol + f_.FcQty 
								   --   else f.FC_Vol + f_.FcQty
							   end as  FC_Vol_f	   
				     from JDE_DB_Alan.vw_FC f left join @mymi f_ on f.ItemNumber = f_.ItemID and f.FCDate_ = f_.FcDate 
					-- where f.ItemNumber in ( '42.210.031','24.7207.4459')
					     --  and f.Date < '2019-03-01'
					 )
               --select * from fc   
				,tb as 
					(  select f.ItemNumber,f.Date,f.FCDate_,f.FC_Vol_f as FC_Vol
							,isnull(p.PO_Vol,0) PO_Vol
							--,isnull(m.QtyOnHand,0) SOH_Vol
							,isnull(m.QtyOnHand,0) as SOH_Begin_M
							 ,0 as SOH_Vol				 
							--, isnull(m.QtyOnHand,0) as SOH_End_M
							,0 as SOH_End_M
							,m.WholeSalePrice
							 
					 from fc f left join po p on f.ItemNumber = p.ItemNumber and f.FCDate_ = p.PODate_
											left join JDE_DB_Alan.vw_Mast m on f.ItemNumber  = m.ItemNumber and f.FCDate_ = m.SOHDate   -- SOHDate is current month name,also note 'vw_Mast' is clearn without duplicated records
					-- where f.Date< @dt
					 where f.Date < '2019-03-01'
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
									   , case when t_.Final_SOH_Begin_M_ <= 0  then 'Y 'else 'N' end as Stk_Out_Stauts
									   ,sum(t_.FC_Vol) over (partition by t_.ItemNumber order by t_.FCDate_ Rows between current row and 2 following ) as CumulativeTotal_FC_Vol_3M			-- only works in SQL 2012 upwards, if you using 2008 need to use below...  https://docs.microsoft.com/en-us/sql/t-sql/queries/select-over-clause-transact-sql?view=sql-server-2017
									   ,sum(t_.FC_Vol) over (partition by t_.ItemNumber order by t_.FCDate_ Rows between 1 following and 3 following ) as CumulativeTotal_FC_Vol_Nxt3M	
									   ,avg(t_.FC_Vol) over (partition by t_.ItemNumber) as Avg_FC_Vol_Nxt8M			--- SQL2008 support this 
									 --  ,mm.PlannerNumber
						 				,case mm.PlannerNumber 
											--when '20071' then 'Domenic Cellucci'		
											when '20071' then 'Rosie Ashpole'
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
					--   where com.ItemNumber in ('24.7207.4459')
					      where com.ItemNumber in ('32.501.000','18.010.035','18.615.007','18.010.036','2780229000','82.391.909','32.379.200','18.013.089','24.7002.0001','24.7334.4459','24.7102.1858','24.7219.4459','32.455.155','24.7121.4459','24.7122.4459','24.7124.4459','24.7127.4459','24.5349.4459','24.7120.4459','24.7250.4459','24.7251.4459','24.7253.4459','24.7146.4459A','24.7207.4459','24.7168.4459A','24.7169.4459A','24.7163.0000A')
				  --where com.ItemNumber in ( select splitdata from JDE_DB_Alan.dbo.fnSplitString(@Item_id,','))
				  order by com.ItemNumber,com.DataType,com.d2 		



---------------------------------------------------------------------------------------------------------------------------------------
--- Below code is used in JDE_DB_Alan_     --- 6/07/2018 database

/****** Script for SelectTopNRows command from SSMS  ******/
SELECT distinct a.ReportDate
  FROM [JDE_DB_Alan_].[JDE_DB_Alan].[FCPRO_Fcst_Accuracy] a

  --- check numb of records in 'FC_history' table in JDE_DB_Alan_ database
   ;with cte as 
  (
	  select convert(varchar(13),y.ReportDate,120) as Date_Uploaded
				,count(*)  as Records_Uploaded
	  from JDE_DB_Alan.FCPRO_Fcst_Accuracy y
	  group by  convert(varchar(13),y.ReportDate,120) )
  
  select *, sum(cte.Records_Uploaded) over (order by Date_Uploaded) TTL_Records_AccuTbl from cte 
 -- where cte.Date_Uploaded between '2018-05-01' and '2018-05-25'
  order by cte.Date_Uploaded asc


  select * from JDE_DB_Alan.JDE_DB_Alan.FCPRO_Fcst_Accuracy
  select * from JDE_DB_Alan.JDE_DB_Alan.FCPRO_Fcst 
  insert into JDE_DB_Alan.JDE_DB_Alan.FCPRO_Fcst_Accuracy select * from JDE_DB_Alan_.JDE_DB_Alan.FCPRO_Fcst_Accuracy				--- transfer data from one tabel to another table

--- table and its size ---
  
SELECT 
    t.NAME AS TableName,
    s.Name AS SchemaName,
    p.rows AS RowCounts,
    SUM(a.total_pages) * 8 AS TotalSpaceKB, 
    CAST(ROUND(((SUM(a.total_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)) AS TotalSpaceMB,
    SUM(a.used_pages) * 8 AS UsedSpaceKB, 
    CAST(ROUND(((SUM(a.used_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)) AS UsedSpaceMB, 
    (SUM(a.total_pages) - SUM(a.used_pages)) * 8 AS UnusedSpaceKB,
    CAST(ROUND(((SUM(a.total_pages) - SUM(a.used_pages)) * 8) / 1024.00, 2) AS NUMERIC(36, 2)) AS UnusedSpaceMB
FROM 
    sys.tables t
INNER JOIN      
    sys.indexes i ON t.OBJECT_ID = i.object_id
INNER JOIN 
    sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
INNER JOIN 
    sys.allocation_units a ON p.partition_id = a.container_id
LEFT OUTER JOIN 
    sys.schemas s ON t.schema_id = s.schema_id
WHERE 
    t.NAME NOT LIKE 'dt%' 
    AND t.is_ms_shipped = 0
    AND i.OBJECT_ID > 255 
GROUP BY 
    t.Name, s.Name, p.Rows
ORDER BY 
    t.Name


--- spaced used by index  ---

SELECT
    OBJECT_NAME(i.OBJECT_ID) AS TableName,
    i.name AS IndexName,
    i.index_id AS IndexID,
    8 * SUM(a.used_pages) AS 'Indexsize(KB)'
FROM
    sys.indexes AS i JOIN 
    sys.partitions AS p ON p.OBJECT_ID = i.OBJECT_ID AND p.index_id = i.index_id JOIN 
    sys.allocation_units AS a ON a.container_id = p.partition_id
GROUP BY
    i.OBJECT_ID,
    i.index_id,
    i.name
ORDER BY
    OBJECT_NAME(i.OBJECT_ID),
    i.index_id


	------------------------------------------------

select * from JDE_DB_Alan.SlsHist_AWFHDMT_FCPro_upload h
where h.ItemNumber in ('0751031000202H','0751031000207H','0751031003001H','0751031003030H','0751031003061H','0850525000202H','0850525000207H','0850525000220H','0850525000222H','0850525000707H','0850525003001H','0850525003020H','0850525003021H','0850525003030H','0850525003061H','085052500M178H','0850531000202H','0850531000207H','0850531000220H','0850531000221H','0850531000222H','0850531000707H','0850531000720H','0850531002022H','0850531003001H','0850531003010H','0850531003020H','0850531003021H','0850531003030H','0850531003061H','085053100M178H','43.205.532M','43.205.535M','43.205.536M','43.205.537M','43.205.563M','43.205.568M','43.205.569M','43.205.574M','43.205.582M','43.205.583M','43.205.584M','43.207.532M','43.207.535M','43.207.536M','43.207.537M','43.207.565M','43.207.582M','43.207.584M','43.295.530','43.295.532','43.295.535','43.295.536','43.295.537')


----------------------------------------

