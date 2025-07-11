USE [Operations]
GO
/****** Object:  Table [Oracle].[ProductDates]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Oracle].[ProductDates](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[PART_NUMBER] [varchar](50) NULL,
	[FirstProductionDate] [date] NULL,
	[AnniversaryDate] [date] NULL,
	[MaturityDate] [date] NULL,
	[LastProductionDate] [date] NULL,
	[FirstSaleDate] [date] NULL,
	[LastSaleDate] [date] NULL,
	[FirstPurchaseDate] [date] NULL,
	[LastPurchaseDate] [date] NULL,
	[CreationDate] [date] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
