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
  Que sejam do tipo:                "<Filtrar por: Nome do Tipo do Campo, VARCHAR, >"
  Contenham no seu nome de coluna:  "<Filtrar por: Nome de Coluna, VARCHAR, >"

  Mostrando apenas.. (1 = Sim / 2 = N�o)
  Procedures:                       "<Mostrar Apenas: Procedures, BIT, 0>"
  Extended Procedures:              "<Mostrar Apenas: Procedures Extendidas, BIT, 0>"
  Fun��es:                          "<Mostrar Apenas: Fun��es, BIT, 0>"
  Views:                            "<Mostrar Apenas: Views, BIT, 0>"
  Tabelas:                          "<Mostrar Apenas: Tabelas, BIT, 0>"
  Acentua��o Igual a Filtrada:      "<Mostrar Apenas: Com Acentua��o Igual, BIT, 0>"

**************************************************************************************/


BEGIN -- Filters
  DECLARE
      @SearchForObjectName AS VARCHAR(MAX) = '<Filtrar por: Nome do Objeto, VARCHAR, >'
    , @SearchForParameterName AS VARCHAR(MAX) = '<Filtrar por: Nome do Par�metro, VARCHAR, >'
    , @SearchForType AS VARCHAR(MAX) = '<Filtrar por: Nome do Tipo do Campo, VARCHAR, >'
    , @SearchForColumnName AS VARCHAR(MAX) = '<Filtrar por: Nome de Coluna, VARCHAR, >'
    
    , @ShowProcedures AS BIT = <Mostrar Apenas: Procedures, BIT, 0>
    , @ShowExtendedProcedures AS BIT = <Mostrar Apenas: Procedures Extendidas, BIT, 0>
    , @ShowFunctions AS BIT = <Mostrar Apenas: Fun��es, BIT, 0>
    , @ShowViews AS BIT = <Mostrar Apenas: Views, BIT, 0>
    , @ShowTables AS BIT = <Mostrar Apenas: Tabelas, BIT, 0>
    , @ShowOnlyWithSameAccent AS BIT = <Mostrar Apenas: Com Acentua��o Igual, BIT, 0>
END


BEGIN -- Validations
  -- Cria��o da tabela tempor�ria que conter� o conte�do dos filtros de switch que ser�o realizados
  IF EXISTS (SELECT * FROM TEMPDB.SYS.TABLES WHERE NAME LIKE ('#Temp_SelectedObjectTypes%'))
  BEGIN
    EXEC ('DROP TABLE #Temp_SelectedObjectTypes')
  END
  CREATE TABLE #Temp_SelectedObjectTypes(
    ObjectType
      NVARCHAR(2)
      COLLATE Latin1_General_CI_AS_KS_WS
  )

  -- Valida��o de filtros de switch
  IF (@ShowProcedures = 0
  AND @ShowExtendedProcedures  = 0
  AND @ShowFunctions  = 0
  AND @ShowViews = 0
  AND @ShowTables  = 0)
    INSERT #Temp_SelectedObjectTypes VALUES ('P'), ('X'), ('FN'), ('AF'), ('IF'), ('TF'), ('V'), ('U')
  IF @ShowProcedures = 1
    INSERT #Temp_SelectedObjectTypes VALUES ('P')
  IF @ShowExtendedProcedures = 1
    INSERT #Temp_SelectedObjectTypes VALUES ('X')
  IF @ShowFunctions = 1
    INSERT #Temp_SelectedObjectTypes VALUES ('FN'), ('AF'), ('IF'), ('TF')
  IF @ShowViews = 1
    INSERT #Temp_SelectedObjectTypes VALUES ('V')
  IF @ShowTables = 1
    INSERT #Temp_SelectedObjectTypes VALUES ('U')
END

BEGIN -- Result
    SELECT
        'ID do Objeto'                      = [object].[object_id]
      , 'Nome do Objeto'                    = [object].[name]
      , 'Par�metro do Objeto (Se Possui)'   = [parameter].[name]
      , 'Nome da Coluna (Se Objeto Possui)' = [column].[name]
      , 'Tipo do Objeto'                    = [object].[type]
      , 'Descri��o do Tipo do Objeto'       = [object].[type_desc]
      , 'Data de Cria��o'                   = [object].[create_date]
      , 'Data de Modifica��o'               = [object].[modify_date]
    FROM
      [sys].[all_objects] AS [object]
        FULL JOIN
      [sys].[parameters] AS [parameter]
          ON [object].[object_id] = [parameter].[object_id]
        FULL JOIN
      [sys].[systypes] AS [type]
          ON [parameter].[system_type_id] = [type].[xtype]
        FULL JOIN
      [sys].[all_columns] AS [column]
          ON [object].[object_id] = [column].[object_id]
    WHERE
      ((@ShowOnlyWithSameAccent = 0 AND
          @SearchForObjectName = '' OR [object].[name] COLLATE Latin1_general_CI_AI LIKE ('%' + @SearchForObjectName + '%') COLLATE Latin1_general_CI_AI)
        OR
        (@ShowOnlyWithSameAccent = 1 AND
          @SearchForObjectName = '' OR [object].[name] LIKE ('%' + @SearchForObjectName + '%')))
      AND ([object].TYPE IN (SELECT ObjectType FROM #Temp_SelectedObjectTypes))
      AND (@SearchForObjectName = '' OR [object].NAME LIKE ('%' + @SearchForObjectName + '%'))
      AND (@SearchForParameterName = '' OR [parameter].NAME LIKE ('%' + @SearchForParameterName + '%'))
      AND (@SearchForType = '' OR [type].NAME LIKE ('%' + @SearchForType + '%'))
      AND (@SearchForColumnName = '' OR [column].[name] LIKE ('%' + @SearchForColumnName + '%'))
END
