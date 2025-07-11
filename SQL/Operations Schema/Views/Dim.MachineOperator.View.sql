USE [Operations]
GO
/****** Object:  View [Dim].[MachineOperator]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [Dim].[MachineOperator] WITH SCHEMABINDING AS 
SELECT ROW_NUMBER() OVER (ORDER BY [OPERATOR]) AS OperatorID
	,[OPERATOR] AS OperatorKey ,MAX([OPERATOR_NAME]) AS OperatorName
	,CAST([OPERATOR] AS VARCHAR(25)) + ': ' + MAX([OPERATOR_NAME]) AS OperatorDesc
FROM [Manufacturing].[MACHINE_INDEX]
GROUP BY [OPERATOR]
GO
