USE [Operations]
GO
/****** Object:  Table [Traffic].[Schedule]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Traffic].[Schedule](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[RECNUM] [int] NOT NULL,
	[DATE] [smalldatetime] NOT NULL,
	[STORE] [char](2) NULL,
	[TIME_SLOT] [char](4) NULL,
	[TRAFFIC_INITIALS] [char](3) NULL,
	[SHIPPING_INITIALS] [char](3) NULL,
	[PICK_UP_NUMBER] [char](25) NULL,
	[CARRIER] [char](50) NULL,
	[CUSTOMER] [char](50) NULL,
	[DESTINATION] [char](50) NULL,
	[NUM_OF_CARTONS] [int] NULL,
	[NUM_OF_SKU] [int] NULL,
	[LABELS] [char](1) NULL,
	[STATUS] [char](20) NULL,
	[SPECIAL_INSTRUCTIONS] [char](255) NULL,
	[START_TIME] [char](4) NULL,
	[END_TIME] [char](4) NULL,
	[USER_ID] [char](25) NULL,
	[SO_ID] [char](16) NULL,
	[Fingerprint] [varchar](32) NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NULL,
	[CurrentRecord] [bit] NULL,
 CONSTRAINT [PK_Schedule] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Traffic].[Schedule] ADD  DEFAULT (getdate()) FOR [StartDate]
GO
ALTER TABLE [Traffic].[Schedule] ADD  DEFAULT ((1)) FOR [CurrentRecord]
GO
