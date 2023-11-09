/**************************************************************************************
Script created by @monambike. Please check https://github.com/monambike for more details,
including the latest licensing information.

Tip: Press "[CTRL] + [SHIFT] + [M]" to specify values for template parameters. Then press
"[F5]" to use the Script below.

===================================================================================
SCRIPT SHORT DESCRIPTION
===================================================================================
This Scripts has as objective make easier database name update on SQL Server.
After defining both databases names press [F5] to update it. After running this Script
you will update the name from database "<Old Database Name, SYSNAME, >" to "<New Database Name, SYSNAME, >".

===================================================================================
WARNING
===================================================================================
This Script will put the database in "Single User Mode" (disconnecting all other users
and dropping all connections) and update its name.

**************************************************************************************/

USE [master]

/* Disconnect everyone that are connected on the database just allowing you to be connected*/
ALTER DATABASE [<Old Database Name, SYSNAME, >] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
PRINT ('All users (except you) where disconnected from the database "<Old Database Name, SYSNAME, >".'
+ CHAR(13) + CHAR(10) + 'At the moment you are the only user connected and all the other users will not be able to connect until the access be released again.')
GO

/* Update database name*/
EXEC master..sp_renamedb  [<Old Database Name, SYSNAME, >], [<New Database Name, SYSNAME, >]
PRINT CHAR(13) + CHAR(10) + 'The database "<Old Database Name, SYSNAME, >" has been renamed to "<New Database Name, SYSNAME, >".'
GO

/* Releases database access so that way other users can access it again */
ALTER DATABASE [<New Database Name, SYSNAME, >] SET MULTI_USER
PRINT CHAR(13) + CHAR(10) + 'The database "<New Database Name, SYSNAME, >" is at "Multi User Mode". Other users will be able to connect to it again.'
GO
