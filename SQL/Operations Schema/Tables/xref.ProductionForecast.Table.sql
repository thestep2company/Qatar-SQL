USE [Operations]
GO
/****** Object:  Table [xref].[ProductionForecast]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [xref].[ProductionForecast](
	[Org] [varchar](5) NULL,
	[Shift] [varchar](5) NULL,
	[Date] [date] NULL,
	[Percent] [float] NULL
) ON [PRIMARY]
GO
