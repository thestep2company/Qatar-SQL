USE [Operations]
GO
/****** Object:  Table [dbo].[FactPlan]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactPlan](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[PlantID] [int] NULL,
	[ProductID] [int] NULL,
	[DemandClassID] [bigint] NULL,
	[InventoryCodeID] [int] NOT NULL,
	[InventoryStatusID] [int] NOT NULL,
	[DateID] [int] NULL,
	[InventoryTypeID] [int] NULL,
	[Sale Price] [float] NULL,
	[Average Cost] [float] NULL,
	[Inventory Cost] [float] NULL,
	[Quantity] [float] NULL,
	[Machine Hours] [float] NULL,
 CONSTRAINT [PK_FactPlan] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
