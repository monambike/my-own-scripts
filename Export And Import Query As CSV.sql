/**************************************************************************************

  Press "[CTRL] + [SHIFT] + [M]" to specify values for template parameters. Then press
  "[F5]" to use the Script below.

  ===================================================================================
   Script Short Description
  ===================================================================================

  This Script has as objective to help you to make a query output as a file.

**************************************************************************************/

DECLARE
  @SQLQuery       AS VARCHAR(MAX) = '<SQL Query       , VARCHAR(MAX), >'
, @OutputFilePath AS VARCHAR(MAX) = '<Output File Path, VARCHAR(MAX), >'
, @ServerName     AS SYSNAME      = '<Server Name     , SYSNAME     , >'

DECLARE @bcp AS VARCHAR(MAX) = 'bcp "' + @SQLQuery + ' " QUERYOUT "' + @OutputFilePath + '" -c -t ";" -r \n -S' + @ServerName + ''
EXEC xp_cmdshell @bcp


IF NOT EXISTS(SELECT * FROM sys.tables a where a.name = 'tmp_testenfeRejeicao')
	create table tmp_testenfeRejeicao(int_codstatus int, str_Rejeicao Varchar(MAX))
	/*DROP TABLE tmp_testenfeRejeicao*/

/* DECLARAÇÃO DAS VARIÁVEIS, TABELAS TEMPORÁRIAS ABAIXO DAS VARIÁVEIS NATURAIS */
DECLARE	
	@str_Estado VARCHAR(2) = 'RS' -- DECLARE AQUI QUAL ESTADO ESTÁ SENDO LIDO; O CAMPO DE ESTADO ESTÁ COMO NOT NULL ENTÃO CASO ESSE CAMPO NÃO ESTEJA PREENCHIDO NADA SERÁ REALIZADO.

DECLARE		-- ESTA TABELA RECEBERÁ TODOS OS INSERTS, CRIEI UM INSERT PARA CADA LINHA DESTA TABELA PARA FICAR MAIS FÁCIL A CÓPIA E NÃO TER PERIGO DE ESTOURAR O TAMANHO DO CAMPO
	@tmp_OutputInserts table(
		str_OutputLine VARCHAR(MAX))

/* FIM DA DECLARAÇÃO DAS VARIÁVEIS */

DELETE FROM tmp_testenfeRejeicao

-- Lembrar que tem que salvar em UNICODE
BULK INSERT tmp_testenfeRejeicao 
FROM '\\srv-sup01\Teste\Brendon\Novo_Documento_de_Texto.csv'
WITH
(
	FIELDTERMINATOR = ';',
	ROWTERMINATOR = '\n',
	FIRSTROW = 1 -- ISSO AQUI TÁ PRA TIRAR O CABEÇALHO, CASO NÃO TENHA CABEÇALHO FAVOR LEMBRAR DE ALTERAR PARA 1
)

--select * from tmp_testenfeRejeicao

--select * from tmp_pathRegistersBeneficioFiscal ORDER BY str_Observacao desc
INSERT INTO @tmp_OutputInserts
SELECT
	'str_OutputLine' ='DECLARE @int_cod_StatusResposta  INT ' + CHAR(13) + CHAR(10) +
										'DECLARE @str_desc_StatusResposta VARCHAR(500)' + CHAR(13) + CHAR(10)

INSERT INTO @tmp_OutputInserts
SELECT
	'str_OutputLine' ='SET @int_cod_StatusResposta = ' + Cast(int_codstatus as varchar(20)) + '																														' + CHAR(13) + CHAR(10) +
										'SET @str_desc_StatusResposta = ''' + str_Rejeicao + '''																												' + CHAR(13) + CHAR(10) +
										'																																																								' + CHAR(13) + CHAR(10) +
										'IF EXISTS (SELECT * FROM StatusRespostaNFEletronica WHERE int_cod_StatusResposta = @int_cod_StatusResposta)		' + CHAR(13) + CHAR(10) +
										'	BEGIN 																																																				' + CHAR(13) + CHAR(10) +
										'		UPDATE																																																			' + CHAR(13) + CHAR(10) +
										'			StatusRespostaNFEletronica																																								' + CHAR(13) + CHAR(10) +
										'		SET																																																					' + CHAR(13) + CHAR(10) +
										'			str_desc_StatusResposta = @str_desc_StatusResposta																												' + CHAR(13) + CHAR(10) +
										'		WHERE																																																				' + CHAR(13) + CHAR(10) +
										'			int_cod_StatusResposta = @int_cod_StatusResposta																													' + CHAR(13) + CHAR(10) +
										'		END																																																					' + CHAR(13) + CHAR(10) +
										'																																																								' + CHAR(13) + CHAR(10) +
										'IF NOT EXISTS (SELECT * FROM StatusRespostaNFEletronica WHERE int_cod_StatusResposta = @int_cod_StatusResposta)' + CHAR(13) + CHAR(10) +
										'	BEGIN 																																																				' + CHAR(13) + CHAR(10) +
										'		INSERT INTO 																																																' + CHAR(13) + CHAR(10) +
										'				dbo.StatusRespostaNFEletronica( 																																				' + CHAR(13) + CHAR(10) +
										'						int_cod_StatusResposta, 																																						' + CHAR(13) + CHAR(10) +
										'						str_desc_StatusResposta) 																																						' + CHAR(13) + CHAR(10) +
										'				VALUES( 																																																' + CHAR(13) + CHAR(10) +
										'						@int_cod_StatusResposta, 																																						' + CHAR(13) + CHAR(10) +
										'						@str_desc_StatusResposta) 																																					' + CHAR(13) + CHAR(10) +
										'	END																																																						' + CHAR(13) + CHAR(10)
FROM
	tmp_testenfeRejeicao
	
DELETE FROM tmp_testenfeRejeicao

SELECT * FROM @tmp_OutputInserts
DELETE FROM @tmp_OutputInserts