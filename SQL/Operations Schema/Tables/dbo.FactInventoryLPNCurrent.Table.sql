USE [Operations]
GO
/****** Object:  Table [dbo].[FactInventoryLPNCurrent]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactInventoryLPNCurrent](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[PlantID] [int] NULL,
	[ProductID] [int] NULL,
	[InventoryCodeID] [bigint] NULL,
	[InventoryTypeID] [int] NULL,
	[InventoryStatusID] [float] NULL,
	[LocatorID] [int] NULL,
	[LOT_NUMBER] [nvarchar](80) NULL,
	[LPN_ID] [float] NULL,
	[AgeID] [int] NULL,
	[Inventory Cost] [float] NULL,
	[Quantity] [float] NOT NULL,
	[Volume] [float] NULL,
	[Average Age] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
