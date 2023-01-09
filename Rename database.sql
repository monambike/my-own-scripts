/**************************************************************************************

  Press [CTRL]+[SHIFT]+[M] to define parameters and values to be used on this current
  template.

  DESCRIPTION
  -------------------------------------------------------------------------------------
  This Scripts has as objective make easier database name update on SQL Server.
  After defining both databases names press [F5] to update it. After running this Script
  you will update the name from database "<Old database name, VARCHAR, >" to "<New database name, VARCHAR, >".


  WARNING
  -------------------------------------------------------------------------------------
  This Script will put the database in "Single User Mode" (disconnecting all other users
  and dropping all connections) and update its name.

**************************************************************************************/

USE [master]

-- Disconnect everyone that are connected on the database just allowing you to be connected
ALTER DATABASE <Old database name, VARCHAR, > SET SINGLE_USER WITH ROLLBACK IMMEDIATE
PRINT ('All users (except you) where disconnected from the database "<Old database name, VARCHAR, >".'
+ CHAR(13) + CHAR(10) + 'At the moment you are the only user connected and all the other users will not be able to connect until the access be released again.')
GO

-- Update database name
EXEC master..sp_renamedb  <Old database name, VARCHAR, >,  <New database name, VARCHAR, >
PRINT CHAR(13) + CHAR(10) + 'The database "<Old database name, VARCHAR, >" has been renamed to "<New database name, VARCHAR, >".'
GO

-- Releases database access so that way other users can access it again
ALTER DATABASE <New database name, VARCHAR, > SET MULTI_USER
PRINT CHAR(13) + CHAR(10) + 'The database "<New database name, VARCHAR, >" is at "Multi User Mode". Other users will be able to connect to it again.'
GO
