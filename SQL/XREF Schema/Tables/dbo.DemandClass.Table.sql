USE [XREF]
GO
/****** Object:  Table [dbo].[DemandClass]    Script Date: 7/8/2025 3:41:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DemandClass](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DEMAND CLASS CODE] [varchar](255) NULL,
	[DEMAND CLASS NAME] [varchar](255) NULL,
	[CUSTOMER - Demand Class] [varchar](255) NULL,
	[Customer Rank] [varchar](255) NULL,
	[Customer Summary] [varchar](255) NULL,
	[Finance Reporting Channel] [varchar](255) NULL,
	[Customer Top Level] [varchar](255) NULL,
	[Ecommerce Type] [varchar](255) NULL,
	[Channel Code] [varchar](50) NULL,
	[Territory] [varchar](50) NULL,
	[Distribution Reporting Channel] [varchar](50) NULL,
	[International/Domestic/ CAD] [nvarchar](255) NULL,
	[Distribution Method] [nvarchar](255) NULL,
	[Selling Method] [nvarchar](255) NULL,
	[Drop Ship/Other] [nvarchar](255) NULL,
	[Parent Customer] [nvarchar](255) NULL,
	[CreateCustomerRecord] [bit] NULL,
 CONSTRAINT [PK_DemandClass] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DemandClass] ADD  CONSTRAINT [DF_DemandClass_CreateCustomerRecord]  DEFAULT ((0)) FOR [CreateCustomerRecord]
GO
