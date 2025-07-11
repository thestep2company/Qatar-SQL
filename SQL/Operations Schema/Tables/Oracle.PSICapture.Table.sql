USE [Operations]
GO
/****** Object:  Table [Oracle].[PSICapture]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Oracle].[PSICapture](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[TRIP_ID] [float] NULL,
	[DELIVERY_ID] [float] NULL,
	[BILL_OF_LADING] [nvarchar](50) NULL,
	[PO] [nvarchar](255) NULL,
	[ORDER_NUMBER] [nvarchar](255) NULL,
	[SHIP_DATE] [datetime2](7) NULL,
	[STATUS_CODE] [nvarchar](50) NULL,
	[Fingerprint] [varchar](32) NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NULL,
	[CurrentRecord] [bit] NOT NULL,
 CONSTRAINT [PK_PSICapture] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Oracle].[PSICapture] ADD  DEFAULT (getdate()) FOR [StartDate]
GO
ALTER TABLE [Oracle].[PSICapture] ADD  DEFAULT ((1)) FOR [CurrentRecord]
GO
