/**************************************************************************************

  ===================================================================================
   Why This Script Is Useful For Performance Tests
  ===================================================================================

  Run all the following commands to clear all Databases cache.
  When you are tuning SQL statements you tend to play in SQL management studio for a
  while. During this time SQL caches your query's and execution plans.

  All well and good but when you are trying to speed up an existing query that is
  taking some time then you may not be making a difference even though your execution
  times are way down.

  You really need to clear SQL's cache (or buffer) every time you test the speed of
  a query. This prevents the data and/or execution plans from being cached, thus
  corrupting the next test.


  ===================================================================================
   Same Command But Single Line
  ===================================================================================

  DBCC FREEPROCCACHE; DBCC DROPCLEANBUFFERS; DBCC FREESYSTEMCACHE ('<Database Name, SYSNAME, >'); DBCC FREESESSIONCACHE;

**************************************************************************************/

DBCC FREEPROCCACHE
GO
DBCC DROPCLEANBUFFERS
GO
DBCC FREESYSTEMCACHE ('<Database Name, SYSNAME, >')
GO
DBCC FREESESSIONCACHE
