USE [Operations]
GO
/****** Object:  StoredProcedure [QA].[Merge_QualityHoldTagHeader]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [QA].[Merge_QualityHoldTagHeader] AS BEGIN

	CREATE TABLE #QUALITY_HOLD_TAG_HEADER (
		[INDEX_ID] [int] NOT NULL,
		[HOLD_TAG_NUMBER] [int] NULL,
		[DATE] [datetime] NULL,
		[INSPECTOR_NAME] [varchar](50) NULL,
		[SHIFT] [varchar](1) NULL,
		[PRODUCT_NUMBER] [varchar](15) NULL,
		[PRODUCT_DESCRIPTION] [varchar](250) NULL,
		[LOCATION_CODE] [varchar](3) NULL,
		[LOCATION_NAME] [varchar](20) NULL,
		[CELL_ZONE_LEAD] [varchar](50) NULL,
		[QUANTITY_ON_HOLD] [int] NULL,
		[MACHINE_NUMBER] [varchar](3) NULL,
		[MACHINE_LOCATION] [varchar](25) NULL,
		[FIRST_PERSON_RESPONSIBLE] [varchar](50) NULL,
		[SECOND_PERSON_RESPONSIBLE] [varchar](50) NULL,
		[NON_CONFORMANCE_NOTES] [varchar](750) NULL,
		[IN_TRAINING] [varchar](1) NULL,
		[INVESTIGATION_COMMENTS] [varchar](750) NULL,
		[CORRECTIVE_ACTION_TAKEN_COMMENTS] [varchar](750) NULL,
		[RE_WORK_COMPLETED_BY_DATE] [datetime] NULL,
		[RE_WORK_INSPECTED_DATE] [datetime] NULL,
		[RE_WORK_COMPLETED_BY] [varchar](300) NULL,
		[RE_WORK_INSPECTED_BY] [varchar](50) NULL,
		[USE_AS_IS_QTY] [int] NULL,
		[SCRAP_PARTS_QTY] [int] NULL,
		[REPAIRED_PARTS_QTY] [int] NULL,
		[OTHER_QTY_PLEASE_EXPLAIN_QTY] [int] NULL,
		[TOTAL_UNITS_INSPECTED_QTY] [int] NULL,
		[USE_AS_IS_COMMENTS] [varchar](750) NULL,
		[SCRAP_PARTS_COMMENTS] [varchar](750) NULL,
		[REPAIRED_PARTS_COMMENTS] [varchar](750) NULL,
		[OTHER_PLEASE_EXPLAIN_COMMENTS] [varchar](750) NULL,
		[TOTAL_UNITS_INSPECTED_COMMENTS] [varchar](750) NULL,
		[TOTAL_QTY_INSPECTED] [int] NULL,
		[Fingerprint] [varchar](32) NOT NULL	
	)
	
	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Download', GETDATE()

	INSERT INTO #QUALITY_HOLD_TAG_HEADER
  	SELECT *, CAST('XXXXXXXX' AS VARCHAR(32)) AS Fingerprint
	FROM OPENQUERY(FINDLAND,'
		SELECT [INDEX_ID]
		      ,[HOLD_TAG_NUMBER]
		      ,[DATE]
		      ,[INSPECTOR_NAME]
		      ,[SHIFT]
		      ,[PRODUCT_NUMBER]
		      ,[PRODUCT_DESCRIPTION]
		      ,[LOCATION_CODE]
		      ,[LOCATION_NAME]
		      ,[CELL_ZONE_LEAD]
		      ,[QUANTITY_ON_HOLD]
		      ,[MACHINE_NUMBER]
		      ,[MACHINE_LOCATION]
		      ,[FIRST_PERSON_RESPONSIBLE]
		      ,[SECOND_PERSON_RESPONSIBLE]
		      ,[NON_CONFORMANCE_NOTES]
		      ,[IN_TRAINING]
		      ,[INVESTIGATION_COMMENTS]
		      ,[CORRECTIVE_ACTION_TAKEN_COMMENTS]
		      ,[RE_WORK_COMPLETED_BY_DATE]
		      ,[RE_WORK_INSPECTED_DATE]
		      ,[RE_WORK_COMPLETED_BY]
		      ,[RE_WORK_INSPECTED_BY]
		      ,[USE_AS_IS_QTY]
		      ,[SCRAP_PARTS_QTY]
		      ,[REPAIRED_PARTS_QTY]
		      ,[OTHER_QTY_PLEASE_EXPLAIN_QTY]
		      ,[TOTAL_UNITS_INSPECTED_QTY]
		      ,[USE_AS_IS_COMMENTS]
		      ,[SCRAP_PARTS_COMMENTS]
		      ,[REPAIRED_PARTS_COMMENTS]
		      ,[OTHER_PLEASE_EXPLAIN_COMMENTS]
		      ,[TOTAL_UNITS_INSPECTED_COMMENTS]
		      ,[TOTAL_QTY_INSPECTED]
		FROM [Quality].[dbo].[QUALITY_HOLD_TAG_HEADER]
	')
	
	/*
		DECLARE @columnList VARCHAR(MAX) = dbo.getHashField ('QUALITY_HOLD_TAG_HEADER','QA') SELECT @columnList
	*/

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Fingerprint', GETDATE()

	UPDATE #QUALITY_HOLD_TAG_HEADER
	SET Fingerprint = 
		SUBSTRING(LOWER(CONVERT(VARCHAR(32),HASHBYTES('MD5',
			--replace @columnList result here
			   CAST(ISNULL([INDEX_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([HOLD_TAG_NUMBER],'0') AS VARCHAR(100)) +  CAST(ISNULL([DATE],'') AS VARCHAR(100)) +  CAST(ISNULL([INSPECTOR_NAME],'') AS VARCHAR(50)) +  CAST(ISNULL([SHIFT],'') AS VARCHAR(1)) +  CAST(ISNULL([PRODUCT_NUMBER],'') AS VARCHAR(15)) +  CAST(ISNULL([PRODUCT_DESCRIPTION],'') AS VARCHAR(250)) +  CAST(ISNULL([LOCATION_CODE],'') AS VARCHAR(3)) +  CAST(ISNULL([LOCATION_NAME],'') AS VARCHAR(20)) +  CAST(ISNULL([CELL_ZONE_LEAD],'') AS VARCHAR(50)) +  CAST(ISNULL([QUANTITY_ON_HOLD],'0') AS VARCHAR(100)) +  CAST(ISNULL([MACHINE_NUMBER],'') AS VARCHAR(3)) +  CAST(ISNULL([MACHINE_LOCATION],'') AS VARCHAR(25)) +  CAST(ISNULL([FIRST_PERSON_RESPONSIBLE],'') AS VARCHAR(50)) +  CAST(ISNULL([SECOND_PERSON_RESPONSIBLE],'') AS VARCHAR(50)) +  CAST(ISNULL([NON_CONFORMANCE_NOTES],'') AS VARCHAR(750)) +  CAST(ISNULL([IN_TRAINING],'') AS VARCHAR(1)) +  CAST(ISNULL([INVESTIGATION_COMMENTS],'') AS VARCHAR(750)) +  CAST(ISNULL([CORRECTIVE_ACTION_TAKEN_COMMENTS],'') AS VARCHAR(750)) +  CAST(ISNULL([RE_WORK_COMPLETED_BY_DATE],'') AS VARCHAR(100)) +  CAST(ISNULL([RE_WORK_INSPECTED_DATE],'') AS VARCHAR(100)) +  CAST(ISNULL([RE_WORK_COMPLETED_BY],'') AS VARCHAR(50)) +  CAST(ISNULL([RE_WORK_INSPECTED_BY],'') AS VARCHAR(50)) +  CAST(ISNULL([USE_AS_IS_QTY],'0') AS VARCHAR(100)) +  CAST(ISNULL([SCRAP_PARTS_QTY],'0') AS VARCHAR(100)) +  CAST(ISNULL([REPAIRED_PARTS_QTY],'0') AS VARCHAR(100)) +  CAST(ISNULL([OTHER_QTY_PLEASE_EXPLAIN_QTY],'0') AS VARCHAR(100)) +  CAST(ISNULL([TOTAL_UNITS_INSPECTED_QTY],'0') AS VARCHAR(100)) +  CAST(ISNULL([USE_AS_IS_COMMENTS],'') AS VARCHAR(750)) +  CAST(ISNULL([SCRAP_PARTS_COMMENTS],'') AS VARCHAR(750)) +  CAST(ISNULL([REPAIRED_PARTS_COMMENTS],'') AS VARCHAR(750)) +  CAST(ISNULL([OTHER_PLEASE_EXPLAIN_COMMENTS],'') AS VARCHAR(750)) +  CAST(ISNULL([TOTAL_UNITS_INSPECTED_COMMENTS],'') AS VARCHAR(750)) +  CAST(ISNULL([TOTAL_QTY_INSPECTED],'0') AS VARCHAR(100)) 
		),1)),3,32);


	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Merge', GETDATE()

		INSERT INTO QA.[QUALITY_HOLD_TAG_HEADER] (
			   [INDEX_ID]
		      ,[HOLD_TAG_NUMBER]
		      ,[DATE]
		      ,[INSPECTOR_NAME]
		      ,[SHIFT]
		      ,[PRODUCT_NUMBER]
		      ,[PRODUCT_DESCRIPTION]
		      ,[LOCATION_CODE]
		      ,[LOCATION_NAME]
		      ,[CELL_ZONE_LEAD]
		      ,[QUANTITY_ON_HOLD]
		      ,[MACHINE_NUMBER]
		      ,[MACHINE_LOCATION]
		      ,[FIRST_PERSON_RESPONSIBLE]
		      ,[SECOND_PERSON_RESPONSIBLE]
		      ,[NON_CONFORMANCE_NOTES]
		      ,[IN_TRAINING]
		      ,[INVESTIGATION_COMMENTS]
		      ,[CORRECTIVE_ACTION_TAKEN_COMMENTS]
		      ,[RE_WORK_COMPLETED_BY_DATE]
		      ,[RE_WORK_INSPECTED_DATE]
		      ,[RE_WORK_COMPLETED_BY]
		      ,[RE_WORK_INSPECTED_BY]
		      ,[USE_AS_IS_QTY]
		      ,[SCRAP_PARTS_QTY]
		      ,[REPAIRED_PARTS_QTY]
		      ,[OTHER_QTY_PLEASE_EXPLAIN_QTY]
		      ,[TOTAL_UNITS_INSPECTED_QTY]
		      ,[USE_AS_IS_COMMENTS]
		      ,[SCRAP_PARTS_COMMENTS]
		      ,[REPAIRED_PARTS_COMMENTS]
		      ,[OTHER_PLEASE_EXPLAIN_COMMENTS]
		      ,[TOTAL_UNITS_INSPECTED_COMMENTS]
		      ,[TOTAL_QTY_INSPECTED]
			  ,[Fingerprint]
		)
			SELECT 
			   a.[INDEX_ID]
		      ,a.[HOLD_TAG_NUMBER]
		      ,a.[DATE]
		      ,a.[INSPECTOR_NAME]
		      ,a.[SHIFT]
		      ,a.[PRODUCT_NUMBER]
		      ,a.[PRODUCT_DESCRIPTION]
		      ,a.[LOCATION_CODE]
		      ,a.[LOCATION_NAME]
		      ,a.[CELL_ZONE_LEAD]
		      ,a.[QUANTITY_ON_HOLD]
		      ,a.[MACHINE_NUMBER]
		      ,a.[MACHINE_LOCATION]
		      ,a.[FIRST_PERSON_RESPONSIBLE]
		      ,a.[SECOND_PERSON_RESPONSIBLE]
		      ,a.[NON_CONFORMANCE_NOTES]
		      ,a.[IN_TRAINING]
		      ,a.[INVESTIGATION_COMMENTS]
		      ,a.[CORRECTIVE_ACTION_TAKEN_COMMENTS]
		      ,a.[RE_WORK_COMPLETED_BY_DATE]
		      ,a.[RE_WORK_INSPECTED_DATE]
		      ,a.[RE_WORK_COMPLETED_BY]
		      ,a.[RE_WORK_INSPECTED_BY]
		      ,a.[USE_AS_IS_QTY]
		      ,a.[SCRAP_PARTS_QTY]
		      ,a.[REPAIRED_PARTS_QTY]
		      ,a.[OTHER_QTY_PLEASE_EXPLAIN_QTY]
		      ,a.[TOTAL_UNITS_INSPECTED_QTY]
		      ,a.[USE_AS_IS_COMMENTS]
		      ,a.[SCRAP_PARTS_COMMENTS]
		      ,a.[REPAIRED_PARTS_COMMENTS]
		      ,a.[OTHER_PLEASE_EXPLAIN_COMMENTS]
		      ,a.[TOTAL_UNITS_INSPECTED_COMMENTS]
		      ,a.[TOTAL_QTY_INSPECTED]
			  ,a.[Fingerprint]
		FROM (
				MERGE QA.[QUALITY_HOLD_TAG_HEADER] b
				USING (SELECT * FROM #QUALITY_HOLD_TAG_HEADER) a
				ON a.[INDEX_ID] = b.[INDEX_ID] AND b.CurrentRecord = 1 --swap with business key of table
				WHEN NOT MATCHED --BY TARGET 
				THEN INSERT (
					   [INDEX_ID]
				      ,[HOLD_TAG_NUMBER]
				      ,[DATE]
				      ,[INSPECTOR_NAME]
				      ,[SHIFT]
				      ,[PRODUCT_NUMBER]
				      ,[PRODUCT_DESCRIPTION]
				      ,[LOCATION_CODE]
				      ,[LOCATION_NAME]
				      ,[CELL_ZONE_LEAD]
				      ,[QUANTITY_ON_HOLD]
				      ,[MACHINE_NUMBER]
				      ,[MACHINE_LOCATION]
				      ,[FIRST_PERSON_RESPONSIBLE]
				      ,[SECOND_PERSON_RESPONSIBLE]
				      ,[NON_CONFORMANCE_NOTES]
				      ,[IN_TRAINING]
				      ,[INVESTIGATION_COMMENTS]
				      ,[CORRECTIVE_ACTION_TAKEN_COMMENTS]
				      ,[RE_WORK_COMPLETED_BY_DATE]
				      ,[RE_WORK_INSPECTED_DATE]
				      ,[RE_WORK_COMPLETED_BY]
				      ,[RE_WORK_INSPECTED_BY]
				      ,[USE_AS_IS_QTY]
				      ,[SCRAP_PARTS_QTY]
				      ,[REPAIRED_PARTS_QTY]
				      ,[OTHER_QTY_PLEASE_EXPLAIN_QTY]
				      ,[TOTAL_UNITS_INSPECTED_QTY]
				      ,[USE_AS_IS_COMMENTS]
				      ,[SCRAP_PARTS_COMMENTS]
				      ,[REPAIRED_PARTS_COMMENTS]
				      ,[OTHER_PLEASE_EXPLAIN_COMMENTS]
				      ,[TOTAL_UNITS_INSPECTED_COMMENTS]
				      ,[TOTAL_QTY_INSPECTED]
					  ,[Fingerprint]
				)
				VALUES (
					   a.[INDEX_ID]
				      ,a.[HOLD_TAG_NUMBER]
				      ,a.[DATE]
				      ,a.[INSPECTOR_NAME]
				      ,a.[SHIFT]
				      ,a.[PRODUCT_NUMBER]
				      ,a.[PRODUCT_DESCRIPTION]
				      ,a.[LOCATION_CODE]
				      ,a.[LOCATION_NAME]
				      ,a.[CELL_ZONE_LEAD]
				      ,a.[QUANTITY_ON_HOLD]
				      ,a.[MACHINE_NUMBER]
				      ,a.[MACHINE_LOCATION]
				      ,a.[FIRST_PERSON_RESPONSIBLE]
				      ,a.[SECOND_PERSON_RESPONSIBLE]
				      ,a.[NON_CONFORMANCE_NOTES]
				      ,a.[IN_TRAINING]
				      ,a.[INVESTIGATION_COMMENTS]
				      ,a.[CORRECTIVE_ACTION_TAKEN_COMMENTS]
				      ,a.[RE_WORK_COMPLETED_BY_DATE]
				      ,a.[RE_WORK_INSPECTED_DATE]
				      ,a.[RE_WORK_COMPLETED_BY]
				      ,a.[RE_WORK_INSPECTED_BY]
				      ,a.[USE_AS_IS_QTY]
				      ,a.[SCRAP_PARTS_QTY]
				      ,a.[REPAIRED_PARTS_QTY]
				      ,a.[OTHER_QTY_PLEASE_EXPLAIN_QTY]
				      ,a.[TOTAL_UNITS_INSPECTED_QTY]
				      ,a.[USE_AS_IS_COMMENTS]
				      ,a.[SCRAP_PARTS_COMMENTS]
				      ,a.[REPAIRED_PARTS_COMMENTS]
				      ,a.[OTHER_PLEASE_EXPLAIN_COMMENTS]
				      ,a.[TOTAL_UNITS_INSPECTED_COMMENTS]
				      ,a.[TOTAL_QTY_INSPECTED]
					  ,a.[Fingerprint]
				)
				--Existing records that have changed are expired
				WHEN MATCHED AND a.Fingerprint<>b.Fingerprint
				THEN UPDATE SET b.EndDate=GETDATE()
					,b.CurrentRecord=0
				OUTPUT 
					   a.[INDEX_ID]
				      ,a.[HOLD_TAG_NUMBER]
				      ,a.[DATE]
				      ,a.[INSPECTOR_NAME]
				      ,a.[SHIFT]
				      ,a.[PRODUCT_NUMBER]
				      ,a.[PRODUCT_DESCRIPTION]
				      ,a.[LOCATION_CODE]
				      ,a.[LOCATION_NAME]
				      ,a.[CELL_ZONE_LEAD]
				      ,a.[QUANTITY_ON_HOLD]
				      ,a.[MACHINE_NUMBER]
				      ,a.[MACHINE_LOCATION]
				      ,a.[FIRST_PERSON_RESPONSIBLE]
				      ,a.[SECOND_PERSON_RESPONSIBLE]
				      ,a.[NON_CONFORMANCE_NOTES]
				      ,a.[IN_TRAINING]
				      ,a.[INVESTIGATION_COMMENTS]
				      ,a.[CORRECTIVE_ACTION_TAKEN_COMMENTS]
				      ,a.[RE_WORK_COMPLETED_BY_DATE]
				      ,a.[RE_WORK_INSPECTED_DATE]
				      ,a.[RE_WORK_COMPLETED_BY]
				      ,a.[RE_WORK_INSPECTED_BY]
				      ,a.[USE_AS_IS_QTY]
				      ,a.[SCRAP_PARTS_QTY]
				      ,a.[REPAIRED_PARTS_QTY]
				      ,a.[OTHER_QTY_PLEASE_EXPLAIN_QTY]
				      ,a.[TOTAL_UNITS_INSPECTED_QTY]
				      ,a.[USE_AS_IS_COMMENTS]
				      ,a.[SCRAP_PARTS_COMMENTS]
				      ,a.[REPAIRED_PARTS_COMMENTS]
				      ,a.[OTHER_PLEASE_EXPLAIN_COMMENTS]
				      ,a.[TOTAL_UNITS_INSPECTED_COMMENTS]
				      ,a.[TOTAL_QTY_INSPECTED]
					  ,a.[Fingerprint]
					  ,$Action AS Action
			) a
			WHERE Action = 'Update'
			;

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()

	DROP TABLE #QUALITY_HOLD_TAG_HEADER

END
GO
