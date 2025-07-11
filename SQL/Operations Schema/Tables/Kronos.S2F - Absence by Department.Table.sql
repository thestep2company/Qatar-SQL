USE [Operations]
GO
/****** Object:  Table [Kronos].[S2F - Absence by Department]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Kronos].[S2F - Absence by Department](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Site] [varchar](50) NULL,
	[Department] [varchar](50) NULL,
	[Calendar Week] [varchar](50) NULL,
	[Unexcused Absenteeism Hours as a % of Scheduled Hours] [varchar](50) NULL,
	[Excused Absenteeism Hours as a % of Scheduled Hours] [varchar](50) NULL,
	[Scheduled Hours] [varchar](50) NULL,
	[Unexcused Absenteeism Hours] [varchar](50) NULL,
	[Excused Absenteeism Hours] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
