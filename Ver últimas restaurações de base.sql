/**************************************************************************************

  DESCRIÇÃO
  -------------------------------------------------------------------------------------
  Pressione "F5" para poder ver as últimas restaurações de bases realizadas no
  servidor.

**************************************************************************************/

USE [master] GO

SELECT  
    [history].[destination_database_name] AS [Base de Destino da Restauração]
  , [history].[restore_date]              AS [Horário de Restauração]
  , [history].[user_name]                 AS [Usuário que restaurou a base]
  , [history].[replace]                   AS [Substituir os Dados da Base Existente]
  , [fileinfo].destination_phys_drive     AS [Drive de Restauração]
  , [fileinfo].[destination_phys_name]    AS [Caminho de Restauração]
FROM
  [msdb].[dbo].[restorehistory] AS [history] WITH(NOLOCK)
  INNER JOIN
  [msdb].[dbo].[restorefile]    AS [fileinfo] WITH(NOLOCK)
    ON [history].[restore_history_id] = [fileinfo].[restore_history_id]
ORDER BY [history].[restore_date] DESC
