USE [Operations]
GO
/****** Object:  Table [Kronos].[Employee Hours by Worked Acct Daily]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Kronos].[Employee Hours by Worked Acct Daily](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Employee ID] [varchar](250) NULL,
	[Employee Number] [varchar](250) NULL,
	[Employee Full Name] [varchar](250) NULL,
	[Employee Pay Rule] [varchar](250) NULL,
	[Hourly Wage Rate] [varchar](250) NULL,
	[Primary Location (Path)] [varchar](250) NULL,
	[Primary Job] [varchar](250) NULL,
	[Home Labor Category] [varchar](250) NULL,
	[Job Name - Full Path (Worked)] [varchar](250) NULL,
	[Actual Total Job Transfer Indicator] [varchar](250) NULL,
	[Paycode Type] [varchar](250) NULL,
	[Paycode Name] [varchar](250) NULL,
	[Actual Total Apply Date] [varchar](250) NULL,
	[Actual Total Hours (Include Corrections)] [varchar](250) NULL,
	[Actual Total Wages (Include Corrections)] [varchar](250) NULL,
	[Labor Category Name (Path)] [varchar](250) NULL,
 CONSTRAINT [PK_Employee Hours by Worked Acct Daily] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
