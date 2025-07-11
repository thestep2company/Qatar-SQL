USE [Forecast]
GO
/****** Object:  Table [dbo].[FactConversionRate]    Script Date: 7/8/2025 3:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactConversionRate](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FROM_CURRENCY] [nvarchar](15) NOT NULL,
	[TO_CURRENCY] [nvarchar](15) NOT NULL,
	[CONVERSION_DATE] [datetime2](7) NOT NULL,
	[CONVERSION_RATE] [float] NOT NULL,
	[INVERSE_CONVERSION_RATE] [float] NOT NULL
) ON [PRIMARY]
GO
