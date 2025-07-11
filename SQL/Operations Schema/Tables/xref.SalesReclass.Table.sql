USE [Operations]
GO
/****** Object:  Table [xref].[SalesReclass]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [xref].[SalesReclass](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[JEDescription] [varchar](100) NOT NULL,
	[SKU] [varchar](50) NULL,
	[DemandClassKey] [varchar](50) NULL,
	[Mute] [bit] NULL,
 CONSTRAINT [PK_SalesReclass] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
