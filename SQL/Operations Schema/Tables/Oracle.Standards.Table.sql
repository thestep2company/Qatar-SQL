USE [Operations]
GO
/****** Object:  Table [Oracle].[Standards]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Oracle].[Standards](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ProductKey] [nvarchar](40) NULL,
	[Organization_Name] [nvarchar](240) NULL,
	[Organization_Code] [nvarchar](3) NULL,
	[Machine] [nvarchar](10) NULL,
	[RoundsPerShift] [int] NULL,
	[UnitsPerSpider] [float] NULL,
	[SpidersPerUnit] [float] NULL,
	[MachineHours] [float] NULL,
	[MachineRate] [numeric](4, 2) NULL,
	[MachineCost] [float] NULL,
	[LaborRate] [float] NULL,
	[RotoOperHours] [float] NULL,
	[RotoFloatHours] [float] NULL,
	[TotalRotoHours] [float] NULL,
	[TotalRotoCost] [float] NULL,
	[AssyLaborHours] [float] NULL,
	[AssyLeadHours] [float] NULL,
	[TotalAssyHours] [float] NULL,
	[TotalAssyCost] [float] NULL,
	[TotalProcessingCost] [float] NULL,
	[TotalStandardHours] [float] NULL,
	[Fingerprint] [varchar](32) NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NULL,
	[CurrentRecord] [bit] NOT NULL,
 CONSTRAINT [PK_Standards] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Oracle].[Standards] ADD  DEFAULT (getdate()) FOR [StartDate]
GO
ALTER TABLE [Oracle].[Standards] ADD  DEFAULT ((1)) FOR [CurrentRecord]
GO
