USE [Operations]
GO
/****** Object:  View [OUTPUT].[WIPCompletionPerrysville]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [OUTPUT].[WIPCompletionPerrysville] AS 
SELECT [ORG_CODE]
      ,[ORG_NAME]
      ,[TRANS_SRC_TYP_NAME]
      ,[TRANSACTION_TYPE]
      ,[TRANSACTION_DESCRIPTION]
      ,[TRANSACTION_DATE]
      ,[FROM_SUBINVENTORY]
      ,[FROM_LOCATOR]
      ,[TO_SUBINVENTORY]
      ,[TO_LOCATOR]
      ,[ITEM]
      ,[PRIMARY_QTY]
      ,[EXT_VAL]
      ,[TRANSACTION_USER]
FROM Oracle.WIPCompletion 
WHERE TRANSACTION_DATE >= DATEADD(DAY,-7,CAST(GETDATE() AS DATE))
	AND ORG_CODE = '122'
GO
