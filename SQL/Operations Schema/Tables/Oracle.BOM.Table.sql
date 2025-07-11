USE [Operations]
GO
/****** Object:  Table [Oracle].[BOM]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Oracle].[BOM](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[PARENT_SKU] [nvarchar](40) NULL,
	[CHILD_SKU] [nvarchar](40) NULL,
	[ITEM_NUM] [float] NULL,
	[LEVEL] [float] NULL,
	[COMPONENT_QUANTITY] [float] NOT NULL,
	[Fingerprint] [varchar](32) NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NULL,
	[CurrentRecord] [bit] NOT NULL,
 CONSTRAINT [PK_RotoParts] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Oracle].[BOM] ADD  DEFAULT (getdate()) FOR [StartDate]
GO
ALTER TABLE [Oracle].[BOM] ADD  DEFAULT ((1)) FOR [CurrentRecord]
GO
