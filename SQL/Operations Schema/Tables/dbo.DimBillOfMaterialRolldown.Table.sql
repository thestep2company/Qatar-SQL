USE [Operations]
GO
/****** Object:  Table [dbo].[DimBillOfMaterialRolldown]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimBillOfMaterialRolldown](
	[SKU] [nvarchar](6) NULL,
	[SKU Name] [nvarchar](300) NULL,
	[PARENT_SKU] [nvarchar](40) NULL,
	[CHILD_SKU] [nvarchar](40) NULL,
	[Component Name] [nvarchar](300) NULL,
	[PARENT_PATH] [nvarchar](4000) NULL,
	[CHILD_PATH] [nvarchar](4000) NULL,
	[MATH] [nvarchar](4000) NULL,
	[ITEM_NUM] [float] NULL,
	[LEVEL] [float] NULL,
	[ITEM_TYPE] [nvarchar](30) NULL,
	[COMPONENT_QUANTITY] [float] NULL,
	[PRIOR_QUANTITY] [float] NULL,
	[ROLLDOWN] [float] NULL,
	[ISLEAF] [float] NULL,
	[Effectivity_Date] [datetime2](7) NULL,
	[Disable_Date] [datetime2](7) NULL,
	[FGItemCost] [float] NULL,
	[FGMaterialCost] [float] NULL,
	[Country of Origin] [nvarchar](240) NULL,
	[ItemCost] [float] NULL,
	[MaterialCost] [float] NULL,
	[MaterialOverheadCost] [float] NULL,
	[ResourceCost] [float] NULL,
	[OutsideProcessingCost] [float] NULL,
	[OverheadCost] [float] NULL,
	[RolldownItemCost] [float] NULL,
	[ChinaItemCost] [float] NULL,
	[RolldownMaterialCost] [float] NULL,
	[ChinaMaterialCost] [float] NULL,
	[LastPurchased] [date] NULL,
	[SalesForecast] [float] NULL,
	[UnitForecast] [float] NULL,
	[SalesActual] [money] NULL,
	[UnitActual] [int] NULL
) ON [PRIMARY]
GO
