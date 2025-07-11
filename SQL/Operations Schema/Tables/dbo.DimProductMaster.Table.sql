USE [Operations]
GO
/****** Object:  Table [dbo].[DimProductMaster]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimProductMaster](
	[ProductID] [int] IDENTITY(1,1) NOT NULL,
	[ProductKey] [nvarchar](100) NOT NULL,
	[ProductName] [nvarchar](300) NOT NULL,
	[ProductDesc] [nvarchar](300) NOT NULL,
	[ProductSort] [nvarchar](10) NOT NULL,
	[4 Digit] [nvarchar](300) NULL,
	[UOM] [nvarchar](5) NOT NULL,
	[Item Type] [nvarchar](30) NOT NULL,
	[SIOP Family] [nvarchar](240) NOT NULL,
	[Category] [nvarchar](240) NOT NULL,
	[SubCategory] [nvarchar](240) NOT NULL,
	[CategoryType] [varchar](25) NOT NULL,
	[Brand] [nvarchar](240) NOT NULL,
	[Inventory Status Code] [nvarchar](10) NOT NULL,
	[Country of Origin] [nvarchar](240) NOT NULL,
	[Part Class] [nvarchar](240) NOT NULL,
	[MakeBuy] [varchar](5) NULL,
	[Contract Manufacturing] [varchar](22) NOT NULL,
	[Channel] [varchar](10) NOT NULL,
	[Part Type] [varchar](14) NOT NULL,
	[IMAP] [varchar](13) NOT NULL,
	[NPD] [varchar](5) NOT NULL,
	[Product Volume] [float] NOT NULL,
	[List Price] [money] NULL,
	[Royalty License Name] [nvarchar](255) NULL,
	[Shipping Method] [nvarchar](255) NULL,
	[Cooler Size] [varchar](25) NULL,
	[FirstProductionDate] [date] NULL,
	[LastProductionDate] [date] NULL,
	[FirstSaleDate] [date] NULL,
	[LastSaleDate] [date] NULL,
	[CreationDate] [date] NULL,
	[ProductGroup] [varchar](250) NULL,
	[ProductLine] [varchar](250) NULL,
	[Department] [varchar](50) NULL,
	[Dimensions] [varchar](50) NULL,
	[Footprint] [decimal](9, 2) NULL,
	[Cube] [decimal](9, 2) NULL,
	[ChildAdult] [varchar](10) NULL,
	[Size] [varchar](10) NULL,
	[Step2 Custom] [varchar](25) NULL,
	[DerivedProductKey] [varchar](100) NULL,
	[PlaceholderName] [varchar](300) NULL,
	[PlaceholderDesc] [varchar](300) NULL,
	[PlaceholderType] [varchar](100) NULL,
	[Forecast Segment] [varchar](100) NULL,
	[UPC] [nvarchar](255) NULL,
	[4 Digit SKU] [varchar](10) NULL,
	[ProductStatus] [varchar](25) NULL,
	[VENDOR_NAME] [varchar](240) NULL,
	[VENDOR_NAME_ALTERNATE] [varchar](240) NULL,
	[PLANNER_CODE] [varchar](10) NULL,
	[BUYER_NAME] [varchar](240) NULL,
	[Product Name Consolidated] [varchar](250) NULL,
	[Visible] [bit] NULL,
	[HasSCP] [bit] NULL,
	[HasInventory] [bit] NULL,
	[Supercategory_NEW] [nvarchar](240) NULL,
	[Category_NEW] [nvarchar](240) NULL,
	[Sub-Category_NEW] [nvarchar](240) NULL,
	[ProductType_NEW] [nvarchar](240) NULL,
	[Brand_NEW] [nvarchar](240) NULL,
	[License] [nvarchar](240) NULL,
	[Product Family] [nvarchar](240) NULL,
	[US Exclusive] [nvarchar](240) NULL,
	[ABCD Code] [nvarchar](240) NULL,
	[Safety Stock Variability] [nvarchar](240) NULL,
	[Weight_Assembled] [nvarchar](240) NULL,
	[Volume_Assembled] [nvarchar](240) NULL,
	[Length_Assembled] [nvarchar](240) NULL,
	[Width_Assembled] [nvarchar](240) NULL,
	[Height_Assembled] [nvarchar](240) NULL,
 CONSTRAINT [PK_DimProductMaster] PRIMARY KEY CLUSTERED 
(
	[ProductID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_ProductMaster_ProductKey]    Script Date: 7/10/2025 11:43:42 AM ******/
CREATE NONCLUSTERED INDEX [IX_ProductMaster_ProductKey] ON [dbo].[DimProductMaster]
(
	[ProductKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DimProductMaster] ADD  DEFAULT ((0)) FOR [HasInventory]
GO
