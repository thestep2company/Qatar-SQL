USE [Operations]
GO
/****** Object:  Table [dbo].[DimEmployee]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimEmployee](
	[EmployeeID] [int] IDENTITY(1,1) NOT NULL,
	[Employee ID] [varchar](250) NULL,
	[Primary Location] [varchar](250) NULL,
	[Primary Job] [varchar](250) NULL,
	[Schedule Group Assignment Name] [varchar](250) NULL,
	[Accrual Profile Name] [varchar](250) NULL,
	[Employee Type] [varchar](250) NULL,
	[Employee Full Name] [varchar](250) NULL,
	[Hire Date] [date] NULL,
	[Date Terminated] [date] NULL,
	[Termination Reason] [varchar](250) NULL,
	[LocationKey] [varchar](3) NULL,
	[Job] [varchar](5) NOT NULL,
	[Department] [varchar](250) NULL,
	[DepartmentID] [bigint] NULL,
	[Status] [varchar](10) NOT NULL,
	[ShiftName] [varchar](50) NOT NULL,
	[ShiftID] [int] NULL,
	[Tenure] [int] NULL,
 CONSTRAINT [PK_DimEmployee_EmployeeID] PRIMARY KEY CLUSTERED 
(
	[EmployeeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
