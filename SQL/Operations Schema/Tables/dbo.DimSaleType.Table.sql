USE [Operations]
GO
/****** Object:  Table [dbo].[DimSaleType]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimSaleType](
	[SaleTypeID] [int] NOT NULL,
	[SaleTypeName] [varchar](7) NOT NULL,
	[SalesTypeDesc] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[SaleTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
