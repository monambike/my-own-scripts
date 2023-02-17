/**************************************************************************************

  Press "[CTRL] + [SHIFT] + [M]" to specify values for template parameters. Then press
  "[F5]" to use the Script below.

  ===================================================================================
   Script Short Description
  ===================================================================================

  Running this Script you will search for objects in SQL Server databases such as Views,
  Procedures, Functions, Parameters, Tables and Columns.
  You can filter by them selecting template parameters "[CTRL] + [SHIFT] + [M]".

  You can view a SQL Server object size using following command too:
  EXEC sp_spaceused '<Filter by: Object Name, SYSNAME, >'


  ===================================================================================
   Selected Filters
  ===================================================================================

  Showing objects that..
  Have as name:                     "<Filter by: Object Name, SYSNAME, >"
  That are from the type:           "<Filter by: Type Name  , SYSNAME, >"

  Showing only.. (0 = No / 1 = Yes)
  Procedures:                       "<Show only: Procedures                          , 0 - Not Show / 1 - Show, 0>"
  Views:                            "<Show only: Views                               , 0 - Not Show / 1 - Show, 0>"
  Functions:                        "<Show only: Functions                           , 0 - Not Show / 1 - Show, 0>"
  Tables:                           "<Show only: Tables                              , 0 - Not Show / 1 - Show, 0>"
  Objects with same accent on name: "<Show only: Objects with the same accent on name, 0 - Not Show / 1 - Show, 0>"

**************************************************************************************/

DECLARE
  @FilterByObjectName                  AS SYSNAME = '<Filter by: Object Name, SYSNAME, >'
, @FilterByType                        AS SYSNAME = '<Filter by: Type Name ,  SYSNAME, >'
    
, @OnlyShowProcedures                  AS BIT     = <Show only: Procedures                          , 0 - Not Show / 1 - Show, 0, 0>
, @OnlyShowViews                       AS BIT     = <Show only: Views                               , 0 - Not Show / 1 - Show, 0, 0>
, @OnlyShowFunctions                   AS BIT     = <Show only: Functions                           , 0 - Not Show / 1 - Show, 0, 0>
, @OnlyShowTables                      AS BIT     = <Show only: Tables                              , 0 - Not Show / 1 - Show, 0, 0>
, @OnlyShowObjectsWithSameAccentOnName AS BIT     = <Show only: Objects with the same accent on name, 0 - Not Show / 1 - Show, 0, 0>

-- VALIDATIONS
------------------------------------------------------------
BEGIN -- Validations
  -- Show Only..
  ------------------------------------------------------------
  -- If table not exists, create it
  IF OBJECT_ID('tempdb..#Temp_SelectedObjectTypes') IS NOT NULL
    DROP TABLE #Temp_SelectedObjectTypes
  CREATE TABLE #Temp_SelectedObjectTypes ( ObjectType NVARCHAR(2) COLLATE Latin1_General_CI_AS_KS_WS )

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
  [object].[object_id]                AS [ObjectID]
, [object].[name]                     AS [Name]
, [parameter].[name]                  AS [Parameter Name]
, [column].[name]                     AS [Column Name]
, [object].[type]                     AS [Type]
, [object].[type_desc]                AS [Type Description]
, [object].[create_date]              AS [Creation Date]
, [object].[modify_date]              AS [Modify Date]
FROM
  sys.all_objects AS [object]
  LEFT JOIN
  sys.parameters  AS [parameter] ON [parameter].[object_id] = [object].[object_id]
  LEFT JOIN
  sys.systypes    AS [type]      ON [type].[xtype]          = [parameter].[system_type_id]
  LEFT JOIN
  sys.all_columns AS [column]    ON [column].[object_id]    = [object].[object_id]
WHERE
  ((@OnlyShowObjectsWithSameAccentOnName = 0 AND
         @FilterByObjectName = '' OR [object].[name]    COLLATE Latin1_general_CI_AI LIKE ('%' + @FilterByObjectName + '%') COLLATE Latin1_general_CI_AI
      OR @FilterByObjectName = '' OR [parameter].[name] COLLATE Latin1_general_CI_AI LIKE ('%' + @FilterByObjectName + '%') COLLATE Latin1_general_CI_AI
      OR @FilterByObjectName = '' OR [column].[name]    COLLATE Latin1_general_CI_AI LIKE ('%' + @FilterByObjectName + '%') COLLATE Latin1_general_CI_AI)
    OR
   (@OnlyShowObjectsWithSameAccentOnName = 1 AND
         @FilterByObjectName = '' OR [object].[name]    COLLATE SQL_Latin1_General_CP1_CI_AS LIKE ('%' + @FilterByObjectName + '%')
      OR @FilterByObjectName = '' OR [parameter].[name] COLLATE SQL_Latin1_General_CP1_CI_AS LIKE ('%' + @FilterByObjectName + '%')
      OR @FilterByObjectName = '' OR [column].[name]    COLLATE SQL_Latin1_General_CP1_CI_AS LIKE ('%' + @FilterByObjectName + '%')))
  AND (NOT EXISTS (SELECT ObjectType FROM #Temp_SelectedObjectTypes) OR [object].TYPE IN (SELECT ObjectType FROM #Temp_SelectedObjectTypes))
  AND (@FilterByType          = '' OR [type].NAME LIKE ('%' + @FilterByType + '%'))
ORDER BY [Name]
