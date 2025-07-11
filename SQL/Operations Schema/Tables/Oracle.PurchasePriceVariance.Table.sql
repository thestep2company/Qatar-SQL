USE [Operations]
GO
/****** Object:  Table [Oracle].[PurchasePriceVariance]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Oracle].[PurchasePriceVariance](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Source] [int] NOT NULL,
	[ORG_CODE] [nvarchar](3) NULL,
	[ORG_NAME] [nvarchar](240) NOT NULL,
	[VENDOR_NAME] [nvarchar](240) NULL,
	[PO_NUMBER] [nvarchar](20) NOT NULL,
	[PO_LINE_NUMBER] [float] NOT NULL,
	[SHIPMENT_LINE_NUMBER] [float] NOT NULL,
	[PART_CLASS] [nvarchar](240) NULL,
	[ITEM] [nvarchar](40) NULL,
	[ITEM_DESC] [nvarchar](240) NULL,
	[PLL_ORDER_QTY] [float] NULL,
	[PLL_QTY_REC] [float] NULL,
	[PLL_QTY_BILLED] [float] NULL,
	[PLL_AMT_BILLED] [float] NULL,
	[POL_UNIT_PRICE] [float] NULL,
	[STD_COST] [float] NULL,
	[MOH_UNIT_COST] [float] NULL,
	[COST_VARIANCE] [float] NULL,
	[CUR_STD_COST] [float] NULL,
	[ZERO_COST_IND] [nvarchar](1) NULL,
	[TX_QTY] [float] NULL,
	[TX_EXT_VAR] [float] NULL,
	[TX_ID] [float] NOT NULL,
	[INV_ITEM_ID] [float] NOT NULL,
	[ORG_ID] [float] NULL,
	[Fingerprint] [varchar](32) NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NULL,
	[CurrentRecord] [bit] NOT NULL,
	[TX_DATE] [date] NULL,
 CONSTRAINT [PK_PurchasePriceVariance] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Oracle].[PurchasePriceVariance] ADD  DEFAULT (getdate()) FOR [StartDate]
GO
ALTER TABLE [Oracle].[PurchasePriceVariance] ADD  DEFAULT ((1)) FOR [CurrentRecord]
GO
