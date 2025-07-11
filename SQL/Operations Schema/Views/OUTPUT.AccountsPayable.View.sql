USE [Operations]
GO
/****** Object:  View [OUTPUT].[AccountsPayable]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [OUTPUT].[AccountsPayable] AS
SELECT [Organization]
      ,[PERIOD]
      ,[GL_MONTH]
      ,[GL_YEAR]
      ,[Accounting Date]
      ,[Distr Amount]
      ,[Description]
      ,[AP Account]
      ,[Company]
      ,[Location]
      ,[Dept]
      ,[Account]
      ,[Addback]
      ,[Supplier Num]
      ,[Vendor]
      ,[CITY]
      ,[STATE]
      ,[ZIP]
      ,[PROVINCE]
      ,[COUNTRY]
      ,[Vendor Invoice]
      ,[Invoice Date]
      ,[Terms]
      ,[Voucher Num]
      ,[Category Code]
      ,[APIA Description]
      ,[Batch Name]
      ,[PO_NUMBER]
      ,[GL_Account_Name]
  FROM [Oracle].[AccountsPayable]
GO
