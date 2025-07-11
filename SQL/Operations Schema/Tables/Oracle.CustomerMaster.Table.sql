USE [Operations]
GO
/****** Object:  Table [Oracle].[CustomerMaster]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Oracle].[CustomerMaster](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ACCOUNT_NUMBER] [nvarchar](30) NOT NULL,
	[ACCOUNT_NAME] [nvarchar](240) NULL,
	[SALES_CHANNEL_CODE] [nvarchar](30) NULL,
	[INSIDE_REP] [nvarchar](150) NULL,
	[TRAFFIC_PERSON] [nvarchar](150) NULL,
	[LABEL_FORMAT] [nvarchar](150) NULL,
	[BUSINESS_SEGMENT] [nvarchar](150) NULL,
	[CUSTOMER_GROUP] [nvarchar](150) NULL,
	[FINANCE_CHANNEL] [nvarchar](150) NULL,
	[TERRITORY] [nvarchar](40) NULL,
	[SALESPERSON] [nvarchar](240) NULL,
	[ORDER_TYPE] [nvarchar](30) NULL,
	[DEMAND_CLASS_CODE] [nvarchar](30) NULL,
	[Fingerprint] [varchar](32) NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NULL,
	[CurrentRecord] [bit] NOT NULL,
 CONSTRAINT [PK_CustomerMaster] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Oracle].[CustomerMaster] ADD  DEFAULT (getdate()) FOR [StartDate]
GO
ALTER TABLE [Oracle].[CustomerMaster] ADD  DEFAULT ((1)) FOR [CurrentRecord]
GO
