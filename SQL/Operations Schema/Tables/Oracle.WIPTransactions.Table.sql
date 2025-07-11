USE [Operations]
GO
/****** Object:  Table [Oracle].[WIPTransactions]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Oracle].[WIPTransactions](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[From] [nvarchar](9) NULL,
	[4_digit_acct] [nvarchar](25) NULL,
	[ORG] [nvarchar](3) NULL,
	[SKU] [nvarchar](40) NULL,
	[DESCRIPTION] [nvarchar](240) NULL,
	[TRANSACTION_ID] [float] NOT NULL,
	[WIP_SUB_LEDGER_ID] [float] NULL,
	[ORGANIZATION_ID] [float] NOT NULL,
	[PRIMARY_ITEM_ID] [float] NULL,
	[PART_ID] [nvarchar](40) NULL,
	[PART_DESCRIPTION] [nvarchar](240) NULL,
	[SUB_INV] [nvarchar](2) NULL,
	[LOCATOR] [nvarchar](2) NULL,
	[TRANSACTION_DATE] [datetime2](7) NOT NULL,
	[TRANSACTION_TYPE] [nvarchar](3) NULL,
	[TRANSACTION_QUANTITY] [float] NULL,
	[PRIAMARY_QTY] [float] NULL,
	[TRANSACTION_VALUE] [float] NULL,
	[BASE_TRANS_VALUE] [float] NULL,
	[AMOUNT] [float] NULL,
	[USAGE_RATE_OR_AMOUNT] [float] NULL,
	[CODE_COMBINATION_ID] [numeric](15, 0) NULL,
	[GL_ACCOUNT] [nvarchar](129) NULL,
	[RESOURCE_CODE] [nvarchar](10) NULL,
	[GROUP_ID] [float] NULL,
	[WIP_ENTITY_ID] [float] NOT NULL,
	[REQUEST_ID] [float] NULL,
	[COMPLETION_TRANSACTION_ID] [float] NULL,
	[ACCT_PERIOD_ID] [float] NOT NULL,
	[OVERHEAD_BASIS_FACTOR] [float] NULL,
	[Fingerprint] [varchar](32) NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NULL,
	[CurrentRecord] [bit] NOT NULL,
 CONSTRAINT [PK_WIPTransactions] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Oracle].[WIPTransactions] ADD  DEFAULT (getdate()) FOR [StartDate]
GO
ALTER TABLE [Oracle].[WIPTransactions] ADD  DEFAULT ((1)) FOR [CurrentRecord]
GO
