/**************************************************************************************

  Pressione CTRL + SHIFT + M para definir os par�metros e valores utilizado
  nesse template.
  Parameter: � a coluna que cont�m o nome do par�metro ou o que ele faz;
  Type: � o valor que pode ser inserido no par�metro;
  Value: � onde voc� deve inserir o valor desejado.
  

  DESCRI��O
  -------------------------------------------------------------------------------------
  Esse Script tem como objetivo facilitar a procura por objetos em bancos de dados
  no SqlServer.
  Escolha os filtros e aperte "F5" para poder filtrar pelos objetos no banco.
  

  FILTROS SELECIONADOS
  -------------------------------------------------------------------------------------
  Mostrando objetos que apenas..
  Contenham no seu nome:            "<Filtrar por: Nome do Objeto, VARCHAR, >"
  Contenham par�metros com nome de: "<Filtrar por: Nome do Par�metro, VARCHAR, >"
  Que sejam do tipo:                "<Filtrar por: Nome do Tipo, VARCHAR, >"
  Contenham no seu nome de coluna:  "<Filtrar por: Nome de Coluna, VARCHAR, >"

  Mostrando apenas.. (1 = Sim / 2 = N�o)
  Procedures:                       "<Mostrar Apenas: Procedures, BIT, 0>"
  Fun��es:                          "<Mostrar Apenas: Fun��es, BIT, 0>"
  Views:                            "<Mostrar Apenas: Views, BIT, 0>"
  Tabelas:                          "<Mostrar Apenas: Tabelas, BIT, 0>"
  Acentua��o Igual a Filtrada:      "<Mostrar Apenas: Com Acentua��o Igual, BIT, 0>"

**************************************************************************************/


-- FILTROS
-- Filtros selecionados.
BEGIN -- Filters
  DECLARE
      @FilterByObjectName    AS VARCHAR(MAX) = '<Filtrar por: Nome do Objeto, VARCHAR, >'
    , @FilterByParameterName AS VARCHAR(MAX) = '<Filtrar por: Nome do Par�metro, VARCHAR, >'
    , @FilterByType          AS VARCHAR(MAX) = '<Filtrar por: Nome do Tipo, VARCHAR, >'
    , @FilterByColumnName    AS VARCHAR(MAX) = '<Filtrar por: Nome de Coluna, VARCHAR, >'
    -- Filtros selecionados de procura por tipo de objeto
    , @FilterByProcedures         AS BIT = <Filtrar por: Procedures, BIT, 0>
    , @FilterByFunctions          AS BIT = <Filtrar por: Fun��es, BIT, 0>
    , @FilterByViews              AS BIT = <Filtrar por: Views, BIT, 0>
    , @FilterByTables             AS BIT = <Filtrar por: Tabelas, BIT, 0>
    , @FilterByOnlyWithSameAccent AS BIT = <Filtrar por: Nomes Com Acentua��o Igual, BIT, 0>
END


BEGIN -- Validations
  -- Se a tabela n�o existe, cria ela
  IF OBJECT_ID('tempdb..#Temp_SelectedObjectTypes') IS NULL
    CREATE TABLE #Temp_SelectedObjectTypes ( ObjectType NVARCHAR(2) COLLATE Latin1_General_CI_AS_KS_WS )
  TRUNCATE TABLE #Temp_SelectedObjectTypes

  -- Preenche a tempor�ria com os filtros selecionados de procura por
  -- tipo de objeto
  IF @FilterByProcedures = 1
    INSERT #Temp_SelectedObjectTypes VALUES ('P'), ('X')
  IF @FilterByFunctions = 1
    INSERT #Temp_SelectedObjectTypes VALUES ('FN'), ('AF'), ('IF'), ('TF')
  IF @FilterByViews = 1
    INSERT #Temp_SelectedObjectTypes VALUES ('V')
  IF @FilterByTables = 1
    INSERT #Temp_SelectedObjectTypes VALUES ('U')
END

BEGIN
    SELECT
        [object].[object_id]                AS [ID do Objeto]
      , [object].[name]                     AS [Nome do Objeto]
      , [parameter].[name]                  AS [Par�metro do Objeto (Se Possui)]
      , [column].[name]                     AS [Nome da Coluna (Se Objeto Possui)]
      , [object].[type]                     AS [Tipo do Objeto]
      , [object].[type_desc]                AS [Descri��o do Tipo do Objeto]
      , [object].[create_date]              AS [Data de Cria��o]
      , [object].[modify_date]              AS [Data de Modifica��o]
    FROM
      [sys].[all_objects] AS [object]
      FULL JOIN
      [sys].[parameters] AS [parameter] ON [object].[object_id] = [parameter].[object_id]
      FULL JOIN
      [sys].[systypes] AS [type] ON [parameter].[system_type_id] = [type].[xtype]
      LEFT JOIN
      [sys].[all_columns] AS [column] ON [object].[object_id] = [column].[object_id]
    WHERE
      ((@FilterByOnlyWithSameAccent = 0 AND
          @FilterByObjectName = '' OR [object].[name] COLLATE Latin1_general_CI_AI LIKE ('%' + @FilterByObjectName + '%') COLLATE Latin1_general_CI_AI)
        OR
        (@FilterByOnlyWithSameAccent = 1 AND
          @FilterByObjectName = '' OR [object].[name] LIKE ('%' + @FilterByObjectName + '%')))
      AND (NOT EXISTS (SELECT ObjectType FROM #Temp_SelectedObjectTypes) OR [object].TYPE IN (SELECT ObjectType FROM #Temp_SelectedObjectTypes))
      AND (@FilterByObjectName = '' OR [object].NAME LIKE ('%' + @FilterByObjectName + '%'))
      AND (@FilterByParameterName = '' OR [parameter].NAME LIKE ('%' + @FilterByParameterName + '%'))
      AND (@FilterByType = '' OR [type].NAME LIKE ('%' + @FilterByType + '%'))
      AND (@FilterByColumnName = '' OR [column].[name] LIKE ('%' + @FilterByColumnName + '%'))
END
