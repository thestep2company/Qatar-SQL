USE [Operations]
GO
/****** Object:  Table [xref].[PrimeDaySKUs]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [xref].[PrimeDaySKUs](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SKU] [varchar](25) NULL
) ON [PRIMARY]
GO
