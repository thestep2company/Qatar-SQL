USE [Operations]
GO
/****** Object:  Table [Manufacturing].[Shift]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Manufacturing].[Shift](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Shift_ID] [int] NULL,
	[Org] [varchar](3) NULL,
	[Start_Date_Time] [datetime] NULL,
	[End_Date_Time] [datetime] NULL,
	[Shift] [varchar](1) NULL,
	[Day_Of_Week] [varchar](8) NULL,
	[Fingerprint] [varchar](32) NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NULL,
	[CurrentRecord] [bit] NULL,
	[HasProduction] [bit] NULL,
 CONSTRAINT [PK_Shift] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Shift_Covered]    Script Date: 7/10/2025 11:43:42 AM ******/
CREATE NONCLUSTERED INDEX [IX_Shift_Covered] ON [Manufacturing].[Shift]
(
	[Org] ASC,
	[CurrentRecord] ASC,
	[Start_Date_Time] ASC,
	[End_Date_Time] ASC
)
INCLUDE([Shift]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [Manufacturing].[Shift] ADD  DEFAULT (getdate()) FOR [StartDate]
GO
ALTER TABLE [Manufacturing].[Shift] ADD  DEFAULT ('9999-12-31') FOR [EndDate]
GO
ALTER TABLE [Manufacturing].[Shift] ADD  DEFAULT ((1)) FOR [CurrentRecord]
GO
