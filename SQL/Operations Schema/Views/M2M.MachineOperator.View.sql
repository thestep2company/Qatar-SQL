USE [Operations]
GO
/****** Object:  View [M2M].[MachineOperator]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [M2M].[MachineOperator] AS
SELECT ms.MachineScheduleID, mobs.OperatorID 
FROM dbo.FactMachineOperatorByShift mobs
	INNER JOIN dbo.FactMachineSchedule ms ON mobs.DateID = ms.DateID AND mobs.MachineID = ms.MachineID AND mobs.LocationID = ms.LocationID
GO
