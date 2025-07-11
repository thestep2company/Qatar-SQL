USE [Operations]
GO
/****** Object:  Table [Oracle].[DebitCreditMemo]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Oracle].[DebitCreditMemo](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ACCOUNT_NUMBER] [nvarchar](30) NULL,
	[ACCOUNT_NAME] [nvarchar](240) NULL,
	[INV_TYPE] [nvarchar](20) NULL,
	[PURCHASE_ORDER] [nvarchar](50) NULL,
	[GL_POSTED_DATE] [datetime2](7) NULL,
	[SPECIAL_INSTR] [nvarchar](240) NULL,
	[COMMENTS] [nvarchar](1760) NULL,
	[CT_REFERENCE] [nvarchar](150) NULL,
	[INVOICE_NUMBER] [nvarchar](20) NOT NULL,
	[INVOICE_DATE] [nvarchar](10) NULL,
	[INV_LINE] [float] NULL,
	[LINE_TYPE] [nvarchar](20) NULL,
	[DESCRIPTION] [nvarchar](240) NULL,
	[QUANTITY_CREDITED] [float] NULL,
	[QUANTITY_INVOICED] [float] NULL,
	[UNIT_SELLING_PRICE] [float] NULL,
	[ACCTD_USD] [float] NULL,
	[GL_ACCOUNT] [nvarchar](129) NULL,
	[PERCENT] [float] NULL,
	[CUSTOMER_TRX_LINE_ID] [numeric](15, 0) NULL,
	[USER_NAME] [nvarchar](100) NULL,
	[FULL_NAME] [nvarchar](240) NULL,
	[Fingerprint] [varchar](32) NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NULL,
	[CurrentRecord] [bit] NOT NULL,
 CONSTRAINT [PK_DebitCreditMemo] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Oracle].[DebitCreditMemo] ADD  DEFAULT (getdate()) FOR [StartDate]
GO
ALTER TABLE [Oracle].[DebitCreditMemo] ADD  DEFAULT ((1)) FOR [CurrentRecord]
GO
