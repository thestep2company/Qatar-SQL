USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[Upsert_DimMachineOperator]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Upsert_DimMachineOperator] AS BEGIN

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Insert', GETDATE()

	--INSERT INTO dbo.DimMachineOperator 
	--SELECT DISTINCT source.Operator
	--FROM xref.MachineOperator source
	--	LEFT JOIN dbo.DimMachineOperator target ON source.Operator = target.OperatorName
	--WHERE source.CurrentRecord = 1	
	--	AND target.OperatorName IS NULL

	INSERT INTO dbo.DimMachineOperator 
	SELECT s.[OperatorKey]
		  ,s.[OperatorName]
		  ,s.[OperatorDesc]
		  ,s.[Person Number]
		  ,s.[Primary Location]
		  ,s.[Primary Job]
		  ,s.[Reports To]
		  ,s.[Pay Rule]
		  ,s.[Hire Date]
		  ,s.[Employment Status]
	FROM Dim.Operator s
		LEFT JOIN dbo.DimMachineOperator t ON s.OperatorKey = t.OperatorKey	
	WHERE t.OperatorKey IS NULL

	INSERT INTO dbo.DimMachineOperator (OperatorKey, OperatorName, OperatorDesc)
	SELECT s.OperatorKey, s.OperatorName, s.OperatorDesc 
	FROM Dim.MachineOperator s
		LEFT JOIN dbo.DimMachineOperator t ON s.OperatorKey = t.OperatorKey
	WHERE t.OperatorKey IS NULL

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()

END
GO
