USE [Operations]
GO
/****** Object:  View [Dim].[LaborCategory]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [Dim].[LaborCategory] AS 
SELECT DISTINCT DENSE_RANK() OVER (ORDER BY LTRIM(RTRIM(REPLACE([Labor Category Name],',','')))) AS LaborCategoryID, LTRIM(RTRIM(REPLACE([Labor Category Name],',',''))) AS LaborCategoryName FROM [Kronos].[EmployeeHours] WITH (NOLOCK)
GO
