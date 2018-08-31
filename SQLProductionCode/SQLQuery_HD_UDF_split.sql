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
/****** Object:  UserDefinedFunction [dbo].[Split]    Script Date: 27/02/2018 2:34:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[Split]
(
    @String VARCHAR(8000),
    @Delimiter varCHAR(1)
)
RETURNS TABLE 
AS
RETURN 
(
    WITH Split(stpos,endpos) 
    AS(
        SELECT 0 AS stpos, CHARINDEX(@Delimiter,@String) AS endpos
        UNION ALL
        SELECT endpos+1, CHARINDEX(@Delimiter,@String,endpos+1)
            FROM Split
            WHERE endpos > 0
        
	)
   SELECT 'Id' = ROW_NUMBER() OVER (ORDER BY (SELECT 1))
			,'Data' = SUBSTRING(@String,stpos,COALESCE(NULLIF(endpos,0),LEN(@String)+1)-stpos)
    FROM Split	    
  -- option (maxrecursion 0)			does not work -- 27/2/2018

  )

