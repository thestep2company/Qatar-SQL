USE [Operations]
GO
/****** Object:  Table [xref].[ProductionBudget2025]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [xref].[ProductionBudget2025](
	[Week] [varchar](25) NULL,
	[Location] [varchar](10) NULL,
	[Production $ Budget (Cost) - TOYS] [money] NULL,
	[Production $ Budget (Cost) - Custom] [money] NULL,
	[Machine Hrs (Budget) - TOYS] [decimal](10, 2) NULL,
	[Machine Hrs (Budget) -Custom] [decimal](10, 2) NULL,
	[Labor Earned OH] [money] NULL,
	[Mfg. Earned OH] [money] NULL,
	[Purchased OH Earned] [money] NULL,
	[Total Overhead Earned] [money] NULL
) ON [PRIMARY]
GO
