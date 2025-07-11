USE [Operations]
GO
/****** Object:  View [Fact].[DOR]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [Fact].[DOR] AS
SELECT [DateID]
      ,[LocationID]
      ,[ShiftID]
      ,ISNULL([ADDED_OVERTIME_HRS],0) AS [Added Overtime Hours]
      ,ISNULL([ADDED_OVERTIME_HEADS],0) AS [Added Overtime Heads]
      ,ISNULL([ASSEMBLY_OT_HRS],0) AS [Assembly Overtime Hours]
      ,ISNULL([ASSEMBLY_OT_HEADS],0) AS [Assembly Overtime Heads]
      ,ISNULL([ROTO_OT_HRS],0) AS [Roto Overtime Hours]
      ,ISNULL([ROTO_OT_HEADS],0) AS [Roto Overtime Heads]
      ,ISNULL([TOTAL_TRAINING_HRS] ,0)AS [Total Training Hours]
      ,ISNULL([TOTAL_TRAINING_HEADS],0) AS [Total Training Heads]
      ,ISNULL([ASSEMBLY_TRAINING_HRS],0) AS [Assembly Training HOurs]
      ,ISNULL([ASSEMBLY_TRAINING_HEADS],0) AS [Assembly Training Heads]
      ,ISNULL([ROTO_TRAINING_HRS],0) AS [Roto Training Hours]
      ,ISNULL([ROTO_TRAINING_HEADS],0) AS [Roto Training Heads]
      ,ISNULL([ASSEMBLY_TOTAL_HRS],0) AS [Assembly Total Hours]
      ,ISNULL([ASSEMBLY_TOTAL_HEADS],0) AS [Assembly Total Heads]
      ,ISNULL([ASSEMBLY_LINE_HRS],0) AS [Assembly Line Hours]
      ,ISNULL([ASSEMBLY_LINE_HEADS],0) AS [Assembly Line Heads]
      ,ISNULL([CELL_LEAD_HRS],0) AS [Cell Lead Hours]
      ,ISNULL([CELL_LEAD_HEADS],0) AS [Cell Lead Heads]
      ,ISNULL([JANITOR_HRS],0) AS [Janitor Hours]
      ,ISNULL([JANITOR_HEADS],0) AS [Janitor Heads]
      ,ISNULL([ASSEMBLY_TRAINEE_HRS],0) AS [Assembly Trainee Hours]
      ,ISNULL([ASSEMBLY_TRAINEE_HEADS],0) AS [Assembly Trainee Heads]
      ,ISNULL([ASSEMBLY_TRAINER_HRS],0) AS [Assembly Trainer Hours]
      ,ISNULL([ASSEMBLY_TRAINER_HEADS],0) AS [Assembly Trainer Heads]
      ,ISNULL([OTHER_DIRECT_HRS],0) AS [Other Direct Horus]
      ,ISNULL([OTHER_DIRECT_HEADS],0) AS [Other Direct Heads]
      ,ISNULL([ASSEMBLY_LT_DUTY_HRS],0) AS [Assembly Light Duty Hours]
      ,ISNULL([ASSEMBLY_LT_DUTY_HEADS],0) AS [Aseembly Light Duty Heads]
      ,ISNULL([ROTO_TOTAL_HRS],0) AS [Roto Total Hours]
      ,ISNULL([ROTO_TOTAL_HEADS],0) AS [Roto Total Heads]
      ,ISNULL([ROTO_MACHINE_HRS],0) AS [Roto Machine Hours]
      ,ISNULL([ROTO_MACHINE_HEADS],0) AS [Roto Machine Heads]
      ,ISNULL([ROTO_FLOAT_HRS],0) AS [Roto Float Hours]
      ,ISNULL([ROTO_FLOAT_HEADS],0) AS [Roto Float Heads]
      ,ISNULL([ROTO_TRAINEE_HRS],0) AS [Roto Trainee Hours]
      ,ISNULL([ROTO_TRAINEE_HEADS],0) AS [Roto Trainee Heads]
      ,ISNULL([ROTO_TRAINER_HRS],0) AS [Roto Trainer Hours]
      ,ISNULL([ROTO_TRAINER_HEADS],0) AS [Roto Trainer Heads]
      ,ISNULL([POWDER_ROOM_HRS],0) AS [Power Room Hours]
      ,ISNULL([POWDER_ROOM_HEADS],0) AS [Power Room Heads]
      ,ISNULL([MOLDED_CHANGES_ACTUAL_HRS],0) AS [Mold Changes]
      ,ISNULL([SPIDERS_REMOVED_ACTUAL_HRS],0) AS [Spiders Removed]
      ,ISNULL([SPIDERS_ADDED_ACTUAL_HRS],0) AS [Spiders Added]
      ,ISNULL([VERSION_CHANGES_ACTUAL_HRS],0) AS [Version Changes]
      ,ISNULL([NUM_OF_SKU_RAN_ACTUAL_HRS],0) AS [Number of SKUs Ran]
      ,ISNULL([TOTAL_EMPTY_SPACES_ACTUAL_HRS],0) AS [Total Empty Spaces]
      ,ISNULL([EMPTY_SPACES_190_ACTUAL_HRS],0) AS [Empty Spaces 190]
      ,ISNULL([EMPTY_SPACES_220_ACTUAL_HRS],0) AS [Empty Spaces 220]
      ,ISNULL([EMPTY_SPACES_280_ACTUAL_HRS],0) AS [Empty Spaces 280]
      ,ISNULL([EMPTY_SPACES_110_ACTUAL_HRS],0) AS [Empty Spaces 110]
      ,ISNULL([SPIDERS_RAN_190_ACTUAL_HRS],0) AS [Spiders Ran 190]
      ,ISNULL([SPIDERS_RAN_220_ACTUAL_HRS],0) AS [Spiders Ran 220]
      ,ISNULL([SPIDERS_RAN_280_ACTUAL_HRS],0) AS [Spiders Ran 280]
      ,ISNULL([SPIDERS_RAN_110_ACTUAL_HRS],0) AS [Spiders Ran 110]
      ,ISNULL([ASSEMBLY_CALL_OFF_ACTUAL_HRS],0) AS [Assembly Call Off Hours]
      ,ISNULL([ROTO_CALL_OFF_ACTUAL_HRS],0) AS [Roto Call Off Hours]
  FROM [DOR].[History] dor
	LEFT JOIN dbo.DimCalendarFiscal cf ON dor.[Date] = cf.DateKey
	LEFT JOIN dbo.DimLocation l ON dor.[ORG_CODE] = l.LocationKey
	LEFT JOIN dbo.DimShift s ON dor.Shift = s.ShiftKey


GO
