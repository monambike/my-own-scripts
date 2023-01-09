/**************************************************************************************

  DESCRIPTION
  -------------------------------------------------------------------------------------
  This Script has as object helping clear and visualize database cache.
  

  COMMANDS FOR CLEARING CACHE
  -------------------------------------------------------------------------------------
  Run all the following commands to clear all Databases cache.

  DBCC FREEPROCCACHE
  GO
  DBCC DROPCLEANBUFFERS
  GO
  DBCC FREESYSTEMCACHE ('ALL')
  GO
  DBCC FREESESSIONCACHE 

**************************************************************************************/

SELECT
    COUNT(*)                                                                  AS [Cached Pages Count]
  , COUNT(*) * 8 / 1024                                                       AS [Cached Size (MB)]
  , (COUNT(*) * 8 / 1024) / 1000                                              AS [Cached Size (GB)]
  , CASE DATABASE_ID WHEN 32767 THEN 'OBJECTDB' ELSE DB_NAME(DATABASE_ID) END AS [Database]
FROM
  SYS.DM_OS_BUFFER_DESCRIPTORS
GROUP BY DB_NAME([DATABASE_ID]), [DATABASE_ID]
ORDER BY [Cached Pages Count] DESC
