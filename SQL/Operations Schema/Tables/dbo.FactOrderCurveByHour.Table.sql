USE [Operations]
GO
/****** Object:  Table [dbo].[FactOrderCurveByHour]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactOrderCurveByHour](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Month Sort] [varchar](6) NULL,
	[DateID] [int] NULL,
	[HourID] [int] NULL,
	[DemandClassID] [bigint] NULL,
	[SalesPercentByDay] [float] NULL,
	[SalesPercentByHour] [float] NOT NULL,
	[Salespercent] [float] NULL,
 CONSTRAINT [PK_FactOrderCurveByHour] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
