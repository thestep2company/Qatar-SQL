USE [Operations]
GO
/****** Object:  Table [xref].[ProductExtensionData]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [xref].[ProductExtensionData](
	[Product_Key] [nvarchar](50) NOT NULL,
	[Product_Name] [nvarchar](100) NOT NULL,
	[Child_Adult] [nvarchar](50) NOT NULL,
	[Product_Line] [nvarchar](100) NOT NULL,
	[Product_Group] [nvarchar](50) NOT NULL,
	[Product Name Consolidated] [nvarchar](100) NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [xref].[ProductExtensionData] ADD  DEFAULT ((0)) FOR [Product Name Consolidated]
GO
