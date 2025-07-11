USE [Operations]
GO
/****** Object:  Table [dbo].[DimCustomerMaster]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimCustomerMaster](
	[CustomerID] [int] IDENTITY(1,1) NOT NULL,
	[CustomerKey] [nvarchar](50) NOT NULL,
	[CustomerName] [nvarchar](240) NOT NULL,
	[CustomerDesc] [nvarchar](272) NOT NULL,
	[CustomerSort] [nvarchar](10) NOT NULL,
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
	[DEMAND_CLASS_NAME] [nvarchar](255) NOT NULL,
	[FINANCE_REPORTING_CHANNEL] [nvarchar](255) NOT NULL,
	[FEED_DEMAND_CLASS_NAME] [varchar](50) NOT NULL,
	[FEED_CUSTOMER] [varchar](17) NOT NULL,
	[LastSaleDate] [date] NULL,
	[CreationDate] [date] NULL,
	[FirstSaleDate] [date] NULL,
	[International/Domestic/ CAD] [varchar](255) NULL,
	[Distribution Method] [varchar](255) NULL,
	[Selling Method] [varchar](255) NULL,
	[DropShipType] [varchar](255) NULL,
	[ParentCustomer] [varchar](255) NULL,
	[Sales Representative] [varchar](50) NULL,
 CONSTRAINT [PK_DimCustomerMaster] PRIMARY KEY CLUSTERED 
(
	[CustomerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
