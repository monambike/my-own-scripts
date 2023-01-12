/**************************************************************************************

  DESCRIPTION
  -------------------------------------------------------------------------------------
  This Script has as objective to see some informations about SQL Server databases such
  check last time database was accessed or used, collation, compatibility level, online state
  and others.


  COMMANDS FOR CLEARING CACHE
  -------------------------------------------------------------------------------------
  Run all the following commands to clear all Databases cache.

  DBCC FREEPROCCACHE
  GO
  DBCC DROPCLEANBUFFERS
  GO
  DBCC FREESYSTEMCACHE ('ALL')
  GO
  DBCC FREESESSIONCACHE 

**************************************************************************************/

DECLARE @Table TABLE([database_id] INT, [cached_page_count] INT)
INSERT INTO @Table
SELECT [database_id], COUNT(*) FROM sys.dm_os_buffer_descriptors GROUP BY DB_NAME([database_id]), [database_id]

SELECT
    [database].[database_id]              AS [DatabaseID]
  , [database].[name]                     AS [Database Name]
  , [database].[collation_name]           AS [Collation Name]
  , [database].[compatibility_level]      AS [Compatibility Level]
  , [database].[state_desc]               AS [Online State]
  , [database].[create_date]              AS [Creation Date]
  , MAX([usage_stats].[last_user_seek])   AS [Last User Seek]
  , MAX([usage_stats].[last_user_scan])   AS [Last User Scan]
  , MAX([usage_stats].[last_user_lookup]) AS [Last User Lookup]
  , MAX([usage_stats].[last_user_update]) AS [Last User Update]
  , CAST( [table].[cached_page_count]                     AS VARCHAR)        AS [Cached Pages Count]
  , CAST( [table].[cached_page_count] * 8 / 1024          AS VARCHAR) + 'MB' AS [Cached Size (MB)]
  , CAST(([table].[cached_page_count] * 8 / 1024) / 1000  AS VARCHAR) + 'GB' AS [Cached Size (GB)]
FROM
  sys.databases                AS [database]
  LEFT JOIN
  sys.dm_db_index_usage_stats  AS [usage_stats] ON [usage_stats].[database_id] = [database].[database_id]
  LEFT JOIN
  @Table                       AS [table]       ON [table].[database_id]       = [database].[database_id]
GROUP BY
    [database].[name]
  , [database].[database_id]
  , [database].[collation_name]
  , [database].[compatibility_level]
  , [database].[state_desc]
  , [database].[create_date]
  , [table].[cached_page_count]
ORDER BY
    CASE WHEN [database].[name] IN ('master', 'tempdb', 'model', 'msdb') THEN 0 ELSE 1 END
  , [database].[name]

SELECT  
    [history].[destination_database_name] AS [Restora Database Destination]
  , [history].[restore_date]              AS [Restore Date]
  , [history].[user_name]                 AS [User Who Restored the Database]
  , [history].[replace]                   AS [Replace Database Data]
  , [fileinfo].destination_phys_drive     AS [Restore Drive]
  , [fileinfo].[destination_phys_name]    AS [Restore Path]
FROM
  [msdb].[dbo].[restorehistory] AS [history]
  INNER JOIN
  [msdb].[dbo].[restorefile]    AS [fileinfo] ON [history].[restore_history_id] = [fileinfo].[restore_history_id]
ORDER BY [history].[restore_date] DESC

