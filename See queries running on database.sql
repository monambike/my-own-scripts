/**************************************************************************************

  DESCRIPTION
  -------------------------------------------------------------------------------------
  This Script has as objective to make easier to see queries running on server.

  SP_WHO2 'active'
  KILL <Kill Process with SPID, INT, >

**************************************************************************************/

SELECT
  -- (Begin) Converting miliseconds to days, hours, minutes and seconds dd:HH:mm:ss
          RIGHT('00' + CAST(FLOOR([request].[total_elapsed_time] / (1000 * 60 * 60 * 24)) AS VARCHAR), 2) -- Days    (dd)
  + ':' + RIGHT('00' + CAST(FLOOR([request].[total_elapsed_time] / (1000 * 60 * 60)) % 24 AS VARCHAR), 2) -- Hours   (HH)
  + ':' + RIGHT('00' + CAST(FLOOR([request].[total_elapsed_time] / (1000 * 60)) % 60      AS VARCHAR), 2) -- Minutes (mm)
  + ':' + RIGHT('00' + CAST(FLOOR([request].[total_elapsed_time] / (1000) % 60)           AS VARCHAR), 2) -- Seconds (ss)
                                     AS [Time (dd:HH:mm:ss)]
  -- (End)   Converting miliseconds to days, hours, minutes and seconds dd:HH:mm:ss
  , [request].[row_count]            AS [Row Count]
  , DB_NAME([request].[database_id]) AS [Database Name]
  , [query_plan].[query_plan]        AS [(Click on the link to see Execution Plan inside SQL Server Management Studio)]
  , [sql_text].[text]                AS [Query]
  , [request].[status]               AS [Status]
  , [request].[command]              AS [Command Type]
  , FORMAT([request].[start_time], 'yyyy/MM/dd HH:mm:ss') AS [Query Start Time]
  , [request].[request_id]
  , [request].transaction_id
FROM
  sys.dm_exec_requests                          AS [request]
  CROSS APPLY
  sys.dm_exec_sql_text([request].[sql_handle])  AS [sql_text]
  CROSS APPLY
  sys.dm_exec_query_plan([request].plan_handle) AS [query_plan]
ORDER BY [Query Start Time] DESC

SELECT
  -- (Begin) Converting miliseconds to days, hours, minutes and seconds
          RIGHT('00' + CAST(FLOOR([process].[waittime] / (1000 * 60 * 60 * 24)) AS VARCHAR), 2) -- Days    (dd)
  + ':' + RIGHT('00' + CAST(FLOOR([process].[waittime] / (1000 * 60 * 60)) % 24 AS VARCHAR), 2) -- Hours   (HH)
  + ':' + RIGHT('00' + CAST(FLOOR([process].[waittime] / (1000 * 60)) % 60      AS VARCHAR), 2) -- Minutes (mm)
  + ':' + RIGHT('00' + CAST(FLOOR([process].[waittime] / (1000) % 60)           AS VARCHAR), 2) -- Seconds (ss)
                                      AS [Wait Time (dd:HH:mm:ss)]
  -- (End)   Converting miliseconds to days, hours, minutes and seconds
  -- (Begin) Process Status
  , RTRIM(LTRIM(
      UPPER(LEFT([process].[status],1)) -- Making first letter uppercase
      +
      LOWER(SUBSTRING([process].[status], 2, LEN([process].[status]))) -- Making remaining letters lowercase
    ))
    + ' - '
    -- Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-compatibility-views/sys-sysprocesses-transact-sql?view=sql-server-ver16
    +  (CASE
          WHEN [process].[status] IN('dormant', 'sleeping') THEN 'SQL Server is resetting the session.'
          WHEN [process].[status] = 'running'               THEN 'The session is running one or more batches. When Multiple Active Result Sets (MARS) is enabled, a session can run multiple batches. For more information, see Using Multiple Active Result Sets (MARS).'
          WHEN [process].[status] = 'background'            THEN 'The session is running a background task, such as deadlock detection.'
          WHEN [process].[status] = 'rollback'              THEN 'The session has a transaction rollback in process.'
          WHEN [process].[status] = 'pending'               THEN 'The session is waiting for a worker thread to become available.'
          WHEN [process].[status] = 'runnable'              THEN 'The task in the session is in the runnable queue of a scheduler while waiting to get a time quantum.'
          WHEN [process].[status] = 'spinloop'              THEN 'The task in the session is waiting for a spinlock to become free.'
          WHEN [process].[status] = 'suspended'             THEN 'The session is waiting for an event, such as I/O, to complete.'
        END)
    AS [Process Status]
  -- (End)   Process Status
  , [process].[spid]          AS [SPID (Session Process ID)]
  , [process].[kpid]          AS [KPID (Kernel Process ID)]
  , [process].[program_name]  AS [Program Name]
  , [process].[cmd]           AS [CMD (Command currently being executed)]
  , DB_NAME([dbid])           AS [Database Name]
  , [process].[lastwaittype]  AS [Wait Type]             -- To see the description about your "Wait Type" see: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-os-wait-stats-transact-sql?view=sql-server-2016
  , CAST([process].[blocked] AS VARCHAR)
    +  (CASE
          WHEN [process].[blocked] =  0 THEN ' - The request is not blocked, or the session information of the blocking session is not available (or cannot be identified).'
          WHEN [process].[blocked] = -2 THEN ' - The blocking resource is owned by an orphaned distributed transaction.'
          WHEN [process].[blocked] = -3 THEN ' - The blocking resource is owned by a deferred recovery transaction.'
          WHEN [process].[blocked] = -4 THEN ' - Session ID of the blocking latch owner could not be determined due to internal latch state transitions.'
        END)
    AS [Session Blocking Request]
  , [process].[memusage]      AS [Memory Usage]          -- Number of pages in the procedure cache that are currently allocated to this process. A negative number indicates that the process is freeing memory allocated by another process.
  , [process].[physical_io]   AS [Disk Reads and Writes] -- Cumulative disk reads and writes for the process.
  , [process].[cpu]           AS [CPU Usage]             -- Cumulative CPU time for the process. The entry is updated for all processes, regardless of whether the SET STATISTICS TIME option is ON or OFF.
  , [user].[name]             AS [User Name]
FROM
  sys.sysprocesses AS [process]
  LEFT JOIN
  sys.sysusers     AS [user]    ON [process].[uid] = [user].[uid]
ORDER BY [process].[waittime] DESC
