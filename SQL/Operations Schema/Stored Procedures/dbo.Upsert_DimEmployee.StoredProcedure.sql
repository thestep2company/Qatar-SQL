USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[Upsert_DimEmployee]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[Upsert_DimEmployee]
AS BEGIN

	INSERT INTO dbo.DimEmployee 
	SELECT s.[Employee ID]
		  ,s.[Primary Location]
		  ,s.[Primary Job]
		  ,s.[Schedule Group Assignment Name]
		  ,s.[Accrual Profile Name]
		  ,s.[Employee Type]
		  ,s.[Employee Full Name]
		  ,s.[Hire Date]
		  ,s.[Date Terminated]
		  ,s.[Termination Reason]
		  ,s.[LocationKey]
		  ,s.[Job]
		  ,s.[Department]
		  ,s.[DepartmentID]
		  ,s.[Status]
		  ,s.[ShiftName]
		  ,s.[ShiftID]
		  ,s.[Tenure] 
	FROM Dim.Employee s
		LEFT JOIN dbo.DimEmployee t ON s.[Employee ID] = t.[Employee ID]
	WHERE t.[Employee ID] IS NULL

	UPDATE t 
	SET  t.[Primary Location] = s.[Primary Location]
		,t.[Primary Job] = s.[Primary Job]
		,t.[Schedule Group Assignment Name] = s.[Schedule Group Assignment Name]
		,t.[Accrual Profile Name] = s.[Accrual Profile Name]
		,t.[Employee Type] = s.[Employee Type]
		,t.[Employee Full Name] = s.[Employee Full Name]
		,t.[Hire Date] = s.[Hire Date]
		,t.[Date Terminated] = s.[Date Terminated]
		,t.[Termination Reason] = s.[Termination Reason]
		,t.[LocationKey] = s.[LocationKey]
		,t.[Job] = s.[Job]
		,t.[Department] = s.[Department]
		,t.[DepartmentID] = s.[DepartmentID]
		,t.[Status] = s.[Status]
		,t.[ShiftName] = s.[ShiftName]
		,t.[ShiftID] = s.[ShiftID]
		,t.[Tenure] = s.[Tenure]
	FROM dbo.DimEmployee t
		LEFT JOIN Dim.Employee s ON s.[Employee ID] = t.[Employee ID]
	WHERE    ISNULL(s.[Primary Location],'') <> ISNULL(s.[Primary Location],'')
		  OR ISNULL(s.[Primary Job],'') <> ISNULL(s.[Primary Job],'')
		  OR ISNULL(s.[Schedule Group Assignment Name],'') <> ISNULL(s.[Schedule Group Assignment Name],'')
		  OR ISNULL(s.[Accrual Profile Name],'') <> ISNULL(s.[Accrual Profile Name],'')
		  OR ISNULL(s.[Employee Type],'') <> ISNULL(s.[Employee Type],'')
		  OR ISNULL(s.[Employee Full Name],'') <> ISNULL(s.[Employee Full Name],'')
		  OR ISNULL(s.[Hire Date],'1900-01-01') <> ISNULL(s.[Hire Date],'1900-01-01')
		  OR ISNULL(s.[Date Terminated],'1900-01-01') <> ISNULL(s.[Date Terminated],'1900-01-01')
		  OR ISNULL(s.[Termination Reason],'') <> ISNULL(s.[Termination Reason],'')
		  OR ISNULL(s.[LocationKey],'') <> ISNULL(s.[LocationKey],'')
		  OR ISNULL(s.[Job],'') <> ISNULL(s.[Job],'')
		  OR ISNULL(s.[Department],'') <> ISNULL(s.[Department],'')
		  OR ISNULL(s.[DepartmentID],0) <> ISNULL(s.[DepartmentID],0)
		  OR ISNULL(s.[Status],'') <> ISNULL(s.[Status],'')
		  OR ISNULL(s.[ShiftName],'') <> ISNULL(s.[ShiftName],'')
		  OR ISNULL(s.[ShiftID],0) <> ISNULL(s.[ShiftID],0)
		  OR ISNULL(s.[Tenure],0) <> ISNULL(s.[Tenure],0)
END
GO
