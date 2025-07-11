USE [Forecast]
GO
/****** Object:  View [dbo].[ObjectDependencies]    Script Date: 7/8/2025 3:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[ObjectDependencies] AS
SELECT 
  'VIEW' AS ObjectType,
  DB_NAME() AS DatabaseName,
  SCHEMA_NAME(v.schema_id) AS SchemaName, 
  v.name AS ObjectName,
  o.type_desc AS RefObjectType,
  sed.Referenced_Server_Name AS RefServerName,
  sed.Referenced_database_Name AS RefDatabaseName,
  SCHEMA_NAME(o.schema_id) AS RefSchemaName,
  o.name AS RefObjectName
FROM sys.views v
	JOIN sys.sql_expression_dependencies sed ON v.object_id = sed.referencing_id
	JOIN sys.objects o ON sed.referenced_id = o.object_id
UNION
SELECT 
  'SQL_STORED_PROCEDURE' AS ObjectType,
  DB_NAME() AS DatabaseName,
  SCHEMA_NAME(v.schema_id) AS SchemaName, 
  v.name AS ObjectName,
  o.type_desc AS RefObjectType,
  sed.Referenced_Server_Name AS RefServerName,
  sed.Referenced_database_Name AS RefDatabaseName,
  SCHEMA_NAME(o.schema_id) AS RefSchemaName,
  o.name AS RefObjectName
FROM sys.procedures v
	JOIN sys.sql_expression_dependencies sed ON v.object_id = sed.referencing_id
	JOIN sys.objects o ON sed.referenced_id = o.object_id
GO
