USE [Operations]
GO
/****** Object:  View [Fact].[MachineGoal]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Fact].[MachineGoal] AS
SELECT 
	m.MachineID
	,Rounds 
FROM Manufacturing.MachineGoal mg
	LEFT JOIN Dim.Machine m ON mg.MachineModel = m.MachineModel
GO
