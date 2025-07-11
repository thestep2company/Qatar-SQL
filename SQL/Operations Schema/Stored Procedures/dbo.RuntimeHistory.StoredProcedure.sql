USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[RuntimeHistory]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[RuntimeHistory]
AS BEGIN

	WITH CTE AS (
		SELECT ROW_NUMBER() OVER (ORDER BY StartDate) AS RowNum, StoredProcedure, Step, StartDate 
		FROM  dbo.ETLLog WHERE StoredProcedure = 'Merge_INV_MSC_ORDERS_V' 
	)
	SELECT a.*, b.StartDate AS EndDate, DATEDIFF(SECOND,a.StartDate,b.StartDate) AS RunTimeSec
	FROM CTE a
		INNER JOIN CTE b ON a.RowNum = b.RowNum - 1
	WHERE b.Step NOT LIKE '%Download%'

END

GO
