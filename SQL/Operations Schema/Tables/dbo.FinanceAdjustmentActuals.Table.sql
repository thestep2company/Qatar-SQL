USE [Operations]
GO
/****** Object:  Table [dbo].[FinanceAdjustmentActuals]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FinanceAdjustmentActuals](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Year] [int] NULL,
	[Month] [varchar](3) NULL,
	[Total Gross Sales - Product] [float] NULL,
	[Invoiced Freight] [float] NULL,
	[Programs & Allowances] [float] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
