USE [Operations]
GO
/****** Object:  Table [Oracle].[Trips]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Oracle].[Trips](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[ORDER_NUM] [nvarchar](150) NULL,
	[ORDER_LINE_NUM] [nvarchar](150) NULL,
	[ORD_HEADER_ID] [float] NULL,
	[ORD_LINE_ID] [float] NOT NULL,
	[CUST_PO_NUM] [nvarchar](50) NULL,
	[LOT_NUMBER] [nvarchar](80) NULL,
	[TRX_NUMBER] [float] NULL,
	[TRIP_ID] [float] NOT NULL,
	[CARRIER_ID] [float] NULL,
	[SHIP_METHOD_CODE] [nvarchar](30) NULL,
	[TRACKING_NUMBER] [nvarchar](30) NULL,
	[VOLUME] [float] NULL,
	[VOLUME_UOM_CODE] [nvarchar](3) NULL,
	[NET_WEIGHT] [float] NULL,
	[WEIGHT_UOM_CODE] [nvarchar](3) NULL,
	[StartDate] [datetime] NOT NULL,
 CONSTRAINT [PK_Trips] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Oracle].[Trips] ADD  DEFAULT (getdate()) FOR [StartDate]
GO
