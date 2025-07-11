USE [Operations]
GO
/****** Object:  Table [Import].[InventoryHistory]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Import].[InventoryHistory](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Organization Code] [float] NULL,
	[Organization Name] [nvarchar](255) NULL,
	[Subinventory Code] [nvarchar](255) NULL,
	[Part Location] [nvarchar](255) NULL,
	[Part Number] [nvarchar](255) NULL,
	[Part Description] [nvarchar](255) NULL,
	[Part Class] [nvarchar](255) NULL,
	[Item Cost] [float] NULL,
	[Item Category] [nvarchar](255) NULL,
	[Quantity] [float] NULL,
	[Value] [float] NULL,
	[InventoryDate] [date] NULL,
	[SourceFile] [nvarchar](255) NULL,
 CONSTRAINT [PK_InventoryHistory] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
