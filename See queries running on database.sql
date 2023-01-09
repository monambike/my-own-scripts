/**************************************************************************************

  DESCRIPTION
  -------------------------------------------------------------------------------------
  This Script has as objective to make easier to see queries running on server.

  SP_WHO2 'active'
  KILL <Kill Process with SPID, INT, >

**************************************************************************************/

SELECT
  -- (Begin) Converting miliseconds to days, hours, minutes and seconds
            RIGHT('00' + CAST(FLOOR([request].[total_elapsed_time] / (1000 * 60 * 60 * 24)) AS VARCHAR), 2) -- Days    (dd)
  + ':' +   RIGHT('00' + CAST(FLOOR([request].[total_elapsed_time] / (1000 * 60 * 60)) % 24 AS VARCHAR), 2) -- Hours   (HH)
  + ':' +   RIGHT('00' + CAST(FLOOR([request].[total_elapsed_time] / (1000 * 60)) % 60      AS VARCHAR), 2) -- Minutes (mm)
  + ':' +   RIGHT('00' + CAST(FLOOR([request].[total_elapsed_time] / (1000) % 60)           AS VARCHAR), 2) -- Seconds (ss)
                                     AS [Time (dd:HH:mm:ss)]
  -- (End)   Converting miliseconds to days, hours, minutes and seconds
  , [request].[row_count]            AS [Row Count]
  , DB_NAME([request].[database_id]) AS [Database Name]
  , [query_plan].[query_plan]        AS [(Click on the link to see Execution Plan inside SQL Server Management Studio)]
  , [sql_text].[text]                AS [Query]
  , [request].[status]               AS [Status]
  , [request].[command]              AS [Command Type]
  , FORMAT([request].[start_time], 'yyyy/MM/dd HH:mm:ss') AS [Query Start Time]
FROM
  sys.dm_exec_requests                          AS [request]
  CROSS APPLY
  sys.dm_exec_sql_text([request].sql_handle)    AS [sql_text]
  CROSS APPLY
  sys.dm_exec_query_plan([request].plan_handle) AS [query_plan]
ORDER BY [Query Start Time] DESC
