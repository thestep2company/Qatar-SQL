USE [Operations]
GO
/****** Object:  View [Dim].[Step2DirectReasonLookup]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [Dim].[Step2DirectReasonLookup] AS
SELECT [ReasonKey]
      ,[ReasonCategory]
  FROM xref.Step2DirectReasonLookup
GO
