USE [Operations]
GO
/****** Object:  Table [Kronos].[S2F - Employee Summary]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Kronos].[S2F - Employee Summary](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Employee ID] [varchar](250) NULL,
	[Primary Location (Path)] [varchar](250) NULL,
	[Primary Job] [varchar](250) NULL,
	[Schedule Group Assignment Name] [varchar](250) NULL,
	[Accrual Profile Name] [varchar](250) NULL,
	[Employee Type] [varchar](250) NULL,
	[Employee Full Name] [varchar](250) NULL,
	[Hire Date] [varchar](250) NULL,
	[Date Terminated] [varchar](250) NULL,
	[Termination Reason] [varchar](250) NULL,
 CONSTRAINT [PK_S2F - Employee Summary] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
