USE [Operations]
GO
/****** Object:  Table [xref].[CustomerDemandClass]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [xref].[CustomerDemandClass](
	[CustomerKey] [nvarchar](30) NOT NULL,
	[DemandClass] [nvarchar](30) NULL
) ON [PRIMARY]
GO
