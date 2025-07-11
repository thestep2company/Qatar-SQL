USE [Operations]
GO
/****** Object:  Table [xref].[ProductDims]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [xref].[ProductDims](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ProductKey] [varchar](10) NULL,
	[Height] [decimal](5, 2) NULL,
	[Width] [decimal](5, 2) NULL,
	[Depth] [decimal](5, 2) NULL,
	[Size] [varchar](10) NULL,
 CONSTRAINT [PK_ProductDims] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
