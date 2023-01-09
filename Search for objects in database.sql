/**************************************************************************************

  Press [CTRL]+[SHIFT]+[M] to define parameters and values to be used on this current
  template.

  DESCRIPTION
  -------------------------------------------------------------------------------------
  This Script has as objective make easier the search for objects in SQL Server databases
  such as Views, Procedures, Functions, Parameters, Tables and Columns.
  After choosing all parameters, press [F5] to be able to filter by objects in current
  database.


  SELECTED FILTERS
  -------------------------------------------------------------------------------------
  Showing objects that..
  Have as name:                     "<Filter by: Object Name, , >"
  Has as parameter with the name:   "<Filter by: Parameter Name, , >"
  That are from the type:           "<Filter by: Type Name, , >"
  Contenham no seu column Name:     "<Filter by: Column Name, , >"

  Showing only.. (0 = No / 1 = Yes)
  Procedures:                       "<Show only: Procedures, 0 - Not Show / 1 - Show, 0>"
  Views:                            "<Show only: Views, 0 - Not Show / 1 - Show, 0>"
  Functions:                        "<Show only: Functions, 0 - Not Show / 1 - Show, 0>"
  Tables:                           "<Show only: Tables, 0 - Not Show / 1 - Show, 0>"
  Objects with same accent on name: "<Show only: Objects with the same accent on name, 0 - Not Show / 1 - Show, 0>"

**************************************************************************************/

DECLARE
    @FilterByObjectName                  AS VARCHAR(MAX) = '<Filter by: Object Name, VARCHAR, >'
  , @FilterByParameterName               AS VARCHAR(MAX) = '<Filter by: Parameter Name, VARCHAR, >'
  , @FilterByType                        AS VARCHAR(MAX) = '<Filter by: Type Name, VARCHAR, >'
  , @FilterByColumnName                  AS VARCHAR(MAX) = '<Filter by: Column Name, VARCHAR, >'
    
  , @OnlyShowProcedures                  AS BIT          = <Show only: Procedures, BIT, 0>
  , @OnlyShowViews                       AS BIT          = <Show only: Views, BIT, 0>
  , @OnlyShowFunctions                   AS BIT          = <Show only: Functions, BIT, 0>
  , @OnlyShowTables                      AS BIT          = <Show only: Tables, BIT, 0>
  , @OnlyShowObjectsWithSameAccentOnName AS BIT          = <Show only: Objects with the same accent on name, BIT, 0>

-- VALIDATIONS
------------------------------------------------------------
BEGIN -- Validations
  -- Show Only..
  ------------------------------------------------------------
  -- If table not exists, create it
  IF OBJECT_ID('tempdb..#Temp_SelectedObjectTypes') IS NULL
    CREATE TABLE #Temp_SelectedObjectTypes ( ObjectType NVARCHAR(2) COLLATE Latin1_General_CI_AS_KS_WS )
  TRUNCATE TABLE #Temp_SelectedObjectTypes

  -- Fills temporary table with selected filters for searching by
  -- object type
  IF @OnlyShowProcedures = 1
    INSERT #Temp_SelectedObjectTypes VALUES ('P'), ('X')
  IF @OnlyShowFunctions = 1
    INSERT #Temp_SelectedObjectTypes VALUES ('FN'), ('AF'), ('IF'), ('TF')
  IF @OnlyShowViews = 1
    INSERT #Temp_SelectedObjectTypes VALUES ('V')
  IF @OnlyShowTables = 1
    INSERT #Temp_SelectedObjectTypes VALUES ('U')
END


SELECT
    [object].[object_id]                AS [ID do Objeto]
  , [object].[name]                     AS [Object Name]
  , [parameter].[name]                  AS [Parâmetro do Objeto (Se Possui)]
  , [column].[name]                     AS [Nome da Coluna (Se Objeto Possui)]
  , [object].[type]                     AS [Tipo do Objeto]
  , [object].[type_desc]                AS [Descrição do Tipo do Objeto]
  , [object].[create_date]              AS [Data de Criação]
  , [object].[modify_date]              AS [Data de Modificação]
FROM
  [sys].[all_objects] AS [object]
  LEFT JOIN
  [sys].[parameters]  AS [parameter] ON [parameter].[object_id] = [object].[object_id]
  FULL JOIN
  [sys].[systypes]    AS [type]      ON [type].[xtype] = [parameter].[system_type_id]
  LEFT JOIN
  [sys].[all_columns] AS [column]    ON [column].[object_id] = [object].[object_id]
WHERE
  ((@OnlyShowObjectsWithSameAccentOnName = 0 AND
      @FilterByObjectName = '' OR [object].[name] COLLATE Latin1_general_CI_AI LIKE ('%' + @FilterByObjectName + '%') COLLATE Latin1_general_CI_AI)
    OR
   (@OnlyShowObjectsWithSameAccentOnName = 1 AND
      @FilterByObjectName = '' OR [object].[name] LIKE ('%' + @FilterByObjectName + '%')))
  AND (NOT EXISTS (SELECT ObjectType FROM #Temp_SelectedObjectTypes) OR [object].TYPE IN (SELECT ObjectType FROM #Temp_SelectedObjectTypes))
  AND (@FilterByObjectName    = '' OR [object].NAME LIKE ('%' + @FilterByObjectName + '%'))
  AND (@FilterByParameterName = '' OR [parameter].NAME LIKE ('%' + @FilterByParameterName + '%'))
  AND (@FilterByType          = '' OR [type].NAME LIKE ('%' + @FilterByType + '%'))
  AND (@FilterByColumnName    = '' OR [column].[name] LIKE ('%' + @FilterByColumnName + '%'))
