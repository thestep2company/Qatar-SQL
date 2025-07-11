USE [Operations]
GO
/****** Object:  Table [dbo].[DimMachineOperator]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimMachineOperator](
	[OperatorID] [int] IDENTITY(1,1) NOT NULL,
	[OperatorKey] [nvarchar](50) NULL,
	[OperatorName] [nvarchar](50) NULL,
	[OperatorDesc] [nvarchar](102) NULL,
	[Person Number] [nvarchar](50) NULL,
	[Primary Location] [nvarchar](50) NULL,
	[Primary Job] [nvarchar](50) NULL,
	[Reports To] [nvarchar](50) NULL,
	[Pay Rule] [nvarchar](50) NULL,
	[Hire Date] [nvarchar](50) NULL,
	[Employment Status] [nvarchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[OperatorID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
