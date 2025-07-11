USE [Operations]
GO
/****** Object:  Table [dbo].[DimPricingDistribution]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimPricingDistribution](
	[Pricing ID] [bigint] IDENTITY(1,1) NOT NULL,
	[Pricing Key] [numeric](6, 2) NULL,
	[Pricing Nickle] [nvarchar](40) NULL,
	[Pricing Nickel Sort] [numeric](6, 2) NULL,
	[Pricing Dime] [nvarchar](40) NULL,
	[Pricing Dime Sort] [numeric](6, 2) NULL,
	[Pricing Quarter] [nvarchar](40) NULL,
	[Pricing Quarter Sort] [numeric](6, 2) NULL,
	[Pricing Half] [nvarchar](40) NULL,
	[Pricing Half Sort] [numeric](6, 2) NULL,
	[Pricing One] [nvarchar](40) NULL,
	[Pricing One Sort] [numeric](6, 2) NULL,
	[Pricing Five] [nvarchar](40) NULL,
	[Pricing Five Sort] [numeric](6, 2) NULL,
	[Pricing Ten] [nvarchar](40) NULL,
	[Pricing Ten Sort] [numeric](6, 2) NULL,
	[Pricing Twenty] [nvarchar](40) NULL,
	[Pricing Twenty Sort] [numeric](6, 2) NULL,
	[Pricing Fifty] [nvarchar](40) NULL,
	[Pricing Fifty Sort] [numeric](6, 2) NULL,
	[Pricing Hundred] [nvarchar](40) NULL,
	[Pricing Hundred Sort] [numeric](6, 2) NULL,
 CONSTRAINT [PK_DimPricingDistribution] PRIMARY KEY CLUSTERED 
(
	[Pricing ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
