USE [Operations]
GO
/****** Object:  View [Dim].[User]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Dim].[User] AS 
SELECT ID AS UserID
	,First_Name AS FirstName
	,Last_Name AS LastName
	,Site AS Plant
	,Location AS Department	
FROM Employee.Employee WHERE CurrentRecord = 1
GO
