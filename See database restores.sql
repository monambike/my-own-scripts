/**************************************************************************************

  Press [CTRL]+[SHIFT]+[M] to define parameters and values to be used on this current
  template.

  DESCRIPTION
  -------------------------------------------------------------------------------------
  Press [F5] to see databases restores made in current server.

**************************************************************************************/

USE [master]

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
