USE [Operations]
GO
/****** Object:  StoredProcedure [OUTPUT].[PIMData]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [OUTPUT].[PIMData] AS BEGIN
	DROP TABLE IF EXISTS dbo.PimProductMaster
	SELECT * INTO dbo.PimProductMaster FROM [PIM].[ProductMaster]
	SELECT * FROM dbo.PIMProductMaster

	DROP TABLE IF EXISTS dbo.PimCarton
	SELECT * INTO dbo.PimCarton FROM Output.PimCartonPass2
	SELECT * FROM dbo.PimCarton ORDER BY SellingUnit
END
GO
