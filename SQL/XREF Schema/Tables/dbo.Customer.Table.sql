USE [XREF]
GO
/****** Object:  Table [dbo].[Customer]    Script Date: 7/8/2025 3:41:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Customer](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CustomerID] [int] NULL,
	[CustomerKey] [nvarchar](50) NOT NULL,
	[CustomerName] [nvarchar](240) NULL,
	[CustomerDesc] [nvarchar](272) NULL,
	[CustomerSort] [nvarchar](10) NULL,
	[SALES_CHANNEL_CODE] [nvarchar](30) NULL,
	[INSIDE_REP] [nvarchar](150) NULL,
	[TRAFFIC_PERSON] [nvarchar](150) NULL,
	[LABEL_FORMAT] [nvarchar](150) NULL,
	[BUSINESS_SEGMENT] [nvarchar](150) NULL,
	[CUSTOMER_GROUP] [nvarchar](150) NULL,
	[FINANCE_CHANNEL] [nvarchar](150) NULL,
	[TERRITORY] [nvarchar](40) NOT NULL,
	[SALESPERSON] [nvarchar](240) NOT NULL,
	[ORDER_TYPE] [nvarchar](30) NOT NULL,
	[DEMAND_CLASS_CODE] [nvarchar](30) NOT NULL,
	[DEMAND_CLASS_NAME] [varchar](255) NOT NULL,
	[FINANCE_REPORTING_CHANNEL] [varchar](255) NOT NULL,
	[FEED_DEMAND_CLASS_NAME] [varchar](50) NULL,
	[FEED_CUSTOMER] [varchar](17) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
