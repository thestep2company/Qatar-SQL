USE [Operations]
GO
/****** Object:  Table [Oracle].[TrialBalance]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Oracle].[TrialBalance](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[JE_HDR_ID] [numeric](15, 0) NOT NULL,
	[CATEGORY] [nvarchar](25) NOT NULL,
	[SOURCE] [nvarchar](25) NOT NULL,
	[PERIOD] [nvarchar](15) NOT NULL,
	[JE_HDR_NAME] [nvarchar](100) NOT NULL,
	[JE_HDR_CREATED] [datetime2](7) NULL,
	[JE_HDR_CREATED_BY] [nvarchar](302) NULL,
	[JE_HDR_EFF_DATE] [datetime2](7) NOT NULL,
	[JE_HDR_POSTED_DATE] [datetime2](7) NULL,
	[JE_BATCH_ID] [numeric](15, 0) NULL,
	[JE_BATCH_NAME] [nvarchar](100) NOT NULL,
	[JE_BATCH_PERIOD] [nvarchar](15) NULL,
	[HDR_TOTAL_ACCT_DR] [float] NULL,
	[HDR_TOTAL_ACCT_CR] [float] NULL,
	[LINE_NUMBER] [numeric](15, 0) NOT NULL,
	[CODE_COMBINATION] [nvarchar](207) NULL,
	[ACCOUNT] [nvarchar](25) NULL,
	[CURRENCY] [nvarchar](15) NOT NULL,
	[ENTERED_DR] [float] NULL,
	[ENTERED_CR] [float] NULL,
	[ACCT_DEBIT] [float] NULL,
	[ACCT_CREDIT] [float] NULL,
	[ENDING_BALANCE] [float] NULL,
	[LINE_DESCRIPTION] [nvarchar](240) NULL,
	[Fingerprint] [varchar](32) NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NULL,
	[CurrentRecord] [bit] NOT NULL,
	[VENDOR_NUM] [nvarchar](240) NULL,
 CONSTRAINT [PK_TrialBalance] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Oracle].[TrialBalance] ADD  DEFAULT (getdate()) FOR [StartDate]
GO
ALTER TABLE [Oracle].[TrialBalance] ADD  DEFAULT ((1)) FOR [CurrentRecord]
GO
