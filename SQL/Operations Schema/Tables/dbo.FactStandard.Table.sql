USE [Operations]
GO
/****** Object:  Table [dbo].[FactStandard]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactStandard](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ProductID] [bigint] NULL,
	[LocationID] [int] NULL,
	[DateID] [int] NULL,
	[Machine] [nvarchar](10) NULL,
	[RoundsPerShift] [numeric](19, 7) NOT NULL,
	[UnitsPerSpider] [float] NOT NULL,
	[SpidersPerUnit] [float] NOT NULL,
	[MachineHours] [float] NOT NULL,
	[MachineRate] [numeric](4, 2) NOT NULL,
	[MachineCost] [float] NOT NULL,
	[LaborRate] [float] NOT NULL,
	[RotoOperHours] [float] NOT NULL,
	[RotoFloatHours] [float] NOT NULL,
	[TotalRotoHours] [float] NOT NULL,
	[TotalRotoCost] [float] NOT NULL,
	[AssyLaborHours] [float] NOT NULL,
	[AssyLeadHours] [float] NOT NULL,
	[TotalAssyHours] [float] NOT NULL,
	[TotalAssyCost] [float] NOT NULL,
	[TotalProcessingCost] [float] NOT NULL,
	[TotalStandardHours] [float] NOT NULL,
	[ItemCost] [float] NOT NULL,
	[MaterialCost] [float] NOT NULL,
	[MaterialOverheadCost] [float] NOT NULL,
	[ResourceCost] [float] NOT NULL,
	[OutsideProcessingCost] [float] NOT NULL,
	[OverheadCost] [float] NOT NULL,
	[StartDate] [datetime] NULL,
	[EndDate] [datetime] NOT NULL,
 CONSTRAINT [PK_FactStandard] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
