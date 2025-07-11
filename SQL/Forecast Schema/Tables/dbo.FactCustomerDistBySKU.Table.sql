USE [Forecast]
GO
/****** Object:  Table [dbo].[FactCustomerDistBySKU]    Script Date: 7/8/2025 3:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactCustomerDistBySKU](
	[SKU] [nvarchar](100) NOT NULL,
	[DEM_CLASS] [nvarchar](30) NULL,
	[ACCT_NUM] [nvarchar](50) NULL,
	[CustomerDist] [float] NULL
) ON [PRIMARY]
GO
