USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[Upsert_FactMachineSchedule]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[Upsert_FactMachineSchedule] AS BEGIN
	
	DECLARE @startDate INT = (SELECT DateID FROM dbo.DimCalendarFiscal WHERE DateKey = CAST(DATEADD(DAY,-30,GETDATE()) AS DATE))
	
	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Insert', GETDATE()

	INSERT INTO dbo.FactMachineSchedule
	SELECT cf.DateID, s.ShiftID, m.MachineiD, l.LocationID
	FROM xref.MachineOperator mobm
		LEFT JOIn dbo.DimCalendarFiscal cf ON mobm.Date = cf.DateKey
		LEFT JOIN dbo.DimShift s ON mobm.Shift = s.ShiftKey
		LEFT JOIN dbo.DimMachine m ON mobm.Machine = m.MachineKey AND m.LocationKey = '111'
		LEFT JOIN dbo.DimLocation l ON l.LocationKey = '111'
		LEFT JOIN dbo.DimMachineOperator mo ON mobm.Operator = mo.OperatorName
		LEFT JOIN dbo.FactMachineSchedule ms ON ms.DateID = cf.DateID AND ms.ShiftID = s.ShiftID AND ms.MachineID = m.MachineID AND ms.LocationID = l.LocationID
	WHERE mobm.CurrentRecord = 1 AND ms.DateID IS NULL AND cf.DateID >= @startDate

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()

END
GO
