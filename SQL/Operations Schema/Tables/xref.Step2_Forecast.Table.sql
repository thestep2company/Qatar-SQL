USE [Operations]
GO
/****** Object:  Table [xref].[Step2_Forecast]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [xref].[Step2_Forecast](
	[Demand_Class] [varchar](50) NULL,
	[Item_Num] [varchar](50) NULL,
	[start date] [varchar](50) NULL,
	[Quantity] [varchar](50) NULL,
	[Bucket Type] [varchar](50) NULL
) ON [PRIMARY]
GO
