USE [Operations]
GO
/****** Object:  Table [Kronos].[EmployeeAbsence]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Kronos].[EmployeeAbsence](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Site] [varchar](50) NULL,
	[Department] [varchar](50) NULL,
	[Calendar Week] [varchar](50) NULL,
	[Scheduled Hours] [float] NULL,
	[Unexcused Absenteeism Hours] [float] NULL,
	[Excused Absenteeism Hours] [float] NULL,
	[Fingerprint] [varchar](32) NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NULL,
	[CurrentRecord] [bit] NOT NULL,
 CONSTRAINT [PK_EmployeeAbsence] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Kronos].[EmployeeAbsence] ADD  DEFAULT (getdate()) FOR [StartDate]
GO
ALTER TABLE [Kronos].[EmployeeAbsence] ADD  DEFAULT ((1)) FOR [CurrentRecord]
GO
