/*********************************************************************

  Pressione CTRL + SHIFT + M para definir os par�metros e valores utilizado
  nesse template.
    
  LEGENDA
  Parameter: � a coluna que cont�m o nome do par�metro ou o que ele faz;
  Type: � o valor que pode ser inserido no par�metro;
  Value: � onde voc� deve inserir o valor desejado.

  
  ATEN��O
  Esse Script colocar� a base em modo de usu�rio �nico (desconectando 
  todos os usu�rios e derrubando conex�es) e alterar� o seu nome.
  
  Ao rodar esse Script, voc� alterar� o nome da base "<Nome da base antiga, VARCHAR, >" para "<Nome da base nova, VARCHAR, >".
  
*********************************************************************/

-- PRESSIONE [CTRL + SHIFT + M] PARA ESCOLHER OS FILTROS
-- PRESSIONE F5 AP�S ESCOLHER OS FILTROS PARA FILTRAR
BEGIN -- Filters
  DECLARE
    @MatchAccents AS BIT = <Considerar: Acentua��o, BIT, 0>,

    @SearchForObjectName AS VARCHAR(MAX) = '<Filtrar por: Nome do Objeto, VARCHAR, >',
    @SearchForParameterName AS VARCHAR(MAX) = '<Filtrar por: Nome do Par�metro, VARCHAR, >',
    @SearchForType AS VARCHAR(MAX) = '<Filtrar por: Nome do Tipo do Campo, VARCHAR, >',

    -- Filtros de Switch
    @ShowProcedures AS BIT = <Mostrar Apenas: Procedures, BIT, 0>,
    @ShowExtendedProcedures AS BIT = <Mostrar Apenas: Procedures Extendidas, BIT, 0>,
    @ShowFunctions AS BIT = <Mostrar Apenas: Fun��es, BIT, 0>,
    @ShowViews AS BIT = <Mostrar Apenas: Views, BIT, 0>,
    @ShowTables AS BIT = <Mostrar Apenas: Tabelas, BIT, 0>
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
        b.NAME AS 'Par�metro do Objeto (Se Possui)',
        a.TYPE AS 'Tipo do Objeto',
        a.TYPE_DESC 'Descri��o do Tipo do Objeto',
        a.CREATE_DATE AS 'Data de Cria��o',
        a.MODIFY_DATE AS 'Data de Modifica��o'
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