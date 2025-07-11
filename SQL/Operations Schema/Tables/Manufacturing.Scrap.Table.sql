USE [Operations]
GO
/****** Object:  Table [Manufacturing].[Scrap]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Manufacturing].[Scrap](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SCRAP_ID] [int] NOT NULL,
	[START_DATE] [datetime] NULL,
	[END_DATE] [datetime] NULL,
	[CREATION_DATE] [datetime] NULL,
	[ORG_CODE] [varchar](3) NULL,
	[SHIFT] [char](1) NULL,
	[LINES] [varchar](8) NULL,
	[REPAIR_SCRAP_TYPE] [varchar](20) NULL,
	[REPAIR_SCRAP_REASON] [varchar](50) NULL,
	[COMP_ITEM] [varchar](20) NULL,
	[ROTO_DESCRIPTION] [varchar](50) NULL,
	[PIGMENT_RESIN] [varchar](25) NULL,
	[QTY] [real] NULL,
	[LBS_REPAIRED_SCRAPPED] [real] NULL,
	[CREATED_BY] [varchar](25) NULL,
	[ERROR_CODE] [varchar](2) NULL,
	[SHIFT_DATE] [datetime] NULL,
	[SHIFT_BY_CREATION_DATE] [char](1) NULL,
	[Fingerprint] [varchar](32) NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NULL,
	[CurrentRecord] [bit] NULL,
 CONSTRAINT [PK_SCRAP] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Manufacturing].[Scrap] ADD  CONSTRAINT [DF_Scrap_StartDate]  DEFAULT (getdate()) FOR [StartDate]
GO
ALTER TABLE [Manufacturing].[Scrap] ADD  CONSTRAINT [DF_Scrap_CurrentRecord]  DEFAULT ((1)) FOR [CurrentRecord]
GO
