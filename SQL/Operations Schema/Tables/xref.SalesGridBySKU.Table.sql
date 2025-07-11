USE [Operations]
GO
/****** Object:  Table [xref].[SalesGridBySKU]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [xref].[SalesGridBySKU](
	[Account Number] [nvarchar](25) NOT NULL,
	[Account Name] [nvarchar](255) NULL,
	[SKU] [nvarchar](255) NULL,
	[Description] [nvarchar](255) NULL,
	[Year] [int] NULL,
	[Month] [int] NULL,
	[Other] [decimal](18, 10) NOT NULL,
	[Freight Allowance] [decimal](18, 10) NOT NULL,
	[DIF Returns] [decimal](18, 10) NOT NULL,
	[Cash Discounts] [decimal](18, 10) NOT NULL,
	[Markdown] [decimal](18, 10) NOT NULL,
	[CoOp] [decimal](18, 10) NOT NULL,
	[Total Program %] [decimal](18, 10) NOT NULL
) ON [PRIMARY]
GO
