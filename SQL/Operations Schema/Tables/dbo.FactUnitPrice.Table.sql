USE [Operations]
GO
/****** Object:  Table [dbo].[FactUnitPrice]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactUnitPrice](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ORDER_NUM] [int] NULL,
	[SO_LINE_NUM] [int] NULL,
	[UnitPrice] [money] NULL,
	[LastGLDate] [datetime] NULL,
	[RecordCount] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
