USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[Reload_DimPricingDistribution]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Reload_DimPricingDistribution] 
AS BEGIN
	TRUNCATE TABLE dbo.DimPricingDistribution		
	
	SET IDENTITY_INSERT dbo.DimPricingDistribution ON
	INSERT INTO dbo.DimPricingDistribution (
	   [Pricing ID]
      ,[Pricing Key]
      ,[Pricing Nickle]
      ,[Pricing Nickel Sort]
      ,[Pricing Dime]
      ,[Pricing Dime Sort]
      ,[Pricing Quarter]
      ,[Pricing Quarter Sort]
      ,[Pricing Half]
      ,[Pricing Half Sort]
      ,[Pricing One]
      ,[Pricing One Sort]
      ,[Pricing Five]
      ,[Pricing Five Sort]
      ,[Pricing Ten]
      ,[Pricing Ten Sort]
      ,[Pricing Twenty]
      ,[Pricing Twenty Sort]
      ,[Pricing Fifty]
      ,[Pricing Fifty Sort]
      ,[Pricing Hundred]
      ,[Pricing Hundred Sort]
	)
	SELECT * FROM Dim.PricingDistribution OPTION (MAXRECURSION 0)
END
GO
