USE [Operations]
GO
/****** Object:  Table [dbo].[PIMCarton]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PIMCarton](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Box SKU] [nvarchar](106) NULL,
	[UPC] [nvarchar](255) NULL,
	[Master Carton: Packaged Length (in)] [float] NULL,
	[Master Carton: Packaged Width (in)] [float] NULL,
	[Master Carton: Packaged Height (in)] [float] NULL,
	[DIMENSION_UOM_CODE] [nvarchar](3) NULL,
	[Master Carton: Cube (sq ft)] [float] NULL,
	[Master Carton: Packaged Weight (lbs)] [float] NULL,
	[WEIGHT_UOM_CODE] [nvarchar](3) NULL,
	[LongestSide] [float] NULL,
	[Shipment Type] [varchar](12) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
