USE [Operations]
GO
/****** Object:  Table [Manufacturing].[ProductionDistribution]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Manufacturing].[ProductionDistribution](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[LocationKey] [varchar](3) NULL,
	[Day of Week] [nvarchar](3) NULL,
	[Hour] [int] NULL,
	[PercentOfNSP] [float] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
