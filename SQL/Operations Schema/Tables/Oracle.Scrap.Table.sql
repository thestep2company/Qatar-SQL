USE [Operations]
GO
/****** Object:  Table [Oracle].[Scrap]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Oracle].[Scrap](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[COLLECTION_ID] [float] NOT NULL,
	[OCCURRENCE] [float] NOT NULL,
	[CREATION_DATE] [nvarchar](19) NULL,
	[ORG_CODE] [nvarchar](3) NULL,
	[SHIFT] [nvarchar](150) NULL,
	[LINES] [nvarchar](150) NULL,
	[REPAIR_SCRAP_TYPE] [nvarchar](150) NULL,
	[REPAIR_SCRAP_REASON] [nvarchar](150) NULL,
	[COMP_ITEM] [nvarchar](4000) NULL,
	[QTY] [nvarchar](150) NULL,
	[LBS_REPAIRED_SCRAPPED] [nvarchar](150) NULL,
	[ROTO_DESCRIPTION] [nvarchar](150) NULL,
	[PIGMEN_RESIN] [nvarchar](150) NULL,
	[ERROR_CODE] [nvarchar](150) NULL,
	[CREATED_BY] [nvarchar](100) NOT NULL,
	[SEGMENT1] [nvarchar](50) NOT NULL,
	[Fingerprint] [nvarchar](32) NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NULL,
	[CurrentRecord] [bit] NOT NULL,
	[Shift_ID] [int] NULL,
 CONSTRAINT [PK_Scrap] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Oracle].[Scrap] ADD  DEFAULT (getdate()) FOR [StartDate]
GO
ALTER TABLE [Oracle].[Scrap] ADD  DEFAULT ((1)) FOR [CurrentRecord]
GO
