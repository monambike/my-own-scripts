
SELECT
    deqp.query_plan AS [Plano de Execução]
  , *
FROM
  sys.dm_exec_requests AS der
  CROSS APPLY
  sys.dm_exec_sql_text(der.sql_handle) AS dest
  CROSS APPLY
  sys.dm_exec_query_plan(der.plan_handle) AS deqp

