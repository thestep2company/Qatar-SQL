USE [Operations]
GO
/****** Object:  Table [dbo].[DimLaborDepartment]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimLaborDepartment](
	[DepartmentID] [bigint] IDENTITY(1,1) NOT NULL,
	[DepartmentKey] [varchar](250) NULL,
	[LaborType] [varchar](14) NOT NULL,
 CONSTRAINT [PK_DimLaborDepartment_DepartmentID] PRIMARY KEY CLUSTERED 
(
	[DepartmentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
