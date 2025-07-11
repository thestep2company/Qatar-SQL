USE [Operations]
GO
/****** Object:  Table [xref].[SalesGridByCustomer]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [xref].[SalesGridByCustomer](
	[Account Number] [nvarchar](25) NULL,
	[Account Name] [nvarchar](255) NULL,
	[COOP] [float] NULL,
	[DIF Returns] [float] NULL,
	[Invoiced Freight] [float] NULL,
	[Freight Allowance] [float] NULL,
	[Markdown] [float] NULL,
	[Cash Discounts] [float] NULL,
	[Other] [float] NULL,
	[Commission] [float] NULL,
	[Year] [int] NULL,
	[Month] [int] NULL,
	[Total] [decimal](18, 10) NULL
) ON [PRIMARY]
GO
