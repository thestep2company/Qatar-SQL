USE [Operations]
GO
/****** Object:  Table [Oracle].[CustomerPartReference]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Oracle].[CustomerPartReference](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ACCT_NUM] [nvarchar](30) NOT NULL,
	[ACCT_NAME] [nvarchar](240) NULL,
	[CUSTOMER_NAME] [nvarchar](360) NOT NULL,
	[STEP2_ITEM_NUM] [nvarchar](40) NULL,
	[CUSTOMER_ITEM] [nvarchar](50) NOT NULL,
	[DESCRIPTION] [nvarchar](240) NULL,
	[ITEM_TYPE] [nvarchar](30) NULL,
	[RANK] [float] NOT NULL,
	[Fingerprint] [varchar](32) NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NULL,
	[CurrentRecord] [bit] NOT NULL,
 CONSTRAINT [PK_CustomerPartReference] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Oracle].[CustomerPartReference] ADD  DEFAULT (getdate()) FOR [StartDate]
GO
ALTER TABLE [Oracle].[CustomerPartReference] ADD  DEFAULT ((1)) FOR [CurrentRecord]
GO
