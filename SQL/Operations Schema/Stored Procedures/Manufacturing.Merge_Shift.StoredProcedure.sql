USE [Operations]
GO
/****** Object:  StoredProcedure [Manufacturing].[Merge_Shift]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Manufacturing].[Merge_Shift] AS BEGIN

	CREATE TABLE #shift (
		Shift_ID INT,
		Org VARCHAR(3),
		Start_Date_Time DateTime,
		End_Date_Time DateTime,
		Shift VARCHAR(1),
		Day_Of_Week VARCHAR(8),
		Fingerprint VARCHAR(32)
	)

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Oracle Download', GETDATE()

	INSERT INTO #shift
	SELECT 
		Shift_ID,
		Org,
		Start_Date_Time,
		End_Date_Time,
		Shift,
		Day_Of_Week, 
		'XXX' 
	FROM OPENQUERY(FINDLAND,'SELECT * FROM Manufacturing.dbo.Shifts')

	/*
		DECLARE @columnList VARCHAR(MAX) = dbo.getHashField ('Shift','Manufacturing') SELECT @columnList
	*/

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Fingerprint', GETDATE()

	UPDATE #Shift
	SET Fingerprint = 
		SUBSTRING(LOWER(CONVERT(VARCHAR(32),HASHBYTES('MD5',
			--replace @columnList result here
				CAST(ISNULL(Shift_ID,'0') AS VARCHAR(100)) +  CAST(ISNULL(Org,'') AS VARCHAR(3)) +  CAST(ISNULL(Start_Date_Time,'') AS VARCHAR(100)) +  CAST(ISNULL(End_Date_Time,'') AS VARCHAR(100)) +  CAST(ISNULL(Shift,'') AS VARCHAR(1)) +  CAST(ISNULL(Day_Of_Week,'') AS VARCHAR(8)) 
		),1)),3,32);

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Merge', GETDATE()

	INSERT INTO Manufacturing.Shift (
				[Shift_ID]
				,[Org]
				,[Start_Date_Time]
				,[End_Date_Time]
				,[Shift]
				,[Day_Of_Week]
				,[Fingerprint]
	)
		SELECT 
				a.[Shift_ID]
				,a.[Org]
				,a.[Start_Date_Time]
				,a.[End_Date_Time]
				,a.[Shift]
				,a.[Day_Of_Week]
				,a.[Fingerprint]
		FROM (
			MERGE Manufacturing.Shift b
			USING (SELECT * FROM #Shift) a
			ON a.Shift_ID = b.Shift_ID AND b.CurrentRecord = 1 --swap with business key of table
			WHEN NOT MATCHED --BY TARGET 
			THEN INSERT (
				[Shift_ID]
				,[Org]
				,[Start_Date_Time]
				,[End_Date_Time]
				,[Shift]
				,[Day_Of_Week]
				,[Fingerprint]
			)
			VALUES (
				a.[Shift_ID]
				,a.[Org]
				,a.[Start_Date_Time]
				,a.[End_Date_Time]
				,a.[Shift]
				,a.[Day_Of_Week]
				,a.[Fingerprint]
			)
			--Existing records that have changed are expired
			WHEN MATCHED AND a.Fingerprint<>b.Fingerprint
			THEN UPDATE SET b.EndDate=GETDATE()
				,b.CurrentRecord=0
			OUTPUT 
						a.[Shift_ID]
						,a.[Org]
						,a.[Start_Date_Time]
						,a.[End_Date_Time]
						,a.[Shift]
						,a.[Day_Of_Week]
						,a.[Fingerprint]
					,$Action AS Action
		) a
		WHERE Action = 'Update'
		;

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()

	DROP TABLE #shift

END

GO
