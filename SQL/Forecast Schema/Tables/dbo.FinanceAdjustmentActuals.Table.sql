USE [Forecast]
GO
/****** Object:  Table [dbo].[FinanceAdjustmentActuals]    Script Date: 7/8/2025 3:39:36 PM ******/
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
	[Programs & Allowances] [float] NULL
) ON [PRIMARY]
GO
