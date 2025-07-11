USE [Forecast]
GO
/****** Object:  View [OUTPUT].[DatabaseDocumentation]    Script Date: 7/8/2025 3:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [OUTPUT].[DatabaseDocumentation] AS 
SELECT SCHEMA_NAME(tbl.schema_id) AS [Table_Schema],
       tbl.name AS [Table_Name],
       clmns.name AS [Column_Name],
       CAST(p.value AS SQL_VARIANT) AS [Value]
FROM sys.tables AS tbl
       INNER JOIN sys.all_columns AS clmns ON clmns.OBJECT_ID=tbl.OBJECT_ID
       INNER JOIN sys.extended_properties AS p ON p.major_id=clmns.OBJECT_ID
                                              AND p.minor_id=clmns.column_id
                                              AND p.class= 1
                                              AND p.name = 'MS_Description'                                    
--ORDER BY [Table_Schema] ASC,
--         [Table_Name] ASC,
--         [Column_ID] ASC
        
GO
