USE [Operations]
GO
/****** Object:  Table [dbo].[PIMParentProduct]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PIMParentProduct](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Parent Name] [nvarchar](247) NULL,
	[Part Type] [varchar](14) NOT NULL,
	[SIOP Family] [nvarchar](240) NULL,
	[Category] [nvarchar](240) NULL,
	[Sub-Category] [nvarchar](240) NULL,
	[Make/Buy] [varchar](5) NULL,
	[Category Old] [nvarchar](240) NULL,
	[Sub-Category Old] [nvarchar](240) NULL,
	[Supercategory] [nvarchar](240) NULL,
	[ProductType] [nvarchar](240) NULL,
	[Brand] [nvarchar](240) NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
