/**************************************************************************************

  Press [CTRL]+[SHIFT]+[M] to define parameters and values to be used on this current
  template.

  DESCRIPTION
  -------------------------------------------------------------------------------------
  This Script has as objective to make easier search for table and columns.

**************************************************************************************/

DECLARE
    @TableName  AS VARCHAR(MAX) = '<Table Name, VARCHAR(MAX), >'
  , @ColumnName AS VARCHAR(MAX) = '<Column Name, VARCHAR(MAX), >'
  , @TypeName   AS VARCHAR(MAX) = '<Type Name, VARCHAR(MAX), >'

SELECT
    [table].[name]         AS [TableName]
  , [column].[name]        AS [Field]
  , [type].[name] 
    + (CASE
         WHEN [type].[name] IN ('CHAR', 'NTEXT', 'TEXT', 'VARCHAR') THEN '(' + CONVERT(VARCHAR, [column].[max_length])     + ')'
         WHEN [type].[name] IN ('NCHAR', 'NVARCHAR')                THEN '(' + CONVERT(VARCHAR, [column].[max_length] / 2) + ')'
         ELSE ''
       END) AS [Type Name]
  , CAST([column].[max_length]     AS VARCHAR) + 'bytes' AS [Size (Bytes)]
  , CAST([column].[max_length] * 8 AS VARCHAR) + 'bits'  AS [Size (Bits)]
  , [column].[is_nullable] AS [Nullable]
FROM
  sys.columns AS [column]
  INNER JOIN
  sys.tables  AS [table] ON [column].[object_id]    = [table].[object_id]
  INNER JOIN
  sys.types   AS [type]  ON [column].[user_type_id] = [type].[user_type_id]
WHERE
      (@TableName  = '' OR [table].[name]  LIKE '%' + @TableName  + '%')
  AND (@ColumnName = '' OR [column].[name] LIKE '%' + @ColumnName + '%')
  AND (@TypeName   = '' OR [type].[name]   LIKE '%' + @TypeName   + '%')
