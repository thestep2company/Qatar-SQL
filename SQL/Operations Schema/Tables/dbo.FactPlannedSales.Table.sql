USE [Operations]
GO
/****** Object:  Table [dbo].[FactPlannedSales]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactPlannedSales](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ForecastID] [int] NOT NULL,
	[LocationID] [int] NULL,
	[DemandClassID] [bigint] NULL,
	[ProductID] [int] NULL,
	[ProductionDateID] [int] NULL,
	[SnapshotDateID] [int] NULL,
	[PlanDate] [int] NULL,
	[PostDateID] [int] NOT NULL,
	[SalesQuantity] [float] NULL,
	[ForecastQuantity] [float] NULL,
	[Cost] [float] NULL,
	[PlanOffset] [int] NULL,
	[MachineHoursPlan] [float] NULL,
	[MachineSize] [nvarchar](10) NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
