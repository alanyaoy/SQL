
---- Convert format Date in SQL server --- 16/12/2017

http://www.sql-server-helper.com/tips/date-formats.aspx
https://docs.microsoft.com/en-us/sql/t-sql/functions/cast-and-convert-transact-sql
https://www.w3schools.com/sql/func_sqlserver_convert.asp


select getdate()

select convert(varchar(10),getdate(),112) -- yield 20171216 - ISO

select convert(varchar(10),getdate(),110) -- yield 12-16-2017 - US
select convert(varchar(10),getdate(),101) -- yield 12/16/2017 - US

select convert(varchar(10),getdate(),105) -- yield 16-12-2017 - Italian
select convert(varchar(10),getdate(),103) -- yield 16/12/2017 - British / French
select convert(varchar(10),getdate(),3) -- yield 16/12/2017

select convert(varchar(10),getdate(),111) -- yield 2017/12/16 - Japan

select convert(varchar(10),getdate(),112)


--How to convert from string to datetime?
http://www.sqlusa.com/bestpractices/datetimeconversion/
Execute the following T-SQL scripts in Microsoft SQL Server Management Studio (SSMS) Query Editor to demonstrate T-SQL CONVERT and CAST functions in transforming string SQL date formats, string time & string datetime data to datetime data type. Practical examples for T-SQL DATE / DATETIME functions.

-- SQL Server string to date / datetime conversion - datetime string format sql server
-- MSSQL string to datetime conversion - convert char to date - convert varchar to date
-- Subtract 100 from style number (format) for yy instead yyyy (or ccyy with century)
SELECT convert(datetime, 'Oct 23 2012 11:01AM', 100) -- mon dd yyyy hh:mmAM (or PM)
SELECT convert(datetime, 'Oct 23 2012 11:01AM') -- 2012-10-23 11:01:00.000
 
-- Without century (yy) string date conversion - convert string to datetime function
SELECT convert(datetime, 'Oct 23 12 11:01AM', 0) -- mon dd yy hh:mmAM (or PM)
SELECT convert(datetime, 'Oct 23 12 11:01AM') -- 2012-10-23 11:01:00.000
 
-- Convert string to datetime sql - convert string to date sql - sql dates format
-- T-SQL convert string to datetime - SQL Server convert string to date
SELECT convert(datetime, '10/23/2016', 101) -- mm/dd/yyyy
SELECT convert(datetime, '2016.10.23', 102) -- yyyy.mm.dd ANSI date with century
SELECT convert(datetime, '23/10/2016', 103) -- dd/mm/yyyy
SELECT convert(datetime, '23.10.2016', 104) -- dd.mm.yyyy
SELECT convert(datetime, '23-10-2016', 105) -- dd-mm-yyyy
-- mon types are nondeterministic conversions, dependent on language setting
SELECT convert(datetime, '23 OCT 2016', 106) -- dd mon yyyy
SELECT convert(datetime, 'Oct 23, 2016', 107) -- mon dd, yyyy
-- 2016-10-23 00:00:00.000
SELECT convert(datetime, '20:10:44', 108) -- hh:mm:ss
-- 1900-01-01 20:10:44.000
 
-- mon dd yyyy hh:mm:ss:mmmAM (or PM) - sql time format - SQL Server datetime format
SELECT convert(datetime, 'Oct 23 2016 11:02:44:013AM', 109)
-- 2016-10-23 11:02:44.013
SELECT convert(datetime, '10-23-2016', 110) -- mm-dd-yyyy
SELECT convert(datetime, '2016/10/23', 111) -- yyyy/mm/dd
-- YYYYMMDD ISO date format works at any language setting - international standard
SELECT convert(datetime, '20161023')
SELECT convert(datetime, '20161023', 112) -- ISO yyyymmdd
-- 2016-10-23 00:00:00.000
SELECT convert(datetime, '23 Oct 2016 11:02:07:577', 113) -- dd mon yyyy hh:mm:ss:mmm
-- 2016-10-23 11:02:07.577
SELECT convert(datetime, '20:10:25:300', 114) -- hh:mm:ss:mmm(24h)
-- 1900-01-01 20:10:25.300
SELECT convert(datetime, '2016-10-23 20:44:11', 120) -- yyyy-mm-dd hh:mm:ss(24h)
-- 2016-10-23 20:44:11.000
SELECT convert(datetime, '2016-10-23 20:44:11.500', 121) -- yyyy-mm-dd hh:mm:ss.mmm
-- 2016-10-23 20:44:11.500
 
-- Style 126 is ISO 8601 format: international standard - works with any language setting
SELECT convert(datetime, '2008-10-23T18:52:47.513', 126) -- yyyy-mm-ddThh:mm:ss(.mmm)
-- 2008-10-23 18:52:47.513
SELECT convert(datetime, N'23 شوال 1429  6:52:47:513PM', 130) -- Islamic/Hijri date
SELECT convert(datetime, '23/10/1429  6:52:47:513PM',    131) -- Islamic/Hijri date
 
-- Convert DDMMYYYY format to datetime - sql server to date / datetime
SELECT convert(datetime, STUFF(STUFF('31012016',3,0,'-'),6,0,'-'), 105)
-- 2016-01-31 00:00:00.000
-- SQL Server T-SQL string to datetime conversion without century - some exceptions
-- nondeterministic means language setting dependent such as Mar/Mär/mars/márc
SELECT convert(datetime, 'Oct 23 16 11:02:44AM') -- Default
SELECT convert(datetime, '10/23/16', 1) -- mm/dd/yy U.S.
SELECT convert(datetime, '16.10.23', 2) -- yy.mm.dd ANSI
SELECT convert(datetime, '23/10/16', 3) -- dd/mm/yy UK/FR
SELECT convert(datetime, '23.10.16', 4) -- dd.mm.yy German
SELECT convert(datetime, '23-10-16', 5) -- dd-mm-yy Italian
SELECT convert(datetime, '23 OCT 16', 6) -- dd mon yy non-det.
SELECT convert(datetime, 'Oct 23, 16', 7) -- mon dd, yy non-det.
SELECT convert(datetime, '20:10:44', 8) -- hh:mm:ss
SELECT convert(datetime, 'Oct 23 16 11:02:44:013AM', 9) -- Default with msec
SELECT convert(datetime, '10-23-16', 10) -- mm-dd-yy U.S.
SELECT convert(datetime, '16/10/23', 11) -- yy/mm/dd Japan
SELECT convert(datetime, '161023', 12) -- yymmdd ISO
SELECT convert(datetime, '23 Oct 16 11:02:07:577', 13) -- dd mon yy hh:mm:ss:mmm EU dflt
SELECT convert(datetime, '20:10:25:300', 14) -- hh:mm:ss:mmm(24h)
SELECT convert(datetime, '2016-10-23 20:44:11',20) -- yyyy-mm-dd hh:mm:ss(24h) ODBC can.
SELECT convert(datetime, '2016-10-23 20:44:11.500', 21)-- yyyy-mm-dd hh:mm:ss.mmm ODBC
------------

-- SQL Datetime Data Type: Combine date & time string into datetime - sql hh mm ss
-- String to datetime - mssql datetime - sql convert date - sql concatenate string
DECLARE @DateTimeValue varchar(32), @DateValue char(8), @TimeValue char(6)
 
SELECT @DateValue = '20120718',
       @TimeValue = '211920'
SELECT @DateTimeValue =
convert(varchar, convert(datetime, @DateValue), 111)
+ ' ' + substring(@TimeValue, 1, 2)
+ ':' + substring(@TimeValue, 3, 2)
+ ':' + substring(@TimeValue, 5, 2)
SELECT
DateInput = @DateValue, TimeInput = @TimeValue,
DateTimeOutput = @DateTimeValue;
/*
DateInput   TimeInput   DateTimeOutput
20120718    211920      2012/07/18 21:19:20 */

/* DATETIME 8 bytes internal storage structure
   o 1st 4 bytes: number of days after the base date 1900-01-01
   o 2nd 4 bytes: number of clock-ticks (3.33 milliseconds) since midnight

DATETIME2 8 bytes (precision > 4) internal storage structure
   o 1st byte: precision like 7
   o middle 4 bytes: number of time units (100ns smallest) since midnight
   o last 3 bytes: number of days after the base date 0001-01-01

DATE 3 bytes internal storage structure
   o 3 bytes integer: number of days after the first date 0001-01-01
   o Note: hex byte order reversed
 
SMALLDATETIME 4 bytes internal storage structure
   o 1st 2 bytes: number of days after the base date 1900-01-01
   o 2nd 2 bytes: number of minutes since midnight   */       

SELECT CONVERT(binary(8), getdate()) -- 0x00009E4D 00C01272
SELECT CONVERT(binary(4), convert(smalldatetime,getdate())) -- 0x9E4D 02BC

-- This is how a datetime looks in 8 bytes
DECLARE @dtHex binary(8)= 0x00009966002d3344;
DECLARE @dt datetime = @dtHex
SELECT @dt   -- 2007-07-09 02:44:34.147
------------ */

------------
-- SQL Server 2012 New Date & Time Related Functions
------------
SELECT DATEFROMPARTS ( 2016, 10, 23 ) AS RealDate; -- 2016-10-23
 
SELECT DATETIMEFROMPARTS ( 2016, 10, 23, 10, 10, 10, 500 ) AS RealDateTime; -- 2016-10-23 10:10:10.500
 
SELECT EOMONTH('20140201');       -- 2014-02-28
SELECT EOMONTH('20160201');       -- 2016-02-29
SELECT EOMONTH('20160201',1);     -- 2016-03-31
 
SELECT FORMAT ( getdate(), 'yyyy/MM/dd hh:mm:ss tt', 'en-US' );   -- 2016/07/30 03:39:48 AM
SELECT FORMAT ( getdate(), 'd', 'en-US' );                        -- 7/30/2016
 
SELECT PARSE('SAT, 13 December 2014' AS datetime USING 'en-US') AS [Date&Time]; 
-- 2014-12-13 00:00:00.000
 
SELECT TRY_PARSE('SAT, 13 December 2014' AS datetime USING 'en-US') AS [Date&Time]; 
-- 2014-12-13 00:00:00.000
 
SELECT TRY_CONVERT(datetime, '13 December 2014' ) AS [Date&Time];  -- 2014-12-13 00:00:00.000
SELECT CONVERT(datetime2, sysdatetime()); AS [DateTime2];  -- 2016-02-12 13:09:24.0642891
------------
 
-- SQL convert seconds to HH:MM:SS - sql times format - sql hh mm
DECLARE  @Seconds INT
SET @Seconds = 20000
SELECT HH = @Seconds / 3600, MM = (@Seconds%3600) / 60, SS = (@Seconds%60)
/* HH    MM    SS
  5     33    20   */
------------
-- SQL Server Date Only from DATETIME column - get date only
-- T-SQL just date - truncate time from datetime - remove time part
------------
DECLARE @Now datetime = CURRENT_TIMESTAMP -- getdate()
SELECT  DateAndTime       = @Now      -- Date portion and Time portion
       ,DateString        = REPLACE(LEFT(CONVERT (varchar, @Now, 112),10),' ','-')
       ,[Date]            = CONVERT(DATE, @Now)  -- SQL Server 2008 and on - date part
       ,Midnight1         = dateadd(day, datediff(day,0, @Now), 0)
       ,Midnight2         = CONVERT(DATETIME,CONVERT(int, @Now))
       ,Midnight3         = CONVERT(DATETIME,CONVERT(BIGINT,@Now) &                                                           (POWER(Convert(bigint,2),32)-1))
/* DateAndTime    DateString  Date  Midnight1   Midnight2   Midnight3
2010-11-02 08:00:33.657 20101102    2010-11-02  2010-11-02 00:00:00.000 2010-11-02 00:00:00.000      2010-11-02 00:00:00.000 */
------------

-- SQL Server 2008 convert datetime to date - sql yyyy mm dd
SELECT      TOP (3)  OrderDate = CONVERT(date, OrderDate),
            Today = CONVERT(date, getdate())
FROM AdventureWorks2008.Sales.SalesOrderHeader
ORDER BY newid();
/*          OrderDate   Today
            2004-02-15  2012-06-18 .....*/
------------

-- SQL date yyyy mm dd - sqlserver yyyy mm dd - date format yyyymmdd
SELECT CONVERT(VARCHAR(10), GETDATE(), 111) AS [YYYY/MM/DD]
/*  YYYY/MM/DD
    2015/07/11    */
SELECT CONVERT(VARCHAR(10), GETDATE(), 112) AS [YYYYMMDD]
/*  YYYYMMDD
    20150711     */
SELECT REPLACE(CONVERT(VARCHAR(10), GETDATE(), 111),'/',' ') AS [YYYY MM DD]
/* YYYY MM DD
   2015 07 11    */
-- Converting to special (non-standard) date fomats: DD-MMM-YY
SELECT UPPER(REPLACE(CONVERT(VARCHAR,GETDATE(),6),' ','-'))
-- 07-MAR-14
------------
-- SQL convert date string to datetime - time set to 00:00:00.000 or 12:00AM
PRINT CONVERT(datetime,'07-10-2012',110)        -- Jul 10 2012 12:00AM
PRINT CONVERT(datetime,'2012/07/10',111)        -- Jul 10 2012 12:00AM
PRINT CONVERT(datetime,'20120710',  112)        -- Jul 10 2012 12:00AM          
------------
-- UNIX to SQL Server datetime conversion      
declare @UNIX bigint  = 1477216861;
select dateadd(ss,@UNIX,'19700101'); -- 2016-10-23 10:01:01.000
------------
-- String to date conversion - sql date yyyy mm dd - sql date formatting
-- SQL Server cast string to date - sql convert date to datetime
SELECT [Date] = CAST (@DateValue AS datetime)
-- 2012-07-18 00:00:00.000
 
-- SQL convert string date to different style - sql date string formatting
SELECT CONVERT(varchar, CONVERT(datetime, '20140508'), 100)
-- May  8 2014 12:00AM

-- SQL Server convert date to integer
DECLARE @Date datetime; SET @Date = getdate();
SELECT DateAsInteger = CAST (CONVERT(varchar,@Date,112) as INT);
-- Result: 20161225
 
-- SQL Server convert integer to datetime
DECLARE @iDate int
SET @iDate = 20151225
SELECT IntegerToDatetime = CAST(convert(varchar,@iDate) as datetime)
-- 2015-12-25 00:00:00.000
 
-- Alternates: date-only datetime values
-- SQL Server floor date - sql convert datetime
SELECT [DATE-ONLY]=CONVERT(DATETIME, FLOOR(CONVERT(FLOAT, GETDATE())))
SELECT [DATE-ONLY]=CONVERT(DATETIME, FLOOR(CONVERT(MONEY, GETDATE())))
-- SQL Server cast string to datetime
-- SQL Server datetime to string convert
SELECT [DATE-ONLY]=CAST(CONVERT(varchar, GETDATE(), 101) AS DATETIME)
-- SQL Server dateadd function - T-SQL datediff function
-- SQL strip time from date - MSSQL strip time from datetime
SELECT getdate() ,dateadd(dd, datediff(dd, 0, getdate()), 0)
-- Results: 2016-01-23 05:35:52.793 2016-01-23 00:00:00.000

-- String date  - 10 bytes of storage
SELECT [STRING DATE]=CONVERT(varchar,  GETDATE(), 110)
SELECT [STRING DATE]=CONVERT(varchar,  CURRENT_TIMESTAMP, 110)
-- Same results: 01-02-2012
 
-- SQL Server cast datetime as string - sql datetime formatting
SELECT stringDateTime=CAST (getdate() as varchar) -- Dec 29 2012  3:47AM
The BEST 70-461 SQL Server 2012 Querying Exam Prep Book!

----------
-- SQL date range BETWEEN operator
----------
-- SQL date range select - date range search - T-SQL date range query
-- Count Sales Orders for 2003 OCT-NOV
DECLARE  @StartDate DATETIME,  @EndDate DATETIME
SET @StartDate = convert(DATETIME,'10/01/2003',101)
SET @EndDate   = convert(DATETIME,'11/30/2003',101)
 
SELECT @StartDate, @EndDate
-- 2003-10-01 00:00:00.000  2003-11-30 00:00:00.000
SELECT dateadd(DAY,1,@EndDate),
       dateadd(ms,-3,dateadd(DAY,1,@EndDate))
-- 2003-12-01 00:00:00.000  2003-11-30 23:59:59.997
 
-- MSSQL date range select using >= and <
SELECT [Sales Orders for 2003 OCT-NOV] = COUNT(* )
FROM   Sales.SalesOrderHeader
WHERE  OrderDate >= @StartDate AND OrderDate < dateadd(DAY,1,@EndDate)
/* Sales Orders for 2003 OCT-NOV
   3668 */
 
-- Equivalent date range query using BETWEEN comparison
-- It requires a bit of trick programming
SELECT [Sales Orders for 2003 OCT-NOV] = COUNT(* )
FROM   Sales.SalesOrderHeader
WHERE  OrderDate BETWEEN @StartDate AND dateadd(ms,-3,dateadd(DAY,1,@EndDate))
-- 3668
 
USE AdventureWorks;
-- SQL between string dates
SELECT POs=COUNT(*) FROM Purchasing.PurchaseOrderHeader
WHERE OrderDate BETWEEN '20040201' AND '20040210' -- Result: 108
 
-- SQL BETWEEN dates without time - time stripped - time removed - date part only
SELECT POs=COUNT(*) FROM Purchasing.PurchaseOrderHeader
WHERE datediff(dd,0,OrderDate)
  BETWEEN datediff(dd,0,'20040201 12:11:39') AND datediff(dd,0,'20040210 14:33:19')
-- 108

-- BETWEEN is equivalent to >=...AND....<=
SELECT POs=COUNT(*) FROM Purchasing.PurchaseOrderHeader
WHERE OrderDate
BETWEEN '2004-02-01 00:00:00.000' AND '2004-02-10  00:00:00.000'
/* Orders with OrderDates
'2004-02-10  00:00:01.000'  - 1 second after midnight (12:00AM)
'2004-02-10  00:01:00.000'  - 1 minute after midnight
'2004-02-10  01:00:00.000'  - 1 hour after midnight
are not included in the two queries above. */
-- To include the entire day of 2004-02-10 use:
SELECT POs=COUNT(*) FROM Purchasing.PurchaseOrderHeader
WHERE OrderDate >= '20040201' AND OrderDate < '20040211'

----------
-- Calculate week ranges in a year
----------
DECLARE @Year INT = '2016';
WITH cteDays AS (SELECT DayOfYear=Dateadd(dd, number,
                 CONVERT(DATE, CONVERT(char(4),@Year)+'0101'))
                 FROM master.dbo.spt_values WHERE type='P'),
CTE AS (SELECT DayOfYear, WeekOfYear=DATEPART(week,DayOfYear)
        FROM cteDays WHERE YEAR(DayOfYear)= @YEAR)
SELECT WeekOfYear, StartOfWeek=MIN(DayOfYear), EndOfWeek=MAX(DayOfYear)
FROM CTE  GROUP BY WeekOfYear ORDER BY WeekOfYear
------------
-- Date validation function ISDATE - returns 1 or 0 - SQL datetime functions
------------
DECLARE @StringDate varchar(32)
SET @StringDate = '2011-03-15 18:50'
IF EXISTS( SELECT * WHERE ISDATE(@StringDate) = 1)
    PRINT 'VALID DATE: ' + @StringDate
ELSE
    PRINT 'INVALID DATE: ' + @StringDate
GO
-- Result: VALID DATE: 2011-03-15 18:50
 
DECLARE @StringDate varchar(32)
SET @StringDate = '20112-03-15 18:50'
IF EXISTS( SELECT * WHERE ISDATE(@StringDate) = 1)
    PRINT 'VALID DATE: ' + @StringDate
ELSE  PRINT 'INVALID DATE: ' + @StringDate
-- Result: INVALID DATE: 20112-03-15 18:50

-- First and last day of date periods - SQL Server 2008 and on code
DECLARE @Date DATE = '20161023'
SELECT ReferenceDate   = @Date 
SELECT FirstDayOfYear  = CONVERT(DATE, dateadd(yy, datediff(yy,0, @Date),0))
SELECT LastDayOfYear   = CONVERT(DATE, dateadd(yy, datediff(yy,0, @Date)+1,-1))
SELECT FDofSemester = CONVERT(DATE, dateadd(qq,((datediff(qq,0,@Date)/2)*2),0))
SELECT LastDayOfSemester 
= CONVERT(DATE, dateadd(qq,((datediff(qq,0,@Date)/2)*2)+2,-1))
SELECT FirstDayOfQuarter  = CONVERT(DATE, dateadd(qq, datediff(qq,0, @Date),0))
-- 2016-10-01
SELECT LastDayOfQuarter = CONVERT(DATE, dateadd(qq, datediff(qq,0,@Date)+1,-1))
-- 2016-12-31
SELECT FirstDayOfMonth = CONVERT(DATE, dateadd(mm, datediff(mm,0, @Date),0))
SELECT LastDayOfMonth  = CONVERT(DATE, dateadd(mm, datediff(mm,0, @Date)+1,-1))
SELECT FirstDayOfWeek  = CONVERT(DATE, dateadd(wk, datediff(wk,0, @Date),0))
SELECT LastDayOfWeek   = CONVERT(DATE, dateadd(wk, datediff(wk,0, @Date)+1,-1))
-- 2016-10-30
 
-- Month sequence generator - sequential numbers / dates
DECLARE @Date date = '2000-01-01'
SELECT MonthStart=dateadd(MM, number, @Date)
FROM  master.dbo.spt_values
WHERE type='P' AND  dateadd(MM, number, @Date) <= CURRENT_TIMESTAMP
ORDER BY MonthStart
/* MonthStart
2000-01-01
2000-02-01
2000-03-01 ....*/
 

 
The BEST 70-461 SQL Server 2012 Querying Exam Prep Book!

------------
-- Selected named date styles
------------
DECLARE @DateTimeValue varchar(32)
-- US-Style
SELECT @DateTimeValue = '10/23/2016'
SELECT StringDate=@DateTimeValue,
[US-Style] = CONVERT(datetime, @DatetimeValue)
 
SELECT @DateTimeValue = '10/23/2016 23:01:05'
SELECT StringDate = @DateTimeValue,
[US-Style] = CONVERT(datetime, @DatetimeValue)
 
-- UK-Style, British/French - convert string to datetime sql
-- sql convert string to datetime
SELECT @DateTimeValue = '23/10/16 23:01:05'
SELECT StringDate = @DateTimeValue,
[UK-Style] = CONVERT(datetime, @DatetimeValue, 3)
 
SELECT @DateTimeValue = '23/10/2016 04:01 PM'
SELECT StringDate = @DateTimeValue,
[UK-Style] = CONVERT(datetime, @DatetimeValue, 103)
 
-- German-Style
SELECT @DateTimeValue = '23.10.16 23:01:05'
SELECT StringDate = @DateTimeValue,
[German-Style] = CONVERT(datetime, @DatetimeValue, 4)
 
SELECT @DateTimeValue = '23.10.2016 04:01 PM'
SELECT StringDate = @DateTimeValue,
[German-Style] = CONVERT(datetime, @DatetimeValue, 104)
------------ 
 
-- Double conversion to US-Style 107 with century: Oct 23, 2016
SET @DateTimeValue='10/23/16'
SELECT StringDate=@DateTimeValue,
[US-Style] = CONVERT(varchar, CONVERT(datetime, @DateTimeValue),107)
 
-- Using DATEFORMAT - UK-Style - SQL dateformat
SET @DateTimeValue='23/10/16'
SET DATEFORMAT dmy
SELECT StringDate=@DateTimeValue,
[Date Time] = CONVERT(datetime, @DatetimeValue)
-- Using DATEFORMAT - US-Style
SET DATEFORMAT mdy 
-- Finding out date format for a session
SELECT session_id, date_format from sys.dm_exec_sessions
------------

  -- Convert date string from DD/MM/YYYY UK format to MM/DD/YYYY US format
DECLARE @UKdate char(10) = '15/03/2016'
SELECT CONVERT(CHAR(10), CONVERT(datetime, @UKdate,103),101)
-- 03/15/2016

-- DATEPART datetime function example - SQL Server datetime functions
SELECT * FROM Northwind.dbo.Orders
WHERE DATEPART(YEAR, OrderDate) = '1996' AND
      DATEPART(MONTH,OrderDate) = '07'   AND
      DATEPART(DAY, OrderDate)  = '10'
 
-- Alternate syntax for DATEPART example
SELECT * FROM Northwind.dbo.Orders
WHERE YEAR(OrderDate)         = '1996' AND
      MONTH(OrderDate)        = '07'   AND
      DAY(OrderDate)          = '10'
------------
-- T-SQL calculate the number of business days function / UDF - exclude SAT & SUN
------------
CREATE FUNCTION fnBusinessDays (@StartDate DATETIME, @EndDate   DATETIME)
RETURNS INT AS
  BEGIN
    IF (@StartDate IS NULL OR @EndDate IS NULL)  RETURN (0)
    DECLARE  @i INT = 0;
    WHILE (@StartDate <= @EndDate)
      BEGIN
        SET @i = @i + CASE
                        WHEN datepart(dw,@StartDate) BETWEEN 2 AND 6 THEN 1
                        ELSE 0
                      END 
        SET @StartDate = @StartDate + 1
      END  -- while 
    RETURN (@i)
  END -- function
GO
SELECT dbo.fnBusinessDays('2016-01-01','2016-12-31')
-- 261
------------

-- T-SQL DATENAME function usage for weekdays
SELECT DayName=DATENAME(weekday, OrderDate), SalesPerWeekDay = COUNT(*)
FROM AdventureWorks2008.Sales.SalesOrderHeader
GROUP BY DATENAME(weekday, OrderDate), DATEPART(weekday,OrderDate)
ORDER BY DATEPART(weekday,OrderDate)
/* DayName   SalesPerWeekDay
Sunday      4482
Monday      4591
Tuesday     4346.... */
 
-- DATENAME application for months
SELECT MonthName=DATENAME(month, OrderDate), SalesPerMonth = COUNT(*)
FROM AdventureWorks2008.Sales.SalesOrderHeader
GROUP BY DATENAME(month, OrderDate), MONTH(OrderDate) ORDER BY MONTH(OrderDate)
/* MonthName      SalesPerMonth
January           2483
February          2686
March             2750
April             2740....  */
 
-- Getting month name from month number
SELECT DATENAME(MM,dateadd(MM,7,-1))  -- July

       ARTICLE - Essential SQL Server Date, Time and DateTime Functions
       ARTICLE - Demystifying the SQL Server DATETIME Datatype
------------
-- Extract string date from text with PATINDEX pattern matching
-- Apply sql server string to date conversion
------------
USE tempdb;
go
CREATE TABLE InsiderTransaction (
      InsiderTransactionID int identity primary key,
      TradeDate datetime,
      TradeMsg varchar(256),
      ModifiedDate datetime default (getdate()))
-- Populate table with dummy data
INSERT InsiderTransaction (TradeMsg) VALUES(
'INSIDER TRAN QABC Hammer, Bruce D. CSO 09-02-08 Buy 2,000 6.10')
INSERT InsiderTransaction (TradeMsg) VALUES(
'INSIDER TRAN QABC Schmidt, Steven CFO 08-25-08 Buy 2,500 6.70')
INSERT InsiderTransaction (TradeMsg) VALUES(
'INSIDER TRAN QABC  Hammer, Bruce D. CSO  08-20-08 Buy 3,000 8.59')
INSERT InsiderTransaction (TradeMsg) VALUES(
'INSIDER TRAN QABC Walters,  Jeff CTO 08-15-08  Sell 5,648 8.49')
INSERT InsiderTransaction (TradeMsg) VALUES(
'INSIDER TRAN  QABC  Walters, Jeff CTO   08-15-08 Option Execute 5,648 2.15')
INSERT InsiderTransaction (TradeMsg) VALUES(
'INSIDER TRAN QABC Hammer, Bruce D. CSO 07-31-08  Buy 5,000 8.05')
INSERT InsiderTransaction (TradeMsg) VALUES(
'INSIDER TRAN QABC Lennot, Mark B. Director  08-31-07 Buy 1,500 9.97')
INSERT InsiderTransaction (TradeMsg) VALUES(
'INSIDER TRAN QABC  O''Neal, Linda COO  08-01-08 Sell 5,000 6.50') 
 
-- Extract dates from stock trade message text
-- Pattern match for MM-DD-YY using the PATINDEX string function
SELECT TradeDate=substring(TradeMsg,
       patindex('%[01][0-9]-[0123][0-9]-[0-9][0-9]%', TradeMsg),8)
FROM InsiderTransaction
WHERE  patindex('%[01][0-9]-[0123][0-9]-[0-9][0-9]%', TradeMsg) > 0
/* Partial results
TradeDate
09-02-08
08-25-08
08-20-08 */
 
-- Update table with extracted date
-- Convert string date to datetime
UPDATE InsiderTransaction
SET TradeDate = convert(datetime,  substring(TradeMsg,
       patindex('%[01][0-9]-[0123][0-9]-[0-9][0-9]%', TradeMsg),8))
WHERE  patindex('%[01][0-9]-[0123][0-9]-[0-9][0-9]%', TradeMsg) > 0
 
SELECT * FROM InsiderTransaction ORDER BY TradeDate desc
/* Partial results
InsiderTransactionID    TradeDate   TradeMsg    ModifiedDate
1     2008-09-02 00:00:00.000 INSIDER TRAN QABC Hammer, Bruce D. CSO 09-02-08 Buy 2,000 6.10      2008-12-22 20:25:19.263
2     2008-08-25 00:00:00.000 INSIDER TRAN QABC Schmidt, Steven CFO 08-25-08 Buy 2,500 6.70      2008-12-22 20:25:19.263 */
-- Cleanup task
DROP TABLE InsiderTransaction
 
/************
VALID DATE RANGES FOR DATE / DATETIME DATA TYPES
 
DATE (3 bytes) date range:
January 1, 1 A.D. through December 31, 9999 A.D.
 
SMALLDATETIME (4 bytes) date range:
January 1, 1900 through June 6, 2079
 
DATETIME (8 bytes) date range:
January 1, 1753 through December 31, 9999
 
DATETIME2 (6-8 bytes) date range:
January 1, 1 A.D. through December 31, 9999 A.D.
 
-- The statement below will give a date range error
SELECT CONVERT(smalldatetime, '2110-01-01')
/* Msg 242, Level 16, State 3, Line 1
The conversion of a varchar data type to a smalldatetime data type
resulted in an out-of-range value. */
************/
The BEST 70-461 SQL Server 2012 Querying Exam Prep Book!

------------
-- SQL CONVERT DATE/DATETIME script applying table variable
------------
-- SQL Server convert date
-- Datetime column is converted into date only string column
DECLARE @sqlConvertDate TABLE ( DatetimeColumn datetime,
                                DateColumn char(10));
INSERT @sqlConvertDate (DatetimeColumn) SELECT GETDATE()
 
UPDATE @sqlConvertDate
SET DateColumn = CONVERT(char(10), DatetimeColumn, 111)
SELECT * FROM @sqlConvertDate
 
-- SQL Server convert datetime - String date column converted into datetime column
UPDATE @sqlConvertDate
SET DatetimeColumn = CONVERT(Datetime, DateColumn, 111)
SELECT * FROM @sqlConvertDate
 
-- Equivalent formulation - SQL Server cast datetime
UPDATE @sqlConvertDate
SET DatetimeColumn = CAST(DateColumn AS datetime)
SELECT * FROM @sqlConvertDate
/* First results
DatetimeColumn                DateColumn
2012-12-25 15:54:10.363       2012/12/25 */
/* Second results:
DatetimeColumn                DateColumn
2012-12-25 00:00:00.000       2012/12/25  */
------------

-- SQL date sequence generation with dateadd & table variable
-- SQL Server cast datetime to string - SQL Server insert default values method
DECLARE @Sequence table (Sequence int identity(1,1))
DECLARE @i int; SET @i = 0
WHILE ( @i < 500)
BEGIN
      INSERT @Sequence DEFAULT VALUES
      SET @i = @i + 1
END
SELECT DateSequence = CAST(dateadd(day, Sequence,getdate()) AS varchar)
FROM @Sequence
/* Partial results:
DateSequence
Dec 31 2008  3:02AM
Jan  1 2009  3:02AM
Jan  2 2009  3:02AM
Jan  3 2009  3:02AM
Jan  4 2009  3:02AM */
 
-- SETTING FIRST DAY OF WEEK TO SUNDAY
SET DATEFIRST 7;
SELECT @@DATEFIRST
-- 7
SELECT CAST('2016-10-23' AS date) AS SelectDate
    ,DATEPART(dw, '2016-10-23') AS DayOfWeek;
-- 2016-10-23     1
 
------------
-- SQL Last Week calculations
------------
-- SQL last Friday - Implied string to datetime conversions in dateadd & datediff
DECLARE @BaseFriday CHAR(8), @LastFriday datetime, @LastMonday datetime
SET @BaseFriday = '19000105'
SELECT @LastFriday = dateadd(dd,
          (datediff (dd, @BaseFriday, CURRENT_TIMESTAMP) / 7) * 7, @BaseFriday)
SELECT [Last Friday] = @LastFriday
-- Result: 2008-12-26 00:00:00.000
 
-- SQL last Monday (last week's Monday)
SELECT @LastMonday=dateadd(dd,
          (datediff (dd, @BaseFriday, CURRENT_TIMESTAMP) / 7) * 7 - 4, @BaseFriday)
SELECT [Last Monday]= @LastMonday 
-- Result: 2008-12-22 00:00:00.000
 
-- SQL last week - SUN - SAT
SELECT [Last Week] = CONVERT(varchar,dateadd(day, -1, @LastMonday), 101)+ ' - ' +
                     CONVERT(varchar,dateadd(day, 1,  @LastFriday), 101)
-- Result: 12/21/2008 - 12/27/2008
 
-----------------
-- Specific day calculations
------------
-- First day of current month
SELECT dateadd(month, datediff(month, 0, getdate()), 0)
 -- 15th day of current month
SELECT dateadd(day,14,dateadd(month,datediff(month,0,getdate()),0))
-- First Monday of current month
SELECT dateadd(day, (9-datepart(weekday, 
       dateadd(month, datediff(month, 0, getdate()), 0)))%7, 
       dateadd(month, datediff(month, 0, getdate()), 0))
-- Next Monday calculation from the reference date which was a Monday
DECLARE @Now datetime = GETDATE();
DECLARE @NextMonday datetime = dateadd(dd, ((datediff(dd, '19000101', @Now)
                               / 7) * 7) + 7, '19000101');
SELECT [Now]=@Now, [Next Monday]=@NextMonday
-- Last Friday of current month
SELECT dateadd(day, -7+(6-datepart(weekday, 
       dateadd(month, datediff(month, 0, getdate())+1, 0)))%7, 
       dateadd(month, datediff(month, 0, getdate())+1, 0))
-- First day of next month
SELECT dateadd(month, datediff(month, 0, getdate())+1, 0)
-- 15th of next month
SELECT dateadd(day,14, dateadd(month, datediff(month, 0, getdate())+1, 0))
-- First Monday of next month
SELECT dateadd(day, (9-datepart(weekday, 
       dateadd(month, datediff(month, 0, getdate())+1, 0)))%7, 
       dateadd(month, datediff(month, 0, getdate())+1, 0))
 
------------
-- SQL Last Date calculations
------------
-- Last day of prior month - Last day of previous month
SELECT convert( varchar, dateadd(dd,-1,dateadd(mm, datediff(mm,0,getdate() ), 0)),101)
-- 01/31/2019
-- Last day of current month
SELECT convert( varchar, dateadd(dd,-1,dateadd(mm, datediff(mm,0,getdate())+1, 0)),101)
-- 02/28/2019
-- Last day of prior quarter - Last day of previous quarter
SELECT convert( varchar, dateadd(dd,-1,dateadd(qq, datediff(qq,0,getdate() ), 0)),101)
-- 12/31/2018
-- Last day of current quarter - Last day of current quarter
SELECT convert( varchar, dateadd(dd,-1,dateadd(qq, datediff(qq,0,getdate())+1, 0)),101)
-- 03/31/2019
-- Last day of prior year - Last day of previous year
SELECT convert( varchar, dateadd(dd,-1,dateadd(yy, datediff(yy,0,getdate() ), 0)),101)
-- 12/31/2018
-- Last day of current year
SELECT convert( varchar, dateadd(dd,-1,dateadd(yy, datediff(yy,0,getdate())+1, 0)),101)
-- 12/31/2019
------------
-- SQL Server dateformat and language setting
------------
-- T-SQL set language - String to date conversion
SET LANGUAGE us_english
SELECT CAST('2018-03-15' AS datetime)
-- 2018-03-15 00:00:00.000
 
SET LANGUAGE british
SELECT CAST('2018-03-15' AS datetime)
/* Msg 242, Level 16, State 3, Line 2
The conversion of a varchar data type to a datetime data type resulted in
an out-of-range value.
*/
SELECT CAST('2018-15-03' AS datetime)
-- 2018-03-15 00:00:00.000
 
SET LANGUAGE us_english
 
-- SQL dateformat with language dependency
SELECT name, alias, dateformat
FROM sys.syslanguages
WHERE langid in (0,1,2,4,5,6,7,10,11,13,23,31)
GO
/* 
name        alias             dateformat
us_english  English           mdy
Deutsch     German            dmy
Français    French            dmy
Dansk       Danish            dmy
Español     Spanish           dmy
Italiano    Italian           dmy
Nederlands  Dutch             dmy
Suomi       Finnish           dmy
Svenska     Swedish           ymd
magyar      Hungarian         ymd
British     British English   dmy
Arabic      Arabic            dmy */
------------
 
-- Generate list of months
;WITH CTE AS (
      SELECT      1 MonthNo, CONVERT(DATE, '19000101') MonthFirst
      UNION ALL
      SELECT      MonthNo+1, DATEADD(Month, 1, MonthFirst)
      FROM  CTE WHERE   Month(MonthFirst) < 12   )
SELECT      MonthNo AS MonthNumber, DATENAME(MONTH, MonthFirst) AS MonthName
FROM  CTE ORDER BY MonthNo
/* MonthNumber    MonthName
      1           January
      2           February
      3           March  ... */
------------

Related articles: 

The ultimate guide to the datetime datatypes

CAST and CONVERT (Transact-SQL)

CAST and CONVERT


--How to format datetime & date in Sql Server 2005
--https://anubhavg.wordpress.com/2009/06/11/how-to-format-datetime-date-in-sql-server-2005/



June 11, 2009 — Anubhav Goyal
Execute the following Microsoft SQL Server T-SQL datetime and date formatting scripts in Management Studio Query Editor to demonstrate the multitude of temporal data formats available in SQL Server.
First we start with the conversion options available for sql datetime formats with century (YYYY or CCYY format). Subtracting 100 from the Style (format) number will transform dates without century (YY). For example Style 103 is with century, Style 3 is without century. The default Style values – Style 0 or 100, 9 or 109, 13 or 113, 20 or 120, and 21 or 121 – always return the century (yyyy) format.
 
— Microsoft SQL Server T-SQL date and datetime formats
— Date time formats – mssql datetime 
— MSSQL getdate returns current system date and time in standard internal format
SELECT convert(varchar, getdate(), 100) — mon dd yyyy hh:mmAM (or PM)
                                        — Oct  2 2008 11:01AM          
SELECT convert(varchar, getdate(), 101) — mm/dd/yyyy – 10/02/2008                  
SELECT convert(varchar, getdate(), 102) — yyyy.mm.dd – 2008.10.02           
SELECT convert(varchar, getdate(), 103) — dd/mm/yyyy
SELECT convert(varchar, getdate(), 104) — dd.mm.yyyy
SELECT convert(varchar, getdate(), 105) — dd-mm-yyyy
SELECT convert(varchar, getdate(), 106) — dd mon yyyy
SELECT convert(varchar, getdate(), 107) — mon dd, yyyy
SELECT convert(varchar, getdate(), 108) — hh:mm:ss
SELECT convert(varchar, getdate(), 109) — mon dd yyyy hh:mm:ss:mmmAM (or PM)
                                        — Oct  2 2008 11:02:44:013AM   
SELECT convert(varchar, getdate(), 110) — mm-dd-yyyy
SELECT convert(varchar, getdate(), 111) — yyyy/mm/dd
SELECT convert(varchar, getdate(), 112) — yyyymmdd
SELECT convert(varchar, getdate(), 113) — dd mon yyyy hh:mm:ss:mmm
                                        — 02 Oct 2008 11:02:07:577     
SELECT convert(varchar, getdate(), 114) — hh:mm:ss:mmm(24h)
SELECT convert(varchar, getdate(), 120) — yyyy-mm-dd hh:mm:ss(24h)
SELECT convert(varchar, getdate(), 121) — yyyy-mm-dd hh:mm:ss.mmm
SELECT convert(varchar, getdate(), 126) — yyyy-mm-ddThh:mm:ss.mmm
                                        — 2008-10-02T10:52:47.513
— SQL create different date styles with t-sql string functions
SELECT replace(convert(varchar, getdate(), 111), ‘/’, ‘ ‘) — yyyy mm dd
SELECT convert(varchar(7), getdate(), 126)                 — yyyy-mm
SELECT right(convert(varchar, getdate(), 106), 8)          — mon yyyy
————
— SQL Server date formatting function – convert datetime to string
————
— SQL datetime functions
— SQL Server date formats
— T-SQL convert dates
— Formatting dates sql server
CREATE FUNCTION dbo.fnFormatDate (@Datetime DATETIME, @FormatMask VARCHAR(32))
RETURNS VARCHAR(32)
AS
BEGIN
    DECLARE @StringDate VARCHAR(32)
    SET @StringDate = @FormatMask
    IF (CHARINDEX (‘YYYY’,@StringDate) > 0)
       SET @StringDate = REPLACE(@StringDate, ‘YYYY’,
                         DATENAME(YY, @Datetime))
    IF (CHARINDEX (‘YY’,@StringDate) > 0)
       SET @StringDate = REPLACE(@StringDate, ‘YY’,
                         RIGHT(DATENAME(YY, @Datetime),2))
    IF (CHARINDEX (‘Month’,@StringDate) > 0)
       SET @StringDate = REPLACE(@StringDate, ‘Month’,
                         DATENAME(MM, @Datetime))
    IF (CHARINDEX (‘MON’,@StringDate COLLATE SQL_Latin1_General_CP1_CS_AS)>0)
       SET @StringDate = REPLACE(@StringDate, ‘MON’,
                         LEFT(UPPER(DATENAME(MM, @Datetime)),3))
    IF (CHARINDEX (‘Mon’,@StringDate) > 0)
       SET @StringDate = REPLACE(@StringDate, ‘Mon’,
                                     LEFT(DATENAME(MM, @Datetime),3))
    IF (CHARINDEX (‘MM’,@StringDate) > 0)
       SET @StringDate = REPLACE(@StringDate, ‘MM’,
                  RIGHT(‘0’+CONVERT(VARCHAR,DATEPART(MM, @Datetime)),2))
    IF (CHARINDEX (‘M’,@StringDate) > 0)
       SET @StringDate = REPLACE(@StringDate, ‘M’,
                         CONVERT(VARCHAR,DATEPART(MM, @Datetime)))
    IF (CHARINDEX (‘DD’,@StringDate) > 0)
       SET @StringDate = REPLACE(@StringDate, ‘DD’,
                         RIGHT(‘0’+DATENAME(DD, @Datetime),2))
    IF (CHARINDEX (‘D’,@StringDate) > 0)
       SET @StringDate = REPLACE(@StringDate, ‘D’,
                                     DATENAME(DD, @Datetime))   
RETURN @StringDate
END
GO
 
— Microsoft SQL Server date format function test
— MSSQL formatting dates
SELECT dbo.fnFormatDate (getdate(), ‘MM/DD/YYYY’)           — 01/03/2012
SELECT dbo.fnFormatDate (getdate(), ‘DD/MM/YYYY’)           — 03/01/2012
SELECT dbo.fnFormatDate (getdate(), ‘M/DD/YYYY’)            — 1/03/2012
SELECT dbo.fnFormatDate (getdate(), ‘M/D/YYYY’)             — 1/3/2012
SELECT dbo.fnFormatDate (getdate(), ‘M/D/YY’)               — 1/3/12
SELECT dbo.fnFormatDate (getdate(), ‘MM/DD/YY’)             — 01/03/12
SELECT dbo.fnFormatDate (getdate(), ‘MON DD, YYYY’)         — JAN 03, 2012
SELECT dbo.fnFormatDate (getdate(), ‘Mon DD, YYYY’)         — Jan 03, 2012
SELECT dbo.fnFormatDate (getdate(), ‘Month DD, YYYY’)       — January 03, 2012
SELECT dbo.fnFormatDate (getdate(), ‘YYYY/MM/DD’)           — 2012/01/03
SELECT dbo.fnFormatDate (getdate(), ‘YYYYMMDD’)             — 20120103
SELECT dbo.fnFormatDate (getdate(), ‘YYYY-MM-DD’)           — 2012-01-03
— CURRENT_TIMESTAMP returns current system date and time in standard internal format
SELECT dbo.fnFormatDate (CURRENT_TIMESTAMP,‘YY.MM.DD’)      — 12.01.03
GO
————
 
/***** SELECTED SQL DATE/DATETIME FORMATS WITH NAMES *****/
 
— SQL format datetime
— Default format: Oct 23 2006 10:40AM
SELECT [Default]=CONVERT(varchar,GETDATE(),100)
 
— US-Style format: 10/23/2006
SELECT [US-Style]=CONVERT(char,GETDATE(),101)
 
— ANSI format: 2006.10.23
SELECT [ANSI]=CONVERT(char,CURRENT_TIMESTAMP,102)
 
— UK-Style format: 23/10/2006
SELECT [UK-Style]=CONVERT(char,GETDATE(),103)
 
— German format: 23.10.2006
SELECT [German]=CONVERT(varchar,GETDATE(),104)
 
— ISO format: 20061023
SELECT ISO=CONVERT(varchar,GETDATE(),112)
 
— ISO8601 format: 2008-10-23T19:20:16.003
SELECT [ISO8601]=CONVERT(varchar,GETDATE(),126)
————
 
— SQL Server datetime formats
— Century date format MM/DD/YYYY usage in a query
— Format dates SQL Server 2005
SELECT TOP (1)
      SalesOrderID,
      OrderDate = CONVERT(char(10), OrderDate, 101),
      OrderDateTime = OrderDate
FROM AdventureWorks.Sales.SalesOrderHeader
/* Result
 
SalesOrderID      OrderDate               OrderDateTime
43697             07/01/2001          2001-07-01 00:00:00.000
*/
 
— SQL update datetime column
— SQL datetime DATEADD
UPDATE Production.Product
SET ModifiedDate=DATEADD(dd,1, ModifiedDate)
WHERE ProductID = 1001
 
— MM/DD/YY date format
— Datetime format sql
SELECT TOP (1)
      SalesOrderID,
      OrderDate = CONVERT(varchar(8), OrderDate, 1),
      OrderDateTime = OrderDate
FROM AdventureWorks.Sales.SalesOrderHeader
ORDER BY SalesOrderID desc
/* Result
 
SalesOrderID      OrderDate         OrderDateTime
75123             07/31/04          2004-07-31 00:00:00.000
*/
 
— Combining different style formats for date & time
— Datetime formats
— Datetime formats sql
DECLARE @Date DATETIME
SET @Date = ‘2015-12-22 03:51 PM’
SELECT CONVERT(CHAR(10),@Date,110) + SUBSTRING(CONVERT(varchar,@Date,0),12,8)
— Result: 12-22-2015  3:51PM
 
— Microsoft SQL Server cast datetime to string
SELECT stringDateTime=CAST (getdate() as varchar)
— Result: Dec 29 2012  3:47AM
————
— SQL Server date and time functions overview
————
— SQL Server CURRENT_TIMESTAMP function
— SQL Server datetime functions
— local NYC – EST – Eastern Standard Time zone
— SQL DATEADD function – SQL DATEDIFF function
SELECT CURRENT_TIMESTAMP                        — 2012-01-05 07:02:10.577
— SQL Server DATEADD function
SELECT DATEADD(month,2,‘2012-12-09’)            — 2013-02-09 00:00:00.000
— SQL Server DATEDIFF function
SELECT DATEDIFF(day,‘2012-12-09’,‘2013-02-09’)  — 62
— SQL Server DATENAME function
SELECT DATENAME(month,   ‘2012-12-09’)          — December
SELECT DATENAME(weekday, ‘2012-12-09’)          — Sunday
— SQL Server DATEPART function
SELECT DATEPART(month, ‘2012-12-09’)            — 12
— SQL Server DAY function
SELECT DAY(‘2012-12-09’)                        — 9
— SQL Server GETDATE function
— local NYC – EST – Eastern Standard Time zone
SELECT GETDATE()                                — 2012-01-05 07:02:10.577
— SQL Server GETUTCDATE function
— London – Greenwich Mean Time
SELECT GETUTCDATE()                             — 2012-01-05 12:02:10.577
— SQL Server MONTH function
SELECT MONTH(‘2012-12-09’)                      — 12
— SQL Server YEAR function
SELECT YEAR(‘2012-12-09’)                       — 2012
 
 
————
— T-SQL Date and time function application
— CURRENT_TIMESTAMP and getdate() are the same in T-SQL
————
— SQL first day of the month
— SQL first date of the month
— SQL first day of current month – 2012-01-01 00:00:00.000
SELECT DATEADD(dd,0,DATEADD(mm, DATEDIFF(mm,0,CURRENT_TIMESTAMP),0))
— SQL last day of the month
— SQL last date of the month
— SQL last day of current month – 2012-01-31 00:00:00.000
SELECT DATEADD(dd,-1,DATEADD(mm, DATEDIFF(mm,0,CURRENT_TIMESTAMP)+1,0))
— SQL first day of last month
— SQL first day of previous month – 2011-12-01 00:00:00.000
SELECT DATEADD(mm,-1,DATEADD(mm, DATEDIFF(mm,0,CURRENT_TIMESTAMP),0))
— SQL last day of last month
— SQL last day of previous month – 2011-12-31 00:00:00.000
SELECT DATEADD(dd,-1,DATEADD(mm, DATEDIFF(mm,0,DATEADD(MM,-1,GETDATE()))+1,0))
— SQL first day of next month – 2012-02-01 00:00:00.000
SELECT DATEADD(mm,1,DATEADD(mm, DATEDIFF(mm,0,CURRENT_TIMESTAMP),0))
— SQL last day of next month – 2012-02-28 00:00:00.000
SELECT DATEADD(dd,-1,DATEADD(mm, DATEDIFF(mm,0,DATEADD(MM,1,GETDATE()))+1,0))
GO
— SQL first day of a month – 2012-10-01 00:00:00.000
DECLARE @Date datetime; SET @Date = ‘2012-10-23’
SELECT DATEADD(dd,0,DATEADD(mm, DATEDIFF(mm,0,@Date),0))
GO
— SQL last day of a month – 2012-03-31 00:00:00.000
DECLARE @Date datetime; SET @Date = ‘2012-03-15’
SELECT DATEADD(dd,-1,DATEADD(mm, DATEDIFF(mm,0,@Date)+1,0))
GO
— SQL first day of year 
— SQL first day of the year  –  2012-01-01 00:00:00.000
SELECT DATEADD(yy, DATEDIFF(yy,0,CURRENT_TIMESTAMP), 0)
— SQL last day of year  
— SQL last day of the year   – 2012-12-31 00:00:00.000
SELECT DATEADD(yy,1, DATEADD(dd, –1, DATEADD(yy,
                     DATEDIFF(yy,0,CURRENT_TIMESTAMP), 0)))
— SQL last day of last year
— SQL last day of previous year   – 2011-12-31 00:00:00.000
SELECT DATEADD(dd,-1,DATEADD(yy,DATEDIFF(yy,0,CURRENT_TIMESTAMP), 0))
GO
— SQL calculate age in years, months, days
— SQL table-valued function
— SQL user-defined function – UDF
— SQL Server age calculation – date difference
— Format dates SQL Server 2008
USE AdventureWorks2008;
GO
CREATE FUNCTION fnAge  (@BirthDate DATETIME)
RETURNS @Age TABLE(Years  INT,
                   Months INT,
                   Days   INT)
AS
  BEGIN
    DECLARE  @EndDate     DATETIME, @Anniversary DATETIME
    SET @EndDate = Getdate()
    SET @Anniversary = Dateadd(yy,Datediff(yy,@BirthDate,@EndDate),@BirthDate)
    
    INSERT @Age
    SELECT Datediff(yy,@BirthDate,@EndDate) – (CASE
                                                 WHEN @Anniversary > @EndDate THEN 1
                                                 ELSE 0
                                               END), 0, 0
     UPDATE @Age     SET    Months = Month(@EndDate – @Anniversary) – 1
    UPDATE @Age     SET    Days = Day(@EndDate – @Anniversary) – 1
    RETURN
  END
GO
 
— Test table-valued UDF
SELECT * FROM   fnAge(‘1956-10-23’)
SELECT * FROM   dbo.fnAge(‘1956-10-23’)
/* Results
Years       Months      Days
52          4           1
*/
 
———-
— SQL date range between
———-
— SQL between dates
USE AdventureWorks;
— SQL between
SELECT POs=COUNT(*) FROM Purchasing.PurchaseOrderHeader
WHERE OrderDate BETWEEN ‘20040301’ AND ‘20040315’
— Result: 108
 
— BETWEEN operator is equivalent to >=…AND….<=
SELECT POs=COUNT(*) FROM Purchasing.PurchaseOrderHeader
WHERE OrderDate
BETWEEN ‘2004-03-01 00:00:00.000’ AND ‘2004-03-15  00:00:00.000’
/*
Orders with OrderDates
‘2004-03-15  00:00:01.000’  – 1 second after midnight (12:00AM)
‘2004-03-15  00:01:00.000’  – 1 minute after midnight
‘2004-03-15  01:00:00.000’  – 1 hour after midnight
 
are not included in the two queries above.
*/
— To include the entire day of 2004-03-15 use the following two solutions
SELECT POs=COUNT(*) FROM Purchasing.PurchaseOrderHeader
WHERE OrderDate >= ‘20040301’ AND OrderDate < ‘20040316’
 
— SQL between with DATE type (SQL Server 2008)
SELECT POs=COUNT(*) FROM Purchasing.PurchaseOrderHeader
WHERE CONVERT(DATE, OrderDate) BETWEEN ‘20040301’ AND ‘20040315’
———-
— Non-standard format conversion: 2011 December 14
— SQL datetime to string
SELECT [YYYY Month DD] =
CAST(YEAR(GETDATE()) AS VARCHAR(4))+ ‘ ‘+
DATENAME(MM, GETDATE()) + ‘ ‘ +
CAST(DAY(GETDATE()) AS VARCHAR(2))
 
— Converting datetime to YYYYMMDDHHMMSS format: 20121214172638
SELECT replace(convert(varchar, getdate(),111),‘/’,”) +
replace(convert(varchar, getdate(),108),‘:’,”)
 
— Datetime custom format conversion to YYYY_MM_DD
select CurrentDate=rtrim(year(getdate())) + ‘_’ +
right(‘0’ + rtrim(month(getdate())),2) + ‘_’ +
right(‘0’ + rtrim(day(getdate())),2)
 
— Converting seconds to HH:MM:SS format
declare @Seconds int
set @Seconds = 10000
select TimeSpan=right(‘0’ +rtrim(@Seconds / 3600),2) + ‘:’ +
right(‘0’ + rtrim((@Seconds % 3600) / 60),2) + ‘:’ +
right(‘0’ + rtrim(@Seconds % 60),2)
— Result: 02:46:40
 
— Test result
select 2*3600 + 46*60 + 40
— Result: 10000
— Set the time portion of a datetime value to 00:00:00.000
— SQL strip time from date
— SQL strip time from datetime
SELECT CURRENT_TIMESTAMP ,DATEADD(dd, DATEDIFF(dd, 0, CURRENT_TIMESTAMP), 0)
— Results: 2014-01-23 05:35:52.793 2014-01-23 00:00:00.000
/*******
 
VALID DATE RANGES FOR DATE/DATETIME DATA TYPES
 
SMALLDATETIME date range:
January 1, 1900 through June 6, 2079
 
DATETIME date range:
January 1, 1753 through December 31, 9999
 
DATETIME2 date range (SQL Server 2008):
January 1,1 AD through December 31, 9999 AD
 
DATE date range (SQL Server 2008):
January 1, 1 AD through December 31, 9999 AD
 
*******/
— Selecting with CONVERT into different styles
— Note: Only Japan & ISO styles can be used in ORDER BY
SELECT TOP(1)
     Italy  = CONVERT(varchar, OrderDate, 105)
   , USA    = CONVERT(varchar, OrderDate, 110)
   , Japan  = CONVERT(varchar, OrderDate, 111)
   , ISO    = CONVERT(varchar, OrderDate, 112)
FROM AdventureWorks.Purchasing.PurchaseOrderHeader
ORDER BY PurchaseOrderID DESC
/* Results
Italy       USA         Japan       ISO
25-07-2004  07-25-2004  2004/07/25  20040725
*/
— SQL Server convert date to integer
DECLARE @Datetime datetime
SET @Datetime = ‘2012-10-23 10:21:05.345’
SELECT DateAsInteger = CAST (CONVERT(varchar,@Datetime,112) as INT)
— Result: 20121023
 
— SQL Server convert integer to datetime
DECLARE @intDate int
SET @intDate = 20120315
SELECT IntegerToDatetime = CAST(CAST(@intDate as varchar) as datetime)
— Result: 2012-03-15 00:00:00.000
————
— SQL Server CONVERT script applying table INSERT/UPDATE
————
— SQL Server convert date
— Datetime column is converted into date only string column
USE tempdb;
GO
CREATE TABLE sqlConvertDateTime   (
            DatetimeCol datetime,
            DateCol char(8));
INSERT sqlConvertDateTime (DatetimeCol) SELECT GETDATE()
 
UPDATE sqlConvertDateTime
SET DateCol = CONVERT(char(10), DatetimeCol, 112)
SELECT * FROM sqlConvertDateTime
 
— SQL Server convert datetime
— The string date column is converted into datetime column
UPDATE sqlConvertDateTime
SET DatetimeCol = CONVERT(Datetime, DateCol, 112)
SELECT * FROM sqlConvertDateTime
 
— Adding a day to the converted datetime column with DATEADD
UPDATE sqlConvertDateTime
SET DatetimeCol = DATEADD(day, 1, CONVERT(Datetime, DateCol, 112))
SELECT * FROM sqlConvertDateTime
 
— Equivalent formulation
— SQL Server cast datetime
UPDATE sqlConvertDateTime
SET DatetimeCol = DATEADD(dd, 1, CAST(DateCol AS datetime))
SELECT * FROM sqlConvertDateTime
GO
DROP TABLE sqlConvertDateTime
GO
/* First results
DatetimeCol                   DateCol
2014-12-25 16:04:15.373       20141225 */
 
/* Second results:
DatetimeCol                   DateCol
2014-12-25 00:00:00.000       20141225  */
 
/* Third results:
DatetimeCol                   DateCol
2014-12-26 00:00:00.000       20141225  */
————
— SQL month sequence – SQL date sequence generation with table variable
— SQL Server cast string to datetime – SQL Server cast datetime to string
— SQL Server insert default values method
DECLARE @Sequence table (Sequence int identity(1,1))
DECLARE @i int; SET @i = 0
DECLARE @StartDate datetime;
SET @StartDate = CAST(CONVERT(varchar, year(getdate()))+
                 RIGHT(‘0’+convert(varchar,month(getdate())),2) + ’01’ AS DATETIME)
WHILE ( @i < 120)
BEGIN
      INSERT @Sequence DEFAULT VALUES
      SET @i = @i + 1
END
SELECT MonthSequence = CAST(DATEADD(month, Sequence,@StartDate) AS varchar)
FROM @Sequence
GO
/* Partial results:
MonthSequence
Jan  1 2012 12:00AM
Feb  1 2012 12:00AM
Mar  1 2012 12:00AM
Apr  1 2012 12:00AM
*/
————
 
————
— SQL Server Server datetime internal storage
— SQL Server datetime formats
————
— SQL Server datetime to hex
SELECT Now=CURRENT_TIMESTAMP, HexNow=CAST(CURRENT_TIMESTAMP AS BINARY(8))
/* Results
 
Now                     HexNow
2009-01-02 17:35:59.297 0x00009B850122092D
*/
— SQL Server date part – left 4 bytes – Days since 1900-01-01
SELECT Now=DATEADD(DAY, CONVERT(INT, 0x00009B85), ‘19000101’)
GO
— Result: 2009-01-02 00:00:00.000
 
— SQL time part – right 4 bytes – milliseconds since midnight
— 1000/300 is an adjustment factor
— SQL dateadd to Midnight
SELECT Now=DATEADD(MS, (1000.0/300)* CONVERT(BIGINT, 0x0122092D), ‘2009-01-02’)
GO
— Result: 2009-01-02 17:35:59.290
————
————
— String date and datetime date&time columns usage
— SQL Server datetime formats in tables
————
USE tempdb;
SET NOCOUNT ON;
— SQL Server select into table create
SELECT TOP (5)
      FullName=convert(nvarchar(50),FirstName+‘ ‘+LastName),
      BirthDate = CONVERT(char(8), BirthDate,112),
      ModifiedDate = getdate()
INTO Employee
FROM AdventureWorks.HumanResources.Employee e
INNER JOIN AdventureWorks.Person.Contact c
ON c.ContactID = e.ContactID
ORDER BY EmployeeID
GO
— SQL Server alter table
ALTER TABLE Employee ALTER COLUMN FullName nvarchar(50) NOT NULL
GO
ALTER TABLE Employee
ADD CONSTRAINT [PK_Employee] PRIMARY KEY (FullName )
GO
/* Results
 
Table definition for the Employee table
Note: BirthDate is string date (only)
 
CREATE TABLE dbo.Employee(
      FullName nvarchar(50) NOT NULL PRIMARY KEY,
      BirthDate char(8) NULL,
      ModifiedDate datetime NOT NULL
      )
*/
SELECT * FROM Employee ORDER BY FullName
GO
/* Results
FullName                BirthDate   ModifiedDate
Guy Gilbert             19720515    2009-01-03 10:10:19.217
Kevin Brown             19770603    2009-01-03 10:10:19.217
Rob Walters             19650123    2009-01-03 10:10:19.217
Roberto Tamburello      19641213    2009-01-03 10:10:19.217
Thierry D’Hers          19490829    2009-01-03 10:10:19.217
*/
 
— SQL Server age
SELECT FullName, Age = DATEDIFF(YEAR, BirthDate, GETDATE()),
       RowMaintenanceDate = CAST (ModifiedDate AS varchar)
FROM Employee ORDER BY FullName
GO
/* Results
FullName                Age   RowMaintenanceDate
Guy Gilbert             37    Jan  3 2009 10:10AM
Kevin Brown             32    Jan  3 2009 10:10AM
Rob Walters             44    Jan  3 2009 10:10AM
Roberto Tamburello      45    Jan  3 2009 10:10AM
Thierry D’Hers          60    Jan  3 2009 10:10AM
*/
 
— SQL Server age of Rob Walters on specific dates
— SQL Server string to datetime implicit conversion with DATEADD
SELECT AGE50DATE = DATEADD(YY, 50, ‘19650123’)
GO
— Result: 2015-01-23 00:00:00.000
 
— SQL Server datetime to string, Italian format for ModifiedDate
— SQL Server string to datetime implicit conversion with DATEDIFF
SELECT FullName,
         AgeDEC31 = DATEDIFF(YEAR, BirthDate, ‘20141231’),
         AgeJAN01 = DATEDIFF(YEAR, BirthDate, ‘20150101’),
         AgeJAN23 = DATEDIFF(YEAR, BirthDate, ‘20150123’),
         AgeJAN24 = DATEDIFF(YEAR, BirthDate, ‘20150124’),
       ModDate = CONVERT(varchar, ModifiedDate, 105)
FROM Employee
WHERE FullName = ‘Rob Walters’
ORDER BY FullName
GO
/* Results
Important Note: age increments on Jan 1 (not as commonly calculated)
 
FullName    AgeDEC31    AgeJAN01    AgeJAN23    AgeJAN24    ModDate
Rob Walters 49          50          50          50          03-01-2009
*/
 
————
— SQL combine integer date & time into datetime
————
— Datetime format sql
— SQL stuff
DECLARE @DateTimeAsINT TABLE ( ID int identity(1,1) primary key, 
   DateAsINT int, 
   TimeAsINT int 
) 
— NOTE: leading zeroes in time is for readability only!  
INSERT @DateTimeAsINT (DateAsINT, TimeAsINT) VALUES (20121023, 235959)  
INSERT @DateTimeAsINT (DateAsINT, TimeAsINT) VALUES (20121023, 010204)  
INSERT @DateTimeAsINT (DateAsINT, TimeAsINT) VALUES (20121023, 002350)
INSERT @DateTimeAsINT (DateAsINT, TimeAsINT) VALUES (20121023, 000244)  
INSERT @DateTimeAsINT (DateAsINT, TimeAsINT) VALUES (20121023, 000050)  
INSERT @DateTimeAsINT (DateAsINT, TimeAsINT) VALUES (20121023, 000006)  
 
SELECT DateAsINT, TimeAsINT,
  CONVERT(datetime, CONVERT(varchar(8), DateAsINT) + ‘ ‘+
  STUFF(STUFF ( RIGHT(REPLICATE(‘0’, 6) + CONVERT(varchar(6), TimeAsINT), 6),
                  3, 0, ‘:’), 6, 0, ‘:’))  AS DateTimeValue
FROM   @DateTimeAsINT 
ORDER BY ID
GO
/* Results
DateAsINT   TimeAsINT   DateTimeValue
20121023    235959      2012-10-23 23:59:59.000
20121023    10204       2012-10-23 01:02:04.000
20121023    2350        2012-10-23 00:23:50.000
20121023    244         2012-10-23 00:02:44.000
20121023    50          2012-10-23 00:00:50.000
20121023    6           2012-10-23 00:00:06.000
*/
————
 
— SQL Server string to datetime, implicit conversion with assignment
UPDATE Employee SET ModifiedDate = ‘20150123’
WHERE FullName = ‘Rob Walters’
GO
SELECT ModifiedDate FROM Employee WHERE FullName = ‘Rob Walters’
GO
— Result: 2015-01-23 00:00:00.000
 
/* SQL string date, assemble string date from datetime parts  */
— SQL Server cast string to datetime – sql convert string date
— SQL Server number to varchar conversion
— SQL Server leading zeroes for month and day
— SQL Server right string function
UPDATE Employee SET BirthDate =
      CONVERT(char(4),YEAR(CAST(‘1965-01-23’ as DATETIME)))+
      RIGHT(‘0’+CONVERT(varchar,MONTH(CAST(‘1965-01-23’ as DATETIME))),2)+
      RIGHT(‘0’+CONVERT(varchar,DAY(CAST(‘1965-01-23’ as DATETIME))),2)
      WHERE FullName = ‘Rob Walters’
GO
SELECT BirthDate FROM Employee WHERE FullName = ‘Rob Walters’
GO
— Result: 19650123
 
— Perform cleanup action
DROP TABLE Employee
— SQL nocount
SET NOCOUNT OFF;
GO
————
————
— sql isdate function
————
USE tempdb;
— sql newid – random sort
SELECT top(3) SalesOrderID,
stringOrderDate = CAST (OrderDate AS varchar)
INTO DateValidation
FROM AdventureWorks.Sales.SalesOrderHeader
ORDER BY NEWID()
GO
SELECT * FROM DateValidation
/* Results
SalesOrderID      stringOrderDate
56720             Oct 26 2003 12:00AM
73737             Jun 25 2004 12:00AM
70573             May 14 2004 12:00AM
*/
— SQL update with top
UPDATE TOP(1) DateValidation
SET stringOrderDate = ‘Apb 29 2004 12:00AM’
GO
— SQL string to datetime fails without validation
SELECT SalesOrderID, OrderDate = CAST (stringOrderDate as datetime)
FROM DateValidation
GO
/* Msg 242, Level 16, State 3, Line 1
The conversion of a varchar data type to a datetime data type resulted in an
out-of-range value.
*/
— sql isdate – filter for valid dates
SELECT SalesOrderID, OrderDate = CAST (stringOrderDate as datetime)
FROM DateValidation
WHERE ISDATE(stringOrderDate) = 1
GO
/* Results
SalesOrderID      OrderDate
73737             2004-06-25 00:00:00.000
70573             2004-05-14 00:00:00.000
*/
— SQL drop table
DROP TABLE DateValidation
Go
 
————
— SELECT between two specified dates – assumption TIME part is 00:00:00.000
————
— SQL datetime between
— SQL select between two dates
SELECT EmployeeID, RateChangeDate
FROM AdventureWorks.HumanResources.EmployeePayHistory
WHERE RateChangeDate >= ‘1997-11-01’ AND 
      RateChangeDate < DATEADD(dd,1,‘1998-01-05’)
GO
/* Results
EmployeeID  RateChangeDate
3           1997-12-12 00:00:00.000
4           1998-01-05 00:00:00.000
*/
 
/* Equivalent to
 
— SQL datetime range
SELECT EmployeeID, RateChangeDate
FROM AdventureWorks.HumanResources.EmployeePayHistory
WHERE RateChangeDate >= ‘1997-11-01 00:00:00’ AND 
      RateChangeDate <  ‘1998-01-06 00:00:00’
GO
*/
————
— SQL datetime language setting
— SQL Nondeterministic function usage – result varies with language settings
SET LANGUAGE  ‘us_english’;  –– Jan 12 2015 12:00AM 
SELECT US = convert(VARCHAR,convert(DATETIME,’01/12/2015′));
SET LANGUAGE  ‘British’;     –– Dec  1 2015 12:00AM 
SELECT UK = convert(VARCHAR,convert(DATETIME,’01/12/2015′));
SET LANGUAGE  ‘German’;      –– Dez  1 2015 12:00AM 
SET LANGUAGE  ‘Deutsch’;     –– Dez  1 2015 12:00AM 
SELECT Germany = convert(VARCHAR,convert(DATETIME,’01/12/2015′));
SET LANGUAGE  ‘French’;      –– déc  1 2015 12:00AM 
SELECT France = convert(VARCHAR,convert(DATETIME,’01/12/2015′));
SET LANGUAGE  ‘Spanish’;     –– Dic  1 2015 12:00AM 
SELECT Spain = convert(VARCHAR,convert(DATETIME,’01/12/2015′));
SET LANGUAGE  ‘Hungarian’;   –– jan 12 2015 12:00AM 
SELECT Hungary = convert(VARCHAR,convert(DATETIME,’01/12/2015′));
SET LANGUAGE  ‘us_english’;
GO
————
————
— Function for Monday dates calculation
————
USE AdventureWorks2008;
GO
— SQL user-defined function
— SQL scalar function – UDF
CREATE FUNCTION fnMondayDate
               (@Year          INT,
                @Month         INT,
                @MondayOrdinal INT)
RETURNS DATETIME
AS
  BEGIN
    DECLARE  @FirstDayOfMonth CHAR(10),
             @SeedDate        CHAR(10)
    
    SET @FirstDayOfMonth = convert(VARCHAR,@Year) + ‘-‘ + convert(VARCHAR,@Month) + ‘-01’
    SET @SeedDate = ‘1900-01-01’
    
    RETURN DATEADD(DD,DATEDIFF(DD,@SeedDate,DATEADD(DD,(@MondayOrdinal * 7) – 1,
                  @FirstDayOfMonth)) / 7 * 7,  @SeedDate)
  END
GO
 
— Test Datetime UDF
— Third Monday in Feb, 2015
SELECT dbo.fnMondayDate(2016,2,3)
— 2015-02-16 00:00:00.000
 
— First Monday of current month
SELECT dbo.fnMondayDate(Year(getdate()),Month(getdate()),1)
— 2009-02-02 00:00:00.000  
————