USE [Forecast]
GO
/****** Object:  Table [dbo].[FactStandardPending]    Script Date: 7/8/2025 3:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactStandardPending](
	[ProductID] [int] NULL,
	[LocationID] [int] NULL,
	[DateID] [int] NOT NULL,
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
	[EndDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
