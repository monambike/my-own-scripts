-- Ver quanto que uma tabela ta consumindo de espa�o
EXEC sys.sp_spaceused @objname = N'Mov_Estoque';

DBCC SHOW_STATISTICS('Mov_Estoque',
                     'PK_SalesOrderHeader_SalesOrderID');