USE [Forecast]
GO
/****** Object:  Table [dbo].[DimRevenueType]    Script Date: 7/8/2025 3:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimRevenueType](
	[RevenueID] [int] IDENTITY(1,1) NOT NULL,
	[RevenueKey] [nvarchar](20) NOT NULL,
	[RevenueName] [nvarchar](15) NULL,
	[RevenueSort] [varchar](5) NULL
) ON [PRIMARY]
GO
