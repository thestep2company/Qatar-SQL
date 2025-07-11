USE [Operations]
GO
/****** Object:  StoredProcedure [OUTPUT].[JobRunTime]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [OUTPUT].[JobRunTime] 
	@jobName VARCHAR(100)
	,@stepName VARCHAR(100) = NULL
AS BEGIN
	WITH CTE AS (
		SELECT ROW_NUMBER() OVER (ORDER BY ID) AS RowID, * 
		FROM dbo.ETLLog 
		WHERE SToredProcedure = @jobName 
		--'Merge_INV_MSC_ORDERS_V'
	)
	SELECT a.*, DATEDIFF(SECOND,a.StartDate,b.StartDate) AS RunTime
	FROM CTE a 
		INNER JOIN CTE b ON a.RowID + 1 = b.RowID
	WHERE a.Step <> 'Done'
		AND a.Step = ISNULL(@stepName,a.Step)
	ORDER BY a.StartDate DESC
END
GO
