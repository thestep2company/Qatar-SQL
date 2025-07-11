USE [Operations]
GO
/****** Object:  View [Dim].[Operator]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [Dim].[Operator] AS 
SELECT [ID] AS OperatorID
      ,[Badge Number] AS OperatorKey
      ,[Name] AS OperatorName
	  ,[Badge Number] + ': ' + [Name] AS OperatorDesc
	  ,[Person Number]
      ,[Primary Location]
      ,[Primary Job]
      ,[Reports To]
      ,[Pay Rule]
      --,[Accrual Profile Name]
      ,[Hire Date]
      --,[Function Access Profile]
      --,[Display Profile]
      --,[Employee Group]
      --,[User Account Name]
      --,[Daily Hours]
      --,[Weekly Hours]
      --,[Time Zone]
      --,[City]
      --,[State]
      --,[Country]
      --,[Email Address]
      --,[Last Totalization Date]
      --,[Job Transfer Set (Employee)]
      --,[Job Transfer Set (Manager)]
      --,[Custom Field]
      --,[Schedule Group Assignment Name]
      ,[Employment Status]
      --,[Employment Status Date]
  FROM [ADP].[Employee Basic Summary]
  WHERE LEN([Badge Number]) > 0 --AND Name LIKE '%Austin%'
GO
