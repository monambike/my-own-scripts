/**************************************************************************************

  Pressione [CTRL]+[SHIFT]+[M] para definir os valores e parâmetros a serem utilizados
  nesse template.

  DESCRIPTION
  -------------------------------------------------------------------------------------
  Esse Script tem como objetivo facilitar a procura por relatórios pelo seu nomes,
  descrições e estado ativo ou inativo, bem como o grupo em que está.


  SELECTED FILTERS
  -------------------------------------------------------------------------------------
  Showing objects that..
  Have as name:         "<Filter by: Object Name, , >"
  Has in their content: "<Filter by: Object Content, , >"

  Showing only.. (0 = No / 1 = Yes)
  Procedures:                       "<Show only: Procedures, 0 - Not Show / 1 - Show, 0>"
  Views:                            "<Show only: Views, 0 - Not Show / 1 - Show, 0>"
  Functions:                        "<Show only: Functions, 0 - Not Show / 1 - Show, 0>"

**************************************************************************************/

DECLARE
    @ObjectContent      AS VARCHAR(MAX) = '<Filter by: Object Content, , >'
  , @ObjectName         AS VARCHAR(MAX) = '<Filter by: Object Name, , >'

  , @OnlyShowProcedures AS BIT          = <Show only: Procedures, BIT, 0>
  , @OnlyShowViews      AS BIT          = <Show only: Views, BIT, 0>
  , @OnlyShowFunctions  AS BIT          = <Show only: Functions, BIT, 0>

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
END

SELECT
    [object].[Name]  AS [Object Name]
  , [object].[Type]  AS [Object Type]
  , [comment].[Text] AS [Object Content]
FROM
  [sysobjects] [object]
  INNER JOIN
  [syscomments] [comment] ON [object].[id] = [comment].[id]
WHERE
  [object].[name]      LIKE  '%' + @ObjectName + '%'
  AND [comment].[Text] LIKE  '%' + @ObjectContent + '%'
  AND (NOT EXISTS (SELECT ObjectType FROM #Temp_SelectedObjectTypes) OR [object].TYPE IN (SELECT ObjectType FROM #Temp_SelectedObjectTypes))
ORDER BY [object].[Name]