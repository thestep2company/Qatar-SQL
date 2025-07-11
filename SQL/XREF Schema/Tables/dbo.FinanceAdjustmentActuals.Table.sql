USE [XREF]
GO
/****** Object:  Table [dbo].[FinanceAdjustmentActuals]    Script Date: 7/8/2025 3:41:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FinanceAdjustmentActuals](
	[Year] [int] NOT NULL,
	[Month] [varchar](3) NOT NULL,
	[Total Gross Sales - Product] [float] NULL,
	[Invoiced Freight] [float] NULL,
	[Programs & Allowances] [float] NULL,
 CONSTRAINT [PK_FinanceAdjustmentActuals] PRIMARY KEY CLUSTERED 
(
	[Year] ASC,
	[Month] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
