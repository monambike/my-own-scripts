SELECT  
    'Base de Destino da Restauração' = [history].[destination_database_name]
  , 'Horário de Restauração' = [history].[restore_date]
  , 'Usuário que restaurou a base' = [history].[user_name]
  , 'Substituir os Dados da Base Existente' = [history].[replace]
  , 'Drive de Restauração' = [fileinfo].destination_phys_drive
  , 'Caminho de Restauração' = [fileinfo].[destination_phys_name]
FROM
  [msdb].[dbo].[restorehistory] AS [history] WITH(NOLOCK)
    INNER JOIN
  [msdb].[dbo].[restorefile] AS [fileinfo] WITH(NOLOCK)
      ON [history].[restore_history_id] = [fileinfo].[restore_history_id]
ORDER BY
  [history].restore_date DESC
