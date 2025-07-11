USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[Upsert_FactMachineIndex]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Upsert_FactMachineIndex] 
	@p_startDate DATE = NULL
AS BEGIN

	DECLARE @startDate DATE
	SET @startDate = ISNULL(@p_startDate,DATEADD(DAY,-3,GETDATE()))

	UPDATE t
	SET  ProductAID = ISNULL(s.ProductAID,0)
		,ProductBID = ISNULL(s.ProductBID,0)
		,ShiftID = ISNULL(s.ShiftID,0)
		,CurrentShiftID = ISNULL(s.CurrentShiftID,0)
		,OperatorID = ISNULL(s.OperatorID,0)
		,ReasonID = ISNULL(s.ReasonID,0)
		,CycleCount = ISNULL(s.CycleCount,0)
		,MissedCycle = ISNULL(s.MissedCycle,0)
		,EmptyCycle = ISNULL(s.EmptyCycle,0)
		,CycleTime = ISNULL(s.CycleTime,0)
		,IndexTime = ISNULL(s.IndexTime,0)
		,MissedTime = ISNULL(s.MissedTime,0)
		,MadeTime = ISNULL(s.MadeTime,0)
		,OvenTime = ISNULL(s.OvenTime,0)
		,TotalTime = ISNULL(s.TotalTime,0)
	FROM Fact.MachineIndex s
		INNER JOIN dbo.FactMachineIndex t ON s.RecNum = t.RecNum AND s.ShiftOffsetID = t.ShiftOffsetID
		INNER JOIN dbo.DimCalendarFiscal cf ON s.DateID = cf.DateID
	WHERE  cf.DateKey >= @startDate 
		AND (
		   ISNULL(s.DateID,0) <> ISNULL(t.DateID,0)
		OR ISNULL(s.HourID,0) <> ISNULL(t.HourID,0)
		OR ISNULL(s.PlantID,0) <> ISNULL(t.PlantID,0)
		OR ISNULL(s.MachineID,0) <> ISNULL(t.MachineID,0)
		OR ISNULL(s.ProductAID,0) <> ISNULL(t.ProductAID,0)
		OR ISNULL(s.ProductBID,0) <> ISNULL(t.ProductBID,0)
		OR ISNULL(s.ShiftID,0) <> ISNULL(t.ShiftID,0)
		OR ISNULL(s.CurrentShiftID,0) = ISNULL(t.CurrentShiftID,0)
		OR ISNULL(s.OperatorID,0) <> ISNULL(t.OperatorID,0)
		OR ISNULL(s.ReasonID,0) <> ISNULL(t.ReasonID,0)
		OR ISNULL(s.CycleCount,0) <> ISNULL(t.CycleCount,0)
		OR ISNULL(s.MissedCycle,0) <> ISNULL(t.MissedCycle,0)
		OR ISNULL(s.EmptyCycle,0) <> ISNULL(t.EmptyCycle,0)
		OR ISNULL(s.CycleTime,0) <> ISNULL(t.CycleTime,0)
		OR ISNULL(s.IndexTime,0) <> ISNULL(t.IndexTime,0)
		OR ISNULL(s.MissedTime,0) <> ISNULL(t.MissedTime,0)
		OR ISNULL(s.MadeTime,0) <> ISNULL(t.MadeTime,0)
		OR ISNULL(s.OvenTime,0) <> ISNULL(t.OvenTime,0)
		OR ISNULL(s.TotalTime,0) <> ISNULL(t.TotalTime,0)
	)

	INSERT INTO dbo.FactMachineIndex (
	   [RecNum]
      ,[DateID]
      ,[HourID]
      ,[PlantID]
      ,[ProductAID]
      ,[ProductBID]
      ,[ShiftID]
	  ,[CurrentShiftID]
      ,[MachineID]
      ,[OperatorID]
      ,[ReasonID]
      ,[ShiftOffsetID]
      ,[CycleCount]
      ,[MissedCycle]
      ,[EmptyCycle]
      ,[CycleTime]
      ,[IndexTime]
      ,[MissedTime]
      ,[MadeTime]
      ,[OvenTime]
      ,[TotalTime]
	)
	SELECT s.RecNum 
		, s.DateID
		, s.HourID
		, s.PlantID
		, s.ProductAID
		, s.ProductBID
		, s.ShiftID
		, s.CurrentShiftID
		, s.MachineID
		, s.OperatorID
		, s.ReasonID
		, s.ShiftOffsetID
		, s.CycleCount
		, s.MissedCycle
		, s.EmptyCycle
		, s.CycleTime
		, s.IndexTime
		, s.MissedTime 
		, s.MadeTime
		, s.OvenTime
		, s.TotalTime
	FROM Fact.MachineIndex s
		LEFT JOIN dbo.FactMachineIndex t ON s.RecNum = t.RecNum AND s.ShiftOffsetID = t.ShiftOffsetID 
		INNER JOIN dbo.DimCalendarFiscal cf ON s.DateID = cf.DateID
	WHERE t.DateID IS NULL AND cf.DateKey >= @startDate 

	UPDATE t
	SET  ProductAID = ISNULL(s.ProductID,0)
		,ProductBID = ISNULL(s.ComponentID,0)
		,ShiftID = ISNULL(s.ShiftID,0)
		,CurrentShiftID = ISNULL(s.CurrentShiftID,0)
		,OperatorID = ISNULL(s.OperatorID,0)
		,ReasonID = ISNULL(s.ReasonID,0)
		,CycleCount = ISNULL(s.Cycle_Count,0)
		,MissedCycle = ISNULL(s.Missed_Cycle,0)
		,EmptyCycle = ISNULL(s.Empty_Cycle,0)
		,CycleTime = ISNULL(s.Cycle_Time,0)
		,IndexTime = ISNULL(s.Index_Time,0)
		,MissedTime = ISNULL(s.Missed_Time,0)
	FROM [Fact].[CycleTime] s
		INNER JOIN dbo.FactMachineIndex t ON s.RecNum = t.RecNum AND s.ShiftOffsetID = t.ShiftOffsetID
		INNER JOIN dbo.DimCalendarFiscal cf ON s.DateID = cf.DateID
	WHERE  s.RecNum < 0 
		AND cf.DateKey >= @startDate 
		AND (
		   ISNULL(s.DateID,0) <> ISNULL(t.DateID,0)
		OR ISNULL(s.HourID,0) <> ISNULL(t.HourID,0)
		OR ISNULL(s.PlantID,0) <> ISNULL(t.PlantID,0)
		OR ISNULL(s.MachineID,0) <> ISNULL(t.MachineID,0)
		OR ISNULL(s.ProductID,0) <> ISNULL(t.ProductAID,0)
		OR ISNULL(s.ComponentID,0) <> ISNULL(t.ProductBID,0)
		OR ISNULL(s.ShiftID,0) <> ISNULL(t.ShiftID,0)
		OR ISNULL(s.CurrentShiftID,0) = ISNULL(t.CurrentShiftID,0)
		OR ISNULL(s.OperatorID,0) <> ISNULL(t.OperatorID,0)
		OR ISNULL(s.ReasonID,0) <> ISNULL(t.ReasonID,0)
		OR ISNULL(s.Cycle_Count,0) <> ISNULL(t.CycleCount,0)
		OR ISNULL(s.Missed_Cycle,0) <> ISNULL(t.MissedCycle,0)
		OR ISNULL(s.Empty_Cycle,0) <> ISNULL(t.EmptyCycle,0)
		OR ISNULL(s.Cycle_Time,0) <> ISNULL(t.CycleTime,0)
		OR ISNULL(s.Index_Time,0) <> ISNULL(t.IndexTime,0)
		OR ISNULL(s.Missed_Time,0) <> ISNULL(t.MissedTime,0)
	)

	INSERT INTO dbo.FactMachineIndex (
		   [RecNum]
		  ,[DateID]
		  ,[HourID]
		  ,[PlantID]
		  ,[ProductAID]
		  ,[ProductBID]
		  ,[ShiftID]
		  ,[MachineID]
		  ,[OperatorID]
		  ,[ReasonID]
		  ,[ShiftOffsetID]
		  ,[CycleCount]
		  ,[MissedCycle]
		  ,[EmptyCycle]
		  ,[CycleTime]
		  ,[IndexTime]
		  ,[MissedTime]
		  ,[MadeTime]
		  ,[OvenTime]
		  ,[TotalTime]
		  ,[CurrentShiftID]
	)
	SELECT   s.[RecNum]
			,s.[DateID]
			,s.[HourID]
			,s.[PlantID]
			,s.[ProductID]
			,s.[ComponentID]
			,s.[ShiftID]
			,s.[MachineID]
			,ISNULL(s.[OperatorID],0) AS OperatorID
			,s.[ReasonID]
			,s.[ShiftOffsetID]
			,s.[CYCLE_COUNT]
			,s.[MISSED_CYCLE]
			,s.[EMPTY_CYCLE]
			,s.[CYCLE_TIME]
			,s.[INDEX_TIME]
			,s.[MISSED_TIME]
			,0 AS MadeTime
			,0 AS [OvenTime]
			,0 AS [TotalTime]
			,s.[CurrentShiftID]
	FROM [Fact].[CycleTime] s
		LEFT JOIN dbo.FactMachineIndex t ON s.RecNum = t.RecNum AND s.ShiftOffsetID = t.ShiftOffsetID 
		INNER JOIN dbo.DimCalendarFiscal cf ON s.DateID = cf.DateID
	WHERE t.DateID IS NULL AND cf.DateKey >= @startDate AND s.RecNum < 0

END



GO
