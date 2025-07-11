USE [Operations]
GO
/****** Object:  Table [dbo].[FactInventoryLPN]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactInventoryLPN](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[PlantID] [int] NULL,
	[ProductID] [int] NULL,
	[InventoryCodeID] [bigint] NULL,
	[DateID] [int] NULL,
	[InventoryTypeID] [int] NULL,
	[InventoryStatusID] [float] NULL,
	[LocatorID] [int] NULL,
	[LOT_NUMBER] [nvarchar](80) NULL,
	[Inventory Cost] [float] NULL,
	[Quantity] [float] NOT NULL,
	[Volume] [float] NULL,
	[Receipt Age] [int] NULL,
	[Original Age] [int] NULL,
	[DateKey] [date] NULL,
	[AgeID] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
