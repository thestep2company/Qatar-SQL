USE [Operations]
GO
/****** Object:  Table [Oracle].[MSC_ORDERS_V_FORECAST]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Oracle].[MSC_ORDERS_V_FORECAST](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SOURCE_TABLE] [nvarchar](12) NULL,
	[ITEM_SEGMENTS] [nvarchar](250) NULL,
	[DESCRIPTION] [nvarchar](240) NULL,
	[USING_ASSEMBLY_SEGMENTS] [nvarchar](25) NULL,
	[DEMAND_CLASS] [nvarchar](34) NULL,
	[NEW_ORDER_DATE] [datetime2](7) NULL,
	[FIRM_PLANNED_TYPE] [float] NULL,
	[FIRM_DATE] [datetime2](7) NULL,
	[QUANTITY] [float] NULL,
	[ORDER_TYPE_TEXT] [nvarchar](25) NULL,
	[ORDER_TYPE] [float] NULL,
	[NEW_DUE_DATE] [datetime2](7) NULL,
	[PLANNER_CODE] [nvarchar](10) NULL,
	[ORGANIZATION_CODE] [nvarchar](7) NULL,
	[SOURCE_ORGANIZATION_CODE] [nvarchar](25) NULL,
	[PLAN_ID] [float] NULL,
	[START_OF_WEEK] [datetime2](7) NULL,
	[ROW_ID] [char](18) NULL,
	[Fingerprint] [varchar](32) NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NULL,
	[CurrentRecord] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
