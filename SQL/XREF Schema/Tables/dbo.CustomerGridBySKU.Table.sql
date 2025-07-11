USE [XREF]
GO
/****** Object:  Table [dbo].[CustomerGridBySKU]    Script Date: 7/8/2025 3:41:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CustomerGridBySKU](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Account Number] [nvarchar](50) NOT NULL,
	[Account Name] [nvarchar](255) NULL,
	[SKU] [nvarchar](255) NOT NULL,
	[Description] [nvarchar](255) NULL,
	[Year] [int] NULL,
	[Month] [int] NULL,
	[Other] [decimal](18, 10) NOT NULL,
	[Freight Allowance] [decimal](18, 10) NOT NULL,
	[DIF Returns] [decimal](18, 10) NOT NULL,
	[Cash Discounts] [decimal](18, 10) NOT NULL,
	[Markdown] [decimal](18, 10) NOT NULL,
	[CoOp] [decimal](18, 10) NOT NULL,
	[Total Program %] [decimal](18, 10) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
