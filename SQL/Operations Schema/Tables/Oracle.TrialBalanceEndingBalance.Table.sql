USE [Operations]
GO
/****** Object:  Table [Oracle].[TrialBalanceEndingBalance]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Oracle].[TrialBalanceEndingBalance](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[PERIOD_YEAR] [numeric](15, 0) NULL,
	[PERIOD_NUM] [numeric](15, 0) NULL,
	[SEGMENT1] [nvarchar](25) NULL,
	[SEGMENT2] [nvarchar](25) NULL,
	[SEGMENT3] [nvarchar](25) NULL,
	[SEGMENT4] [nvarchar](25) NULL,
	[CODE_COMBINATION] [nvarchar](181) NULL,
	[STARTING_BALANCE] [float] NULL,
	[ENDING_BALANCE] [float] NULL,
	[Fingerprint] [varchar](32) NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NULL,
	[CurrentRecord] [bit] NOT NULL,
 CONSTRAINT [PK_TrialBalanceEndingBalance] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Oracle].[TrialBalanceEndingBalance] ADD  DEFAULT (getdate()) FOR [StartDate]
GO
ALTER TABLE [Oracle].[TrialBalanceEndingBalance] ADD  DEFAULT ((1)) FOR [CurrentRecord]
GO
