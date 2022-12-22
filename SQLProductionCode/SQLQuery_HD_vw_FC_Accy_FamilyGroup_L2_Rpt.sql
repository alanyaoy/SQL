   --- 10/4/2020,  --- For Family Group Level --- Level 2
		  --- This code will use Family level accuracy data as nput to feed in accuracy for Family Group accuracy, therefore Level 2. Rather than use Family Group Accury data on itw own for Input.

	    --- Better to use view to extract modified data from  'JDE_DB_Alan.FCPRO_FC_Accy_Group'  table ----
		  --- 'JDE_DB_Alan.FCPRO_FC_Accy_Group' table willl accumulate data month in & out, but you want to get most recent month data each time ---
       ------ Also, you want to add  'Summary Row' at bottom of rows rather to manager it in VBA ( using Formula ) -------


CREATE view  [JDE_DB_Alan].[vw_FC_Accy_Family_Group_Lv2_Rpt] with schemabinding as 


	 --- 1. First to Get all your data for Family as Input for Family Group Accuracy rather than using Fam Group's Own aggregated Error data    ---

	        --- 203 familys ---
	 with tb as (
				select f.Hierarchy_0,f.Sls_,f.FC_,f.Bias_,f.Abs_,f.err1,f.err2,f.err3,f.acc1,f.acc2,f.acc3,f.Reportdate
				  from JDE_DB_Alan.FCPRO_FC_Accy_Group f
				where f.Reportdate = ( select max(a.Reportdate) from JDE_DB_Alan.FCPRO_FC_Accy_Group a )
					 and f.DataType in ('Units')
					 and f.Hierarchy_Cat in ('Family_')
              )


           --- Need to get Clean Family data, some Family points to 2 different family Group ! ------ Master data is dirty ! 10/4/2020
        ,_mas as ( select distinct m.FamilyGroup_, m.Family_0,m.FamilyGroup,m.Family
						from JDE_DB_Alan.vw_Mast m
		           --order by m.FamilyGroup,m.Family
				)

        ,mas_ as ( select a.FamilyGroup_,a.Family_0,a.FamilyGroup,a.Family,row_number() over(partition by family  order by family ) rownumber  
		             from _mas a
					 where a.FamilyGroup_ is not null and a.Family_0 is not null
					       -- and a.Family_0 like ('%DBA Roman Component%')               --> example of culprit !
					  )
        --select * from mas_  
		,mas as  ( select a.FamilyGroup_,a.Family_0,a.FamilyGroup,a.Family,a.rownumber
		               from mas_ a
                    where a.rownumber = 1
					--  where a.rownumber > 1
					)
		 --select * from mas  
		      
			  --=====================================================---    
              ----- Now You should get 203 familys back after join ---
			  --=====================================================---  
        ,_tb as ( select f.Hierarchy_0,f.Sls_,f.FC_,f.Bias_,f.Abs_,f.err1,f.err2,f.err3,f.acc1,f.acc2,f.acc3,f.Reportdate
		                 ,mas.FamilyGroup_
		          from tb as f left join mas  on f.Hierarchy_0 = mas.Family_0

				  )
        --select * from tb_ order by tb_.FamilyGroup_

		   --=====================================================---  
		  ---- Now Aggregate to Family Group Level For each Family Group ------
		   --=====================================================---  
		,tbl as ( select f.FamilyGroup_,sum(f.Sls_) Sls_ag,sum(f.FC_) FC_ag,sum(f.Bias_) Bias_ag,sum(f.Abs_) Abs_ag
		                   
		           from _tb f
				   group by f.FamilyGroup_
				   )
         --select * from tbl
		,_tbl as ( select f.FamilyGroup_,Sls_ag,FC_ag,Bias_ag,Abs_ag
				          ,(select max(v) from ( values (f.Sls_ag),(f.FC_ag) ) as  Alldmd(v) ) as Maxdmd	        
		           from tbl f				   
				   )

         ,_tbl_ as ( select FamilyGroup_,Sls_ag,FC_ag,Bias_ag,Abs_ag
					,coalesce(b.Abs_ag/nullif(b.Sls_ag,0),0) as err1,coalesce(b.Abs_ag/nullif(b.FC_ag,0),0) as err2, coalesce(b.Abs_ag/nullif(Maxdmd,0),0) as err3					-- use 'nullif' to avoid divide by zero; NULLIF(expression1, expression2) -> If both the arguments are equal, it returns a null value; If both the arguments are not equal, it returns the value of the first argument --- https://www.sqlshack.com/methods-to-avoid-sql-divide-by-zero-error/ --- https://stackoverflow.com/questions/861778/how-to-avoid-the-divide-by-zero-error-in-sql		
					
					from _tbl b
					 )
         ,tbl_ as (  select FamilyGroup_,Sls_ag,FC_ag,Bias_ag,Abs_ag
		               ,b.err1,b.err2,b.err3
		 		       ,1- b.err1 as acc1, 1- b.err2 as acc2, 1-b.err3 as acc3
						,GETDATE() as Reportdate					
					from _tbl_ b
					)
         --select * from tbl_
		             

      --- 2. Secondly to Get all your data of 'Summary' Row at bottom for Family ---

        ,t as 
		     ( select 'Grand_Total' Grnd_Hierarchy_0,sum(tbl_.Sls_ag) Sls_Grnd,sum(tbl_.FC_ag) FC_Grnd,sum(tbl_.Bias_ag) Bias_Grnd,sum(tbl_.Abs_ag) Abs_Grnd		          
			   from tbl_
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
		         select tbl_.FamilyGroup_ as Hierarchy_0,tbl_.Sls_ag,tbl_.FC_ag,tbl_.Bias_ag,tbl_.Abs_ag,tbl_.err1,tbl_.err2,tbl_.err3,tbl_.acc1,tbl_.acc2,tbl_.acc3,tbl_.Reportdate		                
				    from tbl_ 
				 union all
				 select  t_.Grnd_Hierarchy_0,t_.Sls_Grnd,t_.FC_Grnd,t_.Bias_Grnd,t_.Abs_Grnd,t_.err1,t_.err2,t_.err3,t_.acc1, t_.acc2, t_.acc3,t_.Reportdate
				     from t_
				 )

         select a.Hierarchy_0,a.Sls_ag,a.FC_ag,a.Bias_ag,a.Abs_ag,a.err1,a.err2,a.err3,a.acc1,a.acc2,a.acc3
		        ,a.Reportdate
		 from fl as a
GO
