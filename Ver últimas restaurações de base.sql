SELECT  
    'Base de Destino da Restaura��o' = [history].[destination_database_name]
  , 'Hor�rio de Restaura��o' = [history].[restore_date]
  , 'Usu�rio que restaurou a base' = [history].[user_name]
  , 'Substituir os Dados da Base Existente' = [history].[replace]
  , 'Drive de Restaura��o' = [fileinfo].destination_phys_drive
  , 'Caminho de Restaura��o' = [fileinfo].[destination_phys_name]
FROM
  [msdb].[dbo].[restorehistory] AS [history] WITH(NOLOCK)
    INNER JOIN
  [msdb].[dbo].[restorefile] AS [fileinfo] WITH(NOLOCK)
      ON [history].[restore_history_id] = [fileinfo].[restore_history_id]
ORDER BY
  [history].restore_date DESC
