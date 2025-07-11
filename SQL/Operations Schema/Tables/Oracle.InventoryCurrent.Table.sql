USE [Operations]
GO
/****** Object:  Table [Oracle].[InventoryCurrent]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Oracle].[InventoryCurrent](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[INVENTORY_ITEM_ID] [float] NOT NULL,
	[ORGANIZATION_ID] [float] NOT NULL,
	[DATE_RECEIVED] [datetime2](7) NULL,
	[LAST_UPDATE_DATE] [datetime2](7) NOT NULL,
	[LAST_UPDATED_BY] [float] NOT NULL,
	[CREATION_DATE] [datetime2](7) NOT NULL,
	[CREATED_BY] [float] NOT NULL,
	[LAST_UPDATE_LOGIN] [float] NULL,
	[PRIMARY_TRANSACTION_QUANTITY] [float] NOT NULL,
	[SUBINVENTORY_CODE] [nvarchar](10) NOT NULL,
	[REVISION] [nvarchar](3) NULL,
	[LOCATOR_ID] [float] NULL,
	[CREATE_TRANSACTION_ID] [float] NULL,
	[UPDATE_TRANSACTION_ID] [float] NULL,
	[LOT_NUMBER] [nvarchar](80) NULL,
	[ORIG_DATE_RECEIVED] [datetime2](7) NULL,
	[COST_GROUP_ID] [float] NULL,
	[CONTAINERIZED_FLAG] [float] NULL,
	[PROJECT_ID] [float] NULL,
	[TASK_ID] [float] NULL,
	[ONHAND_QUANTITIES_ID] [float] NOT NULL,
	[ORGANIZATION_TYPE] [float] NOT NULL,
	[OWNING_ORGANIZATION_ID] [float] NOT NULL,
	[OWNING_TP_TYPE] [float] NOT NULL,
	[PLANNING_ORGANIZATION_ID] [float] NOT NULL,
	[PLANNING_TP_TYPE] [float] NOT NULL,
	[TRANSACTION_UOM_CODE] [nvarchar](3) NOT NULL,
	[TRANSACTION_QUANTITY] [float] NOT NULL,
	[SECONDARY_UOM_CODE] [nvarchar](3) NULL,
	[SECONDARY_TRANSACTION_QUANTITY] [float] NULL,
	[IS_CONSIGNED] [float] NOT NULL,
	[LPN_ID] [float] NULL,
	[STATUS_ID] [float] NULL,
	[Fingerprint] [varchar](32) NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NULL,
	[CurrentRecord] [bit] NOT NULL,
 CONSTRAINT [PK_InventoryCurrent] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Oracle].[InventoryCurrent] ADD  DEFAULT (getdate()) FOR [StartDate]
GO
ALTER TABLE [Oracle].[InventoryCurrent] ADD  DEFAULT ((1)) FOR [CurrentRecord]
GO
