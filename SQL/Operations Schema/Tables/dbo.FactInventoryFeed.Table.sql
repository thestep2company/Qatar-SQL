USE [Operations]
GO
/****** Object:  Table [dbo].[FactInventoryFeed]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactInventoryFeed](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CustomerID] [int] NULL,
	[DemandClassID] [bigint] NULL,
	[ProductID] [int] NULL,
	[DateID] [int] NOT NULL,
	[Quantity] [float] NULL,
	[UnitPrice] [int] NOT NULL,
	[Discontinued] [bit] NULL,
 CONSTRAINT [PK_FactInventoryFeed] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
