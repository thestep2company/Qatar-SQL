USE [Operations]
GO
/****** Object:  Table [Oracle].[Production]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Oracle].[Production](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[TRANS_DATE_TIME] [datetime] NOT NULL,
	[PART_NUMBER] [varchar](50) NULL,
	[PART_DESCRIPTION] [varchar](100) NULL,
	[PRODUCTION_QTY] [int] NULL,
	[LIST_LESS_7] [real] NULL,
	[TOTAL_PRICE] [real] NULL,
	[PLANNER_CODE] [varchar](50) NULL,
	[RESOURCE_HOURS] [real] NULL,
	[TOTAL_MACHINE_HOURS] [real] NULL,
	[FG_RESIN_WGT] [real] NULL,
	[FG_TOTAL_RESIN] [real] NULL,
	[UNIT_VOLUME] [real] NULL,
	[TOTAL_VOLUME] [real] NULL,
	[ORG_CODE] [varchar](3) NULL,
	[ORG_NAME] [varchar](50) NULL,
	[STD_COST] [real] NULL,
	[RESOURCE_COST] [real] NULL,
	[EARNED_OVERHEAD] [real] NULL,
	[MATERIAL_COST] [real] NULL,
	[MATERIAL_OVERHEAD_COST] [real] NULL,
	[OUTSIDE_PROCESSING_COST] [real] NULL,
	[TRANSACTION_ID] [int] NULL,
	[LINE_CODE] [varchar](25) NULL,
	[LINE_DESCRIPTION] [varchar](50) NULL,
	[SUBINVENTORY] [varchar](50) NULL,
	[ITEM_TYPE] [varchar](50) NULL,
	[COSTED_MACHINE_HOURS] [real] NULL,
	[TRANSACTION_SET_ID] [int] NOT NULL,
	[SHIFT] [nvarchar](150) NULL,
	[SHIFT_ID] [int] NULL,
	[Fingerprint] [varchar](32) NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NULL,
	[CurrentRecord] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Oracle].[Production] ADD  DEFAULT (getdate()) FOR [StartDate]
GO
ALTER TABLE [Oracle].[Production] ADD  DEFAULT ((1)) FOR [CurrentRecord]
GO
