USE [XREF]
GO
/****** Object:  Table [dbo].[ProductionBudget]    Script Date: 7/8/2025 3:41:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProductionBudget](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Week] [varchar](25) NULL,
	[Location] [varchar](10) NULL,
	[Production $ Budget (Cost) - TOYS] [money] NULL,
	[Production $ Budget (Cost) - Custom] [money] NULL,
	[Machine Hrs (Budget) - TOYS] [decimal](10, 2) NULL,
	[Machine Hrs (Budget) -Custom] [decimal](10, 2) NULL,
	[Labor Earned OH] [money] NULL,
	[Mfg. Earned OH] [money] NULL,
	[Purchased OH Earned] [money] NULL,
	[Total Overhead Earned] [money] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
