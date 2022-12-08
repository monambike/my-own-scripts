/*********************************************************************

  Pressione CTRL + SHIFT + M para definir os parâmetros e valores utilizado
  nesse template.
    
  LEGENDA
  Parameter: É a coluna que contém o nome do parâmetro ou o que ele faz;
  Type: É o valor que pode ser inserido no parâmetro;
  Value: É onde você deve inserir o valor desejado.

  
  ATENÇÃO
  Esse Script colocará a base em modo de usuário único (desconectando 
  todos os usuários e derrubando conexões) e alterará o seu nome.
  
  Ao rodar esse Script, você alterará o nome da base "<Nome da base antiga, VARCHAR, >" para "<Nome da base nova, VARCHAR, >".
  
*********************************************************************/

-- PRESSIONE [CTRL + SHIFT + M] PARA ESCOLHER OS FILTROS
-- PRESSIONE F5 APÓS ESCOLHER OS FILTROS PARA FILTRAR
BEGIN -- Filters
  DECLARE
    @MatchAccents AS BIT = <Considerar: Acentuação, BIT, 0>,

    @SearchForObjectName AS VARCHAR(MAX) = '<Filtrar por: Nome do Objeto, VARCHAR, >',
    @SearchForParameterName AS VARCHAR(MAX) = '<Filtrar por: Nome do Parâmetro, VARCHAR, >',
    @SearchForType AS VARCHAR(MAX) = '<Filtrar por: Nome do Tipo do Campo, VARCHAR, >',

    -- Filtros de Switch
    @ShowProcedures AS BIT = <Mostrar Apenas: Procedures, BIT, 0>,
    @ShowExtendedProcedures AS BIT = <Mostrar Apenas: Procedures Extendidas, BIT, 0>,
    @ShowFunctions AS BIT = <Mostrar Apenas: Funções, BIT, 0>,
    @ShowViews AS BIT = <Mostrar Apenas: Views, BIT, 0>,
    @ShowTables AS BIT = <Mostrar Apenas: Tabelas, BIT, 0>
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
        a.OBJECT_ID AS 'ID do Objeto',
        a.NAME 'Nome do Objeto',
        b.NAME AS 'Parâmetro do Objeto (Se Possui)',
        a.TYPE AS 'Tipo do Objeto',
        a.TYPE_DESC 'Descrição do Tipo do Objeto',
        a.CREATE_DATE AS 'Data de Criação',
        a.MODIFY_DATE AS 'Data de Modificação'
      FROM
        SYS.ALL_OBJECTS AS a
          FULL JOIN
        SYS.PARAMETERS AS b
            ON a.OBJECT_ID = b.OBJECT_ID
          FULL JOIN
        SYS.SYSTYPES AS c
            ON b.SYSTEM_TYPE_ID = c.XTYPE
      WHERE
        (
          (@MatchAccents = 0) AND
            (@SearchForObjectName = '' OR a.NAME COLLATE Latin1_general_CI_AI LIKE ('%' + @SearchForObjectName + '%') COLLATE Latin1_general_CI_AI)
          OR
          (@MatchAccents = 1) AND
            (@SearchForObjectName = '' OR a.NAME LIKE ('%' + @SearchForObjectName + '%'))
        )
        AND (a.TYPE IN (SELECT ObjectType FROM #Temp_SelectedObjectTypes))
        AND (@SearchForObjectName = '' OR a.NAME LIKE ('%' + @SearchForObjectName + '%'))
        AND (@SearchForParameterName = '' OR b.NAME LIKE ('%' + @SearchForParameterName + '%'))
        AND (@SearchForType = '' OR c.NAME LIKE ('%' + @SearchForType + '%'))
    END
END