USE [Forecast]
GO
/****** Object:  Table [dbo].[DimDemandClass]    Script Date: 7/8/2025 3:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimDemandClass](
	[DemandClassID] [bigint] IDENTITY(1,1) NOT NULL,
	[DemandClassKey] [nvarchar](255) NOT NULL,
	[DemandClassName] [varchar](255) NOT NULL,
	[DemandClassDesc] [varchar](255) NOT NULL,
	[Customer Rank] [varchar](255) NOT NULL,
	[Customer Summary] [varchar](255) NOT NULL,
	[Finance Reporting Channel] [varchar](255) NOT NULL,
	[Customer Top Level] [varchar](255) NOT NULL,
	[Ecommerce Type] [varchar](255) NOT NULL,
	[Territory] [varchar](50) NOT NULL,
	[Channel Code] [varchar](50) NOT NULL,
	[Distribution Reporting Channel] [varchar](255) NOT NULL,
	[Selling Method] [nvarchar](255) NULL,
	[Drop Ship/Other] [nvarchar](255) NULL,
	[Parent Customer] [nvarchar](255) NULL,
	[International/Domestic/ CAD] [nvarchar](255) NULL,
	[Distribution Method] [nvarchar](255) NULL,
	[CreateCustomerRecord] [bit] NULL
) ON [PRIMARY]
GO
