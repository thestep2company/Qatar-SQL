USE [XREF]
GO
/****** Object:  Table [dbo].[ProductExtensionData]    Script Date: 7/8/2025 3:41:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProductExtensionData](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Product_Key] [nvarchar](50) NOT NULL,
	[Product_Name] [nvarchar](100) NOT NULL,
	[Child_Adult] [nvarchar](50) NOT NULL,
	[Product_Line] [nvarchar](100) NOT NULL,
	[Product_Group] [nvarchar](50) NOT NULL,
	[Product Name Consolidated] [nvarchar](100) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProductExtensionData] ADD  DEFAULT ((0)) FOR [Product Name Consolidated]
GO
