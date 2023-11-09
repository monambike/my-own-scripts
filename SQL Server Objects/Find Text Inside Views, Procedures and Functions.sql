/**************************************************************************************
Script created by @monambike. Please check https://github.com/monambike for more details,
including the latest licensing information.

Tip: Press "[CTRL] + [SHIFT] + [M]" to specify values for template parameters. Then press
"[F5]" to use the Script below.

===================================================================================
SCRIPT SHORT DESCRIPTION
===================================================================================
This Script has as objective make easier the search for content inside SQL Server
objects as view, stored procedures, functions.
You can filter by them selecting template parameters "[CTRL] + [SHIFT] + [M]".

**************************************************************************************/

/* Filters */
DECLARE
  @ObjectName    AS SYSNAME = '<Filter by: SQL Server Object Name, SYSNAME, >'
, @ObjectContent AS SYSNAME = '<Filter by: SQL Server Object Content, SYSNAME, >'
, @OnlyShowProcedures AS VARCHAR(MAX) = '<Show only: Procedures, BIT, 0>'
, @OnlyShowViews      AS VARCHAR(MAX) = '<Show only: Views, BIT, 0>'
, @OnlyShowFunctions  AS VARCHAR(MAX) = '<Show only: Functions , BIT, 0>'

/* If table not exists, drop and creates another one */
IF OBJECT_ID('tempdb..#Temp_SelectedObjectTypes') IS NOT NULL
  DROP TABLE #Temp_SelectedObjectTypes
CREATE TABLE #Temp_SelectedObjectTypes ( ObjectType NVARCHAR(2) )
/* Fills temporary table with selected filters for searching by object type */
IF @OnlyShowProcedures = '1'
  INSERT #Temp_SelectedObjectTypes VALUES ('P'), ('X')
IF @OnlyShowFunctions = '1'
  INSERT #Temp_SelectedObjectTypes VALUES ('FN'), ('AF'), ('IF'), ('TF')
IF @OnlyShowViews = '1'
  INSERT #Temp_SelectedObjectTypes VALUES ('V')

SELECT
  [object].[name]  AS [Name]
, [object].[type]  AS [Type]
, [comment].[text] AS [Content]
FROM
  [sysobjects]  AS [object]
  INNER JOIN
  [syscomments] AS [comment] ON [object].[id] = [comment].[id]
WHERE
  /* Filter by SQL Server object name (Views, Procedures, Functions) */
      (@ObjectName IN ('', CHAR(60) + 'Filter by: SQL Server Object Name, SYSNAME, ' + CHAR(62))
        AND [object].[name]  LIKE '%' + @ObjectName    + '%')
  /* Filter by SQL Server object content (Views, Procedures, Functions) */
  AND (@ObjectContent IN ('', CHAR(60) + 'Filter by: SQL Server Object Content, SYSNAME, ' + CHAR(62))
        AND [comment].[Text] LIKE '%' + @ObjectContent + '%')
  /* Filter by SQL Server object type (Views, Procedures, Functions) */
  AND NOT EXISTS (SELECT ObjectType FROM #Temp_SelectedObjectTypes) /* Se o usuário não informar nada mostra tudo*/
         OR [object].[type]    IN (SELECT ObjectType FROM #Temp_SelectedObjectTypes) /* Se o usuário selecionar mostra só os tipos que ele escolheu */
ORDER BY [object].[Name]
GO
