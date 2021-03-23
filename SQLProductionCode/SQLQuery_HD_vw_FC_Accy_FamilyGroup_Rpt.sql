        --- 10/4/2020,  --- For Family Group Level ---
	    --- Better to use view to extract modified data from  'JDE_DB_Alan.FCPRO_FC_Accy_Group'  table ----
		  --- 'JDE_DB_Alan.FCPRO_FC_Accy_Group' table willl accumulate data month in & out, but you want to get most recent month data each time ---
       ------ Also, you want to add  'Summary Row' at bottom of rows rather to manager it in VBA ( using Formula ) -------


CREATE view  [JDE_DB_Alan].[vw_FC_Accy_FamilyGroup_Rpt] with schemabinding as 
    

	  --- 1. First to Get all your data for Family Group ---
	with tb as (
				select f.Hierarchy_0,f.Sls_,f.FC_,f.Bias_,f.Abs_,f.err1,f.err2,f.err3,f.acc1,f.acc2,f.acc3,f.Reportdate
				from JDE_DB_Alan.FCPRO_FC_Accy_Group f
				where f.Reportdate = ( select max(a.Reportdate) from JDE_DB_Alan.FCPRO_FC_Accy_Group a )
					 and f.DataType in ('Units')
					 and f.Hierarchy_Cat in ('FamilyGroup_')
              )
      
	   --- 2. Secondly to Get all your data of 'Summary' Row at bottom for Family Group ---  
        ,t as 
		     ( select 'Grand_Total' Grnd_Hierarchy_0,sum(tb.Sls_) Sls_Grnd,sum(tb.FC_) FC_Grnd,sum(tb.Bias_) Bias_Grnd,sum(tb.Abs_) Abs_Grnd		          
			   from tb 
			  -- group by 'Grand_Total'
			   )

        ,_t as ( select t.Grnd_Hierarchy_0,t.Sls_Grnd,t.FC_Grnd,t.Bias_Grnd,t.Abs_Grnd
		                ,(select max(v) from ( values (t.Sls_Grnd),(t.FC_Grnd) ) as  Alldmd(v) ) as Maxdmd	
		           from t

		           )        
		--select * from _t
		,_t_ as ( select b.Grnd_Hierarchy_0,b.Sls_Grnd,b.FC_Grnd,b.Bias_Grnd,b.Abs_Grnd		          
						,coalesce(b.Abs_Grnd/nullif(b.Sls_Grnd,0),0) as err1,coalesce(b.Abs_Grnd/nullif(b.FC_Grnd,0),0) as err2, coalesce(b.Abs_Grnd/nullif(Maxdmd,0),0) as err3					-- use 'nullif' to avoid divide by zero; NULLIF(expression1, expression2) -> If both the arguments are equal, it returns a null value; If both the arguments are not equal, it returns the value of the first argument --- https://www.sqlshack.com/methods-to-avoid-sql-divide-by-zero-error/ --- https://stackoverflow.com/questions/861778/how-to-avoid-the-divide-by-zero-error-in-sql								
				
		          from _t as b
				  )
        ,t_ as ( select b.Grnd_Hierarchy_0,b.Sls_Grnd,b.FC_Grnd,b.Bias_Grnd,b.Abs_Grnd
		                ,b.err1,b.err2,b.err3	
		                ,1- b.err1 as acc1, 1- b.err2 as acc2, 1-b.err3 as acc3
						,GETDATE() as Reportdate
		         from _t_ as b
                 )
         
		  --- 3. Thirdly,finally to Join 1 & 2 together ---
        ,fl as (
		         select tb.Hierarchy_0,tb.Sls_,tb.FC_,tb.Bias_,tb.Abs_,tb.err1,tb.err2,tb.err3,tb.acc1,tb.acc2,tb.acc3,tb.Reportdate		                
				    from tb 
				 union all
				 select  t_.Grnd_Hierarchy_0,t_.Sls_Grnd,t_.FC_Grnd,t_.Bias_Grnd,t_.Abs_Grnd,t_.err1,t_.err2,t_.err3,t_.acc1, t_.acc2, t_.acc3,t_.Reportdate
				     from t_
				 )

         select a.Hierarchy_0,a.Sls_,a.FC_,a.Bias_,a.Abs_,a.err1,a.err2,a.err3,a.acc1,a.acc2,a.acc3
		        ,a.Reportdate
		 from fl as a
		 
GO