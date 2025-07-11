USE [Operations]
GO
/****** Object:  Table [xref].[COGSLookup]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [xref].[COGSLookup](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[TRX_NUMBER] [nvarchar](20) NOT NULL,
	[SKU] [nvarchar](30) NOT NULL,
	[Qty] [int] NULL,
	[Sales] [money] NULL,
	[LookupCOGS] [money] NULL,
	[LookupUnitCOGS] [money] NULL,
	[GLCOGS] [money] NULL,
	[GLUnitCOGS] [money] NULL,
	[LookupMaterial] [money] NULL,
	[LookupMaterialOH] [money] NULL,
	[LookupResourceCost] [money] NULL,
	[LookupOutsideProcessing] [money] NULL,
	[LookupOverhead] [money] NULL,
	[GLMaterial] [money] NULL,
	[GLMaterialOH] [money] NULL,
	[GLResourceCost] [money] NULL,
	[GLOutsideProcessing] [money] NULL,
	[GLOverhead] [money] NULL,
	[GLUnitMaterial] [money] NULL,
	[GLUnitMaterialOH] [money] NULL,
	[GLUnitResourceCost] [money] NULL,
	[GLUnitOutsideProcessing] [money] NULL,
	[GLUnitOverhead] [money] NULL,
	[LookupUnitMaterial] [money] NULL,
	[LookupUnitMaterialOH] [money] NULL,
	[LookupUnitResourceCost] [money] NULL,
	[LookupUnitOutsideProcessing] [money] NULL,
	[LookupUnitOverhead] [money] NULL,
 CONSTRAINT [PK_COGSLookup] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_OrderSKU] UNIQUE NONCLUSTERED 
(
	[TRX_NUMBER] ASC,
	[SKU] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
