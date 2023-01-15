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
  sys.tables  AS [table] ON [table].[object_id]     = [column].[object_id]
  INNER JOIN
  sys.types   AS [type]  ON [type].[user_type_id]   = [column].[user_type_id]
WHERE
      (@TableName  = '' OR [table].[name]  LIKE '%' + @TableName  + '%')
  AND (@ColumnName = '' OR [column].[name] LIKE '%' + @ColumnName + '%')
  AND (@TypeName   = '' OR [type].[name]   LIKE '%' + @TypeName   + '%')


SELECT * FROM
(
  SELECT
      [table].[name]                   AS [Table Name]
    , [pk_ak_constraint].[name]        AS [Constraint Name]
    , [pk_ak_constraint].[create_date] AS [Constraint Create Date]
    , [pk_ak_constraint].[modify_date] AS [Constraint Modify Date]
  FROM
    sys.tables              AS [table]
    INNER JOIN
    sys.key_constraints     AS [pk_ak_constraint] ON [pk_ak_constraint].[parent_object_id] = [table].[object_id]
  UNION ALL
  SELECT
      [table].[name]                   AS [Table Name]
    , [fk_constraint].[name]           AS [Foreign Key Constraint]
    , [fk_constraint].[create_date]    AS [Constraint Create Date]
    , [fk_constraint].[modify_date]    AS [Constraint Modify Date]
  FROM
    sys.tables              AS [table]
    INNER JOIN
    sys.foreign_keys        AS [fk_constraint]    ON [fk_constraint].[parent_object_id]    = [table].[object_id]
  UNION ALL
  SELECT
      [table].[name]                   AS [Table Name]
    , [ck_constraint].[name]           AS [Foreign Key Constraint]
    , [ck_constraint].[create_date]    AS [Constraint Create Date]
    , [ck_constraint].[modify_date]    AS [Constraint Modify Date]
  FROM
    sys.tables              AS [table]
    INNER JOIN
    sys.check_constraints   AS [ck_constraint]    ON [ck_constraint].[parent_object_id]    = [table].[object_id]
  UNION ALL
  SELECT
      [table].[name]                   AS [Table Name]
    , [df_constraint].[name]           AS [Default Value Key Constraint]
    , [df_constraint].[create_date]    AS [Constraint Create Date]
    , [df_constraint].[modify_date]    AS [Constraint Modify Date]
  FROM
    sys.tables              AS [table]
    INNER JOIN
    sys.default_constraints AS [df_constraint]    ON [df_constraint].[parent_object_id]    = [table].[object_id]
) AS [table_constraint]
WHERE
  [table_constraint].[Table Name] NOT IN ('sysdiagrams')
ORDER BY
    [table_constraint].[Table Name]
  , CASE
      WHEN [table_constraint].[Constraint Name] LIKE 'PK_%' THEN 0
      WHEN [table_constraint].[Constraint Name] LIKE 'FK_%' THEN 1
      WHEN [table_constraint].[Constraint Name] LIKE 'AK_%' THEN 2
    END
