/**************************************************************************************

  Press [CTRL]+[SHIFT]+[M] to define parameters and values to be used on this current
  template.

  DESCRIPTION
  -------------------------------------------------------------------------------------
  This Script has as objective to make easier search for table and columns.

**************************************************************************************/

SELECT
  [column].[name]        AS [Field],
  [type].[name]          AS [Type],
  (CASE
    WHEN [type].[name] IN ('CHAR', 'NTEXT', 'TEXT', 'VARCHAR') THEN CONVERT(VARCHAR, [column].MAX_LENGTH)
    WHEN [type].[name] IN ('NCHAR', 'NVARCHAR') THEN CONVERT(VARCHAR, [column].MAX_LENGTH / 2)
    ELSE ''
  END)                   AS [Size],
  [column].[is_nullable] AS [Nullable],
  [table].[name]         AS [TableName]
FROM
  sys.columns AS [column]
  INNER JOIN
  sys.tables  AS [table] ON [column].[object_id]    = [table].[object_id]
  INNER JOIN
  sys.types   AS [type]  ON [column].[user_type_id] = [type].[user_type_id]
WHERE
  [table].[name] = '<Table Name, , >'
  AND [column].[name] LIKE '<Column Name, , >'