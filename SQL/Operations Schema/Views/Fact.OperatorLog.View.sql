USE [Operations]
GO
/****** Object:  View [Fact].[OperatorLog]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [Fact].[OperatorLog] AS 
WITH MachineIndex AS (
	SELECT [LogDateTime]
      ,[MachineLocation]
      ,[MachineNumber]
	  ,[MachineSize]
      ,CAST([Operator] AS VARCHAR(10)) AS Operator
	  ,'L' + RIGHT('00'+CAST(MachineNumber AS VARCHAR(2)),2) + '_' + CAST(MachineSize AS VARCHAR(3)) AS MachineKey
	  ,CASE WHEN Operator = LAG (Operator) OVER (PARTITION BY MachineLocation, MachineNumber ORDER BY LogDateTime) THEN 0 ELSE 1 END AS OperatorLogIn
	  ,CASE WHEN Operator = LEAD (Operator) OVER (PARTITION BY MachineLocation, MachineNumber ORDER BY LogDateTime) THEN 0 ELSE 1 END AS OperatorLogOut
	FROM [MachineData].[MachineIndex]
	WHERE CurrentRecord = 1
)
, Data AS (
	SELECT ROW_NUMBER() OVER (PARTITION BY MachineKey ORDER BY LogDateTime) AS LogID, * --MachineLocation, MachineNumber, MachineSize, Operator, Shift, Shift_ID, ScanIn, ScanOut
	FROM MachineIndex
	WHERE OperatorLogIn = 1 OR OperatorLogOut = 1
)
SELECT a.LogID, m.MachineID, mo.OperatorID, a.LogDateTime AS StartDate, ISNULL(b.LogDateTime, GETDATE()) AS EndDate
FROM Data a 
	LEFT JOIN Data b ON a.LogID + 1 = b.LogID AND a.MachineKey = b.MachineKey
	LEFT JOIN dbo.DimMachineOperator mo ON a.Operator = mo.OperatorKey
	LEFT JOIN dbo.DimMachine m ON a.MachineKey = m.MachineKey AND a.MachineLocation = m.LocationKey
GO
