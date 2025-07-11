USE [Operations]
GO
/****** Object:  Table [dbo].[FactSupplyChainPlanBase]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactSupplyChainPlanBase](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[PLAN_ID] [float] NULL,
	[ORDER_TYPE] [float] NULL,
	[FIRM_PLANNED_TYPE] [float] NULL,
	[ORDER_TYPE_TEXT] [nvarchar](4000) NULL,
	[ORG_CODE] [nvarchar](3) NULL,
	[ITEM_SEGMENTS] [nvarchar](250) NULL,
	[START_OF_WEEK] [datetime2](7) NULL,
	[DEMAND_CLASS] [nvarchar](34) NULL,
	[PLANNER_CODE] [nvarchar](10) NULL,
	[QUANTITY] [float] NULL,
	[InventoryType] [nvarchar](4000) NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
