USE [Forecast]
GO
/****** Object:  Table [dbo].[BudgetCategoryMarginLookup]    Script Date: 7/8/2025 3:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BudgetCategoryMarginLookup](
	[Category] [varchar](50) NULL,
	[Net Standard Margin %] [decimal](18, 10) NULL
) ON [PRIMARY]
GO
