USE [Operations]
GO
/****** Object:  Table [xref].[CommissionsSalesRep]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [xref].[CommissionsSalesRep](
	[Number] [float] NULL,
	[Customer] [nvarchar](255) NULL,
	[Sales Representative] [nvarchar](255) NULL
) ON [PRIMARY]
GO
