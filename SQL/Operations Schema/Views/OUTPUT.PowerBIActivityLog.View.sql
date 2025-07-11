USE [Operations]
GO
/****** Object:  View [OUTPUT].[PowerBIActivityLog]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [OUTPUT].[PowerBIActivityLog] AS 
SELECT [Id]
      ,[CreationTime]
      ,[Workload]
      ,UPPER(SUBSTRING([UserID],1,CHARINDEX('@',[UserID])-1)) AS UserID
      ,[Activity]
      ,[ItemName]
      ,CASE WHEN [WorkSpaceName] IS NULL THEN ConsumptionMethod ELSE [WorkspaceName] END AS [WorkspaceName]
      ,REPLACE([DatasetName],' - Analyzed in Excel','') AS [DatasetName]
      ,[ReportName]
      ,[WorkspaceId]
      ,[ObjectId]
      ,[DatasetId]
      ,[ReportId]
      ,[ReportType]
      ,[DistributionMethod]
      ,CASE WHEN ItemName IS NULL OR ItemName = 'Excel.exe' OR ItemName = 'Excel Online' OR Activity = 'ConnectFromExternalApplication' OR Activity = 'AnalyzedByExternalApplication' OR Activity = 'AnalyzeInExcel' OR Activity = 'ExportReport' THEN 'Excel Report' 
			WHEN Activity = 'AnalyzedByExternalApplication' AND ItemName LIKE 'Power BI Desktop%' THEN 'Power BI Desktop'
			WHEN Activity = 'ViewReport' AND [ConsumptionMethod] IS NULL THEN 'Power BI Web'
			ELSE [ConsumptionMethod] 
		END AS [ConsumptionMethod]
      ,[Import_Timestamp]
      ,CAST(CreationTime AS DATE) AS CreationDate 
FROM dbo.PowerBIActivityLog WHERE CreationTime >= DATEADD(DAY,-30,GETDATE()) 
AND Activity IN ('AnalyzeInExcel', 'ViewReport', 'AnalyzedByExternalApplication', 'ConnectFromExternalApplication', 'ExportReport')
GO
