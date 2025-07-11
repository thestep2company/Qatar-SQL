USE [Operations]
GO
/****** Object:  Table [dbo].[FactProductionPlan]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactProductionPlan](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[PlantID] [int] NOT NULL,
	[ProductID] [int] NOT NULL,
	[DemandClassID] [int] NULL,
	[InventoryCodeID] [int] NOT NULL,
	[DateID] [int] NOT NULL,
	[InventoryTypeID] [int] NOT NULL,
	[Quantity] [float] NOT NULL,
	[Cost] [float] NULL,
	[MachineHours] [float] NULL,
	[MachineID] [int] NULL,
	[PlanMachineID] [int] NULL,
 CONSTRAINT [PK_FactProductionPlan] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
