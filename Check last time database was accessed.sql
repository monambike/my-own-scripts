/**************************************************************************************

  DESCRIPTION
  -------------------------------------------------------------------------------------
  This Script has as objective check last time database was accessed or used.

**************************************************************************************/

SELECT
    [database].[name]                     AS [Database Name]
  , MAX([usage_stats].[last_user_seek])   AS [Last User Seek]
  , MAX([usage_stats].[last_user_scan])   AS [Last User Scan]
  , MAX([usage_stats].[last_user_lookup]) AS [Last User Lookup]
  , MAX([usage_stats].[last_user_update]) AS [Last User Update]
FROM
  sys.dm_db_index_usage_stats AS [usage_stats]
  LEFT JOIN
  sys.databases               AS [database] ON [usage_stats].[database_id] = [database].[database_id]
GROUP BY [database].[name]
