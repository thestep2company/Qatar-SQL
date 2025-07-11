USE [Operations]
GO
/****** Object:  Table [Manufacturing].[Budget]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Manufacturing].[Budget](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Year] [int] NOT NULL,
	[Month] [int] NOT NULL,
	[Week] [int] NOT NULL,
	[PlantKey] [varchar](25) NOT NULL,
	[ProductionDays] [float] NULL,
	[MachineCount] [float] NOT NULL,
	[NSP] [money] NOT NULL,
	[Cost] [money] NULL,
	[FTEHC] [int] NULL,
	[TrainingHC] [int] NULL,
 CONSTRAINT [PK_Budget] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
