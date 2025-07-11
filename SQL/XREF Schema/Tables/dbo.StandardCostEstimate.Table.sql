USE [XREF]
GO
/****** Object:  Table [dbo].[StandardCostEstimate]    Script Date: 7/8/2025 3:41:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[StandardCostEstimate](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SKU] [varchar](100) NULL,
	[Description] [varchar](100) NULL,
	[ItemCost] [money] NULL,
	[MaterialCost] [money] NULL,
	[MaterialOverheadCost] [money] NULL,
	[ResourceCost] [money] NULL,
	[OutsideProcessingCost] [money] NULL,
	[OverheadCost] [money] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
