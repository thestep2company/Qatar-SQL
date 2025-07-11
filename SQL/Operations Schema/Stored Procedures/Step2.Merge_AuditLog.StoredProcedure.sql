USE [Operations]
GO
/****** Object:  StoredProcedure [Step2].[Merge_AuditLog]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Step2].[Merge_AuditLog] 
AS BEGIN

	DROP TABLE IF EXISTS #AuditLog 

	CREATE TABLE #AuditLog (
		[ID] [int] NOT NULL,
		[ChangeDate] [datetime] NULL,
		[FC_Year] [int] NULL,
		[Type] [varchar](2) NULL,
		[CustomerID] [varchar](8) NULL,
		[PartID] [varchar](25) NULL,
		[FC_Month] [int] NULL,
		[FC_Week] [int] NULL,
		[FC_Date] [datetime] NULL,
		[Orig_Qty] [int] NULL,
		[New_Qty] [int] NULL,
		[Orig_Dollars] [money] NULL,
		[New_Dollars] [money] NULL,
		[Orig_Price] [money] NULL,
		[Rev_Price] [money] NULL,
		[Record_Status] [char](1) NULL,
		[User_Added] [varchar](50) NULL,
		[Date_Added] [datetime] NULL
	) 
	
	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Download', GETDATE()

	INSERT INTO #AuditLog
	SELECT * 
	FROM OPENQUERY(Step2sql,'
		SELECT *
		FROM step2forecasting.dbo.tblAuditLog 
		WHERE fc_year>=2024   
			and date_added >= getdate() -7
	')

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Insert', GETDATE()

	INSERT INTO Step2.AuditLog
	SELECT s.*, GETDATE() AS StartDate FROM #AuditLog s
		LEFT JOIN Step2.AuditLog t ON s.ID = t.ID
	WHERE t.ID IS NULL

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()

END
GO
