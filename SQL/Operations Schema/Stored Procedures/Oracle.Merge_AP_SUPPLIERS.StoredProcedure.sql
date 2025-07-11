USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[Merge_AP_SUPPLIERS]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Oracle].[Merge_AP_SUPPLIERS] AS BEGIN

	CREATE TABLE #AP_SUPPLIERS (
		[VENDOR_ID] [float] NOT NULL,
		[VENDOR_NAME] [nvarchar](240) NULL,
		[VENDOR_TYPE_LOOKUP_CODE] [nvarchar](30) NULL,
		[Fingerprint] [varchar](32) NOT NULL
	)

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Oracle Download', GETDATE()

	INSERT INTO #AP_SUPPLIERS
	SELECT VENDOR_ID, VENDOR_NAME, VENDOR_TYPE_LOOKUP_CODE, 'XXXXXXXXXXX' 
	FROM OPENQUERY(PROD,'SELECT * FROM AP_SUPPLIERS')
	
	/*
		DECLARE @columnList VARCHAR(MAX) = dbo.getHashField ('AP_SUPPLIERS','Oracle') SELECT @columnList
	*/

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Fingerprint', GETDATE()

	UPDATE #AP_SUPPLIERS
	SET Fingerprint = 
		SUBSTRING(LOWER(CONVERT(VARCHAR(32),HASHBYTES('MD5',
			--replace @columnList result here
			 CAST(ISNULL([VENDOR_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([VENDOR_NAME],'') AS VARCHAR(240)) +  CAST(ISNULL([VENDOR_TYPE_LOOKUP_CODE],'') AS VARCHAR(30)) 
		),1)),3,32);


	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Merge', GETDATE()

	INSERT INTO Oracle.[AP_SUPPLIERS] (
			[VENDOR_ID]
		,[VENDOR_NAME]
		,[VENDOR_TYPE_LOOKUP_CODE]
		,[Fingerprint]
	)
		SELECT 
				a.[VENDOR_ID]
			,a.[VENDOR_NAME]
			,a.[VENDOR_TYPE_LOOKUP_CODE]
			,a.[Fingerprint]
		FROM (
			MERGE Oracle.[AP_SUPPLIERS] b
			USING (SELECT * FROM #AP_SUPPLIERS) a
			ON a.[VENDOR_ID] = b.[VENDOR_ID] AND b.CurrentRecord = 1 --swap with business key of table
			WHEN NOT MATCHED --BY TARGET 
			THEN INSERT (
					[VENDOR_ID]
				,[VENDOR_NAME]
				,[VENDOR_TYPE_LOOKUP_CODE]
				,[Fingerprint]
			)
			VALUES (
					a.[VENDOR_ID]
				,a.[VENDOR_NAME]
				,a.[VENDOR_TYPE_LOOKUP_CODE]
				,a.[Fingerprint]
			)
			--Existing records that have changed are expired
			WHEN MATCHED AND a.Fingerprint<>b.Fingerprint
			THEN UPDATE SET b.EndDate=GETDATE()
				,b.CurrentRecord=0
			OUTPUT 
						a.[VENDOR_ID]
					,a.[VENDOR_NAME]
					,a.[VENDOR_TYPE_LOOKUP_CODE]
					,a.[Fingerprint],
					$Action AS Action
		) a
		WHERE Action = 'Update'
		;

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()
	
	DROP TABLE #AP_SUPPLIERS

END

	
GO
