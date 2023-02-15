/**************************************************************************************

  Press "[CTRL] + [SHIFT] + [M]" to specify values for template parameters. Then press
  "[F5]" to use the Script below.

  ===================================================================================
   Script Short Description
  ===================================================================================

  This Script has as objective make easier the search for content inside SQL Server
  objects as view, stored procedures, functions.
  You can filter by them selecting template parameters "[CTRL] + [SHIFT] + [M]".

  ===================================================================================
   Selected Filters
  ===================================================================================
  
  Showing objects that..
  Have as name:         "<Filter by: Object Name   , SYSNAME, >"
  Has in their content: "<Filter by: Object Content, SYSNAME, >"

  Showing only.. (0 = No / 1 = Yes)
  Procedures:                       "<Show only: Procedures, 0 - Not Show / 1 - Show, 0>"
  Views:                            "<Show only: Views, 0 - Not Show / 1 - Show, 0>"
  Functions:                        "<Show only: Functions, 0 - Not Show / 1 - Show, 0>"

**************************************************************************************/

DECLARE
  @ObjectContent      AS SYSNAME = '<Filter by: Object Content, SYSNAME, >'
, @ObjectName         AS SYSNAME = '<Filter by: Object Name   , SYSNAME, >'

, @OnlyShowProcedures AS BIT     = <Show only: Procedures, BIT, 0>
, @OnlyShowViews      AS BIT     = <Show only: Views     , BIT, 0>
, @OnlyShowFunctions  AS BIT     = <Show only: Functions , BIT, 0>

-- VALIDATIONS
------------------------------------------------------------
BEGIN -- Validations
  -- Show Only..
  ------------------------------------------------------------
  -- If table not exists, create it
  IF OBJECT_ID('tempdb..#Temp_SelectedObjectTypes') IS NOT NULL
    DROP TABLE #Temp_SelectedObjectTypes
  CREATE TABLE #Temp_SelectedObjectTypes ( ObjectType NVARCHAR(2) )

  -- Fills temporary table with selected filters for searching by
  -- object type
  IF @OnlyShowProcedures = 1
    INSERT #Temp_SelectedObjectTypes VALUES ('P'), ('X')
  IF @OnlyShowFunctions = 1
    INSERT #Temp_SelectedObjectTypes VALUES ('FN'), ('AF'), ('IF'), ('TF')
  IF @OnlyShowViews = 1
    INSERT #Temp_SelectedObjectTypes VALUES ('V')
END

SELECT
  [object].[name]  AS [Object Name]
, [object].[type]  AS [Object Type]
, [comment].[text] AS [Object Content]
FROM
  [sysobjects] [object]
  INNER JOIN
  [syscomments] [comment] ON [object].[id] = [comment].[id]
WHERE
  [object].[name]      LIKE  '%' + @ObjectName    + '%'
  AND [comment].[Text] LIKE  '%' + @ObjectContent + '%'
  AND (NOT EXISTS (SELECT ObjectType FROM #Temp_SelectedObjectTypes) OR [object].TYPE IN (SELECT ObjectType FROM #Temp_SelectedObjectTypes))
ORDER BY [object].[Name]
GO