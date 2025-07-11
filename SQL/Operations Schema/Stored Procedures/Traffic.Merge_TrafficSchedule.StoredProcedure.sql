USE [Operations]
GO
/****** Object:  StoredProcedure [Traffic].[Merge_TrafficSchedule]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [Traffic].[Merge_TrafficSchedule] 
AS BEGIN

	CREATE TABLE #Schedule (
		[RECNUM] [int] NOT NULL,
		[DATE] [smalldatetime] NOT NULL,
		[STORE] [char](2) NULL,
		[TIME_SLOT] [char](4) NULL,
		[TRAFFIC_INITIALS] [char](3) NULL,
		[SHIPPING_INITIALS] [char](3) NULL,
		[PICK_UP_NUMBER] [char](25) NULL,
		[CARRIER] [char](50) NULL,
		[CUSTOMER] [char](50) NULL,
		[DESTINATION] [char](50) NULL,
		[NUM_OF_CARTONS] [int] NULL,
		[NUM_OF_SKU] [int] NULL,
		[LABELS] [char](1) NULL,
		[STATUS] [char](20) NULL,
		[SPECIAL_INSTRUCTIONS] [char](255) NULL,
		[START_TIME] [char](4) NULL,
		[END_TIME] [char](4) NULL,
		[USER_ID] [char](25) NULL,
		[SO_ID] [char](16) NULL,
		[Fingerprint] [varchar](32) NULL
	)

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Download', GETDATE()

	INSERT INTO #Schedule
	SELECT [RECNUM]
      ,[DATE]
      ,[STORE]
      ,[TIME_SLOT]
      ,[TRAFFIC_INITIALS]
      ,[SHIPPING_INITIALS]
      ,[PICK_UP_NUMBER]
      ,[CARRIER]
      ,[CUSTOMER]
      ,[DESTINATION]
      ,[NUM_OF_CARTONS]
      ,[NUM_OF_SKU]
      ,[LABELS]
      ,[STATUS]
      ,[SPECIAL_INSTRUCTIONS]
      ,[START_TIME]
      ,[END_TIME]
      ,[USER_ID]
      ,[SO_ID]
	  ,'XXX'
	FROM OPENQUERY(FINDLAND,'
	SELECT [RECNUM]
		  ,[DATE]
		  ,[STORE]
		  ,[TIME_SLOT]
		  ,[TRAFFIC_INITIALS]
		  ,[SHIPPING_INITIALS]
		  ,[PICK_UP_NUMBER]
		  ,[CARRIER]
		  ,[CUSTOMER]
		  ,[DESTINATION]
		  ,[NUM_OF_CARTONS]
		  ,[NUM_OF_SKU]
		  ,[LABELS]
		  ,[STATUS]
		  ,[SPECIAL_INSTRUCTIONS]
		  ,[START_TIME]
		  ,[END_TIME]
		  ,[USER_ID]
		  ,[SO_ID]
	  FROM [TRAFFIC].[dbo].[TRAFFIC_SCHEDULE]
	  WHERE ISNULL(SO_ID,'''') <> '''' AND DATE >= ''2019-01-01''
	')

	/*
		DECLARE @columnList VARCHAR(MAX) = dbo.getHashField ('Schedule','traffic') SELECT @columnList
	*/

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Fingerprint', GETDATE()

	UPDATE #Schedule
	SET Fingerprint = 
		SUBSTRING(LOWER(CONVERT(VARCHAR(32),HASHBYTES('MD5',
			--replace @columnList result here
			  CAST(ISNULL([RECNUM],'0') AS VARCHAR(100)) +  CAST(ISNULL([DATE],'') AS VARCHAR(100)) +  CAST(ISNULL([STORE],'') AS VARCHAR(2)) +  CAST(ISNULL([TIME_SLOT],'') AS VARCHAR(4)) +  CAST(ISNULL([TRAFFIC_INITIALS],'') AS VARCHAR(3)) +  CAST(ISNULL([SHIPPING_INITIALS],'') AS VARCHAR(3)) +  CAST(ISNULL([PICK_UP_NUMBER],'') AS VARCHAR(25)) +  CAST(ISNULL([CARRIER],'') AS VARCHAR(50)) +  CAST(ISNULL([CUSTOMER],'') AS VARCHAR(50)) +  CAST(ISNULL([DESTINATION],'') AS VARCHAR(50)) +  CAST(ISNULL([NUM_OF_CARTONS],'0') AS VARCHAR(100)) +  CAST(ISNULL([NUM_OF_SKU],'0') AS VARCHAR(100)) +  CAST(ISNULL([LABELS],'') AS VARCHAR(1)) +  CAST(ISNULL([STATUS],'') AS VARCHAR(20)) +  CAST(ISNULL([SPECIAL_INSTRUCTIONS],'') AS VARCHAR(255)) +  CAST(ISNULL([START_TIME],'') AS VARCHAR(4)) +  CAST(ISNULL([END_TIME],'') AS VARCHAR(4)) +  CAST(ISNULL([USER_ID],'') AS VARCHAR(25)) +  CAST(ISNULL([SO_ID],'') AS VARCHAR(16)) 
		),1)),3,32);

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Merge', GETDATE()

	INSERT INTO traffic.[Schedule] (
			[RECNUM]
		  ,[DATE]
		  ,[STORE]
		  ,[TIME_SLOT]
		  ,[TRAFFIC_INITIALS]
		  ,[SHIPPING_INITIALS]
		  ,[PICK_UP_NUMBER]
		  ,[CARRIER]
		  ,[CUSTOMER]
		  ,[DESTINATION]
		  ,[NUM_OF_CARTONS]
		  ,[NUM_OF_SKU]
		  ,[LABELS]
		  ,[STATUS]
		  ,[SPECIAL_INSTRUCTIONS]
		  ,[START_TIME]
		  ,[END_TIME]
		  ,[USER_ID]
		  ,[SO_ID]
		  ,[Fingerprint]
		)
			SELECT 
				   a.[RECNUM]
				  ,a.[DATE]
				  ,a.[STORE]
				  ,a.[TIME_SLOT]
				  ,a.[TRAFFIC_INITIALS]
				  ,a.[SHIPPING_INITIALS]
				  ,a.[PICK_UP_NUMBER]
				  ,a.[CARRIER]
				  ,a.[CUSTOMER]
				  ,a.[DESTINATION]
				  ,a.[NUM_OF_CARTONS]
				  ,a.[NUM_OF_SKU]
				  ,a.[LABELS]
				  ,a.[STATUS]
				  ,a.[SPECIAL_INSTRUCTIONS]
				  ,a.[START_TIME]
				  ,a.[END_TIME]
				  ,a.[USER_ID]
				  ,a.[SO_ID]
				  ,a.[Fingerprint]
			FROM (
				MERGE traffic.[Schedule] b
				USING (SELECT * FROM #schedule) a
				ON a.[RECNUM] = b.[RECNUM] AND b.CurrentRecord = 1 --swap with business key of table
				WHEN NOT MATCHED --BY TARGET 
				THEN INSERT (
						[RECNUM]
					  ,[DATE]
					  ,[STORE]
					  ,[TIME_SLOT]
					  ,[TRAFFIC_INITIALS]
					  ,[SHIPPING_INITIALS]
					  ,[PICK_UP_NUMBER]
					  ,[CARRIER]
					  ,[CUSTOMER]
					  ,[DESTINATION]
					  ,[NUM_OF_CARTONS]
					  ,[NUM_OF_SKU]
					  ,[LABELS]
					  ,[STATUS]
					  ,[SPECIAL_INSTRUCTIONS]
					  ,[START_TIME]
					  ,[END_TIME]
					  ,[USER_ID]
					  ,[SO_ID]		
					  ,[Fingerprint]
				)
				VALUES (
					  a.[RECNUM]
					  ,a.[DATE]
					  ,a.[STORE]
					  ,a.[TIME_SLOT]
					  ,a.[TRAFFIC_INITIALS]
					  ,a.[SHIPPING_INITIALS]
					  ,a.[PICK_UP_NUMBER]
					  ,a.[CARRIER]
					  ,a.[CUSTOMER]
					  ,a.[DESTINATION]
					  ,a.[NUM_OF_CARTONS]
					  ,a.[NUM_OF_SKU]
					  ,a.[LABELS]
					  ,a.[STATUS]
					  ,a.[SPECIAL_INSTRUCTIONS]
					  ,a.[START_TIME]
					  ,a.[END_TIME]
					  ,a.[USER_ID]
					  ,a.[SO_ID]
					  ,a.[Fingerprint]
				)
				--Existing records that have changed are expired
				WHEN MATCHED AND a.Fingerprint<>b.Fingerprint
				THEN UPDATE SET b.EndDate=GETDATE()
					,b.CurrentRecord=0
				OUTPUT 
					  a.[RECNUM]
					  ,a.[DATE]
					  ,a.[STORE]
					  ,a.[TIME_SLOT]
					  ,a.[TRAFFIC_INITIALS]
					  ,a.[SHIPPING_INITIALS]
					  ,a.[PICK_UP_NUMBER]
					  ,a.[CARRIER]
					  ,a.[CUSTOMER]
					  ,a.[DESTINATION]
					  ,a.[NUM_OF_CARTONS]
					  ,a.[NUM_OF_SKU]
					  ,a.[LABELS]
					  ,a.[STATUS]
					  ,a.[SPECIAL_INSTRUCTIONS]
					  ,a.[START_TIME]
					  ,a.[END_TIME]
					  ,a.[USER_ID]
					  ,a.[SO_ID]
					  ,a.[Fingerprint]
					  ,$Action AS Action
			) a
			WHERE Action = 'Update'
			;

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()

	DROP TABLE #Schedule

END
GO
