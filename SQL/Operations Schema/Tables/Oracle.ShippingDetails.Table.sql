USE [Operations]
GO
/****** Object:  Table [Oracle].[ShippingDetails]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Oracle].[ShippingDetails](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CUSTOMER_NAME] [nvarchar](360) NULL,
	[CUSTOMER_NUM] [nvarchar](30) NULL,
	[CUST_PO_NUMBER] [nvarchar](50) NULL,
	[ORDER_DATE] [nvarchar](10) NULL,
	[QUANTITY_ORDERED] [float] NULL,
	[PART] [nvarchar](40) NULL,
	[PART_DESC] [nvarchar](240) NULL,
	[SHIPPED_QTY] [float] NULL,
	[DATEREQUESTED] [nvarchar](10) NULL,
	[SCHSHIPDATE] [nvarchar](10) NULL,
	[ACTUAL_SHIP_DATE] [nvarchar](10) NULL,
	[Fingerprint] [varchar](32) NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NULL,
	[CurrentRecord] [bit] NULL,
 CONSTRAINT [PK_ShippingDetails] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Oracle].[ShippingDetails] ADD  DEFAULT (getdate()) FOR [StartDate]
GO
ALTER TABLE [Oracle].[ShippingDetails] ADD  DEFAULT ((1)) FOR [CurrentRecord]
GO
