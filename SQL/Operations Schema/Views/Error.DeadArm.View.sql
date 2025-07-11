USE [Operations]
GO
/****** Object:  View [Error].[DeadArm]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [Error].[DeadArm] AS 
SELECT  
       [PLANT]
      ,[SHIFT]
      ,[TransDate]
	  ,[MACHINE_NUM]
      ,[ARM_NUMBER]
      ,SUM([DEAD_ARM]*1.0)/COUNT(*) AS PercentDead
	  ,SUM([DEAD_ARM]) AS DeadRound
	  ,COUNT(*) AS Rounds
FROM [Manufacturing].[MACHINE_INDEX]
WHERE EndDate IS NULL AND TransDate = '2022-02-08'
	--AND Machine_Num = '12' --AND ,[CurrentRecord]
GROUP BY [PLANT]
      ,[SHIFT]
      ,[TransDate]
	  ,[MACHINE_NUM]
      ,[ARM_NUMBER]
--ORDER BY [TransDate] DESC, Plant, Shift, Machine_Num, Arm_Number
GO
