USE [Operations]
GO
/****** Object:  Table [dbo].[FactCurrentInvoicedOrders]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactCurrentInvoicedOrders](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DateID] [int] NULL,
	[LocationID] [int] NOT NULL,
	[ProductID] [int] NOT NULL,
	[DemandClassID] [bigint] NOT NULL,
	[QUANTITY] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
