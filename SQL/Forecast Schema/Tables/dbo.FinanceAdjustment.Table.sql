USE [Forecast]
GO
/****** Object:  Table [dbo].[FinanceAdjustment]    Script Date: 7/8/2025 3:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FinanceAdjustment](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ForecastVersion] [varchar](50) NULL,
	[Year] [int] NULL,
	[Month] [varchar](3) NULL,
	[Gross Sales Manufactured] [float] NULL,
	[Add: Invoiced Freight] [float] NULL,
	[Less: Deductions] [float] NULL,
	[Standard COGS - Manuf FG] [float] NULL,
	[Standard COGS - Labor] [float] NULL
) ON [PRIMARY]
GO
