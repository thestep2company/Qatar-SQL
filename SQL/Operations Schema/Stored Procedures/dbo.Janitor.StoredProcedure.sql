USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[Janitor]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Janitor] AS BEGIN

	DECLARE @object VARCHAR(100) 

	DECLARE db_janitor CURSOR FOR 
	SELECT 'DROP ' + CASE WHEN Type = 'U' THEN 'TABLE ' WHEN Type = 'V' THEN 'VIEW ' WHEN Type = 'P' THEN 'PROCEDURE' WHEN Type = 'FN' THEN 'FUNCTION' END + ' [' + s.Name + '].[' + o.Name + ']'  AS Script
	FROM sys.Objects o
		LEFT JOIN sys.schemas s ON o.schema_id = s.schema_id
	WHERE RIGHT(o.Name,8) < CAST(YEAR(DATEADD(DAY,-30,GETDATE())) * 10000 + MONTH(DATEADD(DAY,-30,GETDATE())) * 100  + DAY(DATEADD(DAY,-30,GETDATE())) AS VARCHAR(8))
		AND o.Name LIKE '%202%'

	OPEN db_janitor  
	FETCH NEXT FROM db_janitor INTO @object

	WHILE @@FETCH_STATUS = 0  
	BEGIN  
		  EXEC(@object)

		  FETCH NEXT FROM db_janitor  INTO @object 
	END 

	CLOSE db_janitor 
	DEALLOCATE db_janitor 

END
GO
