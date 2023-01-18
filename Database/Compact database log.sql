/**************************************************************************************

  Press [CTRL]+[SHIFT]+[M] to define parameters and values to be used on this current
  template.

  ===================================================================================
   Script Short Description
  ===================================================================================

  This Script has as objective to make database size smaller compressing database log. You
  are going to compress "<Database name:, , >" log size.

**************************************************************************************/

SET NOCOUNT ON
DECLARE @DatabaseName VARCHAR(500) = '<Database name:, , >'

DECLARE @Databases TABLE
(
    [Counter]         INT IDENTITY(1,1)
  , [DatabaseName]    VARCHAR(500)
  , [DatabaseLogName] VARCHAR(500)
)

INSERT INTO 
  @Databases
SELECT 
    [database].[name]    AS [DatabaseName]
  , [master_file].[name] AS [DatabaseLogName]
FROM 
  [sys].[databases]    AS [database]
  INNER JOIN
  [sys].[master_files] AS [master_file] ON [database].[database_id] = [master_file].[database_id]
WHERE 
      [database].[name]       = @DatabaseName
  AND [database].[name]       NOT IN('master','model','msdb', 'tempdb')
  AND [master_file].[file_id] = 2
ORDER BY [database].[Name]

DECLARE @DatabaseStart INT, @DatabaseEnd INT
SELECT   @DatabaseStart = MIN([Counter])
       , @DatabaseEnd   = MAX([Counter])
FROM @Databases
WHILE @DatabaseStart <= @DatabaseEnd
BEGIN
  DECLARE @DatabaseLogName NVARCHAR(500)
  SELECT 
      @DatabaseName    = [DatabaseName]
    , @DatabaseLogName = [DatabaseLogName]
  FROM
    @Databases 
  WHERE
    [Counter] = @DatabaseStart

  PRINT @DatabaseName
  
  DECLARE @CommandSQL NVARCHAR(4000)
  SET @CommandSQL = ''
  SET @CommandSQL = @CommandSQL + 'USE [' + @DatabaseName + '];' + char(13)
  SET @CommandSQL = @CommandSQL + 'ALTER DATABASE [' + @DatabaseName + ']' + Char(13)
  SET @CommandSQL = @CommandSQL + 'SET RECOVERY SIMPLE;' + Char(13)
  SET @CommandSQL = @CommandSQL + 'DBCC SHRINKFILE('+ ''''+ @DatabaseLogName + '''' + ');' + Char(13)
  SET @CommandSQL = @CommandSQL + 'ALTER DATABASE [' + @DatabaseName + ']' + Char(13)
  SET @CommandSQL = @CommandSQL + 'SET RECOVERY FULL;' + Char(13) + Char(13)

  EXECUTE (@CommandSQL)
  SET @DatabaseStart = @DatabaseStart + 1
End