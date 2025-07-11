USE [Operations]
GO
/****** Object:  Table [xref].[CustomerExtensionData]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [xref].[CustomerExtensionData](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CUSTOMER_NUM] [nvarchar](255) NULL,
	[International/Domestic/ CAD] [nvarchar](255) NULL,
	[Distribution Method] [nvarchar](255) NULL,
	[Selling Method] [nvarchar](255) NULL,
	[DropShipType] [nvarchar](255) NULL,
	[ParentCustomer] [varchar](255) NULL,
 CONSTRAINT [PK_CustomerExtensionData] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
