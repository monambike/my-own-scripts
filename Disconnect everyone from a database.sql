/**************************************************************************************

  Press [CTRL]+[SHIFT]+[M] to define parameters and values to be used on this current
  template.


  DESCRIPTION
  -------------------------------------------------------------------------------------
  This script has the objective to disconnect all users from an specific database. You
  are going to disconnect everyone from "<Database Name:, , >".


  WARNING
  -------------------------------------------------------------------------------------
  This script will disconnect all users from a database. Be aware that some applications
  may stop working and you may interrupt someone's work.

**************************************************************************************/

USE [master]

DECLARE @database SYSNAME = '<Database Name:, , >'

DECLARE @spid INT
SELECT @spid = MIN([spid]) FROM [master].[dbo].[sysprocesses]
WHERE DBID = DB_ID(@database)

WHILE @spid IS NOT NULL
  BEGIN
    EXECUTE ('KILL ' + @spid)
    
    SELECT @spid = MIN([spid]) FROM [master].[dbo].[sysprocesses]
    WHERE [dbid] = DB_ID(@database) AND [spid] > @spid
  END

PRINT 'All users where disconnected from "<Database Name:, , >"'