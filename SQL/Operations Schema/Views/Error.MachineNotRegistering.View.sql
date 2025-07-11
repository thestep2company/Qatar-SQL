USE [Operations]
GO
/****** Object:  View [Error].[MachineNotRegistering]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Error].[MachineNotRegistering] AS 
SELECT Plant, Machine_Num, MAX(DATE_TIME) AS LastRegistered, DATEDIFF(MINUTE,MAX(DATE_TIME),GETDATE()) AS ElapsedTime
FROM Manufacturing.MACHINE_INDEX 
WHERE PLANT = '111' AND CurrentRecord = 1 AND LEN(LTRIM(RTRIM(Machine_Num))) = 2 AND Machine_Num > '0'
GROUP BY Plant, Machine_Num, LEN(Machine_Num)
HAVING DATEDIFF(MINUTE,MAX(DATE_TIME),GETDATE()) > 60
GO
