USE [Operations]
GO
/****** Object:  Table [xref].[ManufacturingForecast]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [xref].[ManufacturingForecast](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Year] [varchar](50) NULL,
	[Week] [varchar](50) NULL,
	[Plant] [varchar](50) NULL,
	[Account] [varchar](50) NULL,
	[Value] [varchar](50) NULL,
	[ContractManufacturing] [varchar](50) NULL,
 CONSTRAINT [PK_ManufacturingForecast] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
