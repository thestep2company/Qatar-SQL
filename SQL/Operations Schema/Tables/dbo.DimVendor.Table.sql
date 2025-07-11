USE [Operations]
GO
/****** Object:  Table [dbo].[DimVendor]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimVendor](
	[VendorID] [int] IDENTITY(1,1) NOT NULL,
	[VendorKey] [float] NULL,
	[VendorName] [nvarchar](240) NULL,
	[VendorDesc] [nvarchar](252) NULL,
	[VendorType] [varchar](30) NULL,
 CONSTRAINT [PK_DimVendor] PRIMARY KEY CLUSTERED 
(
	[VendorID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
