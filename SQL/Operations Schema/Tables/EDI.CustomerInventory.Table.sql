USE [Operations]
GO
/****** Object:  Table [EDI].[CustomerInventory]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [EDI].[CustomerInventory](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[RecNum] [decimal](8, 0) NOT NULL,
	[Active] [varchar](1) NOT NULL,
	[AccountNumber] [varchar](50) NOT NULL,
	[PartID] [varchar](50) NOT NULL,
	[PartDescription] [varchar](240) NOT NULL,
	[UPCCode] [varchar](50) NOT NULL,
	[CustomerPartID] [varchar](50) NOT NULL,
	[CustomerSKU] [varchar](50) NULL,
	[Quantity] [numeric](18, 0) NOT NULL,
	[UnitPrice] [numeric](18, 6) NOT NULL,
	[EffectiveDate] [datetime] NULL,
	[Discontinuedate] [datetime] NULL,
	[Discontinued] [varchar](50) NULL,
	[CustomerWarehouseCode] [varchar](50) NULL,
	[Fingerprint] [varchar](32) NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NULL,
	[CurrentRecord] [bit] NOT NULL,
	[InventoryItemID] [varchar](50) NULL,
	[OrgCode] [varchar](50) NULL,
	[MinimumDaysShip] [decimal](10, 0) NULL,
	[MaximumDaysShip] [decimal](10, 0) NULL,
	[CheckOpenOrders] [varchar](1) NULL,
	[CustomerQtyConversion] [varchar](1) NULL,
	[ForecastQty] [decimal](10, 0) NULL,
	[ForecastPercent] [decimal](18, 6) NULL,
	[UseManualQty] [varchar](1) NULL,
	[DemandClass] [varchar](50) NULL,
	[ForecastPartID] [varchar](50) NULL,
	[LastSendQty] [decimal](18, 0) NULL,
	[LastSendDate] [datetime] NULL,
 CONSTRAINT [PK_CustomerInventory] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [EDI].[CustomerInventory] ADD  DEFAULT (getdate()) FOR [StartDate]
GO
ALTER TABLE [EDI].[CustomerInventory] ADD  DEFAULT ((1)) FOR [CurrentRecord]
GO
