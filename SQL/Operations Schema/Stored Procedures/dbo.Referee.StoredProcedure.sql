USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[Referee]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Referee] AS BEGIN

	DECLARE @job VARCHAR(50), @startDate VARCHAR(30), @duration INT

	SELECT 
		@job = N''+ CAST(jobs.name AS VARCHAR(50))
		,@startDate = CONVERT(VARCHAR(30),ja.start_execution_date,121)
		,@duration = [Duration_secs]
	FROM msdb.dbo.sysjobs jobs
		LEFT JOIN (
			SELECT *
			FROM msdb.dbo.sysjobactivity
			WHERE session_id = (
				SELECT MAX(session_id) FROM msdb.dbo.syssessions) AND
				start_execution_date IS NOT NULL AND
				stop_execution_date IS NULL
		) AS ja ON ja.job_id = jobs.job_id
	CROSS APPLY (SELECT DATEDIFF(ss,ja.start_execution_date,GETDATE()) AS [Duration_secs]) AS ca1
	WHERE jobs.name IN ('Production Diff','Sales - Orders') AND Duration_secs > 300

	DECLARE @sql VARCHAR(MAX)

	SET @sql = 
	'msdb.dbo.sp_send_dbmail  
		@profile_name = ''SQL Mail'',  
		@recipients = ''daustin@step2.net'',
		@body = ''' + CAST(@duration AS VARCHAR(10)) + ' seconds elapsed'',
		@subject = ''' + @job + ' has been running since ' + @startDate + ';'''
	
	EXEC(@sql)
END
GO
