USE [Operations]
GO
/****** Object:  Table [Oracle].[Inventory]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Oracle].[Inventory](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ORG_CODE] [nvarchar](3) NULL,
	[ITEM] [nvarchar](40) NULL,
	[SUBINV_CODE] [nvarchar](10) NOT NULL,
	[UOM] [nvarchar](3) NOT NULL,
	[P_OH_QTY] [float] NULL,
	[OH_QTY] [float] NULL,
	[P_TOT_COST] [float] NULL,
	[T_TOT_COST] [float] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
