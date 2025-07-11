USE [XREF]
GO
/****** Object:  Table [dbo].[CustomerExtensionData]    Script Date: 7/8/2025 3:41:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CustomerExtensionData](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CUSTOMER_NUM] [nvarchar](255) NOT NULL,
	[International/Domestic/ CAD] [nvarchar](255) NOT NULL,
	[Distribution Method] [nvarchar](255) NOT NULL,
	[Selling Method] [nvarchar](255) NOT NULL,
	[DropShipType] [nvarchar](255) NOT NULL,
	[ParentCustomer] [nvarchar](250) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
