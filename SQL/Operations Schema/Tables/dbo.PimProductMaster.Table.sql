USE [Operations]
GO
/****** Object:  Table [dbo].[PimProductMaster]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PimProductMaster](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Part Type] [varchar](14) NULL,
	[SKU] [nvarchar](40) NULL,
	[Oracle Name] [nvarchar](240) NULL,
	[Box SKU] [nvarchar](4000) NULL,
	[SIOP Family] [nvarchar](240) NULL,
	[Category] [nvarchar](240) NULL,
	[Sub-Category] [nvarchar](240) NULL,
	[UPC] [nvarchar](255) NULL,
	[GTIN] [nvarchar](14) NULL,
	[H.S. Code] [nvarchar](240) NULL,
	[Make/Buy] [varchar](5) NULL,
	[Product Lifecycle Stage] [nvarchar](10) NOT NULL,
	[Standard Cost] [int] NULL,
	[Amazon DS Invoice Price] [float] NULL,
	[Walmart Invoice Price] [float] NULL,
	[Wayfair Invoice Price] [float] NULL,
	[HD.com Invoice Price] [float] NULL,
	[Kohls.com Invoice Price] [float] NULL,
	[Target.com Invoice Price] [float] NULL,
	[Smyths Invoice Price] [float] NULL,
	[Lowes B&M Invoice Price] [float] NULL,
	[Aldi B&M Invoice Price] [float] NULL,
	[Amazon SKU] [nvarchar](50) NULL,
	[Walmart SKU] [nvarchar](50) NULL,
	[Wayfair SKU] [nvarchar](50) NULL,
	[Home Depot OMSID] [nvarchar](50) NULL,
	[Kohls.com SKU] [nvarchar](50) NULL,
	[Target.com SKU] [nvarchar](50) NULL,
	[Smyths ID] [nvarchar](50) NULL,
	[Lowe's B&M SKU] [nvarchar](50) NULL,
	[Aldi SKU] [nvarchar](50) NULL,
	[Country of Origin] [nvarchar](240) NULL,
	[Multipack Quantity] [float] NULL,
	[Count] [float] NULL,
	[Item Type] [nvarchar](30) NULL,
	[DIMENSION_UOM_CODE] [nvarchar](3) NULL,
	[Master Carton: Packaged Length (in)] [float] NULL,
	[Master Carton: Packaged Width (in)] [float] NULL,
	[Master Carton: Packaged Height (in)] [float] NULL,
	[WEIGHT_UOM_CODE] [nvarchar](3) NULL,
	[Master Carton: Packaged Weight (lbs)] [float] NULL,
	[VOLUME_UOM_CODE] [nvarchar](3) NULL,
	[Master Carton: Cube (sq ft)] [float] NULL,
	[Shipment Type] [varchar](12) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
