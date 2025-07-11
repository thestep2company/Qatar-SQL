USE [Forecast]
GO
/****** Object:  Table [xref].[Customer Grid Misc]    Script Date: 7/8/2025 3:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [xref].[Customer Grid Misc](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Demand Class Code] [nvarchar](50) NOT NULL,
	[Other] [decimal](18, 10) NOT NULL,
	[Freight Allowance] [decimal](18, 10) NOT NULL,
	[DIF Returns] [decimal](18, 10) NOT NULL,
	[Cash Discounts] [decimal](18, 10) NOT NULL,
	[Markdown] [decimal](18, 10) NOT NULL,
	[CoOp] [decimal](18, 10) NOT NULL,
	[Total] [decimal](18, 10) NOT NULL,
	[Commission] [decimal](18, 10) NULL,
	[Invoiced Freight] [decimal](18, 10) NULL
) ON [PRIMARY]
GO
