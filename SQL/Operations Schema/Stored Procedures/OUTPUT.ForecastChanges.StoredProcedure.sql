USE [Operations]
GO
/****** Object:  StoredProcedure [OUTPUT].[ForecastChanges]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [OUTPUT].[ForecastChanges]
	@startDate DATE = NULL,
	@endDate DATE = NULL
AS BEGIN

	SET @startDate = ISNULL(@startDate,(SELECT DATEADD(WEEK,-1,DATEADD(DAY, 1-DATEPART(WEEKDAY, CAST(GETDATE() AS DATE)), CAST(GETDATE() AS DATE)))))
	SET @endDate = ISNULL(@endDate,(SELECT DATEADD(DAY, 1-DATEPART(WEEKDAY, CAST(GETDATE() AS DATE)), CAST(GETDATE() AS DATE))))

	SELECT ROW_NUMBER() OVER (PARTITION BY LTRIM(RTRIM(UPPER(CustomerID))), LTRIM(RTRIM(UPPER(PartID))), FC_Week, Type ORDER BY FC_Year, FC_Week) AS RowNum
		, ChangeDate, User_Added AS UserName
		, FC_Year*100+FC_Month AS FC_Period
		, FC_Year, FC_Month, FC_Week
		, LTRIM(RTRIM(UPPER(CustomerID))) AS DemandClass
		, LTRIM(RTRIM(UPPER(PartID))) AS SKU ,ProductName AS SKUName
		, Orig_Qty, New_Qty, New_Qty - Orig_Qty AS Var_Qty 
	FROM Step2.AuditLog al
		LEFT JOIN dbo.DimProductMaster pm ON al.PartID = pm.ProductKey
	WHERE Date_Added BETWEEN @startDate AND @endDate

END
GO
