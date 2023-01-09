SELECT
    [database_id]
  , [name]
  , [collation_name]
  , [compatibility_level]
  , [state_desc]
  , [create_date]
FROM
  sys.databases
ORDER BY
    CASE WHEN [name] IN ('master', 'tempdb', 'model', 'msdb') THEN 0 ELSE 1 END
  , [name]