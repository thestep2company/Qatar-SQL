USE [Operations]
GO
/****** Object:  Table [Oracle].[InventoryTransactions]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Oracle].[InventoryTransactions](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CC_CD] [nvarchar](25) NULL,
	[Transaction_ID] [float] NOT NULL,
	[INV_SUB_LEDGER_ID] [float] NULL,
	[JE_SOURCE] [nvarchar](9) NULL,
	[JE_CATEGORY] [nvarchar](2) NULL,
	[DESCRIPTION] [nvarchar](240) NULL,
	[ACCOUNT_CODE] [nvarchar](25) NULL,
	[NAME] [nvarchar](14) NULL,
	[ACCOUNTED_DR] [float] NULL,
	[ACCOUNTED_CR] [float] NULL,
	[DOC_SEQUENCE_VALUE] [float] NULL,
	[ACCOUNTING_DATE] [datetime2](7) NULL,
	[JE_HEADER_ID] [float] NULL,
	[JE_LINE_NUM] [float] NULL,
	[INV_ID] [nvarchar](2) NULL,
	[INV_NUM] [nvarchar](2) NULL,
	[LINK_ID] [float] NULL,
	[CODE_COMBINATION_ID] [numeric](15, 0) NOT NULL,
	[SEGMENT2] [nvarchar](25) NULL,
	[REFERENCE_4] [nvarchar](2) NULL,
	[SET_OF_BOOKS_ID] [float] NULL,
	[OPENING_BALANCE] [float] NULL,
	[PO_NUMBER] [nvarchar](2) NULL,
	[PO_LINE_NUM] [float] NULL,
	[PO_LINE_NAME] [nvarchar](150) NULL,
	[VENDOR_NAME] [nvarchar](2) NULL,
	[VOU_NUM] [nvarchar](30) NULL,
	[QUANTITY] [float] NOT NULL,
	[ORGANIZATION_ID] [float] NOT NULL,
	[ITEM_CODE] [nvarchar](40) NULL,
	[USER_NAME] [nvarchar](100) NULL,
	[Fingerprint] [varchar](32) NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NULL,
	[CurrentRecord] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Oracle].[InventoryTransactions] ADD  DEFAULT (getdate()) FOR [StartDate]
GO
ALTER TABLE [Oracle].[InventoryTransactions] ADD  DEFAULT ((1)) FOR [CurrentRecord]
GO
