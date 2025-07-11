USE [Operations]
GO
/****** Object:  Table [dbo].[FactSupplierScores]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactSupplierScores](
	[VENDOR_ID] [float] NOT NULL,
	[CostEffectiveness] [varchar](1) NULL,
	[PriceCompetitiveness] [varchar](1) NULL,
	[QuotingProcess] [varchar](1) NULL,
	[PackingLists] [varchar](1) NULL,
	[DPPMCurrentPeriod] [varchar](1) NULL,
	[DPPMRolling12Months] [varchar](1) NULL,
	[CorrectAction] [varchar](1) NULL,
	[PaymentTerms] [varchar](1) NULL,
	[OnTime] [varchar](1) NULL,
	[InFull] [varchar](1) NULL,
PRIMARY KEY CLUSTERED 
(
	[VENDOR_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
