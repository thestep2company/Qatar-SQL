USE [XREF]
GO
/****** Object:  Table [dbo].[Customer Grid - Original]    Script Date: 7/8/2025 3:41:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Customer Grid - Original](
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
	[Invoiced Freight] [decimal](18, 10) NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
