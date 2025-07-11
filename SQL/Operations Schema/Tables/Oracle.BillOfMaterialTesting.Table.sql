USE [Operations]
GO
/****** Object:  Table [Oracle].[BillOfMaterialTesting]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Oracle].[BillOfMaterialTesting](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ORDER_LEVEL] [nvarchar](4000) NULL,
	[ASSEMBLY_ITEM] [nvarchar](40) NULL,
	[ASSEMBLY_DESCRIPTION] [nvarchar](240) NULL,
	[ASSEMBLY_ITEM_STATUS] [nvarchar](10) NOT NULL,
	[PATH] [nvarchar](4000) NULL,
	[NEW_PATH] [nvarchar](4000) NULL,
	[COMPONENT_ITEM] [nvarchar](40) NULL,
	[COMPONENT_ITEM_DESCRIPTION] [nvarchar](240) NULL,
	[COMPONENT_ITEM_STATUS] [nvarchar](10) NOT NULL,
	[ITEM_NUM] [float] NULL,
	[OPERATION_SEQ_NUM] [float] NOT NULL,
	[COMPONENT_QUANTITY] [float] NOT NULL,
	[Fingerprint] [varchar](32) NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NULL,
	[CurrentRecord] [bit] NOT NULL,
 CONSTRAINT [PK_BillOfMaterialTesting] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Oracle].[BillOfMaterialTesting] ADD  DEFAULT (getdate()) FOR [StartDate]
GO
ALTER TABLE [Oracle].[BillOfMaterialTesting] ADD  DEFAULT ((1)) FOR [CurrentRecord]
GO
