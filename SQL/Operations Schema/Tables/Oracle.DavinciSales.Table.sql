USE [Operations]
GO
/****** Object:  Table [Oracle].[DavinciSales]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Oracle].[DavinciSales](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CUSTOMER_TRX_LINE_ID] [numeric](15, 0) NOT NULL,
	[TERM_ID] [numeric](15, 0) NULL,
	[StartDate] [datetime] NOT NULL,
 CONSTRAINT [PK_DavinciSales] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Oracle].[DavinciSales] ADD  DEFAULT (getdate()) FOR [StartDate]
GO
