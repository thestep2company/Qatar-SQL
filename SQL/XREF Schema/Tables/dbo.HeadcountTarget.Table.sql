USE [XREF]
GO
/****** Object:  Table [dbo].[HeadcountTarget]    Script Date: 7/8/2025 3:41:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HeadcountTarget](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[PlantID] [varchar](5) NULL,
	[ShiftID] [varchar](5) NULL,
	[Department] [varchar](50) NULL,
	[Headcount] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
