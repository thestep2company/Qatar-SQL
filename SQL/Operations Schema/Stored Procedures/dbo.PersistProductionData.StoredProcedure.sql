USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[PersistProductionData]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[PersistProductionData] AS BEGIN

	EXEC dbo.Reload_DimDistribution
	EXEC dbo.Reload_DimForecastPeriod 

	EXEC dbo.Upsert_DimLocation
	EXEC dbo.Upsert_DimMachine --1:53
	EXEC dbo.Upsert_DimMachineOperator
	EXEC dbo.Upsert_DimProductMaster --:22
	EXEC dbo.Upsert_DimRepair
	EXEC dbo.Upsert_DimRepairReason
	EXEC dbo.Upsert_DimShift

	--TRUNCATE TABLE dbo.FactStandard				INSERT INTO dbo.FactStandard SELECT * FROM Fact.Standard --1:49
	--TRUNCATE TABLE dbo.FactStandardPending		INSERT INTO dbo.FactStandardPending SELECT * FROM Fact.StandardPending --1:26
	TRUNCATE TABLE dbo.FactStandards			INSERT INTO dbo.FactStandards SELECT * FROM Fact.Standards
	TRUNCATE TABLE dbo.FactStandardsHistory		INSERT INTO dbo.FactStandardsHistory SELECT * FROM Fact.StandardsHistory
	TRUNCATE TABLE dbo.FactShiftHours			INSERT INTO dbo.FactShiftHours SELECT * FROM Fact.ShiftHours
	TRUNCATE TABLE dbo.FactShiftLength			INSERT INTO dbo.FactShiftLength SELECT * FROM  Fact.ShiftLength

	EXEC dbo.Upsert_FactCycleTime
	EXEC dbo.Upsert_FactLabor
	EXEC dbo.Upsert_FactProduction		
	EXEC dbo.Upsert_FactMachineIndex
	EXEC dbo.Upsert_FactStandard --1:06
	EXEC dbo.Upsert_FactStandardPending --1:14

	--TRUNCATE TABLE dbo.FactMachineCapacity INSERT INTO dbo.FactMachineCapacity SELECT * FROM Fact.MachineCapacity
	
END

GO
