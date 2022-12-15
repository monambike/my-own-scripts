/**************************************************************************************

  DESCRI��O
  -------------------------------------------------------------------------------------
  Pressione "F5" para poder ver as �ltimas restaura��es de bases realizadas no
  servidor.

**************************************************************************************/

USE [master] GO

SELECT  
    [history].[destination_database_name] AS [Base de Destino da Restaura��o]
  , [history].[restore_date]              AS [Hor�rio de Restaura��o]
  , [history].[user_name]                 AS [Usu�rio que restaurou a base]
  , [history].[replace]                   AS [Substituir os Dados da Base Existente]
  , [fileinfo].destination_phys_drive     AS [Drive de Restaura��o]
  , [fileinfo].[destination_phys_name]    AS [Caminho de Restaura��o]
FROM
  [msdb].[dbo].[restorehistory] AS [history] WITH(NOLOCK)
  INNER JOIN
  [msdb].[dbo].[restorefile]    AS [fileinfo] WITH(NOLOCK)
    ON [history].[restore_history_id] = [fileinfo].[restore_history_id]
ORDER BY [history].[restore_date] DESC
