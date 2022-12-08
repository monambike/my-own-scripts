/**************************************************************************************

  Pressione CTRL + SHIFT + M para definir os parâmetros e valores utilizado
  nesse template.
  Parameter: É a coluna que contém o nome do parâmetro ou o que ele faz;
  Type: É o valor que pode ser inserido no parâmetro;
  Value: É onde você deve inserir o valor desejado.
  

  DESCRIÇÃO
  -------------------------------------------------------------------------------------
  Esse Script tem como objetivo facilitar a procura por objetos em bancos de dados
  no SqlServer.
  Escolha os filtros e aperte "F5" para poder filtrar pelos objetos no banco.
  

  FILTROS SELECIONADOS
  -------------------------------------------------------------------------------------
  Mostrando objetos que apenas..
  Contenham no seu nome:            "<Filtrar por: Nome do Objeto, VARCHAR, >"
  Contenham parâmetros com nome de: "<Filtrar por: Nome do Parâmetro, VARCHAR, >"
  Que sejam do tipo:                "<Filtrar por: Nome do Tipo do Campo, VARCHAR, >"

  Mostrando apenas.. (1 = Sim / 2 = Não)
  Procedures:                  "<Mostrar Apenas: Procedures, BIT, 0>"
  Extended Procedures:         "<Mostrar Apenas: Procedures Extendidas, BIT, 0>"
  Funções:                     "<Mostrar Apenas: Funções, BIT, 0>"
  Views:                       "<Mostrar Apenas: Views, BIT, 0>"
  Tabelas:                     "<Mostrar Apenas: Tabelas, BIT, 0>"
  Acentuação Igual a Filtrada: "<Mostrar Apenas: Com Acentuação Igual, BIT, 0>"

**************************************************************************************/


BEGIN -- Filters
  DECLARE
      @SearchForObjectName AS VARCHAR(MAX) = '<Filtrar por: Nome do Objeto, VARCHAR, >'
    , @SearchForParameterName AS VARCHAR(MAX) = '<Filtrar por: Nome do Parâmetro, VARCHAR, >'
    , @SearchForType AS VARCHAR(MAX) = '<Filtrar por: Nome do Tipo do Campo, VARCHAR, >'
    
    , @ShowProcedures AS BIT = <Mostrar Apenas: Procedures, BIT, 0>
    , @ShowExtendedProcedures AS BIT = <Mostrar Apenas: Procedures Extendidas, BIT, 0>
    , @ShowFunctions AS BIT = <Mostrar Apenas: Funções, BIT, 0>
    , @ShowViews AS BIT = <Mostrar Apenas: Views, BIT, 0>
    , @ShowTables AS BIT = <Mostrar Apenas: Tabelas, BIT, 0>
    , @ShowOnlyWithSameAccent AS BIT = <Mostrar Apenas: Com Acentuação Igual, BIT, 0>
END


BEGIN -- Validations
  -- Criação da tabela temporária que conterá o conteúdo dos filtros de switch que serão realizados
  IF EXISTS (SELECT * FROM TEMPDB.SYS.TABLES WHERE NAME LIKE ('#Temp_SelectedObjectTypes%'))
  BEGIN
    EXEC ('DROP TABLE #Temp_SelectedObjectTypes')
  END
  CREATE TABLE #Temp_SelectedObjectTypes(
    ObjectType
      NVARCHAR(2)
      COLLATE Latin1_General_CI_AS_KS_WS
  )

  -- Validação de filtros de switch
  IF (@ShowProcedures = 0 AND
      @ShowExtendedProcedures  = 0 AND
      @ShowFunctions  = 0 AND
      @ShowViews = 0 AND
      @ShowTables  = 0)
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
    BEGIN
      SELECT
          'ID do Objeto' = [object].[OBJECT_ID]
        , 'Nome do Objeto' = [object].[NAME]
        , 'Parâmetro do Objeto (Se Possui)' = [parameter].[NAME]
        , 'Tipo do Objeto' = [object].[TYPE]
        , 'Descrição do Tipo do Objeto' = [object].[TYPE_DESC]
        , 'Data de Criação' = [object].[CREATE_DATE]
        , 'Data de Modificação' = [object].[MODIFY_DATE]
      FROM
        SYS.ALL_OBJECTS AS [object]
          FULL JOIN
        SYS.PARAMETERS AS [parameter]
            ON [object].OBJECT_ID = [parameter].OBJECT_ID
          FULL JOIN
        SYS.SYSTYPES AS [type]
            ON [parameter].SYSTEM_TYPE_ID = [type].XTYPE
      WHERE
        (
          (@ShowOnlyWithSameAccent = 0) AND
            (@SearchForObjectName = '' OR [object].[NAME] COLLATE Latin1_general_CI_AI LIKE ('%' + @SearchForObjectName + '%') COLLATE Latin1_general_CI_AI)
          OR
          (@ShowOnlyWithSameAccent = 1) AND
            (@SearchForObjectName = '' OR [object].[NAME] LIKE ('%' + @SearchForObjectName + '%'))
        )
        AND ([object].TYPE IN (SELECT ObjectType FROM #Temp_SelectedObjectTypes))
        AND (@SearchForObjectName = '' OR [object].NAME LIKE ('%' + @SearchForObjectName + '%'))
        AND (@SearchForParameterName = '' OR [parameter].NAME LIKE ('%' + @SearchForParameterName + '%'))
        AND (@SearchForType = '' OR [type].NAME LIKE ('%' + @SearchForType + '%'))
    END
END
