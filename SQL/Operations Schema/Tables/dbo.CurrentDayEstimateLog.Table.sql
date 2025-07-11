USE [Operations]
GO
/****** Object:  Table [dbo].[CurrentDayEstimateLog]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CurrentDayEstimateLog](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DateKey] [datetime] NOT NULL,
	[SalesEstimate] [float] NULL,
	[NetSalesEstimate] [float] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CurrentDayEstimateLog] ADD  DEFAULT (getdate()) FOR [DateKey]
GO
