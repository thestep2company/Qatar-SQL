USE [Operations]
GO
/****** Object:  Table [Kronos].[EmployeeHours]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Kronos].[EmployeeHours](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Employee ID] [varchar](250) NOT NULL,
	[Employee Full Name] [varchar](250) NULL,
	[Employee Pay Rule] [varchar](250) NULL,
	[Hourly Wage] [money] NULL,
	[Primary Location] [varchar](250) NULL,
	[Primary Job] [varchar](250) NULL,
	[Home Labor Category] [varchar](250) NULL,
	[Job Name] [varchar](250) NOT NULL,
	[Job Transfer] [bit] NULL,
	[Paycode Type] [varchar](250) NOT NULL,
	[Paycode Name] [varchar](250) NOT NULL,
	[Work Date] [date] NOT NULL,
	[Actual Hours] [float] NULL,
	[Actual Wages] [money] NULL,
	[Labor Category Name] [varchar](250) NULL,
	[Fingerprint] [varchar](32) NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NULL,
	[CurrentRecord] [bit] NULL,
 CONSTRAINT [PK_EmployeeHoursTest] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Kronos].[EmployeeHours] ADD  DEFAULT (getdate()) FOR [StartDate]
GO
ALTER TABLE [Kronos].[EmployeeHours] ADD  DEFAULT ((1)) FOR [CurrentRecord]
GO
