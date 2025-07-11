USE [Operations]
GO
/****** Object:  Table [Manufacturing].[Production]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Manufacturing].[Production](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[PRODUCTION_ID] [int] NOT NULL,
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
	[SHIFT] [char](1) NULL,
	[STD_COST] [real] NULL,
	[RESOURCE_COST] [real] NULL,
	[EARNED_OVERHEAD] [real] NULL,
	[MATERIAL_COST] [real] NULL,
	[MATERIAL_OVERHEAD_COST] [real] NULL,
	[OUTSIDE_PROCESSING_COST] [real] NULL,
	[TRANSACTION_ID] [int] NOT NULL,
	[LINE_CODE] [varchar](32) NULL,
	[LINE_DESCRIPTION] [varchar](50) NULL,
	[Fingerprint] [varchar](32) NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NULL,
	[CurrentRecord] [bit] NOT NULL,
	[Shift_ID] [int] NULL,
 CONSTRAINT [PK_Production] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_Production_EndDate]    Script Date: 7/10/2025 11:43:42 AM ******/
CREATE NONCLUSTERED INDEX [IX_Production_EndDate] ON [Manufacturing].[Production]
(
	[EndDate] ASC
)
INCLUDE([TRANS_DATE_TIME],[TOTAL_PRICE],[ORG_CODE],[SHIFT]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Production_LINE_CODE]    Script Date: 7/10/2025 11:43:42 AM ******/
CREATE NONCLUSTERED INDEX [IX_Production_LINE_CODE] ON [Manufacturing].[Production]
(
	[CurrentRecord] ASC
)
INCLUDE([LINE_CODE]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Production_LocationDate]    Script Date: 7/10/2025 11:43:42 AM ******/
CREATE NONCLUSTERED INDEX [IX_Production_LocationDate] ON [Manufacturing].[Production]
(
	[ORG_CODE] ASC,
	[EndDate] ASC
)
INCLUDE([TRANS_DATE_TIME],[TOTAL_PRICE]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Production_Shift]    Script Date: 7/10/2025 11:43:42 AM ******/
CREATE NONCLUSTERED INDEX [IX_Production_Shift] ON [Manufacturing].[Production]
(
	[CurrentRecord] ASC
)
INCLUDE([SHIFT]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [Manufacturing].[Production] ADD  DEFAULT (getdate()) FOR [StartDate]
GO
ALTER TABLE [Manufacturing].[Production] ADD  DEFAULT ((1)) FOR [CurrentRecord]
GO
