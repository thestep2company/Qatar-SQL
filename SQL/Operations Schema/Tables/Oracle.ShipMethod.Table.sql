USE [Operations]
GO
/****** Object:  Table [Oracle].[ShipMethod]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Oracle].[ShipMethod](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SCAC_CODE] [nvarchar](4) NULL,
	[MODE_OF_TRANSPORT] [nvarchar](30) NULL,
	[SHIP_METHOD_CODE] [nvarchar](30) NOT NULL,
	[SERVICE_LEVEL] [nvarchar](30) NULL,
	[SHIP_METHOD_MEANING] [nvarchar](240) NULL,
	[CARRIER_ID] [float] NOT NULL,
	[FREIGHT_CODE] [nvarchar](30) NOT NULL,
	[Fingerprint] [varchar](32) NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NULL,
	[CurrentRecord] [bit] NOT NULL,
 CONSTRAINT [PK_ShipMethod] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Oracle].[ShipMethod] ADD  DEFAULT (getdate()) FOR [StartDate]
GO
ALTER TABLE [Oracle].[ShipMethod] ADD  DEFAULT ((1)) FOR [CurrentRecord]
GO
