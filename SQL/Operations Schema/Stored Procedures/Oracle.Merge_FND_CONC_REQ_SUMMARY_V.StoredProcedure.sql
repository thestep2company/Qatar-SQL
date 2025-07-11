USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[Merge_FND_CONC_REQ_SUMMARY_V]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Oracle].[Merge_FND_CONC_REQ_SUMMARY_V] AS BEGIN

	DROP TABLE IF EXISTS #concurrentRequests

	CREATE TABLE #concurrentRequests
	(
		[REQUEST_ID] [INT] NOT NULL,
		[PROGRAM] [nvarchar](483) NULL,
		[DESCRIPTION] [nvarchar](240) NULL,
		[REQUESTED_BY] [numeric](15, 0) NOT NULL,
		[REQUEST_DATE] [datetime2](7) NOT NULL,
		[ACTUAL_START_DATE] [datetime2](7) NULL,
		[ACTUAL_COMPLETION_DATE] [datetime2](7) NULL,
		[RUN_TIME_MIN] [float] NULL,
		[COMPLETION_TEXT] [nvarchar](240) NULL,
		[PHASE_CODE] [nvarchar](1) NOT NULL,
		[REQUESTED_START_DATE] [nvarchar](1) NOT NULL,
		[Meridiem] [varchar](2) NOT NULL
	) ON [PRIMARY]

	INSERT INTO #concurrentRequests
	SELECT * 
		,CASE WHEN DATEPART(HOUR,ACTUAL_COMPLETION_DATE) < 12 THEN 'AM' ELSE 'PM' END Meridiem
	FROM OPENQUERY(ASCP,'
		select 
			 fcrsv.REQUEST_ID
			,fcrsv.PROGRAM
			,fcrsv.description 
			,fcrsv.REQUESTED_BY
			,fcrsv.REQUEST_DATE
			,fcrsv.ACTUAL_START_DATE
			,fcrsv.ACTUAL_COMPLETION_DATE
			,round((fcrsv.ACTUAL_COMPLETION_DATE - fcrsv.ACTUAL_START_DATE)*(24)*60,2) as run_time_min	
			,fcrsv.COMPLETION_TEXT
			,fcrsv.PHASE_CODE
			,fcrsv.STATUS_CODE
			REQUESTED_START_DATE
		from FND_CONC_REQ_SUMMARY_V fcrsv
		where 1=1 
			and fcrsv.description  IN (''XX Refresh Materialized Views(140)'') --, ''XXSTEP2 Planning Request Set All'')
			and fcrsv.requested_by = 1534
		order by REQUEST_ID --fcrsv.actual_start_date -- desc
	')

	--UPDATE
	UPDATE crsv 
	SET PROGRAM = cr.PROGRAM	
		,DESCRIPTION = cr.DESCRIPTION
		,REQUESTED_BY = cr.REQUESTED_BY
		,REQUEST_DATE = cr.REQUEST_DATE
		,ACTUAL_START_DATE = cr.ACTUAL_START_DATE
		,ACTUAL_COMPLETION_DATE = cr.ACTUAL_COMPLETION_DATE
		,RUN_TIME_MIN = cr.RUN_TIME_MIN
		,COMPLETION_TEXT = cr.COMPLETION_TEXT
		,PHASE_CODE = cr.PHASE_CODE
		,REQUESTED_START_DATE = cr.REQUESTED_START_DATE
		,Meridiem = cr.Meridiem
	FROM #concurrentRequests cr
		INNER JOIN Oracle.FND_CONC_REQ_SUMMARY_V crsv ON cr.REQUEST_ID = crsv.REQUEST_ID
	WHERE crsv.RUN_TIME_MIN = 0 OR crsv.PHASE_CODE = 'R'

	INSERT INTO Oracle.FND_CONC_REQ_SUMMARY_V
	SELECT cr.*, GETDATE() FROM #concurrentRequests cr
		LEFT JOIN Oracle.FND_CONC_REQ_SUMMARY_V crsv ON cr.REQUEST_ID = crsv.REQUEST_ID
	WHERE crsv.REQUEST_ID IS NULL

END
GO
