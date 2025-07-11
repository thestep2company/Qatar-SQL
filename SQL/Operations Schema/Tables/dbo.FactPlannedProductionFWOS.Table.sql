USE [Operations]
GO
/****** Object:  Table [dbo].[FactPlannedProductionFWOS]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactPlannedProductionFWOS](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ForecastID] [int] NOT NULL,
	[LocationID] [int] NULL,
	[ProductID] [int] NULL,
	[DemandClassID] [bigint] NULL,
	[ProductionDateID] [int] NULL,
	[SnapshotDateID] [int] NULL,
	[PostDateID] [int] NULL,
	[ProductionQuantity] [float] NULL,
	[Cost] [float] NULL,
	[MachineHoursPlan] [float] NULL,
	[MachineSize] [nvarchar](10) NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
