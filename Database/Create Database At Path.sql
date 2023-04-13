/**************************************************************************************

  Press "[CTRL] + [SHIFT] + [M]" to specify values for template parameters. Then press
  "[F5]" to use the Script below.

  ===================================================================================
   Script Short Description
  ===================================================================================

  This script has the objective to help at the proccess of creating a database.

**************************************************************************************/

USE master;
GO
CREATE
  DATABASE <Database Name, , DBName>
    ON (NAME = Solutions_dat, FILENAME = '<File Path (Without Last "\"), , C:>\<Database Name, , DBName>.mdf')
  LOG
    ON (NAME = Solutions_log, FILENAME = '<File Path (Without Last "\"), , C:>\<Database Name, , DBName>.ldf')
GO
