USE [Operations]
GO
/****** Object:  Table [Oracle].[Buyer]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Oracle].[Buyer](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ITEM_NAME] [nvarchar](250) NULL,
	[SUPPLIER_FROM_ASL] [nvarchar](4000) NULL,
	[PLANNER_CODE] [nvarchar](10) NULL,
	[BUYER_NAME] [nvarchar](240) NULL,
	[Fingerprint] [varchar](32) NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NULL,
	[CurrentRecord] [bit] NOT NULL,
 CONSTRAINT [PK_Buyer] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Oracle].[Buyer] ADD  DEFAULT (getdate()) FOR [StartDate]
GO
ALTER TABLE [Oracle].[Buyer] ADD  DEFAULT ((1)) FOR [CurrentRecord]
GO
