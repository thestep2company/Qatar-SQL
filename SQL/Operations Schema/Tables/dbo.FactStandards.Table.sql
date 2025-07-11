USE [Operations]
GO
/****** Object:  Table [dbo].[FactStandards]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactStandards](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Rank] [bigint] NULL,
	[ProductID] [int] NULL,
	[4 Digit] [nvarchar](4) NULL,
	[LocationID] [int] NULL,
	[Machine] [nvarchar](10) NULL,
	[RoundsPerShift] [numeric](17, 5) NULL,
	[UnitsPerSpider] [float] NULL,
	[SpidersPerUnit] [float] NULL,
	[MachineHours] [float] NULL,
	[MachineRate] [numeric](4, 2) NULL,
	[MachineCost] [float] NULL,
	[LaborRate] [float] NULL,
	[RotoOperHours] [float] NULL,
	[RotoFloatHours] [float] NULL,
	[TotalRotoHours] [float] NULL,
	[TotalRotoCost] [float] NULL,
	[AssyLaborHours] [float] NULL,
	[AssyLeadHours] [float] NULL,
	[TotalAssyHours] [float] NULL,
	[TotalAssyCost] [float] NULL,
	[TotalProcessingCost] [float] NULL,
	[TotalStandardHours] [float] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
