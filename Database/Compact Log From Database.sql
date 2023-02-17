/**************************************************************************************

  Press "[CTRL] + [SHIFT] + [M]" to specify values for template parameters. Then press
  "[F5]" to use the Script below.

  ===================================================================================
   Script Short Description
  ===================================================================================

  This Script has as objective to make database size smaller compressing database
  log. You are going to compress "<Database Name, SYSNAME, >" log size.

**************************************************************************************/

SET NOCOUNT ON
DECLARE @DatabaseName SYSNAME = '<Database Name, SYSNAME, >'

DECLARE @Databases TABLE
(
  [Counter]         INT          IDENTITY(1,1)
, [DatabaseName]    VARCHAR(500)
, [DatabaseLogName] VARCHAR(500)
)

INSERT INTO 
  @Databases
SELECT 
  [database].[name]    AS "DatabaseName"
, [master_file].[name] AS "DatabaseLogName"
FROM 
  [sys].[databases]    AS "database"
  INNER JOIN
  [sys].[master_files] AS "master_file" ON [database].[database_id] = [master_file].[database_id]
WHERE 
      [database].[name] = @DatabaseName AND [database].[name] NOT IN('master','model','msdb', 'tempdb')
  AND [master_file].[file_id] = 2
ORDER BY [database].[Name]


DECLARE @DatabaseStart INT, @DatabaseEnd INT
SELECT @DatabaseStart = MIN([Counter]), @DatabaseEnd = MAX([Counter]) FROM @Databases

WHILE @DatabaseStart <= @DatabaseEnd
BEGIN
  DECLARE @DatabaseLogName NVARCHAR(MAX)
  SELECT @DatabaseName = [DatabaseName], @DatabaseLogName = [DatabaseLogName]
  FROM @Databases 
  WHERE [Counter] = @DatabaseStart

  PRINT @DatabaseName
  
  DECLARE @CommandSQL AS NVARCHAR(MAX) = ''
  SET @CommandSQL =                          'USE [' + @DatabaseName + '];'
  SET @CommandSQL = CHAR(13) + @CommandSQL + 'ALTER DATABASE [' + @DatabaseName + ']'
  SET @CommandSQL = CHAR(13) + @CommandSQL + 'SET RECOVERY SIMPLE;'
  SET @CommandSQL = CHAR(13) + @CommandSQL + 'DBCC SHRINKFILE('+ ''''+ @DatabaseLogName + '''' + ');'
  SET @CommandSQL = CHAR(13) + @CommandSQL + 'ALTER DATABASE [' + @DatabaseName + ']'
  SET @CommandSQL = CHAR(13) + @CommandSQL + 'SET RECOVERY FULL;' + CHAR(13) + CHAR(13)

  EXECUTE (@CommandSQL)
  SET @DatabaseStart = @DatabaseStart + 1
End