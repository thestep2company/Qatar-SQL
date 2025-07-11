USE [Operations]
GO
/****** Object:  Table [dbo].[FactInventoryLive]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactInventoryLive](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[PlantID] [int] NULL,
	[ProductID] [int] NULL,
	[InventoryCodeID] [bigint] NULL,
	[DateID] [int] NULL,
	[InventoryTypeID] [int] NULL,
	[InventoryStatusID] [float] NULL,
	[AgeID] [int] NULL,
	[Inventory List] [float] NULL,
	[Inventory Cost] [float] NULL,
	[Quantity] [float] NULL,
	[Volume] [float] NULL,
	[Average Age] [int] NULL,
	[DateKey] [date] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
