/**************************************************************************************
Script created by @monambike. Please check https://github.com/monambike for more details,
including the latest licensing information.

Tip: Press "[CTRL] + [SHIFT] + [M]" to specify values for template parameters. Then press
"[F5]" to use the Script below.

===================================================================================
SCRIPT SHORT DESCRIPTION
===================================================================================
This script has the objective to kill all process from an specific database. You
are going to kill everyone process from "<Database Name, SYSNAME, >".

===================================================================================
WARNING
===================================================================================
This script will kill everyone process from a database. Be aware that some applications
may stop working and you may interrupt someone's work.

**************************************************************************************/

USE [master]

DECLARE @Database SYSNAME = '<Database Name, SYSNAME, >'

/* Verifica se o usuário informou a base */
IF @Database IN ('', CHAR(60) + 'Database Name, SYSNAME, ' + CHAR(62))
  BEGIN
    PRINT 'É necessário informar uma base para matar os processos.'
    RETURN
  END

DECLARE @SPID INT
SELECT @SPID = MIN([spid]) FROM [master].[dbo].[sysprocesses] WHERE DBID = DB_ID(@Database)

WHILE @SPID IS NOT NULL
  BEGIN
    EXECUTE ('KILL ' + @SPID)
    SELECT @SPID = MIN([spid]) FROM [master].[dbo].[sysprocesses] WHERE [dbid] = DB_ID(@Database) AND [spid] > @SPID
  END

PRINT 'All process where killed from "<Database Name, SYSNAME, >".'
