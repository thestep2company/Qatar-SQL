USE [XREF]
GO
/****** Object:  Table [dbo].[Customer Grid by Account]    Script Date: 7/8/2025 3:41:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Customer Grid by Account](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Account Number] [nvarchar](25) NOT NULL,
	[Account Name] [nvarchar](100) NOT NULL,
	[Other] [decimal](18, 10) NOT NULL,
	[Freight Allowance] [decimal](18, 10) NOT NULL,
	[DIF Returns] [decimal](18, 10) NOT NULL,
	[Cash Discounts] [decimal](18, 10) NOT NULL,
	[Markdown] [decimal](18, 10) NOT NULL,
	[CoOp] [decimal](18, 10) NOT NULL,
	[Total] [decimal](18, 10) NOT NULL,
	[Commission] [decimal](18, 10) NULL,
	[Invoiced Freight] [decimal](18, 10) NULL,
	[Year] [int] NULL,
	[Month] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_CustomerGridAccount] UNIQUE NONCLUSTERED 
(
	[Account Number] ASC,
	[Year] ASC,
	[Month] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
