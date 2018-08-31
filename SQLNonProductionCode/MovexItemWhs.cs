using System;
using System.Data;
using System.Data.SqlClient;
using IBM.Data.DB2.iSeries;
//using Microsoft.SqlServer.Dts.Runtime;
using System.Windows.Forms;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;
using System.Data.Odbc;


// ----- 27/2/2015 -------

namespace MyFirstProjectLocal
{
    class MovexItemWhs
    {

       public static void Main()
        {
           
            //-----------------------------------------------------------------------------------------
            // set up connections to MOVEX, DSX-Staging, CDW
            //-----------------------------------------------------------------------------------------
            OdbcConnection cnDB2 = setUpMVXconn();          // MOVEX-10
            SqlConnection cnSTG1 = setUpDSXconn();          // DSX database - STAGING
            SqlConnection cnCDW = setUpCDWconn();           // CDW - Datawarehouse

            //-----------------------------------------------------------------------------------------
            // work out invalid business key combinations that don't exist
            // in item-warehouse master - write out to SQL server table
            // repopulate as datatable - dtINVL
            //-----------------------------------------------------------------------------------------
            DataTable dtIWHS = getMOVEXItemWhseMaster(cnDB2);
            DataTable dtUCOM = GetUniqueCombinations(cnCDW);                //dbo.[INVALID_BUSINESSKEYS]
            qryInValidCombinations(dtIWHS, dtUCOM, cnSTG1);
           // DataTable dtINVL = GetInvalidKeys(cnSTG1);

            //-----------------------------------------------------------------------------------------
            // pull full inner-join dtIWHS X dtUCOM retrieving ITEM X WHSE X STATE
            //-----------------------------------------------------------------------------------------
            qryLoadItemWarehouseMaster(dtIWHS, cnSTG1);                     // dbo.[ITEM_WAREHOUSE_MASTER]
           //qryValidItemStateWhseCombinations(dtIWHS, dtUCOM, cnSTG1);      // dbo.[UNIQUE_BUSINESSKEYS]


          
        }

        private static DataTable getMOVEXItemWhseMaster(OdbcConnection db2)
        {
            string sql = @"   with ProdHierarchy as (
                         SELECT TRIM(Z0ITNO) AS ITEM,
                         A.Z0ITGR AS BRAND_CODE,
                         B.Z0TX40 AS BRAND_DESC,
                         A.Z0BUAR AS LEVEL1_CODE,
                         C.Z0TX40 AS LEVEL1_DESC,
                         A.Z0GRP2 AS LEVEL2_CODE,
                         D.Z0TX40 AS LEVEL2_DESC,
                         A.Z0GRP3 AS LEVEL3_CODE,
                         E.Z0TX40 AS LEVEL3_DESC,
                         A.Z0GRP5 AS LEVEL4_CODE,
                         F.Z0TX40 AS LEVEL4_DESC,
                         A.Z0CFI1 AS LEVEL5_CODE,
                         G.Z0TX40 AS LEVEL5_DESC FROM CUSEDTPROD.WITMAS A
                         LEFT JOIN CUSEDTPROD.WSYTAB B ON A.Z0ITGR=B.Z0STKY AND B.Z0STCO='GRP5'
                         LEFT JOIN CUSEDTPROD.WSYTAB C ON A.Z0BUAR=C.Z0STKY AND C.Z0STCO='BUAR'
                         LEFT JOIN CUSEDTPROD.WSYTAB D ON A.Z0GRP2=D.Z0STKY AND D.Z0STCO='ITGR'
                         LEFT JOIN CUSEDTPROD.WSYTAB E ON A.Z0GRP3=E.Z0STKY AND E.Z0STCO='CFI1'
                         LEFT JOIN CUSEDTPROD.WSYTAB F ON A.Z0GRP5=F.Z0STKY AND F.Z0STCO='GRP2'
                         LEFT JOIN CUSEDTPROD.WSYTAB G ON A.Z0CFI1=G.Z0STKY AND G.Z0STCO='GRP3'
                         )
                  select distinct
                     rtrim(MMITNO) Item
                     ,MBDIVI Division
                     ,MBFACI Facility
                     ,MMBUAR BU
                     ,coalesce(replace(LEVEL2_DESC,',',''),'NotSpecified') ProdHierarchyL2
                     ,MBWHLO Warehouse
                     ,rtrim(ltrim(MMITNO)) || '-' || ltrim(rtrim(MBDIVI)) || '-' || ltrim(rtrim(MBWHLO)) ComboKey
                     ,MBMABC ABCClass
                     ,MBSTAT WHStatus
                     ,case when MBMABC in ('F','G','H','K','L') and MBOPLC='1' then 'N'
                     when MBMABC in ('A','B','C','D','E','I') and MBOPLC='1' then
                     case when rtrim(MBPRCD) = '' and rtrim(MBFCCM)='' then 'N'
                     Else 'Y' End
                     when MBMABC in ('J') and substr(MMBUAR,1,1) in ('3') and MBOPLC='1' then
                     case when rtrim(MBPRCD) = '' and rtrim(MBFCCM)='' then 'N'
                     Else 'Y' End
                     when MBMABC in ('J') and substr(MMBUAR,1,1) not in ('3') and MBOPLC='1' then 'N'
                     when MBOPLC='2' and MMBUAR in ('170','180') and MBMABC in ('A','B','C','D','E','I') then 'Y'
                     when MBOPLC='2' and MMBUAR in ('170','180') and MBMABC not in ('A','B','C','D','E','I') then 'N'
                     when MBOPLC='2' and MMBUAR not in ('170','180') then 'RoP'
                     when MBOPLC='0' then 'N'
                     when MBOPLC='3' then 'N' Else 'N'
                     End FcstMethod
                     ,case when MBPUIT = 1 then 'MFG'
                     when MBPUIT = 2 then MBSUNO
                     when MBPUIT = 3 then MBSUWH
                     Else 'Error' End PrimarySupply
                     ,case when MBPUIT = 1 then 'MFG : '||MBWHLO
                     when MBPUIT = 2 then replace(rtrim(IDSUNM),',','')
                     when MBPUIT = 3 then replace(rtrim(MWWHNM),',','')
                     Else 'Error' End PrimarySupplyDesc
                     ,case when M9VAMT = 1 then M9UCOS
                     when M9VAMT = 2 then M9APPR Else 0.0 End Cost
                     ,case when MBDIVI = 'C01' then 'AUD'
                     when MBDIVI = 'C15' then 'AUD'
                     when MBDIVI = 'C60' then 'NZD'
                     Else 'error' End CostCurrency
                     ,MBLOQT MinOrdQty
                     ,MBUNMU OrdMult
                     ,case when MBSSQT > 0 then MBSSQT
                     when MBREOP > 0 then MBREOP
                     Else 0 End SafetyStock
                     ,MBSTQT OnHand
                  from (((((((((M3EDTAPROD.MITMAS a
                     left outer join (select CTCONO,CTSTKY,rtrim(CTTX40) BUAR from M3EDTAPROD.CSYTAB where CTCONO = 100
                     and CTSTCO = 'BUAR') b
                     on a.MMCONO = b.CTCONO and a.MMBUAR = b.CTSTKY)
                     left outer join (select MBCONO,MBITNO,min(MBMABC) GABC from M3EDTAPROD.MITBAL where MBCONO = 100
                     and MBSTAT = '20' and MBWHLO in (select MWWHLO from M3EDTAPROD.MITWHL where MWCONO = 100 and
                     MWDIVI IN ('C01','C15','C60','C63') and MWCSCD = 'AU' and MWWHTY in ('10','30','01'))
                     group by MBCONO,MBITNO) c
                     on a.MMCONO = c.MBCONO and a.MMITNO = c.MBITNO)
                     left outer join (select MBCONO,MBITNO,MBWHLO,MBPUIT,MBDIVI,MBFACI,MBSUWH,MBSUNO,MBMABC,MBOPLC,
                     MBPRCD,MBFCCM,MBSTAT,MBSSQT,MBREOP,MBSTQT,
                     MBRGDT,MBLOQT,MBUNMU from M3EDTAPROD.MITBAL where MBCONO = 100 and MBWHLO in
                     (select MWWHLO from M3EDTAPROD.MITWHL where MWCONO = 100
                     and MWDIVI in ('C01','C60','C63','C15') and MWWHTY in ('10','30','01','02'))) d
                     on a.MMCONO = d.MBCONO and a.MMITNO = d.MBITNO)
                     left outer join ProdHierarchy e
                     on a.MMITNO = e.ITEM)
                     left outer join (select CTCONO,CTSTKY,replace(rtrim(CTTX40),',','') ITGR from M3EDTAPROD.CSYTAB
                     where CTCONO = 100 and CTSTCO = 'ITGR') f
                     on a.MMCONO = f.CTCONO and a.MMITGR = f.CTSTKY)
                     left outer join (select CTCONO,CTSTKY,replace(rtrim(CTTX40),',','') ITCL from M3EDTAPROD.CSYTAB
                     where CTCONO = 100 and CTSTCO = 'ITCL') g
                     on a.MMCONO = g.CTCONO and a.MMITCL = g.CTSTKY)
                     left outer join (select CTCONO,CTSTKY,replace(rtrim(CTTX40),',','') POODESC from M3EDTAPROD.CSYTAB
                     where CTCONO = 100 and CTSTCO = 'POO_') h
                     on a.MMCONO = h.CTCONO and a.MMCFI2 = h.CTSTKY)
                     left outer join M3EDTAPROD.MITFAC j
                     on d.MBCONO = j.M9CONO and d.MBITNO = j.M9ITNO and d.MBFACI = j.M9FACI)
                     left outer join M3EDTAPROD.CIDMAS k
                     on d.MBCONO = k.IDCONO and d.MBSUNO = k.IDSUNO)
                     left outer join M3EDTAPROD.MITWHL m
                     on d.MBCONO = m.MWCONO and d.MBSUWH = m.MWWHLO
                 where MMCONO = 100 and MBDIVI in ('C01','C15','C60','C63') and left(MMBUAR,1) not in ('H','A','') and
                     MBWHLO in ('200','220','300','350','400','450','500','515','521','525','550','560','601','602')
              --        and mmitno in ('834300W','F6001')
              --     order by item
    
                   ";

           // sql = "select mbitno,mbwhlo from m3edtaprod.mitbal where mbcono=100 and mbitno='834300W'";

            db2.Open();
            OdbcDataAdapter adDB2 = new OdbcDataAdapter(sql, db2);
            adDB2.SelectCommand.CommandTimeout = 100000;
            DataSet ds = new DataSet();
            adDB2.Fill(ds);
            db2.Close();
            return ds.Tables[0];
        }


        private static DataTable GetUniqueCombinations(SqlConnection conn)
        {
            string manSuper = @" select distinct ltrim(rtrim(a.[Item number]))  Item 
                                  ,ltrim(rtrim(a.[Division]))  Division 
                                  ,ltrim(rtrim(b.[User-defined field 4 - customer])) State 
                                  ,ltrim(rtrim(a.[Warehouse])) as Whse 
                                  ,ltrim(rtrim(a.[Item number])) + '-' + 
                                  ltrim(rtrim(a.[Division])) + '-' + 
                                  ltrim(rtrim(a.[Warehouse])) ComboKey 
                                  ,count(*) as NumLine 
                              from dbo.[Sales Statistics - enhanced] as a 
                                  left outer join dbo.[Customer master] as b 
                                  on a.[Company]=b.[Company] and 
                                  a.[Customer number]=b.[Customer number] 
                              where ltrim(rtrim(a.[Division])) in ('C01','C15','C60') 
                                  and a.[Company]=100 and [Customer order category] in ('1','2','6') 
                                  and [Kit Component Independant Flag] in ('K','I') 
                                  and a.[Customer number] not in ('M00021','H71010') 
                                  and a.[Warehouse] in ('200','220','300','350','400','450','500','515','521','525','550','560','601','602')
                                  and b.[User-defined field 4 - customer] in 
                                  ('NSW','VIC','QLD','SA','WA','NZ','OS') 
                              group by ltrim(rtrim(a.[Item number])) 
                                  ,ltrim(rtrim(a.[Division])) 
                                  ,ltrim(rtrim(b.[User-defined field 4 - customer])) 
                                  ,ltrim(rtrim(a.[Warehouse])) 
                                  ,ltrim(rtrim(a.[Item number])) + '-' + 
                                  ltrim(rtrim(a.[Division])) + '-' + ltrim(rtrim(a.[Warehouse]))
            
                      ";

            conn.Open();
            SqlCommand SqlCmd = new SqlCommand(manSuper, conn);
            SqlDataAdapter objDataAdapter1 = new SqlDataAdapter();
            objDataAdapter1.SelectCommand = SqlCmd;
            objDataAdapter1.SelectCommand.CommandTimeout = 10000;
            DataSet objDataset1 = new DataSet();
            objDataAdapter1.Fill(objDataset1);
            conn.Close();
            return objDataset1.Tables[0];
        }

        //----------------------------------------------------------------------------------------
        // match unique business key combinations against valid item-warehouse locations
        // dt1 = Item-Warehouse combinations dt2 = Unique transactional combinations
        // write invalid combinations back to SQL server STAGING
        //----------------------------------------------------------------------------------------
        private static void qryInValidCombinations(DataTable dt1, DataTable dt2, SqlConnection dc)
        {
            // dbo.[INVALID_BUSINESSKEYS] has a primary unique key on COMBOKEY field
            // to prevent duplicates getting through use '.GroupBy(p=>p.ComboKey).Select(p=>p.First()) tacked
            // onto end of LINQ query

            var invalid = (from pp in dt2.AsEnumerable()
                           join xx in dt1.AsEnumerable() on pp.Field<string>("ComboKey") equals xx.Field<string>("ComboKey") into yy
                           from kk in yy.DefaultIfEmpty()
                           select new
                           {
                               Item = kk == null ? pp.Field<string>("Item") : string.Empty,
                               Division = kk == null ? pp.Field<string>("Division") : string.Empty,
                               SalesState = kk == null ? pp.Field<string>("State") : string.Empty,
                               Whse = kk == null ? pp.Field<string>("Whse") : string.Empty,
                               ComboKey = kk == null ? pp.Field<string>("ComboKey") : string.Empty,
                               NumLine = kk == null ? pp.Field<Int32>("NumLine") : (Int32)0,
                               Validity = "NotValid"
                           }).Where(p => !String.IsNullOrEmpty(p.ComboKey)).GroupBy(p => p.ComboKey).Select(p => p.First());

            var myinvalid = (from pp in dt2.AsEnumerable()
                           join xx in dt1.AsEnumerable() on pp.Field<string>("ComboKey") equals xx.Field<string>("ComboKey") into yy
                           from kk in yy.DefaultIfEmpty()
                           select new
                           {
                               Item = kk == null ? pp.Field<string>("Item") : string.Empty,
                               Division = kk == null ? pp.Field<string>("Division") : string.Empty,
                               SalesState = kk == null ? pp.Field<string>("State") : string.Empty,
                               Whse = kk == null ? pp.Field<string>("Whse") : string.Empty,
                               ComboKey = kk == null ? pp.Field<string>("ComboKey") : string.Empty,
                               NumLine = kk == null ? pp.Field<Int32>("NumLine") : (Int32)0,
                               Validity = "NotValid"
                           });

            //// now truncate SQL table before uploading data back into it

            //dc.Open();
            //SqlCommand cmd = new SqlCommand("truncate table dbo.[INVALID_BUSINESSKEYS]", dc);
            //cmd.CommandType = CommandType.Text;
            //cmd.CommandTimeout = 100000;
            //cmd.ExecuteNonQuery();
            //cmd.Dispose();

            //// insert into SQL Server table dbo.[INVALID_BUSINESSKEYS]

            //foreach (var g in invalid)
            //{
            //    string strval = string.Format("insert into dbo.[INVALID_BUSINESSKEYS] (Item,Division,SalesState,Whse,ComboKey,NumLine,Validity) " +
            //                                  "VALUES ('{0}','{1}','{2}','{3}','{4}',{5},'{6}')", g.Item, g.Division, g.SalesState, g.Whse, g.ComboKey, g.NumLine, g.Validity);
            //    SqlCommand upl = new SqlCommand(strval, dc);
            //    upl.CommandType = CommandType.Text;
            //    upl.ExecuteNonQuery();
            //    upl.Dispose();
            //}

            dc.Close();
        }


        //----------------------------------------------------------------------------------------
        // load item-warehouse extract back to STAGING database with mapping
        // Need to apply DEFAULT State Designations to each WAREHOUSE
        //----------------------------------------------------------------------------------------
        private static void qryLoadItemWarehouseMaster(DataTable dt1, SqlConnection con)
        {

            string fileName = @"C:\Alan_GWA_C\DSX_Logging\NoHierarchy.txt";

            // now truncate SQL table before uploading data back into it
            
                //con.Open();
                //SqlCommand cmd = new SqlCommand("truncate table dbo.[ITEM_WAREHOUSE_MASTER]", con);
                //cmd.CommandType = CommandType.Text;
                //cmd.CommandTimeout = 100000;
                //cmd.ExecuteNonQuery();
                //cmd.Dispose();


            // pull out valid records
            var valid = (from p in dt1.AsEnumerable() select p).Where(p => p.Field<string>("PRODHIERARCHYL2") != "NotSpecified");
            var invalid = (from p in dt1.AsEnumerable() select p).Where(p => p.Field<string>("PRODHIERARCHYL2") == "NotSpecified");
            // write out invalid records
            using (StreamWriter sw = new StreamWriter(fileName))
            {
                foreach (var w in invalid)
                {
                    sw.WriteLine(string.Format("No Hierarchy : {0},{1},{2},{3},{4}"
                                                , w.Field<string>("Item")
                                                , w.Field<string>("Division")
                                                , w.Field<string>("Facility")
                                                , w.Field<string>("BU")
                                                , w.Field<string>("Warehouse")));
                }
            }

            // insert records with mapping into database table dbo.[ITEM_WAREHOUSE_MASTER]
            foreach (var g in valid)
            {
                string tmpBu = "";
                string tmpSt = "";
                // map BUShort
                if (Convert.ToInt32(g.Field<string>("BU")) >= 100 && Convert.ToInt32(g.Field<string>("BU")) < 170) tmpBu = "San";
                else if (Convert.ToInt32(g.Field<string>("BU")) >= 170 && Convert.ToInt32(g.Field<string>("BU")) < 200) tmpBu = "B&S";
                else if (Convert.ToInt32(g.Field<string>("BU")) >= 200 && Convert.ToInt32(g.Field<string>("BU")) < 300) tmpBu = "Taps";
                else if (Convert.ToInt32(g.Field<string>("BU")) >= 300 && Convert.ToInt32(g.Field<string>("BU")) < 400) tmpBu = "K&L";
                else if (Convert.ToInt32(g.Field<string>("BU")) >= 400 && Convert.ToInt32(g.Field<string>("BU")) < 600) tmpBu = "Star";
                else tmpBu = "Other";
                // map Whse ==> State
                if (Convert.ToInt32(g.Field<string>("Warehouse")) >= 200 && Convert.ToInt32(g.Field<string>("Warehouse")) < 300) tmpSt = "NSW";
                else if (Convert.ToInt32(g.Field<string>("Warehouse")) >= 300 && Convert.ToInt32(g.Field<string>("Warehouse")) < 400) tmpSt = "VIC";
                else if (Convert.ToInt32(g.Field<string>("Warehouse")) >= 400 && Convert.ToInt32(g.Field<string>("Warehouse")) < 500) tmpSt = "QLD";
                else if (Convert.ToInt32(g.Field<string>("Warehouse")) >= 500 && Convert.ToInt32(g.Field<string>("Warehouse")) < 550) tmpSt = "SA";
                else if (Convert.ToInt32(g.Field<string>("Warehouse")) >= 550 && Convert.ToInt32(g.Field<string>("Warehouse")) < 570) tmpSt = "WA";
                else if (Convert.ToInt32(g.Field<string>("Warehouse")) == 601 || Convert.ToInt32(g.Field<string>("Warehouse")) == 602) tmpSt = "NZ";
                
                
                // set up INSERT string for commandtext
                string mystrval = string.Format("insert into dbo.[ITEM_WAREHOUSE_MASTER] (Item,Division,Facility,Business,BUShort," +
                                              "Hierarchy2,State,Whse,Pareto,Whstatus,Fcstmethod,PrimarySupp,PrimarySuppDesc," +
                                              "Cost,CostCurr,MinOrdQty,OrdMult,ComboKey,SafetyStock,OnHand) " +
                                              "VALUES ('{0}','{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}','{9}','{10}'," +
                                              "'{11}','{12}',{13},'{14}',{15},{16},'{17}',{18},{19})",
                                              g.Field<string>("Item").Trim(), g.Field<string>("Division").Trim(),
                                              g.Field<string>("Facility").Trim(), g.Field<string>("BU").Trim(),
                                              tmpBu, g.Field<string>("Prodhierarchyl2").Trim(), tmpSt, g.Field<string>("Warehouse").Trim(),
                                              g.Field<string>("Abcclass").Trim(), g.Field<string>("WhStatus").Trim(),
                                              g.Field<string>("Fcstmethod").Trim(), g.Field<string>("PrimarySupply").Trim(),
                                              Regex.Replace(g.Field<string>("PrimarySupplyDesc").Trim(), @"[^a-zA-Z0-9_ ]", " "),
                                              g.Field<decimal>("Cost").ToString("F2").Trim(),
                                              g.Field<string>("CostCurrency").Trim(), g.Field<decimal>("MinOrdQty").ToString("F0").Trim(),
                                              g.Field<decimal>("OrdMult").ToString("F0").Trim(), g.Field<string>("ComboKey").Trim(),
                                              g.Field<decimal>("SafetyStock").ToString("F0").Trim(), g.Field<decimal>("OnHand").ToString("F0").Trim());
                string strval ="";
                SqlCommand upl = new SqlCommand(strval, con);
                upl.CommandType = CommandType.Text;
                upl.ExecuteNonQuery();
                upl.Dispose();
            }

            con.Close();
        }
        


        //-------------------------------------------------------------------
        // set up connection to DSX
        //-------------------------------------------------------------------

        private static SqlConnection setUpDSXconn()
        {
            // create connection object
            string strSQLsrvr = "SERVER=WETNT260;USER ID=#DSXdbadmin;PASSWORD=F0res!3R;" +
                    "DATABASE=STAGING;CONNECTION TIMEOUT=100000;";
            SqlConnection SqlConn = new SqlConnection(strSQLsrvr);
            return SqlConn;
        }

        
        //------------------------------------------------------------------------
        // set up connection to CDW
        //------------------------------------------------------------------------

        private static SqlConnection setUpCDWconn()
        {
            // create connection object
            string strSQLsrvr = "SERVER=EPPSQL10;USER ID=#palo;PASSWORD=#palo;" +
                    "DATABASE=PROD_Reporting;CONNECTION TIMEOUT=100000;";
            SqlConnection SqlConn = new SqlConnection(strSQLsrvr);
            return SqlConn;
        }


        //------------------------------------------------------------------------
        // set up connection to MVX
        //------------------------------------------------------------------------
        private static OdbcConnection setUpMVXconn()
        {

            string strDB2srvr = @"DRIVER={iSeries Access ODBC Driver};System=REVAS110;Uid=yaoal;Pwd=yaoacc;";
            OdbcConnection conMVX = new OdbcConnection(strDB2srvr);
            return conMVX;
        }




    }
}
