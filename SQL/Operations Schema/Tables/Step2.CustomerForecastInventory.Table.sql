USE [Operations]
GO
/****** Object:  Table [Step2].[CustomerForecastInventory]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Step2].[CustomerForecastInventory](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[PartID] [varchar](50) NOT NULL,
	[DemandClass] [varchar](50) NOT NULL,
	[ForecastPercentage] [numeric](18, 4) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
	[CheckSum] [numeric](38, 4) NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NULL,
	[CurrentRecord] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Step2].[CustomerForecastInventory] ADD  DEFAULT (getdate()) FOR [StartDate]
GO
ALTER TABLE [Step2].[CustomerForecastInventory] ADD  DEFAULT ((1)) FOR [CurrentRecord]
GO
