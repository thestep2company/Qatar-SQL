USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[Upsert_FactMachineIndexLive]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Upsert_FactMachineIndexLive] AS BEGIN
	BEGIN TRY
		BEGIN TRAN

			TRUNCATE TABLE dbo.FactMachineIndexLive

			INSERT INTO dbo.FactMachineIndexLive SELECT * FROM [Fact].[MachineIndexLive] WHERE CurrentShiftID = (SELECT MAX([CurrentShiftID]) FROM [Fact].[MachineIndexLive] WHERE PlantID = 3) AND ShiftOffsetID = 1
			INSERT INTO dbo.FactMachineIndexLive SELECT * FROM [Fact].[MachineIndexLive] WHERE CurrentShiftID = (SELECT MAX([CurrentShiftID]) FROM [Fact].[MachineIndexLive] WHERE PlantID = 2) AND ShiftOffsetID = 1

			INSERT INTO dbo.FactMachineIndexLive
			SELECT [DateID]
				  ,[HourID]
				  ,[PlantID]
				  ,[ComponentID]
				  ,[ProductID]
				  ,[ShiftID]
				  ,[MachineID]
				  ,[OperatorID]
				  ,[ReasonID]
				  ,[ShiftOffsetID]
				  ,[CYCLE_COUNT]
				  ,[MISSED_CYCLE]
				  ,[EMPTY_CYCLE]
				  ,[CYCLE_TIME]
				  ,[INDEX_TIME]
				  ,[MISSED_TIME]
				  ,0 AS MadeTime
				  ,0 AS [OvenTime]
				  ,0 AS [TotalTime]
				  ,[CurrentShiftID]
			FROM [Fact].[CycleTimeLive]
			WHERE CurrentShiftID = (SELECT MAX([CurrentShiftID]) FROM [Fact].[CycleTimeLive] WHERE PlantID = 2) AND ShiftOffsetID = 1
				AND INDEX_ID < 0

			--
			--INSERT INTO dbo.FactMachineIndexLive
			--SELECT [DateID]
			--	  ,[HourID]
			--	  ,[PlantID]
			--	  ,[ComponentID]
			--	  ,[ProductID]
			--	  ,[ShiftID]
			--	  ,[MachineID]
			--	  ,[OperatorID]
			--	  ,[ReasonID]
			--	  ,[ShiftOffsetID]
			--	  ,[CYCLE_COUNT]
			--	  ,[MISSED_CYCLE]
			--	  ,[EMPTY_CYCLE]
			--	  ,[CYCLE_TIME]
			--	  ,[INDEX_TIME]
			--	  ,[MISSED_TIME]
			--	  ,0 AS MadeTime
			--	  ,0 AS [OvenTime]
			--	  ,0 AS [TotalTime]
			--	  ,[CurrentShiftID]
			--FROM [Fact].[CycleTimeLive]
			--WHERE CurrentShiftID = (SELECT MAX([CurrentShiftID]) FROM [Fact].[CycleTimeLive] WHERE PlantID = 3) AND ShiftOffsetID = 1
		COMMIT TRAN
	END TRY

	BEGIN CATCH
		ROLLBACK TRAN
		THROW
	END CATCH
END
GO
