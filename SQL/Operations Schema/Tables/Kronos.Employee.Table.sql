USE [Operations]
GO
/****** Object:  Table [Kronos].[Employee]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Kronos].[Employee](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Employee ID] [varchar](250) NULL,
	[Primary Location] [varchar](250) NULL,
	[Primary Job] [varchar](250) NULL,
	[Schedule Group Assignment Name] [varchar](250) NULL,
	[Accrual Profile Name] [varchar](250) NULL,
	[Employee Type] [varchar](250) NULL,
	[Employee Full Name] [varchar](250) NULL,
	[Hire Date] [datetime] NULL,
	[Date Terminated] [datetime] NULL,
	[Termination Reason] [varchar](250) NULL,
	[Fingerprint] [varchar](32) NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NULL,
	[CurrentRecord] [bit] NOT NULL,
 CONSTRAINT [PK_Employee] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Kronos].[Employee] ADD  DEFAULT (getdate()) FOR [StartDate]
GO
ALTER TABLE [Kronos].[Employee] ADD  DEFAULT ((1)) FOR [CurrentRecord]
GO
