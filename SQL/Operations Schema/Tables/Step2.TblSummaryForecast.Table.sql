USE [Operations]
GO
/****** Object:  Table [Step2].[TblSummaryForecast]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Step2].[TblSummaryForecast](
	[ID] [int] NOT NULL,
	[Year] [int] NULL,
	[Type] [varchar](2) NULL,
	[Customer] [varchar](8) NULL,
	[Part] [varchar](25) NULL,
	[Month] [int] NULL,
	[Week] [int] NULL,
	[Quantity] [int] NULL,
	[Dollars] [money] NULL,
	[Price] [money] NULL,
	[Buyer] [varchar](50) NULL,
	[Stores] [varchar](50) NULL,
	[UserAdded] [varchar](50) NULL,
	[DateAdded] [datetime] NOT NULL,
	[UserMod] [varchar](50) NULL,
	[DateMod] [datetime] NOT NULL,
	[StartDate] [datetime] NOT NULL,
 CONSTRAINT [PK_TblSummaryForecast] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Step2].[TblSummaryForecast] ADD  DEFAULT (getdate()) FOR [StartDate]
GO
