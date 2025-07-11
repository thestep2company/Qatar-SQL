USE [Operations]
GO
/****** Object:  Table [ADP].[Employee Basic Summary]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ADP].[Employee Basic Summary](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Person Number] [nvarchar](50) NULL,
	[Badge Number] [nvarchar](50) NULL,
	[Name] [nvarchar](50) NULL,
	[Primary Location] [nvarchar](50) NULL,
	[Primary Job] [nvarchar](50) NULL,
	[Reports To] [nvarchar](50) NULL,
	[Pay Rule] [nvarchar](50) NULL,
	[Accrual Profile Name] [nvarchar](50) NULL,
	[Hire Date] [nvarchar](50) NULL,
	[Function Access Profile] [nvarchar](50) NULL,
	[Display Profile] [nvarchar](50) NULL,
	[Employee Group] [nvarchar](50) NULL,
	[User Account Name] [nvarchar](50) NULL,
	[Daily Hours] [nvarchar](50) NULL,
	[Weekly Hours] [nvarchar](50) NULL,
	[Time Zone] [nvarchar](50) NULL,
	[City] [nvarchar](50) NULL,
	[State] [nvarchar](50) NULL,
	[Country] [nvarchar](50) NULL,
	[Email Address] [nvarchar](50) NULL,
	[Last Totalization Date] [nvarchar](50) NULL,
	[Job Transfer Set (Employee)] [nvarchar](50) NULL,
	[Job Transfer Set (Manager)] [nvarchar](50) NULL,
	[Custom Field] [nvarchar](50) NULL,
	[Schedule Group Assignment Name] [nvarchar](50) NULL,
	[Employment Status] [nvarchar](50) NULL,
	[Employment Status Date] [nvarchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
