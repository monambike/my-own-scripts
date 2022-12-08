/*********************************************************************

  LEGENDA

  Pressione CTRL + SHIFT + M para definir os parâmetros e valores util
  izado nesse template.
  
  Parameter: É a coluna que contém o nome do parâmetro ou o que ele fa
  z;
  Type: É o valor que pode ser inserido no parâmetro;
  Value: É onde você deve inserir o valor desejado.

  
  ATENÇÃO
  
  Esse Script colocará a base em modo de usuário único (desconectando 
  todos os usuários e derrubando conexões) e alterará o seu nome.
  
*********************************************************************/

USE master
GO

ALTER DATABASE <Nome da base antiga, VARCHAR, >
  SET SINGLE_USER WITH ROLLBACK IMMEDIATE
PRINT
(
  'Todos os usuários, exceto você, foram desconectados da base "Teste". No momento você é o único ' + CHAR(13) + CHAR(10) +
  'usuário conectado e outros usuários não poderão se conectar até o acesso ser liberado' + CHAR(13) + CHAR(10) +
  'novamente.' + CHAR(13) + CHAR(10)
)
GO

EXEC master..sp_renamedb  <Nome da base antiga, VARCHAR, >,  <Nome da base nova, VARCHAR, >
PRINT CHAR(13) + CHAR(10) + 'A base "<Nome da base antiga, VARCHAR, >" teve seu nome alterado para "<Nome da base nova, VARCHAR, >".'
GO

ALTER DATABASE <Nome da base nova, VARCHAR, >
  SET MULTI_USER
PRINT CHAR(13) + CHAR(10) + 'O acesso à base foi liberado. Novos usuários poderão se conectar novamente à base.'
GO
