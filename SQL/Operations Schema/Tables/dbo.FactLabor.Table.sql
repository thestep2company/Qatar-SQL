USE [Operations]
GO
/****** Object:  Table [dbo].[FactLabor]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactLabor](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[EmployeeID] [int] NULL,
	[DepartmentID] [bigint] NULL,
	[LaborCategoryID] [bigint] NULL,
	[PaycodeID] [bigint] NULL,
	[LocationID] [int] NULL,
	[ShiftID] [bigint] NULL,
	[DateID] [int] NULL,
	[Hours] [float] NULL,
	[Wages] [money] NULL,
 CONSTRAINT [PK_FactLabor] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_FactLabor_DateID]    Script Date: 7/10/2025 11:43:42 AM ******/
CREATE NONCLUSTERED INDEX [IX_FactLabor_DateID] ON [dbo].[FactLabor]
(
	[DateID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
