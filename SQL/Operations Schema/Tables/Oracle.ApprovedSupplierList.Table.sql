USE [Operations]
GO
/****** Object:  Table [Oracle].[ApprovedSupplierList]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Oracle].[ApprovedSupplierList](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ASL_ID] [int] NOT NULL,
	[ITEM_NUMBER] [nvarchar](40) NULL,
	[ITEM_DESCRIPTION] [nvarchar](240) NULL,
	[OWNING ORGANIZATION CODE] [nvarchar](3) NULL,
	[PRIMARY_UNIT_OF_MEASURE] [nvarchar](3) NULL,
	[ITEM_STATUS] [nvarchar](8) NULL,
	[ITEM_CREATION_DATE] [datetime] NOT NULL,
	[VENDOR_NUMBER] [nvarchar](30) NOT NULL,
	[VENDOR_NAME] [nvarchar](240) NULL,
	[VENDOR_SITE_CODE] [nvarchar](45) NULL,
	[INACTIVE_DATE] [datetime] NULL,
	[PRIMARY_VENDOR_ITEM] [nvarchar](25) NULL,
	[DISABLE_FLAG] [nvarchar](1) NULL,
	[ASL_STATUS] [nvarchar](25) NOT NULL,
	[Fingerprint] [varchar](32) NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NULL,
	[CurrentRecord] [bit] NOT NULL,
 CONSTRAINT [PK_ApprovedSupplierList] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Oracle].[ApprovedSupplierList] ADD  DEFAULT (getdate()) FOR [StartDate]
GO
ALTER TABLE [Oracle].[ApprovedSupplierList] ADD  DEFAULT ((1)) FOR [CurrentRecord]
GO
