/**************************************************************************************

  Press [CTRL]+[SHIFT]+[M] to define parameters and values to be used on this current
  template.


  DESCRIPTION
  -------------------------------------------------------------------------------------
  This script has the objective to kill all process from an specific database. You
  are going to kill everyone process from "<Database Name:, , >".


  WARNING
  -------------------------------------------------------------------------------------
  This script will kill everyone process from a database. Be aware that some applications
  may stop working and you may interrupt someone's work.

**************************************************************************************/

USE [master]

DECLARE @Database SYSNAME = '<Database Name:, , >'

DECLARE @SPID INT
SELECT @SPID = MIN([spid]) FROM [master].[dbo].[sysprocesses] WHERE DBID = DB_ID(@Database)

WHILE @SPID IS NOT NULL
  BEGIN
    EXECUTE ('KILL ' + @SPID)
    SELECT @SPID = MIN([spid]) FROM [master].[dbo].[sysprocesses] WHERE [dbid] = DB_ID(@Database) AND [spid] > @SPID
  END

PRINT 'All process where killed from "<Database Name:, , >".'
