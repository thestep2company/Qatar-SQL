USE [Operations]
GO
/****** Object:  Table [dbo].[DimInventoryType]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimInventoryType](
	[InventoryTypeID] [int] IDENTITY(1,1) NOT NULL,
	[InventoryTypeName] [varchar](25) NULL,
	[InventoryTypeSort] [varchar](5) NULL,
 CONSTRAINT [PK_DimInventoryType] PRIMARY KEY CLUSTERED 
(
	[InventoryTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
