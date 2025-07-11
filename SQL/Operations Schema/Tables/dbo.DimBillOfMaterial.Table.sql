USE [Operations]
GO
/****** Object:  Table [dbo].[DimBillOfMaterial]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimBillOfMaterial](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ProductID] [int] NULL,
	[CHILD_SKU] [nvarchar](40) NULL,
	[PARENT_SKU] [nvarchar](40) NULL,
	[CHILD_PATH] [varchar](1000) NULL,
	[PARENT_PATH] [varchar](1000) NULL,
	[ITEM_NUM] [float] NULL,
	[COMPONENT_QUANTITY] [float] NOT NULL,
	[ParentID] [int] NULL,
	[Level] [int] NULL,
	[ROLLDOWN] [float] NOT NULL,
	[DERIVED_QUANTITY] [float] NOT NULL,
 CONSTRAINT [PK_DimBillOfMaterial] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
