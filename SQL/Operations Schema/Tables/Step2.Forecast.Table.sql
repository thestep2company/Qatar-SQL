USE [Operations]
GO
/****** Object:  Table [Step2].[Forecast]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Step2].[Forecast](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[Demand_Class] [varchar](50) NULL,
	[Item_Num] [varchar](50) NULL,
	[Start Date] [varchar](50) NULL,
	[Quantity] [varchar](50) NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NULL,
	[CurrentRecord] [bit] NULL,
	[Bucket Type] [varchar](250) NULL,
 CONSTRAINT [PK_Forecast] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Step2].[Forecast] ADD  DEFAULT (getdate()) FOR [StartDate]
GO
ALTER TABLE [Step2].[Forecast] ADD  DEFAULT ((1)) FOR [CurrentRecord]
GO
